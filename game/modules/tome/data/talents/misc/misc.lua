-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
load("/data/talents/misc/races.lua")

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
		if not self:canBe("worldport") or self:attr("never_move") then
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
