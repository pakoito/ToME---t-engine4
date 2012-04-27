-- ToME - Tales of Middle-Earth
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

newTalent{
	name = "Instill Fear",
	type = {"cursed/fears", 1},
	require = cursed_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	hate = 8,
	range = 8,
	radius = function(self, t) return 2 end,
	tactical = { DISABLE = 2 },
	getDuration = function(self, t)
		return 8
	end,
	getParanoidAttackChance = function(self, t)
		return math.min(60, self:combatTalentMindDamage(t, 30, 50))
	end,
	getDespairResistAllChange = function(self, t)
		return -self:combatTalentMindDamage(t, 15, 40)
	end,
	hasEffect = function(self, t, target)
		if target:hasEffect(target.EFF_PARANOID) then return true end
		if target:hasEffect(target.EFF_DISPAIR) then return true end
		if target:hasEffect(target.EFF_TERRIFIED) then return true end
		if target:hasEffect(target.EFF_DISTRESSED) then return true end
		if target:hasEffect(target.EFF_HAUNTED) then return true end
		if target:hasEffect(target.EFF_TORMENTED) then return true end
		return false
	end,
	applyEffect = function(self, t, target)
		if not target:canBe("fear") then
			game.logSeen(target, "#F53CBE#%s ignores the fear!", target.name:capitalize())
			return true
		end
		
		local tHeightenFear = nil
		if self:knowTalent(self.T_HEIGHTEN_FEAR) then tHeightenFear = self:getTalentFromId(self.T_HEIGHTEN_FEAR) end
		local tTyrant = nil
		if self:knowTalent(self.T_TYRANT) then tTyrant = self:getTalentFromId(self.T_TYRANT) end
		local mindpowerChange = tTyrant and tTyrant.getMindpowerChange(self, tTyrant) or 0
		
		local mindpower = self:combatMindpower(1, mindpowerChange)
		if not target:checkHit(mindpower, target:combatMentalResist()) then
			game.logSeen(target, "%s resists the fear!", target.name:capitalize())
			return nil
		end
		
		local effects = {}
		if not target:hasEffect(target.EFF_PARANOID) then table.insert(effects, target.EFF_PARANOID) end
		if not target:hasEffect(target.EFF_DISPAIR) then table.insert(effects, target.EFF_DISPAIR) end
		if tHeightenFear and not target:hasEffect(target.EFF_TERRIFIED) then table.insert(effects, target.EFF_TERRIFIED) end
		if tHeightenFear and not target:hasEffect(target.EFF_DISTRESSED) then table.insert(effects, target.EFF_DISTRESSED) end
		if tTyrant and not target:hasEffect(target.EFF_HAUNTED) then table.insert(effects, target.EFF_HAUNTED) end
		if tTyrant and not target:hasEffect(target.EFF_TORMENTED) then table.insert(effects, target.EFF_TORMENTED) end
		
		if #effects == 0 then return nil end
		local effectId = rng.table(effects)
		
		local duration = t.getDuration(self, t)
		local eff = { source=self, duration=duration }
		if effectId == target.EFF_PARANOID then
			eff.attackChance = t.getParanoidAttackChance(self, t)
			eff.mindpower = mindpower
		elseif effectId == target.EFF_DISPAIR then
			eff.resistAllChange = t.getDespairResistAllChange(self, t)
		elseif effectId == target.EFF_TERRIFIED then
			eff.actionFailureChance = tHeightenFear.getTerrifiedActionFailureChance(self, tHeightenFear)
		elseif effectId == target.EFF_DISTRESSED then
			eff.saveChange = tHeightenFear.getDistressedSaveChange(self, tHeightenFear)
		elseif effectId == target.EFF_HAUNTED then
			eff.damage = tTyrant.getHauntedDamage(self, tTyrant)
		elseif effectId == target.EFF_TORMENTED then
			eff.count = tTyrant.getTormentedCount(self, tTyrant)
			eff.damage = tTyrant.getTormentedDamage(self, tTyrant)
			eff.counts = {}
			for i = 1, duration do
				eff.counts[i] = math.floor(eff.count / duration) + ((eff.count % duration >= i) and 1 or 0)
			end
		else
			print("* fears: failed to get effect", effectId)
		end
		
		target:setEffect(effectId, duration, eff)
		
		-- heightened fear
		if tHeightenFear and not target:hasEffect(target.EFF_HEIGHTEN_FEAR) then
			local turnsUntilTrigger = tHeightenFear.getTurnsUntilTrigger(self, tHeightenFear)
			target:setEffect(target.EFF_HEIGHTEN_FEAR, 1, { source=self, range=self:getTalentRange(tHeightenFear), turns=turnsUntilTrigger, turns_left=turnsUntilTrigger })
		end
		
		return effectId
	end,
	endEffect = function(self, t)
		local tHeightenFear = nil
		if self:knowTalent(self.T_HEIGHTEN_FEAR) then tHeightenFear = self:getTalentFromId(self.T_HEIGHTEN_FEAR) end
		if tHeightenFear then
			if not t.hasEffect(self, t) then
				-- no more fears
				self:removeEffect(self.EFF_HEIGHTEN_FEAR)
			end
		end
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target or core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		
		self:project(
			tg, x, y,
			function(px, py)
				local actor = game.level.map(px, py, engine.Map.ACTOR)
				if actor and self:reactionToward(actor) < 0 and actor ~= self then
					if actor == target or rng.percent(25) then
						local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
						tInstillFear.applyEffect(self, tInstillFear, actor)
					end
				end
			end,
			nil, nil)

		return true
	end,
	info = function(self, t)
		return ([[Instill fear in your target, causing one of several possible fears that lasts for %d turns. There is also a 25%% chance of instilling fear in any foe in a radius of %d. The target can save versus Mindpower to resist the effect and can be affected by multiple fears.  You gain 2 new fears: The Paranoid effect gives the target an %d%% chance to physically attack a nearby creature, friend or foe. If hit, their target will be afflicted with paranoia as well. The Despair effect reduces the targets resistance to all damage by %d%%.
		Fear effects improve with your Mindpower.]]):format(t.getDuration(self, t), self:getTalentRadius(t),
		t.getParanoidAttackChance(self, t),
		-t.getDespairResistAllChange(self, t))
	end,
}

newTalent{
	name = "Heighten Fear",
	type = {"cursed/fears", 2},
	require = cursed_wil_req2,
	mode = "passive",
	points = 5,
	range = function(self, t)
		return math.sqrt(self:getTalentLevel(t)) * 3
	end,
	getTurnsUntilTrigger = function(self, t)
		return 5
	end,
	getTerrifiedActionFailureChance = function(self, t)
		return math.min(50, self:combatTalentMindDamage(t, 20, 45))
	end,
	getDistressedSaveChange = function(self, t)
		return -self:combatTalentMindDamage(t, 15, 30)
	end,
	tactical = { DISABLE = 2 },
	info = function(self, t)
		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		local range = self:getTalentRange(t)
		local turnsUntilTrigger = t.getTurnsUntilTrigger(self, t)
		local duration = tInstillFear.getDuration(self, tInstillFear)
		return ([[Heighten the fears of everyone around you. Any foe experiencing at least one fear who remains in a radius of %d and in sight of you for %d (non-consecutive) turns will gain a new fear that lasts for %d turns. The target can save versus Mindpower to resist the effect and each heightened fear reduces the chances of another by 10%%. You gain 2 new fears: The Terrified effect causes talents and attacks to fail %d%% of the time. The Distressed effect reduces all saves by %d.
		Fear effects improve with your Mindpower.]]):format(range, turnsUntilTrigger, duration,
		t.getTerrifiedActionFailureChance(self, t),
		-t.getDistressedSaveChange(self, t))
	end,
}

newTalent{
	name = "Tyrant",
	type = {"cursed/fears", 3},
	mode = "passive",
	require = cursed_wil_req3,
	points = 5,
	on_learn = function(self, t)
	end,
	on_unlearn = function(self, t)
	end,
	getMindpowerChange = function(self, t)
		return math.floor(math.sqrt(self:getTalentLevel(t)) * 7)
	end,
	getHauntedDamage = function(self, t)
		return self:combatTalentMindDamage(t, 40, 60)
	end,
	getTormentedCount = function(self, t)
		return 4 + math.min(5, math.floor(math.pow(self:getTalentLevelRaw(t), 0.7)))
	end,
	getTormentedDamage = function(self, t)
		return self:combatTalentMindDamage(t, 40, 60)
	end,
	info = function(self, t)
		return ([[Impose your tyranny on the minds of those who fear you. Your mindpower is increased by %d against foes who attempt to resist your fears. You gain 2 new fears: The Haunted effect causes each existing or new fear effect that the target suffers from to inflict %d mind damage. The Tormented effect causes %d apparitions to manifest and attack the target, inflicting %d mind damage each before disappearing.
		Fear effects improve with your Mindpower.]]):format(t.getMindpowerChange(self, t),
		t.getHauntedDamage(self, t),
		t.getTormentedCount(self, t), t.getTormentedDamage(self, t))
	end,
}

newTalent{
	name = "Panic",
	type = {"cursed/fears", 4},
	require = cursed_wil_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 20,
	hate =  1,
	range = 4,
	tactical = { DISABLE = 4 },
	getDuration = function(self, t)
		return 3 + math.floor(math.pow(self:getTalentLevel(t), 0.5) * 2.2)
	end,
	getChance = function(self, t)
		return math.min(60, math.floor(30 + (math.sqrt(self:getTalentLevel(t)) - 1) * 22))
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		self:project(
			{type="ball", radius=range}, self.x, self.y,
			function(px, py)
				local actor = game.level.map(px, py, engine.Map.ACTOR)
				if actor and self:reactionToward(actor) < 0 and actor ~= self then
					if not actor:canBe("fear") then
						game.logSeen(actor, "#F53CBE#%s ignores the panic!", actor.name:capitalize())
					elseif actor:checkHit(self:combatMindpower(), actor:combatMentalResist(), 0, 95) then
						actor:setEffect(actor.EFF_PANICKED, duration, {source=self,range=10,chance=chance})
					else
						game.logSeen(actor, "#F53CBE#%s resists the panic!", actor.name:capitalize())
					end
				end
			end,
			nil, nil)
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([[Panic your enemies within a range of %d for %d turns. Anyone who fails to make a mental save has a %d%% chance each turn of trying to run from you.]]):format(range, duration, chance)
	end,
}
