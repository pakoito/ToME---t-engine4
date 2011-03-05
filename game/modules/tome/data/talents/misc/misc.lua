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

-- race & classes
newTalentType{ type="base/class", name = "class", hide = true, description = "The basic talents defining a class." }
newTalentType{ type="base/race", name = "race", hide = true, description = "The various racial bonuses a character can have." }
newTalentType{ type="inscriptions/infusions", name = "infusions", hide = true, description = "Infusions are not class abilities, you must find them or learn them from other people." }
newTalentType{ is_spell=true, type="inscriptions/runes", name = "runes", hide = true, description = "Runes are not class abilities, you must find them or learn them from other people." }
newTalentType{ is_spell=true, type="inscriptions/taints", name = "taints", hide = true, description = "Taints are not class abilities, you must find them or learn them from other people." }

-- Load other misc things
load("/data/talents/misc/inscriptions.lua")
load("/data/talents/misc/npcs.lua")

-- Default melee attack
newTalent{
	name = "Attack",
	type = {"base/class", 1},
	no_energy = "fake",
	hide = true,
	innate = true,
	points = 1,
	range = 1,
	message = false,
	requires_target = true,
	target = {type="hit", range=1},
	tactical = { ATTACK = 1 },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x then return end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x then return end
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then return end

		self:attackTarget(target)
		return true
	end,
	info = function(self, t)
		return ([[Hack and slash, baby!]])
	end,
}

--mindslayer resource
newTalent{
	name = "Psi Pool",
	type = {"base/class", 1},
	info = "Allows you to have an energy pool. Energy is used to perform psionic manipulations.",
	mode = "passive",
	hide = true,
}

newTalent{
	name = "Mana Pool",
	type = {"base/class", 1},
	info = "Allows you to have a mana pool. Mana is used to cast all spells.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Vim Pool",
	type = {"base/class", 1},
	info = "Allows you to have a vim pool. Vim is used by corruptions.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Stamina Pool",
	type = {"base/class", 1},
	info = "Allows you to have a stamina pool. Stamina is used to activate special combat attacks.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Equilibrium Pool",
	type = {"base/class", 1},
	info = "Allows you to have an equilibrium pool. Equilibrium is used to measure your balance with nature and the use of wild gifts.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Positive Pool",
	type = {"base/class", 1},
	info = "Allows you to have a positive energy pool.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Negative Pool",
	type = {"base/class", 1},
	info = "Allows you to have a negative energy pool.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Hate Pool",
	type = {"base/class", 1},
	info = "Allows you to have a hate pool.",
	mode = "passive",
	hide = true,
}

newTalent{
	name = "Paradox Pool",
	type = {"base/class", 1},
	info = "Allows you to have a paradox pool.",
	mode = "passive",
	hide = true,
}

newTalent{
	name = "Improved Health I",
	type = {"base/race", 1},
	info = "Improves the number of health points per level.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Improved Health II",
	type = {"base/race", 1},
	info = "Improves the number of health points per level.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Improved Health III",
	type = {"base/race", 1},
	info = "Improves the number of health points per level.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Decreased Health I",
	type = {"base/race", 1},
	info = "Improves the number of health points per level.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Decreased Health II",
	type = {"base/race", 1},
	info = "Improves the number of health points per level.",
	mode = "passive",
	hide = true,
}
newTalent{
	name = "Decreased Health III",
	type = {"base/race", 1},
	info = "Improves the number of health points per level.",
	mode = "passive",
	hide = true,
}

-- Mages class talent, teleport to angolwen
newTalent{
	short_name = "TELEPORT_ANGOLWEN",
	name = "Teleport: Angolwen",
	type = {"base/class", 1},
	cooldown = 1000,
	no_npc_use = true,
	no_silence=true, is_spell=true,
	action = function(self, t)
		if not self:canBe("worldport") then
			game.logPlayer(self, "The spell fizzles...")
			return
		end

		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then seen = true end
		end, nil)
		if seen then
			game.log("There are creatures that could be watching you; you cannot take the risk.")
			return
		end

		self:setEffect(self.EFF_TELEPORT_ANGOLWEN, 40, {})
		return true
	end,
	info = [[Allows a mage to teleport to the secret town of Angolwen.
	You have studied the magic arts there and have been granted a special portal spell to teleport there.
	Nobody must learn about this spell and so it should never be used while seen by any creatures.
	The spell will take time to activate. You must be out of sight of any creature when you cast it and when the teleportation takes effect.]]
}

-- Highers's power, a "weak" regeneration
newTalent{
	short_name = "HIGHER_HEAL",
	name = "Gift of the Pureborn",
	type = {"base/race", 1},
	no_energy = true,
	cooldown = 50,
	tactical = { HEAL = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 10, {power=5 + self:getWil() * 0.5})
		return true
	end,
	info = function(self)
		return ([[Call upon the gift of the pureborn to regenerate your body for %d life every turn for 10 turns.
		The life healed will increase with the Willpower stat]]):format(5 + self:getWil() * 0.5)
	end,
}

-- Shaloren's power, a temporary speedup
newTalent{
	short_name = "SHALOREN_SPEED",
	name = "Grace of the Eternals",
	type = {"base/race", 1},
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

-- Dwarf's power, a temporary stone shield
newTalent{
	short_name = "DWARF_RESILIENCE",
	name = "Resilience of the Dwarves",
	type = {"base/race", 1},
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

-- Halflings's power, temporary crit bonus
newTalent{
	short_name = "HALFLING_LUCK",
	name = "Luck of the Little Folk",
	type = {"base/race", 1},
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

-- Thaloren's power: temporary damage increase and damage reduction
newTalent{
	short_name = "THALOREN_WRATH",
	name = "Wrath of the Eternals",
	type = {"base/race", 1},
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

-- Orc's power: temporary damage increase
newTalent{
	short_name = "ORC_FURY",
	name = "Orcish Fury",
	type = {"base/race", 1},
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

-- Yeek's power: temporary damage increase
newTalent{
	short_name = "YEEK_WILL",
	name = "Dominant Will",
	type = {"base/race", 1},
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
	type = {"base/race", 1},
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

-- Undeads's power: ID
newTalent{
	short_name = "UNDEAD_ID",
	name = "Knowledge of the Past",
	type = {"base/race", 1},
	no_npc_use = true,
	on_learn = function(self, t) self.auto_id = 2 end,
	action = function(self, t)
		local Chat = require("engine.Chat")
		local chat = Chat.new("elisa-orb-scrying", {name="Past memories"}, self, {version="undead"})
		chat:invoke()
		return true
	end,
	info = function(self)
		return ([[You concentrate for a moment to recall some of your memories as a living being and look for knowledge to identify rare objects.]])
	end,
}
