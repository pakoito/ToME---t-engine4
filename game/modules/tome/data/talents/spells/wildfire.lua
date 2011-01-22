-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

newTalent{
	name = "Blastwave",
	type = {"spell/wildfire",1},
	require = spells_req_high1,
	points = 5,
	mana = 12,
	cooldown = 5,
	tactical = { ATTACKAREA = 2, DISABLE = 2, ESCAPE = 2 },
	direct_hit = true,
	requires_target = true,
	range = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 180) end,
	action = function(self, t)
		local tg = {type="ball", range=0, radius=self:getTalentRange(t), friendlyfire=false, talent=t}
		local grids = self:project(tg, self.x, self.y, DamageType.FIREKNOCKBACK, {dist=3, dam=self:spellCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_fire", {radius=tg.radius})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[A wave of fire emanates from you, knocking back anything caught inside and setting them ablaze and doing %0.2f fire damage over 3 turns.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Dancing Fires",
	type = {"spell/wildfire",2},
	require = spells_req_high2,
	points = 5,
	mana = 35,
	cooldown = 16,
	tactical = { ATTACKAREA = 2 },
	range = 10,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 240) end,
	getTargetCount = function(self, t) return math.ceil(self:getTalentLevel(t) + 2) end,
	action = function(self, t)
		local max = t.getTargetCount(self, t)
		for i, act in ipairs(self.fov.actors_dist) do
			if self:reactionToward(act) < 0 then
				local tg = {type="hit", friendlyfire=false, talent=t}
				local grids = self:project(tg, act.x, act.y, DamageType.FIREBURN, {dur=8, initial=0, dam=self:spellCrit(t.getDamage(self, t))})
				game.level.map:particleEmitter(act.x, act.y, tg.radius, "ball_fire", {radius=1})

				max = max - 1
				if max <= 0 then break end
			end
		end
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local targetcount = t.getTargetCount(self, t)
		return ([[Surround yourself in flames, setting all those in your line of sight ablaze and doing %0.2f fire damage over 8 turns.
		At most it will affect %d foes.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.FIRE, damage), targetcount)
	end,
}

newTalent{
	name = "Combust",
	type = {"spell/wildfire",3},
	require = spells_req_high3,
	points = 5,
	mana = 40,
	cooldown = 14,
	tactical = { ATTACKAREA = 1 },
	range = 7,
	requires_target = true,
	getMultiplier = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 1.5) end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=2, friendlyfire=self:spellFriendlyFire(), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local mult = t.getMultiplier(self, t)

		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			if not target:hasEffect(target.EFF_BURNING) then return end
			local p = target:hasEffect(target.EFF_BURNING)
			local dam = p.dur * p.power
			target:removeEffect(target.EFF_BURNING)

			-- Kaboom!
			dam = dam * mult
			DamageType:get(DamageType.FIRE).projector(self, tx, ty, DamageType.FIRE, dam)
		end)

		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "fireflash", {radius=tg.radius, tx=x, ty=y})

		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local mult = t.getMultiplier(self, t)
		return ([[Disrupts all fires in a radius. All targets that were burning will combust, doing all the remaining burn damage instantly.
		The combustion effect will deal %d%% of the normal burn damage.]]):format(mult * 100)
	end,
}

newTalent{
	name = "Wildfire",
	type = {"spell/wildfire",4},
	require = spells_req_high4,
	points = 5,
	mode = "sustained",
	sustain_mana = 50,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getFireDamageIncrease = function(self, t) return self:getTalentLevelRaw(t) * 2 end,
	getResistPenalty = function(self, t) return self:getTalentLevelRaw(t) * 10 end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.FIRE] = t.getFireDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.FIRE] = t.getResistPenalty(self, t)}),
			particle = self:addParticles(Particles.new("wildfire", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		return true
	end,
	info = function(self, t)
		local damageinc = t.getFireDamageIncrease(self, t)
		local ressistpen = t.getResistPenalty(self, t)
		return ([[Surround yourself with Wildfire, increasing all your fire damage by %d%% and ignoring %d%% fire resistance of your targets.]])
		:format(damageinc, ressistpen)
	end,
}
