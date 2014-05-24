-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	name = "Bind",
	type = {"psionic/grip", 1},
	require = psi_cun_high1,
	points = 5,
	random_ego = "attack",
	cooldown = 25,
	psi = 10,
	tactical = { DISABLE = 2 },
	range = function(self, t)
		local r = 5
		local mult = 1 + 0.01*self:callTalent(self.T_REACH, "rangebonus")
		return math.floor(r*mult)
	end,
	getDuration = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 3, 10))
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t} end,
	action = function(self, t)
		local dur = t.getDuration(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(self.EFF_PSIONIC_BIND, dur, {power=1, apply_power=self:combatMindpower()})
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		return ([[Bind the target in crushing bands of telekinetic force, immobilizing it for %d turns. 
		The duration will improve with your Mindpower.]]):
		format(dur)
	end,
}

newTalent{
	name = "Greater Telekinetic Grasp",
	type = {"psionic/grip", 4},
	require = psi_cun_high4,
	hide = true,
	points = 5,
	mode = "passive",
	getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.15, 0.50) end, -- Limit < 100%
	stat_sub = function(self, t) -- called by _M:combatDamage in mod\class\interface\Combat.lua
		return self:combatTalentScale(t, 0.64, 0.80)
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "disarm_immune", t.getImmune(self, t))
	end,
	info = function(self, t)
		local boost = 100 * t.stat_sub(self, t)
		return ([[Use finely controlled forces to augment both your flesh-and-blood grip, and your telekinetic grip. This does the following:
		Increases disarm immunity by %d%%.
		Allows %d%% of Willpower and Cunning (instead of the usual 60%%) to be substituted for Strength and Dexterity for the purposes of determining damage done by telekinetically-wielded weapons.
		At talent level 5, telekinetically wielded gems and mindstars will be treated as one material level higher than they actually are.
		]]):
		format(t.getImmune(self, t)*100, boost)
	end,
}