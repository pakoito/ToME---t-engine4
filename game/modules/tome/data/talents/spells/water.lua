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
	name = "Corrosive Vapour",
	type = {"spell/water",1},
	require = spells_req1,
	points = 5,
	random_ego = "attack",
	mana = 25,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 15,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local duration = self:getTalentLevel(t) + 2
		local radius = 3
		local dam = self:combatTalentSpellDamage(t, 4, 50)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.ACID, dam,
			radius,
			5, nil,
			{type="vapour"},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		return ([[Corrosive fumes rise from the ground doing %0.2f acid damage in a radius of 3 each turn for %d turns.
		The damage and duration will increase with the Magic stat]]):format(damDesc(self, DamageType.ACID, self:combatTalentSpellDamage(t, 4, 50)), self:getTalentLevel(t) + 2)
	end,
}

newTalent{
	name = "Freeze",
	type = {"spell/water", 2},
	require = spells_req2,
	points = 5,
	random_ego = "attack",
	mana = 14,
	cooldown = 5,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.COLD, self:spellCrit(self:combatTalentSpellDamage(t, 12, 180)), {type="freeze"})
		self:project(tg, x, y, DamageType.FREEZE, 3)
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[Condenses ambient water on a target, freezing it for a short while and damaging it for %0.2f.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.COLD, self:combatTalentSpellDamage(t, 12, 180)))
	end,
}

newTalent{
	name = "Tidal Wave",
	type = {"spell/water",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 55,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	direct_hit = true,
	action = function(self, t)
		local duration = 5 + self:combatSpellpower(0.01) * self:getTalentLevel(t)
		local radius = 1
		local dam = self:combatTalentSpellDamage(t, 5, 90)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.WAVE, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=30, color_bg=60, color_bb=200},
			function(e)
				e.radius = e.radius + 1
			end,
			false
		)
		game:playSoundNear(self, "talents/tidalwave")
		return true
	end,
	info = function(self, t)
		return ([[A wall of water rushes out from the caster doing %0.2f cold damage and %0.2f physical damage as well as knocking back targets each turn for %d turns.
	        The damage and duration will increase with the Magic stat]]):format(damDesc(self, DamageType.COLD, self:combatTalentSpellDamage(t, 5, 90)/2), damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(t, 5, 90)/2), 5 + self:combatSpellpower(0.01) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Ice Storm",
	type = {"spell/water",4},
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
			DamageType.ICE, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=30, color_bg=60, color_bb=200},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			false
		)
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[A furious ice storm rages around the caster doing %0.2f cold damage in a radius of 3 each turn for %d turns.
		It has 25%% chance to freeze damaged targets.
		The damage and duration will increase with the Magic stat]]):format(damDesc(self, DamageType.COLD, self:combatTalentSpellDamage(t, 5, 90)), 5 + self:combatSpellpower(0.05) + self:getTalentLevel(t))
	end,
}
