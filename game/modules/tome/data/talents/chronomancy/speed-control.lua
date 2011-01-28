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
	name = "Entropic Shield",
	type = {"chronomancy/speed-control", 1},
	require = chrono_req1,
	points = 5,
	paradox = 5,
	cooldown = 20,
	tactical = { DEFEND = 2 },
	getPower = function(self, t) return 10 + (self:combatTalentSpellDamage(t, 10, 50)*getParadoxModifier(self, pm)) end,
	action = function(self, t)
		self:setEffect(self.EFF_ENTROPIC_SHIELD, 10, {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[You encase yourself in a shield that slows incoming projectiles by %d%% and grants you %d%% physical resistance for 10 turns.  Additionally any attacker that strikes you in melee will suffer %0.2f temporal damage.
		The effect will scale with your Paradox and Magic stat.]]):format(power, power / 2, damDesc(self, DamageType.TEMPORAL, power))
	end,
}

newTalent{
	name = "Stop",
	type = {"chronomancy/speed-control",2},
	require = chrono_req2,
	points = 5,
	paradox = 15,
	cooldown = 20,
	tactical = { DISABLE = 3 },
	range = 6,
	direct_hit = true,
	requires_target = true,
	getDuration = function(self, t) return 2 + math.ceil(((self:getTalentLevel(t) / 2)) * getParadoxModifier(self, pm)) end,
	getRadius = function(self, t) return 1 + math.floor(self:getTalentLevel(t) / 3) end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t), friendlyfire=self:spellFriendlyFire(), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.STOP, t.getDuration(self, t))
		game.level.map:particleEmitter(x, y, tg.radius, "temporal_flash", {radius=tg.radius, tx=x, ty=y})
		game:playSoundNear(self, "talents/tidalwave")
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local duration = t.getDuration(self, t)
		return ([[Attempts to stun all creatures in a radius %d ball for %d turns.
		The stun duration will scale with your Paradox.]]):
		format(radius, duration)
	end,
}

newTalent{
	name = "Slow",
	type = {"chronomancy/speed-control", 3},
	require = chrono_req3,
	points = 5,
	paradox = 10,
	cooldown = 30,
	tactical = { ATTACKAREA = 2, DISABLE = 2 },
	range = 6,
	direct_hit = true,
	requires_target = true,
	getSlow = function(self, t) return 1 - 1 / (1 + ((10 + (self:combatTalentSpellDamage(t, 10, 50) * getParadoxModifier(self, pm))) / 100)) end,
	getRadius = function (self, t) return 2 + math.floor(self:getTalentLevel(t)/4) end,
	getDuration = function(self, t) return 5 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		local _ _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.CHRONOSLOW, t.getSlow(self, t),
			t.getRadius(self, t),
			5, nil,
			{type="temporal_cloud"},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local slow = t.getSlow(self, t)
		local radius = t.getRadius(self, t)
		local duration = t.getDuration(self, t)
		return ([[Creates a time distortion in a radius of %d that lasts for %d turns, decreasing affected targets global speed by %d%% for 2 turns and inflicting %0.2f temporal damage each turn they remain in the area.
		The slow effect and damage will scale with your Paradox and Magic stat.]]):
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
		self:setEffect(self.EFF_SPEED, 8, {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[Increases the caster's global speed by %d%% for the next 8 turns.
		The speed increase will scale with your Paradox and Magic stat.]]):format(100 * power)
	end,
}
