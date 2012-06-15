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
	getChance = function(self, t)
		return math.sqrt(self:getTalentLevel(t)) * 7
	end,
	getDuration = function(self, t)
		return 3
	end,
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
		if game.zone.wilderness then return end

		-- all gloom effects are handled here
		local tWeakness = self:getTalentFromId(self.T_WEAKNESS)
		local tDismay = self:getTalentFromId(self.T_DISMAY)
		local tSanctuary = self:getTalentFromId(self.T_SANCTUARY)
		--local tLifeLeech = self:getTalentFromId(self.T_LIFE_LEECH)
		--local lifeLeeched = 0
		
		--local mindpower = self:combatMindpower(1, self:getTalentLevelRaw(tGloom) + self:getTalentLevelRaw(tWeakness) + self:getTalentLevelRaw(tDismayed) + self:getTalentLevelRaw(tLifeLeech))
		local mindpower = self:combatMindpower(1, self:getTalentLevelRaw(tGloom) + self:getTalentLevelRaw(tWeakness) + self:getTalentLevelRaw(tDismayed) + self:getTalentLevelRaw(tSanctuary))
		
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(tGloom), true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local target = game.level.map(x, y, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					-- check for hate bonus against tough foes
					if target.rank >= 3.5 and not target.gloom_hate_bonus then
						local hateGain = target.rank >= 4 and 20 or 10
						self:incHate(hateGain)
						game.logPlayer(self, "#F53CBE#Your heart hardens as a powerful foe enters your gloom! (+%d hate)", hateGain)
						target.gloom_hate_bonus = true
					end
				
					-- Gloom
					if self:getTalentLevel(tGloom) > 0 and rng.percent(tGloom.getChance(self, tGloom)) and target:checkHit(mindpower, target:combatMentalResist(), 5, 95, 15) then
						local effect = rng.range(1, 3)
						if effect == 1 then
							-- confusion
							if target:canBe("confusion") and not target:hasEffect(target.EFF_GLOOM_CONFUSED) then
								target:setEffect(target.EFF_GLOOM_CONFUSED, 2, {power=70})
								hit = true
							end
						elseif effect == 2 then
							-- stun
							if target:canBe("stun") and not target:hasEffect(target.EFF_GLOOM_STUNNED) then
								target:setEffect(target.EFF_GLOOM_STUNNED, 2, {})
								hit = true
							end
						elseif effect == 3 then
							-- slow
							if target:canBe("slow") and not target:hasEffect(target.EFF_GLOOM_SLOW) then
								target:setEffect(target.EFF_GLOOM_SLOW, 2, {power=0.3})
								hit = true
							end
						end
					end

					-- Weakness
					if self:getTalentLevel(tWeakness) > 0 and rng.percent(tWeakness.getChance(self, tWeakness)) and target:checkHit(mindpower, target:combatMentalResist(), 5, 95, 15) then
						if not target:hasEffect(target.EFF_GLOOM_WEAKNESS) then
							local duration = tWeakness.getDuration(self, tWeakness)
							local incDamageChange = tWeakness.getIncDamageChange(self, tWeakness)
							local hateBonus = tWeakness.getHateBonus(self, tWeakness)
							target:setEffect(target.EFF_GLOOM_WEAKNESS, duration, {incDamageChange=incDamageChange,hateBonus=hateBonus})
							hit = true
						end
					end

					-- Dismay
					if self:getTalentLevel(tDismay) > 0 and rng.percent(tDismay.getChance(self, tDismay)) and target:checkHit(mindpower, target:combatMentalResist(), 5, 95, 15) then
						target:setEffect(target.EFF_DISMAYED, tDismay.getDuration(self, tDismay), {})
					end

					-- Life Leech
					--if tLifeLeech and self:getTalentLevel(tLifeLeech) > 0 and target:checkHit(mindpower, target:combatMentalResist(), 5, 95, 15) then
					--	local damage = tLifeLeech.getDamage(self, tLifeLeech)
					--	local actualDamage = DamageType:get(DamageType.LIFE_LEECH).projector(self, target.x, target.y, DamageType.LIFE_LEECH, damage)
					--	lifeLeeched = lifeLeeched + actualDamage
					--end
				end
			end
		end

		-- life leech
		--if lifeLeeched > 0 then
		--	lifeLeeched = math.min(lifeLeeched, tLifeLeech.getMaxHeal(self, tLifeLeech))
		--	local temp = self.healing_factor
		--	self.healing_factor = 1
		--	self:heal(lifeLeeched)
		--	self.healing_factor = temp
		--	game.logPlayer(self, "#F53CBE#You leech %0.1f life from your foes.", lifeLeeched)
		--end
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local duration = t.getDuration(self, t)
		local mindpowerChange = self:getTalentLevelRaw(self.T_GLOOM) + self:getTalentLevelRaw(self.T_WEAKNESS) + self:getTalentLevelRaw(self.T_DISMAY) + self:getTalentLevelRaw(self.T_SANCTUARY)
		return ([[A terrible gloom surrounds you, affecting all those who approach. Each turn, those caught in your gloom must save against your mindpower or have an %d%% chance to suffer from slowness, stun or confusion for %d turns.
		This ability is innate and carries no cost to activate or deactivate. Each point in Gloom increases the mindpower of all gloom effects (current: %+d).]]):format(chance, duration, mindpowerChange)
	end,
}

newTalent{
	name = "Weakness",
	type = {"cursed/gloom", 2},
	mode = "passive",
	require = cursed_wil_req2,
	points = 5,
	getChance = function(self, t)
		return math.sqrt(self:getTalentLevel(t)) * 7
	end,
	getDuration = function(self, t)
		return 3
	end,
	getIncDamageChange = function(self, t)
		return -math.sqrt(self:getTalentLevel(t)) * 12
	end,
	getHateBonus = function(self, t)
		return 2
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local duration = t.getDuration(self, t)
		local incDamageChange = t.getIncDamageChange(self, t)
		local hateBonus = t.getHateBonus(self, t)
		local mindpowerChange = self:getTalentLevelRaw(self.T_GLOOM) + self:getTalentLevelRaw(self.T_WEAKNESS) + self:getTalentLevelRaw(self.T_DISMAY) + self:getTalentLevelRaw(self.T_SANCTUARY)
		return ([[Each turn, those caught in your gloom must save against your mindpower or have an %d%% chance to be crippled by fear for %d turns, reducing damage they inflict by %d%%. The first time you melee strike a foe after they have been weakened will give you %d hate.
		Each point in Weakness increases the mindpower of all gloom effects (current: %+d).]]):format(chance, duration, -incDamageChange, hateBonus, mindpowerChange)
	end,
}

newTalent{
	name = "Dismay",
	type = {"cursed/gloom", 3},
	mode = "passive",
	require = cursed_wil_req3,
	points = 5,
	getChance = function(self, t)
		return math.sqrt(self:getTalentLevel(t)) * 3.5
	end,
	getDuration = function(self, t)
		return 3
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local duration = t.getDuration(self, t)
		local mindpowerChange = self:getTalentLevelRaw(self.T_GLOOM) + self:getTalentLevelRaw(self.T_WEAKNESS) + self:getTalentLevelRaw(self.T_DISMAY) + self:getTalentLevelRaw(self.T_SANCTUARY)
		return ([[Each turn, those caught in your gloom must save against your mindpower or have an %0.1f%% chance of becoming dismayed for %d turns. When dismayed, the first melee attack against the foe will result in a critical hit.
		Each point in Dismay increases the mindpower of all gloom effects (current: %+d).]]):format(chance, duration, mindpowerChange)
	end,
}

--newTalent{
--	name = "Life Leech",
--	type = {"cursed/gloom", 4},
--	mode = "passive",
--	require = cursed_wil_req4,
--	points = 5,
--	getDamage = function(self, t)
--		return combatTalentDamage(self, t, 2, 10)
--	end,
--	getMaxHeal = function(self, t)
--		return combatTalentDamage(self, t, 4, 25)
--	end,
--	info = function(self, t)
--		local damage = t.getDamage(self, t)
--		local maxHeal = t.getMaxHeal(self, t)
--		local mindpowerChange = self:getTalentLevelRaw(self.T_GLOOM) + self:getTalentLevelRaw(self.T_WEAKNESS) + self:getTalentLevelRaw(self.T_DISMAY) + self:getTalentLevelRaw(self.T_LIFE_LEECH)
--		return ([[Each turn, those caught in your gloom must save against your mindpower or have %0.1f life leeched from them. Life leeched in this way will restore up to a total of %0.1f of your own life per turn. This form of healing is unaffected by healing modifiers.
--		Each point in Life Leech increases the mindpower of all gloom effects (current: %+d).]]):format(damage, maxHeal, mindpowerChange)
--	end,
--}

newTalent{
	name = "Sanctuary",
	type = {"cursed/gloom", 4},
	mode = "passive",
	require = cursed_wil_req4,
	points = 5,
	getDamageChange = function(self, t)
		return math.max(-35, -math.sqrt(self:getTalentLevel(t)) * 11)
	end,
	info = function(self, t)
		local damageChange = t.getDamageChange(self, t)
		local mindpowerChange = self:getTalentLevelRaw(self.T_GLOOM) + self:getTalentLevelRaw(self.T_WEAKNESS) + self:getTalentLevelRaw(self.T_DISMAY) + self:getTalentLevelRaw(self.T_SANCTUARY)
		return ([[Your gloom has become a sanctuary from the outside world. Damage from any attack that originates beyond the boundary of your gloom is reduced by %d%%.
		Each point in Sanctuary increases the mindpower of all gloom effects (current: %+d).]]):format(-damageChange, mindpowerChange)
	end,
}
