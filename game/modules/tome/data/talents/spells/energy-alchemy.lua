-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org
local Object = require "engine.Object"

newTalent{
	name = "Lightning Infusion",
	type = {"spell/energy-alchemy", 1},
	mode = "sustained",
	require = spells_req_high1,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getIncrease = function(self, t) return self:combatTalentScale(t, 0.05, 0.25) * 100 end,
	activate = function(self, t)
		cancelAlchemyInfusions(self)
		game:playSoundNear(self, "talents/arcane")
		local ret = {}
		self:talentTemporaryValue(ret, "inc_damage", {[DamageType.LIGHTNING] = t.getIncrease(self, t)})
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[When you throw your alchemist bombs, you infuse them with lightning damage that can daze your foes.
		In addition all lightning damage you do is increased by %d%%.]]):
		format(daminc)
	end,
}

newTalent{
	name = "Dynamic Recharge",
	type = {"spell/energy-alchemy", 2},
	require = spells_req_high2,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return math.floor(self:combatTalentLimit(t, 100, 20, 75)) end,
	getNb = function(self, t) return self:getTalentLevel(t) <= 6 and 1 or 2 end,
	applyEffect = function(self, t, golem)
		local tids = table.keys(golem.talents_cd)
		local did_something = false
		local nb = t.getNb(self, t)
		for _, tid in ipairs(tids) do
			if golem.talents_cd[tid] > 0 and rng.percent(t.getChance(self, t)) then
				golem.talents_cd[tid] = golem.talents_cd[tid] - nb
				if golem.talents_cd[tid] <= 0 then golem.talents_cd[tid] = nil end
				did_something = true
			end
		end
		if did_something then
			game.logSeen(golem, "%s is energized by the attack, reducing some talent cooldowns!", golem.name:capitalize())
		end
	end,
	info = function(self, t)
		return ([[While Lightning Infusion is active, your bombs energize your golem.
		All talents on cooldown on your golem have %d%% chance to be reduced by %d.]]):
		format(t.getChance(self, t), t.getNb(self, t))
	end,
}

newTalent{
	name = "Thunderclap",
	type = {"spell/energy-alchemy",3},
	require = spells_req_high3,
	points = 5,
	mana = 40,
	cooldown = 12,
	requires_target = true,
	tactical = { DISABLE = { disarm = 1 }, ATTACKAREA={PHYSICAL=1, LIGHTNING=1} },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 8)) end,
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.03) * self:getTalentLevel(t), 2, 0, 7, 8)) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 250) / 2 end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo then
			game.logPlayer(self, "You need to ready alchemist gems in your quiver.")
			return
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		ammo = self:removeObject(self:getInven("QUIVER"), 1)
		if not ammo then return end

		local dam = self:spellCrit(t.getDamage(self, t))
		local affected = {}
		self:project(tg, x, y, function(px, py)
			local actor = game.level.map(px, py, Map.ACTOR)
			if not actor or affected[actor] then return end
			affected[actor] = true

			DamageType:get(DamageType.PHYSICAL).projector(self, px, py, DamageType.PHYSICAL, dam)
			DamageType:get(DamageType.LIGHTNING).projector(self, px, py, DamageType.LIGHTNING, dam)
			if actor:canBe("disarm") then
 				actor:setEffect(actor.EFF_DISARMED, t.getDuration(self, t), {src=self, apply_power=self:combatSpellpower()})
 			end
 			if actor:canBe("knockback") then
  				actor:knockback(self.x, self.y, 3)
  				actor:crossTierEffect(actor.EFF_OFFBALANCE, self:combatSpellpower())
  			end
		end, dam)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "gravity_breath", {radius=tg.radius, tx=x-self.x, ty=y-self.y, allow=core.shader.allow("distort")})
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[By crushing an alchemist gem you generate a thunderclap in a cone of radius %d dealing %0.2f physical damage and %0.2f lightning damage.
		All creatures caught inside are knocked back and disarmed for %d turns.
		The duration and damage will increase with your Spellpower.]]):format(radius, damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), damDesc(self, DamageType.LIGHTNING, t.getDamage(self, t)), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Living Lightning",
	type = {"spell/energy-alchemy",4},
	require = spells_req_high4,
	mode = "sustained",
	cooldown = 40,
	sustain_mana = 100,
	points = 5,
	range = function(self, t) return math.ceil(self:combatTalentLimit(t, 6, 1, 3)) end,
	tactical = { BUFF=1 },
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.05, 0.15, 0.90) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 70) end,
	getTurn = function(self, t) return util.bound(50 + self:combatTalentSpellDamage(t, 5, 500) / 10, 50, 160) end,
	callbackOnActBase = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 6, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t, selffire=self:spellFriendlyFire()}
		for i = 1, 1 do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.LIGHTNING, self:spellCrit(t.getDamage(self, t)))
			if core.shader.active() then game.level.map:particleEmitter(a.x, a.y, tg.radius, "ball_lightning_beam", {radius=1, tx=x, ty=y}, {type="lightning"})
			else game.level.map:particleEmitter(a.x, a.y, tg.radius, "ball_lightning_beam", {radius=1, tx=x, ty=y}) end
			game:playSoundNear(self, "talents/lightning")
		end
	end,
	callbackOnAct = function(self, t)
		local p = self:isTalentActive(t.id)
		if not p then return end
		if not p.last_life then p.last_life = self.life end
		local min = self.max_life * 0.2
		if self.life <= p.last_life - min then
			game.logSeen(self, "#LIGHT_STEEL_BLUE#%s is energized by all the damage taken!", self.name:capitalize())
			self.energy.value = self.energy.value + (t.getTurn(self, t) * game.energy_to_act / 100)
		end
		p.last_life = self.life
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/lightning")
		local ret = {name = self.name:capitalize().."'s "..t.name}
		self:talentTemporaryValue(ret, "movement_speed", t.getSpeed(self, t))
		ret.last_life = self.life
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local speed = t.getSpeed(self, t) * 100
		local dam = t.getDamage(self, t)
		local turn = t.getTurn(self, t)
		local range = self:getTalentRange(t)
		return ([[Infuse your body with lightning energy, bolstering your movement speed by +%d%%.
		Each turn, a foe within range %d will be struck by lightning and be dealt %0.1f Lightning damage.
		In addition, damage to your health will energize you.
		At the start of each turn in which you have lost at least %d life (20%% of your maximum life) since your last turn, you will gain %d%% of a turn.
		The effects increase with your Spellpower.]]):
		format(speed, range, damDesc(self, DamageType.LIGHTNING, t.getDamage(self, t)), self.max_life * 0.2, turn)
	end,
}
