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
-- Obsolete but undeleted incase something uses it 
newTalent{
	name = "Grappling Stance",
	type = {"technique/unarmed-other", 1},
	mode = "sustained",
	hide = true,
	points = 1,
	cooldown = 12,
	tactical = { BUFF = 2 },
	type_no_req = true,
	no_npc_use = true, -- They dont need it since it auto switches anyway
	no_unlearn_last = true,
	getSave = function(self, t) return self:getStr(20, true) end,
	getDamage = function(self, t) return self:getStr(10, true) end,
	activate = function(self, t)
		cancelStances(self)
		local ret = {
			phys = self:addTemporaryValue("combat_physresist", t.getSave(self, t)),
			power = self:addTemporaryValue("combat_dam", t.getDamage(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physresist", p.phys)
		self:removeTemporaryValue("combat_dam", p.power)
		return true
	end,
	info = function(self, t)
		local save = t.getSave(self, t)
		local damage = t.getDamage(self, t)
		return ([[Increases your Physical Save by %d and your Physical Power by %d.
		The bonuses will scale with your Strength.]])
		:format(save, damage)
	end,
}

newTalent{
	name = "Clinch",
	type = {"technique/grappling", 1},
	require = techs_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 5,
	tactical = { ATTACK = 2, DISABLE = 2 },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getPower = function(self, t) return self:combatTalentPhysicalDamage(t, 20, 60) end,
	getDrain = function(self, t) return 6 end,
	getSharePct = function(self, t) return math.min(0.35, self:combatTalentScale(t, 0.05, 0.25)) end,
	getDamage = function(self, t) return 1 end,
	action = function(self, t)

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local grappled = false

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		-- end the talent without effect if the target is to big
		if self:grappleSizeCheck(target) then
			return true
		end

		-- start the grapple; this will automatically hit and reapply the grapple if we're already grappling the target
		local hit self:attackTarget(target, nil, t.getDamage(self, t), true)
		local hit2 = self:startGrapple(target)
		
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		local drain = t.getDrain(self, t)
		local share = t.getSharePct(self, t)*100
		local damage = t.getDamage(self, t)*100
		return ([[Make a melee attack for %d%% damage and then attempt to grapple a target up to one size category larger then yourself for %d turns. A grappled opponent will be unable to move, take %d damage each turn, and %d%% of the damage you receive from any source will be redirected to them.  Any movement from the target or you will break the grapple.  Maintaining a grapple drains %d stamina per turn.
		You may only grapple a single target at a time, and using any targeted unarmed talent on a target that you're not grappling will break the grapple.]])
		:format(damage, duration, power, share, drain)
	end,
}

-- I tried to keep this relatively consistent with the existing Grappling code structure, but it wound up pretty awkward as a result
newTalent{
	name = "Crushing Hold",
	type = {"technique/grappling", 2},
	require = techs_req2,
	mode = "passive",
	points = 5,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = { silence = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 5, 50) * getUnarmedTrainingBonus(self) end, -- this function shouldn't be used any more but I left it in to be safe, Clinch now handles the damage 
	getSlow = function(self, t)
		if self:getTalentLevel(self.T_CRUSHING_HOLD) >= 5 then
			return self:combatTalentPhysicalDamage(t, 0.05, 0.65)
		else
			return 0
		end
	end,
	getDamageReduction = function(self, t)
		return self:combatTalentPhysicalDamage(t, 1, 15)
	end,
	getSilence = function(self, t) -- this is a silence without an immunity check by design, if concerned about NPC use this is the talent to block
		if self:getTalentLevel(self.T_CRUSHING_HOLD) >= 3 then
			return 1
		else
			return 0
		end
	end,
	getBonusEffects = function(self, t) -- used by startGrapple in Combat.lua, essentially merges these properties and the Clinch bonuses
		return {silence = t.getSilence(self, t), slow = t.getSlow(self, t), reduce = t.getDamageReduction(self, t)}	
	end,
	info = function(self, t)
		local reduction = t.getDamageReduction(self, t)
		local slow = t.getSlow(self, t)
		
		return ([[Enhances your grapples with additional effects.  All additional effects will apply to every grapple with no additional save or resist check.
		#RED#Talent Level 1:  Reduces base weapon damage by %d
		Talent Level 3:  Silences
		Talent Level 5:  Reduces global action speed by %d%%]])
		:format(reduction, slow*100)
	end,
}

newTalent{
	name = "Take Down",
	type = {"technique/grappling", 3},
	require = techs_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 15,
	tactical = { ATTACK = { PHYSICAL = 1}, CLOSEIN = 2 },
	requires_target = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 3.7)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getTakeDown = function(self, t) return self:combatTalentPhysicalDamage(t, 10, 100) * getUnarmedTrainingBonus(self) end,
	getSlam = function(self, t) return self:combatTalentPhysicalDamage(t, 10, 400) * getUnarmedTrainingBonus(self) end,
	getDamage = function(self, t)
		return self:combatTalentWeaponDamage(t, .1, 1)
	end,
	action = function(self, t)

		-- if the target is grappled then do an attack+AoE project
		if self:hasEffect(self.EFF_GRAPPLING) then
			local target = self:hasEffect(self.EFF_GRAPPLING)["trgt"]
			local tg = {type="ball", range=1, radius=5, selffire=false}

			local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
			local slam = self:physicalCrit(t.getSlam(self, t), nil, target, self:combatAttack(), target:combatDefense())
			self:project(tg, self.x, self.y, DamageType.PHYSICAL, slam, {type="bones"})
			
			self:breakGrapples()
					
			return true
		else
			local tg = {type="hit", range=self:getTalentRange(t)}
			local x, y, target = self:getTarget(tg)
			if not x or not y or not target then return nil end
			if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		

			local grappled = false

			-- do the rush
			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			local tx, ty = self.x, self.y
			while lx and ly do
				if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
				tx, ty = lx, ly
				lx, ly, is_corner_blocked = l:step()
			end

			local ox, oy = self.x, self.y
			self:move(tx, ty, true)
			if config.settings.tome.smooth_move > 0 then
				self:resetMoveAnim()
				self:setMoveAnim(ox, oy, 8, 5)
			end

			-- breaks active grapples if the target is not grappled
			if target:isGrappled(self) then
				grappled = true
			else
				self:breakGrapples()
			end

			if core.fov.distance(self.x, self.y, x, y) == 1 then
				-- end the talent without effect if the target is to big
				if self:grappleSizeCheck(target) then
					return true
				end

				-- start the grapple; this will automatically hit and reapply the grapple if we're already grappling the target
				local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)	
				local hit2 = self:startGrapple (target)
				
			end

			return true
			end
	end,
	info = function(self, t)
		local takedown = t.getDamage(self, t)*100
		local slam = t.getSlam(self, t)
		return ([[Rushes forward and attempts to take the target to the ground, making a melee attack for %d%% damage then attempting to grapple them. If you're already grappling the target you'll instead slam them into the ground creating a radius 5 shockwave for %d physical damage and breaking your grapple.
		The grapple effects and duration will be based off your grapple talent, if you have it, and the damage will scale with your Physical Power.]])
		:format(damDesc(self, DamageType.PHYSICAL, (takedown)), damDesc(self, DamageType.PHYSICAL, (slam)))
	end,
}

newTalent{
	name = "Hurricane Throw",
	type = {"technique/grappling", 4},
	require = techs_req4,
	points = 5,
	random_ego = "attack",
	requires_target = true,
	cooldown = function(self, t)
		return 8
	end,
	stamina = 20,
	range = function(self, t)
		return 8
	end,
	radius = function(self, t)
		return 1
	end,
	getDamage = function(self, t)
		return self:combatTalentWeaponDamage(t, 1, 3.5) -- no interaction with Striking Stance so we make the base damage higher to compensate
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
	
		if self:hasEffect(self.EFF_GRAPPLING) then
			local grappled = self:hasEffect(self.EFF_GRAPPLING)["trgt"]
			
			local tg = self:getTalentTarget(t)
			local x, y, target = self:getTarget(tg)
			if not x or not y then return nil end
			local _ _, x, y = self:canProject(tg, x, y)
			
			-- if the target square is an actor, find a free grid around it instead
			if game.level.map(x, y, Map.ACTOR) then
				x, y = util.findFreeGrid(x, y, 1, true, {[Map.ACTOR]=true})
				if not x then return end
			end

			if game.level.map:checkAllEntities(x, y, "block_move") then return end

			local ox, oy = grappled.x, grappled.y
			grappled:move(x, y, true)
			if config.settings.tome.smooth_move > 0 then
				grappled:resetMoveAnim()
				grappled:setMoveAnim(ox, oy, 8, 5)
			end
			
			-- pick all targets around the landing point and do a melee attack
			self:project(tg, grappled.x, grappled.y, function(px, py, tg, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and target ~= self then
				
					local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
					self:breakGrapples()
				end
			end)
			return true

		else
			-- only usable if you have something Grappled
			return false
		end
	end,
	info = function(self, t)
		return ([[In a mighty show of strength you whirl your grappled victim around and throw them into the air causing %d%% damage to them and any nearby enemies they collide with on landing.]]):format(t.getDamage(self, t)*100)	
	end,
}
