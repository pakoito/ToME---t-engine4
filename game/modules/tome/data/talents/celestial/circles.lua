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


newTalent{
	name = "Circle of Shifting Shadows",
	type = {"celestial/circles", 1},
	require = divi_req_high1,
	points = 5,
	cooldown = 20,
	negative = 10,
	no_energy = true,
	tactical = { DEFEND = 2, ATTACKAREA = {DARKNESS = 1} },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 4, 30) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, self:spellCrit(t.getDuration(self, t)),
			DamageType.SHIFTINGSHADOWS, self:spellCrit(t.getDamage(self, t)),
			self:getTalentRadius(t),
			5, nil,
			MapEffect.new{zdepth=6, overlay_particle={zdepth=6, only_one=true, type="circle", args={appear=8, oversize=0, img="darkness_celestial_circle", radius=self:getTalentRadius(t)}}, color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/darkness_effect.png"},
			nil, self:spellFriendlyFire(true)
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Creates a circle of radius %d at your feet; the circle increases your Defense by %d, and deals %0.2f darkness damage per turn to everyone else with in its radius. The circle lasts %d turns.
		The damage will increase with your Spellpower.]]):
		format(radius, damage, (damDesc (self, DamageType.DARKNESS, damage)), duration)
	end,
}

newTalent{
	name = "Circle of Blazing Light",
	type = {"celestial/circles", 2},
	require = divi_req_high2,
	points = 5,
	cooldown = 20,
	positive = 10,
	no_energy = true,
	tactical = { DEFEND = 2, ATTACKAREA = {FIRE = 0.5, LIGHT = 0.5} },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 2, 15) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		local radius = self:getTalentRadius(t)
		local tg = {type="ball", range=0, selffire=true, radius=radius, talent=t}
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, self:spellCrit(t.getDuration(self, t)),
			DamageType.BLAZINGLIGHT, self:spellCrit(t.getDamage(self, t)),
			radius,
			5, nil,
			MapEffect.new{zdepth=6, overlay_particle={zdepth=6, only_one=true, type="circle", args={appear=8, img="sun_circle", radius=self:getTalentRadius(t)}}, color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/sunlight_effect.png"},
			nil, self:spellFriendlyFire(true)
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Creates a circle of radius %d at your feet; the circle lights up affected tiles, increases your positive energy by %d each turn, and deals %0.2f light damage and %0.2f fire damage per turn to everyone else within its radius.  The circle lasts %d turns.
		The damage will increase with your Spellpower.]]):
		format(radius, 1 + (damage / 4), (damDesc (self, DamageType.LIGHT, damage)), (damDesc (self, DamageType.FIRE, damage)), duration)
	end,
}

newTalent{
	name = "Circle of Sanctity",
	type = {"celestial/circles", 3},
	require = divi_req_high3,
	points = 5,
	cooldown = 20,
	positive = 10,
	negative = 10,
	no_energy = true,
	tactical = { DEFEND = 2, ATTACKAREA = 1 },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, self:spellCrit(t.getDuration(self, t)),
			DamageType.SANCTITY, 1,
			self:getTalentRadius(t),
			5, nil,
			MapEffect.new{zdepth=6, overlay_particle={zdepth=6, only_one=true, type="circle", args={appear=8, img="sun_circle", radius=self:getTalentRadius(t)}}, color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/sunlight_effect.png"},
			nil, self:spellFriendlyFire(true)
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Creates a circle of radius %d at your feet; the circle protects you from silence effects while you remain in its radius, and silences everyone else who enters. The circle lasts %d turns.]]):
		format(radius, duration)
	end,
}

newTalent{
	name = "Circle of Warding",
	type = {"celestial/circles", 4},
	require = divi_req_high4,
	points = 5,
	cooldown = 20,
	positive = 10,
	negative = 10,
	no_energy = true,
	tactical = { DEFEND = 2, ATTACKAREA = {LIGHT = 0.5, DARKNESS = 0.5} },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 2, 20)  end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, self:spellCrit(t.getDuration(self, t)),
			DamageType.WARDING, self:spellCrit(t.getDamage(self, t)),
			self:getTalentRadius(t),
			5, nil,
			MapEffect.new{zdepth=6, overlay_particle={zdepth=6, only_one=true, type="circle", args={appear=8, oversize=0, img="moon_circle", radius=self:getTalentRadius(t)}}, color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/moonlight_effect.png"},
			nil, self:spellFriendlyFire(true)
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Creates a circle of radius %d at your feet; the circle slows incoming projectiles by %d%%, and attempts to push all creatures other then yourself out of its radius, inflicting %0.2f light damage and %0.2f darkness damage per turn as it does so.  The circle lasts %d turns.
		The effects will increase with your Spellpower.]]):
		format(radius, damage*5, (damDesc (self, DamageType.LIGHT, damage)), (damDesc (self, DamageType.DARKNESS, damage)), duration)
	end,
}

