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
	name = "Circle of Shifting Shadows",
	type = {"divine/circles", 1},
	require = divi_req_high1,
	points = 5,
	cooldown = 20,
	negative = 20,
	tactical = {
		ATTACK = 10,
		BUFF = 10,
	},
	action = function(self, t)
		local duration = 3 + math.ceil(self:getTalentLevel(t))
		radius = 2 + math.floor(self:getTalentLevelRaw(t)/2)
		local dam = self:combatTalentSpellDamage(t, 4, 30)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.SHIFTINGSHADOWS, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=75, display='', color_br=60, color_bg=10, color_bb=60},
			nil, self:spellFriendlyFire(true)
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Creates a radius %d circle at your feet that increases your defense by %d and deals %0.2f darkness damage per turn to everyone else with in its radius.  The circle lasts %d turns.
		The duration will increase with the Magic stat.]]):format(2 + math.floor(self:getTalentLevelRaw(t)/2), self:combatTalentSpellDamage(t, 4, 30), (damDesc (self, DamageType.DARKNESS, self:combatTalentSpellDamage(t, 4, 30))), 3 + math.ceil(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Circle of Blazing Light",
	type = {"divine/circles", 2},
	require = divi_req_high2,
	points = 5,
	cooldown = 20,
	positive = 20,
	tactical = {
		ATTACK = 10,
		BUFF = 10,
	},
	action = function(self, t)
		local duration = 3 + math.ceil(self:getTalentLevel(t))
		radius = 2 + math.floor(self:getTalentLevelRaw(t)/2)
		local dam = self:combatTalentSpellDamage(t, 2, 15) 
		local tg = {type="ball", range=0, friendlyfire=true, radius=radius, talent=t}
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.BLAZINGLIGHT, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=75, display='', color_br=250, color_bg=200, color_bb=10},
			nil, self:spellFriendlyFire(true)
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Creates a radius %d circle at your feet that lights up affected tiles, increases your positive energy by %d each turn, and deals %0.2f light damage and %0.2f fire damage per turn to everyone else with in its radius.  The circle lasts %d turns.
		The duration will increase with the Magic stat.]]):format(2 + math.floor(self:getTalentLevelRaw(t)/2), 1 + (self:combatTalentSpellDamage(t, 2, 15) / 4), (damDesc (self, DamageType.LIGHT, self:combatTalentSpellDamage(t, 2, 15))), (damDesc (self, DamageType.FIRE, self:combatTalentSpellDamage(t, 2, 15))), 3 + math.ceil(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Circle of Sanctity",
	type = {"divine/circles", 3},
	require = divi_req_high3,
	points = 5,
	cooldown = 20,
	positive = 20,
	negative = 20,
	tactical = {
		ATTACK = 10,
		BUFF = 10,
	},
	action = function(self, t)
		local duration = 3 + math.ceil(self:getTalentLevel(t))
		radius = 2 + math.floor(self:getTalentLevelRaw(t)/2)
		local dam = 1
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.SANCTITY, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=75, display='', color_br=150, color_bg=10, color_bb=200},
			nil, self:spellFriendlyFire(true)
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Creates a radius %d circle at your feet that protects you from silence effects while you remain in its radius and silences everyone else who enters.  The circle lasts %d turns.
		The duration will increase with the Magic stat.]]):format(2 + math.floor(self:getTalentLevelRaw(t)/2), 3 + math.ceil(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Circle of Warding",
	type = {"divine/circles", 4},
	require = divi_req_high4,
	points = 5,
	cooldown = 20,
	positive = 20,
	negative = 20,
	tactical = {
		ATTACK = 10,
		BUFF = 10,
	},
	action = function(self, t)
		local duration = 3 + math.ceil(self:getTalentLevel(t))
		radius = 2 + math.floor(self:getTalentLevelRaw(t)/2)
		local dam = self:combatTalentSpellDamage(t, 2, 20) 
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.WARDING, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=75, display='', color_br=200, color_bg=200, color_bb=200},
			nil, self:spellFriendlyFire(true)
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Creates a radius %d circle at your feet that slows incoming projectiles %d%% and attempts to push all creatures other then yourself out of its radius, inflicting %0.2f light damage and %0.2f darkness damage per turn as it does so.  The circle lasts %d turns.
		The duration will increase with the Magic stat.]]):format(2 + math.floor(self:getTalentLevelRaw(t)/2), self:combatTalentSpellDamage(t, 2, 20), (damDesc (self, DamageType.LIGHT, self:combatTalentSpellDamage(t, 2, 20))), (damDesc (self, DamageType.DARKNESS, self:combatTalentSpellDamage(t, 2, 20))), 3 + math.ceil(self:getTalentLevel(t)))
	end,
}

