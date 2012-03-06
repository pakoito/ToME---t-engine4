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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")

newEntity{base="HARDWALL", define_as = "ATAMATHON_BROKEN",
	nice_tiler = false,
	display = 'g', color = colors.RED,
	image = "npc/atamathon_broken.png",
	resolvers.nice_tile{image="terrain/grass.png", add_displays = {class.new{z=18,image="npc/construct_golem_athamathon_the_giant_golem.png", display_y=-1, display_h=2}}},
	name = "the remains of Atamathon",
	show_tooltip = true,
	desc = [[This giant golem was constructed by the halflings during the Pyre Wars to fight the orcs, but was felled by Garkul the Devourer.
Its body is made of marble, its joints of solid voratun, and its eyes of purest ruby. One of its eyes seems to be missing. At over 40 feet high it towers above you.
Someone foolish has tried to reconstruct it, but it seems like it misses an eye to be completed.]],
	dig = false,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			e:learnLore("broken-atamathon")
			local eye, eye_item = e:findInInventoryBy(e:getInven("INVEN"), "define_as", "ATAMATHON_ACTIVATE")
			if eye then
				require("engine.ui.Dialog"):yesnoPopup("Atamathon", "It seems that your "..eye:getName{do_color=true}.." is made to fit inside the empty eye socket of Atamathon. This is probably very unwise.", function(ret)
					if not ret then return end
					if game.difficulty == game.DIFFICULTY_INSANE then
						game.zone.base_level = 50 * 2 + 10
					else
						game.zone.base_level = 50
					end
					game.zone.min_material_level = 5
					game.zone.max_material_level = 5
					game.level.data.no_worldport = true
					local grass = game.zone:makeEntityByName(game.level, "terrain", "GRASS")
					local atamathon = game.zone:makeEntityByName(game.level, "actor", "ATAMATHON")
					if not grass or not atamathon then game.log("The socket seems broken.") return end

					e:removeObject(e:getInven("INVEN"), eye_item)

					game.log("#LIGHT_RED#As you insert the gem the golem starts to shake. All its systems and magics are reactivating.")
					game.log("#LIGHT_RED#Atamathon walks the world again, but without control.")
					game.zone:addEntity(game.level, grass, "terrain", x, y)
					game.zone:addEntity(game.level, atamathon, "actor", x, y)
					atamathon:doEmote("Activating defenses. Targetting hostile. **DESTRUCTION**!", 60)
					atamathon:setTarget(e)
				end, "Insert", "Cancel")
			end
		end
		return true
	end
}
