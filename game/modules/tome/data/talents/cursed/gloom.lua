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

local function combatTalentDamage(self, t, min, max)
	return self:combatTalentSpellDamage(t, min, max, self.level + self:getWil())
end

local function getWillFailureEffectiveness(self, minChance, maxChance, attackStrength)
	return attackStrength * self:getWil() * 0.05 * (minChance + (maxChance - minChance) / 2)
end

newTalent{
	name = "Gloom",
	type = {"cursed/gloom", 1},
	mode = "sustained",
	require = cursed_wil_req1,
	points = 5,
	cooldown = 0,
	range = 3,
	no_energy = true,
	tactical = { BUFF = 5 },
	activate = function(self, t)
		self.torment_turns = nil -- restart torment
		game:playSoundNear(self, "talents/arcane")
		return {
			particle = self:addParticles(Particles.new("gloom", 1)),
		}
	end,
	getAttackStrength = function(self, t, target, forceStalk)
		local effStalker = self:hasEffect(self.EFF_STALKER)
		if forceStalk or (effStalker and effStalker.target == target) then
			return 0.6 + self:getTalentLevel(t) * 0.12
		else
			return 0.3 + self:getTalentLevel(t) * 0.12
		end
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	do_gloom = function(self, tGloom)
		-- all gloom effects are handled here
		local tWeakness = self:getTalentFromId(self.T_WEAKNESS)
		local tTorment = self:getTalentFromId(self.T_TORMENT)
		local tLifeLeech = self:getTalentFromId(self.T_LIFE_LEECH)
		local lifeLeeched = 0
		local attackStrength = 0.3 + self:getTalentLevel(tGloom) * 0.12
		local tormentHit = false

		if game.zone.wilderness then return end

		local doTorment = false
		local resetTorment = false
		if tTorment and self:getTalentLevelRaw(tTorment) > 0 then
			if not self.torment_turns then
				-- initialize turns
				resetTorment = true
			elseif self.torment_turns == 0 then
				-- attack one of our targets
				doTorment = true;
			else
				-- reduce Torment turns
				self.torment_turns = self.torment_turns - 1
			end
		end

		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(tGloom), true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local target = game.level.map(x, y, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then

					-- Gloom
					if tGloom and self:getTalentLevelRaw(tGloom) > 0 then
						local attackStrength = tGloom.getAttackStrength(self, tGloom, target)
						if checkWillFailure(self, target, 5, 35, attackStrength) then
							local effect = rng.range(1, 3)
							if effect == 1 then
								-- confusion
								if target:canBe("confusion") and not target:hasEffect(target.EFF_GLOOM_CONFUSED) then
									target:setEffect(target.EFF_GLOOM_CONFUSED, 2, {power=70})
									--game:playSoundNear(self, "talents/fire")
									hit = true
								end
							elseif effect == 2 then
								-- stun
								if target:canBe("stun") and not target:hasEffect(target.EFF_GLOOM_STUNNED) then
									target:setEffect(target.EFF_GLOOM_STUNNED, 2, {})
									--game:playSoundNear(self, "talents/fire")
									hit = true
								end
							elseif effect == 3 then
								-- slow
								if target:canBe("slow") and not target:hasEffect(target.EFF_GLOOM_SLOW) then
									target:setEffect(target.EFF_GLOOM_SLOW, 2, {power=0.3})
									--game:playSoundNear(self, "talents/fire")
									hit = true
								end
							end
						end
					end

					-- Weakness
					if tWeakness and self:getTalentLevelRaw(tWeakness) > 0 then
						local attackStrength = tGloom.getAttackStrength(self, tWeakness, target)
						if checkWillFailure(self, target, 10, 60, attackStrength) and not target:hasEffect(target.EFF_GLOOM_WEAKNESS) then
							local turns = 3 + math.ceil(self:getTalentLevel(tWeakness))

							local weapon = target:getInven("MAINHAND")
							if weapon then weapon = weapon[1] and weapon[1].combat end
							if not weapon or type(weapon) ~= "table" then weapon = nil end
							weapon = weapon or target.combat
							local attack = target:combatAttack(weapon) * (2 + self:getTalentLevel(tWeakness)) * 3.5 / 100
							local damage = target:combatDamage(weapon) * (2 + self:getTalentLevel(tWeakness)) * 3.5 / 100
							target:setEffect(target.EFF_GLOOM_WEAKNESS, turns, {atk=attack, dam=damage})
							hit = true
						end
					end

					-- Torment
					if doTorment then
						resetTorment = true
						local attackStrength = tGloom.getAttackStrength(self, tTorment, target)
						if checkWillFailure(self, target, 30, 95, attackStrength) then
							local tg = {type="hit", selffire=false, talent=tTorment}
							local damage = (30 + self:getWil() * 0.4 * self:getTalentLevel(tTorment)) * getHateMultiplier(self, 0.5, 1.5)
							local grids = self:project(tg, target.x, target.y, DamageType.DARKNESS, damage, {type="slime"})
							--game:playSoundNear(self, "talents/spell_generic")
							doTorment = false
						else
							game.logSeen(target, "#F53CBE#%s resists the torment.", target.name:capitalize())
						end
					end

					-- Life Leech
					if tLifeLeech and self:getTalentLevelRaw(tLifeLeech) > 0 then
						local damage = tLifeLeech.getDamage(self, tLifeLeech)
						local actualDamage = DamageType:get(DamageType.LIFE_LEECH).projector(self, target.x, target.y, DamageType.LIFE_LEECH, damage)
						lifeLeeched = lifeLeeched + actualDamage
					end
				end
			end
		end

		if resetTorment then
			self.torment_turns = 20
		end

		-- life leech
		if lifeLeeched > 0 then
			lifeLeeched = math.min(lifeLeeched, tLifeLeech.getMaxHeal(self, tLifeLeech))
			local temp = self.healing_factor
			self.healing_factor = 1
			self:heal(lifeLeeched)
			self.healing_factor = temp
			game.logPlayer(self, "#F53CBE#You leech %0.1f life from your foes.", lifeLeeched)
		end
	end,
	info = function(self, t)
		local effectiveness = getWillFailureEffectiveness(self, 5, 35, t.getAttackStrength(self, t, nil, false))
		local effectivenessStalk = getWillFailureEffectiveness(self, 5, 35, t.getAttackStrength(self, t, nil, true))
		return ([[A terrible gloom surrounds you, affecting all those who approach.
		The weak-minded may suffer from slowness, stun or confusion. (%d effectiveness, %d effectiveness vs stalked prey)
		This ability is innate and carries no cost to activate or deactivate.]]):format(effectiveness, effectivenessStalk)
	end,
}

newTalent{
	name = "Weakness",
	type = {"cursed/gloom", 2},
	mode = "passive",
	require = cursed_wil_req2,
	points = 5,
	info = function(self, t)
		local turns = 3 + math.ceil(self:getTalentLevel(t))
		local attack = (2 + self:getTalentLevel(t)) * 3.5
		local damage = (2 + self:getTalentLevel(t)) * 3.5
		local tGloom = self:getTalentFromId(self.T_GLOOM)
		local effectiveness = getWillFailureEffectiveness(self, 10, 60, tGloom.getAttackStrength(self, t, nil, false))
		local effectivenessStalk = getWillFailureEffectiveness(self, 10, 60, tGloom.getAttackStrength(self, t, nil, true))
		return ([[The weak-minded caught in your gloom are crippled by fear for %d turns. (-%d%% accuracy, -%d%% damage, %d effectiveness, %d effectiveness vs stalked prey)]]):format(turns, attack, damage, effectiveness, effectivenessStalk)
	end,
}

newTalent{
	name = "Torment",
	type = {"cursed/gloom", 3},
	mode = "passive",
	require = cursed_wil_req3,
	points = 5,
	info = function(self, t)
		local baseDamage = 30 + self:getWil() * 0.4 * self:getTalentLevel(t)
		local tGloom = self:getTalentFromId(self.T_GLOOM)
		local effectiveness = getWillFailureEffectiveness(self, 30, 95, tGloom.getAttackStrength(self, t, nil, false))
		local effectivenessStalk = getWillFailureEffectiveness(self, 30, 95, tGloom.getAttackStrength(self, t, nil, true))
		return ([[Your rage builds within you for 20 turns, then unleashes itself for %d (at 0 Hate) to %d (at 10+ Hate) darkness damage on the first one to enter your gloom. (%d effectiveness, %d effectiveness vs stalked prey)
		Improves with the Willpower stat.]]):format(baseDamage * .5, baseDamage * 1.5, effectiveness, effectivenessStalk)
	end,
}

newTalent{
	name = "Life Leech",
	type = {"cursed/gloom", 4},
	mode = "passive",
	require = cursed_wil_req4,
	points = 5,
	getDamage = function(self, t)
		return combatTalentDamage(self, t, 3, 15)
	end,
	getMaxHeal = function(self, t)
		return combatTalentDamage(self, t, 5, 30)
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local maxHeal = t.getMaxHeal(self, t)
		return ([[Every turn you leech %0.1f life from each foe in your gloom restoring up to a total of %0.1f of your own life. This form of healing cannot be reduced.
		Improves with the Willpower stat.]]):format(damage, maxHeal)
	end,
}
