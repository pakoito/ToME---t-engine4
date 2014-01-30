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
	name = "Disengage",
	type = {"technique/field-control", 1},
	require = techs_dex_req1,
	points = 5,
	random_ego = "utility",
	cooldown = 12,
	stamina = 20,
	range = 7,
	tactical = { ESCAPE = 2 },
	requires_target = true,
	on_pre_use = function(self, t)
		if self:attr("never_move") then return false end
		return true
	end,
	getDist = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end

		self:knockback(target.x, target.y, t.getDist(self, t))
		return true
	end,
	info = function(self, t)
		return ([[Jump away %d grids from your target.]]):format(t.getDist(self, t))
	end,
}

newTalent{
	name = "Track",
	type = {"technique/field-control", 2},
	require = techs_dex_req2,
	points = 5,
	random_ego = "utility",
	stamina = 20,
	cooldown = 20,
	radius = function(self, t) return math.floor(self:combatScale(self:getCun(10, true) * self:getTalentLevel(t), 5, 0, 55, 50)) end,
	no_npc_use = true,
	action = function(self, t)
		local rad = self:getTalentRadius(t)
		self:setEffect(self.EFF_SENSE, 3 + self:getTalentLevel(t), {
			range = rad,
			actor = 1,
		})
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		return ([[Sense foes around you in a radius of %d for %d turns.
		The radius will increase with your Cunning.]]):format(rad, 3 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Heave",
	type = {"technique/field-control", 3},
	require = techs_dex_req3,
	points = 5,
	random_ego = "defensive",
	cooldown = 15,
	stamina = 5,
	tactical = { ESCAPE = { knockback = 1 }, DISABLE = { knockback = 3 } },
	requires_target = true,
	getDist = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- Try to knockback !
		local can = function(target)
			if target:checkHit(math.max(self:combatAttack(), self:combatPhysicalpower()), target:combatPhysicalResist(), 0, 95) and target:canBe("knockback") then -- Deprecated Checkhit call
				return true
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end

		if can(target) then 
			target:knockback(self.x, self.y, t.getDist(self, t), can)
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatPhysicalpower())
		end

		return true
	end,
	info = function(self, t)
		return ([[A mighty kick that pushes your target away %d grids.
		If another creature is in the way, it will also be pushed away.
		The Knockback chance increase with your Accuracy or your Physical Power, whichever is greater.]])
		:format(t.getDist(self, t))
	end,
}

newTalent{
	name = "Slow Motion",
	type = {"technique/field-control", 4},
	require = techs_dex_req4,
	mode = "sustained",
	points = 5,
	cooldown = 30,
	range = 10,
	sustain_stamina = 80,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		return {
			slow_projectiles = self:addTemporaryValue("slow_projectiles", math.min(90, 15 + self:getDex(10, true) * self:getTalentLevel(t))),
		}
	end,

	deactivate = function(self, t, p)
		self:removeTemporaryValue("slow_projectiles", p.slow_projectiles)
		return true
	end,
	info = function(self, t)
		return ([[Your great dexterity allows you to see incoming projectiles (spells, arrows, ...), effectively slowing them down by %d%%.]]):
		format(math.min(90, 15 + self:getDex(10, true) * self:getTalentLevel(t)))
	end,
}

