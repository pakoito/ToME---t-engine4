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
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 45, 25)) end, -- Limit >10
	tactical = { HEAL = 2 },
	on_pre_use = function(self, t) return not self:hasEffect(self.EFF_REGENERATION) end,
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 10, {power=5 + self:getWil() * 0.5})
		return true
	end,
	info = function(self, t)
		return ([[Call upon the gift of the highborn to regenerate your body for %d life every turn for 10 turns.
		The life healed will increase with your Willpower.]]):format(5 + self:getWil() * 0.5)
	end,
}

newTalent{
	name = "Overseer of Nations",
	type = {"race/higher", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getSight = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getESight = function(self, t) return math.ceil(self:combatTalentScale(t, 0.3, 2.3, "log", 0, 2)) end,
	getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.1, 0.4) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "blind_immune", t.getImmune(self, t))
		self:talentTemporaryValue(p, "sight", t.getSight(self, t))
		self:talentTemporaryValue(p, "infravision", t.getESight(self, t))
		self:talentTemporaryValue(p, "heightened_senses", t.getESight(self, t))
	end,
	info = function(self, t)
		return ([[While Highers are not meant to rule other humans - and show no particular will to do so - they are frequently called to higher duties.
		Their nature grants them better senses than other humans.
		Increase blindness immunity by %d%%, maximum sight range by %d, and increases existing infravision, and heightened senses range by %d.]]):
		format(t.getImmune(self, t) * 100, t.getSight(self, t), t.getESight(self, t))
	end,
}

newTalent{
	name = "Born into Magic",
	type = {"race/higher", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 0, 19, 7)) end, -- Limit > 0
	getSave = function(self, t) return self:combatTalentScale(t, 5, 25, 0.75) end,
	power = function(self, t) return self:combatTalentScale(t, 7, 25) end,
	trigger = function(self, t, damtype)
		self:startTalentCooldown(t)
		self:setEffect(self.EFF_BORN_INTO_MAGIC, 5, {damtype=damtype})
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_spellresist", t.getSave(self, t))
		self:talentTemporaryValue(p, "resists",{[DamageType.ARCANE]=t.power(self, t)})
	end,
	info = function(self, t)
		local netpower = t.power(self, t)
		return ([[Highers were originally created during the Age of Allure by the human Conclave. They are imbued with magic at the very core of their being.
		Increase spell save by +%d and arcane resistance by %d%%.
		Also when you cast a spell dealing damage, you gain a 15%% bonus to the damage type for 5 turns. (This effect has a cooldown.)]]):
		format(t.getSave(self, t), netpower)
	end,
}

newTalent{
	name = "Highborn's Bloom",
	type = {"race/higher", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 20, 47, 35)) end, -- Limit >20
	tactical = { MANA = 2, VIM = 2, EQUILIBRIUM = 2, STAMINA = 2, POSITIVE = 2, NEGATIVE = 2, PARADOX = 2, PSI = 2 },
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 2, 6.1)) end,  --  Limit to < 10
	action = function(self, t)
		self:setEffect(self.EFF_HIGHBORN_S_BLOOM, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Activate some of your inner magic, using it to power your abilities.  For the next %d turns, all active talents will be used without resource cost.
		Your resources must still be high enough to initially power the talent, and failure rates (etc.) still apply.
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
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 46, 30)) end,  -- Limit to >10 turns
	getSpeed = function(self, t) return self:combatStatScale(math.max(self:getDex(), self:getMag()), 0.1, 0.476, 0.75) end,
	tactical = { DEFEND = 1 },
	action = function(self, t)
		self:setEffect(self.EFF_SPEED, 8, {power=t.getSpeed(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Call upon the grace of the Eternals to increase your general speed by %d%% for 8 turns.
		The speed bonus will increase with your Dexterity or Magic (whichever is higher).]]):
		format(t.getSpeed(self, t) * 100)
	end,
}

newTalent{
	name = "Magic of the Eternals",
	type = {"race/shalore", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	critChance = function(self, t) return self:combatTalentScale(t, 3, 10, 0.75) end,
	critPower = function(self, t) return self:combatTalentScale(t, 6, 25, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physcrit", t.critChance(self, t))
		self:talentTemporaryValue(p, "combat_spellcrit", t.critChance(self, t))
		self:talentTemporaryValue(p, "combat_mindcrit", t.critChance(self, t))
		self:talentTemporaryValue(p, "combat_critical_power", t.critPower(self, t))
	end,
	info = function(self, t)
		return ([[Reality bends slightly in the presence of a Shaloren, due to their inherent magical nature.
		Increases critical chance by %d%% and critical strike power by %d%%.]]):
		format(t.critChance(self, t), t.critPower(self, t))
	end,
}

newTalent{
	name = "Secrets of the Eternals",
	type = {"race/shalore", 3},
	require = racial_req3,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 47, 35)) end, -- Limit > 5
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 21, 45) end, -- Limit < 100%
	getInvis = function(self, t) return self:combatStatScale("mag" , 7, 25) end,
	mode = "sustained",
	no_energy = true,
	activate = function(self, t)
		self.invis_on_hit_disable = self.invis_on_hit_disable or {}
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			invis = self:addTemporaryValue("invis_on_hit", t.getChance(self, t)),
			power = self:addTemporaryValue("invis_on_hit_power", t.getInvis(self, t)),
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
		%d%% chance to become invisible (power %d) for 5 turns, when hit by a blow doing at least 10%% of their total life.]]):
		format(t.getChance(self, t), t.getInvis(self, t))
	end,
}

newTalent{
	name = "Timeless",
	type = {"race/shalore", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	fixed_cooldown = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 20, 47, 35)) end, -- Limit to >20
	getEffectGood = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getEffectBad = function(self, t) return math.floor(self:combatTalentScale(t, 2.9, 10.01, "log")) end,
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
					p.dur = math.min(p.dur*2, p.dur + t.getEffectGood(self, t))
				elseif e.status == "detrimental" then
					p.dur = p.dur - t.getEffectBad(self, t)
					if p.dur <= 0 then todel[#todel+1] = eff_id end
				end
			end
		end
		while #todel > 0 do
			target:removeEffect(table.remove(todel))
		end

		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and self.talents_cd[tid] and not t.fixed_cooldown then tids[#tids+1] = t end
		end
		while #tids > 0 do
			local tt = rng.tableRemove(tids)
			if not tt then break end
			self.talents_cd[tt.id] = self.talents_cd[tt.id] - t.getEffectGood(self, t)
			if self.talents_cd[tt.id] <= 0 then self.talents_cd[tt.id] = nil end
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[The world grows old as you stand through the ages. To you, time is different.
		Reduces the time remaining on detrimental effects by %d, most cooling down talents by %d, and increases the time remaining on beneficial effects by %d (up to 2 times the current duration).]]):
		format(t.getEffectBad(self, t), t.getEffectGood(self, t), t.getEffectGood(self, t))
	end,
}

------------------------------------------------------------------
-- Thaloren's powers
------------------------------------------------------------------
newTalentType{ type="race/thalore", name = "thalore", generic = true, is_nature=true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "THALOREN_WRATH",
	name = "Wrath of the Woods",
	type = {"race/thalore", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end, -- Limit > 5
	getPower = function(self, t) return self:combatStatScale("wil", 11, 20) end,
	tactical = { ATTACK = 1, DEFEND = 1 },
	action = function(self, t)
		self:setEffect(self.EFF_ETERNAL_WRATH, 5, {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Call upon the power of the Eternals, increasing all damage by %d%% and reducing all damage taken by %d%% for 5 turns.
		The bonus will increase with your Willpower.]]):
		format(t.getPower(self, t), t.getPower(self, t))
	end,
}

newTalent{
	name = "Unshackled",
	type = {"race/thalore", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getSave = function(self, t) return self:combatTalentScale(t, 6, 25, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physresist", t.getSave(self, t))
		self:talentTemporaryValue(p, "combat_mentalresist", t.getSave(self, t))
	end,
	info = function(self, t)
		return ([[Thaloren have always been a free people, living in their beloved forest and never caring much about the world outside.
		Increase Physical and Mental Save by +%d.]]):
		format(t.getSave(self, t))
	end,
}

newTalent{
	name = "Guardian of the Wood",
	type = {"race/thalore", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	getDiseaseImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.75) end, -- Limit < 100%
	getBResist = function(self, t) return self:combatTalentScale(t, 3, 10) end,
	getAllResist = function(self, t) return self:combatTalentScale(t, 2, 6.5) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "disease_immune", t.getDiseaseImmune(self, t))
		self:talentTemporaryValue(p, "resists",{[DamageType.BLIGHT]=t.getBResist(self, t)})
		self:talentTemporaryValue(p, "resists",{all=t.getAllResist(self, t)})
	end,
	info = function(self, t)
		return ([[You are part of the wood; it shields you from corruption.
		Increase disease immunity by %d%%, blight resistance by %0.1f%%, and all resistances by %0.1f%%.]]):
		format(t.getDiseaseImmune(self, t)*100, t.getBResist(self, t), t.getAllResist(self, t))
	end,
}

newTalent{
	name = "Nature's Pride",
	type = {"race/thalore", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 46, 34)) end, -- limit >8
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = { stun = 1, knockback = 1 } },
	range = 4,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		for i = 1, 2 do
			local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to summon!")
				if i == 1 then return else break end
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
				combat = { dam=resolvers.levelup(resolvers.rngavg(15,25), 1, 1.3), atk=resolvers.levelup(resolvers.rngavg(15,25), 1, 1.6), dammod={str=1.1} },
				inc_stats = {
					str=25 + self:combatScale(self:getWil() * self:getTalentLevel(t), 0, 0, 100, 500, 0.75),
					dex=18,
					con=10 + self:combatTalentScale(t, 3, 10, 0.75),
				},
				level_range = {1, nil}, exp_worth = 0,
				silent_levelup = true,

				resists = {all = self:combatGetResist(DamageType.BLIGHT)},

				combat_armor = 13, combat_def = 8,
				resolvers.talents{ [Talents.T_STUN]=self:getTalentLevelRaw(t), [Talents.T_KNOCKBACK]=self:getTalentLevelRaw(t), [Talents.T_TAUNT]=self:getTalentLevelRaw(t), },

				faction = self.faction,
				summoner = self, summoner_gain_exp=true,
				summon_time = 8,
				ai_target = {actor=target}
			}
			setupSummon(self, m, x, y)
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Nature is with you; you can always feel the call of the woods.
		Summons two elite Treants to your side for 8 turns.
		The treants have a global resistance equal to your blight resistance, and can stun, knockback and taunt your foes.
		Their power increases with your Willpower.]]):format()
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
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 45, 25)) end, -- Limit >8
	getParams = function(self, t)
		return {
			armor = self:combatStatScale("con", 7, 25),
			physical = self:combatStatScale("con", 12, 30, 0.75),
			spell = self:combatStatScale("con", 12, 30, 0.75),
		}
	end,
	tactical = { DEFEND = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_DWARVEN_RESILIENCE, 8, t.getParams(self, t))
		return true
	end,
	info = function(self, t)
		local params = t.getParams(self, t)
		return ([[Call upon the legendary resilience of the Dwarven race to increase your Armor (+%d), Spell (+%d) and Physical (+%d) saves for 8 turns.
		The bonus will increase with your Constitution.]]):
		format(params.armor, params.physical, params.spell)
	end,
}

newTalent{
	name = "Stoneskin",
	type = {"race/dwarf", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	armor = function(self, t) return self:combatTalentScale(t, 6, 30) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "auto_stoneskin", t.armor(self, t))
	end,
	info = function(self, t)
		return ([[Dwarf skin is a complex structure, it can automatically react to physical blows to harden itself.
		When you are hit in melee, you have a 15%% chance to increase your Armour total by %d for 5 turns.]]):
		format(t.armor(self, t))
	end,
}

newTalent{
	name = "Power is Money",
	type = {"race/dwarf", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	getMaxSaves = function(self, t) return self:combatTalentScale(t, 8, 35) end,
	getGold = function(self, t) return self:combatTalentLimit(t, 40, 85, 65) end, -- Limit > 40
	-- called by _M:combatPhysicalResist, _M:combatSpellResist, _M:combatMentalResist in mod.class.interface.Combat.lua
	getSaves = function(self, t)
		return util.bound(self.money / t.getGold(self, t), 0, t.getMaxSaves(self, t))
	end,
	info = function(self, t)
		return ([[Money is the heart of the Dwarven Empire; it rules over all other considerations.
		Increases Physical, Mental and Spell Saves based on the amount of gold you possess.
		+1 save every %d gold, up to +%d. (currently +%d)]]):
		format(t.getGold(self, t), t.getMaxSaves(self, t), t.getSaves(self, t))
	end,
}

newTalent{
	name = "Stone Walking",
	type = {"race/dwarf", 4},
	require = racial_req4,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end, -- Limit >5
	range = 1,
	no_npc_use = true,
	getRange = function(self, t)
		return math.max(1, math.floor(self:combatScale(0.04*self:getCon() + self:getTalentLevel(t), 2.4, 1.4, 10, 9)))
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		self:probabilityTravel(x, y, t.getRange(self, t))
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		return ([[While the origins of the dwarves remain clouded in mysteries to the other races, it is obvious they share strong ties to the stone.
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
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end, -- Limit >5
	getParams = function(self, t)
		return {
			physical = self:combatStatScale("cun", 15, 60, 0.75),
			spell = self:combatStatScale("cun", 15, 60, 0.75),
			mind = self:combatStatScale("cun", 15, 60, 0.75),
			}
	end,
	tactical = { ATTACK = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_HALFLING_LUCK, 5, t.getParams(self, t))
		return true
	end,
	info = function(self, t)
		local params = t.getParams(self, t)
		return ([[Call upon the luck and cunning of the Little Folk to increase your physical, mental, and spell critical strike chance by %d%% and your saves by %d for 5 turns.
		The bonus will increase with your Cunning.]]):
		format(params.mind, params.mind)
	end,
}

newTalent{
	name = "Duck and Dodge",
	type = {"race/halfling", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getThreshold = function(self, t) return math.max(10, (15 - self:getTalentLevelRaw(t))) / 100 end,
	getEvasionChance = function(self, t) return 50 end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 1.3, 3.3)) end,
	-- called by _M:onTakeHit function in mod.class.Actor.lua for trigger 
	getDefense = function(self) 
		local oldevasion = self:hasEffect(self.EFF_EVASION)
		return self:getStat("lck")/200*(self:combatDefenseBase() - (oldevasion and oldevasion.defense or 0)) -- Prevent stacking
	end,
	info = function(self, t)
		local threshold = t.getThreshold(self, t)
		local evasion = t.getEvasionChance(self, t)
		local duration = t.getDuration(self, t)
		return ([[Your incredible luck kicks in at just the right moment to save your skin.
		Whenever you take %d%% or more of your life from a single attack, you gain Evasion (%d%%) and %d additional defense (based on your luck and other defensive stats) for the next %d turns.]]):
		format(threshold * 100, evasion, t.getDefense(self), duration)
	end,
}

newTalent{
	name = "Militant Mind",
	type = {"race/halfling", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	info = function(self, t)
		return ([[Halflings have always been a very organised and methodical race; the more foes they face, the more organised they are.
		If two or more foes are in sight your Physical Power, Physical Save, Spellpower, Spell Save, Mental Save, and Mindpower are increased by %0.1f per foe (up to 5 foes).]]):
		format(self:getTalentLevel(t) * 1.5)
	end,
}

newTalent{
	name = "Indomitable",
	type = {"race/halfling", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 45, 25)) end, -- limit >10
	tactical = { DEFEND = 1,  CURE = 1 },
	getRemoveCount = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6, "log")) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
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
		return ([[Halflings have one of the most powerful military forces in the known world and they have been at war with most other races for thousand of years.
		Removes %d stun, daze, or pin effects, and makes you immune to stuns, dazes and pins for %d turns.
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
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 46, 30)) end, -- Limit to >5 turns
	getPower = function(self, t) return self:combatStatScale("wil", 12, 30) end,
	tactical = { ATTACK = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_ORC_FURY, 5, {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Summons your lust for blood and destruction, increasing all damage you deal by %d%% for 5 turns.
		The bonus will increase with your Willpower.]]):
		format(t.getPower(self, t))
	end,
}

newTalent{
	name = "Hold the Ground",
	type = {"race/orc", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getSaves = function(self, t) return self:combatTalentScale(t, 6, 25, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physresist", t.getSaves(self, t))
		self:talentTemporaryValue(p, "combat_mentalresist", t.getSaves(self, t))
	end,
	info = function(self, t)
		return ([[Orcs have been the prey of the other races for thousands of years, with or without justification. They have learnt to withstand things that would break weaker races.
		Increase physical and mental save by +%d.]]):
		format(t.getSaves(self, t))
	end,
}

newTalent{
	name = "Skirmisher",
	type = {"race/orc", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	getPen = function(self, t) return self:combatTalentLimit(t, 20, 7, 15) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "resists_pen", {all = t.getPen(self, t)})
	end,
	info = function(self, t)
		return ([[Orcs have seen countless battles, and won many of them.
		Increase all damage penetration by %d%%.]]):
		format(t.getPen(self, t))
	end,
}

newTalent{
	name = "Pride of the Orcs",
	type = {"race/orc", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 46, 30)) end, -- Limit to >10
	remcount  = function(self,t) return math.ceil(self:combatTalentScale(t, 0.5, 3, "log", 0, 3)) end,
	heal = function(self, t) return 25 + 2.3* self:getCon() + self:combatTalentLimit(t, 0.1, 0.01, 0.05)*self.max_life end,
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

		for i = 1, t.remcount(self,t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			end
		end
		self:attr("allow_on_heal", 1)
		self:heal(t.heal(self, t), t)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
		end
		self:attr("allow_on_heal", -1)
		return true
	end,
	info = function(self, t)
		return ([[Call upon the will of all of the Orc Prides to survive this battle.
		You heal for %d life, and remove up to %d detrimental effects.
		The healing will increase with your Constitution.]]):
		format(t.heal(self, t), t.remcount(self,t))
	end,
}

------------------------------------------------------------------
-- Yeeks' powers
------------------------------------------------------------------
newTalentType{ type="race/yeek", name = "yeek", is_mind=true, generic = true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "YEEK_WILL",
	name = "Dominant Will",
	type = {"race/yeek", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 47, 35)) end, -- Limit >10
	getduration = function(self) return math.floor(self:combatStatScale("wil", 5, 14)) end,
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
			if not target or target.dead or target == self then return end
			if not target:canBe("instakill") or target.rank > 3 or target:attr("undead") or game.party:hasMember(target) or not target:checkHit(self:getWil(20, true) + self.level * 1.5, target.level) then
				game.logSeen(target, "%s resists the mental assault!", target.name:capitalize())
				return
			end
			target:takeHit(1, self)
			target:takeHit(1, self)
			target:takeHit(1, self)
			target:setEffect(target.EFF_DOMINANT_WILL, t.getduration(self), {src=self})
		end)
		return true
	end,
	info = function(self, t)
		return ([[Shatters the mind of your victim, giving you full control over its actions for %s turns.
		When the effect ends, you pull out your mind and the victim's body collapses, dead.
		This effect does not work on rares, bosses, or undeads.
		The duration will increase with your Willpower.]]):format(t.getduration(self))
	end,
}

newTalent{
	name = "Unity",
	type = {"race/yeek", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.17, 0.6) end, -- Limit < 100%
	getSave = function(self, t) return self:combatTalentScale(t, 5, 20, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "confusion_immune", t.getImmune(self, t))
		self:talentTemporaryValue(p, "silence_immune", t.getImmune(self, t))
		self:talentTemporaryValue(p, "combat_mentalresist", t.getSave(self, t))
	end,
	info = function(self, t)
		return ([[Your mind becomes more attuned to the Way, and is shielded from outside effects.
		Increase confusion and silence immunities by %d%%, and your Mental Save by +%d.]]):
		format(100*t.getImmune(self, t), t.getSave(self, t))
	end,
}

newTalent{
	name = "Quickened",
	type = {"race/yeek", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	speedup = function(self, t) return self:combatTalentScale(t, 0.04, 0.15, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "global_speed_base", t.speedup(self, t))
		self:recomputeGlobalSpeed()
	end,
	info = function(self, t)
		return ([[Yeeks live fast, think fast, and sacrifice fast for the Way.
		Increase global speed by %0.1f%%.]]):format(100*t.speedup(self, t))
	end,
}

newTalent{
	name = "Wayist",
	type = {"race/yeek", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 6, 47, 35)) end, -- Limit >6
	range = 4,
	no_npc_use = true,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
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
				inc_stats = {
					str=self:combatScale(self:getWil() * self:getTalentLevel(t), 25, 0, 125, 500, 0.75),
					mag=10,
					cun=self:combatScale(self:getWil() * self:getTalentLevel(t), 25, 0, 125, 500, 0.75),
					wil=self:combatScale(self:getWil() * self:getTalentLevel(t), 25, 0, 125, 500, 0.75),
					dex=18,
					con=10 + self:combatTalentScale(t, 2, 10, 0.75),
				},
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
		Summons up to 3 yeek mindslayers to your side for 6 turns.]])
	end,
}

-- Yeek's power: ID
newTalent{
	short_name = "YEEK_ID",
	name = "Knowledge of the Way",
	type = {"base/race", 1},
	no_npc_use = true,
	no_unlearn_last = true,
	mode = "passive",
	on_learn = function(self, t) self.auto_id = 100 end,
	info = function(self, t)
		return ([[You merge your mind with the rest of the Way for a brief moment; the sum of all yeek knowledge gathers in your mind,
		and allows you to identify any item you could not recognize yourself.]])
	end,
}
