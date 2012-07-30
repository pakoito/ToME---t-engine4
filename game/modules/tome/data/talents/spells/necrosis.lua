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

newTalent{
	name = "Blurred Mortality",
	type = {"spell/necrosis",1},
	require = spells_req1,
	mode = "sustained",
	points = 5,
	sustain_mana = 30,
	cooldown = 30,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		local ret = {
			die_at = self:addTemporaryValue("die_at", -50 * self:getTalentLevelRaw(t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("die_at", p.die_at)
		return true
	end,
	info = function(self, t)
		return ([[The line between life and death blurs for you; you can only die when you reach -%d life.
		However, when below 0 you cannot see how much life you have left.]]):
		format(50 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Impending Doom",
	type = {"spell/necrosis",2},
	require = spells_req2,
	points = 5,
	mana = 70,
	cooldown = 30,
	tactical = { ATTACK = { ARCANE = 3 }, DISABLE = 2 },
	range = 7,
	requires_target = true,
	getMax = function(self, t) return 200 + self:combatTalentSpellDamage(t, 28, 850) end,
	getDamage = function(self, t) return 50 + self:combatTalentSpellDamage(t, 10, 100) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			local dam = target.life * t.getDamage(self, t) / 100
			dam = math.min(dam, t.getMax(self, t))
			target:setEffect(target.EFF_IMPENDING_DOOM, 10, {dam=dam/10, src=self})
		end, 1, {type="freeze"})
		return true
	end,
	info = function(self, t)
		return ([[Your target's doom draws near. It cannot regenerate or heal at all and will take %d%% of its remaining life (or %0.2f, whichever is lower) over 10 turns as arcane damage.
		The damage will increase with your Spellpower.]]):
		format(t.getDamage(self, t), t.getMax(self, t))
	end,
}

newTalent{
	name = "Undeath Link",
	type = {"spell/necrosis",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 35,
	cooldown = 20,
	tactical = { HEAL = 2 },
	is_heal = true,
	getHeal = function(self, t) return 20 + self:combatTalentSpellDamage(t, 10, 70) end,
	on_pre_use = function(self, t)
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.necrotic_minion then
					return true
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.necrotic_minion then
					return true
				end
			end
		end
		return false
	end,
	action = function(self, t)
		local heal = t.getHeal(self, t)
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.necrotic_minion then
					act:takeHit(act.max_life * heal / 100, self)
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.necrotic_minion then
					act:takeHit(act.max_life * heal / 100, self)
				end
			end
		end
		self:attr("allow_on_heal", 1)
		self:heal(self.max_life * heal / 100)
		self:attr("allow_on_heal", -1)
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[Absorb %d%% of all your minions' life (possibly destroying them) and use this energy to heal you for %d%% of your total life.
		The healing will increase with your Spellpower.]]):
		format(heal, heal)
	end,
}

newTalent{
	name = "Lichform",
	type = {"spell/necrosis",4},
	require = {
		stat = { mag=function(level) return 40 + (level-1) * 2 end },
		level = function(level) return 20 + (level-1)  end,
		special = { desc="'From Death, Life' quest completed", fct=function(self, t) return self:isQuestStatus("lichform", engine.Quest.DONE) end},
	},
	mode = "sustained",
	points = 5,
	sustain_mana = 150,
	cooldown = 30,
	no_unlearn_last = true,
	no_npc_use = true,
	becomeLich = function(self, t)
		self.descriptor.race = "Undead"
		self.descriptor.subrace = "Lich"
		self.moddable_tile = "skeleton"
		self.moddable_tile_nude = true
		self.moddable_tile_base = "base_lich_01.png"
		self.moddable_tile_ornament = nil
		self.blood_color = colors.GREY
		self:attr("poison_immune", 1)
		self:attr("disease_immune", 0.5)
		self:attr("stun_immune", 0.5)
		self:attr("cut_immune", 1)
		self:attr("fear_immune", 1)
		self:attr("no_breath", 1)
		self:attr("undead", 1)
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 20
		self.resists[DamageType.DARKNESS] = (self.resists[DamageType.DARKNESS] or 0) + 20
		self.inscription_restrictions = self.inscription_restrictions or {}
		self.inscription_restrictions["inscriptions/runes"] = true
		self.inscription_restrictions["inscriptions/taints"] = true

		local level = self:getTalentLevel(t)
		if level < 2 then
			self:incIncStat("mag", -3) self:incIncStat("wil", -3)
			self.resists.all = (self.resists.all or 0) - 10
		elseif level < 3 then
			-- nothing
		elseif level < 4 then
			self:incIncStat("mag", 3) self:incIncStat("wil", 3)
			self.life_rating = self.life_rating + 1
		elseif level < 5 then
			self:incIncStat("mag", 3) self:incIncStat("wil", 3)
			self:attr("combat_spellresist", 10) self:attr("combat_mentalresist", 10)
			self.life_rating = self.life_rating + 2
			self:learnTalentType("celestial/star-fury", true)
			self:setTalentTypeMastery("celestial/star-fury", 0.7)
			self.negative_regen = self.negative_regen + 0.2 + 0.1
		elseif level < 6 then
			self:incIncStat("mag", 5) self:incIncStat("wil", 5)
			self:attr("combat_spellresist", 10) self:attr("combat_mentalresist", 10)
			self.resists_cap.all = (self.resists_cap.all or 0) + 10
			self.life_rating = self.life_rating + 2
			self:learnTalentType("celestial/star-fury", true)
			self:setTalentTypeMastery("celestial/star-fury", 0.9)
			self.negative_regen = self.negative_regen + 0.2 + 0.5
		else
			self:incIncStat("mag", 6) self:incIncStat("wil", 6) self:incIncStat("cun", 6)
			self:attr("combat_spellresist", 15) self:attr("combat_mentalresist", 15)
			self.resists_cap.all = (self.resists_cap.all or 0) + 15
			self.life_rating = self.life_rating + 3
			self:learnTalentType("celestial/star-fury", true)
			self:setTalentTypeMastery("celestial/star-fury", 1.1)
			self.negative_regen = self.negative_regen + 0.2 + 1
		end

		if self:attr("blood_life") then
			self.blood_life = nil
			game.log("#GREY#As you turn into a powerful undead you feel your body violently rejecting the Blood of Life.")
		end

		require("engine.ui.Dialog"):simplePopup("Lichform", "#GREY#You feel your life slip away, only to be replaced by pure arcane forces! Your flesh starts to rot on your bones, and your eyes fall apart as you are reborn into a Lich!")

		game.level.map:particleEmitter(self.x, self.y, 1, "demon_teleport")
	end,
	on_pre_use = function(self, t)
		if self:attr("undead") then return false else return true end
	end,
	activate = function(self, t)
		local ret = {
			mana = self:addTemporaryValue("mana_regen", -4),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("mana_regen", p.mana)
		return true
	end,
	info = function(self, t)
		return ([[Your true goal. The purpose of all necromancy, to become a powerful and everliving Lich!
		If you are killed while this spell is active the arcane forces you unleash will be able to rebuild your body into Lichform.
		All liches gain the following intrinsics:
		- Poison, cut, fear immunity
		- Disease resistance 50%%
		- Stun resistance 50%%
		- Cold and darkness resistance 20%%
		- No need to breathe
		- Infusions do not work
		Also:
		At level 1: -3 to all stats, -10%% to all resistances. Such meagre devotion!
		At level 2: Nothing
		At level 3: +3 Magic and Willpower, +1 life rating (not retroactive)
		At level 4: +3 Magic and Willpower, +2 life rating (not retroactive), +10 spell and mental saves, Celestial/Star Fury category (0.7) and 0.1 negative energies regeneration
		At level 5: +5 Magic and Willpower, +2 life rating (not retroactive), +10 spell and mental saves, all resistance caps raised by 10%%, Celestial/Star Fury category (0.9) and 0.5 negative energies regeneration
		At level 6: +6 Magic, Willpower and Cunning, +3 life rating (not retroactive), +15 spell and mental saves, all resistance caps raised by 15%%, Celestial/Star Fury category (1.1) and 1.0 negative energies regeneration. Fear my power!
		The undead cannot use this talent.
		While active it will drain 4 mana per turn.]]):
		format()
	end,
}
