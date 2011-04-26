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

load("/data/general/grids/basic.lua")

newEntity{
	define_as = "LAKE_NUR",
	name = "stair back to the lake of Nur",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 3, change_zone = "lake-nur", force_down = true,
}

newEntity{
	define_as = "SEALED_DOOR",
	name = "sealed door", image = "terrain/stone_wall_door.png",
	display = '+', color=colors.WHITE, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	block_sight = true,
	does_block_move = true,
}

newEntity{ base = "HARDWALL",
	define_as = "HARD_BIGWALL",
	block_sense = true,
	block_esp = true,
	dig = false,
}

newEntity{
	define_as = "TELEPORT_OUT",
	name = "teleportation circle to the surface", image = "terrain/maze_floor.png", add_displays = {class.new{image="terrain/maze_teleport.png"}},
	display = '>', color_r=255, color_g=0, color_b=255,
	notice = true, show_tooltip = true,
	change_level = 1, change_zone = "wilderness",
}

newEntity{
	define_as = "COMMAND_ORB",
	name = "Sher'Tul Control Orb", image = "terrain/maze_floor.png", add_displays = {class.new{image="terrain/worldmap.png"}},
	display = '*', color=colors.PURPLE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local chat = require("engine.Chat").new("shertul-fortress-command-orb", self, e)
			chat:invoke()
		end
		return true
	end,
}

newEntity{ base = "HARD_BIGWALL",
	define_as = "GREEN_DRAPPING",
	add_displays = {class.new{image="terrain/green_drapping.png"}},
}
newEntity{ base = "HARD_BIGWALL",
	define_as = "PURPLE_DRAPPING",
	add_displays = {class.new{image="terrain/purple_drapping.png"}},
}

newEntity{
	define_as = "FARPORTAL",
	name = "Exploratory Farportal",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/maze_floor.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[A farportal is a way to travel incredible distances in the blink of an eye. They are left over of the powerful Sher'tul race.
This farportal is not connected to any other portal, it is made for exploration, you can not know where it will send you.
It should automatically create a portal back, but it might not be near your arrival zone.]],

	on_move = function(self, x, y, who)
		if not who.player then return end
		local Dialog = require "engine.ui.Dialog"
		local q = who:hasQuest("shertul-fortress")
		if not q then Dialog:simplePopup("Exploratory Farportal", "The farportal seems to be inactive") return end
		if not q:exploratory_energy(true) then Dialog:simplePopup("Exploratory Farportal", "The fortress does not have enough energy to power a trip through the portal.") return end

		Dialog:yesnoPopup("Exploratory Farportal", "Do you want to travel in the farportal? You can not know where you will end up.", function(ret) if ret then
			local zone, boss = game.state:createRandomZone()
			zone.no_worldport = true
			boss.explo_portal_on_die = boss.on_die
			boss.on_die = function(self, ...)
				local x, y = self.x or game.player.x, self.y or game.player.y
				local g = game.level.map(x, y, engine.Map.TERRAIN)
				g = g:cloneFull()
				g.show_tooltip = true
				g.name = "Exploratory Farportal exit"
				g.display = '&' g.color_r = colors.VIOLET.r g.color_g = colors.VIOLET.g g.color_b = colors.VIOLET.b
				g.add_displays = g.add_displays or {}
				g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/maze_teleport.png"}
				g.notice = true
				g.change_level = 1 g.change_zone = "shertul-fortress"
				g._mo = nil
				g:resolve() g:resolve(nil, true)
				game.zone:addEntity(game.level, g, "terrain", x, y)
				game.logSeen(self, "#VIOLET#As %s falls you notice a portal appearing.", self.name)

				self:check("explo_portal_on_die", ...)
				self.on_die = self.explo_portal_on_die
				self.explo_portal_on_die = nil
			end
			game:changeLevel(1, zone)
			q:exploratory_energy()
			game.log("#VIOLET#You enter the swirling portal and in the blink of an eye you set foot in an unfamiliar zone, with no trace of the portal...")
		end end)
	end,
}

newEntity{ base = "FARPORTAL", define_as = "CFARPORTAL",
	image = "terrain/maze_floor.png",
	add_displays = {
		class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3},
	},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(y, y, 3, "farportal_lightning")
	end,
}
