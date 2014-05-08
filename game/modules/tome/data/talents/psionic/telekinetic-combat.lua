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

newTalent{
	name = "Impale",
	type = {"psionic/telekinetic-combat", 1},
	require = psi_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	psi = 20,
	range = 3,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	getDamage = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 12, 340))
	end,
	action = function(self, t)
		local weapon = self:getInven(self.INVEN_PSIONIC_FOCUS) and self:getInven(self.INVEN_PSIONIC_FOCUS)[1]
		if type(weapon) == "boolean" then weapon = nil end
		if not weapon or self:attr("disarmed")then
			game.logPlayer(self, "You cannot do that without a weapon in your telekinetic slot.")
			return nil
		end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 3 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1.5, 2.6))
		if hit and target:canBe("bleed") then
			target:setEffect(target.EFF_CUT, 4, {power=t.getDamage(self,t)/4, apply_power=self:combatMindpower()})
		end
		return true
	end,
	info = function(self, t)
		return ([[Gather your will and thrust your telekinetically-wielded weapon into your target with such force that it impales it dealing %d%% weapon damage, then suddenly rip it out causing your target to bleed for %0.2f physical damage over four turns. 
		This attack uses your Willpower and Cunning instead of Strength and Dexterity to determine Accuracy and damage.
		Bleeding damage scales with Mindpower.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1.5, 2.6), damDesc(self, DamageType.PHYSICAL, t.getDamage(self,t)))
	end,
}

newTalent{
	name = "Warding Weapon",
	type = {"psionic/telekinetic-combat", 2},
	require = psi_wil_req2,
	points = 5,
	cooldown = 10,
	psi = 15,
	no_energy = true,
	tactical = { BUFF = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_WEAPON_WARDING, 1, {})
		return true
	end,
	info = function(self, t)
		return ([[Focus your telekinetically-wielded weapon to deflect melee attacks for one turn. You fully block the next melee attack used against you and strike the attacker with your telekinetically-wielded weapon for %d%% weapon damage. 
		At talent level 3 you also disarm the attacker for 3 turns.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.75, 1.1))
	end,
}

newTalent{
	name = "Telekinetic Assault",
	type = {"psionic/telekinetic-combat", 3},
	require = psi_wil_req3, 
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	psi = 25,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 3 } },
	action = function(self, t)
		local weapon = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1]
		if type(weapon) == "boolean" then weapon = nil end
		if not weapon or self:attr("disarmed")then
			game.logPlayer(self, "You cannot do that without a weapon in your hands.")
			return nil
		end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:attr("use_psi_combat", 1)
		if self:getInven(self.INVEN_PSIONIC_FOCUS) then
			for i, o in ipairs(self:getInven(self.INVEN_PSIONIC_FOCUS)) do
				if o.combat and not o.archery then
					self:attackTargetWith(target, o.combat, nil, self:combatTalentWeaponDamage(t, 1.2, 1.9))
					self:attackTargetWith(target, o.combat, nil, self:combatTalentWeaponDamage(t, 1.2, 1.9))
				end
			end
		end
		self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1.5, 2.5))
		self:attr("use_psi_combat", -1)
		return true
	end,
	info = function(self, t)
		return ([[Assault your target with all weapons, dealing two strikes with your telekinetically-wielded weapon for %d%% damage followed by an attack with your physical weapon for %d%% damage. 
		This physical weapon attack uses your Willpower and Cunning instead of Strength and Dexterity to determine Accuracy and damage.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1.2, 1.9), 100 * self:combatTalentWeaponDamage(t, 1.5, 2.5))
	end,
}

newTalent{
	name = "Shattering Charge",
	type = {"psionic/telekinetic-combat", 4},
	require = psi_wil_high4,
	points = 5,
	random_ego = "attack",
	psi = 60,
	cooldown = 10,
	tactical = { CLOSEIN = 2, ATTACK = { PHYSICAL = 1 } },
	range = function(self, t)
		return self:combatTalentLimit(t, 10, 6, 9) --Limit base range to 10
	end,
	--range = function(self, t) return 3+self:getTalentLevel(t)+self:getWil(4) end,
	direct_hit = true,
	requires_target = true,
	on_pre_use = function(self, t, silent)
		if not self:hasEffect(self.EFF_KINSPIKE_SHIELD) and not self:isTalentActive(self.T_KINETIC_SHIELD) then
			if not silent then game.logSeen(self, "You must either have a spiked kinetic shield or be able to spike one. Cancelling charge.") end
			return false
		end
		return true
	end,
	action = function(self, t)
		if self:getTalentLevelRaw(t) < 5 then
			local tg = {type="beam", range=self:getTalentRange(t), nolock=true, talent=t}
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end
			if self:hasLOS(x, y) and not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
				if not self:hasEffect(self.EFF_KINSPIKE_SHIELD) and self:isTalentActive(self.T_KINETIC_SHIELD) then
					self:forceUseTalent(self.T_KINETIC_SHIELD, {ignore_energy=true})
				end
				local dam = self:mindCrit(self:combatTalentMindDamage(t, 20, 600))
				self:project(tg, x, y, DamageType.MINDKNOCKBACK, self:mindCrit(rng.avg(2*dam/3, dam, 3)))
				--local _ _, x, y = self:canProject(tg, x, y)
				game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
				game:playSoundNear(self, "talents/lightning")
				--self:move(x, y, true)
				local fx, fy = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
				if not fx then
					return
				end
				self:move(fx, fy, true)
			else
				game.logSeen(self, "You can't move there.")
				return nil
			end
			return true
		else

			local tg = {type="beam", range=self:getTalentRange(t), nolock=true, talent=t, display={particle="bolt_earth", trail="earthtrail"}}
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end
			if not self:hasEffect(self.EFF_KINSPIKE_SHIELD) and self:isTalentActive(self.T_KINETIC_SHIELD) then
				self:forceUseTalent(self.T_KINETIC_SHIELD, {ignore_energy=true})
			end
			local dam = self:mindCrit(self:combatTalentMindDamage(t, 20, 600))

			for i = 1, self:getTalentRange(t) do
				self:project(tg, x, y, DamageType.DIG, 1)
			end
			self:project(tg, x, y, DamageType.MINDKNOCKBACK, self:mindCrit(rng.avg(2*dam/3, dam, 3)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/lightning")

			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, engine.Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			local tx, ty = self.x, self.y
			while lx and ly do
				if is_corner_blocked or block_actor(_, lx, ly) then break end
				tx, ty = lx, ly
				lx, ly, is_corner_blocked = l:step()
			end

			--self:move(tx, ty, true)
			local fx, fy = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
			if not fx then
				return
			end
			self:move(fx, fy, true)
			return true
		end
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local dam = self:combatTalentMindDamage(t, 20, 600)
		return ([[You expend massive amounts of energy to launch yourself across %d squares at incredible speed. All enemies in your path will be knocked flying and dealt between %d and %d damage. At talent level 5, you can batter through solid walls.
		You must have a spiked Kinetic Shield erected in order to not get smashed to a pulp when using this ability. Shattering Charge automatically spikes your Kinetic Shield if available and not already spiked. If no such shield is available, you cannot use Shattering Charge.
		This talent receives a reduced benefit from the Reach talent.]]):
		format(range, 2*dam/3, dam)
	end,
}

