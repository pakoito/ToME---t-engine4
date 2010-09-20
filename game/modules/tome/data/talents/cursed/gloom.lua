-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

local function getHateMultiplier(self, min, max)
	return (min + ((max - min) * self.hate / 10))
end

local function getWillDamage(self, t, base, max)
	-- Compute at "max"
	local mod = max / ((base + 100) * ((math.sqrt(5) - 1) * 0.8 + 1))
	-- Compute real
	return (base + self:getWil()) * ((math.sqrt(self:getTalentLevel(t)) - 1) * 0.8 + 1) * mod
end

local function checkWillFailure(self, target, minChance, maxChance, attackStrength)
	-- attack power is analogous to mental resist except all willpower and no cunning
	local attack = self:getWil() * 0.5 * attackStrength
	local defense = target:combatMentalResist()

	-- used this instead of checkHit to get a curve that is a little more ratio dependent than difference dependent.
	-- + 10 prevents large changes for low attack/defense values
	-- 2 * log adjusts falloff to roughly get 0% break near attack = 0.5 * defense and 100% break near attack = 2 * defense
	local chance = minChance + (1 + 2 * math.log((attack + 10) / (defense + 10))) * (maxChance - minChance) * 0.5

	local result = rng.avg(1, 100)
	--game.logSeen(target, "[%s]: %0.3f / %0.3f; %d vs %d; %d to %d", target.name:capitalize(), result, chance, attack, defense, minChance, maxChance)

	if result <= minChance then return true end
	if result >= maxChance then return false end
	return result <= chance, chance
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
	activate = function(self, t)
		self.torment_turns = nil -- restart torment
		game:playSoundNear(self, "talents/arcane")
		return {
			particle = self:addParticles(Particles.new("gloom", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	do_gloom = function(self, tGloom)
		-- all gloom effects are handled here
		local tWeakness = self:getTalentFromId(self.T_WEAKNESS)
		local tTorment = self:getTalentFromId(self.T_TORMENT)
		local tAbsorbLife = self:getTalentFromId(self.T_ABSORB_LIFE)
		local lifeAbsorbed = 0
		local attackStrength = 0.3 + self:getTalentLevel(tGloom) * 0.12
		local tormentHit = false

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
				if target
						and self:reactionToward(target) < 0
						and (not target.stalker or target.stalker ~= self) then

					-- Gloom
					if tGloom and self:getTalentLevelRaw(tGloom) > 0 then
						local attackStrength = 0.3 + self:getTalentLevel(tGloom) * 0.12
						if checkWillFailure(self, target, 5, 35, attackStrength) then
							local effect = rng.range(1, 3)
							if effect == 1 then
								-- confusion
								if target:canBe("confusion") and not target:hasEffect(target.EFF_GLOOM_CONFUSED) then
									target:setEffect(target.EFF_GLOOM_CONFUSED, 2, {power=0.75})
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
						local attackStrength = 0.3 + self:getTalentLevel(tWeakness) * 0.12
						if checkWillFailure(self, target, 10, 60, attackStrength) and not target:hasEffect(target.EFF_GLOOM_WEAKNESS) then
							local turns = 3 + math.ceil(self:getTalentLevel(tWeakness))

							local weapon = target:getInven("MAINHAND")
							if weapon then
								weapon = weapon[1] and weapon[1].combat
							end
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
						local attackStrength = 0.3 + self:getTalentLevel(tTorment) * 0.12
						if checkWillFailure(self, target, 30, 95, attackStrength) then
							local tg = {type="hit", friendlyfire=false, talent=tTorment}
							local grids = self:project(tg, target.x, target.y, DamageType.BLIGHT, 30 + self:getWil() * 0.4 * self:getTalentLevel(tTorment), {type="slime"})
							--game:playSoundNear(self, "talents/spell_generic")
							doTorment = false
						else
							game.logSeen(target, "#F53CBE#%s resists your torment.", target.name:capitalize())
						end
					end

					-- Absorb Life
					if tAbsorbLife and self:getTalentLevelRaw(tAbsorbLife) > 0 then
						local fraction = self:getTalentLevel(tAbsorbLife) * 0.002
						local damage = math.min(target.max_life * fraction, self.max_life * fraction * 2)
						local actualDamage = DamageType:get(DamageType.ABSORB_LIFE).projector(self, target.x, target.y, DamageType.ABSORB_LIFE, damage)
						lifeAbsorbed = lifeAbsorbed + actualDamage
						--game.logSeen(target, "#F53CBE#You absorb %.2f life from %s!", actualDamage, target.name:capitalize())
					end
				end
			end
		end

		if resetTorment then
			self.torment_turns = 20
		end

		-- absorb life
		if lifeAbsorbed > 0 then
			self:heal(lifeAbsorbed)
			game.logPlayer(self, "#F53CBE#You absorb %0.1f life from your foes.", lifeAbsorbed)
		end
	end,
	info = function(self, t)
		local attackStrength = 0.3 + self:getTalentLevel(t) * 0.12
		local effectiveness = getWillFailureEffectiveness(self, 5, 35, attackStrength)
		return ([[A terrible gloom surrounds you affecting all those who approach.
		The weak-minded may suffer from slow, stun or confusion. (%d effectiveness)
		This ability is innate and carries no cost to activate or deactivate.]]):format(effectiveness)
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
		local attackStrength = 0.3 + self:getTalentLevel(t) * 0.12
		local effectiveness = getWillFailureEffectiveness(self, 10, 60, attackStrength)
		return ([[The weak-minded caught in your gloom are crippled by fear for %d turns. (-%d%% attack, -%d%% damage, %d effectiveness)]]):format(turns, attack, damage, effectiveness)
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
		local attackStrength = 0.3 + self:getTalentLevel(t) * 0.12
		local effectiveness = getWillFailureEffectiveness(self, 30, 95, attackStrength)
		return ([[Your rage builds within you for 20 turns then unleashes itself for %d to %d hate-based blight damage on the first one to enter your gloom. (%d effectiveness)]]):format(baseDamage * .5, baseDamage * 1.5, effectiveness)
	end,
}

newTalent{
	name = "Life Leech",
	type = {"cursed/gloom", 4},
	mode = "passive",
	require = cursed_wil_req4,
	points = 5,
	info = function(self, t)
		return ([[Each turn your gloom leeches up to %0.1f%% of the life of foes.]]):format(self:getTalentLevel(t) * 0.2)
	end,
}
