-- ToME - Tales of Middle-Earth
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
local Object = require "engine.Object"

newTalent{
	name = "Heat",
	type = {"spell/fire-alchemy", 1},
	require = spells_req1,
	points = 5,
	mana = 10,
	cooldown = 5,
	random_ego = "attack",
	refectable = true,
	proj_speed = 20,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIREBURN, {dur=5, initial=0, dam=self:spellCrit(self:combatTalentSpellDamage(t, 25, 220))}, {type="flame"})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[Turn part of your target into fire, burning the rest for %0.2f fire damage over 5 turns.
		The damage will increase with Magic stat.]]):format(self:combatTalentSpellDamage(t, 25, 220))
	end,
}

newTalent{
	name = "Smoke Bomb",
	type = {"spell/fire-alchemy", 2},
	require = spells_req2,
	points = 5,
	mana = 80,
	cooldown = 34,
	range = 10,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=1, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local e = Object.new{
				block_sight=true,
				temporary = 2 + self:combatSpellpower(0.03) * self:getTalentLevel(t),
				x = px, y = py,
				canAct = false,
				act = function(self)
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map:remove(self.x, self.y, Map.TERRAIN+2)
						game.level:removeEntity(self)
						game.level.map:redisplay()
					end
				end,
				summoner_gain_exp = true,
				summoner = self,
			}
			game.level:addEntity(e)
			game.level.map(px, py, Map.TERRAIN+2, e)
		end, nil, {type="dark"})
		self:teleportRandom(self.x, self.y, 5)
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[Throw a smoke bomb, blocking line of sight. The smoke dissipates after %d turns.]]):format(2 + self:combatSpellpower(0.03) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Fire Storm",
	type = {"spell/fire-alchemy",3},
	require = spells_req4,
	points = 5,
	random_ego = "attack",
	mana = 40,
	cooldown = 30,
	tactical = {
		ATTACKAREA = 20,
	},
	action = function(self, t)
		local duration = 5 + self:combatSpellpower(0.05) + self:getTalentLevel(t)
		local radius = 3
		local dam = self:combatTalentSpellDamage(t, 5, 90)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.FIRE, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=200, color_bg=60, color_bb=30},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			false
		)
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[A furious fire storm rages around the caster doing %0.2f fire damage in a radius of 3 each turn for %d turns.
		The damage and duration will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 5, 90), 5 + self:combatSpellpower(0.05) + self:getTalentLevel(t))
	end,
}


newTalent{
	name = "Body of Fire",
	type = {"spell/fire-alchemy",4},
	require = spells_req4,
	mode = "sustained",
	cooldown = 40,
	sustain_mana = 250,
	points = 5,
	range = 1,
	proj_speed = 1.3,
	range = 12,
	do_fire = function(self, t)
		if self:getMana() <= 0 then
			local old = self.energy.value
			self.energy.value = 100000
			self:useTalent(self.T_BODY_OF_FIRE)
			self.energy.value = old
			return
		end

		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 5, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire"}}
		for i = 1, math.floor(self:getTalentLevel(t)) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:projectile(tg, a.x, a.y, DamageType.FIRE, self:spellCrit(self:combatTalentSpellDamage(t, 15, 70)), {type="flame"})
			game:playSoundNear(self, "talents/fire")
		end
	end,
	activate = function(self, t)
		local res = self:combatTalentSpellDamage(t, 5, 45)
		local dam = self:combatTalentSpellDamage(t, 5, 25)

		game:playSoundNear(self, "talents/fireflash")
		game.logSeen(self, "#FF8000#%s turns into pure flame!", self.name:capitalize())
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.FIRE]=dam}),
			res = self:addTemporaryValue("resists", {[DamageType.FIRE] = res}),
			drain = self:addTemporaryValue("mana_regen", -0.4 * self:getTalentLevelRaw(t)),
		}
	end,
	deactivate = function(self, t, p)
		game.logSeen(self, "#FF8000#The raging fire around %s calms down and disappears.", self.name)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("resists", p.res)
		self:removeTemporaryValue("mana_regen", p.drain)
		return true
	end,
	info = function(self, t)
		return ([[Turn your body into pure flame, increasing your fire resistance by %d%%, burning any creatures attacking you for %0.2f fire damage and projecting randomly slow moving fire bolts at targets in sight doing %0.2f fire damage.
		This powerful spell drains mana while active.
		The damage will increase with Magic stat.]]):
		format(
			self:combatTalentSpellDamage(t, 5, 45),
			self:combatTalentSpellDamage(t, 5, 25),
			self:combatTalentSpellDamage(t, 15, 70)
		)
	end,
}
