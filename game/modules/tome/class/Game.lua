-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
local Map = require "engine.Map"
local Level = require "engine.Level"
local Birther = require "engine.Birther"
local Astar = require "engine.Astar"
local DirectPath = require "engine.DirectPath"
local Shader = require "engine.Shader"

local Store = require "mod.class.Store"
local Trap = require "mod.class.Trap"
local Grid = require "mod.class.Grid"
local Actor = require "mod.class.Actor"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorAI = require "engine.interface.ActorAI"
local Player = require "mod.class.Player"
local NPC = require "mod.class.NPC"

local PlayerDisplay = require "mod.class.PlayerDisplay"

local HotkeysDisplay = require "engine.HotkeysDisplay"
local ActorsSeenDisplay = require "engine.ActorsSeenDisplay"
local LogDisplay = require "engine.LogDisplay"
local LogFlasher = require "engine.LogFlasher"
local DebugConsole = require "engine.DebugConsole"
local FlyingText = require "engine.FlyingText"
local Tooltip = require "engine.Tooltip"
local Calendar = require "engine.Calendar"

local Dialog = require "engine.Dialog"
local QuitDialog = require "mod.dialogs.Quit"

module(..., package.seeall, class.inherit(engine.GameTurnBased, engine.interface.GameMusic, engine.interface.GameSound, engine.interface.GameTargeting))

-- Difficulty settings
DIFFICULTY_EASY = 1
DIFFICULTY_NORMAL = 2
DIFFICULTY_NIGHTMARE = 3
DIFFICULTY_INSANE = 4

function _M:init()
	engine.GameTurnBased.init(self, engine.KeyBind.new(), 1000, 100)
	engine.interface.GameMusic.init(self)
	engine.interface.GameSound.init(self)

	self.persistant_actors = {}
	-- Pause at birth
	self.paused = true

	-- Same init as when loaded from a savefile
	self:loaded()
end

function _M:run()
	self.flash = LogFlasher.new(0, 0, self.w, 20, nil, nil, nil, {255,255,255}, {0,0,0})
	self.logdisplay = LogDisplay.new(0, self.h * 0.8, self.w * 0.5, self.h * 0.2, nil, nil, nil, {255,255,255}, {30,30,30})
	self.player_display = PlayerDisplay.new(0, 220, 200, self.h * 0.8 - 220, {30,30,0})
	self.hotkeys_display = HotkeysDisplay.new(nil, self.w * 0.5, self.h * 0.8, self.w * 0.5, self.h * 0.2, {30,30,0})
	self.npcs_display = ActorsSeenDisplay.new(nil, self.w * 0.5, self.h * 0.8, self.w * 0.5, self.h * 0.2, {30,30,0})
	self.calendar = Calendar.new("/data/calendar_rivendell.lua", "Today is the %s %s of the %s year of the Fourth Age of Middle-earth.\nThe time is %02d:%02d.", 122)
	self.tooltip = Tooltip.new(nil, nil, {255,255,255}, {30,30,30})
	self.flyers = FlyingText.new()
	self:setFlyingText(self.flyers)

	self.log = function(style, ...) if type(style) == "number" then self.logdisplay(...) self.flash(style, ...) else self.logdisplay(style, ...) self.flash(self.flash.NEUTRAL, style, ...) end end
	self.logSeen = function(e, style, ...) if e and self.level.map.seens(e.x, e.y) then self.log(style, ...) end end
	self.logPlayer = function(e, style, ...) if e == self.player then self.log(style, ...) end end

	self.log(self.flash.GOOD, "Welcome to #00FF00#Tales of Middle Earth!")

	-- Setup inputs
	self:setupCommands()
	self:setupMouse()

	-- Starting from here we create a new game
	if not self.player then self:newGame() end

	self.hotkeys_display.actor = self.player
	self.npcs_display.actor = self.player

	engine.interface.GameTargeting.init(self)

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()

	-- Run the current music if any
	self:playMusic()

	if self.level then self:setupDisplayMode() end
end

function _M:newGame()
	self.player = Player.new{name=self.player_name, game_ender=true}
	Map:setViewerActor(self.player)
	self:setupDisplayMode()

	-- Load for quick birth
	local save = Savefile.new(self.save_name)
	local quickbirth = save:loadQuickBirth()
	save:close()

	local birth = Birther.new(self.player, {"base", "difficulty", "world", "race", "subrace", "sex", "class", "subclass" }, function()
		-- Save for quick birth
		local save = Savefile.new(self.save_name)
		save:saveQuickBirth(self.player.descriptor)
		save:close()

		self.player.wild_x, self.player.wild_y = self.player.default_wilderness[1], self.player.default_wilderness[2]
		self.player.last_wilderness = self.player.default_wilderness[3] or "wilderness"
		self:changeLevel(1, self.player.starting_zone)
		print("[PLAYER BIRTH] resolve...")
		self.player:resolve()
		self.player:resolve(nil, true)
		self.player.energy.value = self.energy_to_act
		self.always_target = true
		Map:setViewerFaction(self.player.faction)

		self.paused = true
		print("[PLAYER BIRTH] resolved!")
		self.player:playerLevelup(function()
			self.player:grantQuest(self.player.starting_quest)
			self:registerDialog(require("mod.dialogs.IntroDialog").new(self.player))
			self.player:resetToFull()
			self.player:registerCharacterPlayed()
		end)
	end, quickbirth)
	self:registerDialog(birth)
end

function _M:loaded()
	engine.GameTurnBased.loaded(self)
	engine.interface.GameMusic.loaded(self)
	engine.interface.GameSound.loaded(self)
	Zone:setup{npc_class="mod.class.NPC", grid_class="mod.class.Grid", object_class="mod.class.Object", trap_class="mod.class.Trap"}
	Map:setViewerActor(self.player)
	Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 32, 32, nil, 20, true)
	if self.player then self.player.changed = true end
	self.key = engine.KeyBind.new()

	if self.always_target then Map:setViewerFaction(self.player.faction) end
end

function _M:onResolutionChange()
	engine.Game.onResolutionChange(self)
	print("[RESOLUTION] changed to ", self.w, self.h)
	self:setupDisplayMode()
	self.flash:resize(0, 0, self.w, 20)
	self.logdisplay:resize(0, self.h * 0.8, self.w * 0.5, self.h * 0.2)
	self.player_display:resize(0, 220, 200, self.h * 0.8 - 220)
	self.hotkeys_display:resize(self.w * 0.5, self.h * 0.8, self.w * 0.5, self.h * 0.2)
	self.npcs_display:resize(self.w * 0.5, self.h * 0.8, self.w * 0.5, self.h * 0.2)
	-- Reset mouse bindings to account for new size
	self:setupMouse(reset)
end

function _M:setupDisplayMode()
	self.gfxmode = self.gfxmode or (config.settings.tome and config.settings.tome.gfxmode) or 1
	if self.gfxmode == 1 then
		print("[DISPLAY MODE] 32x32 GFX")
		Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 32, 32, nil, 22, true, true)
		Map:resetTiles()
		Map.tiles.use_images = true
	elseif self.gfxmode == 2 then
		print("[DISPLAY MODE] 16x16 GFX")
		Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 16, 16, nil, 14, true, true)
		Map:resetTiles()
		Map.tiles.use_images = true
	elseif self.gfxmode == 3 then
		print("[DISPLAY MODE] 32x32 ASCII")
		Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 32, 32, nil, 22, false, false)
		Map:resetTiles()
		Map.tiles.use_images = false
	elseif self.gfxmode == 4 then
		print("[DISPLAY MODE] 16x16 ASCII")
		Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 16, 16, nil, 14, false, false)
		Map:resetTiles()
		Map.tiles.use_images = false
	elseif self.gfxmode == 5 then
		print("[DISPLAY MODE] 32x32 ASCII/background")
		Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 32, 32, nil, 22, true, true)
		Map:resetTiles()
		Map.tiles.use_images = false
	elseif self.gfxmode == 6 then
		print("[DISPLAY MODE] 16x16 ASCII/background")
		Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 16, 16, nil, 14, true, true)
		Map:resetTiles()
		Map.tiles.use_images = false
	else
		print("[DISPLAY MODE] ????", self.gfxmode)
	end
	if self.level then
		self.level.map:recreate()
		engine.interface.GameTargeting.init(self)
		self.level.map:moveViewSurround(self.player.x, self.player.y, 8, 8)
	end
	self:setupMiniMap()
	self:saveSettings("tome.gfxmode", ("tome.gfxmode = %d\n"):format(self.gfxmode))

	-- Create the framebuffer
--	self.fbo = core.display.newFBO(Map.viewport.width, Map.viewport.height)
--	if self.fbo then self.fbo_shader = Shader.new("main_fbo") end
end

function _M:setupMiniMap()
	if self.level and self.level.map then self.level.map._map:setupMiniMapGridSize(4) end
end

function _M:save()
	return class.save(self, self:defaultSavedFields{difficulty=true, persistant_actors=true}, true)
end

function _M:getSaveDescription()
	return {
		name = self.player.name,
		description = ([[%s the level %d %s %s.
Difficulty: %s
Exploring level %d of %s.]]):format(
		self.player.name, self.player.level, self.player.descriptor.subrace, self.player.descriptor.subclass,
		self.player.descriptor.difficulty,
		self.level.level, self.zone.name
		),
	}
end

function _M:getStore(def)
	return Store.stores_def[def]:clone()
end

function _M:leaveLevel(level, lev, old_lev)
	self.to_re_add_actors = {}
	if level:hasEntity(self.player) then
		level.exited = level.exited or {}
		if lev > old_lev then
			level.exited.down = {x=self.player.x, y=self.player.y}
		else
			level.exited.up = {x=self.player.x, y=self.player.y}
		end
		level.last_turn = game.turn
		for act, _ in pairs(self.persistant_actors) do
			if level:hasEntity(act) then
				level:removeEntity(act)
				self.to_re_add_actors[act] = true
			end
		end
		level:removeEntity(self.player)
	end
end

function _M:changeLevel(lev, zone, keep_old_lev)
	if not self.player.game_ender then
		game.logPlayer(self.player, "#LIGHT_RED#You may not change level without your own body!")
		return
	end

	if self.zone and self.zone.on_leave then
		local nl, nz = self.zone.on_leave(lev, old_lev, zone)
		if nl then lev = nl end
		if nz then zone = nz end
	end

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
	end
	self.zone:getLevel(self, lev, old_lev)

	-- Decay level ?
	if self.level.last_turn and self.level.data.decay and self.level.last_turn + self.level.data.decay[1] * 10 < game.turn then
		local nb_actor, remain_actor = self.level:decay(Map.ACTOR, function(e) return not e.unique and self.level.last_turn + rng.range(self.level.data.decay[1], self.level.data.decay[2]) < game.turn * 10 end)
		local nb_object, remain_object = self.level:decay(Map.OBJECT, function(e) return not e.unique and self.level.last_turn + rng.range(self.level.data.decay[1], self.level.data.decay[2]) < game.turn * 10 end)

		local gen = self.zone:getGenerator("actor", self.level)
		if gen.regenFrom then gen:regenFrom(remain_actor) end

		local gen = self.zone:getGenerator("object", self.level)
		if gen.regenFrom then gen:regenFrom(remain_object) end
	end

	-- Move back to old wilderness position
	if self.zone.wilderness then
		self.player:move(self.player.wild_x, self.player.wild_y, true)
		self.player.last_wilderness = self.zone.short_name
	else
		if lev > old_lev then
			self.player:move(self.level.default_up.x, self.level.default_up.y, true)
		else
			self.player:move(self.level.default_down.x, self.level.default_down.y, true)
		end
	end
	self.player.changed = true
	if self.to_re_add_actors then for act, _ in pairs(self.to_re_add_actors) do
		local x, y = util.findFreeGrid(self.player.x, self.player.y, 20, true, {[Map.ACTOR]=true})
		if x then act:move(x, y, true) end
	end end

	-- Re add entities
	self.level:addEntity(self.player)
	if self.to_re_add_actors then for act, _ in pairs(self.to_re_add_actors) do
		self.level:addEntity(act)
		act:setTarget(nil)
	end end

	if self.zone.on_enter then
		self.zone.on_enter(lev, old_lev, zone)
	end

	if self.level.data.ambiant_music then
		if self.level.data.ambiant_music ~= "last" then
			self:playMusic(self.level.data.ambiant_music)
		end
	else
		self:stopMusic()
	end

	-- Update the minimap
	self:setupMiniMap()

	-- Tell the map to use path strings to speed up path calculations
	for uid, e in pairs(self.level.entities) do
		self.level.map:addPathString(e:getPathString())
	end
	self.zone_name_s = nil
	self.level.map:redisplay()
end

function _M:getPlayer()
	return self.player
end

function _M:tick()
	if self.level then
		self:targetOnTick()

		engine.GameTurnBased.tick(self)
		-- Fun stuff: this can make the game realtime, although callit it in display() will make it work better
		-- (since display is on a set FPS while tick() ticks as much as possible
		-- engine.GameEnergyBased.tick(self)
	end
	if game.paused then return true end
end

--- Called every game turns
-- Does nothing, you can override it
function _M:onTurn()
	if self.zone then
		if self.zone.on_turn then self.zone:on_turn() end
	end

	-- The following happens only every 10 game turns (once for every turn of 1 mod speed actors)
	if self.turn % 10 ~= 0 then return end

	-- Process overlay effects
	self.level.map:processEffects()

	if not self.day_of_year or self.day_of_year ~= self.calendar:getDayOfYear(self.turn) then
		self.log(self.calendar:getTimeDate(self.turn))
		self.day_of_year = self.calendar:getDayOfYear(self.turn)
	end
end

function _M:display()
	-- Now the map, if any
	if self.level and self.level.map and self.level.map.finished then
		-- Display the map and compute FOV for the player if needed
		if self.level.map.changed then
			self.player:playerFOV()
		end

		-- Level background
		if self.level.data.background then
			self.level.data.background(self.level)
		end

		-- Display using Framebuffer, sotaht we can use shaders and all
		if self.fbo then
			self.fbo:use(true)
			self.level.map:display(0, 0)
			self.target:display(0, 0)
			self.fbo:use(false)
			self.fbo:toScreen(
				self.level.map.display_x, self.level.map.display_y,
				self.level.map.viewport.width, self.level.map.viewport.height,
				self.fbo_shader.shad
			)

		-- Basic display
		else
			self.level.map:display()
			self.target:display()
		end

		if not self.zone_name_s then
			self.zone_name_s = core.display.drawStringBlendedNewSurface(self.player_display.font, ("%s (%d)"):format(self.zone.name, self.level.level), 0, 255, 255)
		end
		local znsx, znsy = self.zone_name_s:getSize()
		self.zone_name_s:toScreen(
			self.level.map.display_x + self.level.map.viewport.width - znsx,
			self.level.map.display_y + self.level.map.viewport.height - znsy
		)

		-- Minimap display
		self.level.map:minimapDisplay(0, 20, util.bound(self.player.x - 25, 0, self.level.map.w - 50), util.bound(self.player.y - 25, 0, self.level.map.h - 50), 50, 50, 1)
	end

	-- We display the player's interface
	self.flash:display():toScreen(self.flash.display_x, self.flash.display_y)
	self.logdisplay:display():toScreen(self.logdisplay.display_x, self.logdisplay.display_y)
	self.player_display:display():toScreen(self.player_display.display_x, self.player_display.display_y)
	if self.show_npc_list then
		self.npcs_display:display():toScreen(self.npcs_display.display_x, self.npcs_display.display_y)
	else
		self.hotkeys_display:display():toScreen(self.hotkeys_display.display_x, self.hotkeys_display.display_y)
	end
	if self.player then self.player.changed = false end

	-- Tooltip is displayed over all else
	self:targetDisplayTooltip(game.w, game.h)

	engine.GameTurnBased.display(self)
end

function _M:setupCommands()
	-- Make targeting work
	self.normal_key = self.key
	self:targetSetupKey()

	-- Activate profiler keybinds
	self.key:setupProfiler()

	-- Helper function to not allow some actions on the wilderness map
	local not_wild = function(f) return function() if self.zone and not self.zone.wilderness then f() else self.logPlayer(self.player, "You can not do that on the world map.") end end end

	self.key:addCommands{
		[{"_d","ctrl"}] = function()
			if config.settings.tome.cheat then
				self.player:forceLevelup(50)
				self.player.no_breath = 1
				self.player.invulnerable = 1
				self.player.esp.all = 1
				self.player.esp.range = 50
				self.player.inc_damage.all = 100000
--				self:changeLevel(5, "gorbat-pride")
--				self:changeLevel(1, "town-gates-of-morning")
				self:changeLevel(1, "wilderness-arda-fareast")
				game.memory_levels["wilderness-arda-fareast-1"] = game.level
				self.player:grantQuest("spydric-infestation")
				self.player:setQuestStatus("spydric-infestation", engine.Quest.COMPLETED)
				self.player:grantQuest("orc-pride")
				self.player:setQuestStatus("orc-pride", engine.Quest.COMPLETED)
--				self.player:grantQuest("escort-duty")
			end
		end,
		[{"_f","ctrl"}] = function()
			if config.settings.tome.cheat then
				self.player:incStat("str", 100) self.player:incStat("dex", 100) self.player:incStat("mag", 100) self.player:incStat("wil", 100) self.player:incStat("cun", 100) self.player:incStat("con", 100)
				self.player:learnTalent(self.player.T_HEAVY_ARMOUR_TRAINING, true) self.player:learnTalent(self.player.T_MASSIVE_ARMOUR_TRAINING, true)
				for i, e in ipairs(self.zone.object_list) do
					if e.unique and (not e.define_as or e.define_as ~= "JEWELER_SUMMON") then -- and e.rarity then
						local a = self.zone:finishEntity(self.level, "object", e)
						a:identify(true)
						self.zone:addEntity(self.level, a, "object", self.player.x, self.player.y)
					end
				end
				self.logPlayer(self.player, "All world artifacts created.")
			end
		end,
		[{"_g","ctrl"}] = function()
			if config.settings.tome.cheat then
				self:changeLevel(15, "high-peak")
				self.player:grantQuest("high-peak")
			end
		end,
	}
	self.key:addBinds
	{
		-- Movements
		MOVE_LEFT = function() self.player:moveDir(4) end,
		MOVE_RIGHT = function() self.player:moveDir(6) end,
		MOVE_UP = function() self.player:moveDir(8) end,
		MOVE_DOWN = function() self.player:moveDir(2) end,
		MOVE_LEFT_UP = function() self.player:moveDir(7) end,
		MOVE_LEFT_DOWN = function() self.player:moveDir(1) end,
		MOVE_RIGHT_UP = function() self.player:moveDir(9) end,
		MOVE_RIGHT_DOWN = function() self.player:moveDir(3) end,
		MOVE_STAY = function() self.player:useEnergy() end,

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
		HOTKEY_THIRD_8 = not_wild(function() self.player:activateHotkey(31) end),
		HOTKEY_THIRD_9 = not_wild(function() self.player:activateHotkey(33) end),
		HOTKEY_THIRD_10 = not_wild(function() self.player:activateHotkey(34) end),
		HOTKEY_THIRD_11 = not_wild(function() self.player:activateHotkey(35) end),
		HOTKEY_THIRD_12 = not_wild(function() self.player:activateHotkey(36) end),
		HOTKEY_PREV_PAGE = not_wild(function() self.player:prevHotkeyPage() end),
		HOTKEY_NEXT_PAGE = not_wild(function() self.player:nextHotkeyPage() end),
--		HOTKEY_HOTPAGE2 = function(sym, ctrl, shift, alt, meta, unicode, isup) self.player:setHotkeyPage(isup and 1 or 2) end,
--		HOTKEY_HOTPAGE3 = function(sym, ctrl, shift, alt, meta, unicode, isup) self.player:setHotkeyPage(isup and 1 or 3) end,

		-- Actions
		CHANGE_LEVEL = function()
			local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
			if self.player:enoughEnergy() and e.change_level then
				if self.player:attr("never_move") then self.log("You can not currently leave the level.") return end

				local stop = {}
				for eff_id, p in pairs(self.player.tmp) do
					local e = self.player.tempeffect_def[eff_id]
					if e.status == "detrimental" then stop[#stop+1] = e.desc end
				end

				if e.change_zone and #stop > 0 and e.change_zone:find("^wilderness") then
					self.log("You can not go into the wilds with the following effects: %s", table.concat(stop, ", "))
				else
					-- Do not unpause, the player is allowed first move on next level
					self:changeLevel(e.change_zone and e.change_level or self.level.level + e.change_level, e.change_zone, e.keep_old_lev)
				end
			else
				self.log("There is no way out of this level here.")
			end
		end,

		REST = function()
			self.player:restInit()
		end,

		PICKUP_FLOOR = not_wild(function()
			self.player:playerPickup()
		end),
		DROP_FLOOR = function()
			self.player:playerDrop()
		end,
		SHOW_INVENTORY = function()
			local d
			local titleupdator = self.player:getEncumberTitleUpdator("Inventory")
			d = self.player:showEquipInven(titleupdator(), nil, function(o, inven, item)
				local ud = require("mod.dialogs.UseItemDialog").new(self.player, o, item, inven, function()
					d:generateList()
					d.title = titleupdator()
				end)
				self:registerDialog(ud)
			end)
		end,
		SHOW_EQUIPMENT = "SHOW_INVENTORY",
		WEAR_ITEM = function()
			self.player:playerWear()
		end,
		TAKEOFF_ITEM = function()
			self.player:playerTakeoff()
		end,
		USE_ITEM = not_wild(function()
			self.player:playerUseItem()
		end),

		QUICK_SWITCH_WEAPON = function()
			self.player:quickSwitchWeapons()
		end,

		USE_TALENTS = not_wild(function()
			self.player:useTalents()
		end),

		LEVELUP = function()
			self.player:playerLevelup()
		end,

		SAVE_GAME = function()
			self:saveGame()
		end,

		SHOW_QUESTS = function()
			self:registerDialog(require("engine.dialogs.ShowQuests").new(self.player))
		end,

		SHOW_CHARACTER_SHEET = function()
			self:registerDialog(require("mod.dialogs.CharacterSheet").new(self.player))
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
			if config.settings.tome.cheat then
				self:registerDialog(DebugConsole.new())
			end
		end,

		-- Switch gfx modes
		SWITCH_GFX = function()
			self.gfxmode = self.gfxmode or 1
			self.gfxmode = util.boundWrap(self.gfxmode + 1, 1, 6)
			self:setupDisplayMode()
		end,

		-- Toggle monster list
		TOGGLE_NPC_LIST = function()
			self.show_npc_list = not self.show_npc_list
			self.player.changed = true
		end,

		EXIT = function()
			local menu menu = require("engine.dialogs.GameMenu").new{
				"resume",
				"achievements",
				{ "Show known Lore", function() game:unregisterDialog(menu) game:registerDialog(require("mod.dialogs.ShowLore").new("Tales of Middle-earth Lore", self.player)) end },
				"keybinds",
				{"Graphic Mode", function() game:unregisterDialog(menu) game:registerDialog(require("mod.dialogs.GraphicMode").new()) end},
				"resolution",
				"sound",
				"save",
				"quit"
			}
			self:registerDialog(menu)
		end,

		TACTICAL_DISPLAY = function()
			if Map.view_faction then
				self.always_target = nil
				Map:setViewerFaction(nil)
			else
				self.always_target = true
				Map:setViewerFaction(self.player.faction)
			end
		end,

		LOOK_AROUND = function()
			self.flash:empty(true)
			self.flash(self.flash.GOOD, "Looking around... (direction keys to select interresting things, shift+direction keys to move freely)")
			local co = coroutine.create(function() self.player:getTarget{type="hit", no_restrict=true, range=2000} end)
			local ok, err = coroutine.resume(co)
			if not ok and err then print(debug.traceback(co)) error(err) end
		end,
	}

	self.key:setCurrent()
end

function _M:setupMouse(reset)
	if reset then self.mouse:reset() end
	self.mouse:registerZone(Map.display_x, Map.display_y, Map.viewport.width, Map.viewport.height, function(button, mx, my, xrel, yrel)
		-- Handle targeting
		if self:targetMouse(button, mx, my, xrel, yrel) then return end

		-- Handle the mouse movement/scrolling
		self.player:mouseHandleDefault(self.key, self.key == self.normal_key, button, mx, my, xrel, yrel)
	end)
	-- Scroll message log
	self.mouse:registerZone(self.logdisplay.display_x, self.logdisplay.display_y, self.w, self.h, function(button)
		if button == "wheelup" then self.logdisplay:scrollUp(1) end
		if button == "wheeldown" then self.logdisplay:scrollUp(-1) end
	end, {button=true})
	-- Use hotkeys with mouse
	self.mouse:registerZone(self.hotkeys_display.display_x, self.hotkeys_display.display_y, self.w, self.h, function(button, mx, my, xrel, yrel)
		self.hotkeys_display:onMouse(button, mx, my, not xrel)
	end)
	if not reset then self.mouse:setCurrent() end
end

--- Ask if we realy want to close, if so, save the game first
function _M:onQuit()
	self.player:runStop("quitting")
	self.player:restStop("quitting")

	if not self.quit_dialog and not self.player.dead then
		self.quit_dialog = QuitDialog.new()
		self:registerDialog(self.quit_dialog)
	end
end

--- Requests the game to save
function _M:saveGame()
	local save = Savefile.new(self.save_name)
	save:saveGame(self)
	save:close()
	world:saveWorld()
	self.log("Saved game.")
end

function _M:setAllowedBuild(what, notify)
	-- Do not unlock things in easy mode
	--if game.difficulty == game.DIFFICULTY_EASY then return end

	profile.mod.allow_build = profile.mod.allow_build or {}
	if profile.mod.allow_build[what] then return end
	profile.mod.allow_build[what] = true

	profile:saveModuleProfile("allow_build", profile.mod.allow_build)

	if notify then
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
function _M:placeRandomLoreObject(define)
	if type(define) == "table" then define = rng.table(define) end
	local o = self.zone:makeEntityByName(self.level, "object", define)
	if not o then return end

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
