-- ToME - Tales of Maj'Eyal
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

-- Generic requires for racial based on talent level
racial_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
racial_req2 = {
	level = function(level) return 4 + (level-1)  end,
}
racial_req3 = {
	level = function(level) return 8 + (level-1)  end,
}
racial_req4 = {
	level = function(level) return 12 + (level-1)  end,
}

------------------------------------------------------------------
-- Highers's powers
------------------------------------------------------------------
newTalentType{ type="race/higher", name = "higher", generic = true, description = "The various racial bonuses a character can have." }

newTalent{
	short_name = "HIGHER_HEAL",
	name = "Gift of the Pureborn",
	type = {"race/higher", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	tactical = { HEAL = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 10, {power=5 + self:getWil() * 0.5})
		return true
	end,
	info = function(self)
		return ([[Call upon the gift of the pureborn to regenerate your body for %d life every turn for 10 turns.
		The life healed will increase with the Willpower stat]]):format(5 + self:getWil() * 0.6)
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
	end,
	on_unlearn = function(self, t)
		self.sight = self.sight - 1
	end,
	info = function(self)
		return ([[]]):format(5 + self:getWil() * 0.6)
	end,
}

------------------------------------------------------------------
-- Shaloren's powers
------------------------------------------------------------------
newTalentType{ type="race/shalore", name = "shalore", generic = true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "SHALOREN_SPEED",
	name = "Grace of the Eternals",
	type = {"race/shalore", 1},
	no_energy = true,
	cooldown = 50,
	tactical = { DEFEND = 1 },
	action = function(self, t)
		local power = 0.1 + self:getDex() / 210
		self:setEffect(self.EFF_SPEED, 8, {power=1 - 1 / (1 + power)})
		return true
	end,
	info = function(self)
		return ([[Call upon the grace of the Eternals to increase your general speed by %d%% for 8 turns.
		The speed bonus will increase with the Dexterity stat]]):format((0.1 + self:getDex() / 210) * 100)
	end,
}

------------------------------------------------------------------
-- Dwarvess powers
------------------------------------------------------------------
newTalentType{ type="race/dwarf", name = "dwarf", generic = true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "DWARF_RESILIENCE",
	name = "Resilience of the Dwarves",
	type = {"race/dwarf", 1},
	no_energy = true,
	cooldown = 50,
	tactical = { DEFEND = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_DWARVEN_RESILIENCE, 8, {
			armor=5 + self:getCon() / 5,
			physical=10 + self:getCon() / 5,
			spell=10 + self:getCon() / 5,
		})
		return true
	end,
	info = function(self)
		return ([[Call upon the legendary resilience of the Dwarven race to increase your armor(+%d), spell(+%d) and physical(+%d) saves for 8 turns.
		The bonus will increase with the Constitution stat]]):format(5 + self:getCon() / 5, 10 + self:getCon() / 5, 10 + self:getCon() / 5)
	end,
}

------------------------------------------------------------------
-- Halflings powers
------------------------------------------------------------------
newTalentType{ type="race/halfling", name = "halfling", generic = true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "HALFLING_LUCK",
	name = "Luck of the Little Folk",
	type = {"race/halfling", 1},
	no_energy = true,
	cooldown = 50,
	tactical = { ATTACK = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_HALFLING_LUCK, 5, {
			physical=10 + self:getCun() / 2,
			spell=10 + self:getCun() / 2,
		})
		return true
	end,
	info = function(self)
		return ([[Call upon the luck and cunning of the Little Folk to increase your physical and spell critical strike chance by %d%% for 5 turns.
		The bonus will increase with the Cunning stat]]):format(10 + self:getCun() / 5, 10 + self:getCun() / 5)
	end,
}

------------------------------------------------------------------
-- Thaloren powers
------------------------------------------------------------------
newTalentType{ type="race/thalore", name = "thalore", generic = true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "THALOREN_WRATH",
	name = "Wrath of the Eternals",
	type = {"race/thalore", 1},
	no_energy = true,
	cooldown = 50,
	tactical = { ATTACK = 1, DEFEND = 1 },
	action = function(self, t)
		self:setEffect(self.EFF_ETERNAL_WRATH, 5, {power=7 + self:getWil(10)})
		return true
	end,
	info = function(self)
		return ([[Call upon the power of the Eternals, increasing all damage by %d%% and reducing all damage taken by %d%% for 5 turns.
		The bonus will increase with the Willpower stat]]):format(7 + self:getWil(10), 7 + self:getWil(10))
	end,
}

------------------------------------------------------------------
-- Orcs powers
------------------------------------------------------------------
newTalentType{ type="race/orc", name = "orc", generic = true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "ORC_FURY",
	name = "Orcish Fury",
	type = {"race/orc", 1},
	no_energy = true,
	cooldown = 50,
	tactical = { ATTACK = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_ORC_FURY, 5, {power=10 + self:getWil(20)})
		return true
	end,
	info = function(self)
		return ([[Summons your lust for blood and destruction, increasing all damage by %d%% for 5 turns.
		The bonus will increase with the Willpower stat]]):format(10 + self:getWil(20))
	end,
}

------------------------------------------------------------------
-- Yeeks powers
------------------------------------------------------------------
newTalentType{ type="race/yeek", name = "yeek", generic = true, description = "The various racial bonuses a character can have." }
newTalent{
	short_name = "YEEK_WILL",
	name = "Dominant Will",
	type = {"race/yeek", 1},
	no_energy = true,
	cooldown = 50,
	range = 4,
	no_npc_use = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if not target:canBe("instakill") or target.rank > 2 or target.undead or not target:checkHit(self:getWil(20) + self.level * 1.5, target.level) then
				game.logSeen(target, "%s resists the mental assault!", target.name:capitalize())
				return
			end
			target:setEffect(target.EFF_DOMINANT_WILL, 4 + self:getWil(10), {src=self})
		end)
		return true
	end,
	info = function(self)
		return ([[Shatters the mind of your victim, giving your full control over its actions for %s turns.
		When the effect ends you pull out your mind and the victim's body colapses dead.
		This effect does not work on elite or undeads.
		The duration will increase with the Willpower stat]]):format(4 + self:getWil(10))
	end,
}

-- Yeek's power: ID
newTalent{
	short_name = "YEEK_ID",
	name = "Knowledge of the Way",
	type = {"race/yeek", 1},
	no_npc_use = true,
	on_learn = function(self, t) self.auto_id = 2 end,
	action = function(self, t)
		local Chat = require("engine.Chat")
		local chat = Chat.new("elisa-orb-scrying", {name="The Way"}, self, {version="yeek"})
		chat:invoke()
		return true
	end,
	info = function(self)
		return ([[You merge your mind with the rest of the Way for a brief moment, the sum of all yeek knowledge gathers in your mind
		and allows you to identify any item you could not recognize yourself.]])
	end,
}
