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

-- We don't have to worry much about this vs. players since it requires combo points to be really effective and the AI isn't very bright
-- I lied, letting the AI use this is a terrible idea
newTalent{
	name = "Combination Kick",
	type = {"technique/unarmed-discipline", 1},
	short_name = "PUSH_KICK",
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 40,
	message = "@Source@ unleashes a flurry of disrupting kicks.",
	tactical = { ATTACK = { weapon = 2 }, },
	requires_target = true,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getStrikes = function(self, t) return self:getCombo() end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.1, 0.4) + getStrikingStyle(self, dam) end,
	checkType = function(self, t, talent)
		if talent.is_spell and self:getTalentLevel(t) < 3 then
			return false
		end
		if talent.is_mind and self:getTalentLevel(t) < 5 then
			return false
		end

		return true
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- breaks active grapples if the target is not grappled
		if not target:isGrappled(self) then
			self:breakGrapples()
		end

		local talents = {}

		for i = 1, t.getStrikes(self, t) do
			local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
			if hit then
				for tid, active in pairs(target.sustain_talents) do
					if active then
						local talent = target:getTalentFromId(tid)
						if t.checkType(self, t, talent) then talents[tid] = talent.name end
					end
				end
			end
		end

		for k, v in pairs(talents) do
			target:forceUseTalent(k, {ignore_energy=true})
		end

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Unleash a flurry of disruptive kicks at your target's vulnerable areas.  For each combo point you attack for %d%% weapon damage and deactivate one physical sustain.
			At talent level 3 #DARK_ORCHID#Magical#LAST# sustains will also be effected.
			At talent level 5 #YELLOW#Mental#LAST# sustains will also be effected.
			Using this talent removes your combo points.]])
		:format(damage)
	end,
}

newTalent{
	name = "Defensive Throw",
	type = {"technique/unarmed-discipline", 2},
	require = techs_dex_req2,
	mode = "passive",
	points = 5,
	-- Limit defensive throws/turn for balance using a buff (warns attacking players of the talent)	
	-- EFF_DEFENSIVE_GRAPPLING effect is refreshed each turn in _M:actBase in mod.class.Actor.lua
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 5, 50) * getUnarmedTrainingBonus(self) end,
	getDamageTwo = function(self, t) return self:combatTalentPhysicalDamage(t, 10, 75) * getUnarmedTrainingBonus(self) end,
	getchance = function(self, t)
		return self:combatLimit(self:getTalentLevel(t) * (5 + self:getCun(5, true)), 100, 0, 0, 50, 50) -- Limit < 100%
	end,
	getThrows = function(self, t)
		return self:combatScale(self:getStr() + self:getDex()-20, 0, 0, 2.24, 180)
	end,
	-- called by _M:attackTargetWith function in mod\class\interface\Combat.lua (includes adjacency check)
	do_throw = function(self, target, t)
		local ef = self:hasEffect(self.EFF_DEFENSIVE_GRAPPLING)
		if not ef or not rng.percent(self.tempeffect_def.EFF_DEFENSIVE_GRAPPLING.throwchance(self, ef)) then return end
		local grappled = target:isGrappled(self)
		local hit = self:checkHit(self:combatAttack(), target:combatDefense(), 0, 95) and (grappled or not self:checkEvasion(target)) -- grappled target can't evade
		ef.throws = ef.throws - 1
		if ef.throws <= 0 then self:removeEffect(self.EFF_DEFENSIVE_GRAPPLING) end
		
		if hit then
			self:project(target, target.x, target.y, DamageType.PHYSICAL, self:physicalCrit(t.getDamageTwo(self, t), nil, target, self:combatAttack(), target:combatDefense()))
			-- if grappled stun
			if grappled and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2, {apply_power=self:combatAttack(), min_dur=1})
				self:logCombat(target, "#Source# slams #Target# into the ground!")
			-- if not grappled daze
			else
				self:logCombat(target, "#Source# throws #Target# to the ground!")
				-- see if the throw dazes the enemy
				if target:canBe("stun") then
					target:setEffect(target.EFF_DAZED, 2, {apply_power=self:combatAttack(), min_dur=1})
				end
			end
		else
			self:logCombat(target, "#Source# misses a defensive throw against #Target#!", self.name:capitalize(),target.name:capitalize())
		end
	end,
	on_unlearn = function(self, t)
		self:removeEffect(self.EFF_DEFENSIVE_GRAPPLING)
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local damagetwo = t.getDamageTwo(self, t)
		return ([[When you avoid a melee blow while unarmed, you have a %d%% chance to throw the target to the ground.  If the throw lands, the target will take %0.2f damage and be dazed for 2 turns, or %0.2f damage and be stunned for 2 turns if the target is grappled.  You may attempt up to %0.1f throws per turn.
		The chance of throwing increases with your Accuracy, the damage scales with your Physical Power, and the number of attempts with your Strength and Dexterity.]]):
		format(t.getchance(self,t), damDesc(self, DamageType.PHYSICAL, (damage)), damDesc(self, DamageType.PHYSICAL, (damagetwo)), t.getThrows(self, t))
	end,
}

newTalent{
	name = "Open Palm Block",
	short_name = "BREATH_CONTROL",
	type = {"technique/unarmed-discipline", 3},
	require = techs_dex_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	stamina = 25,
	message = "@Source@ prepares to block incoming attacks.",
	tactical = { ATTACK = 3, DEFEND = 3 },
	requires_target = true,
	getBlock = function(self, t) return self:combatTalentPhysicalDamage(t, 10, 75) end,
	action = function(self, t)
		local blockval = t.getBlock(self, t) * self:getCombo()
		self:setEffect(self.EFF_BRAWLER_BLOCK, 2, {block = blockval})

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local block = t.getBlock(self, t)
		local maxblock = block*5
		return ([[Toughen your body blocking up to %d damage per combo point (Max %d) across 2 turns.
			Current block value:  %d
			Using this talent removes your combo points.]])
		:format(block, maxblock, block * self:getCombo())
	end,
}


newTalent{
	name = "Roundhouse Kick",
	type = {"technique/unarmed-discipline", 4},
	require = techs_dex_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 18,
	range = 0,
	radius = function(self, t) return 1 end,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 15, 150) * getUnarmedTrainingBonus(self) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end

		self:breakGrapples()

		self:project(tg, x, y, DamageType.PHYSKNOCKBACK, {dam=t.getDamage(self, t), dist=4})

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Attack your foes in a frontal arc with a roundhouse kick, which deals %0.2f physical damage and knocks your foes back.
		This will break any grapples you're maintaining, and the damage will scale with your Physical Power.]]):
		format(damDesc(self, DamageType.PHYSICAL, (damage)))
	end,
}

--[[
newTalent{
	name = "Tempo",
	type = {"technique/unarmed-discipline", 3},
	short_name = "BREATH_CONTROL",
	require = techs_dex_req3,
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 15,
	tactical = { BUFF = 1, STAMINA = 2 },
	getStamina = function(self, t) return 1 end,
	getDamage = function(self, t) return math.min(10, math.floor(self:combatTalentScale(t, 1, 4))) end,
	getDefense = function(self, t) return math.floor(self:combatTalentScale(t, 1, 8)) end,
	getResist = function(self, t) return 20 end,
	activate = function(self, t)		
		return {

		}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if not hitted or self.turn_procs.tempo or not (self:reactionToward(target) < 0) then return end
		self.turn_procs.tempo = true

		self:setEffect(target.EFF_RELENTLESS_TEMPO, 2, {
			stamina = t.getStamina(self, t),
			damage = t.getDamage(self, t),
			defense = t.getDefense(self, t),
			resist = t.getResist(self, t)
			 })
		return true
	end,
	info = function(self, t)
		local stamina = t.getStamina(self, t)
		local damage = t.getDamage(self, t)
		local resistance = t.getResist(self, t)
		local defense = t.getDefense(self, t)

		return (Your years of fighting have trained you for sustained engagements.  Each turn you attack at least once you gain %d Stamina Regeneration, %d Defense, and %d%% Damage Increase.
			This effect lasts 2 turns and stacks up to 5 times.
			At talent level 3 you gain %d%% All Resistance upon reaching 5 stacks.
		 ):
		--format(stamina, defense, damage, resistance ) -- 
	--end,
--}
--]]
