-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

----------------------------------------------------------------------
-- Offense
----------------------------------------------------------------------

newTalent{
	name = "Shield Pummel",
	type = {"technique/shield-offense", 1},
	require = techs_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 8,
	requires_target = true,
	tactical = { ATTACK = 1, DISABLE = { stun = 3 } },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Shield Pummel without a shield!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 1, 1.7, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 1.2, 2.1, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))

		-- Try to stun !
		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2 + self:getTalentLevel(t) / 2, {apply_power=self:combatAttackStr()})
			else
				game.logSeen(target, "%s resists the shield bash!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with two shield strikes doing %d%% and %d%% shield damage. If it hits a second time it stuns target for %d turns.]])
		:format(100 * self:combatTalentWeaponDamage(t, 1, 1.7, self:getTalentLevel(self.T_SHIELD_EXPERTISE)),
		100 * self:combatTalentWeaponDamage(t, 1.2, 2.1, self:getTalentLevel(self.T_SHIELD_EXPERTISE)),
		2 + self:getTalentLevel(t) / 2)
	end,
}

newTalent{
	name = "Riposte",
	type = {"technique/shield-offense", 2},
	require = techs_req2,
	mode = "passive",
	points = 5,
	getDurInc = function(self, t)
		return math.ceil(self:getTalentLevel(t)/4)
	end,
	getCritInc = function(self, t)
		return self:combatTalentIntervalDamage(t, "dex", 10, 50)
	end,
	info = function(self, t)
		local inc = t.getDurInc(self, t)
		return ([[Improves your ability to perform counterstrikes after blocks in the following ways:
		Allows counterstrikes after incomplete blocks.
		Increases the duration of the counterstrike debuff on attackers by %d turn%s.
		Increases the number of counterstrikes you can perform on a target while they're vulnerable by %d.
		Increases the crit chance of counterstrikes by %d%%. This increase scales with Dexterity.]]):format(inc, (inc > 1 and "s" or ""), inc, t.getCritInc(self, t))
	end,
}

newTalent{
	name = "Overpower",
	type = {"technique/shield-offense", 3},
	require = techs_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	stamina = 22,
	requires_target = true,
	tactical = { ATTACK = 2, ESCAPE = { knockback = 1 }, DISABLE = { knockback = 1 } },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Overpower without a shield!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- First attack with weapon
		self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3), true)
		-- Second attack with shield
		self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))
		-- Third attack with shield
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttack(shield.special_combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
				target:knockback(self.x, self.y, 4)
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon doing %d%% and two shield strikes doing %d%% damage, trying to overpower your target.
		If the last attack hits, the target is knocked back. The chance for knock back increases with talent level.]])
		:format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.3), 100 * self:combatTalentWeaponDamage(t, 0.8, 1.3, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))
	end,
}

newTalent{
	name = "Assault",
	type = {"technique/shield-offense", 4},
	require = techs_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 16,
	requires_target = true,
	tactical = { ATTACK = 4 },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Assault without a shield!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- First attack with shield
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 1, 1.5, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))

		-- Second & third attack with weapon
		if hit then
			self.combat_physcrit = self.combat_physcrit + 1000
			self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1, 1.5), true)
			self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1, 1.5), true)
			self.combat_physcrit = self.combat_physcrit - 1000
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your shield doing %d%% damage. If it hits, you follow up with two weapon strikes which are automatic critical hits.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1, 1.5, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))
	end,
}


----------------------------------------------------------------------
-- Defense
----------------------------------------------------------------------
newTalent{
	name = "Shield Wall",
	type = {"technique/shield-defense", 1},
	require = techs_req1,
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 30,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Shield Wall without a shield!")
			return nil
		end

		return {
			stun = self:addTemporaryValue("stun_immune", 0.1 * self:getTalentLevel(t)),
			knock = self:addTemporaryValue("knockback_immune", 0.1 * self:getTalentLevel(t)),
			dam = self:addTemporaryValue("inc_damage", {[DamageType.PHYSICAL]=-20}),
			def = self:addTemporaryValue("combat_def", 5 + (1 + self:getDex(4, true)) * self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE) * 2),
			armor = self:addTemporaryValue("combat_armor", 5 + (1 + self:getDex(4, true)) * self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_def", p.def)
		self:removeTemporaryValue("combat_armor", p.armor)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("stun_immune", p.stun)
		self:removeTemporaryValue("knockback_immune", p.knock)
		return true
	end,
	info = function(self, t)
		return ([[Enter a protective battle stance, increasing defense by %d and armor by %d at the cost of -20%% physical damage. The defense and armor increase is based on dexterity.
		It also grants resistance to stunning and knockback (%d%%).]]):format(
		5 + (1 + self:getDex(4, true)) * self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE)* 2,
		5 + (1 + self:getDex(4, true)) * self:getTalentLevel(t) + self:getTalentLevel(self.T_SHIELD_EXPERTISE),
		10 * self:getTalentLevel(t), 10 * self:getTalentLevel(t)
		)
	end,
}

newTalent{
	name = "Repulsion",
	type = {"technique/shield-defense", 2},
	require = techs_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 30,
	tactical = { ESCAPE = { knockback = 2 }, DEFEND = { knockback = 0.5 } },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	range = 0,
	radius = 1,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Repulsion without a shield!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				if target:checkHit(self:combatAttack(shield.special_combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
					target:knockback(self.x, self.y, 2 + self:getTalentLevel(t))
					if target:canBe("stun") then target:setEffect(target.EFF_DAZED, 3 + self:getStr(8), {}) end
				else
					game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
				end
			end
		end)

		return true
	end,
	info = function(self, t)
		return ([[Let all your foes pile up on your shield, then put all your strength in one mighty thrust and repel them all away %d grids.
		In addition all creature knocked back will also be dazed for %d turns.
		The distance increases with talent level and the daze with Strength.]]):format(math.floor(2 + self:getTalentLevel(t)), 3 + self:getStr(8))
	end,
}

newTalent{
	name = "Shield Expertise",
	type = {"technique/shield-defense", 3},
	require = techs_req3,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.combat_physresist = self.combat_physresist + 4
		self.combat_spellresist = self.combat_spellresist + 2
	end,
	on_unlearn = function(self, t)
		self.combat_physresist = self.combat_physresist - 4
		self.combat_spellresist = self.combat_spellresist - 2
	end,
	info = function(self, t)
		return ([[Improves your damage with shield attacks and increases your spell(+%d) and physical(+%d) saves.]]):format(2 * self:getTalentLevelRaw(t), 4 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Last Stand",
	type = {"technique/shield-defense", 4},
	require = techs_req4,
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 50,
	tactical = { DEFEND = 3 },
	no_npc_use = true,
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Last Stand without a shield!")
			return nil
		end

		return {
			max_life = self:addTemporaryValue("max_life", (10 + self:getCon() * 0.7) * self:getTalentLevel(t)),
			def = self:addTemporaryValue("combat_def", 5 + self:getDex(4, true) * self:getTalentLevel(t)),
			nomove = self:addTemporaryValue("never_move", 1),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_def", p.def)
		self:removeTemporaryValue("max_life", p.max_life)
		self:removeTemporaryValue("never_move", p.nomove)
		return true
	end,
	info = function(self, t)
		return ([[You brace yourself for the final stand, increasing defense by %d and maximum life by %d, but making you unable to move.
		The increase in defense is based on Dexterity and life on Constitution.]]):
		format(5 + self:getDex(4, true) * self:getTalentLevel(t),
		(10 + self:getCon() * 0.7) * self:getTalentLevel(t))
	end,
}

