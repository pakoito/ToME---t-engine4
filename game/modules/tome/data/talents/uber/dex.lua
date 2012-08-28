-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

uberTalent{
	name = "Through The Crowd",
	mode = "passive",
	on_learn = function(self, t)
		self:attr("bump_swap_speed_divide", 10)
	end,
	on_unlearn = function(self, t)
		self:attr("bump_swap_speed_divide", -10)
	end,
	require = { special={desc="Have had at least 6 party members at the same time.", fct=function(self)
		return self:attr("huge_party")
	end} },
	info = function(self, t)
		return ([[You are used to a crowded party, you can swap place with friendly creatures for only one tenth of a turn.]])
		:format()
	end,
}

uberTalent{
	name = "Swift Hands",
	mode = "passive",
	on_learn = function(self, t)
		self:attr("quick_weapon_swap", 1)
		self:attr("quick_equip_cooldown", 2)
	end,
	on_unlearn = function(self, t)
		self:attr("quick_weapon_swap", -1)
		self:attr("quick_equip_cooldown", -2)
	end,
	info = function(self, t)
		return ([[You have very agile hands, swaping equipment sets (default x key) takes no turn.
		Also the cooldown for equiping activable equipment is reduced by half.]])
		:format()
	end,
}

uberTalent{
	name = "Windblade",
	mode = "activated",
	require = { special={desc="Know at least 20 talent levels of stamina using talents.", fct=function(self) return knowRessource(self, "stamina", 20) end} },
	cooldown = 20,
	stamina = 30,
	radius = 2,
	range = 1,
	tactical = { ATTACK = { PHYSICAL=2 }, DISABLE = { disarm = 2 } },
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local hit = self:attackTarget(target, nil, 1.4, true)
				if hit and target:canBe("disarm") then
					target:setEffect(target.EFF_DISARMED, 4, {})
				end
			end
		end)

		return true
	end,
	info = function(self, t)
		return ([[You spin madly in a gust of wind, dealing 140%% weapon damage to all foes in a radius 2 and disarming them for 4 turns.]])
		:format()
	end,
}

uberTalent{
	name = "Windtouched Speed",
	mode = "passive",
	require = { special={desc="Know at least 20 talent levels of equilibrium using talents.", fct=function(self) return knowRessource(self, "equilibrium", 20) end} },
	on_learn = function(self, t)
		self:attr("global_speed_add", 0.15)
		self:attr("avoid_pressure_traps", 1)
		self:recomputeGlobalSpeed()
	end,
	on_unlearn = function(self, t)
		self:attr("global_speed_add", -0.15)
		self:attr("avoid_pressure_traps", -1)
		self:recomputeGlobalSpeed()
	end,
	info = function(self, t)
		return ([[You are attuned wih Nature and she helps you in your fight against the arcane forces.
		You gain 15%% permanent global speed and avoidance of pressure traps.]])
		:format()
	end,
}

uberTalent{
	name = "Giant Leap",
	mode = "activated",
	require = { special={desc="Know at least 20 talent levels of stamina using talents.", fct=function(self) return knowRessource(self, "stamina", 20) end} },
	cooldown = 20,
	stamina = 30,
	radius = 1,
	range = 10,
	tactical = { CLOSEIN = 2, ATTACK = { PHYSICAL = 2 }, DISABLE = { daze = 1 } },
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)

		if game.level.map(x, y, Map.ACTOR) then
			x, y = util.findFreeGrid(x, y, 1, true, {[Map.ACTOR]=true})
			if not x then return end
		end

		if game.level.map:checkAllEntities(x, y, "block_move") then return end

		local ox, oy = self.x, self.y
		self:move(x, y, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end

		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local hit = self:attackTarget(target, nil, 1.3, true)
				if hit and target:canBe("stun") then
					target:setEffect(target.EFF_DAZED, 3, {})
				end
			end
		end)

		return true
	end,
	info = function(self, t)
		return ([[You jump accurately to the target, dealing 130%% weapon damage to all foes in a radius 1 on impactand dazing them for 3 turns.]])
		:format()
	end,
}

uberTalent{
	name = "Crafty Hands",
	mode = "passive",
	require = { special={desc="Know Imbue Item to level 5.", fct=function(self)
		return self:getTalentLevelRaw(self.T_IMBUE_ITEM) >= 5
	end} },
	info = function(self, t)
		return ([[You are very crafty, you can now also embed gems into your helm and belt.]])
		:format()
	end,
}

uberTalent{
	name = "Roll With It",
	mode = "sustained",
	cooldown = 10,
	tactical = { ESCAPE = 1 },
	require = { special={desc="Having been knocked around at least 50 times.", fct=function(self) return self:attr("knockback_times") and self:attr("knockback_times") >= 50 end} },
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "knockback_on_hit", 1)
		self:talentTemporaryValue(ret, "resists", {[DamageType.PHYSICAL] = 10})
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[You have learnt to take a few hits when needed, you know how to flow with them, reducing all physical damage by 10%%.
		When you get hit by melee or archery you go back one tile (this can only happen once per turn) for free.]])
		:format()
	end,
}
