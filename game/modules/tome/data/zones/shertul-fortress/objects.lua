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

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_WAND",
	power_source = {unknown=true, arcane=false},
	type = "chest", subtype = "sher'tul",
	define_as = "TRANSMO_CHEST",
	add_name = false,
	identified=true, force_lore_artifact=true,
	name = "Transmogrification Chest", display = '~', color=colors.GOLD, unique=true, image = "object/chest4.png",
	desc = [[This chest is an extension of Yiilkgur, any items dropped inside is transported to the Fortress, processed by the core and destroyed to extract energy.
The byproduct of this effect is the creation of gold, which is useless to the Fortress, so it is sent back to you.

When you possess the chest all items you walk upon will automatically be put inside and transmogrified when you leave the level.
Simply go to your inventory to move them out of the chest if you wish to keep them.
Items in the chest will not encumber you.]],
	cost = 0, quest=true,

	carrier = {
		has_transmo = 1,
	},

	max_power = 1000, power_regen = 1,
	use_power = { name = "transmogrify all the items in your chest at once(also done automatically when you change level)", power = 0,
		use = function(self, who)
			local inven = who:getInven("INVEN")
			require("engine.ui.Dialog"):yesnoPopup("Transmogrification Chest", "Transmogrify all "..#inven.." item(s) in your chest?", function(ret)
				if not ret then return end
				for i = #inven, 1, -1 do
					local o = inven[i]
					if o.__transmo then
						who:transmoInven(inven, i, o)
					end
				end
			end)
			return {id=true, used=true}
		end
	},

	on_pickup = function(self, who)
		require("engine.ui.Dialog"):simpleLongPopup("Transmogrification Chest", [[This chest is an extension of Yiilkgur, any items dropped inside is transported to the Fortress, processed by the core and destroyed to extract energy.
The byproduct of this effect is the creation of gold, which is useless to the Fortress, so it is sent back to you.

When you possess the chest all items you walk upon will automatically be put inside and transmogrified when you leave the level.
To take an item out, simply go to your inventory to move them out of the chest.
Items in the chest will not encumber you.]], 500)
	end,
	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	define_as = "SIMPLE_GOWN",
	name = "simple gown",
	cost = 0.5,
	material_level = 1,
	moddable_tile = "upper_body_12",
	egos = false, egos_chance = false,
}
