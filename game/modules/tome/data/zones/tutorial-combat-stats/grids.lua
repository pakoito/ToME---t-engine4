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
load("/data/general/grids/lava.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/cave.lua")
load("/data/general/grids/fortress.lua")

newEntity{
	define_as = "PORTAL_BACK",
	name = "Lobby Portal", image = "terrain/grass.png", add_displays = {class.new{image = "trap/trap_teleport_01.png"}},
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[This portal will bring you back to the Tutorial Lobby.]],

	on_move = function(self, x, y, who)
		if who == game.player then
			require("engine.ui.Dialog"):yesnoPopup("Tutorial Lobby Portal", "Enter the portal back to the lobby?", function(ret)
				if not ret then
					--game:onLevelLoad("wilderness-1", function(zone, level)
					--	local spot = level:pickSpot{type="farportal-end", subtype="demon-plane-arrival"}
					--	who.wild_x, who.wild_y = spot.x, spot.y
					--end)
					game:changeLevel(1, "tutorial")
					game.logPlayer(who, "#VIOLET#You enter the swirling portal and in the blink of an eye you are back in the lobby.")
				end
			end, "Stay", "Enter")
		end
	end,
}

newEntity{
	define_as = "PORTAL_BACK_2",
	name = "Lobby Portal", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image = "trap/trap_teleport_01.png"}},
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[This portal will bring you back to the Tutorial Lobby.]],

	on_move = function(self, x, y, who)
		if who == game.player then
			require("engine.ui.Dialog"):yesnoPopup("Tutorial Lobby Portal", "Enter the portal back to the lobby?", function(ret)
				if not ret then
					--game:onLevelLoad("wilderness-1", function(zone, level)
					--	local spot = level:pickSpot{type="farportal-end", subtype="demon-plane-arrival"}
					--	who.wild_x, who.wild_y = spot.x, spot.y
					--end)
					game:changeLevel(1, "tutorial")
					game.logPlayer(who, "#VIOLET#You enter the swirling portal and in the blink of an eye you are back in the lobby.")
				end
			end, "Stay", "Enter")
		end
	end,
}

newEntity{
	define_as = "SQUARE_GRASS",
	type = "floor", subtype = "grass",
	name = "grass", image = "terrain/grass.png",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	grow = "TREE",
	--nice_tiler = { method="replace", base={"GRASS_PATCH", 70, 1, 12}},
	--nice_editer = grass_editer,
}

newEntity{ base="WATER_BASE",
	define_as = "TUTORIAL_WATER",
	image="terrain/water_grass_5_1.png",
	air_level = -5, air_condition="water",
	does_block_move = true,
	pass_projectile = true,
}

newEntity{
	define_as = "SIGN",
	name = "Sign",
	desc = [[Contains a snippet of ToME wisdom.]],
	image = "terrain/grass.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
}


newEntity{
	define_as = "SIGN_FLOOR",
	name = "Sign",
	desc = [[Contains a snippet of ToME wisdom.]],
	image = "terrain/marble_floor.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
}

newEntity{
	define_as = "SIGN_CAVE",
	name = "Sign",
	desc = [[Contains a snippet of ToME wisdom.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
}

newEntity{
	define_as = "SIGN_SOLID_FLOOR",
	name = "Sign",
	desc = [[Contains a snippet of ToME wisdom.]],
	image = "terrain/solidwall/solid_floor1.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
}

newEntity{
	define_as = "UNLEARN_ALL",
	name = "Rune of Enlightenment: Summer Vacation",
	desc = [[Causes the player's brain to jettison all recently-acquired knowledge.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/trap_lethargy_rune_01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		game.level.map:particleEmitter(x, y, 1, "teleport")
		game.logPlayer(actor, "#VIOLET#You feel unenlightened.")
		if actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
			actor:unlearnTalent(actor.T_TUTORIAL_PHYS_KB)
		end
		if actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
			actor:unlearnTalent(actor.T_TUTORIAL_SPELL_KB)
		end
		if actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
			actor:unlearnTalent(actor.T_TUTORIAL_MIND_KB)
		end
		if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
			actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLINK)
		end
		if actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
			actor:unlearnTalent(actor.T_TUTORIAL_MIND_FEAR)
		end
		actor:unlearnTalent(actor.T_TUTORIAL_MIND_CONFUSION)
		actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLEED)

	end,
}


newEntity{
	define_as = "LEARN_PHYS_KB",
	name = "Rune of Enlightenment: Shove",
	desc = [[Teaches the player 'Shove'.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/blast_acid01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if q and not actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
			actor:learnTalent(game.player.T_TUTORIAL_PHYS_KB, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#You have learned the talent Shove.")
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLINK)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_FEAR)
			end
			if q and not q:isCompleted("learn_phys_kb") then
				game.logPlayer(actor, "#VIOLET#The sound of an ancient door grinding open echoes down the tunnel!")
				local spot = game.level:pickSpot{type="door", subtype="sealed"}
				local g = game.zone:makeEntityByName(game.level, "terrain", "DOOR_OPEN")
				game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
				actor:setQuestStatus("tutorial-combat-stats", engine.Quest.COMPLETED, "learn_phys_kb")
			end
		end
	end,
}

newEntity{
	define_as = "LEARN_SPELL_KB",
	name = "Rune of Enlightenment: Mana Gale",
	desc = [[Teaches the player 'Mana Gale'.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/blast_fire01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if q and not actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
			actor:learnTalent(game.player.T_TUTORIAL_SPELL_KB, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#You have learned the talent Mana Gale.")
			if actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_PHYS_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLINK)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_FEAR)
			end
		end
	end,
}

newEntity{
	define_as = "LEARN_SPELL_KB3",
	name = "Rune of Enlightenment: Mana Gale",
	desc = [[Teaches the player 'Mana Gale'.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/blast_fire01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if q and not actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
			actor:learnTalent(game.player.T_TUTORIAL_SPELL_KB, true, 3)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#You have learned the talent Mana Gale.")
			if actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_PHYS_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLINK)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_FEAR)
			end
		end
	end,
}

newEntity{
	define_as = "LEARN_MIND_KB",
	name = "Rune of Enlightenment: Telekinetic Punt",
	desc = [[Teaches the player 'Telekinetic Punt'.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/blast_ice01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if q and not actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
			actor:learnTalent(game.player.T_TUTORIAL_MIND_KB, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#You have learned the talent Telekinetic Punt.")
			if actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_PHYS_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLINK)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_FEAR)
			end
		end
	end,
}


newEntity{
	define_as = "LEARN_SPELL_BLINK",
	name = "Rune of Enlightenment: Blink",
	desc = [[Teaches the player 'Blink'.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/blast_lightning01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if not actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
			actor:learnTalent(game.player.T_TUTORIAL_SPELL_BLINK, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#You have learned the talent Blink.")
			if actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_PHYS_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_FEAR)
			end
		end
	end,
}

newEntity{
	define_as = "LEARN_MIND_FEAR",
	name = "Rune of Enlightenment: Fear",
	desc = [[Teaches the player 'Fear'.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/trap_poison_burst_01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if not actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
			actor:learnTalent(game.player.T_TUTORIAL_MIND_FEAR, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#You have learned the talent Fear.")
			if actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_PHYS_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLINK)
			end
		end
	end,
}

newEntity{
	define_as = "LEARN_SPELL_BLEED",
	name = "Rune of Enlightenment: Bleed",
	desc = [[Teaches the player 'Bleed'.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/trap_magical_disarm_01_64.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		if not actor:knowTalent(actor.T_TUTORIAL_SPELL_BLEED) then
			actor:learnTalent(game.player.T_TUTORIAL_SPELL_BLEED, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#You have learned the talent Bleed.")
		end
		if actor:knowTalent(actor.T_TUTORIAL_MIND_CONFUSION) then
			actor:unlearnTalent(actor.T_TUTORIAL_MIND_CONFUSION)
		end
	end,
}

newEntity{
	define_as = "LEARN_MIND_CONFUSION",
	name = "Rune of Enlightenment: Confusion",
	desc = [[Teaches the player 'Confusion'.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/trap_teleport_01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		if not actor:knowTalent(actor.T_TUTORIAL_MIND_CONFUSION) then
			actor:learnTalent(game.player.T_TUTORIAL_MIND_CONFUSION, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#You have learned the talent Confusion.")
		end
		if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLEED) then
			actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLEED)
		end
	end,
}

newEntity{
	define_as = "MAGIC_DOOR",
	type = "wall", subtype = "floor",
	name = "glowing door", image = "terrain/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	--nice_tiler = { method="door3d", north_south="DOOR_VERT", west_east="DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	does_block_move = true,
	is_door = true,
	
--[=[	on_move = function(self, x, y, actor, forced) 
		if not actor.player then return end
		if forced then return end
		local q = game.player:hasQuest("tutorial")
		if q and q:isCompleted("learn_phys_kb") then
			local f = game.zone:makeEntityByName(game.level, "terrain", "DOOR_OPEN")
			game.zone:addEntity(game.level, f, "terrain", x, y)
			game.nicer_tiles:updateAround(game.level, x, y)
		else
			game.logPlayer(game.player, "#VIOLET#You must achieve Enlightenment before you can pass. Seek ye to the west to discover the ancient art of Shoving Stuff.")
		end
	end,]=]
	door_opened = function(self, x, y, actor, forced) 
		if not actor.player then return end
		if forced then return end
		local q = game.player:hasQuest("tutorial-combat-stats")
		if q and q:isCompleted("learn_phys_kb") then
			return "DOOR_OPEN"
		else
			game.logPlayer(game.player, "#VIOLET#You must achieve Enlightenment before you can pass. Seek ye to the west to discover the ancient art of Shoving Stuff.")
		end
	end,
}

newEntity{
	define_as = "LOCK",
	name = "sealed door", image = "terrain/granite_door1.png",
	display = '+', color=colors.WHITE, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	block_sight = true,
	does_block_move = true,
}

newEntity{
	define_as = "FINAL_LESSON",
	name = "Sign",
	desc = [[Contains a snippet of ToME wisdom.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if q and not q:isCompleted("final-lesson") then
			actor:setQuestStatus("tutorial-combat-stats", engine.Quest.COMPLETED, "final-lesson")
		end
	end,
}

newEntity{
	define_as = "COMBAT_STATS_DONE",
	name = "Sign",
	desc = [[Contains a snippet of ToME wisdom.]],
	image = "terrain/solidwall/solid_floor1.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if q and not q:isCompleted("finished-combat-stats") then
			actor:setQuestStatus("tutorial-combat-stats", engine.Quest.COMPLETED, "finished-combat-stats")
			--q:final_message()
		end
	end,
}