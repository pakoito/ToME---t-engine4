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

newTalent{
	name = "Bow Mastery",
	type = {"technique/archery-bow", 1},
	points = 10,
	require = { stat = { dex=function(level) return 12 + level * 3 end }, },
	mode = "passive",
	info = function(self, t)
		return ([[Increases damage done with bows by %d%%.]]):format(100 * (math.sqrt(self:getTalentLevel(t) / 10)))
	end,
}

newTalent{
	name = "Piercing Arrow",
	type = {"technique/archery-bow", 2},
	no_energy = true,
	points = 5,
	cooldown = 8,
	stamina = 15,
	require = techs_dex_req2,
	range = 20,
	requires_target = true,
	action = function(self, t)
		local targets = self:archeryAcquireTargets({type="beam"}, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, {type="beam"}, {mult=self:combatTalentWeaponDamage(t, 1, 1.5), apr=1000})
		return true
	end,
	info = function(self, t)
		return ([[You fire an arrow that cuts right through anything, piercing multiple targets if possible with nigh infinite armor penetration, doing %d%% damage.]]):format(100 * self:combatTalentWeaponDamage(t, 1, 1.5))
	end,
}

newTalent{
	name = "Dual Arrows",
	type = {"technique/archery-bow", 3},
	no_energy = true,
	points = 5,
	cooldown = 8,
	stamina = 15,
	require = techs_dex_req3,
	range = 20,
	requires_target = true,
	action = function(self, t)
		local tg = {type="ball", radius=1}
		local targets = self:archeryAcquireTargets(tg, {limit_shots=2})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1.2, 1.7)})
		return true
	end,
	info = function(self, t)
		return ([[You fire two arrows at your target, hitting it and a nearby foe if possible, doing %d%% damage.]]):format(100 * self:combatTalentWeaponDamage(t, 1.2, 1.7))
	end,
}

newTalent{
	name = "Volley of Arrows",
	type = {"technique/archery-bow", 4},
	no_energy = true,
	points = 5,
	cooldown = 12,
	stamina = 35,
	require = techs_dex_req4,
	range = 20,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="ball", radius=2 + self:getTalentLevel(t)/3, friendlyfire=false}
		local targets = self:archeryAcquireTargets(tg)
		if not targets then return end
		self:archeryShoot(targets, t, {type="bolt",friendlyfire=false}, {mult=self:combatTalentWeaponDamage(t, 0.6, 1.3)})
		return true
	end,
	info = function(self, t)
		return ([[You fire multiple arrows at the area, doing %d%% damage.]]):format(100 * self:combatTalentWeaponDamage(t, 0.6, 1.3))
	end,
}
