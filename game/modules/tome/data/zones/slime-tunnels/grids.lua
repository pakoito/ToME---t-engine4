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

load("/data/general/grids/basic.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/slime.lua")

local orb_activate = function(self, x, y, who, act, couldpass)
	if not who or not who.player or not act then return false end
	if self.orbed then return false end

	local owner, orb = game.party:findInAllPartyInventoriesBy("define_as", self.define_as)

	if not orb then
		require("engine.ui.Dialog"):simplePopup("Strange Pedestal", "This pedestal looks old, you can see the shape of an orb carved on it.")
	else
		require("engine.ui.Dialog"):yesnoLongPopup("Strange Pedestal", "The pedestal seems to react to something in your bag. After some tests you notice it is the "..tostring(orb:getName{do_color=true})..".\nDo you wish to use the orb on the pedestal?", 400, function(ret)
			if ret then game.player:useCommandOrb(orb, x, y) end
		end)
	end
	return false
end

local orb_summon = function(self, who)
	local filter = self.summon
	local npc = game.zone:makeEntity(game.level, "actor", filter, nil, true)
	local nx, ny = util.findFreeGrid(who.x, who.y, 10, true, {[engine.Map.ACTOR]=true})
	if npc and nx then
		npc.on_die = function(self) world:gainAchievement("SLIME_TUNNEL_BOSSES", game.player) end
		game.zone:addEntity(game.level, npc, "actor", nx, ny)
	end
end

newEntity{
	define_as = "ORB_DRAGON",
	name = "orb pedestal (dragon)", special = true, image = "terrain/slime/slime_floor_01.png", add_displays={class.new{image = "terrain/pedestal_01.png", display_h=2, display_y=-1}},
	display = '_', color_r=255, color_g=255, color_b=255, back_color=colors.LIGHT_RED,
	always_remember = true,
	notice = true,
	once_used_image = "terrain/pedestal_orb_03.png",
	orb_command = {
		continue = true,
		summon = {
			base_list="mod.class.NPC:/data/general/npcs/multihued-drake.lua",
			type="dragon", subtype="multihued", name="greater multi-hued wyrm",
			random_boss = {name_scheme="#rng# the Fearsome", class_filter=function(d) return d.name == "Archmage" end},
			add_levels = 12,
		},
		special = orb_summon,
	},
	block_move = orb_activate,
}
newEntity{
	define_as = "ORB_UNDEATH",
	name = "orb pedestal (undeath)", special = true, image = "terrain/slime/slime_floor_01.png", add_displays={class.new{image = "terrain/pedestal_01.png", display_h=2, display_y=-1}},
	display = '_', color_r=255, color_g=255, color_b=255, back_color=colors.LIGHT_RED,
	always_remember = true,
	notice = true,
	once_used_image = "terrain/pedestal_orb_05.png",
	orb_command = {
		continue = true,
		summon = {
			base_list="mod.class.NPC:/data/general/npcs/lich.lua",
			type="undead", subtype="lich", name="archlich",
			random_boss = {name_scheme="#rng# the Neverdead", class_filter=function(d) return d.name == "Necromancer" end},
			add_levels = 12,
		},
		special = orb_summon,
	},
	block_move = orb_activate,
}
newEntity{
	define_as = "ORB_ELEMENTS",
	name = "orb pedestal (elements)", special = true, image = "terrain/slime/slime_floor_01.png", add_displays={class.new{image = "terrain/pedestal_01.png", display_h=2, display_y=-1}},
	display = '_', color_r=255, color_g=255, color_b=255, back_color=colors.LIGHT_RED,
	always_remember = true,
	notice = true,
	once_used_image = "terrain/pedestal_orb_04.png",
	orb_command = {
		continue = true,
		summon = {
			base_list="mod.class.NPC:/data/general/npcs/gwelgoroth.lua",
			type="elemental", subtype="air", name="ultimate gwelgoroth",
			random_boss = {name_scheme="#rng# the Silent Death", class_filter=function(d) return d.name == "Shadowblade" end},
			add_levels = 12,
		},
		special = orb_summon,
	},
	block_move = orb_activate,
}
newEntity{
	define_as = "ORB_DESTRUCTION",
	name = "orb pedestal (destruction)", special = true, image = "terrain/slime/slime_floor_01.png", add_displays={class.new{image = "terrain/pedestal_01.png", display_h=2, display_y=-1}},
	display = '_', color_r=255, color_g=255, color_b=255, back_color=colors.LIGHT_RED,
	always_remember = true,
	notice = true,
	once_used_image = "terrain/pedestal_orb_02.png",
	orb_command = {
		continue = true,
		summon = {
			base_list="mod.class.NPC:/data/general/npcs/major-demon.lua",
			type="demon", subtype="major", name="forge-giant",
			random_boss = {name_scheme="#rng# the Crusher", class_filter=function(d) return d.name == "Corruptor" end},
			add_levels = 12,
		},
		special = orb_summon,
	},
	block_move = orb_activate,
}

newEntity{ base = "SLIME_DOOR_VERT",
	define_as = "PEAK_DOOR",
	name = "sealed door",
	is_door = true,
	door_opened = false,
	nice_tiler = false,
	does_block_move = true,
}

newEntity{
	define_as = "PEAK_STAIR",
	always_remember = true,
	show_tooltip=true,
	name="Entrance to the High Peak",
	display='>', color=colors.VIOLET, image = "terrain/stair_up_wild.png",
	notice = true,
	change_level=1, change_zone="high-peak",
	change_level_check = function()
		require("engine.ui.Dialog"):yesnoLongPopup("High Peak", 'As you stand on the stairs you can feel this is a "do or die" one way trip. If you enter there will be no coming back.\nEnter?', 500, function(ret) if ret then
			game:changeLevel(1, "high-peak")
		end end)
		return true
	end,
}

newEntity{ base = "SLIME_UP",
	define_as = "UP_GRUSHNAK",
	name = "exit to Grushnak Pride",
	change_level = 6,
	change_zone = "grushnak-pride",
	force_down = true,
}
