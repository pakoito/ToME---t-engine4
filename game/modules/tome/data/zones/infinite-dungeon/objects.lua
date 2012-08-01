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

load("/data/general/objects/objects.lua")

newEntity{
	power_source = {technique=true},
	unique = true,
	type = "potion", subtype="potion",
	name = "Potion of Martial Prowess",
	unided_name = "phial filled with metallic liquid",
	level_range = {1, 50},
	display = '!', color=colors.VIOLET, image="object/elixir_of_stoneskin.png",
	encumber = 0.4,
	rarity = 150,
	desc = [[This potent elixir can give insights into martial combat to those unlucky enough to ignore the basics.]],
	cost = 500,

	use_simple = { name = "quaff the elixir", use = function(self, who)
		game.logSeen(who, "%s quaffs the %s!", who.name:capitalize(), self:getName())

		local done = 0

		if not who:knowTalentType("technique/combat-training") then
			who:learnTalentType("technique/combat-training", true)
			game.logPlayer(who, "#VIOLET#You seem to understand the basic martial pratices. (Combat Training talents unlocked)")
			done = done + 1
		end
		if not who:knowTalent(who.T_SHOOT) then
			who:learnTalent(who.T_SHOOT, true, nil, {no_unlearn=true})
			game.logPlayer(who, "#VIOLET#You seem to now know how to properly use a bow or a sling.")
			done = done + 1
		end

		if done == 0 then
			game.logPlayer(who, "#VIOLET#It seems you already knew all the elixir could teach you.")
		end

		return {used=true, id=true, destroy=true}
	end},
}

newEntity{
	power_source = {technique=true},
	unique = true,
	type = "potion", subtype="potion",
	name = "Antimagic Wyrm Bile Extract",
	unided_name = "phial filled with slimy liquid",
	level_range = {10, 50},
	display = '!', color=colors.VIOLET, image="object/elixir_of_avoidance.png",
	encumber = 0.4,
	rarity = 150,
	desc = [[This potent elixir extracted from a powerful wyrm can grant the power to repel arcane forces.]],
	cost = 500,

	use_simple = { name = "quaff the elixir", use = function(self, who, inven, item)
		local d = require("engine.ui.Dialog"):yesnoLongPopup("Antimagic", [[Quaffing this potion will grant you access to the antimagic talents but at the cost of all access to runes, arcane items and spells.]], 500, function(ret)
			if ret then
				game.logSeen(who, "%s quaffs the %s!", who.name:capitalize(), self:getName())

				who:removeObject(inven, item)

				for tid, _ in pairs(who.sustain_talents) do
					local t = who:getTalentFromId(tid)
					if t.is_spell then who:forceUseTalent(tid, {ignore_energy=true}) end
				end

				-- Remove equipment
				for inven_id, inven in pairs(who.inven) do
					for i = #inven, 1, -1 do
						local o = inven[i]
						if o.power_source and o.power_source.arcane then
							game.logPlayer(who, "You can not use your %s anymore, it is tainted by magic.", o:getName{do_color=true})
							local o = who:removeObject(inven, i, true)
							who:addObject(who.INVEN_INVEN, o)
							who:sortInven()
						end
					end
				end

				who:attr("forbid_arcane", 1)
				who:learnTalentType("wild-gift/antimagic", true)
				who:learnTalent(who.T_RESOLVE, true, nil, {no_unlearn=true})
			end
		end)

		return {used=true, id=true}
	end},
}
