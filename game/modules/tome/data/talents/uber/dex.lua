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

uberTalent{
	name = "Through The Crowd",
	require = { special={desc="Have had at least 6 party members at the same time", fct=function(self)
		return self:attr("huge_party")
	end} },
	mode = "sustained",
	on_learn = function(self, t)
		self:attr("bump_swap_speed_divide", 10)
	end,
	on_unlearn = function(self, t)
		self:attr("bump_swap_speed_divide", -10)
	end,
	callbackOnAct = function(self, t)
		local nb_friends = 0
		local act
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			if act and self:reactionToward(act) > 0 and self:canSee(act) then nb_friends = nb_friends + 1 end
		end
		if nb_friends > 1 then
			nb_friends = math.min(nb_friends, 5)
			self:setEffect(self.EFF_THROUGH_THE_CROWD, 4, {power=nb_friends * 10})
		end
	end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "nullify_all_friendlyfire", 1)
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[You are used to a crowded party:
		- you can swap places with friendly creatures in just one tenth of a turn as a passive effect.
		- you can never damage your friends or neutral creatures while this talent is active.
		- you love being surrounded by friends; for each friendly creature in sight you gain +10 to all saves]])
		:format()
	end,
}

uberTalent{
	name = "Swift Hands",
	mode = "passive",
	on_learn = function(self, t)
		self:attr("quick_weapon_swap", 1)
		self:attr("quick_equip_cooldown", 1)
		self:attr("quick_wear_takeoff", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("quick_weapon_swap", -1)
		self:attr("quick_equip_cooldown", -1)
		self:attr("quick_wear_takeoff", -1)
	end,
	info = function(self, t)
		return ([[You have very agile hands; swapping equipment sets (default q key) takes no time, nor does equipping/unequipping items.
		The free item switch may only happen once per turn.
		The cooldown for equipping activatable equipment is removed.]])
		:format()
	end,
}

uberTalent{
	name = "Windblade",
	mode = "activated",
	require = { special={desc="Have dealt over 50000 damage with dual wielded weapons", fct=function(self) return self.damage_log and self.damage_log.weapon.dualwield and self.damage_log.weapon.dualwield >= 50000 end} },
	cooldown = 12,
	radius = 4,
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
				local hit = self:attackTarget(target, nil, 3.2, true)
				if hit and target:canBe("disarm") then
					target:setEffect(target.EFF_DISARMED, 4, {})
				end
			end
		end)

		return true
	end,
	info = function(self, t)
		return ([[You spin madly, generating a sharp gust of wind with your weapons that deals 320%% weapon damage to all foes within radius 4 and disarms them for 4 turns.]])
		:format()
	end,
}

uberTalent{
	name = "Windtouched Speed",
	mode = "passive",
	require = { special={desc="Know at least 20 talent levels of equilibrium-using talents", fct=function(self) return knowRessource(self, "equilibrium", 20) end} },
	on_learn = function(self, t)
		self:attr("global_speed_add", 0.2)
		self:attr("avoid_pressure_traps", 1)
		self:recomputeGlobalSpeed()
	end,
	on_unlearn = function(self, t)
		self:attr("global_speed_add", -0.2)
		self:attr("avoid_pressure_traps", -1)
		self:recomputeGlobalSpeed()
	end,
	info = function(self, t)
		return ([[You are attuned wih Nature, and she helps you in your fight against the arcane forces.
		You gain 20%% permanent global speed and do not trigger pressure traps.]])
		:format()
	end,
}

uberTalent{
	name = "Giant Leap",
	mode = "activated",
	require = { special={desc="Have dealt over 50000 damage with any weapon or unarmed", fct=function(self) return 
		self.damage_log and (
			(self.damage_log.weapon.twohanded and self.damage_log.weapon.twohanded >= 50000) or
			(self.damage_log.weapon.shield and self.damage_log.weapon.shield >= 50000) or
			(self.damage_log.weapon.dualwield and self.damage_log.weapon.dualwield >= 50000) or
			(self.damage_log.weapon.other and self.damage_log.weapon.other >= 50000)
		)
	end} },
	cooldown = 20,
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
				local hit = self:attackTarget(target, nil, 2, true)
				if hit and target:canBe("stun") then
					target:setEffect(target.EFF_DAZED, 3, {})
				end
			end
		end)

		return true
	end,
	info = function(self, t)
		return ([[You accurately jump to the target and deal 200%% weapon damage to all foes within radius 1 on impact as well as dazing them for 3 turns.]])
		:format()
	end,
}

uberTalent{
	name = "Crafty Hands",
	mode = "passive",
	require = { special={desc="Know Imbue Item to level 5", fct=function(self)
		return self:getTalentLevelRaw(self.T_IMBUE_ITEM) >= 5
	end} },
	info = function(self, t)
		return ([[You are very crafty. You can now also embed gems into helms and belts.]])
		:format()
	end,
}

uberTalent{
	name = "Roll With It",
	mode = "sustained",
	cooldown = 10,
	tactical = { ESCAPE = 1 },
	require = { special={desc="Have been knocked around at least 50 times", fct=function(self) return self:attr("knockback_times") and self:attr("knockback_times") >= 50 end} },
	-- Called by default projector in mod.data.damage_types.lua
	getMult = function(self, t) return self:combatLimit(self:getDex(), 0.7, 0.9, 50, 0.85, 100) end, -- Limit > 70% damage taken
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "knockback_on_hit", 1)
		self:talentTemporaryValue(ret, "movespeed_on_hit", {speed=3, dur=1})
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[You have learned to take a few hits when needed and can flow with the tide of battle.
		So long as you can move, you find a way to dodge, evade, deflect or otherwise reduce physical damage against you by %d%%.
		Once per turn, when you get hit by a melee or archery attack you move back one tile for free and gain 200%% movement speed for a turn.
		The damage avoidance scales with your Dexterity and applies after resistances.]])
		:format(100*(1-t.getMult(self, t)))
	end,
}

uberTalent{
	name = "Vital Shot",
	no_energy = "fake",
	cooldown = 10,
	range = archery_range,
	require = { special={desc="Have dealt over 50000 damage with ranged weapons", fct=function(self) return self.damage_log and self.damage_log.weapon.archery and self.damage_log.weapon.archery >= 50000 end} },
	tactical = { ATTACK = { weapon = 3 }, DISABLE = 3 },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, 5, {apply_power=self:combatAttack()})
		end
		target:setEffect(target.EFF_CRIPPLE, 5, {speed=0.50, apply_power=self:combatAttack()})
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=4.5})
		return true
	end,
	info = function(self, t)
		return ([[You fire a shot straight at your enemy's vital areas, wounding them terribly.
		Enemies hit by this shot will take 450%% weapon damage and will be stunned and crippled (losing 50%% physical, magical and mental attack speeds) for five turns due to the devastating impact of the shot.
		The stun and cripple chances increase with your Accuracy.]]):format()
	end,
}
