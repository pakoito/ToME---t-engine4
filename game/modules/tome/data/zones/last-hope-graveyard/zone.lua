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

return {
	name = "Last Hope Graveyard",
	display_name = function(x, y)
		if game.level.level == 1 then return "Last Hope Graveyard"
		elseif game.level.level == 2 then return "Mausoleum"
		end
		return "Last Hope Graveyard"
	end,
	level_range = {15, 35},
	level_scheme = "player",
	max_level = 2,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	color_shown = {0.7, 0.7, 0.7, 1},
	color_obscure = {0.7*0.6, 0.7*0.6, 0.7*0.6, 0.6},
	ambient_music = "Inside a dream.ogg",
	min_material_level = 2,
	max_material_level = 3,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"random_room"},
			lite_room_chance = 0,
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			nb_npc = {0, 0},
		},
		object = {
			nb_object = {0, 0},
		},
		trap = {
			nb_trap = {0, 0},
		},
	},
	levels =
	{
		[1] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/last-hope-graveyard",
				},
			},
		},
		[2] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/last-hope-mausoleum",
				},
			},
		},
	},

	open_coffin = function(x, y, who)
		local Dialog = require("engine.ui.Dialog")
		Dialog:yesnoLongPopup("Open the coffin", "In rich families the dead are sometimes put to rest with some treasures. However they also sometime protect the coffins with powerful curses. Open?", 500, function(ret)
			if not ret then return end
			-- clear chrono worlds and their various effects
			if game._chronoworlds then
				game.log("#CRIMSON#Your timetravel has no effect on pre-determined outcomes such as this.")
				game._chronoworlds = nil
			end
			local r = rng.range(1, 100)
			if r <= 10 then
				if not who:knowTalentType("cursed/cursed-aura") then
					Dialog:simplePopup("Curse!", "The coffin was a decoy, a powerful curse was set upon you (check your talents).")
					who:learnTalentType("cursed/cursed-aura", true)
					who:learnTalent(who.T_DEFILING_TOUCH, true, nil, {no_unlearn=true})
				else
					game.log("There is nothing there.")
				end
			elseif r <= 60 then
				local m = game.zone:makeEntity(game.level, "actor", {properties={"undead"}, add_levels=10, random_boss={nb_classes=1, rank=3, ai = "tactical", loot_quantity = 0, no_loot_randart = true}}, nil, true)
				local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
				if m and x and y then
					game.zone:addEntity(game.level, m, "actor", x, y)
					game.log("You were not the first here: the corpse was turned into an undead.")
				else
					game.log("There is nothing there.")
				end
			elseif r <= 95 then
				game.log("There is nothing there.")
			else
				local o = game.zone:makeEntity(game.level, "object", {unique=true, not_properties={"lore"}}, nil, true)
				local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.OBJECT]=true})
				if o and x and y then
					game.zone:addEntity(game.level, o, "object", x, y)
					game.log("The corpse had a treasure!")
				else
					game.log("There is nothing there.")
				end
			end

			local g = game.zone:makeEntityByName(game.level, "terrain", "COFFIN_OPEN")
			game.zone:addEntity(game.level, g, "terrain", x, y)
		end)
	end,

	open_all_coffins = function(who, celia)
		local floor = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
		local coffin_open = game.zone:makeEntityByName(game.level, "terrain", "COFFIN_OPEN")
		local spot = game.level:pickSpotRemove{type="door", subtype="chamber"}
		while spot do
			local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN)
			if g.is_door then game.zone:addEntity(game.level, floor, "terrain", spot.x, spot.y) end
			spot = game.level:pickSpotRemove{type="door", subtype="chamber"}
		end

		local spot = game.level:pickSpotRemove{type="coffin", subtype="chamber"}
		while spot do
			local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN)
			if g.define_as == "COFFIN" then
				game.zone:addEntity(game.level, coffin_open, "terrain", spot.x, spot.y)

				local m = game.zone:makeEntity(game.level, "actor", {properties={"undead"}, add_levels=10, random_boss={nb_classes=1, rank=3, ai = "tactical", loot_quantity = 0, no_loot_randart = true}}, nil, true)
				local x, y = util.findFreeGrid(spot.x, spot.y, 5, true, {[engine.Map.ACTOR]=true})
				if m and x and y then
					game.zone:addEntity(game.level, m, "actor", x, y)
					m:setTarget(who)
					m.necrotic_minion = true
					m.summoner = celia
				end
			end
			spot = game.level:pickSpotRemove{type="coffin", subtype="chamber"}
		end

		local spot = game.level:pickSpotRemove{type="stairs", subtype="stairs"}
		if spot then
			local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN)
			game.zone:addEntity(game.level, floor, "terrain", spot.x, spot.y)
		end

		game.log("#YELLOW#You hear all the doors being shattered into pieces.")
	end,

	on_enter = function(lev, old_lev, newzone)
		local Dialog = require("engine.ui.Dialog")
		if lev == 2 and not game.level.shown_warning then
			Dialog:simpleLongPopup("Mausoleum", [[As you tread softly down the stairs a large stone slab slides into place behind you, blocking all retreat. The air is still and stuffy, and in this tight space you feel as if in a coffin, buried alive.

Adding to your unease is a rising feeling of dread, overwhelming fear in fact. A hall of doors lies ahead, and behind each you sense a power of great malevolence and unholy horror. At the end of the corridor you see a faint light beneath a large black door, and you have a vague sense that the other doors are enslaved to this one - obedient, subservient, and waiting...

You hear the sound of a woman sobbing, and every now and then it turns into a fit of pained moans and screams. They echo round the dark chamber and through the darkest parts of your mind, reminding you of every black deed and vile sin you have ever committed. Guilt, horror and terror flood through your thoughts, each competing for stronger control of your psyche. Your only clear thought is of escape, by whatever means you can find.]], 600)
			game.level.shown_warning = true
		end
	end,
}
