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

load("/data/general/objects/objects-far-east.lua")
load("/data/general/objects/lore/sunwall.lua")
load("/data/general/objects/lore/orc-prides.lua")

local Stats = require"engine.interface.ActorStats"

-- Artifact, randomly dropped in Vor Pride, and only there
newEntity{ base = "BASE_SCROLL", subtype="tome",
	power_source = {arcane=true},
	name = "Tome of Wildfire", unided_name = "burning book", unique=true, no_unique_lore=true, image = "object/artifact/tome_of_wildfire.png",
	desc = "This huge book is covered in searing flames. Yet they do not harm you.",
	color = colors.VIOLET,
	level_range = {35, 45},
	rarity = 200,
	cost = 100,

	use_simple = { name="learn the ancient secrets", use = function(self, who)
		if not who:knowTalent(who.T_FLAME) then
			who:learnTalent(who.T_FLAME, true, 3, {no_unlearn=true})
			game.logPlayer(who, "#00FFFF#You read the tome and learn about ancient forgotten fire magic!")
		else
			who.talents_types_mastery["spell/fire"] = (who.talents_types_mastery["spell/fire"] or 1) + 0.1
			who.talents_types_mastery["spell/wildfire"] = (who.talents_types_mastery["spell/wildfire"] or 1) + 0.1
			game.logPlayer(who, "#00FFFF#You read the tome and perfect your mastery of fire magic!")
		end

		return {used=true, id=true, destroy=true}
	end}
}

-- Artifact, randomly dropped in Vor Pride, and only there
newEntity{ base = "BASE_SCROLL", subtype="tome",
	power_source = {arcane=true},
	name = "Tome of Uttercold", unided_name = "frozen book", unique=true, no_unique_lore=true, image = "object/artifact/tome_of_uttercold.png",
	desc = "This huge book is covered in slowly shifting patterns of ice. Yet they do not harm you.",
	color = colors.VIOLET,
	level_range = {35, 45},
	rarity = 200,
	cost = 100,

	use_simple = { name="learn the ancient secrets", use = function(self, who)
		if not who:knowTalent(who.T_ICE_STORM) then
			who:learnTalent(who.T_ICE_STORM, true, 3, {no_unlearn=true})
			game.logPlayer(who, "#00FFFF#You read the tome and learn about ancient forgotten ice magic!")
		else
			who.talents_types_mastery["spell/water"] = (who.talents_types_mastery["spell/water"] or 1) + 0.1
			who.talents_types_mastery["spell/ice"] = (who.talents_types_mastery["spell/ice"] or 1) + 0.1
			game.logPlayer(who, "#00FFFF#You read the tome and perfect your mastery of ice magic!")
		end

		return {used=true, id=true, destroy=true}
	end}
}

newEntity{ base = "BASE_LORE",
	define_as = "NOTE_LORE",
	name = "draft note", lore="vor-pride-note",
	desc = [[A note.]],
	rarity = false,
}

for i = 1, 5 do
newEntity{ base = "BASE_LORE",
	define_as = "ORC_HISTORY"..i,
	name = "Records of Lorekeeper Hadak", lore="orc-history-"..i, unique="Records of Lorekeeper Hadak "..i,
	desc = [[Part of the long history of the Orc race.]],
	rarity = false,
}
end
