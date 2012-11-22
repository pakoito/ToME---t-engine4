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

-- Generic requires for racial based on talent level
racial_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
racial_req2 = {
	level = function(level) return 8 + (level-1)  end,
}
racial_req3 = {
	level = function(level) return 16 + (level-1)  end,
}
racial_req4 = {
	level = function(level) return 24 + (level-1)  end,
}

------------------------------------------------------------------
-- Highers' powers
------------------------------------------------------------------
newTalentType{ type="race/higher", name = "higher", generic = true, description = "The various racial bonuses a character can have." }

newTalent{
	short_name = "HIGHER_HEAL",
	name = "Gift of the Highborn",
	type = {"race/higher", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	tactical = { HEAL = 2 },
	on_pre_use = function(self, t) return not self:hasEffect(self.EFF_REGENERATION) end,
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 10, {power=5 + self:getWil() * 0.5})
		return true
	end,
	info = function(self, t)
		return ([[Call upon the gift of the highborn to regenerate your body for %d life every turn for 10 turns.
		The life healed will increase with the Willpower stat.]]):format(5 + self:getWil() * 0.5)
	end,
}

newTalent{
	name = "Overseer of Nations",
	type = {"race/higher", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.sight = self.sight + 1
		self.heightened_senses = (self.heightened_senses or 0) + 1
		self.infravision = (self.infravision or 0) + 1
	end,
	on_unlearn = function(self, t)
		self.sight = self.sight - 1
		self.heightened_senses = (self.heightened_senses or 0) - 1
		self.infravision = (self.infravision or 0) - 1
	end,
	info = function(self, t)
		return ([[While Highers are not meant to rule other humans - and show no particular will to do so - they are frequently called to higher duties.
		Their nature grants them better senses than other humans.
		Increase maximum sight range by %d and increases existing lite, infravision, and heightened senses range by %d.]]):
		format(self:getTalentLevelRaw(t), math.ceil(self:getTalentLevelRaw(t)/2))
	end,
}

newTalent{
	name = "Born into Magic",
	type = {"race/higher", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.combat_spellresist = self.combat_spellresist + 5
		self.resists[DamageType.ARCANE] = (self.resists[DamageType.ARCANE] or 0) + 5
		self.inc_damage[DamageType.ARCANE] = (self.inc_damage[DamageType.ARCANE] or 0) + 5
	end,
	on_unlearn = function(self, t)
		self.combat_spellresist = self.combat_spellresist - 5
		self.resists[DamageType.ARCANE] = (self.resists[DamageType.ARCANE] or 0) - 5
		self.inc_damage[DamageType.ARCANE] = (self.inc_damage[DamageType.ARCANE] or 0) - 5
	end,
	info = function(self, t)
		return ([[Highers were originally created during the Age of Allure by the human Conclave. They are imbued with magic at the very core of their being.
		Increase spell save by +%d, arcane damage by %d%%, and arcane resistance by %d%%.]]):
		format(self:getTalentLevelRaw(t) * 5, self:getTalentLevelRaw(t) * 5, self:getTalentLevelRaw(t) * 5)
	end,
}

newTalent{
	name = "Highborn's Bloom",
	type = {"race/higher", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 3 end,
	tactical = { MANA = 2, VIM = 2, EQUILIBRIUM = 2, STAMINA = 2, POSITIVE = 2, NEGATIVE = 2, PARADOX = 2, PSI = 2 },
	getDuration = function(self, t) return 1 + math.ceil(self:getTalentLevelRaw(t)/2) end,
	action = function(self, t)
		self:setEffect(self.EFF_HIGHBORN_S_BLOOM, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Activate some of your inner magic, using it to power your abilities.  For the next %d turns all active talents will be used without resource cost.
		Your resources must still be high enough to initially power the talent and failure rates (etc.) still apply.
		]]):format(duration)
	end,
}

------------------------------------------------------------------
-- Shaloren's powers
------------------------------------------------------------------
newTalentType{ type="race/shalore", name = "shalore", generic = true, is_spell=true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "SHALOREN_SPEED",
	name = "Grace of the Eternals",
	type = {"race/shalore", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 4 end,
	tactical = { DEFEND = 1 },
	action = function(self, t)
		local power = 0.1 + self:getDex() / 210
		self:setEffect(self.EFF_SPEED, 8, {power=power})
		return true
	end,
	info = function(self, t)
		return ([[Call upon the grace of the Eternals to increase your general speed by %d%% for 8 turns.
		The speed bonus will increase with the Dexterity stat.]]):format((0.1 + self:getDex() / 210) * 100)
	end,
}

newTalent{
	name = "Magic of the Eternals",
	type = {"race/shalore", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.combat_physcrit = self.combat_physcrit + 2
		self.combat_spellcrit = self.combat_spellcrit + 2
		self.combat_mindcrit = self.combat_mindcrit + 2
	end,
	on_unlearn = function(self, t)
		self.combat_physcrit = self.combat_physcrit - 2
		self.combat_spellcrit = self.combat_spellcrit - 2
		self.combat_mindcrit = self.combat_mindcrit - 2
	end,
	info = function(self, t)
		return ([[Reality bends slightly in the presence of a Shaloren due to their inherent magical nature.
		Increases critical chance by %d%%.]]):format(self:getTalentLevelRaw(t) * 2)
	end,
}

newTalent{
	name = "Secrets of the Eternals",
	type = {"race/shalore", 3},
	require = racial_req3,
	points = 5,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 3 end,
	mode = "sustained",
	no_energy = true,
	activate = function(self, t)
		self.invis_on_hit_disable = self.invis_on_hit_disable or {}
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			invis = self:addTemporaryValue("invis_on_hit", self:getTalentLevelRaw(t) * 5),
			power = self:addTemporaryValue("invis_on_hit_power", 5 + self:getMag(20, true)),
			talent = self:addTemporaryValue("invis_on_hit_disable", {[t.id]=1}),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("invis_on_hit", p.invis)
		self:removeTemporaryValue("invis_on_hit_power", p.power)
		self:removeTemporaryValue("invis_on_hit_disable", p.talent)
		return true
	end,
	info = function(self, t)
		return ([[As the only immortal race of Eyal, Shaloren have learnt, over the long years, to use their innate inner magic to protect themselves.
		%d%% chance to become invisible (power %d) for 5 turns when hit by a blow doing at least 15%% of their total life.]]):
		format(self:getTalentLevelRaw(t) * 5, 5 + self:getMag(20, true))
	end,
}

newTalent{
	name = "Timeless",
	type = {"race/shalore", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 3 end,
	tactical = {
		BUFF = function(self, t, target)
			local nb = 0
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.status == "beneficial" then nb = nb + 1 end
			end
			return nb
		end,
		CURE = function(self, t, target)
			local nb = 0
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.status == "detrimental" then nb = nb + 1 end
			end
			return nb
		end,
	},
	action = function(self, t)
		local target = self
		local todel = {}
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.type ~= "other" then
				if e.status == "beneficial" then
					p.dur = p.dur + self:getTalentLevelRaw(t)
				elseif e.status == "detrimental" then
					p.dur = p.dur - self:getTalentLevelRaw(t) * 2
					if p.dur <= 0 then todel[#todel+1] = eff end
				end
			end
		end
		while #todel > 0 do
			target:removeEffect(table.remove(todel))
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[The world grows old as you stand the ages. To you time is different.
		Reduces the time remaining on detrimental effects by %d and increases the time remaining on beneficial effects by %d.]]):
		format(self:getTalentLevelRaw(t) * 2, self:getTalentLevelRaw(t))
	end,
}

------------------------------------------------------------------
-- Thaloren's powers
------------------------------------------------------------------
newTalentType{ type="race/thalore", name = "thalore", generic = true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "THALOREN_WRATH",
	name = "Wrath of the Woods",
	type = {"race/thalore", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	tactical = { ATTACK = 1, DEFEND = 1 },
	action = function(self, t)
		self:setEffect(self.EFF_ETERNAL_WRATH, 5, {power=7 + self:getWil(10, true)})
		return true
	end,
	info = function(self, t)
		return ([[Call upon the power of the Eternals, increasing all damage by %d%% and reducing all damage taken by %d%% for 5 turns.
		The bonus will increase with the Willpower stat.]]):format(7 + self:getWil(10, true), 7 + self:getWil(10, true))
	end,
}

newTalent{
	name = "Unshackled",
	type = {"race/thalore", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.combat_physresist = self.combat_physresist + 5
		self.combat_mentalresist = self.combat_mentalresist + 5
	end,
	on_unlearn = function(self, t)
		self.combat_physresist = self.combat_physresist - 5
		self.combat_mentalresist = self.combat_mentalresist - 5
	end,
	info = function(self, t)
		return ([[Thaloren have always been a free people, living in their beloved forest, never caring much about the world outside.
		Increase physical and mental save by +%d.]]):format(self:getTalentLevelRaw(t) * 5)
	end,
}

newTalent{
	name = "Guardian of the Wood",
	type = {"race/thalore", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:attr("disease_immune", 0.12)
		self.resists[DamageType.BLIGHT] = (self.resists[DamageType.BLIGHT] or 0) + 4
	end,
	on_unlearn = function(self, t)
		self:attr("disease_immune", -0.12)
		self.resists[DamageType.BLIGHT] = (self.resists[DamageType.BLIGHT] or 0) - 4
	end,
	info = function(self, t)
		return ([[You are part of the wood, it shields you from corruption.
		Increase disease immunity by %d%% and blight resistance by %d%%.]]):format(self:getTalentLevelRaw(t) * 12, self:getTalentLevelRaw(t) * 4)
	end,
}

newTalent{
	name = "Nature's Pride",
	type = {"race/thalore", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 3 end,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = { stun = 1, knockback = 1 } },
	range = 4,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		for i = 1, 2 do
			local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to summon!")
				return
			end

			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "immovable", subtype = "plants",
				display = "#",
				name = "treant", color=colors.GREEN,
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/immovable_plants_treant.png", display_h=2, display_y=-1}}},
				desc = "A very strong near-sentient tree.",

				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

				rank = 3,
				life_rating = 13,
				max_life = resolvers.rngavg(50,80),
				infravision = 10,

				autolevel = "none",
				ai = "summoned", ai_real = "tactical", ai_state = { talent_in=2, },
				stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
				combat = { dam=resolvers.levelup(resolvers.rngavg(15,25), 1, 1.3), atk=resolvers.levelup(resolvers.rngavg(15,25), 1, 1.3), dammod={str=1.1} },
				inc_stats = { str=25 + self:getWil() * self:getTalentLevel(t) / 5, dex=18, con=10 + self:getTalentLevel(t) * 2, },

				level_range = {1, nil}, exp_worth = 0,
				silent_levelup = true,

				combat_armor = 13, combat_def = 8,
				resolvers.talents{ [Talents.T_STUN]=3, [Talents.T_KNOCKBACK]=2, },

				faction = self.faction,
				summoner = self, summoner_gain_exp=true,
				summon_time = 6,
				ai_target = {actor=target}
			}
			setupSummon(self, m, x, y)
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Nature is with you, you can always feel the call of the woods.
		Summons two elite Treants to your side for 6 turns.
		Their strength increases with your Willpower stat.]]):format()
	end,
}

------------------------------------------------------------------
-- Dwarves' powers
------------------------------------------------------------------
newTalentType{ type="race/dwarf", name = "dwarf", generic = true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "DWARF_RESILIENCE",
	name = "Resilience of the Dwarves",
	type = {"race/dwarf", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	tactical = { DEFEND = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_DWARVEN_RESILIENCE, 8, {
			armor=5 + self:getCon() / 5,
			physical=10 + self:getCon() / 5,
			spell=10 + self:getCon() / 5,
		})
		return true
	end,
	info = function(self, t)
		return ([[Call upon the legendary resilience of the Dwarven race to increase your armor(+%d), spell(+%d) and physical(+%d) saves for 8 turns.
		The bonus will increase with the Constitution stat.]]):format(5 + self:getCon() / 5, 10 + self:getCon() / 5, 10 + self:getCon() / 5)
	end,
}

newTalent{
	name = "Stoneskin",
	type = {"race/dwarf", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:attr("auto_stoneskin", 6)
	end,
	on_unlearn = function(self, t)
		self:attr("auto_stoneskin", -6)
	end,
	info = function(self, t)
		return ([[Dwarf skin is a complex structure, it can automatically react to physical blows to harden itself.
		15%% chance when hit in melee to increase armour total by %d for 5 turns.]]):format(self:getTalentLevelRaw(t) * 6)
	end,
}

newTalent{
	name = "Power is Money",
	type = {"race/dwarf", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	info = function(self, t)
		return ([[Money is the heart of the dwarven Empire, it rules over all other considerations.
		Increases physical, mental and spell saves based on the amount of gold you possess.
		+1 save every %d gold, up to +%d.]]):format(90 - self:getTalentLevelRaw(t) * 5, self:getTalentLevelRaw(t) * 7)
	end,
}

newTalent{
	name = "Stone Walking",
	type = {"race/dwarf", 4},
	require = racial_req4,
	points = 5,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	range = 1,
	no_npc_use = true,
	getRange = function(self, t) return math.floor(1 + self:getCon(4, true) + self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		self:probabilityTravel(x, y, t.getRange(self, t))
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		return ([[While the origins of the dwarves remain clouded in mysteries to the other races it is obvious they share strong ties to the stone.
		You can target any wall and immediately enter it and appear on the other side of the obstacle.
		Works up to %d grids away (increases with Constitution and talent level).]]):
		format(range)
	end,
}

------------------------------------------------------------------
-- Halflings' powers
------------------------------------------------------------------
newTalentType{ type="race/halfling", name = "halfling", generic = true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "HALFLING_LUCK",
	name = "Luck of the Little Folk",
	type = {"race/halfling", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	tactical = { ATTACK = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_HALFLING_LUCK, 5, {
			physical=10 + self:getCun() / 2,
			spell=10 + self:getCun() / 2,
			mind=10 + self:getCun() / 2,
		})
		return true
	end,
	info = function(self, t)
		return ([[Call upon the luck and cunning of the Little Folk to increase your physical, mental, and spell critical strike chance by %d%% for 5 turns.
		The bonus will increase with the Cunning stat.]]):format(10 + self:getCun() / 2, 10 + self:getCun() / 2)
	end,
}

newTalent{
	name = "Duck and Dodge",
	type = {"race/halfling", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getThreshold = function(self, t) return math.max(10, (15 - self:getTalentLevelRaw(t))) / 100 end,
	getEvasionChance = function(self, t) return self:getStat("lck") end,
	getDuration = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)/2) end,
	info = function(self, t)
		local threshold = t.getThreshold(self, t)
		local evasion = t.getEvasionChance(self, t)
		local duration = t.getDuration(self, t)
		return ([[Your incredible luck kicks in at just the right moment to save your skin.
		Whenever you take %d%% or more of your life from a single attack you gain Evasion equal to your luck stat (currently %d%%) for the next %d turns.]]):
		format(threshold * 100, evasion, duration)
	end,
}

newTalent{
	name = "Militant Mind",
	type = {"race/halfling", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	info = function(self, t)
		return ([[Halflings have always been a very organised and methodical race, the more foes they face the more organised they are.
		If two or more foes are in sight your physical power, physical save, spellpower, spell save, mental save, and mindpower are increased by %0.1f per foes (up to 5 foes).]]):
		format(self:getTalentLevel(t) * 0.6)
	end,
}

newTalent{
	name = "Indomitable",
	type = {"race/halfling", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	tactical = { DEFEND = 1,  CURE = 1 },
	getRemoveCount = function(self, t) return 1 + self:getTalentLevel(t) end,
	getDuration = function(self, t) return 1 + self:getTalentLevel(t) end,
	action = function(self, t)
		local effs = {}

		-- Go through all effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.subtype.stun or e.subtype.pin then -- Daze is stun subtype
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				self:removeEffect(eff[2])
			end
		end
	
		self:setEffect(self.EFF_FREE_ACTION, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local count = t.getRemoveCount(self, t)
		return ([[Halflings are one of the more powerful military force of the known world, they have been at war with most other races for thousand of years.
		Removes %d stun, daze, or pin effects and makes you immune to stuns, dazes and pins for %d turns.
		This talent takes no time to use.]]):format(duration, count)
	end,
}

------------------------------------------------------------------
-- Orcs' powers
------------------------------------------------------------------
newTalentType{ type="race/orc", name = "orc", generic = true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "ORC_FURY",
	name = "Orcish Fury",
	type = {"race/orc", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 4 end,
	tactical = { ATTACK = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_ORC_FURY, 5, {power=10 + self:getWil(20, true)})
		return true
	end,
	info = function(self, t)
		return ([[Summons your lust for blood and destruction, increasing all damage by %d%% for 5 turns.
		The bonus will increase with the Willpower stat.]]):format(10 + self:getWil(20, true))
	end,
}

newTalent{
	name = "Hold the Ground",
	type = {"race/orc", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.combat_physresist = self.combat_physresist + 5
		self.combat_mentalresist = self.combat_mentalresist + 5
	end,
	on_unlearn = function(self, t)
		self.combat_physresist = self.combat_physresist - 5
		self.combat_mentalresist = self.combat_mentalresist - 5
	end,
	info = function(self, t)
		return ([[Orcs have been the prey of the other races for thousands of years, with or without reasons. They have learnt to withstand things that would break weaker races.
		Increase physical and mental save by +%d.]]):format(self:getTalentLevelRaw(t) * 5)
	end,
}

newTalent{
	name = "Skirmisher",
	type = {"race/orc", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.resists_pen.all = (self.resists_pen.all or 0) + 5
	end,
	on_unlearn = function(self, t)
		self.resists_pen.all = (self.resists_pen.all or 0) - 5
	end,
	info = function(self, t)
		return ([[Orcs have seen many battles, and won many of them.
		Increase all damage penetration by %d%%.]]):format(self:getTalentLevelRaw(t) * 5)
	end,
}

newTalent{
	name = "Pride of the Orcs",
	type = {"race/orc", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 4 end,
	is_heal = true,
	tactical = { DEFEND = 1, HEAL = 2, CURE = function(self, t, target)
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and (e.type == "physical" or e.type == "magical" or e.type == "mental") then
				nb = nb + 1
			end
		end
		return nb
	end },
	action = function(self, t)
		local target = self
		local effs = {}

		-- Go through all temporary effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.status == "detrimental" and (e.type == "physical" or e.type == "magical" or e.type == "mental") then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, math.ceil(self:getTalentLevel(t) * 3 / 5) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			end
		end
		self:attr("allow_on_heal", 1)
		self:heal(25 + self:getCon() * 2.3)
		self:attr("allow_on_heal", -1)
		return true
	end,
	info = function(self, t)
		return ([[Call upon the will of all the Orc Prides to survive this battle.
		Heals for %d life and removes up to %d detrimental effects.
		The bonus will increase with the Constitution stat.]]):format(25 + self:getCon() * 2.3, math.ceil(self:getTalentLevel(t) * 3 / 5))
	end,
}

------------------------------------------------------------------
-- Yeeks' powers
------------------------------------------------------------------
newTalentType{ type="race/yeek", name = "yeek", generic = true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "YEEK_WILL",
	name = "Dominant Will",
	type = {"race/yeek", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 3 end,
	range = 4,
	no_npc_use = true,
	requires_target = true,
	direct_hit = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or target.dead then return end
			if not target:canBe("instakill") or target.rank > 2 or target:attr("undead") or not target:checkHit(self:getWil(20, true) + self.level * 1.5, target.level) then
				game.logSeen(target, "%s resists the mental assault!", target.name:capitalize())
				return
			end
			target:takeHit(1, self)
			target:takeHit(1, self)
			target:takeHit(1, self)
			target:setEffect(target.EFF_DOMINANT_WILL, 4 + self:getWil(10), {src=self})
		end)
		return true
	end,
	info = function(self, t)
		return ([[Shatters the mind of your victim, giving you full control over its actions for %s turns.
		When the effect ends you pull out your mind and the victim's body collapses dead.
		This effect does not work on elite or undeads.
		The duration will increase with the Willpower stat.]]):format(4 + self:getWil(10))
	end,
}

newTalent{
	name = "Unity",
	type = {"race/yeek", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:attr("confusion_immune", 0.12)
		self:attr("silence_immune", 0.12)
		self.combat_mentalresist = self.combat_mentalresist + 4
	end,
	on_unlearn = function(self, t)
		self:attr("confusion_immune", -0.12)
		self:attr("silence_immune", -0.12)
		self.combat_mentalresist = self.combat_mentalresist - 4
	end,
	info = function(self, t)
		return ([[Your mind becomes more attuned to the Way and is shielded from outside effects.
		Increase confusion and silence immunities by %d%% and your mental save by +%d.]]):format(self:getTalentLevelRaw(t) * 12, self:getTalentLevelRaw(t) * 4)
	end,
}

newTalent{
	name = "Quickened",
	type = {"race/yeek", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.global_speed_base = self.global_speed_base + 0.03
		self:recomputeGlobalSpeed()
	end,
	on_unlearn = function(self, t)
		self.global_speed_base = self.global_speed_base - 0.03
		self:recomputeGlobalSpeed()
	end,
	info = function(self, t)
		return ([[Yeeks live fast, think fast, and sacrifice fast for the Way.
		Increase global speed by %d%%.]]):format(self:getTalentLevelRaw(t) * 3)
	end,
}

newTalent{
	name = "Wayist",
	type = {"race/yeek", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 3 end,
	range = 4,
	no_npc_use = true,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		for i = 1, 3 do
			local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to summon!")
				return
			end

			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "humanoid", subtype = "yeek",
				display = "y",
				name = "yeek mindslayer", color=colors.YELLOW,
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_yeek_yeek_mindslayer.png", display_h=2, display_y=-1}}},
				desc = "A wayist that came to help.",

				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

				rank = 3,
				life_rating = 8,
				max_life = resolvers.rngavg(50,80),
				infravision = 10,

				autolevel = "none",
				ai = "summoned", ai_real = "tactical", ai_state = { talent_in=2, },
				stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
				inc_stats = { str=25 + self:getWil() * self:getTalentLevel(t) / 5, mag=10, cun=25 + self:getWil() * self:getTalentLevel(t) / 5, wil=25 + self:getWil() * self:getTalentLevel(t) / 5, dex=18, con=10 + self:getTalentLevel(t) * 2, },

				resolvers.equip{
					{type="weapon", subtype="longsword", autoreq=true},
					{type="weapon", subtype="dagger", autoreq=true},
				},

				level_range = {1, nil}, exp_worth = 0,
				silent_levelup = true,

				combat_armor = 13, combat_def = 8,
				resolvers.talents{
					[Talents.T_KINETIC_SHIELD]={base=1, every=5, max=5},
					[Talents.T_KINETIC_AURA]={base=1, every=5, max=5},
					[Talents.T_CHARGED_AURA]={base=1, every=5, max=5},
				},

				faction = self.faction,
				summoner = self, summoner_gain_exp=true,
				summon_time = 6,
				ai_target = {actor=target}
			}
			setupSummon(self, m, x, y)
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Reach through the collective psionic gestalt of the yeeks, the Way, to call for immediate help.
		Summons up to 3 yeek mindslayers to your side.]])
	end,
}

-- Yeek's power: ID
newTalent{
	short_name = "YEEK_ID",
	name = "Knowledge of the Way",
	type = {"base/race", 1},
	no_npc_use = true,
	no_unlearn_last = true,
	on_learn = function(self, t) self.auto_id = 2 end,
	action = function(self, t)
		local Chat = require("engine.Chat")
		local chat = Chat.new("elisa-orb-scrying", {name="The Way"}, self, {version="yeek"})
		chat:invoke()
		return true
	end,
	info = function(self, t)
		return ([[You merge your mind with the rest of the Way for a brief moment, the sum of all yeek knowledge gathers in your mind
		and allows you to identify any item you could not recognize yourself.]])
	end,
}
