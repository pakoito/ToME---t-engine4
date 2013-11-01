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
	name = "Dual Weapon Training",
	type = {"technique/dualweapon-training", 1},
	mode = "passive",
	points = 5,
	require = techs_dex_req1,
	-- called by  _M:getOffHandMult in mod\class\interface\Combat.lua
	-- This talent could probably use a slight buff at higher talent levels after diminishing returns kick in
	getoffmult = function(self,t)
		return	self:combatTalentLimit(t, 1, 0.65, 0.85)-- limit <100%
	end,
	info = function(self, t)
		return ([[Increases the damage of your off-hand weapon to %d%%.]]):format(100 * t.getoffmult(self,t))
	end,
}

newTalent{ -- Note: classes: Temporal Warden, Rogue, Shadowblade, Marauder
	name = "Dual Weapon Defense",
	type = {"technique/dualweapon-training", 2},
	mode = "passive",
	points = 5,
	require = techs_dex_req2,
	-- called by _M:combatDefenseBase in mod.class.interface.Combat.lua
	getDefense = function(self, t) return self:combatScale(self:getTalentLevel(t) * self:getDex(), 4, 0, 45.7, 500) end,
	getDeflectChance = function(self, t) --Chance to parry with an offhand weapon, kicks in for TL > 5
		return self:combatTalentLimit(math.max(0, self:getTalentLevel(t)-5), 100, 16.7, 50)
	end,
	getDeflectPercent = function(self, t) -- Percent of offhand weapon damage used to deflect
		return math.max(0, self:combatTalentLimit(self:getTalentLevel(t)-5, 100, 10, 40))
	end,
	getDamageChange = function(self, t, fake)
		local dam,_,weapon = 0,self:hasDualWeapon()
		if not weapon or weapon.subtype=="mindstar" and not fake then return 0 end
		if weapon then
			dam = self:combatDamage(weapon.combat) * self:getOffHandMult(weapon.combat)
		end
		return t.getDeflectPercent(self, t) * dam/100
	end,
	-- deflect count handled in physical effect "DUAL_WEAPON_DEFENSE" in mod.data.timed_effects.physical.lua
	-- buff refreshed each turn in mod.class.Actor.lua _M:actBase
	getDeflects = function(self, t, fake)
		if not self:hasDualWeapon() and not fake then return 0 end
		return self:combatStatScale("cun", 0, 2.25)
	end,
	-- Called by _M:attackTargetWith in mod.class.interface.Combat.lua
	doDeflect = function(self, t)
		local eff = self:hasEffect(self.EFF_DUAL_WEAPON_DEFENSE)
		if not eff then return 0 end
		local deflected = 0
		if rng.percent(self.tempeffect_def.EFF_DUAL_WEAPON_DEFENSE.deflectchance(self, eff)) then
			deflected = eff.dam
		end
		eff.deflects = eff.deflects -1
		if eff.deflects <=0 then self:removeEffect(self.EFF_DUAL_WEAPON_DEFENSE) end
		return deflected
	end,
	on_unlearn = function(self, t)
		self:removeEffect(self.EFF_DUAL_WEAPON_DEFENSE)
	end,
	info = function(self, t)
		local xs = ([[  At talent levels higher than 5, you may parry melee attacks with your offhand weapon (except mindstars).
		(You currently have a %d%% chance to deflect up to %d damage (%d%% of your offhand weapon damage) from approximately %0.1f melee attacks (based on your Cunning) each turn.)]]):
		format(t.getDeflectChance(self,t),t.getDamageChange(self, t, true), t.getDeflectPercent(self,t), t.getDeflects(self, t, true))
		return ([[You have learned to block incoming blows with your weapons.  When dual wielding, your defense is increased by %d.
		The Defense bonus scales with your Dexterity.%s]]):format(t.getDefense(self, t),xs)
	end,
}

newTalent{
	name = "Precision",
	type = {"technique/dualweapon-training", 3},
	mode = "sustained",
	points = 5,
	require = techs_dex_req3,
	no_energy = true,
	cooldown = 10,
	sustain_stamina = 20,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon() then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	getApr = function(self, t) return self:combatScale(self:getTalentLevel(t) * self:getDex(), 4, 0, 25, 500, 0.75) end,
	activate = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Precision without dual wielding!")
			return nil
		end

		return {
			apr = self:addTemporaryValue("combat_apr",t.getApr(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_apr", p.apr)
		return true
	end,
	info = function(self, t)
		return ([[You have learned to hit the right spot, increasing your armor penetration by %d when dual wielding.
		The Armour penetration bonus will increase with your Dexterity.]]):format(t.getApr(self, t))
	end,
}

newTalent{
	name = "Momentum",
	type = {"technique/dualweapon-training", 4},
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 50,
	require = techs_dex_req4,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon() then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.21, 0.70, 0.75) end,
	activate = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Momentum without dual wielding!")
			return nil
		end

		return {
			combat_physspeed = self:addTemporaryValue("combat_physspeed", t.getSpeed(self, t)),
			stamina_regen = self:addTemporaryValue("stamina_regen", -6),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physspeed", p.combat_physspeed)
		self:removeTemporaryValue("stamina_regen", p.stamina_regen)
		return true
	end,
	info = function(self, t)
		return ([[When dual wielding, increases attack speed by %d%%, but drains stamina quickly (-6 stamina/turn).]]):format(t.getSpeed(self, t)*100)
	end,
}

------------------------------------------------------
-- Attacks
------------------------------------------------------
newTalent{
	name = "Dual Strike",
	type = {"technique/dualweapon-attack", 1},
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 15,
	require = techs_dex_req1,
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = { stun = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon() then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	getStunDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Dual Strike without dual wielding!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- First attack with offhand
		local speed, hit = self:attackTargetWith(target, offweapon.combat, nil, self:getOffHandMult(offweapon.combat, self:combatTalentWeaponDamage(t, 0.7, 1.5)))

		-- Second attack with mainhand
		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getStunDuration(self, t), {apply_power=self:combatAttack()})
			else
				game.logSeen(target, "%s resists the stunning strike!", target.name:capitalize())
			end

			-- Attack after the stun, to benefit from backstabs
			self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 0.7, 1.5))
		end

		return true
	end,
	info = function(self, t)
		return ([[Attack with your offhand weapon for %d%% damage. If the attack hits, the target is stunned for %d turns, and you hit it with your mainhand weapon doing %d%% damage.
		The stun chance increases with your Accuracy.]])
		:format(100 * self:combatTalentWeaponDamage(t, 0.7, 1.5), t.getStunDuration(self, t), 100 * self:combatTalentWeaponDamage(t, 0.7, 1.5))
	end,
}

newTalent{
	name = "Flurry",
	type = {"technique/dualweapon-attack", 2},
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 15,
	require = techs_dex_req2,
	requires_target = true,
	tactical = { ATTACK = { weapon = 4 } },
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon() then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Flurry without dual wielding!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.4, 1.0), true)
		self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.4, 1.0), true)
		self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.4, 1.0), true)

		return true
	end,
	info = function(self, t)
		return ([[Lashes out with a flurry of blows, hitting your target three times with each weapon for %d%% damage.]]):format(100 * self:combatTalentWeaponDamage(t, 0.4, 1.0))
	end,
}

newTalent{
	name = "Sweep",
	type = {"technique/dualweapon-attack", 3},
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	stamina = 30,
	require = techs_dex_req3,
	requires_target = true,
	tactical = { ATTACKAREA = { weapon = 1, cut = 1 } },
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon() then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	cutdur = function(self,t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	cutPower = function(self, t)
		local main, off = self:hasDualWeapon()
		if main then
			-- Damage based on mainhand weapon and dex with an assumed 8 turn cut duration
			return self:combatTalentScale(t, 1, 1.7) * self:combatDamage(main.combat)/8 + self:getDex()/2
		else 
			return 0
		end
	end,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Sweep without dual wielding!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local dir = util.getDir(x, y, self.x, self.y)
		if dir == 5 then return nil end
		local lx, ly = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
		local rx, ry = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
		local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

		local hit
		hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1, 1.7), true)
		if hit and target:canBe("cut") then target:setEffect(target.EFF_CUT, t.cutdur(self, t), {power=t.cutPower(self, t), src=self}) end

		if lt then
			hit = self:attackTarget(lt, nil, self:combatTalentWeaponDamage(t, 1, 1.7), true)
			if hit and lt:canBe("cut") then lt:setEffect(lt.EFF_CUT, t.cutdur(self, t), {power=t.cutPower(self, t), src=self}) end
		end

		if rt then
			hit = self:attackTarget(rt, nil, self:combatTalentWeaponDamage(t, 1, 1.7), true)
			if hit and rt:canBe("cut") then rt:setEffect(rt.EFF_CUT, t.cutdur(self, t), {power=t.cutPower(self, t), src=self}) end
		end
		print(x,y,target)
		print(lx,ly,lt)
		print(rx,ry,rt)

		return true
	end,
	info = function(self, t)
		return ([[Attack your foes in a frontal arc, doing %d%% weapon damage and making your targets bleed for %d each turn for %d turns.
		The bleed damage increases with your main hand weapon damage and Dexterity.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1, 1.7), damDesc(self, DamageType.PHYSICAL, t.cutPower(self, t)), t.cutdur(self, t))
	end,
}

newTalent{
	name = "Whirlwind",
	type = {"technique/dualweapon-attack", 4},
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	stamina = 30,
	require = techs_dex_req4,
	tactical = { ATTACKAREA = { weapon = 2 } },
	range = 0,
	radius = 1,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t)}
	end,
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon() then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Whirlwind without dual wielding!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1.2, 1.9), true)
			end
		end)

		self:addParticles(Particles.new("meleestorm2", 1, {}))

		return true
	end,
	info = function(self, t)
		return ([[Spin around, damaging all targets around you with both weapons for %d%% weapon damage.]]):format(100 * self:combatTalentWeaponDamage(t, 1.2, 1.9))
	end,
}

