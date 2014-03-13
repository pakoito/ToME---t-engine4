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
	name = "Juggernaut",
	type = {"technique/superiority", 1},
	require = techs_req_high1,
	points = 5,
	random_ego = "attack",
	cooldown = 40,
	stamina = 50,
	no_energy = true,
	tactical = { DEFEND = 2 },
	critResist = function(self, t) return self:combatTalentScale(t, 8, 20, 0.75) end,
	getResist = function(self, t) return self:combatTalentScale(t, 15, 35) end,
	action = function(self, t)
		self:setEffect(self.EFF_JUGGERNAUT, 20, {power=t.getResist(self, t), crits=t.critResist(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Concentrate on the battle, ignoring some of the damage you take.
		Improves physical damage reduction by %d%% and provides %d%% chances to shrug off critical damage for 20 turns.]]):
		format(t.getResist(self,t), t.critResist(self, t))
	end,
}

newTalent{
	name = "Onslaught",
	type = {"technique/superiority", 2},
	require = techs_req_high2,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	no_energy = true,
	sustain_stamina = 10,
	tactical = { BUFF = 2 },
	range = function(self,t) return math.floor(self:combatTalentLimit(t, 10, 1, 5)) end, -- Limit KB range to <10
	activate = function(self, t)
		return {
			onslaught = self:addTemporaryValue("onslaught", t.range(self,t)), 
			stamina = self:addTemporaryValue("stamina_regen", -1),
		}
	end,

	deactivate = function(self, t, p)
		self:removeTemporaryValue("onslaught", p.onslaught)
		self:removeTemporaryValue("stamina_regen", p.stamina)
		return true
	end,
	info = function(self, t)
		return ([[Take an offensive stance. As you walk through your foes, you knock them all back in an frontal arc (up to %d grids).
		This consumes stamina rapidly (-1 stamina/turn).]]):
		format(t.range(self, t))
	end,
}

newTalent{
	name = "Battle Call",
	type = {"technique/superiority", 3},
	require = techs_req_high3,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 30,
	tactical = { CLOSEIN = 2 },
	range = 0,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t, 3, 7))
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if tx and ty and target:canBe("teleport") then
				target:move(tx, ty, true)
				game.logSeen(target, "%s is called to battle!", target.name:capitalize())
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Call all foes in a radius of %d around you into battle, getting them into melee range in an instant.]]):format(t.radius(self,t))
	end,
}

newTalent{
	name = "Shattering Impact",
	type = {"technique/superiority", 4},
	require = techs_req_high4,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 40,
	tactical = { BUFF = 2 },
	weaponDam = function(self, t) return (self:combatTalentLimit(t, 1, 0.38, 0.6)) end, -- Limit < 100% weapon damage
	--Note: Shattering impact effect handled in mod.class.interface.Combat.lua : _M:attackTargetWith
	activate = function(self, t)
		return {
			dam = self:addTemporaryValue("shattering_impact", t.weaponDam(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("shattering_impact", p.dam)
		return true
	end,
	info = function(self, t)
		return ([[Put all of your strength into your weapon blows, creating shockwaves that deal %d%% Physical weapon damage to all nearby targets.  Only one shockwave will be created per action, and the primary target does not take extra damage.
		Each shattering impact will drain 8 stamina.]]):
		format(100*t.weaponDam(self, t))
	end,
}
