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
	name = "Uppercut",
	type = {"technique/finishing-moves", 1},
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return math.floor(16 - self:getTalentLevelRaw(t) * 2) end,
	stamina = 10,
	message = "@Source@ throws a finishing uppercut.",
	tactical = { ATTACK = 2, DISABLE = 2 },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.5) end,
	getDuration = function(self, t) return 2 + (self:getCombo(combo)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		
		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end
			
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		
		if hit then
			if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {})
			else
				game.logSeen(target, "%s resists the stun!", target.name:capitalize())
			end
		end
		
		self:clearCombo()
			
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[A finishing uppercut that deals %d%% damage and attempts to stun your target for 2 turns + 1 turn per combo point you have.
		The stun chance will improve with the strength stat.
		Using this talent removes your combo points.]])
		:format(damage)
	end,
}

newTalent{
	name = "Spinning Backhand",
	type = {"technique/finishing-moves", 2},
	require = techs_dex_req2,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return math.floor(16 - self:getTalentLevelRaw(t) * 2) end,
	stamina = 12,
	range = function(self, t) return 1 + (self:getCombo(combo) or 0) end,
	message = "@Source@ lashes out with a spinning backhand.",
	tactical = { ATTACKAREA = 2, CLOSEIN = 1 },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 1.7) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > self:getTalentRange(t) then return nil end
		
		-- bonus damage for charging
		local charge  = math.floor((core.fov.distance(self.x, self.y, x, y)) -1) / 10
		local damage = t.getDamage(self, t) + charge
		
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

			local hit = self:attackTarget(target, nil, damage, true)
			
			--left hit
			if lt then
				hit2 = self:attackTarget(lt, nil, damage, true)
			end
			--right hit
			if rt then
				hit3 = self:attackTarget(rt, nil, damage, true)
			end
		end
		
		-- remove grappls
		self:breakGrapples()
		
		self:clearCombo()
			
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Attack your foes in a frontal arc with a spinning backhand doing %d%% damage.  If your not adjacent to the target you'll step forward as you spin, gaining 10%% bonus damage for each tile you move.
		The range of this attack will increase by one per combo point you have.
		This attack will remove any grapples you're maintaining and remove your combo points.]])
		:format(damage)
	end,
}

newTalent{
	name = "Relentless Strikes",
	type = {"technique/finishing-moves", 3},
	require = techs_dex_req3,
	points = 5,
	random_ego = "utility",
	cooldown = function(self, t) return math.floor(26 - self:getTalentLevelRaw(t) * 2) end,
	stamina = 20,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getStamina = function(self, t) return self:getTalentLevel(t) * 2 end,
	getDuration = function(self, t) return self:getCombo(combo) * 2 end,
	action = function(self, t)
	
		self:setEffect(self.EFF_RELENTLESS_STRIKES, t.getDuration(self, t), {power=t.getStamina(self, t)})
		
		self:clearCombo()
		
		return true
	end,
	info = function(self, t)
		local stamina = t.getStamina(self, t)
		return ([[Increases your stamina regen by %d per turn for a number of turns equal to double your combo points.  Additionally every combo point you earn during this time will reduce the cooldown on all your techniques on cooldown by 1.
		Using this talent removes your combo points.]])
		:format(stamina)
	end,
}

newTalent{
	name = "Haymaker",
	type = {"technique/finishing-moves", 4},
	require = techs_dex_req4,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return math.floor(16 - self:getTalentLevelRaw(t) * 2) end,
	stamina = 12,
	message = "@Source@ throws a wild haymaker!",
	tactical = { ATTACK = 2 },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.3, 1.7) end,
	getBonusDamage = function(self, t) return (self:getCombo(combo))/10 end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		
		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end
		
		local damage = t.getDamage(self, t) * (1 + (t.getBonusDamage(self, t) or 0))
		
		self:attackTarget(target, nil, damage, true)
		
		self:clearCombo()
			
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[A vicious finishing strike that deals %d%% damage + 10%% damage per combo point you have.
		Using this talent removes your combo points.]])
		:format(damage)
	end,
}