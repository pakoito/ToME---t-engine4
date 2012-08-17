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
load("/data/general/grids/fortress.lua")

newEntity{ base = "UP",
	define_as = "LAKE_NUR",
	name = "stair back to the lake of Nur",
	display = '<', color_r=255, color_g=255, color_b=0,
	change_level = 3, change_zone = "lake-nur", force_down = true,
}

newEntity{
	define_as = "TELEPORT_OUT",
	name = "teleportation circle to the surface", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image="terrain/maze_teleport.png"}},
	display = '>', color_r=255, color_g=0, color_b=255,
	notice = true, show_tooltip = true,
	change_level = 1, change_zone = "wilderness",
}

newEntity{
	define_as = "COMMAND_ORB",
	name = "Sher'Tul Control Orb", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image="terrain/shertul_control_orb_blue.png"}},
	display = '*', color=colors.PURPLE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local chat = require("engine.Chat").new("shertul-fortress-command-orb", self, e, {player=e})
			chat:invoke()
		end
		return true
	end,
}

newEntity{
	define_as = "FARPORTAL",
	name = "Exploratory Farportal",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/solidwall/solid_floor1.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[A farportal is a way to travel incredible distances in the blink of an eye. They are left over of the powerful Sher'tul race.
This farportal is not connected to any other portal, it is made for exploration, you can not know where it will send you.
It should automatically create a portal back, but it might not be near your arrival zone.]],


	checkSpecialLocation = function(self, who, q)
		-- Caldizar space fortress
		if rng.percent(2) and not game.state:hasSeenSpecialFarportal("caldizar-space-fortress") then
			game:changeLevel(1, "shertul-fortress-caldizar")
			q:exploratory_energy()
			game.log("#VIOLET#You enter the swirling portal and in the blink of an eye you set foot in a strangely familiar zone, right next to a farportal...")
			game.state:seenSpecialFarportal("caldizar-space-fortress")
			return true
		end
	end,

	on_move = function(self, x, y, who)
		if not who.player then return end
		local Dialog = require "engine.ui.Dialog"
		local q = who:hasQuest("shertul-fortress")
		if not q then Dialog:simplePopup("Exploratory Farportal", "The farportal seems to be inactive") return end
		if not q:exploratory_energy(true) then Dialog:simplePopup("Exploratory Farportal", "The fortress does not have enough energy to power a trip through the portal.") return end
		if q:isCompleted("farportal-broken") then Dialog:simplePopup("Exploratory Farportal", "The farportal is broken and will not be usable anymore.") return end

		Dialog:yesnoPopup("Exploratory Farportal", "Do you want to travel in the farportal? You can not know where you will end up.", function(ret) if ret then
			if self:checkSpecialLocation(who, q) then return end

			local zone, boss = game.state:createRandomZone()
			zone.no_worldport = true
			zone.force_farportal_recall = true
			zone.generator.actor.abord_no_guardian = true
			zone.make_back_portal = function(self)
				local p = game:getPlayer(true)
				local x, y = p.x, p.y
				local g = game.zone:makeEntityByName(game.level, "terrain", game.zone.basic_floor)
				if g.change_level then return end
				g = g:clone()
				g:removeAllMOs(true)
				g.nice_tiler = nil
				g.show_tooltip = true
				g.name = "Exploratory Farportal exit"
				g.display = '&' g.color_r = colors.VIOLET.r g.color_g = colors.VIOLET.g g.color_b = colors.VIOLET.b
				g.add_displays = g.add_displays or {}
				g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/maze_teleport.png"}
				g.notice = true
				g.change_level = 1 g.change_zone = "shertul-fortress"
				game.zone:addEntity(game.level, g, "terrain", x, y)
				if self then game.logSeen(self, "#VIOLET#As %s falls you notice a portal appearing.", self.name)
				else game.logSeen(p, "#VIOLET#Your rod of recall shakes, a portal appears beneath you.") end
			end
			zone.on_turn = function(zone)
				if game.turn % 1000 == 0 and game.level.level == zone.max_level then
					for uid, e in pairs(game.level.entities) do
						if e.define_as == zone.generator.actor.guardian and not e.dead then return end
					end
					-- Not found!
					zone.make_back_portal()
				end
			end

			boss.explo_portal_on_die = boss.on_die
			boss.on_die = function(self, ...)
				game.zone.make_back_portal(self)

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
	image = "terrain/solidwall/solid_floor1.png",
	add_displays = {
		class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3},
	},
	on_added = function(self, level, x, y)
		if core.shader.active(4) then
			level.map:particleEmitter(x, y, 3, "shader_shield", {}, {type="shield", time_factor=8000, color={0.3, 0.4, 0.7}})
		end
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
	end,
}

newEntity{
	define_as = "LIBRARY",
	name = "Library of Lost Mysteries", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image="terrain/temporal_instability_blue.png"}},
	display = '*', color=colors.BLUE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local nb = 0
			for lore, _ in pairs(profile.mod.lore.lore) do nb = nb + 1 end

			local popup = require("engine.ui.Dialog"):simpleWaiter("Yiilkgur's Library of Lost Mysteries", "Receiving the lost knowledge of the universe...", nil, nil, nb)
			core.wait.enableManualTick(true)
			core.display.forceRedraw()

			if profile.mod.lore and profile.mod.lore.lore then
				for lore, _ in pairs(profile.mod.lore.lore) do
					game.player:learnLore(lore, true, true)
					core.wait.manualTick(1)
				end
			end

			popup:done()

			game:registerDialog(require("mod.dialogs.ShowLore").new("Yiilkgur's Library of Lost Mysteries", game.player))
		end
		return true
	end,
}

for i = 1, 9 do
newEntity{ define_as = "MURAL_PAINTING"..i,
	type = "wall", subtype = "floor",
	name="mural painting", lore = "shertul-fortress-"..i,
	display='#', color=colors.LIGHT_RED,
	image="terrain/solidwall/solid_wall_mural_shertul"..i..".png",
	block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then e:learnLore(self.lore) end return true end
}
end
