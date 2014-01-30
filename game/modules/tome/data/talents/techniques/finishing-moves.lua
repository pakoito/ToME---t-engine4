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
	name = "Uppercut",
	type = {"technique/finishing-moves", 1},
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 12,
	message = "@Source@ throws a finishing uppercut.",
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.8) + getStrikingStyle(self, dam) end,
	getDuration = function(self, t, comb) return math.ceil(self:combatTalentScale(t, 1, 5) * (0.25 + comb/5)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t, self:getCombo(combo)), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s resists the stun!", target.name:capitalize())
			end
		end

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local stun = t.getDuration(self, t, 0)
		local stunmax = t.getDuration(self, t, 5)
		return ([[A finishing uppercut that deals %d%% damage, and attempts to stun your target for %d to %d turns, depending on the amount of combo points you've accumulated.
		The stun chance will improve with your Physical Power.
		Using this talent removes your combo points.]])
		:format(damage, stun, stunmax)
	end,
}

newTalent{
	name = "Concussive Punch",
	type = {"technique/finishing-moves", 2},
	require = techs_dex_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 10,
	message = "@Source@ throws a concussive punch.",
	tactical = { ATTACK = { weapon = 2 }, },
	requires_target = true,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.1, 0.8) + getStrikingStyle(self, dam) end,
	getAreaDamage = function(self, t) return self:combatTalentStatDamage(t, "str", 10, 300) * (1 + getStrikingStyle(self, dam)) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.25, 2.25)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hit then
			local tg = {type="ball", range=1, radius=self:getTalentRadius(t), selffire=false, talent=t}
			local damage = t.getAreaDamage(self, t) * (0.25 + (self:getCombo(combo) /5))
			self:project(tg, x, y, DamageType.PHYSICAL, damage)
			game.level.map:particleEmitter(x, y, tg.radius, "ball_earth", {radius=tg.radius})
			game:playSoundNear(self, "talents/breath")
		end

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local area = t.getAreaDamage(self, t) * 0.25
		local areamax = t.getAreaDamage(self, t) * 1.25
		local radius = self:getTalentRadius(t)
		return ([[A powerful concussive punch that deals %d%% weapon damage to your target.  If the punch hits, all targets in a radius of %d will take %0.2f to %0.2f damage, depending on the amount of combo points you've accumulated.
		The area damage will scale with your Strength, and the radius will increase by 1 for every four talent levels.
		Using this talent removes your combo points.]])
		:format(damage, radius, damDesc(self, DamageType.PHYSICAL, area), damDesc(self, DamageType.PHYSICAL, areamax))
	end,
}

newTalent{
	name = "Body Shot",
	type = {"technique/finishing-moves", 3},
	require = techs_dex_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 10,
	message = "@Source@ throws a body shot.",
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.8) + getStrikingStyle(self, dam) end,
	getDuration = function(self, t, comb) return math.ceil(self:combatTalentScale(t, 1, 5) * (0.25 + comb/5)) end,
	getDrain = function(self, t) return self:combatTalentScale(t, 2, 10, 0.75) * self:getCombo(combo) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hit then
			-- try to daze
			if target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, t.getDuration(self, t, self:getCombo(combo)), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s resists the body shot!", target.name:capitalize())
			end

			target:incStamina(- t.getDrain(self, t))

		end

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local drain = self:getTalentLevel(t) * 2
		local daze = t.getDuration(self, t, 0)
		local dazemax = t.getDuration(self, t, 5)
		return ([[A punch to the body that deals %d%% damage, drains %d of the target's stamina per combo point, and dazes the target for %d to %d turns, depending on the amount of combo points you've accumulated.
		The daze chance will increase with your Physical Power.
		Using this talent removes your combo points.]])
		:format(damage, drain, daze, dazemax)
	end,
}

newTalent{
	name = "Haymaker",
	type = {"technique/finishing-moves", 4},
	require = techs_dex_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 16,
	stamina = 12,
	message = "@Source@ throws a wild haymaker!",
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.4, 2.1) + getStrikingStyle(self, dam) end,
	getBonusDamage = function(self, t) return self:getCombo(combo)/10 end,
	getStamina = function(self, t, comb)
		return self:combatLimit((self:getTalentLevel(t) + comb), 0.5, 0, 0, 0.2, 10) * self.max_stamina
	end, -- Limit 50% stamina gain
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		local damage = t.getDamage(self, t) + (t.getBonusDamage(self, t) or 0)

		local hit = self:attackTarget(target, nil, damage, true)

		-- Try to insta-kill
		if hit then
			if target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("instakill") and target.life > target.die_at and target.life < target.max_life * 0.2 then
				-- KILL IT !
				game.logSeen(target, "%s feels the pain of the death blow!", target.name:capitalize())
				target:die(self)
			elseif target.life > 0 and target.life < target.max_life * 0.2 then
				game.logSeen(target, "%s resists the death blow!", target.name:capitalize())
			end
		end

		-- restore stamina
		if target.dead then
			self:incStamina(t.getStamina(self, t, self:getCombo(combo)))
		end

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local stamina = t.getStamina(self, t, 0)/self.max_stamina*100
		local staminamax = t.getStamina(self, t, 5)/self.max_stamina*100
		return ([[A vicious finishing strike that deals %d%% damage + 10%% damage per combo point you have.  If the target ends up with low enough life (<20%%), it might be instantly killed.
		Killing a target with Haymaker will instantly restore %d%% to %d%% of your maximum stamina, depending on the amount of combo points you've accumulated.
		Using this talent removes your combo points.]])
		:format(damage, stamina, staminamax)
	end,
}

