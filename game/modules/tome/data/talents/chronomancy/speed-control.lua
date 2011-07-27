-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	name = "Celerity",
	type = {"chronomancy/speed-control", 1},
	require = chrono_req1,
	mode = "sustained",
	points = 5,
	sustain_paradox = 75,
	cooldown = 10,
	tactical = { BUFF = 1, CLOSEIN = 1, ESCAPE = 1 },
	no_energy = true,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 40) / 100 end,
	activate = function(self, t)
		local power = t.getPower(self, t)
		return {
		move = self:addTemporaryValue("movement_speed", power)
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("movement_speed", p.move)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[Increases the caster's movement speed by %d%%.  Additionally switching weapons takes no time while Celerity is active.
		The effect will scale with your Spellpower.]]):format(power * 100)
	end,
}


newTalent{
	name = "Stop",
	type = {"chronomancy/speed-control",2},
	require = chrono_req2,
	points = 5,
	paradox = 10,
	cooldown = 12,
	tactical = { ATTACKAREA = 1, DISABLE = 3 },
	range = 6,
	radius = function(self, t)
		return 1 + math.floor(self:getTalentLevel(t) / 3)
	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t}
	end,
	getDuration = function(self, t) return 2 + math.ceil(((self:getTalentLevel(t) / 2)) * getParadoxModifier(self, pm)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 170) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		x, y = checkBackfire(self, x, y)
		local grids = self:project(tg, x, y, DamageType.STOP, t.getDuration(self, t))
		self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))

		game.level.map:particleEmitter(x, y, tg.radius, "temporal_flash", {radius=tg.radius, tx=x, ty=y})
		game:playSoundNear(self, "talents/tidalwave")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[Inflicts %0.2f temporal damage and attempts to stun all creatures in a radius %d ball for %d turns.
		The stun duration will scale with your Paradox and the damage will scale with your Paradox and Spellpower.]]):
		format(damage, radius, duration)
	end,
}

newTalent{
	name = "Slow",
	type = {"chronomancy/speed-control", 3},
	require = chrono_req3,
	points = 5,
	paradox = 15,
	cooldown = 24,
	tactical = { ATTACKAREA = 2, DISABLE = 2 },
	range = 6,
	radius = function(self, t)
		return 2 + math.floor(self:getTalentLevel(t)/4)
	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getSlow = function(self, t) return math.min((10 + (self:combatTalentSpellDamage(t, 10, 50) * getParadoxModifier(self, pm))) / 100, 0.6) end,
	getDuration = function(self, t) return 5 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		x, y = checkBackfire(self, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.CHRONOSLOW, t.getSlow(self, t),
			self:getTalentRadius(t),
			5, nil,
			{type="temporal_cloud"},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local slow = t.getSlow(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[Creates a time distortion in a radius of %d that lasts for %d turns, decreasing affected targets global speed by %d%% for 2 turns and inflicting %0.2f temporal damage each turn they remain in the area.
		The slow effect and damage will scale with your Paradox and Spellpower.]]):
		format(radius, duration, 100 * slow, damDesc(self, DamageType.TEMPORAL, 100 * slow))
	end,
}

newTalent{
	name = "Haste",
	type = {"chronomancy/speed-control", 4},
	require = chrono_req4,
	points = 5,
	paradox = 20,
	cooldown = 50,
	tactical = { BUFF = 2, CLOSEIN = 2, ESCAPE = 2 },
	no_energy = true,
	getPower = function(self, t) return ((10 + (self:combatTalentSpellDamage(t, 10, 50) * getParadoxModifier(self, pm))) / 100) end,
	action = function(self, t)
		self:setEffect(self.EFF_HASTE, 8, {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[Increases the caster's global speed by %d%% and casting speed by %d%% for the next 8 turns.
		The speed increase will scale with your Paradox and Spellpower.]]):format(100 * power, 50 * power)
	end,
}
