-- Skirmisher, a class for Tales of Maj'Eyal 1.1.5
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

local sling_equipped = function(self, silent)
	if not self:hasArcheryWeapon("sling") then
		if not silent then
			game.logPlayer(self, "You must wield a sling!")
		end
		return false
	end
	return true
end

-- calc_all is so the info can show all the effects.
local sniper_bonuses = function(self, calc_all)
	local bonuses = {}
	local t = self:getTalentFromId("T_SKIRMISHER_SLING_SNIPER")
	local level = self:getTalentLevel(t)

	if level > 0 or calc_all then
		bonuses.crit_chance = math.min(25, self:combatTalentScale(t, 1, 10))
		bonuses.crit_power = math.min(.5, self:combatTalentScale(t, 0.1, 0.2))
	end
	if level >= 5 or calc_all then
		local resists_pen = math.min(30, self:combatStatScale("cun", 1, 20))
		bonuses.resists_pen = {[DamageType.PHYSICAL] = resists_pen}
	end
	return bonuses
end

-- Add the phys pen to self right before the shot hits.
local pen_on = function(self, talent, tx, ty, tg, target)
	if target and tg and tg.archery and tg.archery.resists_pen then
		self.temp_skirmisher_sling_sniper = self:addTemporaryValue("resists_pen", tg.archery.resists_pen)
	end
end

-- The action for each of the shots.
local fire_shot = function(self, t)
	local tg = {type = "hit"}

	local targets = self:archeryAcquireTargets(tg, table.clone(t.archery_target_parameters))
	if not targets then return end
	local bonuses = sniper_bonuses(self)
	local params = {mult = t.damage_multiplier(self, t)}
	if bonuses.crit_chance then params.crit_chance = bonuses.crit_chance end
	if bonuses.crit_power then params.crit_power = bonuses.crit_power end
	if bonuses.resists_pen then params.resists_pen = bonuses.resists_pen end
	self:archeryShoot(targets, t, {type = "hit", speed = 200}, params) -- Projectile speed because using "hit" with slow projectiles is infuriating
	return true
end

-- Remove the phys pen from self right after the shot is finished.
local pen_off = function(self, talent, target, x, y)
	if self.temp_skirmisher_sling_sniper then
		self:removeTemporaryValue("resists_pen", self.temp_skirmisher_sling_sniper)
	end
end

local shot_cooldown = function(self, t)
	if self:getTalentLevel(self.T_SKIRMISHER_SLING_SNIPER) >= 3 then
		return 6
	else
		return 8
	end
end

newTalent {
	short_name = "SKIRMISHER_KNEECAPPER",
	name = "Kneecapper",
	type = {"cunning/called-shots", 1},
	require = techs_cun_req1,
	points = 5,
	no_energy = "fake",
	random_ego = "attack",
	tactical = {ATTACK = {weapon = 1}, DISABLE = 1},
	stamina = 10,
	cooldown = shot_cooldown,
	requires_target = true,
	range = archery_range,
	on_pre_use = function(self, t, silent) return sling_equipped(self, silent) end,
	pin_duration = function(self, t)
		return math.floor(1 + self:getTalentLevel(t) * 0.2)
	end,
	slow_duration = function(self, t)
		return math.floor(3 + self:getTalentLevel(t) / 3)
	end,
	slow_power = function(self, t)
		return math.min(0.6, 0.1 + self:getCun(0.5, true) + self:combatTalentScale(t, 0, 0.5))
	end,
	archery_onreach = pen_on,
	archery_onmiss = pen_off,
	archery_onhit = function(self, t, target, x, y)
		target:setEffect(target.EFF_SLOW_MOVE, t.slow_duration(self, t), {power = t.slow_power(self, t), apply_power = self:combatAttack()})
		if target:canBe("pin") then
			target:setEffect(target.EFF_PINNED, t.pin_duration(self, t), {apply_power = self:combatAttack()})
		else
			game.logSeen(target, "%s resists being knocked down.", target.name:capitalize())
		end
		pen_off(self, t, target, x, y)
	end,
	archery_target_parameters = {one_shot = true},
	damage_multiplier = function(self, t)
		return self:combatTalentWeaponDamage(t, 1.5, 1.9)
	end,
	action = fire_shot,
	info = function(self, t)
		return ([[Nail your opponent in the knee for %d%% weapon damage, knocking them down (%d turn pin) and slowing their movement by %d%% for %d turns afterwards.
			This shot will pass through enemies to reach its target.]])
		:format(t.damage_multiplier(self, t) * 100,
				t.pin_duration(self, t),
				t.slow_power(self, t) * 100,
				t.slow_duration(self, t))
	end,
}

-- This serves two primary roles
-- 1.  Core high damage shot
-- 2.  Sniping off-targets like casters in any situation in potentially one shot
newTalent {
	short_name = "SKIRMISHER_THROAT_SMASHER",
	name = "Kill Shot",
	type = {"cunning/called-shots", 2},
	require = techs_cun_req2,
	points = 5,
	no_energy = "fake",
	random_ego = "attack",
	tactical = {ATTACK = {weapon = 2}},
	stamina = 35,
	cooldown = shot_cooldown,
	no_npc_use = true, -- Numbers overtuned to make sure the class has a satisfying high damage shot
	requires_target = true,
	range = archery_range,
	on_pre_use = function(self, t, silent) return sling_equipped(self, silent) end,
	getDistanceBonus = function(self, t)
		return 0.3
	end,
	getDamage = function(self, t)
		return 1
	end,
	damage_multiplier = function(self, t)
		return self:combatTalentWeaponDamage(t, 0.3, 1.5)
	end,
	archery_onreach = pen_on,
	archery_onmiss = pen_off,
	archery_onhit = function(self, t, target, x, y)
		pen_off(self, t, target, x, y)
	end,
	archery_target_parameters = {one_shot = true},
	action = function(self, t)
		local tg = {type = "hit"}

		local targets = self:archeryAcquireTargets(tg, table.clone(t.archery_target_parameters))
		if not targets then return end

		-- THIS IS WHY I HATE YOUR CODE STRUCTURE GRAYSWANDIR
		local bonuses = sniper_bonuses(self)
		local dist = core.fov.distance(self.x, self.y, targets[1].x, targets[1].y)
		local damage = t.damage_multiplier(self, t) + ( t.getDistanceBonus(self, t) * dist )

		local target = game.level.map(targets[1].x, targets[1].y, engine.Map.ACTOR)
		if not target then return end
		game.logSeen(self, "#DARK_ORCHID#%s snipes %s for %d%% weapon damage (+%d%% range bonus)!#LAST#", self.name:capitalize(), target.name:capitalize(), damage*100, t.getDistanceBonus(self, t) * dist * 100 )


		local params = {mult = damage}
		if bonuses.crit_chance then params.crit_chance = bonuses.crit_chance end
		if bonuses.crit_power then params.crit_power = bonuses.crit_power end
		if bonuses.resists_pen then params.resists_pen = bonuses.resists_pen end
		self:archeryShoot(targets, t, {type = "hit", speed = 200}, params)

		return true
	end, 
	info = function(self, t)
		return ([[Snipe a target at long range dealing %d%% damage increased by %d%% for each tile between you and the target.
			This shot will pass through enemies to reach its target.]])
		:format(t.damage_multiplier(self, t) * 100, t.getDistanceBonus(self, t)*100
				)
	end,
}

newTalent {
	short_name = "SKIRMISHER_NOGGIN_KNOCKER",
	name = "Noggin Knocker",
	type = {"cunning/called-shots", 3},
	require = techs_cun_req3,
	points = 5,
	no_energy = "fake",
	tactical = {ATTACK = {weapon = 2}, DISABLE = {stun = 2}},
	stamina = 15,
	cooldown = shot_cooldown,
	requires_target = true,
	range = archery_range,
	on_pre_use = function(self, t, silent) return sling_equipped(self, silent) end,
	damage_multiplier = function(self, t)
		return self:combatTalentWeaponDamage(t, 0.3, 0.75)
	end,
	archery_onreach = pen_on,
	archery_onmiss = pen_off,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("stun") then
			target:setEffect(target.EFF_SKIRMISHER_STUN_INCREASE, 1, {apply_power = self:combatAttack()})
		else
			game.logSeen(target, "%s resists the stunning shot!", target.name:capitalize())
		end
		pen_off(self, t, target, x, y)
	end,
	archery_target_parameters = {limit_shots = 1, multishots = 3},
	action = fire_shot,
	info = function(self, t)
		return ([[Apply directly to the forehead! Shoot 3 quick sling bullets for %d%% damage in succession into your opponent’s brow. Each bullet will try to stun or increase the target's stun duration by 1.
			This shot will pass through enemies to reach its target.]])
		:format(t.damage_multiplier(self, t) * 100)
	end,
}

newTalent {
	short_name = "SKIRMISHER_SLING_SNIPER",
	name = "Sling Sniper",
	type = {"cunning/called-shots", 4},
	require = techs_cun_req4,
	points = 5,
	no_energy = "fake",
	mode = "passive",
	info = function(self, t)
	bonuses = sniper_bonuses(self, true)
		return ([[Your mastery of called shots is unparalleled. Gain %d%% bonus critical chance and %d%% critical damage on your Called Shots. At rank 3 lowers the cooldowns of your Called Shots by 2 each. At rank 5 gain %d%% physical resist piercing with all Called Shot attacks.]])
		:format(bonuses.crit_chance,
			bonuses.crit_power * 100,
			bonuses.resists_pen[DamageType.PHYSICAL])
	end
}
