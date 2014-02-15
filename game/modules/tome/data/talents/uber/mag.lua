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

uberTalent{
	name = "Spectral Shield",
	mode = "passive",
	require = { special={desc="Know the Block talent, have cast 100 spells, and have a block value over 200", fct=function(self)
		return self:knowTalent(self.T_BLOCK) and self:getTalentFromId(self.T_BLOCK).getBlockValue(self) >= 200 and self.talent_kind_log and self.talent_kind_log.spell and self.talent_kind_log.spell >= 100
	end} },
	on_learn = function(self, t)
		self:attr("spectral_shield", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("spectral_shield", -1)
	end,
	info = function(self, t)
		return ([[By infusing your shield with raw magic, your block can now block any damage type.]])
		:format()
	end,
}

uberTalent{
	name = "Aether Permeation",
	mode = "passive",
	require = { special={desc="Have at least 25% arcane damage reduction and have been exposed to the void of space", fct=function(self)
		return (game.state.birth.ignore_prodigies_special_reqs or self:attr("planetary_orbit")) and self:combatGetResist(DamageType.ARCANE) >= 25
	end} },
	on_learn = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "force_use_resist", DamageType.ARCANE)
		self:talentTemporaryValue(ret, "force_use_resist_percent", 66)
		return ret
	end,
	on_unlearn = function(self, t)
	end,
	info = function(self, t)
		return ([[You manifest a thin layer of aether all around you. Any attack passing through it will check arcane resistance instead of the incoming damage resistance.
		In effect, all of your resistances are equal to 66%% of your arcane resistance.]])
		:format()
	end,
}

uberTalent{
	name = "Mystical Cunning", image = "talents/vulnerability_poison.png",
	mode = "passive",
	require = { special={desc="Know either traps or poisons", fct=function(self)
		return self:knowTalent(self.T_VILE_POISONS) or self:knowTalent(self.T_TRAP_MASTERY)
	end} },
	on_learn = function(self, t)
		self:attr("combat_spellresist", 20)
		if self:knowTalent(self.T_VILE_POISONS) then self:learnTalent(self.T_VULNERABILITY_POISON, true, nil, {no_unlearn=true}) end
		if self:knowTalent(self.T_TRAP_MASTERY) then self:learnTalent(self.T_GRAVITIC_TRAP, true, nil, {no_unlearn=true}) end
	end,
	on_unlearn = function(self, t)
		self:attr("combat_spellresist", -20)
	end,
	info = function(self, t)
		return ([[Your study of arcane forces has let you develop new traps and poisons (depending on which you know when learning this prodigy).
		You can learn:
		- Vulnerability Poison: reduces all resistances and deals arcane damage.
		- Gravitic Trap: each turn, all foes in a radius 5 around it are pulled in and take temporal damage.
		You also permanently gain 20 Spell Save.]])
		:format()
	end,
}

uberTalent{
	name = "Arcane Might",
	mode = "passive",
	info = function(self, t)
		return ([[You have learned to harness your latent arcane powers, channeling them through your weapon.
		Equipped weapons are treated as having an additional 50%% Magic modifier.]])
		:format()
	end,
}

uberTalent{
	name = "Temporal Form",
	cooldown = 30,
	require = { special={desc="Have cast over 1000 spells and visited a zone outside of time", fct=function(self) return
		self.talent_kind_log and self.talent_kind_log.spell and self.talent_kind_log.spell >= 1000 and (game.state.birth.ignore_prodigies_special_reqs or self:attr("temporal_touched"))
	end} },
	no_energy = true,
	is_spell = true,
	requires_target = true,
	range = 10,
	tactical = { BUFF = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_TEMPORAL_FORM, 10, {})
		return true
	end,
	info = function(self, t)
		return ([[You can wrap temporal threads around you, assuming the form of a telugoroth for 10 turns.
		While in this form you gain pinning, bleeding, blindness and stun immunity, 30%% temporal resistance, your temporal damage bonus is set to your current highest damage bonus + 30%%, 50%% of the damage you deal becomes temporal, and you gain 20%% temporal resistance penetration.
		You also are able to cast two anomalies: Anomaly Rearrange and Anomaly Temporal Storm.
		Transforming to this form will increase your paradox by 400 but also grant the equivalent of +400 willpower to control paradoxes and failures. This reverts back at the end of the effect.]])
		:format()
	end,
}

uberTalent{
	name = "Blighted Summoning",
	mode = "passive",
	require = { special={desc="Have summoned at least 100 creatures affected by this talent. The alchemist golem counts as 100.", fct=function(self)
		return self:attr("summoned_times") and self:attr("summoned_times") >= 100
	end} },
	on_learn = function(self, t)
		local golem = self.alchemy_golem
		if not golem then return end
		golem:learnTalentType("corruption/reaving-combat", true)
		golem:learnTalent(golem.T_CORRUPTED_STRENGTH, true, 3)
	end,
	bonusTalentLevel = function(self, t) return math.ceil(3*self.level/50) end, -- Talent level for summons
	-- called by _M:addedToLevel and by _M:levelup in mod.class.Actor.lua
	doBlightedSummon = function(self, t, who)
		if not self:knowTalent(self.T_BLIGHTED_SUMMONING) then return false end
		if who.necrotic_minion then who:incIncStat("mag", self:getMag()) end
		local tlevel = self:callTalent(self.T_BLIGHTED_SUMMONING, "bonusTalentLevel")
		-- learn specified talent if present
		if who.blighted_summon_talent then 
			who:learnTalent(who.blighted_summon_talent, true, tlevel)
			if who.talents_def[who.blighted_summon_talent].mode == "sustained" then -- Activate sustained talents by default
				who:forceUseTalent(who.blighted_summon_talent, {ignore_energy=true})
			end 
		elseif who.name == "war hound" then
			who:learnTalent(who.T_CURSE_OF_DEFENSELESSNESS,true,tlevel)
		elseif who.subtype == "jelly" then
			who:learnTalent(who.T_VIMSENSE,true,tlevel)
		elseif who.subtype == "minotaur" then
			who:learnTalent(who.T_LIFE_TAP,true,tlevel)
		elseif who.name == "stone golem" then
			who:learnTalent(who.T_BONE_SPEAR,true,tlevel)
		elseif who.subtype == "ritch" then
			who:learnTalent(who.T_DRAIN,true,tlevel)
		elseif who.type =="hydra" then
			who:learnTalent(who.T_BLOOD_SPRAY,true,tlevel)
		elseif who.name == "rimebark" then
			who:learnTalent(who.T_POISON_STORM,true,tlevel)	
		elseif who.name == "treant" then
			who:learnTalent(who.T_CORROSIVE_WORM,true,tlevel)
		elseif who.name == "fire drake" then
			who:learnTalent(who.T_DARKFIRE,true,tlevel)
		elseif who.name == "turtle" then
			who:learnTalent(who.T_CURSE_OF_IMPOTENCE,true,tlevel)
		elseif who.subtype == "spider" then
			who:learnTalent(who.T_CORROSIVE_WORM,true,tlevel)
		elseif who.subtype == "skeleton" then
			who:learnTalent(who.T_BONE_GRAB,true,tlevel)
		elseif who.subtype == "giant" and who.undead then
			who:learnTalent(who.T_BONE_SHIELD,true,tlevel)
		elseif who.subtype == "ghoul" then
				who:learnTalent(who.T_BLOOD_LOCK,true,tlevel)
		elseif who.subtype == "vampire" or who.subtype == "lich" then
			who:learnTalent(who.T_DARKFIRE,true,tlevel)
		elseif who.subtype == "ghost" or who.subtype == "wight" then
			who:learnTalent(who.T_BLOOD_BOIL,true,tlevel)
		elseif who.subtype == "shadow" then
			local tl = who:getTalentLevelRaw(who.T_EMPATHIC_HEX)
			tl = tlevel-tl
			if tl > 0 then who:learnTalent(who.T_EMPATHIC_HEX, true, tl) end		
		elseif who.type == "thought-form" then
			who:learnTalent(who.T_FLAME_OF_URH_ROK,true,tlevel)
		elseif who.subtype == "yeek" then
			who:learnTalent(who.T_DARK_PORTAL, true, tlevel)
		elseif who.name == "bloated ooze" then
			who:learnTalent(who.T_BONE_SHIELD,true,math.ceil(tlevel*2/3))
		elseif who.name == "mucus ooze" then
			who:learnTalent(who.T_VIRULENT_DISEASE,true,tlevel)
		else
--			print("Error: attempting to apply talent Blighted Summoning to incorrect creature type")
			return false
		end
		return true
	end,
	info = function(self, t)
		local tl = t.bonusTalentLevel(self, t)
		return ([[You infuse blighted energies into all of your summons, granting them a new talent (at talent level %d):
		- War Hound: Curse of Defenselessness
		- Jelly: Vimsense
		- Minotaur: Life Tap
		- Golem: Bone Spear
		- Alchemy Golems: Corrupted Strength (level 3) and the Reaving Combat tree
		- Ritch: Drain
		- Hydra: Blood Spray
		- Rimebark: Poison Storm
		- Fire Drake: Darkfire
		- Turtle: Curse of Impotence
		- Spider: Corrosive Worm
		- Skeletons: Bone Grab or Bone Spear
		- Bone Giants: Bone Shield
		- Ghouls: Blood Lock
		- Ghoul Rot ghoul: Rend
		- Vampires / Liches: Darkfire
		- Ghosts / Wights: Blood Boil
		- Shadows: Empathic Hex
		- Thought-Forms: Flame of Urh'Rok
		- Treants: Corrosive Worm
		- Yeek Wayists: Dark Portal
		- Bloated Oozes: Bone Shield (level %d)
		- Mucus Oozes: Virulent Disease
		Your necrotic minions and wild-summons get a bonus to Magic equal to yours.
		The talent levels increase with your level, and other race- or object-based summons may also be affected.
		]]):format(tl,math.ceil(tl*2/3))
	end,
-- Note: Choker of Dread Vampire, and Mummified Egg-sac of Ungolë spiders handled by default
-- Crystal Shard summons use specified talent
}

uberTalent{
	name = "Revisionist History",
	cooldown = 30,
	no_energy = true,
	is_spell = true,
	no_npc_use = true,
	require = { special={desc="Have time-travelled at least once", fct=function(self) return game.state.birth.ignore_prodigies_special_reqs or (self:attr("time_travel_times") and self:attr("time_travel_times") >= 1) end} },
	action = function(self, t)
		if game._chronoworlds and game._chronoworlds.revisionist_history then
			self:hasEffect(self.EFF_REVISIONIST_HISTORY).back_in_time = true
			self:removeEffect(self.EFF_REVISIONIST_HISTORY)
			return nil -- the effect removal starts the cooldown
		end

		if checkTimeline(self) == true then return end

		game:onTickEnd(function()
			game:chronoClone("revisionist_history")
			self:setEffect(self.EFF_REVISIONIST_HISTORY, 19, {})
		end)
		return nil -- We do not start the cooldown!
	end,
	info = function(self, t)
		return ([[You can now control the recent past. Upon using this prodigy you gain a temporal effect for 20 turns.
		While this effect holds you can use the prodigy again to rewrite history.
		This prodigy splits the timeline. Attempting to use another spell that also splits the timeline while this effect is active will be unsuccessful.]])
		:format()
	end,
}
newTalent{
	name = "Unfold History", short_name = "REVISIONIST_HISTORY_BACK",
	type = {"uber/other",1},
	cooldown = 30,
	no_energy = true,
	is_spell = true,
	no_npc_use = true,
	action = function(self, t)
		if game._chronoworlds and game._chronoworlds.revisionist_history then
			self:hasEffect(self.EFF_REVISIONIST_HISTORY).back_in_time = true
			self:removeEffect(self.EFF_REVISIONIST_HISTORY)
			return nil -- the effect removal starts the cooldown
		end
		return nil -- We do not start the cooldown!
	end,
	info = function(self, t)
		return ([[Rewrite the recent past to go back to when you cast Revisionist History.]])
		:format()
	end,
}

uberTalent{
	name = "Cauterize",
	mode = "passive",
	cooldown = 12,
	require = { special={desc="Have received at least 7500 fire damage and have cast at least 1000 spells", fct=function(self) return
		self.talent_kind_log and self.talent_kind_log.spell and self.talent_kind_log.spell >= 1000 and self.damage_intake_log and self.damage_intake_log[DamageType.FIRE] and self.damage_intake_log[DamageType.FIRE] >= 7500
	end} },
	trigger = function(self, t, value)
		self:startTalentCooldown(t)

		if self.player then world:gainAchievement("AVOID_DEATH", self) end
		self:setEffect(self.EFF_CAUTERIZE, 8, {dam=value/10})
		return true
	end,
	info = function(self, t)
		return ([[Your inner flame is strong. Each time that you receive a blow that would kill you, your body is wreathed in flames.
		The flames will cauterize the wound, fully absorbing all damage done this turn, but they will continue to burn for 8 turns.
		Each turn 10% of the damage absorbed will be dealt by the flames. This will bypass resistance and affinity.
		Warning: this has a cooldown.]])
	end,
}
