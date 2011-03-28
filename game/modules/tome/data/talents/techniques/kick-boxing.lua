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
	name = "Push Kick",
	type = {"unarmed/kick-boxing", 1},
	require = mart_dex_req1,
	points = 5,
	cooldown = 6,
	stamina = 6,
	tactical = { ATTACK = 2, ESCAPE = 2 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentStatDamage(t, "str", 20, 200) * (1 + getStrikingStyle(self, dam)) end,
	getPush = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)/4) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		
		local hit = target:checkHit(self:combatAttack(), target:combatDefense(), 0, 95, 5 - self:getTalentLevel(t) / 2)
	--	local hit = self:attackTarget(target, nil, nil, true)
		
		-- Try to knockback !
		if hit then
			local can = function(target)
				if target:checkHit(self:combatAttack(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
					self:project(target, target.x, target.y, DamageType.PHYSICAL, t.getDamage(self, t), nil, target)
					return true
				else
					self:project(target, target.x, target.y, DamageType.PHYSICAL, t.getDamage(self, t), nil, target)
					game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
				end
					
			end
			
			if can(target) then target:knockback(self.x, self.y, t.getPush(self, t), can) end
				
			-- move the attacker back and build combo point
			self:knockback(target.x, target.y, 1)
			self:buildCombo()
		else
			game.logSeen(target, "%s misses %s.", self.name:capitalize(), target.name:capitalize())
		end
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local push =t.getPush(self, t)
		return ([[A push kick that knocks the target back %d tiles, moves you back 1 tile, and inflicts %0.2f physical damage.  If another creature is in the way that creature will be affected too.  Targets knocked into other targets may take extra damage.
		The damage will scale with the Strength stat.
		Builds one combo point.]])
		:format(push, damDesc(self, DamageType.PHYSICAL, (damage)))
	end,
}

newTalent{
	name = "Uppercut3",
	type = {"unarmed/kick-boxing", 2},
	require = mart_dex_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 10,
	tactical = { ATTACK = 2 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.5) + getStrikingStyle(self, dam) end,
	getDamageTwo = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 2.1) + getStrikingStyle(self, dam) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		
		-- extra damage vs. grappled targets
		if target:isGrappled(self) then
			hit = self:attackTarget(target, nil, t.getDamageTwo(self, t), true)
		else
			hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		end
				
		-- combo point
		if hit then
			self:buildCombo()
		end
			
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local damagetwo = t.getDamageTwo(self, t) * 100
		return ([[Attack the target with a rising knee strike that deals %d%% damage or %d%% damage against grappled targets.
		If the attack lands it will build one combo point.]])
		:format(damage, damagetwo)
	end,
}

newTalent{
	name = "Spinning Backhand3",
	type = {"unarmed/kick-boxing", 3},
	require = mart_dex_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 18,
	stamina = 20,
	range = function(self, t) return 2 + math.floor(self:getTalentLevel(t)/3) end,
	tactical = { ATTACKAREA = 2, CLOSEIN = 1 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.7) + getStrikingStyle(self, dam) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > self:getTalentRange(t) then return nil end
		
		-- bonus damage for charging
		local charge  = math.floor((core.fov.distance(self.x, self.y, x, y)) -1) / 10
		
		-- do the rush
		local l = line.new(self.x, self.y, x, y)
		local tx, ty = self.x, self.y
		lx, ly = l()
		while lx and ly do
			if game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
			tx, ty = lx, ly
			lx, ly = l()
		end

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end
		
		-- do the backhand
		if math.floor(core.fov.distance(self.x, self.y, x, y)) == 1 then
			-- get left and right side
			local dir = util.getDir(x, y, self.x, self.y)
			local lx, ly = util.coordAddDir(self.x, self.y, dir_sides[dir].left)
			local rx, ry = util.coordAddDir(self.x, self.y, dir_sides[dir].right)
			local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

			local hit = self:attackTarget(target, nil, t.getDamage(self, t) + charge, true)
			--combo point?
			if hit then
				self:buildCombo()
			end
			
			--left hit
			if lt then
				hit2 = self:attackTarget(lt, nil, t.getDamage(self, t) + charge, true)
				--combo point?
				if hit2 then
					self:buildCombo()
				end
			end
			--right hit
			if rt then
				hit3 = self:attackTarget(rt, nil, t.getDamage(self, t) + charge, true)
				--combo point?
				if hit3 then
					self:buildCombo()
				end
			end
		end
		
		-- remove grappls
		self:breakGrapples()
			
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Attack your foes in a frontal arc with a spinning backhand doing %d%% damage.  If your not adjacent to the target you'll step forward as you spin, gaining 10%% bonus damage for each tile you move.
		This attack will remove any grapples you're maintaining.
		Earns one combo point for each target hit.]])
		:format(damage)
	end,
}

newTalent{
	name = "Expert Strikes3",
	type = {"unarmed/kick-boxing", 4},
	require = mart_dex_req4,
	mode = "sustained",
	points = 5,
	cooldown = 24,
	sustain_stamina = 50,
	tactical = { BUFF = 2 },
	no_energy = true,
	getResistPenetration = function(self, t) return 10 + self:combatTalentStatDamage(t, "dex", 10, 50) end,
	getStaminaDrain = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	getComboChance = function(self, t) return 20 * self:getTalentLevelRaw(t) end,
	on_crit = function(self, t)
		if rng.percent(t.getComboChance(self,t)) then
			self:buildCombo()
		end
	end,
	activate = function(self, t)
		local ret = {
			resist = self:addTemporaryValue("resists_pen", {[DamageType.PHYSICAL] = t.getResistPenetration(self, t)}),
			stamina_regen = self:addTemporaryValue("stamina_regen", - t.getStaminaDrain(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("resists_pen", p.resist)
		self:removeTemporaryValue("stamina_regen", p.stamina_regen)
		return true
	end,
	info = function(self, t)
		local resistpen = t.getResistPenetration(self, t)
		local drain = t.getStaminaDrain(self, t)
		local combo = t.getComboChance(self, t)
		return ([[Increases your physical resist penetration by %d%% and has a %d%% chance to grant you a combo point whenever one of your attacks is a critical hit but drains stamina quickly (-%d stamina/turn).		
		The resist penetration will scale with the Dexterity stat.]]):
		format(resistpen, combo, drain)
	end,
}