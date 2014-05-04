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
	getStunDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
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
				target:setEffect(target.EFF_STUNNED, t.getStunDuration(self, t), {apply_power=self:combatAttackStr()})
			else
				game.logSeen(target, "%s resists the shield bash!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with two shield strikes, doing %d%% and %d%% shield damage. If it hits a second time, it stuns the target for %d turns.
		The stun chance increases with your Accuracy and your Strength.]])
		:format(100 * self:combatTalentWeaponDamage(t, 1, 1.7, self:getTalentLevel(self.T_SHIELD_EXPERTISE)),
		100 * self:combatTalentWeaponDamage(t, 1.2, 2.1, self:getTalentLevel(self.T_SHIELD_EXPERTISE)),
		t.getStunDuration(self, t))
	end,
}

newTalent{
	name = "Riposte",
	type = {"technique/shield-offense", 2},
	require = techs_req2,
	mode = "passive",
	points = 5,
	getDurInc = function(self, t)  -- called in effect "BLOCKING" in mod.data\timed_effects\physical.lua
		return math.ceil(self:combatTalentScale(t, 0.15, 1.15))
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
		Increases the crit chance of counterstrikes by %d%%. This increase scales with your Dexterity.]]):format(inc, (inc > 1 and "s" or ""), inc, t.getCritInc(self, t))
	end,
}

newTalent{
	name = "Shield Slam",
	type = {"technique/shield-offense", 3},
	require = techs_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	stamina = 15,
	requires_target = true,
	getShieldDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.1, 0.8, self:getTalentLevel(self.T_SHIELD_EXPERTISE)) end,
	tactical = { ATTACK = 2}, -- is there a way to make this consider the free Block?
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Shield Slam without a shield!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local damage = t.getShieldDamage(self, t)
		self:forceUseTalent(self.T_BLOCK, {ignore_energy=true, ignore_cd = true, silent = true})
		
		self:attackTargetWith(target, shield.special_combat, nil, damage)
		self:attackTargetWith(target, shield.special_combat, nil, damage)
		self:attackTargetWith(target, shield.special_combat, nil, damage)

		return true
	end,
	info = function(self, t)
		local damage = t.getShieldDamage(self, t)*100
		return ([[Hit your target with your shield 3 times for %d%% damage then quickly return to a blocking position.  The bonus block will not check or trigger Block cooldown.]])
		:format(damage)
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
			self.turn_procs.auto_phys_crit = true
			self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1, 1.5), true)
			self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1, 1.5), true)
			self.turn_procs.auto_phys_crit = nil
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your shield, doing %d%% damage. If it hits, you follow up with two automatic critical hits with your weapon, doing %d%% base damage each.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1, 1.5, self:getTalentLevel(self.T_SHIELD_EXPERTISE)), 100 * self:combatTalentWeaponDamage(t, 1, 1.5))
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
	getarmor = function(self,t) return self:combatScale((1+self:getDex(4))*self:getTalentLevel(t), 5, 0, 30, 25, 0.375) + self:combatTalentScale(self:getTalentLevel(self.T_SHIELD_EXPERTISE), 1, 5, 0.75) end, -- Scale separately with talent level and talent level of Shield Expertise
	getDefense = function(self, t)
		return self:combatScale((1 + self:getDex(4, true)) * self:getTalentLevel(t), 6.4, 1.4, 30, 25) + self:combatTalentScale(self:getTalentLevel(self.T_SHIELD_EXPERTISE), 2, 10, 0.75)
	end,
	stunKBresist = function(self, t) return self:combatTalentLimit(t, 1, 0.15, 0.50) end, -- Limit <100%
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Shield Wall without a shield!")
			return nil
		end
		return {
			stun = self:addTemporaryValue("stun_immune", t.stunKBresist(self, t)),
			knock = self:addTemporaryValue("knockback_immune", t.stunKBresist(self, t)),
			dam = self:addTemporaryValue("inc_damage", {[DamageType.PHYSICAL]=-20}),
			def = self:addTemporaryValue("combat_def", t.getDefense(self, t)),
			armor = self:addTemporaryValue("combat_armor", t.getarmor(self,t)),
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
		return ([[Enter a protective battle stance, increasing Defense by %d and Armour by %d at the cost of -20%% physical damage. The Defense and Armor increase is based on your Dexterity.
		It also grants %d%% resistance to stunning and knockback.]]):
		format(t.getDefense(self, t), t.getarmor(self, t), 100*t.stunKBresist(self, t))
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
	getDist = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getDuration = function(self, t) return math.floor(self:combatStatScale("str", 3.8, 11)) end,
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
				if target:checkHit(self:combatAttack(shield.special_combat), target:combatPhysicalResist(), 0, 95) and target:canBe("knockback") then --Deprecated checkHit call
					target:knockback(self.x, self.y, t.getDist(self, t))
					if target:canBe("stun") then target:setEffect(target.EFF_DAZED, t.getDuration(self, t), {}) end
				else
					game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
				end
			end
		end)

		self:addParticles(Particles.new("meleestorm2", 1, {radius=2}))

		return true
	end,
	info = function(self, t)
		return ([[Let all your foes pile up on your shield, then put all your strength in one mighty thrust and repel them all away %d grids.
		In addition, all creatures knocked back will also be dazed for %d turns.
		The distance increases with your talent level, and the Daze duration with your Strength.]]):format(t.getDist(self, t), t.getDuration(self, t))
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
		return ([[Improves your damage and defense with shield-based skills, and increases your Spell (+%d) and Physical (+%d) Saves.]]):format(2 * self:getTalentLevelRaw(t), 4 * self:getTalentLevelRaw(t))
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
	lifebonus = function(self,t, base_life) -- Scale bonus with max life
		return self:combatTalentStatDamage(t, "con", 30, 500) + (base_life or self.max_life) * self:combatTalentLimit(t, 1, 0.02, 0.10) -- Limit <100% of base life
	end,
	getDefense = function(self, t) return self:combatScale(self:getDex(4, true) * self:getTalentLevel(t), 5, 0, 25, 20) end,
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Last Stand without a shield!")
			return nil
		end
		local hp = t.lifebonus(self,t)
		local ret = {
			base_life = self.max_life,
			max_life = self:addTemporaryValue("max_life", hp),
			def = self:addTemporaryValue("combat_def", t.getDefense(self, t)),
			nomove = self:addTemporaryValue("never_move", 1),
			dieat = self:addTemporaryValue("die_at", -hp),
			extra_life = self:addTemporaryValue("life", hp), -- Avoid healing effects
		}
--		if not self:attr("talent_reuse") then
--			self:heal(hp)
--		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_def", p.def)
		self:removeTemporaryValue("max_life", p.max_life)
		self:removeTemporaryValue("never_move", p.nomove)
		self:removeTemporaryValue("die_at", p.dieat)
		self:removeTemporaryValue("life", p.extra_life)
		return true
	end,
	info = function(self, t)
		local hp = self:isTalentActive(self.T_LAST_STAND)
		if hp then
			hp = t.lifebonus(self, t, hp.base_life)
		else
			hp = t.lifebonus(self,t)
		end
		return ([[You brace yourself for the final stand, increasing Defense by %d, maximum and current life by %d, but making you unable to move.
		Your stand lets you concentrate on every blow, allowing you to avoid death from normally fatal wounds. You can only die when reaching -%d life; however below 0 life you can not see how much you have left.
		The increase in Defense is based on your Dexterity, and the increase in life is based on your Constitution and normal maximum life.]]):
		format(t.getDefense(self, t), hp, hp)
	end,
}

