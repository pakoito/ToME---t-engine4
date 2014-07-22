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
	name = "Fast As Lightning",
	mode = "passive",
	trigger = function(self, t, ox, oy)
		local dx, dy = (self.x - ox), (self.y - oy)
		if dx ~= 0 then dx = dx / math.abs(dx) end
		if dy ~= 0 then dy = dy / math.abs(dy) end
		local dir = util.coordToDir(dx, dy, 0)

		local eff = self:hasEffect(self.EFF_FAST_AS_LIGHTNING)
		if eff and eff.blink then
			if eff.dir ~= dir then
				self:removeEffect(self.EFF_FAST_AS_LIGHTNING)
			else
				return
			end
		end

		self:setEffect(self.EFF_FAST_AS_LIGHTNING, 1, {})
		eff = self:hasEffect(self.EFF_FAST_AS_LIGHTNING)

		if not eff.dir then eff.dir = dir eff.nb = 0 end

		if eff.dir ~= dir then
			self:removeEffect(self.EFF_FAST_AS_LIGHTNING)
			self:setEffect(self.EFF_FAST_AS_LIGHTNING, 1, {})
			eff = self:hasEffect(self.EFF_FAST_AS_LIGHTNING)
			eff.dir = dir eff.nb = 0
			game.logSeen(self, "#LIGHT_BLUE#%s slows from critical velocity!", self.name:capitalize())
		end

		eff.nb = eff.nb + 1

		if eff.nb >= 3 and not eff.blink then
			self:effectTemporaryValue(eff, "prob_travel", 5)
			game.logSeen(self, "#LIGHT_BLUE#%s reaches critical velocity!", self.name:capitalize())
			local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
			game.flyers:add(sx, sy, 30, rng.float(-3, -2), (rng.range(0,2)-1) * 0.5, "CRITICAL VELOCITY!", {0,128,255})
			eff.particle = self:addParticles(Particles.new("megaspeed", 1, {angle=util.dirToAngle((dir == 4 and 6) or (dir == 6 and 4 or dir))}))
			eff.blink = true
			game:playSoundNear(self, "talents/thunderstorm")
		end
	end,
	info = function(self, t)
		return ([[When moving over 800%% speed for at least 3 turns in the same direction, you become so fast you can blink through obstacles as if they were not there.
		Changing direction will break the effect.]])
		:format()
	end,
}

uberTalent{
	name = "Tricky Defenses",
	mode = "passive",
	require = { special={desc="Antimagic", fct=function(self) return self:knowTalentType("wild-gift/antimagic") end} },
	-- called by getMax function in Antimagic shield talent definition mod.data.talents.gifts.antimagic.lua
	shieldmult = function(self) return self:combatStatScale("cun", 0.1, 0.5) end,
	info = function(self, t)
		return ([[You are full of tricks and surprises; your Antimagic Shield can absorb %d%% more damage.
		The increase scales with your Cunning.]])
		:format(t.shieldmult(self)*100)
	end,
}

uberTalent{
	name = "Endless Woes",
	mode = "passive",
	require = { special={desc="Have dealt over 50000 acid, blight, darkness, mind or temporal damage", fct=function(self) return 
		self.damage_log and (
			(self.damage_log[DamageType.ACID] and self.damage_log[DamageType.ACID] >= 50000) or
			(self.damage_log[DamageType.BLIGHT] and self.damage_log[DamageType.BLIGHT] >= 50000) or
			(self.damage_log[DamageType.DARKNESS] and self.damage_log[DamageType.DARKNESS] >= 50000) or
			(self.damage_log[DamageType.MIND] and self.damage_log[DamageType.MIND] >= 50000) or
			(self.damage_log[DamageType.TEMPORAL] and self.damage_log[DamageType.TEMPORAL] >= 50000)
		)
	end} },
	cunmult = function(self) return self:combatStatScale("cun", 0.15, 1) end,
	trigger = function(self, t, target, damtype, dam)
		if dam < 150 then return end
		if damtype == DamageType.ACID and rng.percent(20) then
			target:setEffect(target.EFF_ACID_SPLASH, 5, {src=self, dam=(dam * t.cunmult(self) / 2.5) / 5, atk=self:getCun() / 2, apply_power=math.max(self:combatSpellpower(), self:combatMindpower())})
		elseif damtype == DamageType.BLIGHT and target:canBe("disease") and rng.percent(20) then
			local diseases = {{self.EFF_WEAKNESS_DISEASE, "str"}, {self.EFF_ROTTING_DISEASE, "con"}, {self.EFF_DECREPITUDE_DISEASE, "dex"}}
			local disease = rng.table(diseases)
			target:setEffect(disease[1], 5, {src=self, dam=(dam * t.cunmult(self)/ 2.5) / 5, [disease[2]]=self:getCun() / 3, apply_power=math.max(self:combatSpellpower(), self:combatMindpower())})
		elseif damtype == DamageType.DARKNESS and target:canBe("blind") and rng.percent(20) then
			target:setEffect(target.EFF_BLINDED, 5, {apply_power=math.max(self:combatSpellpower(), self:combatMindpower())})
		elseif damtype == DamageType.TEMPORAL and target:canBe("slow") and rng.percent(20) then
			target:setEffect(target.EFF_SLOW, 5, {apply_power=math.max(self:combatSpellpower(), self:combatMindpower()), power=0.3})
		elseif damtype == DamageType.MIND and target:canBe("confusion") and rng.percent(20) then
			target:setEffect(target.EFF_CONFUSED, 5, {apply_power=math.max(self:combatSpellpower(), self:combatMindpower()), power=20})
		end
	end,
	info = function(self, t)
		return ([[Surround yourself with a malevolent aura.
		Any acid damage you do has a 20%% chance to apply a lasting acid that deals %d%% of the initial damage for 5 turns and reduces accuracy by %d.
		Any blight damage you do has a 20%% chance to cause a random disease that deals %d%% of the initial damage for 5 turns and reduces a stat by %d.
		Any darkness damage you do has a 20%% chance to blind the target for 5 turns.
		Any temporal damage you do has a 20%% chance to slow (30%%) the target for 5 turns.
		Any mind damage you do has a 20%% chance to confuse (20%%) the target for 5 turns.
		This only triggers for hits over 150 damage.
		The damage values increase with your Cunning.]])
		:format(100*t.cunmult(self) / 2.5, self:getCun() / 2, 100*t.cunmult(self) / 2.5, self:getCun() / 3)
	end,
}

uberTalent{
	name = "Secrets of Telos",
	mode = "passive",
	require = { special={desc="Possess Telos Top Half, Telos Bottom Half, and Telos Staff Crystal", fct=function(self)
		local o1 = self:findInAllInventoriesBy("define_as", "GEM_TELOS")
		local o2 = self:findInAllInventoriesBy("define_as", "TELOS_TOP_HALF")
		local o3 = self:findInAllInventoriesBy("define_as", "TELOS_BOTTOM_HALF")
		return o1 and o2 and o3
	end} },
	on_learn = function(self, t)
		local list = mod.class.Object:loadList("/data/general/objects/special-artifacts.lua")
		local o = game.zone:makeEntityByName(game.level, list, "TELOS_SPIRE", true)
		if o then
			o:identify(true)
			self:addObject(self.INVEN_INVEN, o)

			local o1, item1, inven1 = self:findInAllInventoriesBy("define_as", "GEM_TELOS")
			self:removeObject(inven1, item1, true)
			local o2, item2, inven2 = self:findInAllInventoriesBy("define_as", "TELOS_TOP_HALF")
			self:removeObject(inven2, item2, true)
			local o3, item3, inven3 = self:findInAllInventoriesBy("define_as", "TELOS_BOTTOM_HALF")
			self:removeObject(inven3, item3, true)

			self:sortInven()

			game.logSeen(self, "#VIOLET#%s assembles %s!", self.name:capitalize(), o:getName{do_colour=true, no_count=true})
		end
	end,
	info = function(self, t)
		return ([[You have obtained the three parts of the Staff of Telos and studied them carefully. You believe that you can merge them back into a single highly potent staff.]])
		:format()
	end,
}

uberTalent{
	name = "Elemental Surge",
	mode = "passive",
	cooldown = 12,
	require = { special={desc="Have dealt over 50000 arcane, fire, cold, lightning, light or nature damage", fct=function(self) return 
		self.damage_log and (
			(self.damage_log[DamageType.ARCANE] and self.damage_log[DamageType.ARCANE] >= 50000) or
			(self.damage_log[DamageType.FIRE] and self.damage_log[DamageType.FIRE] >= 50000) or
			(self.damage_log[DamageType.COLD] and self.damage_log[DamageType.COLD] >= 50000) or
			(self.damage_log[DamageType.LIGHTNING] and self.damage_log[DamageType.LIGHTNING] >= 50000) or
			(self.damage_log[DamageType.LIGHT] and self.damage_log[DamageType.LIGHT] >= 50000) or
			(self.damage_log[DamageType.NATURE] and self.damage_log[DamageType.NATURE] >= 50000)
		)
	end} },
	getThreshold = function(self, t) return 4*self.level end,
	getColdEffects = function(self, t)
		return {physresist = 30,
		armor = self:combatStatScale("cun", 20, 50, 0.75),
		dam = math.max(100, self:getCun()),
		}
	end,
	getShield = function(self, t) return 100 + 2*self:getCun() end,
	-- triggered in default projector in mod.data.damage_types.lua
	trigger = function(self, t, target, damtype, dam)
		if dam < t.getThreshold(self, t) then return end
		
		local ok = false
		if damtype == DamageType.ARCANE and rng.percent(30) then ok=true self:setEffect(self.EFF_ELEMENTAL_SURGE_ARCANE, 5, {})
		elseif damtype == DamageType.FIRE and rng.percent(30) then ok=true self:removeEffectsFilter{type="magical", status="detrimental"} self:removeEffectsFilter{type="physical", status="detrimental"} game.logSeen(self, "#CRIMSON#%s fiery attack invokes a cleansing flame!", self.name:capitalize())
		elseif damtype == DamageType.COLD and rng.percent(30) then
			-- EFF_ELEMENTAL_SURGE_COLD in mod.data.timed_effect.magical.lua holds the parameters
			ok=true self:setEffect(self.EFF_ELEMENTAL_SURGE_COLD, 5, t.getColdEffects(self, t))
		elseif damtype == DamageType.LIGHTNING and rng.percent(30) then ok=true self:setEffect(self.EFF_ELEMENTAL_SURGE_LIGHTNING, 5, {})
		elseif damtype == DamageType.LIGHT and rng.percent(30) and not self:hasEffect(self.EFF_DAMAGE_SHIELD) then
			ok=true
			self:setEffect(self.EFF_DAMAGE_SHIELD, 5, {power=t.getShield(self, t)})
		elseif damtype == DamageType.NATURE and rng.percent(30) then ok=true self:setEffect(self.EFF_ELEMENTAL_SURGE_NATURE, 5, {})
		end

		if ok then self:startTalentCooldown(t) end
	end,
	info = function(self, t)
		local cold = t.getColdEffects(self, t)
		return ([[Surround yourself with an elemental aura. When you deal a critical hit with an element, you have a chance to trigger a special effect.
		Arcane damage has a 30%% chance to increase your spellcasting speed by 20%% for 5 turns.
		Fire damage has a 30%% chance to cleanse all physical or magical detrimental effects on you.
		Cold damage has a 30%% chance to turn your skin into ice for 5 turns, reducing physical damage taken by %d%%, increasing armor by %d, and dealing %d ice damage to attackers.
		Lightning damage has a 30%% chance to transform you into pure lightning for 5 turns; any damage will teleport you to an adjacent tile and ignore the damage (can only happen once per turn).
		Light damage has a 30%% chance to create a barrier around you, absorbing %d damage for 5 turns.
		Nature damage has a 30%% chance to harden your skin, preventing the application of any magical detrimental effects for 5 turns.
		The Cold and Light effects scale with your Cunning.
		These effects only trigger for hits over %d damage (based on your level).]])
		:format(cold.physresist, cold.armor, cold.dam, t.getShield(self, t), t.getThreshold(self, t))
	end,
}

uberTalent{
	name = "Eye of the Tiger",
	mode = "passive",
	trigger = function(self, t, kind)
		if self.turn_procs.eye_tiger then return end

		local tids = {}

		for tid, _ in pairs(self.talents_cd) do
			local t = self:getTalentFromId(tid)
			if not t.fixed_cooldown then
				if
					(kind == "physical" and
						(
							t.type[1]:find("^technique/") or
							t.type[1]:find("^cunning/")
						)
					) or
					(kind == "spell" and
						(
							t.type[1]:find("^spell/") or
							t.type[1]:find("^corruption/") or
							t.type[1]:find("^celestial/") or
							t.type[1]:find("^chronomancy/")
						)
					) or
					(kind == "mind" and
						(
							t.type[1]:find("^wild%-gift/") or
							t.type[1]:find("^cursed/") or
							t.type[1]:find("^psionic/")
						)
					)
					then
					tids[#tids+1] = tid
				end
			end
		end
		if #tids == 0 then return end
		local tid = rng.table(tids)
		self.talents_cd[tid] = self.talents_cd[tid] - (kind == "spell" and 1 or 2)
		if self.talents_cd[tid] <= 0 then self.talents_cd[tid] = nil end
		self.changed = true
		self.turn_procs.eye_tiger = true
	end,
	info = function(self, t)
		return ([[All physical criticals reduce the remaining cooldown of a random technique or cunning talent by 2.
		All spell criticals reduce the remaining cooldown of a random spell talent by 1.
		All mind criticals reduce the remaining cooldown of a random wild gift/psionic/afflicted talent by 2.
		This can only happen once per turn, and cannot affect the talent that triggers it.]])
		:format()
	end,
}

uberTalent{
	name = "Worldly Knowledge",
	mode = "passive",
	on_learn = function(self, t, kind)
		local Chat = require "engine.Chat"
		local chat = Chat.new("worldly-knowledge", {name="Worldly Knowledge"}, self)
		chat:invoke()
	end,
	info = function(self, t)
		return ([[Learn a new talent category from one of the below at 0.9 mastery, unlocked. Group 1 categories are available to anyone; Group 2 are available only to people without any spells or runes, and Group 3 are not available to followers of Zigur.
		GROUP 1:
		- Technique / Conditioning
		- Cunning / Survival
		GROUP 2:
		- Technique / Mobility
		- Technique / Field Control
		- Wild Gift / Call of the Wild
		- Wild Gift / Mindstar Mastery
		- Psionic / Dreaming
		GROUP 3:
		- Spell / Divination
		- Spell / Staff Combat
		- Spell / Stone Alchemy
		- Celestial / Chants
		- Celestial / Light
		- Chronomancy / Chronomancy]])
		:format()
	end,
}

uberTalent{
	name = "Tricks of the Trade",
	mode = "passive",
	require = { special={desc="Have sided with the Assassin Lord", fct=function(self) return game.state.birth.ignore_prodigies_special_reqs or (self:isQuestStatus("lost-merchant", engine.Quest.COMPLETED, "evil")) end} },
	on_learn = function(self, t) 
		if self:knowTalentType("cunning/stealth") then
			self:setTalentTypeMastery("cunning/stealth", self:getTalentTypeMastery("cunning/stealth") + 0.2)
		elseif self:knowTalentType("cunning/stealth") == false then
			self:learnTalentType("cunning/stealth", true)
		end
		if self:knowTalentType("cunning/scoundrel") then
			self:setTalentTypeMastery("cunning/scoundrel", self:getTalentTypeMastery("cunning/scoundrel") + 0.1)
		else
			self:learnTalentType("cunning/scoundrel", true)
			self:setTalentTypeMastery("cunning/scoundrel", 0.9)
		end
		self.invisible_damage_penalty_divisor = (self.invisible_damage_penalty_divisor or 0) + 2
	end,
	info = function(self, t)
		return ([[You have friends in low places and have learned some underhanded tricks.
		Gain 0.2 Category Mastery to the Cunning/Stealth Category (or unlock it, if locked), and either gain +0.1 to the Cunning/Scoundrel category or learn and unlock the category at 0.9 if you lack it.
		Additionally, all of your damage penalties from invisibility are permanently halved.]]):
		format()
	end,
}
