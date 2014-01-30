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

-- Default archery attack
newTalent{
	name = "Shoot",
	type = {"technique/archery-base", 1},
	no_energy = "fake",
	hide = true,
	innate = true,
	points = 1,
	cooldown = 0,
	range = archery_range,
	message = "@Source@ shoots!",
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	no_unlearn_last = true,
	use_psi_archery = function(self, t)
		local inven = self:getInven("PSIONIC_FOCUS")
		if not inven then return false end
		local pf_weapon = inven[1]
		if pf_weapon and pf_weapon.archery then
			return true
		else
			return false
		end
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {use_psi_archery = t.use_psi_archery(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Shoot your bow or sling!]])
	end,
}
newTalent{
	name = "Reload",
	type = {"technique/archery-base", 1},
	cooldown = 0,
	innate = true,
	points = 1,
	tactical = { AMMO = 2 },
	no_reload_break = true,
	no_break_stealth = true,
	on_pre_use = function(self, t, silent)
		local q = self:hasAmmo()
		if not q then if not silent then game.logPlayer(self, "You must have a quiver or pouch equipped.") end return false end
		if q.combat.shots_left >= q.combat.capacity then return false end
		return true 
	end,
	no_unlearn_last = true,
	shots_per_turn = function(self, t)
		local v = math.max(self:getTalentLevelRaw(self.T_BOW_MASTERY), self:getTalentLevelRaw(self.T_SLING_MASTERY))
		local add = 0
		if v >= 5 then add = add + 3
		elseif v >= 4 then add = add + 2
		elseif v >= 2 then add = add + 1
		end
		return self:getTalentLevelRaw(t) + (self:attr("ammo_reload_speed") or 0) + add
	end,
	action = function(self, t)
		local q, err = self:hasAmmo()
		if not q then
			game.logPlayer(self, "%s", err)
			return
		end
		if q.combat.shots_left >= q.combat.capacity then
			game.logPlayer(self, "Your %s is full.", q.name)
			return
		end
		self:setEffect(self.EFF_RELOADING, q.combat.capacity, {ammo = q, shots_per_turn = t.shots_per_turn(self, t)})
		return true
	end,
	info = function(self, t)
		local spt = t.shots_per_turn(self, t)
		return ([[Reload your quiver or shot pouch at the rate of %d shot%s per turn (depends on the ammo used).
		Reloading does not break stealth.]]):format(spt, (spt > 1 and "s") or "")
	end,
}

newTalent{
	name = "Steady Shot",
	type = {"technique/archery-training", 1},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 3,
	stamina = 8,
	require = techs_dex_req1,
	range = archery_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1.1, 2.2)})
		return true
	end,
	info = function(self, t)
		return ([[A steady shot, doing %d%% damage.]]):format(self:combatTalentWeaponDamage(t, 1.1, 2.2) * 100)
	end,
}

newTalent{
	name = "Aim",
	type = {"technique/archery-training", 2},
	mode = "sustained",
	points = 5,
	require = techs_dex_req2,
	cooldown = 8,
	sustain_stamina = 20,
	no_energy = true,
	tactical = { BUFF = 2 },
	no_npc_use = true,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	getCombatVals = function(self, t)
		local vals = {speed = -self:combatTalentLimit(t, 0.5, 0.05, 0.25), -- Limit < 50% speed loss
			crit =  self:combatScale(self:getTalentLevel(t) * self:getDex(10, true), 7, 0, 57, 50),
			atk = self:combatScale(self:getTalentLevel(t) * self:getDex(10, true), 4, 0, 54, 50),
			dam = self:combatScale(self:getTalentLevel(t) * self:getDex(10, true), 4, 0, 54, 50),
			apr = self:combatScale(self:getTalentLevel(t) * self:getDex(10, true), 3, 0, 53, 50)}
		return vals
	end,
	activate = function(self, t)
		local weapon = self:hasArcheryWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Aim without a bow or sling!")
			return nil
		end

		if self:isTalentActive(self.T_RAPID_SHOT) then self:forceUseTalent(self.T_RAPID_SHOT, {ignore_energy=true}) end
		local vals = t.getCombatVals(self, t)
		return {
			move = self:addTemporaryValue("never_move", 1),
			speed = self:addTemporaryValue("combat_physspeed", vals.speed),
			crit = self:addTemporaryValue("combat_physcrit", vals.crit),
			atk = self:addTemporaryValue("combat_dam", vals.atk),
			dam = self:addTemporaryValue("combat_atk", vals.dam),
			apr = self:addTemporaryValue("combat_apr", vals.apr),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("never_move", p.move)
		self:removeTemporaryValue("combat_physspeed", p.speed)
		self:removeTemporaryValue("combat_physcrit", p.crit)
		self:removeTemporaryValue("combat_apr", p.apr)
		self:removeTemporaryValue("combat_atk", p.atk)
		self:removeTemporaryValue("combat_dam", p.dam)
		return true
	end,
	info = function(self, t)
		local vals = t.getCombatVals(self, t)
		return ([[You enter a calm, focused stance, increasing your Physical Power (+%d), Accuracy (+%d), Armour penetration (+%d), and critical chance (+%d%%), but reducing your firing speed by %d%% and making you unable to move.
		The effects will increase with your Dexterity.]]):
		format(vals.dam, vals.atk, vals.apr, vals.crit, -vals.speed * 100)
	end,
}

newTalent{
	name = "Rapid Shot",
	type = {"technique/archery-training", 3},
	mode = "sustained",
	points = 5,
	require = techs_dex_req3,
	cooldown = 8,
	sustain_stamina = 20,
	no_energy = true,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	getCombatVals = function(self, t)
		local vals = {speed = self:combatTalentScale(t, 0.1, 0.5, 0.75),
			crit = -self:combatTalentScale(t, 10.4, 20),
			atk = -self:combatTalentScale(t, 10.4, 20, 0.75),
			dam = -self:combatTalentScale(t, 10.4, 20, 0.75)
			}
		return vals
	end,
	activate = function(self, t)
		local weapon = self:hasArcheryWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Rapid Shot without a bow or sling!")
			return nil
		end

		if self:isTalentActive(self.T_AIM) then self:forceUseTalent(self.T_AIM, {ignore_energy=true}) end
		local vals = t.getCombatVals(self, t)
		return {
			speed = self:addTemporaryValue("combat_physspeed", vals.speed),
			atk = self:addTemporaryValue("combat_dam", vals.atk),
			dam = self:addTemporaryValue("combat_atk", vals.dam),
			crit = self:addTemporaryValue("combat_physcrit", vals.crit),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physspeed", p.speed)
		self:removeTemporaryValue("combat_physcrit", p.crit)
		self:removeTemporaryValue("combat_dam", p.dam)
		self:removeTemporaryValue("combat_atk", p.atk)
		return true
	end,
	info = function(self, t)
		local vals = t.getCombatVals(self, t)
		return ([[You switch to a fluid and fast battle stance, increasing your firing speed by %d%% at the cost of your Accuracy (%d), Physical Power (%d), and critical chance (%d%%).]]):
		format(vals.speed*100, vals.atk, vals.dam, vals.crit)
	end,
}

newTalent{
	name = "Relaxed Shot",
	type = {"technique/archery-training", 4},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 14,
	require = techs_dex_req4,
	range = archery_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 }, STAMINA = 1 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 0.5, 1.1)})
		self:incStamina(12 + self:getTalentLevel(t) * 8)
		return true
	end,
	info = function(self, t)
		return ([[You fire a shot without putting much strength into it, doing %d%% damage.
		That brief moment of relief allows you to regain %d stamina.]]):format(self:combatTalentWeaponDamage(t, 0.5, 1.1) * 100, 12 + self:getTalentLevel(t) * 8)
	end,
}

-------------------------------- Utility -----------------------------------

newTalent{
	name = "Flare",
	type = {"technique/archery-utility", 1},
	no_energy = "fake",
	points = 5,
	cooldown = 15,
	stamina = 15,
	range = archery_range,
	radius = function(self, t)
		local rad = 1
		if self:getTalentLevel(t) >= 3 then rad = rad + 1 end
		if self:getTalentLevel(t) >= 5 then rad = rad + 1 end
		return rad
	end,
	require = techs_dex_req1,
	tactical = { ATTACKAREA = { FIRE = 2 }, DISABLE = { blind = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	requires_target = true,
	target = function(self, t)
		return {type="ball", x=x, y=y, radius=self:getTalentRadius(t), range=self:getTalentRange(t)}
	end,
	archery_onreach = function(self, t, x, y)
		local tg = self:getTalentTarget(t)
		self:project(tg, x, y, DamageType.LITE, 1)
		if self:getTalentLevel(t) >= 3 then
			tg.selffire = false
			self:project(tg, x, y, DamageType.BLINDPHYSICAL, 3)
		end
		game.level.map:particleEmitter(x, y, tg.radius, "ball_light", {radius=tg.radius})
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 0.5, 1.2), damtype=DamageType.FIRE})
		return true
	end,
	info = function(self, t)
		local rad = 1
		if self:getTalentLevel(t) >= 3 then rad = rad + 1 end
		if self:getTalentLevel(t) >= 5 then rad = rad + 1 end
		return ([[You fire a burning shot, doing %d%% fire damage to the target and lighting up the area around the target in a radius of %d.
		At level 3, it also has a chance to blind for 3 turns.]]):
		format(self:combatTalentWeaponDamage(t, 0.5, 1.2) * 100, rad)
	end,
}

newTalent{
	name = "Crippling Shot",
	type = {"technique/archery-utility", 2},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 15,
	require = techs_dex_req2,
	range = archery_range,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = 1 },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		target:setEffect(target.EFF_SLOW, 7, {power=util.bound((self:combatAttack() * 0.15 * self:getTalentLevel(t)) / 100, 0.1, 0.4), apply_power=self:combatAttack()})
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.5)})
		return true
	end,
	info = function(self, t)
		return ([[You fire a crippling shot, doing %d%% damage and reducing your target's speed by %d%% for 7 turns.
		The status power and status hit chance improve with your Accuracy.]]):format(self:combatTalentWeaponDamage(t, 1, 1.5) * 100, util.bound((self:combatAttack() * 0.15 * self:getTalentLevel(t)) / 100, 0.1, 0.4) * 100)
	end,
}

newTalent{
	name = "Pinning Shot",
	type = {"technique/archery-utility", 3},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 15,
	require = techs_dex_req3,
	range = archery_range,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = { pin = 2 } },
	requires_target = true,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 5.5)) end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("pin") then
			target:setEffect(target.EFF_PINNED, t.getDur(self, t), {apply_power=self:combatAttack()})
		else
			game.logSeen(target, "%s resists!", target.name:capitalize())
		end
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.4)})
		return true
	end,
	info = function(self, t)
		return ([[You fire a pinning shot, doing %d%% damage and pinning your target to the ground for %d turns.
		The pinning chance increases with your Dexterity.]])
		:format(self:combatTalentWeaponDamage(t, 1, 1.4) * 100,
		t.getDur(self, t))
	end,
}

newTalent{
	name = "Scatter Shot",
	type = {"technique/archery-utility", 4},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 14,
	stamina = 15,
	require = techs_dex_req4,
	range = archery_range,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.3, 2.7)) end,
	tactical = { ATTACKAREA = { weapon = 2 }, DISABLE = { stun = 3 } },
	requires_target = true,
	target = function(self, t)
		local weapon, ammo = self:hasArcheryWeapon()
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), display=self:archeryDefaultProjectileVisual(weapon, ammo)}
	end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	getStunDur = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, t.getStunDur(self, t), {apply_power=self:combatAttack()})
		else
			game.logSeen(target, "%s resists the stunning shot!", target.name:capitalize())
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local targets = self:archeryAcquireTargets(tg, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, tg, {mult=self:combatTalentWeaponDamage(t, 0.5, 1.5)})
		return true
	end,
	info = function(self, t)
		return ([[You fire multiple shots in a circular pattern with radius %d, doing %d%% damage and stunning everyone hit for %d turns.
		The stun chance increases with your Accuracy.]])
		:format(self:getTalentRadius(t), self:combatTalentWeaponDamage(t, 0.5, 1.5) * 100, t.getStunDur(self,t))
	end,
}
