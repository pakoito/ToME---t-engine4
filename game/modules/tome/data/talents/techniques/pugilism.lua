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
	name = "Striking Stance",
	type = {"technique/unarmed-other", 1},
	mode = "sustained",
	hide = true,
	points = 1,
	cooldown = 12,
	tactical = { BUFF = 2 },
	type_no_req = true,
	getCriticalPower = function(self, t) return 10 + self:getDex(20) end,
	getDamage = function(self, t) return 20 + self:getDex(20) end,
	activate = function(self, t)
		cancelStances(self)
		local ret = {
			critpower = self:addTemporaryValue("combat_critical_power", t.getCriticalPower(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_critical_power", p.critpower)
		return true
	end,
	info = function(self, t)
		local critpower = t.getCriticalPower(self, t)
		local damage = t.getDamage(self, t)
		return ([[Increases your critical damage multiplier by %d%% and the damage multiplier of your pugilism talents by %d%%.
		The bonuses will scale with the Dexterity stat.]]):
		format(critpower, damage)
	end,
}

newTalent{
	name = "Double Strike",
	type = {"technique/pugilism", 1},
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 3,
	stamina = 5,
	message = "@Source@ throws two quick punches.",
	tactical = { ATTACK = 2 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.3, 0.7) + getStrikingStyle(self, dam) end,
	-- Learn the appropriate stance
	on_learn = function(self, t)
		if not self:knowTalent(self.T_STRIKING_STANCE) then
			self:learnTalent(self.T_STRIKING_STANCE, true)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:unlearnTalent(self.T_STRIKING_STANCE)
		end
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		
		-- force stance change
		if target and not self:isTalentActive(self.T_STRIKING_STANCE) then	
			self:forceUseTalent(self.T_STRIKING_STANCE, {ignore_energy=true, ignore_cd = true})
		end
		
		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end
		
		local hit1 = self:attackTarget(target, nil, t.getDamage(self, t), true)
		local hit2 = self:attackTarget(target, nil, t.getDamage(self, t), true)
				
		if hit1 then
			self:buildCombo()
		end
		
		if hit2 then
			self:buildCombo()
		end
				
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Two quick punches that deal %d%% damage each.
		Each jab that connects will earn one combo point.]])
		:format(damage)
	end,
}

newTalent{
	name = "Body Shot",
	type = {"technique/pugilism", 2},
	require = techs_dex_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	stamina = 10,
	message = "@Source@ throws a body shot.",
	tactical = { ATTACK = 2, DISABLE = 2 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.5) + getStrikingStyle(self, dam) end,
	getDuration = function(self, t) return 1 + math.floor(self:getTalentLevel(t)) end,
	getDrain = function(self, t) return self:getTalentLevel(t) * 5 end,
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
			-- try to daze
			if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, t.getDuration(self, t), {})
			else
				game.logSeen(target, "%s resists the body shot!", target.name:capitalize())
			end
			
			target:incStamina(- t.getDrain(self, t))
			self:buildCombo()
			
		end
				
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local drain = t.getDrain(self, t)
		local daze = t.getDuration(self, t)
		return ([[A punch to the body that deals %d%% damage, drains %d of the target's stamina, and potentially dazes the target for %d turns.
		The daze chance will increase with the strength stat.
		If the blow connects it will earn one combo point.]])
		:format(damage, drain, daze)
	end,
}

newTalent{
	name = "Rushing Strike",
	type = {"technique/pugilism", 3},
	require = techs_dex_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	message = "@Source@ throws a rushing punch!",
	range = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)/2) end,
	stamina = 8,
	tactical = { ATTACK = 2, DISABLE = 2, CLOSEIN = 2 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.4)  + getStrikingStyle(self, dam) end,
	getDuration = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "You can not do that currently.") return end
	
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > self:getTalentRange(t) then return nil end

		-- bonus damage for charging
		local charge  = math.floor((core.fov.distance(self.x, self.y, x, y)) -1) / 5
		
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
				
		-- force stance change
		if target and not self:isTalentActive(self.T_STRIKING_STANCE) then	
			self:forceUseTalent(self.T_STRIKING_STANCE, {ignore_energy=true, ignore_cd = true})
		end
		
		-- break grabs
		self:breakGrapples()
		
		if math.floor(core.fov.distance(self.x, self.y, x, y)) == 1 then
			local hit =  self:attackTarget(target, nil, t.getDamage(self, t), true)

			-- Try to stun !
			if hit then
				
				if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {})
				else
					game.logSeen(target, "%s resists the stun!", target.name:capitalize())
				end
		
				self:buildCombo()
			end
			
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Attacks the target with a vicious rushing strike that deals %d%% and may stun the target for %d turns.  If the target is at range you'll rush towards them and deal 20%% bonus damage per tile traveled.
		This attack will remove any grapples you're maintaining, switch your stance to Striking Stance, and earn one combo point if the blow connects.
		The stun chance will increase with the strength stat.]])
		:format(damage, duration)
	end,
}

newTalent{
	name = "Flurry of Fists",
	type = {"technique/pugilism", 4},
	require = techs_dex_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 24,
	stamina = 15,
	message = "@Source@ lashes out with a flurry of fists.",
	tactical = { ATTACK = 2 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1) + getStrikingStyle(self, dam) end,
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
		
		
		local hit1 = self:attackTarget(target, nil, t.getDamage(self, t), true)
		local hit2 = self:attackTarget(target, nil, t.getDamage(self, t), true)
		local hit3 = self:attackTarget(target, nil, t.getDamage(self, t), true)
				
		if hit1 then
			self:buildCombo()
		end
		
		if hit2 then
			self:buildCombo()
		end
		
		if hit3 then
			self:buildCombo()
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Lashes out at the target with three quick punches that each deal %d%% damage.
		Each punch that connects will earn one combo point.]])
		:format(damage)
	end,
}