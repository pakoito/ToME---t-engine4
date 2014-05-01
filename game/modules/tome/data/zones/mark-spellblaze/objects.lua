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

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_LORE",
	define_as = "DRAFT_LETTER",
	name = "draft letter", lore="grand-corruptor-draft",
	desc = [[A letter.]],
	rarity = false,
	encumberance = 0,
}

newEntity{
	power_source = {nature=true},
	define_as = "CORRUPTED_SANDQUEEN_HEART",
	type = "corpse", subtype = "heart", image = "object/artifact/corrupted_queen_heart.png",
	name = "Corrupted heart of the Sandworm Queen", unique=true, unided_name="pulsing organ",
	display = "*", color=colors.VIOLET,
	desc = [[The heart of the Sandworm Queen, ripped from her dead body and corrupted in the mark of the spellblaze altar. You could ... consume it, should you feel mad enough.]],
	cost = 3000,
	quest = 1,

	use_simple = { name="consume the heart", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You consume the heart and feel the corruption fill you!")
		who.unused_stats = who.unused_stats + 3
		who.unused_talents = who.unused_talents + 1
		who.unused_generics = who.unused_generics + 1
		game.logPlayer(who, "You have %d stat point(s) to spend. Press G to use them.", who.unused_stats)
		game.logPlayer(who, "You have %d class talent point(s) to spend. Press G to use them.", who.unused_talents)
		game.logPlayer(who, "You have %d generic talent point(s) to spend. Press G to use them.", who.unused_generics)

		if not who:attr("forbid_arcane") then
			if who:knowTalentType("corruption/vile-life") then
				who:setTalentTypeMastery("corruption/vile-life", who:getTalentTypeMastery("corruption/vile-life") + 0.2)
			elseif who:knowTalentType("corruption/vile-life") == false then
				who:learnTalentType("corruption/vile-life", true)
			else
				who:learnTalentType("corruption/vile-life", false)
			end
			-- Make sure a previous amulet didnt bug it out
			if who:getTalentTypeMastery("corruption/vile-life") == 0 then who:setTalentTypeMastery("corruption/vile-life", 1) end
			game.logPlayer(who, "You are transformed by the corrupted heart of the Queen!.")
			game.logPlayer(who, "#00FF00#You gain an affinity for blight. You can now learn new Vile Life talents (press G).")

			who:attr("drake_touched", 1)
		end

--		game:setAllowedBuild("wilder_wyrmic", true)

		return {used=true, id=true, destroy=true}
	end}
}
