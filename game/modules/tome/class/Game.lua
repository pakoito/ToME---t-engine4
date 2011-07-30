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

require "engine.class"
require "engine.GameTurnBased"
require "engine.interface.GameMusic"
require "engine.interface.GameSound"
require "engine.interface.GameTargeting"
local KeyBind = require "engine.KeyBind"
local Savefile = require "engine.Savefile"
local DamageType = require "engine.DamageType"
local Zone = require "engine.Zone"
local Tiles = require "engine.Tiles"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Birther = require "mod.dialogs.Birther"
local Astar = require "engine.Astar"
local DirectPath = require "engine.DirectPath"
local Shader = require "engine.Shader"

local NicerTiles = require "mod.class.NicerTiles"
local GameState = require "mod.class.GameState"
local Store = require "mod.class.Store"
local Trap = require "mod.class.Trap"
local Grid = require "mod.class.Grid"
local Actor = require "mod.class.Actor"
local Party = require "mod.class.Party"
local Player = require "mod.class.Player"
local NPC = require "mod.class.NPC"

local PlayerDisplay = require "mod.class.PlayerDisplay"

local HotkeysDisplay = require "engine.HotkeysDisplay"
local HotkeysIconsDisplay = require "engine.HotkeysIconsDisplay"
local ActorsSeenDisplay = require "engine.ActorsSeenDisplay"
local LogDisplay = require "engine.LogDisplay"
local LogFlasher = require "engine.LogFlasher"
local DebugConsole = require "engine.DebugConsole"
local FlyingText = require "engine.FlyingText"
local Tooltip = require "mod.class.Tooltip"
local Calendar = require "engine.Calendar"
local Gestures = require "engine.ui.Gestures"

local Dialog = require "engine.ui.Dialog"
local MapMenu = require "mod.dialogs.MapMenu"

module(..., package.seeall, class.inherit(engine.GameTurnBased, engine.interface.GameMusic, engine.interface.GameSound, engine.interface.GameTargeting))

-- Difficulty settings
DIFFICULTY_EASY = 1
DIFFICULTY_NORMAL = 2
DIFFICULTY_NIGHTMARE = 3
DIFFICULTY_INSANE = 4
PERMADEATH_INFINITE = 1
PERMADEATH_MANY = 2
PERMADEATH_ONE = 3

-- Tell the engine that we have a fullscreen shader that supports gamma correction
support_shader_gamma = true

function _M:init()
	engine.GameTurnBased.init(self, engine.KeyBind.new(), 1000, 100)
	engine.interface.GameMusic.init(self)
	engine.interface.GameSound.init(self)

	-- Pause at birth
	self.paused = true

	-- Same init as when loaded from a savefile
	self:loaded()

	self.visited_zones = {}
end

function _M:run()
	local size, size_mono, font, font_mono, font_mono_h, font_h
	local flysize = ({normal=14, small=12, big=16})[config.settings.tome.fonts.size]
	if config.settings.tome.fonts.type == "fantasy" then
		size = ({normal=16, small=14, big=18})[config.settings.tome.fonts.size]
		size_mono = ({normal=14, small=10, big=16})[config.settings.tome.fonts.size]
		font = "/data/font/USENET_.ttf"
		font_mono = "/data/font/SVBasicManual.ttf"
	else
		size = ({normal=12, small=10, big=14})[config.settings.tome.fonts.size]
		size_mono = ({normal=12, small=10, big=14})[config.settings.tome.fonts.size]
		font = "/data/font/Vera.ttf"
		font_mono = "/data/font/VeraMono.ttf"
	end
	local f = core.display.newFont(font, size)
	font_h = f:lineSkip()
	f = core.display.newFont(font_mono, size_mono)
	font_mono_h = f:lineSkip()

	self.delayed_log_damage = {}
	self.calendar = Calendar.new("/data/calendar_allied.lua", "Today is the %s %s of the %s year of the Age of Ascendancy of Maj'Eyal.\nThe time is %02d:%02d.", 122, 167, 11)

	self.player_display = PlayerDisplay.new(0, 200, 200, self.h - 200, {30,30,0}, font_mono, size_mono)
	self.map_h_stop = self.h - 52
	self.logdisplay = LogDisplay.new(216, self.map_h_stop - font_h * config.settings.tome.log_lines -16, (self.w - 216) / 2, font_h * config.settings.tome.log_lines, nil, font, size, nil, nil)
	self.logdisplay.resizeToLines = function() self.logdisplay:resize(216, self.map_h_stop - font_h * config.settings.tome.log_lines -16, (self.w - 216) / 2, font_h * config.settings.tome.log_lines) end
	self.logdisplay:enableShadow(1)
	self.logdisplay:enableFading(config.settings.tome.log_fade or 3)

	profile.chat:resize(216 + (self.w - 216) / 2, self.map_h_stop - font_h * config.settings.tome.log_lines -16, (self.w - 216) / 2, font_h * config.settings.tome.log_lines, font, size, nil, nil)
	profile.chat.resizeToLines = function() profile.chat:resize(216 + (self.w - 216) / 2, self.map_h_stop - font_h * config.settings.tome.log_lines -16, (self.w - 216) / 2, font_h * config.settings.tome.log_lines) end
	profile.chat:enableShadow(1)
	profile.chat:enableFading(config.settings.tome.log_fade or 3)
	profile.chat:enableDisplayChans(false)

	self.hotkeys_display = HotkeysIconsDisplay.new(nil, 216, self.h - 52, self.w - 216, 52, "/data/gfx/ui/talents-list.png", font_mono, size_mono, 48, 48)
	self.hotkeys_display:enableShadow(0.6)
	self.hotkeys_display:setColumns(3)
	self.npcs_display = ActorsSeenDisplay.new(nil, 216, self.h - font_mono_h * 4.2, self.w - 216, font_mono_h * 4.2, "/data/gfx/ui/talents-list.png", font_mono, size_mono)
	self.npcs_display:setColumns(3)
	self.tooltip = Tooltip.new(font_mono, size, {255,255,255}, {30,30,30,230})
	self.tooltip2 = Tooltip.new(font_mono, size, {255,255,255}, {30,30,30,230})
	self.flyers = FlyingText.new("/data/font/INSULA__.ttf", flysize, "/data/font/INSULA__.ttf", flysize + 3)
	self.flyers:enableShadow(0.6)

	self:setFlyingText(self.flyers)
	self.minimap_bg, self.minimap_bg_w, self.minimap_bg_h = core.display.loadImage("/data/gfx/ui/minimap.png"):glTexture()
	self.nicer_tiles = NicerTiles.new()
	self:createSeparators()

	self.log = function(style, ...) if type(style) == "number" then self.logdisplay(...) else self.logdisplay(style, ...) end end
	self.logChat = function(style, ...)
		if true or not config.settings.tome.chat_log then return end
		if type(style) == "number" then
		local old = self.logdisplay.changed
		self.logdisplay(...) else self.logdisplay(style, ...) end
		if self.show_userchat then self.logdisplay.changed = old end
	end
	self.logSeen = function(e, style, ...) if e and e.x and e.y and self.level.map.seens(e.x, e.y) then self.log(style, ...) end end
	self.logPlayer = function(e, style, ...) if e == self.player or e == self.party then self.log(style, ...) end end

	-- List of stuff to do on tick end
	self.on_tick_end = {}

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()

	-- Start time
	self.real_starttime = os.time()

	self:setupDisplayMode(false, "postinit")
	if self.level and self.level.data.day_night then self.state:dayNightCycle() end
	if self.level and self.player then self.calendar = Calendar.new("/data/calendar_"..(self.player.calendar or "allied")..".lua", "Today is the %s %s of the %s year of the Age of Ascendancy of Maj'Eyal.\nThe time is %02d:%02d.", 122, 167, 11) end

	-- Setup inputs
	self:setupCommands()
	self:setupMouse()

	-- Starting from here we create a new game
	if not self.player then self:newGame() end

	self:initTargeting()

	self.hotkeys_display.actor = self.player
	self.npcs_display.actor = self.player

	-- Run the current music if any
	self:onTickEnd(function() self:playMusic() end)

	-- Create the map scroll text overlay
	self.player_display.font:setStyle("bold")
	local s = core.display.drawStringBlendedNewSurface(self.player_display.font, "<Scroll mode, press keys to scroll, caps lock to exit>", unpack(colors.simple(colors.GOLD)))
	self.player_display.font:setStyle("normal")
	self.caps_scroll = {s:glTexture()}
	self.caps_scroll.w, self.caps_scroll.h = s:getSize()
end

--- Checks if the current character is "tainted" by cheating
function _M:isTainted()
	if config.settings.cheat then return true end
	return (game.player and game.player.__cheated) and true or false
end

--- Sets the player name
function _M:setPlayerName(name)
	self.save_name = name
	self.player_name = name
	if self.party and self.party:findMember{main=true} then
		self.party:findMember{main=true}.name = name
	end
end

function _M:newGame()
	self.party = Party.new()
	local player = Player.new{name=self.player_name, game_ender=true}
	self.party:addMember(player, {
		control="full",
		type="player",
		title="Main character",
		main=true,
		orders = {target=true, anchor=true, behavior=true, leash=true, talents=true},
	})
	self.party:setPlayer(player)

	-- Create the entity to store various game state things
	self.state = GameState.new{}
	local birth_done = function()
		if self.player.__allow_rod_recall then game.state:allowRodRecall(true) self.player.__allow_rod_recall = nil end

		for i = 1, 50 do
			local o = self.state:generateRandart(true)
			self.zone.object_list[#self.zone.object_list+1] = o
		end

		if config.settings.cheat then self.player.__cheated = true end

		-- Register the character online if possible
		self.player:getUUID()
		self:updateCurrentChar()
	end

	self.always_target = true
	local nb_unlocks, max_unlocks = self:countBirthUnlocks()
	self.creating_player = true
	local birth; birth = Birther.new("Character Creation ("..nb_unlocks.."/"..max_unlocks.." unlocked birth options)", self.player, {"base", "world", "difficulty", "permadeath", "race", "subrace", "sex", "class", "subclass" }, function(loaded)
		if not loaded then
			self.calendar = Calendar.new("/data/calendar_"..(self.player.calendar or "allied")..".lua", "Today is the %s %s of the %s year of the Age of Ascendancy of Maj'Eyal.\nThe time is %02d:%02d.", 122, 167, 11)
			self.player:check("make_tile")
			self.player.make_tile = nil
			self.player:check("before_starting_zone")
			self.player:check("class_start_check")

			-- Configure & create the worldmap
			self.player.last_wilderness = self.player.default_wilderness[3] or "wilderness"
			game:onLevelLoad(self.player.last_wilderness.."-1", function(zone, level)
				game.player.wild_x, game.player.wild_y = game.player.default_wilderness[1], game.player.default_wilderness[2]
				if type(game.player.wild_x) == "string" and type(game.player.wild_y) == "string" then
					local spot = level:pickSpot{type=game.player.wild_x, subtype=game.player.wild_y} or {x=1,y=1}
					game.player.wild_x, game.player.wild_y = spot.x, spot.y
				end
			end)

			-- Generate
			if self.player.__game_difficulty then self:setupDifficulty(self.player.__game_difficulty) end
			self:setupPermadeath(self.player)
			self:changeLevel(self.player.starting_level or 1, self.player.starting_zone, nil, self.player.starting_level_force_down)

			print("[PLAYER BIRTH] resolve...")
			self.player:resolve()
			self.player:resolve(nil, true)
			self.player.energy.value = self.energy_to_act
			Map:setViewerFaction(self.player.faction)
			self.player:updateModdableTile()

			self.paused = true
			print("[PLAYER BIRTH] resolved!")
			local birthend = function()
				local d = require("engine.dialogs.ShowText").new("Welcome to ToME", "intro-"..self.player.starting_intro, {name=self.player.name}, nil, nil, function()
					self.player:resetToFull()
					self.player:registerCharacterPlayed()
					self.player:onBirth(birth)
					-- For quickbirth
					savefile_pipe:push(self.player.name, "entity", self.party, "engine.CharacterVaultSave")
					self.creating_player = false

					self.player:grantQuest(self.player.starting_quest)

					birth_done()
					self.player:check("on_birth_done")

					if __module_extra_info.birth_done_script then loadstring(__module_extra_info.birth_done_script)() end
				end, true)
				self:registerDialog(d)
				if __module_extra_info.no_birth_popup then d.key:triggerVirtual("EXIT") end
			end

			if self.player.no_birth_levelup or __module_extra_info.no_birth_popup then birthend()
			else self.player:playerLevelup(birthend) end

		-- Player was loaded from a premade
		else
			self.calendar = Calendar.new("/data/calendar_"..(self.player.calendar or "allied")..".lua", "Today is the %s %s of the %s year of the Age of Ascendancy of Maj'Eyal.\nThe time is %02d:%02d.", 122, 167, 11)
			Map:setViewerFaction(self.player.faction)
			if self.player.__game_difficulty then self:setupDifficulty(self.player.__game_difficulty) end
			self:setupPermadeath(self.player)

			-- Configure & create the worldmap
			self.player.last_wilderness = self.player.default_wilderness[3] or "wilderness"
			game:onLevelLoad(self.player.last_wilderness.."-1", function(zone, level)
				game.player.wild_x, game.player.wild_y = game.player.default_wilderness[1], game.player.default_wilderness[2]
				if type(game.player.wild_x) == "string" and type(game.player.wild_y) == "string" then
					local spot = level:pickSpot{type=game.player.wild_x, subtype=game.player.wild_y} or {x=1,y=1}
					game.player.wild_x, game.player.wild_y = spot.x, spot.y
				end
			end)

			-- Tell the level gen code to add all the party
			self.to_re_add_actors = {}
			for act, _ in pairs(self.party.members) do if self.player ~= act then self.to_re_add_actors[act] = true end end

			self:changeLevel(self.player.starting_level or 1, self.player.starting_zone, nil, self.player.starting_level_force_down)
			self.player:grantQuest(self.player.starting_quest)
			self.creating_player = false

			-- Add all items so they regen correctly
			self.player:inventoryApplyAll(function(inven, item, o) game:addEntity(o) end)

			birth_done()
			self.player:check("on_birth_done")
		end
	end, quickbirth, 800, 600)
	self:registerDialog(birth)
end

function _M:setupDifficulty(d)
	self.difficulty = d
end
function _M:setupPermadeath(p)
	if p:attr("infinite_lifes") then self.permadeath = PERMADEATH_INFINITE
	elseif p:attr("easy_mode_lifes") then self.permadeath = PERMADEATH_MANY
	else self.permadeath = PERMADEATH_ONE
	end
end

function _M:loaded()
	engine.GameTurnBased.loaded(self)
	engine.interface.GameMusic.loaded(self)
	engine.interface.GameSound.loaded(self)
	Actor.projectile_class = "mod.class.Projectile"
	Zone:setup{
		npc_class="mod.class.NPC", grid_class="mod.class.Grid", object_class="mod.class.Object", trap_class="mod.class.Trap",
		on_setup = function(zone)
			-- Increases zone level for higher difficulties
			if not zone.__applied_difficulty then
				zone.__applied_difficulty = true
				if self.difficulty == self.DIFFICULTY_INSANE then
					zone.base_level_range = table.clone(zone.level_range, true)
					zone.specific_base_level.object = -10 -zone.level_range[1]
					zone.level_range[1] = zone.level_range[1] * 2 + 10
					zone.level_range[2] = zone.level_range[2] * 2 + 10
				end
			end
		end,
	}
	Zone.check_filter = function(...) return self.state:entityFilter(...) end
	Zone.default_prob_filter = true
	Zone.default_filter = function(...) return self.state:defaultEntityFilter(...) end
	Zone.alter_filter = function(...) return self.state:entityFilterAlter(...) end
	Zone.post_filter = function(...) return self.state:entityFilterPost(...) end
	Map:setViewerActor(self.player)
	self:setupDisplayMode(false, "init")
	self:setupDisplayMode(false, "postinit")
	if self.player then self.player.changed = true end
	self.key = engine.KeyBind.new()

	if self.always_target == true then Map:setViewerFaction(self.player.faction) end
	if self.player and config.settings.cheat then self.player.__cheated = true end
	self:updateCurrentChar()
end

function _M:setupDisplayMode(reboot, mode)
	if not mode or mode == "init" then
		local gfx = config.settings.tome.gfx
		self:saveSettings("tome.gfx", ('tome.gfx = {tiles=%q, size=%q, tiles_custom_dir=%q, tiles_custom_moddable=%s, tiles_custom_adv=%s}\n'):format(gfx.tiles, gfx.size, gfx.tiles_custom_dir or "", gfx.tiles_custom_moddable and "true" or "false", gfx.tiles_custom_adv and "true" or "false"))

		if reboot then
			self.change_res_dialog = true
			self:saveGame()
			util.showMainMenu(false, nil, nil, self.__mod_info.short_name, self.save_name, false)
		end

		Map:resetTiles()
	end

	if not mode or mode == "postinit" then
		local gfx = config.settings.tome.gfx

		-- Select tiles
		Tiles.prefix = "/data/gfx/"..gfx.tiles.."/"
		if config.settings.tome.gfx.tiles == "customtiles" then
			Tiles.prefix = "/data/gfx/"..config.settings.tome.gfx.tiles_custom_dir.."/"
		end
		print("[DISPLAY MODE] Tileset: "..gfx.tiles)
		print("[DISPLAY MODE] Size: "..gfx.size)

		local do_bg = gfx.tiles == "ascii_full"
		local _, _, tw, th = gfx.size:find("^([0-9]+)x([0-9]+)$")
		tw, th = tonumber(tw), tonumber(th)
		if not tw then tw, th = 64, 64 end
		local pot_th = math.pow(2, math.ceil(math.log(th-0.1) / math.log(2.0)))
		local fsize = math.floor( pot_th/th*(0.7 * th + 5) )

		if th <= 20 then
			Map:setViewPort(216, 0, self.w - 216, (self.map_h_stop or 80) - 16, tw, th, "/data/font/FSEX300.ttf", pot_th, do_bg)
		else
			Map:setViewPort(216, 0, self.w - 216, (self.map_h_stop or 80) - 16, tw, th, nil, fsize, do_bg)
		end

		-- Show a count for stacked objects
		Map.object_stack_count = true

		Map.tiles.use_images = true
		if gfx.tiles == "ascii" then
			Map.tiles.use_images = false
			Map.tiles.force_back_color = {r=0, g=0, b=0, a=255}
			Map.tiles.no_moddable_tiles = true
		elseif gfx.tiles == "ascii_full" then
			Map.tiles.use_images = false
			Map.tiles.no_moddable_tiles = true
		elseif gfx.tiles == "shockbolt" then
			Map.tiles.nicer_tiles = true
		elseif gfx.tiles == "oldrpg" then
			Map.tiles.nicer_tiles = true
		elseif gfx.tiles == "customtiles" then
			Map.tiles.no_moddable_tiles = not config.settings.tome.gfx.tiles_custom_moddable
			Map.tiles.nicer_tiles = config.settings.tome.gfx.tiles_custom_adv
		end

		if self.level then
			if self.level.map.finished then
				self.level.map:recreate()
				self.level.map:moveViewSurround(self.player.x, self.player.y, 8, 8)
			end
			self:initTargeting()
		end
		self:setupMiniMap()

		-- Create the framebuffer
		self.fbo = core.display.newFBO(Map.viewport.width, Map.viewport.height)
		if self.fbo then self.fbo_shader = Shader.new("main_fbo") if not self.fbo_shader.shad then self.fbo = nil self.fbo_shader = nil end end
		if self.player then self.player:updateMainShader() end

		self.full_fbo = core.display.newFBO(self.w, self.h)
		if self.full_fbo then self.full_fbo_shader = Shader.new("full_fbo") if not self.full_fbo_shader.shad then self.full_fbo = nil self.full_fbo_shader = nil end end

		self.mm_fbo = core.display.newFBO(200, 200)
		if self.mm_fbo then self.mm_fbo_shader = Shader.new("mm_fbo") if not self.mm_fbo_shader.shad then self.mm_fbo = nil self.mm_fbo_shader = nil end end
	end
end

function _M:initTargeting()
	engine.interface.GameTargeting.init(self)
end


function _M:setupMiniMap()
	if self.level and self.level.map and self.level.map.finished then self.level.map._map:setupMiniMapGridSize(4) end
end

function _M:save()
	self.total_playtime = (self.total_playtime or 0) + (os.time() - (self.last_update or self.real_starttime))
	self.last_update = os.time()
	return class.save(self, self:defaultSavedFields{difficulty=true, permadeath=true, to_re_add_actors=true, party=true, _chronoworlds=true, total_playtime=true, on_level_load_fcts=true, visited_zones=true}, true)
end

function _M:updateCurrentChar()
	if not self.party then return end
	local player = self.party:findMember{main=true}
	profile:currentCharacter(self.__mod_info.version_string, ("%s the level %d %s %s"):format(player.name, player.level, player.descriptor.subrace, player.descriptor.subclass), player.__te4_uuid)
end

function _M:getSaveDescription()
	local player = self.party:findMember{main=true}

	return {
		name = player.name,
		description = ([[%s the level %d %s %s.
Difficulty: %s / %s
Campaign: %s
Exploring level %d of %s.]]):format(
		player.name, player.level, player.descriptor.subrace, player.descriptor.subclass,
		player.descriptor.difficulty, player.descriptor.permadeath,
		player.descriptor.world,
		self.level.level, self.zone.name
		),
	}
end

function _M:getVaultDescription(e)
	e = e:findMember{main=true} -- Because vault "chars" are actualy parties for tome
	return {
		name = ([[%s the %s %s]]):format(e.name, e.descriptor.subrace, e.descriptor.subclass),
		descriptors = e.descriptor,
		description = ([[%s the %s %s.
Difficulty: %s / %s
Campaign: %s]]):format(
		e.name, e.descriptor.subrace, e.descriptor.subclass,
		e.descriptor.difficulty, e.descriptor.permadeath,
		e.descriptor.world
		),
	}
end

function _M:getStore(def)
	return Store.stores_def[def]:clone()
end

function _M:leaveLevel(level, lev, old_lev)
	self.to_re_add_actors = self.to_re_add_actors or {}
	if level:hasEntity(self.player) then
		level.exited = level.exited or {}
		if lev > old_lev then
			level.exited.down = {x=self.player.x, y=self.player.y}
		else
			level.exited.up = {x=self.player.x, y=self.player.y}
		end
		level.last_turn = self.turn
		for act, _ in pairs(self.party.members) do
			if self.player ~= act and level:hasEntity(act) then
				level:removeEntity(act)
				self.to_re_add_actors[act] = true
			end
		end
		level:removeEntity(self.player)
	end
end

function _M:onLevelLoad(id, fct, data)
	if self.zone and self.level and id == self.zone.short_name.."-"..self.level.level then
		print("Direct execute of on level load", id, fct, data)
		fct(self.zone, self.level, data)
		return
	end

	self.on_level_load_fcts = self.on_level_load_fcts or {}
	self.on_level_load_fcts[id] = self.on_level_load_fcts[id] or {}
	local l = self.on_level_load_fcts[id]
	l[#l+1] = {fct=fct, data=data}
	print("Registering on level load", id, fct, data)
end

function _M:changeLevel(lev, zone, keep_old_lev, force_down)
	if not self.player.can_change_level then
		self.logPlayer(self.player, "#LIGHT_RED#You may not change level without your own body!")
		return
	end
	if zone and not self.player.can_change_zone then
		self.logPlayer(self.player, "#LIGHT_RED#You may not leave the zone with this character!")
		return
	end
	if game.player:hasEffect(game.player.EFF_PARADOX_CLONE) or game.player:hasEffect(game.player.EFF_IMMINENT_PARADOX_CLONE) then
		self.logPlayer(self.player, "#LIGHT_RED#You cannot escape your fate by leaving the level!")
		return
	end

	if self.zone and self.level then self.party:leftLevel() end

	if game.player:isTalentActive(game.player.T_JUMPGATE) then
		game.player:forceUseTalent(game.player.T_JUMPGATE, {ignore_energy=true})
	end

	if game.player:isTalentActive(game.player.T_JUMPGATE_TWO) then
		game.player:forceUseTalent(game.player.T_JUMPGATE_TWO, {ignore_energy=true})
	end

	-- clear chrono worlds and their various effects
	if game._chronoworlds then game._chronoworlds = nil end

	if game.player:isTalentActive(game.player.T_DOOR_TO_THE_PAST) then
		game.player:forceUseTalent(game.player.T_DOOR_TO_THE_PAST, {ignore_energy=true})
	end

	local left_zone = self.zone

	if self.zone and self.zone.on_leave then
		local nl, nz, stop = self.zone.on_leave(lev, old_lev, zone)
		if stop then return end
		if nl then lev = nl end
		if nz then zone = nz end
	end

	if self.zone and self.level then self.player:onLeaveLevel(self.zone, self.level) end

	local old_lev = (self.level and not zone) and self.level.level or -1000
	if keep_old_lev then old_lev = self.level.level end
	if zone then
		if self.zone then
			self.zone:leaveLevel(false, lev, old_lev)
			self.zone:leave()
		end
		if type(zone) == "string" then
			self.zone = Zone.new(zone)
		else
			self.zone = zone
		end
		if type(self.zone.save_per_level) == "nil" then self.zone.save_per_level = config.settings.tome.save_zone_levels and true or false end
	end
	self.zone:getLevel(self, lev, old_lev)
	self.visited_zones[self.zone.short_name] = true

	-- Post process walls
	self.nicer_tiles:postProcessLevelTiles(self.level)

	-- Post process if needed once the nicer tiles are done
	if self.level.data and self.level.data.post_nicer_tiles then self.level.data.post_nicer_tiles(self.level) end

	-- Check if we need to switch the current guardian
	self.state:zoneCheckBackupGuardian()

	-- Check if we must do some special things on load of this level
	self.on_level_load_fcts = self.on_level_load_fcts or {}
	print("Running on level loads", self.zone.short_name.."-"..self.level.level)
	for i, fct in ipairs(self.on_level_load_fcts[self.zone.short_name.."-"..self.level.level] or {}) do
		fct.fct(self.zone, self.level, fct.data)
	end
	self.on_level_load_fcts[self.zone.short_name.."-"..self.level.level] = nil

	-- Decay level ?
	if self.level.last_turn and self.level.data.decay and self.level.last_turn + self.level.data.decay[1] * 10 < self.turn then
		local only = self.level.data.decay.only or nil
		if not only or only.actor then
--			local nb_actor, remain_actor = self.level:decay(Map.ACTOR, function(e) return not e.unique and not e.lore and not e.quest and self.level.last_turn + rng.range(self.level.data.decay[1], self.level.data.decay[2]) < self.turn * 10 end)
--			if not self.level.data.decay.no_respawn then
--				local gen = self.zone:getGenerator("actor", self.level)
--				if gen.regenFrom then gen:regenFrom(remain_actor) end
--			end
		end

		if not only or only.object then
			local nb_object, remain_object = self.level:decay(Map.OBJECT, function(e) return not e.unique and not e.lore and not e.quest and self.level.last_turn + rng.range(self.level.data.decay[1], self.level.data.decay[2]) < self.turn * 10 end)
--			if not self.level.data.decay.no_respawn then
--				local gen = self.zone:getGenerator("object", self.level)
--				if gen.regenFrom then gen:regenFrom(remain_object) end
--			end
		end
	end

	-- Move back to old wilderness position
	if self.zone.wilderness then
		self.player:move(self.player.wild_x, self.player.wild_y, true)
		self.player.last_wilderness = self.zone.short_name
	else
		local x, y
		if lev > old_lev and not force_down then
			x, y = self.level.default_up.x, self.level.default_up.y
		else
			x, y = self.level.default_down.x, self.level.default_down.y
		end
		-- Check if there is already an actor at that location, if so move it
		x = x or 1 y = y or 1
		local blocking_actor = self.level.map(x, y, engine.Map.ACTOR)
		if blocking_actor then
			local newx, newy = util.findFreeGrid(x, y, 20, true, {[Map.ACTOR]=true})
			if newx and newy then blocking_actor:move(newx, newy, true)
			else blocking_actor:teleportRandom(x, y, 200) end
		end
		self.player:move(x, y, true)
	end
	self.player.changed = true
	if self.to_re_add_actors and not self.zone.wilderness then for act, _ in pairs(self.to_re_add_actors) do
		local x, y = util.findFreeGrid(self.player.x, self.player.y, 20, true, {[Map.ACTOR]=true})
		if x then act:move(x, y, true) end
	end end

	-- Re add entities
	self.level:addEntity(self.player)
	if self.to_re_add_actors and not self.zone.wilderness then
		for act, _ in pairs(self.to_re_add_actors) do
			self.level:addEntity(act)
			act:setTarget(nil)
			if act.ai_state and act.ai_state.tactic_leash_anchor then
				act.ai_state.tactic_leash_anchor = game.player
			end
		end
		self.to_re_add_actors = nil
	end

	if self.zone.on_enter then
		self.zone.on_enter(lev, old_lev, zone)
	end

	self.player:onEnterLevel(self.zone, self.level)

	local musics = {}
	local keep_musics = false
	if self.level.data.ambient_music then
		if self.level.data.ambient_music ~= "last" then
			if type(self.level.data.ambient_music) == "string" then musics[#musics+1] = self.level.data.ambient_music
			elseif type(self.level.data.ambient_music) == "table" then for i, name in ipairs(self.level.data.ambient_music) do musics[#musics+1] = name end
			elseif type(self.level.data.ambient_music) == "function" then for i, name in ipairs{self.level.data.ambient_music()} do musics[#musics+1] = name end
			end
		elseif self.level.data.ambient_music == "last" then
			keep_musics = true
		end
	end
	if not keep_musics then self:playAndStopMusic(unpack(musics)) end

	-- Update the minimap
	self:setupMiniMap()

	-- Tell the map to use path strings to speed up path calculations
	for uid, e in pairs(self.level.entities) do
		if e.getPathString then
			self.level.map:addPathString(e:getPathString())
		end
	end
	self.zone_name_s = nil

	-- Level feeling
	local feeling
	if self.level.special_feeling then
		feeling = self.level.special_feeling
	else
		local lev = self.zone.base_level + self.level.level - 1
		if self.zone.level_adjust_level then lev = self.zone:level_adjust_level(self.level) end
		local diff = lev - game.player.level
		if diff >= 5 then feeling = "You feel a thrill of terror and your heart begins to pound in your chest. You feel terribly threatened upon entering this area."
		elseif diff >= 2 then feeling = "You feel mildly anxious, and walk with caution."
		elseif diff >= -2 then feeling = nil
		elseif diff >= -5 then feeling = "You feel very confident walking into this place."
		else feeling = "You stride into this area without a second thought, while stifling a yawn. You feel your time might be better spent elsewhere."
		end
	end
	if feeling then game.log("#TEAL#%s", feeling) end

	-- Autosave
	if config.settings.tome.autosave and not config.settings.cheat and ((left_zone and left_zone.short_name ~= "wilderness") or self.zone.save_per_level) and (left_zone and left_zone.short_name ~= self.zone.short_name) then self:saveGame() end

	self.player:onEnterLevelEnd(self.zone, self.level)

	-- Day/Night cycle
	if self.level.data.day_night then self.state:dayNightCycle() end

	self.level.map:redisplay()
	self.level.map:reopen()
end

function _M:getPlayer(main)
	if main then
		return self.party:findMember{main=true}
	else
		return self.player
	end
end

--- Clones the game world for chronomancy spells
function _M:chronoClone(name)
	local d = Dialog:simplePopup("Chronomancy", "Folding the space time structure...")
	d.__showup = nil
	core.display.forceRedraw()
	game:unregisterDialog(d)

	if name then
		self._chronoworlds = self._chronoworlds or {}
		self._chronoworlds[name] = game:cloneFull()
	else
		return game:cloneFull()
	end
end

--- Restores a chronomancy clone
function _M:chronoRestore(name, remove)
	local ngame
	if type(name) == "string" then
		ngame = self._chronoworlds[name]
		if remove then self._chronoworlds[name] = nil end
	else ngame = name end
	if not ngame then return false end

	local d = Dialog:simplePopup("Chronomancy", "Unfolding the space time structure...")
	d.__showup = nil
	core.display.forceRedraw()
	game:unregisterDialog(d)

	ngame:cloneReloaded()
	_G.game = ngame
	game:run()
	game.key:setCurrent()
	game.mouse:setCurrent()
	profile.chat:setupOnGame()
	return true
end

--- Update the zone name, if needed
function _M:updateZoneName()
	local name
	if self.zone.display_name then
		name = self.zone.display_name()
	else
		local lev = self.level.level
		if self.level.data.reverse_level_display then lev = 1 + self.level.data.max_level - lev end
		name = ("%s (%d)"):format(self.zone.name, lev)
	end
	if self.zone_name_s and self.old_zone_name == name then return end

	self.player_display.font:setStyle("bold")
	local s = core.display.drawStringBlendedNewSurface(self.player_display.font, name, unpack(colors.simple(colors.GOLD)))
	self.player_display.font:setStyle("normal")
	self.zone_name_w, self.zone_name_h = s:getSize()
	self.zone_name_s, self.zone_name_tw, self.zone_name_th = s:glTexture()
	self.old_zone_name = name
	print("Updating zone name", name)
end

function _M:tick()
	if self.level then
		self:targetOnTick()

		engine.GameTurnBased.tick(self)
		-- Fun stuff: this can make the game realtime, although calling it in display() will make it work better
		-- (since display is on a set FPS while tick() ticks as much as possible
		-- engine.GameEnergyBased.tick(self)
	end

	-- Run tick end stuff
	if #self.on_tick_end > 0 then
		local fs = self.on_tick_end
		self.on_tick_end = {}
		for i = 1, #fs do fs[i]() end
	end

	-- Check damages to log
	self:displayDelayedLogDamage()

	if savefile_pipe.saving then self.player.changed = true end
	if self.paused and not savefile_pipe.saving then return true end
end

function _M:displayDelayedLogDamage()
	for src, tgts in pairs(self.delayed_log_damage) do
		for target, dams in pairs(tgts) do
			if #dams.descs > 1 then
				game.logSeen(target, "%s hits %s for %s damage (total %0.2f).", src.name:capitalize(), target.name, table.concat(dams.descs, ", "), dams.total)
			else
				game.logSeen(target, "%s hits %s for %s damage.", src.name:capitalize(), target.name, table.concat(dams.descs, ", "))
			end

			local rsrc = src.resolveSource and src:resolveSource() or src
			local rtarget = target.resolveSource and target:resolveSource() or target
			local x, y = target.x or -1, target.y or -1
			local sx, sy = game.level.map:getTileToScreen(x, y)
			if target.dead then
				if game.level.map.seens(x, y) and (rsrc == game.player or rtarget == game.player or game.party:hasMember(rsrc) or game.party:hasMember(rtarget)) then
					game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, rng.float(-2.5, -1.5), ("Kill (%d)!"):format(dams.total), {255,0,255}, true)
				end
			else
				if game.level.map.seens(x, y) and (rsrc == game.player or game.party:hasMember(rsrc)) then
					game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, rng.float(-3, -2), tostring(-math.ceil(dams.total)), {0,255,0})
				elseif game.level.map.seens(x, y) and (rtarget == game.player or game.party:hasMember(rtarget)) then
					game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -rng.float(-3, -2), tostring(-math.ceil(dams.total)), {255,0,0})
				end
			end
		end
	end
	self.delayed_log_damage = {}
end

function _M:delayedLogDamage(src, target, dam, desc)
	self.delayed_log_damage[src] = self.delayed_log_damage[src] or {}
	self.delayed_log_damage[src][target] = self.delayed_log_damage[src][target] or {total=0, descs={}}
	local t = self.delayed_log_damage[src][target]
	t.descs[#t.descs+1] = desc
	t.total = t.total + dam
end

--- Register things to do on tick end
-- This is used for recall spells to let the tick finish before switching levels
function _M:onTickEnd(f)
	self.on_tick_end[#self.on_tick_end+1] = f
end

--- Called every game turns
-- Does nothing, you can override it
function _M:onTurn()
	if self.zone then
		if self.zone.on_turn then self.zone:on_turn() end
	end

	-- The following happens only every 10 game turns (once for every turn of 1 mod speed actors)
	if self.turn % 10 ~= 0 then return end

	-- Day/Night cycle
	if self.level.data.day_night then self.state:dayNightCycle() end

	-- Process overlay effects
	self.level.map:processEffects()

	if not self.day_of_year or self.day_of_year ~= self.calendar:getDayOfYear(self.turn) then
		self.log(self.calendar:getTimeDate(self.turn))
		self.day_of_year = self.calendar:getDayOfYear(self.turn)
	end
end

function _M:updateFOV()
	self.player:playerFOV()
end

function _M:display(nb_keyframes)
	-- If switching resolution, blank everything but the dialog
	if self.change_res_dialog then engine.GameTurnBased.display(self, nb_keyframes) return end

	if self.full_fbo then self.full_fbo:use(true) end

	-- Now the map, if any
	if self.level and self.level.map and self.level.map.finished then
		local map = self.level.map

		-- Display the map and compute FOV for the player if needed
		local changed = map.changed
		if changed then self:updateFOV() end

		-- Display using Framebuffer, so that we can use shaders and all
		if self.fbo then
			self.fbo:use(true)
				if self.level.data.background then self.level.data.background(self.level, 0, 0, nb_keyframes) end
				map:display(0, 0, nb_keyframes, config.settings.tome.smooth_fov)
				if self.level.data.foreground then self.level.data.foreground(self.level, 0, 0, nb_keyframes) end
				if self.level.data.weather_particle then self.state:displayWeather(self.level, self.level.data.weather_particle, nb_keyframes) end
				if config.settings.tome.smooth_fov then map._map:drawSeensTexture(0, 0, nb_keyframes) end
			self.fbo:use(false, self.full_fbo)

			_2DNoise:bind(1, false)
			self.fbo:toScreen(map.display_x, map.display_y, map.viewport.width, map.viewport.height, self.fbo_shader.shad)
			if self.target then self.target:display() end

		-- Basic display; no FBOs
		else
			if self.level.data.background then self.level.data.background(self.level, map.display_x, map.display_y, nb_keyframes) end
			map:display(nil, nil, nb_keyframes)
			if self.target then self.target:display() end
			if self.level.data.foreground then self.level.data.foreground(self.level, map.display_x, map.display_y, nb_keyframes) end
			if self.level.data.weather_particle then self.state:displayWeather(self.level, self.level.data.weather_particle, nb_keyframes) end
		end

		if not self.zone_name_s then self:updateZoneName() end
		self.zone_name_s:toScreenFull(
			map.display_x + map.viewport.width - self.zone_name_w - 15,
--			map.display_y + map.viewport.height - self.zone_name_h - 5,
			map.display_y + 5,
			self.zone_name_w, self.zone_name_h,
			self.zone_name_tw, self.zone_name_th
		)

		-- emotes display
		map:displayEmotes(nb_keyframe or 1)

		-- Minimap display
--		if self.mm_fbo then
--			self.mm_fbo:use(true)
--			self.minimap_scroll_x, self.minimap_scroll_y = util.bound(self.player.x - 25, 0, map.w - 50), util.bound(self.player.y - 25, 0, map.h - 50)
--			map:minimapDisplay(0, 0, self.minimap_scroll_x, self.minimap_scroll_y, 50, 50, 1)
--			self.mm_fbo:use(false, self.full_fbo)
--			self.minimap_bg:toScreen(0, 0, 200, 200)
--			self.mm_fbo:toScreen(0, 0, 200, 200, self.mm_fbo_shader.shad)
--		else
			self.minimap_bg:toScreen(0, 0, 200, 200)
			self.minimap_scroll_x, self.minimap_scroll_y = util.bound(self.player.x - 25, 0, map.w - 50), util.bound(self.player.y - 25, 0, map.h - 50)
			map:minimapDisplay(0, 0, self.minimap_scroll_x, self.minimap_scroll_y, 50, 50, 1)
--		end

		-- Mouse gestures
		self.gestures:update()
		self.gestures:display(map.display_x, map.display_y + map.viewport.height - self.gestures.font_h - 5)

		-- Inform the player that map is in scroll mode
		if core.key.modState("caps") then
			local w = map.viewport.width * 0.5
			local h = w * self.caps_scroll.h / self.caps_scroll.w
			self.caps_scroll[1]:toScreenFull(
				map.display_x + (map.viewport.width - w) / 2,
				map.display_y + (map.viewport.height - h) / 2,
				w, h,
				self.caps_scroll[2] * w / self.caps_scroll.w, self.caps_scroll[3] * h / self.caps_scroll.h,
				1, 1, 1, 0.5
			)
		end
	end

	-- We display the player's interface
	profile.chat:toScreen()
	self.logdisplay:toScreen()

	self.player_display:toScreen(nb_keyframes)
	if self.show_npc_list then
		self.npcs_display:toScreen()
	else
		self.hotkeys_display:toScreen()
	end
	if self.player then self.player.changed = false end

	-- UI
	self:displayUI()

	engine.GameTurnBased.display(self, nb_keyframes)

	-- Tooltip is displayed over all else, even dialogs
	local mx, my, button = core.mouse.get()

	if self.tooltip.w and mx > self.w - self.tooltip.w and my > self.h - self.tooltip.h then
		self:targetDisplayTooltip(Map.display_x, self.h)
	else
		self:targetDisplayTooltip(self.w, self.h)
	end

	if self.full_fbo then
		self.full_fbo:use(false)
		self.full_fbo:toScreen(0, 0, self.w, self.h, self.full_fbo_shader.shad)
	end
end

--- Called when a dialog is registered to appear on screen
function _M:onRegisterDialog(d)
	-- Clean up tooltip
	self.tooltip_x, self.tooltip_y = nil, nil
	self.tooltip2_x, self.tooltip2_y = nil, nil
	if self.player then self.player:updateMainShader() end
end
function _M:onUnregisterDialog(d)
	-- Clean up tooltip
	self.tooltip_x, self.tooltip_y = nil, nil
	self.tooltip2_x, self.tooltip2_y = nil, nil
	if self.player then self.player:updateMainShader() self.player.changed = true end
end

function _M:setupCommands()
	-- Make targeting work
	self.normal_key = self.key
	self:targetSetupKey()

	-- Activate profiler keybinds
	self.key:setupProfiler()

	-- Activate mouse gestures
	self.gestures = Gestures.new("Gesture: ", self.key, true)

	-- Helper function to not allow some actions on the wilderness map
	local not_wild = function(f) return function() if self.zone and not self.zone.wilderness then f() else self.logPlayer(self.player, "You cannot do that on the world map.") end end end

	-- Debug mode
	self.key:addCommands{
		[{"_q","ctrl"}] = function() if config.settings.cheat then game:registerDialog(require("mod.dialogs.debug.DebugMain").new()) end end,
		[{"_d","ctrl"}] = function() if config.settings.cheat then
			local g = game.level.map(game.player.x, game.player.y, Map.TERRAIN)
			print(g.define_as, g.image, g.z)
			for i, a in ipairs(g.add_mos or {}) do print(" => ", a.image) end
			local add = g.add_displays
			if add then for i, e in ipairs(add) do
				print(" -", e.image, e.z)
				for i, a in ipairs(e.add_mos or {}) do print("   => ", a.image) end
			end end
		end end,
		[{"_g","ctrl"}] = function() if config.settings.cheat then
			self.state:debugRandomZone()
		end end,
		[{"_f","ctrl"}] = function() if config.settings.cheat then
			for i, e in ipairs(mod.class.Object:loadList("/data/general/objects/brotherhood-artifacts.lua")) do if e.name then
				local e = e:clone()
				e:resolve() e:resolve(nil, true)
				game.zone:addEntity(game.level, e, "object", game.player.x,game.player.y)
			end end
		end end,
	}

	self.key.any_key = function(sym)
		-- Control resets the tooltip
		if sym == self.key._LCTRL or sym == self.key._RCTRL then
			self.player.changed = true
			self.tooltip.old_tmx = nil
		elseif sym == self.key._LSHIFT or sym == self.key._RSHIFT then
			self.player.changed = true
		end
	end
	self.key:addBinds
	{
		-- Movements
		MOVE_LEFT = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(4) else self.player:moveDir(4) end end,
		MOVE_RIGHT = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(6) else self.player:moveDir(6) end end,
		MOVE_UP = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(8) else self.player:moveDir(8) end end,
		MOVE_DOWN = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(2) else self.player:moveDir(2) end end,
		MOVE_LEFT_UP = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(7) else self.player:moveDir(7) end end,
		MOVE_LEFT_DOWN = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(1) else self.player:moveDir(1) end end,
		MOVE_RIGHT_UP = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(9) else self.player:moveDir(9) end end,
		MOVE_RIGHT_DOWN = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(3) else self.player:moveDir(3) end end,
		MOVE_STAY = function() if core.key.modState("caps") and self.level then self.level.map:centerViewAround(self.player.x, self.player.y) else if self.player:enoughEnergy() then self.player:describeFloor(self.player.x, self.player.y) self.player:useEnergy() end end end,

		RUN = function()
			game.log("Run in which direction?")
			local co = coroutine.create(function()
				local x, y = self.player:getTarget{type="hit", no_restrict=true, range=1, immediate_keys=true, default_target=self.player}
				if x and y then self.player:runInit(util.getDir(x, y, self.player.x, self.player.y)) end
			end)
			local ok, err = coroutine.resume(co)
			if not ok and err then print(debug.traceback(co)) error(err) end
		end,
		RUN_LEFT = function() self.player:runInit(4) end,
		RUN_RIGHT = function() self.player:runInit(6) end,
		RUN_UP = function() self.player:runInit(8) end,
		RUN_DOWN = function() self.player:runInit(2) end,
		RUN_LEFT_UP = function() self.player:runInit(7) end,
		RUN_LEFT_DOWN = function() self.player:runInit(1) end,
		RUN_RIGHT_UP = function() self.player:runInit(9) end,
		RUN_RIGHT_DOWN = function() self.player:runInit(3) end,

		-- Hotkeys
		HOTKEY_1 = not_wild(function() self.player:activateHotkey(1) end),
		HOTKEY_2 = not_wild(function() self.player:activateHotkey(2) end),
		HOTKEY_3 = not_wild(function() self.player:activateHotkey(3) end),
		HOTKEY_4 = not_wild(function() self.player:activateHotkey(4) end),
		HOTKEY_5 = not_wild(function() self.player:activateHotkey(5) end),
		HOTKEY_6 = not_wild(function() self.player:activateHotkey(6) end),
		HOTKEY_7 = not_wild(function() self.player:activateHotkey(7) end),
		HOTKEY_8 = not_wild(function() self.player:activateHotkey(8) end),
		HOTKEY_9 = not_wild(function() self.player:activateHotkey(9) end),
		HOTKEY_10 = not_wild(function() self.player:activateHotkey(10) end),
		HOTKEY_11 = not_wild(function() self.player:activateHotkey(11) end),
		HOTKEY_12 = not_wild(function() self.player:activateHotkey(12) end),
		HOTKEY_SECOND_1 = not_wild(function() self.player:activateHotkey(13) end),
		HOTKEY_SECOND_2 = not_wild(function() self.player:activateHotkey(14) end),
		HOTKEY_SECOND_3 = not_wild(function() self.player:activateHotkey(15) end),
		HOTKEY_SECOND_4 = not_wild(function() self.player:activateHotkey(16) end),
		HOTKEY_SECOND_5 = not_wild(function() self.player:activateHotkey(17) end),
		HOTKEY_SECOND_6 = not_wild(function() self.player:activateHotkey(18) end),
		HOTKEY_SECOND_7 = not_wild(function() self.player:activateHotkey(19) end),
		HOTKEY_SECOND_8 = not_wild(function() self.player:activateHotkey(20) end),
		HOTKEY_SECOND_9 = not_wild(function() self.player:activateHotkey(21) end),
		HOTKEY_SECOND_10 = not_wild(function() self.player:activateHotkey(22) end),
		HOTKEY_SECOND_11 = not_wild(function() self.player:activateHotkey(23) end),
		HOTKEY_SECOND_12 = not_wild(function() self.player:activateHotkey(24) end),
		HOTKEY_THIRD_1 = not_wild(function() self.player:activateHotkey(25) end),
		HOTKEY_THIRD_2 = not_wild(function() self.player:activateHotkey(26) end),
		HOTKEY_THIRD_3 = not_wild(function() self.player:activateHotkey(27) end),
		HOTKEY_THIRD_4 = not_wild(function() self.player:activateHotkey(28) end),
		HOTKEY_THIRD_5 = not_wild(function() self.player:activateHotkey(29) end),
		HOTKEY_THIRD_6 = not_wild(function() self.player:activateHotkey(30) end),
		HOTKEY_THIRD_7 = not_wild(function() self.player:activateHotkey(31) end),
		HOTKEY_THIRD_8 = not_wild(function() self.player:activateHotkey(32) end),
		HOTKEY_THIRD_9 = not_wild(function() self.player:activateHotkey(33) end),
		HOTKEY_THIRD_10 = not_wild(function() self.player:activateHotkey(34) end),
		HOTKEY_THIRD_11 = not_wild(function() self.player:activateHotkey(35) end),
		HOTKEY_THIRD_12 = not_wild(function() self.player:activateHotkey(36) end),
		HOTKEY_PREV_PAGE = not_wild(function() self.player:prevHotkeyPage() self.log("Hotkey page %d is now displayed.", self.player.hotkey_page) end),
		HOTKEY_NEXT_PAGE = not_wild(function() self.player:nextHotkeyPage() self.log("Hotkey page %d is now displayed.", self.player.hotkey_page) end),

		-- Party commands
		SWITCH_PARTY_1 = not_wild(function() self.party:select(1) end),
		SWITCH_PARTY_2 = not_wild(function() self.party:select(2) end),
		SWITCH_PARTY_3 = not_wild(function() self.party:select(3) end),
		SWITCH_PARTY_4 = not_wild(function() self.party:select(4) end),
		SWITCH_PARTY_5 = not_wild(function() self.party:select(5) end),
		SWITCH_PARTY_6 = not_wild(function() self.party:select(6) end),
		SWITCH_PARTY_7 = not_wild(function() self.party:select(7) end),
		SWITCH_PARTY_8 = not_wild(function() self.party:select(8) end),
		SWITCH_PARTY = not_wild(function() self:registerDialog(require("mod.dialogs.PartySelect").new()) end),
		ORDER_PARTY_1 = not_wild(function() self.party:giveOrders(1) end),
		ORDER_PARTY_2 = not_wild(function() self.party:giveOrders(2) end),
		ORDER_PARTY_3 = not_wild(function() self.party:giveOrders(3) end),
		ORDER_PARTY_4 = not_wild(function() self.party:giveOrders(4) end),
		ORDER_PARTY_5 = not_wild(function() self.party:giveOrders(5) end),
		ORDER_PARTY_6 = not_wild(function() self.party:giveOrders(6) end),
		ORDER_PARTY_7 = not_wild(function() self.party:giveOrders(7) end),
		ORDER_PARTY_8 = not_wild(function() self.party:giveOrders(8) end),

		-- Actions
		CHANGE_LEVEL = function()
			local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
			if self.player:enoughEnergy() and e.change_level then
				if self.player:attr("never_move") then self.log("You cannot currently leave the level.") return end

				local stop = {}
				for eff_id, p in pairs(self.player.tmp) do
					local e = self.player.tempeffect_def[eff_id]
					if e.status == "detrimental" and not e.no_stop_enter_worlmap then stop[#stop+1] = e.desc end
				end

				if e.change_zone and #stop > 0 and e.change_zone:find("^wilderness") then
					self.log("You cannot go into the wilds with the following effects: %s", table.concat(stop, ", "))
				else
					-- Do not unpause, the player is allowed first move on next level
					if e.change_level_check and e:change_level_check(game.player) then return end
					self:changeLevel(e.change_zone and e.change_level or self.level.level + e.change_level, e.change_zone, e.keep_old_lev, e.force_down)
				end
			else
				self.log("There is no way out of this level here.")
			end
		end,

		REST = function()
			self.player:restInit()
		end,

		PICKUP_FLOOR = not_wild(function()
			if self.player.no_inventory_access then return end
			self.player:playerPickup()
		end),
		DROP_FLOOR = function()
			if self.player.no_inventory_access then return end
			self.player:playerDrop()
		end,
		SHOW_INVENTORY = function()
			if self.player.no_inventory_access then return end
			local d
			local titleupdator = self.player:getEncumberTitleUpdator("Inventory")
			d = self.player:showEquipInven(titleupdator(), nil, function(o, inven, item, button, event)
				if not o then return end
				local ud = require("mod.dialogs.UseItemDialog").new(event == "button", self.player, o, item, inven, function(_, _, _, stop)
					d:generate()
					d:generateList()
					d:updateTitle(titleupdator())
					if stop then self:unregisterDialog(d) end
				end)
				self:registerDialog(ud)
			end)
		end,
		SHOW_EQUIPMENT = "SHOW_INVENTORY",
		WEAR_ITEM = function()
			if self.player.no_inventory_access then return end
			self.player:playerWear()
		end,
		TAKEOFF_ITEM = function()
			if self.player.no_inventory_access then return end
			self.player:playerTakeoff()
		end,
		USE_ITEM = not_wild(function()
			if self.player.no_inventory_access then return end
			self.player:playerUseItem()
		end),

		QUICK_SWITCH_WEAPON = function()
			if self.player.no_inventory_access then return end
			self.player:quickSwitchWeapons()
		end,

		USE_TALENTS = not_wild(function()
			self:registerDialog(require("mod.dialogs.UseTalents").new(self.player))
		end),

		LEVELUP = function()
			self.player:playerLevelup()
		end,

		SAVE_GAME = function()
			self:saveGame()
		end,

		SHOW_QUESTS = function()
			self:registerDialog(require("engine.dialogs.ShowQuests").new(self.party:findMember{main=true}))
		end,

		SHOW_CHARACTER_SHEET = function()
			self:registerDialog(require("mod.dialogs.CharacterSheet").new(self.player))
		end,

		SHOW_MESSAGE_LOG = function()
			self:registerDialog(require("mod.dialogs.ShowChatLog").new("Message Log", 0.6, self.logdisplay, profile.chat))
		end,

		-- Show time
		SHOW_TIME = function()
			self.log(self.calendar:getTimeDate(self.turn))
		end,
		-- Exit the game
		QUIT_GAME = function()
			self:onQuit()
		end,
		-- Lua console
		LUA_CONSOLE = function()
			if config.settings.cheat then
				self:registerDialog(DebugConsole.new())
			end
		end,

		-- Toggle monster list
		TOGGLE_NPC_LIST = function()
			self.show_npc_list = not self.show_npc_list
			self.player.changed = true
		end,

		HELP = "EXIT",
		EXIT = function()
			local menu menu = require("engine.dialogs.GameMenu").new{
				"resume",
				"achievements",
				{ "Show known Lore", function() game:unregisterDialog(menu) game:registerDialog(require("mod.dialogs.ShowLore").new("Tales of Maj'Eyal Lore", self.player)) end },
				{ "Inventory", function() game:unregisterDialog(menu) self.key:triggerVirtual("SHOW_INVENTORY") end },
				{ "Character Sheet", function() game:unregisterDialog(menu) self.key:triggerVirtual("SHOW_CHARACTER_SHEET") end },
				"keybinds",
				{"Graphic Mode", function() game:unregisterDialog(menu) game:registerDialog(require("mod.dialogs.GraphicMode").new()) end},
				{"Game Options", function() game:unregisterDialog(menu) game:registerDialog(require("mod.dialogs.GameOptions").new()) end},
				"video",
				"sound",
				"save",
				"quit"
			}
			self:registerDialog(menu)
		end,

		TACTICAL_DISPLAY = function()
			if self.always_target == true then
				self.always_target = "health"
				Map:setViewerFaction(nil)
				game.log("Showing healthbars only.")
			elseif self.always_target == nil then
				self.always_target = true
				Map:setViewerFaction(self.player.faction)
				game.log("Showing healthbars and tactical borders.")
			elseif self.always_target == "health" then
				self.always_target = nil
				Map:setViewerFaction(nil)
				game.log("Showing no tactical information.")
			end
		end,

		LOOK_AROUND = function()
			self.log("Looking around... (direction keys to select interesting things, shift+direction keys to move freely)")
			local co = coroutine.create(function() self.player:getTarget{type="hit", no_restrict=true, range=2000} end)
			local ok, err = coroutine.resume(co)
			if not ok and err then print(debug.traceback(co)) error(err) end
		end,

		USERCHAT_SHOW_TALK = function()
			self.show_userchat = not self.show_userchat
		end
	}

	self.key:setCurrent()
end

function _M:setupMouse(reset)
	if reset then self.mouse:reset() end
	self.mouse:registerZone(Map.display_x, Map.display_y, Map.viewport.width, Map.viewport.height, function(button, mx, my, xrel, yrel, bx, by, event, extra)
		self.tooltip.add_map_str = extra and extra.log_str

		-- Handle targeting
		if self:targetMouse(button, mx, my, xrel, yrel, event) then return end

		-- Handle Use menu
		if button == "right" then
			if event == "motion" then
				self.gestures:changeMouseButton(true)
				self.gestures:mouseMove(mx, my)
			elseif event == "button" then
				if not self.gestures:isGesturing() then
					if not xrel and not yrel then
						-- Handle Use menu
						self:mouseRightClick(mx, my, extra)
						return
					end
				else
					self.gestures:changeMouseButton(false)
					self.gestures:useGesture()
					self.gestures:reset()
				end
			end
		end

		-- Default left button action
		if button == "left" and not xrel and not yrel and event == "button" and self.zone and not self.zone.wilderness then if self:mouseLeftClick(mx, my) then return end end

		-- Default middle button action
		if button == "middle" and not xrel and not yrel and event == "button" and self.zone and not self.zone.wilderness then if self:mouseMiddleClick(mx, my) then return end end

		-- Handle the mouse movement/scrolling
		self.player:mouseHandleDefault(self.key, self.key == self.normal_key, button, mx, my, xrel, yrel, event)
	end, nil, "playmap")
	-- Scroll message log
	self.mouse:registerZone(profile.chat.display_x, profile.chat.display_y, profile.chat.w, profile.chat.h, function(button, mx, my, xrel, yrel, bx, by, event)
		profile.chat.mouse:delegate(button, mx, my, xrel, yrel, bx, by, event)
	end)
	-- Use hotkeys with mouse
	self.mouse:registerZone(self.hotkeys_display.display_x, self.hotkeys_display.display_y, self.w, self.h, function(button, mx, my, xrel, yrel, bx, by, event)
		if self.show_npc_list then return end
		if event == "button" and button == "left" and ((self.zone and self.zone.wilderness) or (self.key ~= self.normal_key)) then return end
		self.hotkeys_display:onMouse(button, mx, my, event == "button",
			function(text)
				text = text:toTString()
				text:add(true, "---", true, {"font","italic"}, {"color","GOLD"}, "Left click to use", true, "Right click to configure", true, "Press 'm' to setup", {"color","LAST"}, {"font","normal"})
				self:tooltipDisplayAtMap(self.w, self.h, text)
			end,
			function(i, hk)
				if button == "right" and hk[1] == "talent" then
					local d = require("mod.dialogs.UseTalents").new(self.player)
					d:use({talent=hk[2], name=self.player:getTalentFromId(hk[2]).name}, "right")
					return true
				end
			end
		)
	end)
	-- Use icons
	self.mouse:registerZone(self.icons.display_x, self.icons.display_y, self.icons.w, self.icons.h, function(button, mx, my, xrel, yrel, bx, by)
		self:mouseIcon(bx, by)
		if button == "left" then self:clickIcon(bx, by) end
	end)
	-- Tooltip over the player pane
	self.mouse:registerZone(self.player_display.display_x, self.player_display.display_y, self.player_display.w, self.player_display.h - self.icons.h, function(button, mx, my, xrel, yrel, bx, by, event)
		self.player_display.mouse:delegate(button, mx, my, xrel, yrel, bx, by, event)
	end)
	-- Move using the minimap
	self.mouse:registerZone(0, 0, 200, 200, function(button, mx, my, xrel, yrel, bx, by, event)
		if button == "left" and not xrel and not yrel and event == "button" then
			local tmx, tmy = math.floor(bx / 4), math.floor(by / 4)
			self.player:mouseMove(tmx + self.minimap_scroll_x, tmy + self.minimap_scroll_y)
		elseif button == "right" then
			local tmx, tmy = math.floor(bx / 4), math.floor(by / 4)
			game.level.map:moveViewSurround(tmx + self.minimap_scroll_x, tmy + self.minimap_scroll_y, 1000, 1000)
		end
	end)
	-- Chat tooltips
	profile.chat:onMouse(function(user, item, button, event, x, y, xrel, yrel, bx, by)
		local mx, my = core.mouse.get()
		if not item or not user or item.faded == 0 then self.mouse:delegate(button, mx, my, xrel, yrel, nil, nil, event, "playmap") return end

		local str = tstring{{"color","GOLD"}, {"font","bold"}, user.name, {"color","LAST"}, {"font","normal"}, true}
		str:add({"color","ANTIQUE_WHITE"}, "Playing: ", {"color", "LAST"}, user.current_char, true)
		str:add({"color","ANTIQUE_WHITE"}, "Game: ", {"color", "LAST"}, user.module, "(", user.valid, ")",true)

		local extra = {}
		if item.extra_data and item.extra_data.mode == "tooltip" then
			local rstr = tstring{item.extra_data.tooltip, true, "---", true, "Linked by: "}
			rstr:merge(str)
			extra.log_str = rstr
		else
			extra.log_str = str
			if button == "right" and event == "button" then
				extra.add_map_action = { name="Show chat user", fct=function() profile.chat:showUserInfo(user.login) end }
			end
		end
		self.mouse:delegate(button, mx, my, xrel, yrel, nil, nil, event, "playmap", extra)
	end)
	if not reset then self.mouse:setCurrent() end
end

--- Left mouse click on the map
function _M:mouseLeftClick(mx, my)
	local tmx, tmy = self.level.map:getMouseTile(mx, my)
	local p = self.player
	local a = game.level.map(tmx, tmy, Map.ACTOR)
	if not a then return end
	if not p.auto_shoot_talent then return end
	local t = p:getTalentFromId(p.auto_shoot_talent)
	if not t then return end

	local target_dist = math.floor(core.fov.distance(p.x, p.y, a.x, a.y))

	if p:enoughEnergy() and p:reactionToward(a) < 0 and not p:isTalentCoolingDown(t) and p:preUseTalent(t, true, true) and target_dist <= p:getTalentRange(t) and p:canProject({type="hit"}, a.x, a.y) then
		p:useTalent(t.id, nil, nil, nil, a)
		return true
	end
end

--- Middle mouse click on the map
function _M:mouseMiddleClick(mx, my)
	local tmx, tmy = self.level.map:getMouseTile(mx, my)
	local p = self.player
	local a = game.level.map(tmx, tmy, Map.ACTOR)
	if not a then return end
	if not p.auto_shoot_midclick_talent then return end
	local t = p:getTalentFromId(p.auto_shoot_midclick_talent)
	if not t then return end

	local target_dist = math.floor(core.fov.distance(p.x, p.y, a.x, a.y))

	if p:enoughEnergy() and p:reactionToward(a) < 0 and not p:isTalentCoolingDown(t) and p:preUseTalent(t, true, true) and target_dist <= p:getTalentRange(t) and p:canProject({type="hit"}, a.x, a.y) then
		p:useTalent(t.id, nil, nil, nil, a)
		return true
	end
end

--- Right mouse click on the map
function _M:mouseRightClick(mx, my, extra)
	local tmx, tmy = self.level.map:getMouseTile(mx, my)
	self:registerDialog(MapMenu.new(mx, my, tmx, tmy, extra and extra.add_map_action))
end

--- Ask if we really want to close, if so, save the game first
function _M:onQuit()
	self.player:runStop("quitting")
	self.player:restStop("quitting")

	if not self.quit_dialog and not self.player.dead and not self:hasDialogUp() then
		self.quit_dialog = Dialog:yesnoPopup("Save and exit?", "Save and exit?", function(ok)
			if ok then
				local d = engine.ui.Dialog:simplePopup("Quitting...", "Quitting...", nil, true)
				d.__show_popup = false
				core.display.forceRedraw()

				-- savefile_pipe is created as a global by the engine
				self:saveGame()
				util.showMainMenu()
			end
			self.quit_dialog = nil
		end)
	end
end

--- Called when we leave the module
function _M:onDealloc()
	local time = os.time() - self.real_starttime
	print("Played ToME for "..time.." seconds")
end

--- When a save is being made, stop running/resting
function _M:onSavefilePush()
	self.player:runStop("saving")
	self.player:restStop("saving")
end

--- Requests the game to save
function _M:saveGame()
	-- savefile_pipe is created as a global by the engine
	savefile_pipe:push(self.save_name, "game", self)
	world:saveWorld()
	if not self.creating_player then
		local oldplayer = self.player
		self.party:setPlayer(self:getPlayer(true), true)
		self.player:saveUUID()
		self.party:setPlayer(oldplayer, true)
	end
	self.log("Saving game...")
end

function _M:setAllowedBuild(what, notify)
	-- Do not unlock things in easy mode
	--if self.difficulty == self.DIFFICULTY_EASY then return end

	profile:saveModuleProfile("allow_build", {name=what})

	if profile.mod.allow_build[what] then return end
	profile.mod.allow_build[what] = true

	if notify then
		self.state:checkDonation() -- They gained someting nice, they could be more receptive
		self:registerDialog(require("mod.dialogs.UnlockDialog").new(what))
	end

	return true
end

function _M:playSoundNear(who, ...)
	if who and self.level.map.seens(who.x, who.y) then
		self:playSound(...)
	end
end

--- Create a random lore object and place it
function _M:placeRandomLoreObjectScale(base, nb, level)
	local dist = ({
		[5] = { {1}, {2,3}, {4,5} }, -- 5 => 3
		korpul = { {1,2}, {3,4} }, -- 5 => 3
		[7] = { {1}, {2,3}, {4}, {5, 6}, {7} }, -- 7 => 5
	})[nb][level]
	if not dist then return end
	for _, i in ipairs(dist) do self:placeRandomLoreObject(base..i) end
end

--- Create a random lore object and place it
function _M:placeRandomLoreObject(define, zone)
	if type(define) == "table" then define = rng.table(define) end
	local o = self.zone:makeEntityByName(self.level, "object", define)
	if not o then return end
	if o.checkFilter and not o:checkFilter({}) then return end

	local x, y = rng.range(0, self.level.map.w-1), rng.range(0, self.level.map.h-1)
	local tries = 0
	while (self.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") or self.level.map(x, y, Map.OBJECT) or self.level.map.room_map[x][y].special) and tries < 100 do
		x, y = rng.range(0, self.level.map.w-1), rng.range(0, self.level.map.h-1)
		tries = tries + 1
	end
	if tries < 100 then
		self.zone:addEntity(self.level, o, "object", x, y)
		print("Placed lore", o.name, x, y)
		o:identify(true)
	end
end

--- Returns the current number of birth unlocks and the max
function _M:countBirthUnlocks()
	local nb = 0
	local max = 0
	local list = {
		campaign_infinite_dungeon = true,
		campaign_arena = true,

		undead_ghoul = true,
		undead_skeleton = true,
		yeek = true,

		mage = true,
		mage_tempest = true,
		mage_geomancer = true,
		mage_pyromancer = true,
		mage_cryomancer = true,

		rogue_poisons = true,

		divine_anorithil = true,
		divine_sun_paladin = true,

		wilder_wyrmic = true,
		wilder_summoner = true,

		corrupter_reaver = true,
		corrupter_corruptor = true,

		afflicted_cursed = true,
		afflicted_doomed = true,

		chronomancer_temporal_warden = true,
		chronomancer_paradox_mage = true,

		psionic_mindslayer = true,

		warrior_brawler = true,
	}

	for name, _ in pairs(list) do
		max = max + 1
		if profile.mod.allow_build[name] then nb = nb + 1 end
	end
	return nb, max
end

--------------------------------------------------------------
-- UI stuff
--------------------------------------------------------------

local _sep_horiz = {core.display.loadImage("/data/gfx/ui/separator-hori.png")} _sep_horiz.tex = {_sep_horiz[1]:glTexture()}
local _sep_vert = {core.display.loadImage("/data/gfx/ui/separator-vert.png")} _sep_vert.tex = {_sep_vert[1]:glTexture()}
local _sep_top = {core.display.loadImage("/data/gfx/ui/separator-top.png")} _sep_top.tex = {_sep_top[1]:glTexture()}
local _sep_bottom = {core.display.loadImage("/data/gfx/ui/separator-bottom.png")} _sep_bottom.tex = {_sep_bottom[1]:glTexture()}
local _sep_bottoml = {core.display.loadImage("/data/gfx/ui/separator-bottom_line_end.png")} _sep_bottoml.tex = {_sep_bottoml[1]:glTexture()}
local _sep_left = {core.display.loadImage("/data/gfx/ui/separator-left.png")} _sep_left.tex = {_sep_left[1]:glTexture()}
local _sep_leftl = {core.display.loadImage("/data/gfx/ui/separator-left_line_end.png")} _sep_leftl.tex = {_sep_leftl[1]:glTexture()}
local _sep_rightl = {core.display.loadImage("/data/gfx/ui/separator-right_line_end.png")} _sep_rightl.tex = {_sep_rightl[1]:glTexture()}

local _log_icon, _log_icon_w, _log_icon_h = core.display.loadImage("/data/gfx/ui/log-icon.png"):glTexture()
local _chat_icon, _chat_icon_w, _chat_icon_h = core.display.loadImage("/data/gfx/ui/chat-icon.png"):glTexture()
local _talents_icon, _talents_icon_w, _talents_icon_h = core.display.loadImage("/data/gfx/ui/talents-icon.png"):glTexture()
local _actors_icon, _actors_icon_w, _actors_icon_h = core.display.loadImage("/data/gfx/ui/actors-icon.png"):glTexture()
local _main_menu_icon, _main_menu_icon_w, _main_menu_icon_h = core.display.loadImage("/data/gfx/ui/main-menu-icon.png"):glTexture()
local _inventory_icon, _inventory_icon_w, _inventory_icon_h = core.display.loadImage("/data/gfx/ui/inventory-icon.png"):glTexture()
local _charsheet_icon, _charsheet_icon_w, _charsheet_icon_h = core.display.loadImage("/data/gfx/ui/charsheet-icon.png"):glTexture()
local _sel_icon, _sel_icon_w, _sel_icon_h = core.display.loadImage("/data/gfx/ui/icon-select.png"):glTexture()

function _M:displayUI()
	local middle = self.w * 0.5
	local bottom = self.h * 0.8
	local bottom_h = self.h * 0.2
	local icon_x = 0
	local icon_y = self.h - (_talents_icon_h * 1)
	local glow = (1+math.sin(core.game.getTime() / 500)) / 2 * 100 + 77

	-- Icons
	local x, y = icon_x, icon_y
	_talents_icon:toScreenFull(x, y, _talents_icon_w, _talents_icon_h, _talents_icon_w, _talents_icon_h)
	if not self.show_npc_list then _sel_icon:toScreenFull(x, y, _sel_icon_w, _sel_icon_h, _sel_icon_w, _sel_icon_h) end
	x = x + _talents_icon_w
	_actors_icon:toScreenFull(x, y, _actors_icon_w, _actors_icon_h, _actors_icon_w, _actors_icon_h)
	if self.show_npc_list then _sel_icon:toScreenFull(x, y, _sel_icon_w, _sel_icon_h, _sel_icon_w, _sel_icon_h) end
	x = x + _talents_icon_w

--	if self.logdisplay.changed then core.display.drawQuad(x, y, _sel_icon_w, _sel_icon_h, 139, 210, 77, glow) end
--	_log_icon:toScreenFull(x, y, _log_icon_w, _log_icon_h, _log_icon_w, _log_icon_h)
--	if not self.show_userchat then _sel_icon:toScreenFull(x, y, _sel_icon_w, _sel_icon_h, _sel_icon_w, _sel_icon_h) end
--	x = x + _talents_icon_w

--	if profile.chat.changed then core.display.drawQuad(x, y, _sel_icon_w, _sel_icon_h, 139, 210, 77, glow) end
--	_chat_icon:toScreenFull(x, y, _chat_icon_w, _chat_icon_h, _chat_icon_w, _chat_icon_h)
--	if self.show_userchat then _sel_icon:toScreenFull(x, y, _sel_icon_w, _sel_icon_h, _sel_icon_w, _sel_icon_h) end

--	x = 0
--	y = y + _chat_icon_h
--	x = x + _talents_icon_w

	_inventory_icon:toScreenFull(x, y, _inventory_icon_w, _inventory_icon_h, _inventory_icon_w, _inventory_icon_h)
	x = x + _talents_icon_w
	_charsheet_icon:toScreenFull(x, y, _charsheet_icon_w, _charsheet_icon_h, _charsheet_icon_w, _charsheet_icon_h)
	x = x + _talents_icon_w
	_main_menu_icon:toScreenFull(x, y, _main_menu_icon_w, _main_menu_icon_h, _main_menu_icon_w, _main_menu_icon_h)
	x = x + _talents_icon_w
	_log_icon:toScreenFull(x, y, _log_icon_w, _log_icon_h, _log_icon_w, _log_icon_h)

	-- Separators
--	_sep_horiz.tex[1]:toScreenFull(0, 20, self.w, _sep_horiz[3], _sep_horiz.tex[2], _sep_horiz.tex[3])
	_sep_horiz.tex[1]:toScreenFull(216, self.map_h_stop - _sep_horiz[3], self.w - 216, _sep_horiz[3], _sep_horiz.tex[2], _sep_horiz.tex[3])

--	_sep_vert.tex[1]:toScreenFull(mid_min, bottom, _sep_vert[2], bottom_h, _sep_vert.tex[2], _sep_vert.tex[3])
--	_sep_vert.tex[1]:toScreenFull(mid_max, bottom, _sep_vert[2], bottom_h, _sep_vert.tex[2], _sep_vert.tex[3])

	_sep_vert.tex[1]:toScreenFull(200, 0, _sep_vert[2], self.h, _sep_vert.tex[2], _sep_vert.tex[3])

	-- Ornaments
--	_sep_top.tex[1]:toScreenFull(mid_min - (-_sep_vert[2] + _sep_top[2]) / 2, bottom - 14, _sep_top[2], _sep_top[3], _sep_top.tex[2], _sep_top.tex[3])
--	_sep_top.tex[1]:toScreenFull(mid_max - (-_sep_vert[2] + _sep_top[2]) / 2, bottom - 14, _sep_top[2], _sep_top[3], _sep_top.tex[2], _sep_top.tex[3])
--	_sep_bottoml.tex[1]:toScreenFull(mid_min - (-_sep_vert[2] + _sep_bottoml[2]) / 2, self.h - _sep_bottoml[3], _sep_bottoml[2], _sep_bottoml[3], _sep_bottoml.tex[2], _sep_bottoml.tex[3])
--	_sep_bottoml.tex[1]:toScreenFull(mid_max - (-_sep_vert[2] + _sep_bottoml[2]) / 2, self.h - _sep_bottoml[3], _sep_bottoml[2], _sep_bottoml[3], _sep_bottoml.tex[2], _sep_bottoml.tex[3])

--	_sep_leftl.tex[1]:toScreenFull(0, 20 - _sep_leftl[3] / 2 + 7, _sep_leftl[2], _sep_leftl[3], _sep_leftl.tex[2], _sep_leftl.tex[3])
	_sep_left.tex[1]:toScreenFull(200 - 7, self.map_h_stop - 7 - _sep_left[3] / 2, _sep_left[2], _sep_left[3], _sep_left.tex[2], _sep_left.tex[3])

--	_sep_rightl.tex[1]:toScreenFull(self.w - _sep_rightl[2], 20 - _sep_rightl[3] / 2 + 7, _sep_rightl[2], _sep_rightl[3], _sep_rightl.tex[2], _sep_rightl.tex[3])
	_sep_rightl.tex[1]:toScreenFull(self.w - _sep_rightl[2], self.map_h_stop - _sep_left[3] / 2, _sep_rightl[2], _sep_rightl[3], _sep_rightl.tex[2], _sep_rightl.tex[3])

	_sep_top.tex[1]:toScreenFull(200 - (_sep_top[2] - _sep_vert[2]) / 2, - 7, _sep_top[2], _sep_top[3], _sep_top.tex[2], _sep_top.tex[3])
--	_sep_bottom.tex[1]:toScreenFull(200 - (_sep_bottom[2] - _sep_vert[2]) / 2, bottom - 25, _sep_bottom[2], _sep_bottom[3], _sep_bottom.tex[2], _sep_bottom.tex[3])

end

function _M:createSeparators()
	local icon_x = 0
	local icon_y = self.h - (_talents_icon_h * 1)
	self.icons = {
		display_x = icon_x,
		display_y = icon_y,
		w = 200,
		h = self.h - icon_y,
	}
end

function _M:clickIcon(bx, by)
	if bx < _talents_icon_w then
		self.show_npc_list = false
		self.player.changed = true
	elseif bx < 2*_talents_icon_w then
		self.show_npc_list = true
		self.player.changed = true
	elseif bx < 3*_talents_icon_w then
		self.key:triggerVirtual("SHOW_INVENTORY")
	elseif bx < 4*_talents_icon_w then
		self.key:triggerVirtual("SHOW_CHARACTER_SHEET")
	elseif bx < 5*_talents_icon_w then
		self.key:triggerVirtual("EXIT")
	elseif bx < 6*_talents_icon_w then
		self.key:triggerVirtual("SHOW_MESSAGE_LOG")
	end
end

function _M:mouseIcon(bx, by)
	if bx < _talents_icon_w then
		self:tooltipDisplayAtMap(self.w, self.h, "Display talents\nToggle with #{bold}##GOLD#[tab]#LAST##{normal}#")
	elseif bx < 2*_talents_icon_w then
		self:tooltipDisplayAtMap(self.w, self.h, "Display creatures\nToggle with #{bold}##GOLD#[tab]#LAST##{normal}#")
	elseif bx < 3*_talents_icon_w then
		self:tooltipDisplayAtMap(self.w, self.h, "#{bold}##GOLD#I#LAST##{normal}#nventory")
	elseif bx < 4*_talents_icon_w then
		self:tooltipDisplayAtMap(self.w, self.h, "#{bold}##GOLD#C#LAST##{normal}#haracter Sheet")
	elseif bx < 5*_talents_icon_w then
		self:tooltipDisplayAtMap(self.w, self.h, "Main menu (#{bold}##GOLD#Esc#LAST##{normal}#)")
	elseif bx < 6*_talents_icon_w then
		self:tooltipDisplayAtMap(self.w, self.h, "Show message/chat log (#{bold}##GOLD#ctrl+m#LAST##{normal}#)")
	end
end
