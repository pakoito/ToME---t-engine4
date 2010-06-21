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
local KeyBind = require "engine.KeyBind"
local Savefile = require "engine.Savefile"
local DamageType = require "engine.DamageType"
local Zone = require "engine.Zone"
local Map = require "engine.Map"
local Target = require "engine.Target"
local Level = require "engine.Level"
local Birther = require "engine.Birther"
local Astar = require "engine.Astar"
local DirectPath = require "engine.DirectPath"

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
local LogDisplay = require "engine.LogDisplay"
local LogFlasher = require "engine.LogFlasher"
local DebugConsole = require "engine.DebugConsole"
local FlyingText = require "engine.FlyingText"
local Tooltip = require "engine.Tooltip"
local Calendar = require "engine.Calendar"

local Dialog = require "engine.Dialog"
local QuitDialog = require "mod.dialogs.Quit"

module(..., package.seeall, class.inherit(engine.GameTurnBased, engine.interface.GameMusic, engine.interface.GameSound))

-- Difficulty settings
DIFFICULTY_EASY = 1
DIFFICULTY_NORMAL = 2
DIFFICULTY_NIGHTMARE = 3
DIFFICULTY_INSANE = 4

function _M:init()
	engine.GameTurnBased.init(self, engine.KeyBind.new(), 1000, 100)
	engine.interface.GameMusic.init(self)
	engine.interface.GameSound.init(self)

	-- Pause at birth
	self.paused = true

	-- Same init as when loaded from a savefile
	self:loaded()
end

function _M:run()
	self.flash = LogFlasher.new(0, 0, self.w, 20, nil, nil, nil, {255,255,255}, {0,0,0})
	self.logdisplay = LogDisplay.new(0, self.h * 0.8, self.w * 0.5, self.h * 0.2, nil, nil, nil, {255,255,255}, {30,30,30})
	self.player_display = PlayerDisplay.new(0, 20, 200, self.h * 0.8 - 20, {30,30,0})
	self.hotkeys_display = HotkeysDisplay.new(nil, self.w * 0.5, self.h * 0.8, self.w * 0.5, self.h * 0.2, {30,30,0})
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

	self.target = Target.new(Map, self.player)
	self.target.target.entity = self.player
	self.old_tmx, self.old_tmy = 0, 0
	self.target_style = "lock"

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

	local birth = Birther.new(self.player, {"base", "difficulty", "world", "race", "subrace", "sex", "class", "subclass" }, function()
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
		end)
	end)
	self:registerDialog(birth)
end

function _M:loaded()
	engine.GameTurnBased.loaded(self)
	engine.interface.GameMusic.loaded(self)
	engine.interface.GameSound.loaded(self)
	Zone:setup{npc_class="mod.class.NPC", grid_class="mod.class.Grid", object_class="mod.class.Object", trap_class="mod.class.Trap"}
	Map:setViewerActor(self.player)
	Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 32, 32, nil, 20, true)
	self.key = engine.KeyBind.new()

	if self.always_target then Map:setViewerFaction(self.player.faction) end
end

function _M:onResolutionChange()
	engine.Game.onResolutionChange(self)
	print("[RESOLUTION] changed to ", self.w, self.h)
	self:setupDisplayMode()
	self.flash:resize(0, 0, self.w, 20)
	self.logdisplay:resize(0, self.h * 0.8, self.w * 0.5, self.h * 0.2)
	self.player_display:resize(0, 20, 200, self.h * 0.8 - 20)
	self.hotkeys_display:resize(self.w * 0.5, self.h * 0.8, self.w * 0.5, self.h * 0.2)
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
		self.target = Target.new(Map, self.player)
		self.target.target.entity = self.player
		self.level.map:moveViewSurround(self.player.x, self.player.y, 8, 8)
	end
	self:setupMiniMap()
	self:saveSettings("tome.gfxmode", ("tome.gfxmode = %d\n"):format(self.gfxmode))
end

function _M:setupMiniMap()
	print("[MINIMAP MODE]", self.minimap_mode)
	self.minimap_mode = self.minimap_mode or (config.settings.tome and config.settings.tome.minimap_mode) or 2
	if self.minimap_mode == 1 then
		print("[MINIMAP MODE] disabled")
	elseif self.minimap_mode == 2 then
		if self.level and self.level.map then self.level.map._map:setupMiniMapGridSize(4) end
		print("[MINIMAP MODE] small")
	elseif self.minimap_mode == 3 then
		if self.level and self.level.map then self.level.map._map:setupMiniMapGridSize(8) end
		print("[MINIMAP MODE] full")
	end
	self:saveSettings("tome.minimap_mode", ("tome.minimap_mode = %d\n"):format(self.minimap_mode))
end

function _M:save()
	return class.save(self, self:defaultSavedFields{difficulty=true}, true)
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
	if level:hasEntity(self.player) then
		level.exited = level.exited or {}
		if lev > old_lev then
			level.exited.down = {x=self.player.x, y=self.player.y}
		else
			level.exited.up = {x=self.player.x, y=self.player.y}
		end
		level.last_turn = game.turn
		level:removeEntity(self.player)
	end
end

function _M:changeLevel(lev, zone)
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
			self.player:move(self.level.ups[1].x, self.level.ups[1].y, true)
		else
			self.player:move(self.level.downs[1].x, self.level.downs[1].y, true)
		end
	end
	self.level:addEntity(self.player)

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
	self.level.map:redisplay()
end

function _M:getPlayer()
	return self.player
end

function _M:tick()
	if self.level then
		if self.target.target.entity and not self.level:hasEntity(self.target.target.entity) then self.target.target.entity = false end

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
	-- We display the player's interface
	self.flash:display():toScreen(self.flash.display_x, self.flash.display_y)
	self.logdisplay:display():toScreen(self.logdisplay.display_x, self.logdisplay.display_y)
	self.player_display:display():toScreen(self.player_display.display_x, self.player_display.display_y)
	self.hotkeys_display:display():toScreen(self.hotkeys_display.display_x, self.hotkeys_display.display_y)
	if self.player then self.player.changed = false end

	-- Now the map, if any
	if self.level and self.level.map and self.level.map.finished then
		-- Display the map and compute FOV for the player if needed
		if self.level.map.changed then
			self.player:playerFOV()
		end

		self.level.map:display()

		-- Display the targetting system if active
		self.target:display()

		-- Display a tooltip if available
		if self.tooltip_x then
			local mx, my = self.tooltip_x , self.tooltip_y
			local tmx, tmy = self.level.map:getMouseTile(mx, my)
			self.tooltip:displayAtMap(tmx, tmy)
		end

		-- Move target around
		if self.old_tmx ~= tmx or self.old_tmy ~= tmy then
			self.target.target.x, self.target.target.y = tmx, tmy
		end
		self.old_tmx, self.old_tmy = tmx, tmy
--[[ too slow
		if self.test_path and self.key.status[self.key._LSHIFT] then
			for i, c in ipairs(self.test_path) do
				local lx, ly = c.x, c.y
				self.test_sprite:toScreen(self.level.map.display_x + (lx - game.level.map.mx) * self.level.map.tile_w, self.level.map.display_y + (ly - game.level.map.my) * self.level.map.tile_h)
			end
		end
]]

		if self.minimap_mode == 2 then
			self.level.map:minimapDisplay(self.w - 200, 20, util.bound(self.player.x - 25, 0, self.level.map.w - 50), util.bound(self.player.y - 25, 0, self.level.map.h - 50), 50, 50, 0.6)
		elseif self.minimap_mode == 3 then
			local mx, my = 0, 0
			local mw, mh = math.floor((self.w - 200) / 8), math.floor(self.h * .80 / 8)

			mx = self.player.x - math.floor(mw / 2)
			my = self.player.y - math.floor(mh / 2)

			if self.level.map.w < mw then mx = math.floor((self.level.map.w - mw) / 2) end
			if self.level.map.h < mh then my = math.floor((self.level.map.h - mh) / 2) end

			self.level.map:minimapDisplay(200, 20, mx, my, mw, mh, 0.9)
		end
	end

	engine.GameTurnBased.display(self)
end

function _M:targetMode(v, msg, co, typ)
	local old = self.target_mode
	self.target_mode = v

	if not v then
		Map:setViewerFaction(self.always_target and self.player.faction or nil)
		if msg then self.log(type(msg) == "string" and msg or "Tactical display disabled. Press shift+'t' or right mouse click to enable.") end
		self.level.map.changed = true
		self.target:setActive(false)

		if tostring(old) == "exclusive" then
			local fct = function(ok)
				if not ok then
					self.target.target.entity = nil
					self.target.target.x = nil
					self.target.target.y = nil
				end

				self.key = self.normal_key
				self.key:setCurrent()
				if self.target_co then
					local co = self.target_co
					self.target_co = nil
					local ok, err = coroutine.resume(co, self.target.target.x, self.target.target.y, self.target.target.entity)
					if not ok and err then print(debug.traceback(co)) error(err) end
				end
			end
			if self.target_warning and self.target.target.x == game.player.x and self.target.target.y == game.player.y then
				Dialog:yesnoPopup("Target yourself?", "Are you sure you want to target yourself?", fct)
			else
				fct(true)
			end
		end
	else
		Map:setViewerFaction(self.player.faction)
		if msg then self.log(type(msg) == "string" and msg or "Tactical display enabled. Press shift+'t' to disable.") end
		self.level.map.changed = true
		self.target:setActive(true, typ)
		self.target_style = "lock"
		self.target_warning = true

		-- Exclusive mode means we disable the current key handler and use a specific one
		-- that only allows targetting and resumes talent coroutine when done
		if tostring(v) == "exclusive" then
			self.target_co = co
			self.key = self.targetmode_key
			self.key:setCurrent()

			if self.target.target.entity and self.level.map.seens(self.target.target.entity.x, self.target.target.entity.y) and self.player ~= self.target.target.entity then
			else
				self.target:scan(5, nil, self.player.x, self.player.y)
			end
		end
		if self.target.target.x then
			self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y)
		end
	end
end

function _M:setupCommands()
	self.targetmode_key = engine.KeyBind.new()
	self.targetmode_key:addCommands{ _SPACE=function() self:targetMode(false, false) self.tooltip_x, self.tooltip_y = nil, nil end, }
	self.targetmode_key:addBinds
	{
		TACTICAL_DISPLAY = function()
			self:targetMode(false, false)
			self.tooltip_x, self.tooltip_y = nil, nil
		end,
		ACCEPT = function()
			self:targetMode(false, false)
			self.tooltip_x, self.tooltip_y = nil, nil
		end,
		EXIT = function()
			self.target.target.entity = nil
			self.target.target.x = nil
			self.target.target.y = nil
			self:targetMode(false, false)
			self.tooltip_x, self.tooltip_y = nil, nil
		end,
		-- Targeting movement
		RUN_LEFT = function() self.target:freemove(4) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_RIGHT = function() self.target:freemove(6) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_UP = function() self.target:freemove(8) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_DOWN = function() self.target:freemove(2) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_LEFT_DOWN = function() self.target:freemove(1) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_RIGHT_DOWN = function() self.target:freemove(3) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_LEFT_UP = function() self.target:freemove(7) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_RIGHT_UP = function() self.target:freemove(9) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,

		MOVE_LEFT = function() if self.target_style == "lock" then self.target:scan(4) else self.target:freemove(4) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_RIGHT = function() if self.target_style == "lock" then self.target:scan(6) else self.target:freemove(6) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_UP = function() if self.target_style == "lock" then self.target:scan(8) else self.target:freemove(8) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_DOWN = function() if self.target_style == "lock" then self.target:scan(2) else self.target:freemove(2) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_LEFT_DOWN = function() if self.target_style == "lock" then self.target:scan(1) else self.target:freemove(1) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_RIGHT_DOWN = function() if self.target_style == "lock" then self.target:scan(3) else self.target:freemove(3) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_LEFT_UP = function() if self.target_style == "lock" then self.target:scan(7) else self.target:freemove(7) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_RIGHT_UP = function() if self.target_style == "lock" then self.target:scan(9) else self.target:freemove(9) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
	}

	self.normal_key = self.key
	-- Activate profiler keybinds
	self.key:setupProfiler()

	-- Helper function to not allow some actions on the wilderness map
	local not_wild = function(f) return function() if self.zone and not self.zone.wilderness then f() else self.logPlayer(self.player, "You can not do that on the world map.") end end end

	self.key:addCommands{
		[{"_d","ctrl"}] = function()
			if config.settings.tome.cheat then
				self.player:forceLevelup(50)
				self:changeLevel(1, "rak-shor-pride")
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
				local stop = {}
				for eff_id, p in pairs(game.player.tmp) do
					local e = game.player.tempeffect_def[eff_id]
					if e.status == "detrimental" then stop[#stop+1] = e.desc end
				end

				if not e.change_zone or (#stop > 0 and e.change_zone:find("^wilderness")) or #stop == 0 then
					-- Do not unpause, the player is allowed first move on next level
					self:changeLevel(e.change_zone and e.change_level or self.level.level + e.change_level, e.change_zone)
				else
					self.log("You can not go into the wilds with the following effects: %s", table.concat(stop, ", "))
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
		DROP_FLOOR = not_wild(function()
			self.player:playerDrop()
		end),
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

		-- Toggle mini map
		TOGGLE_MINIMAP = function()
			self.minimap_mode = self.minimap_mode or 1
			self.minimap_mode = util.boundWrap(self.minimap_mode + 1, 1, 3)
			self:setupMiniMap()
		end,

		EXIT = function()
			local menu menu = require("engine.dialogs.GameMenu").new{
				"resume",
				"achievements",
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

--[[
	self.key:addCommands
	{
		-- Targeting movement
		[{"_LEFT","ctrl","shift"}] = function() self.target.target.entity=nil self.target.target.x = self.target.target.x - 1 end,
		[{"_RIGHT","ctrl","shift"}] = function() self.target.target.entity=nil self.target.target.x = self.target.target.x + 1 end,
		[{"_UP","ctrl","shift"}] = function() self.target.target.entity=nil self.target.target.y = self.target.target.y - 1 end,
		[{"_DOWN","ctrl","shift"}] = function() self.target.target.entity=nil self.target.target.y = self.target.target.y + 1 end,
		[{"_KP4","ctrl","shift"}] = function() self.target.target.entity=nil self.target.target.x = self.target.target.x - 1 end,
		[{"_KP6","ctrl","shift"}] = function() self.target.target.entity=nil self.target.target.x = self.target.target.x + 1 end,
		[{"_KP8","ctrl","shift"}] = function() self.target.target.entity=nil self.target.target.y = self.target.target.y - 1 end,
		[{"_KP2","ctrl","shift"}] = function() self.target.target.entity=nil self.target.target.y = self.target.target.y + 1 end,
		[{"_KP1","ctrl","shift"}] = function() self.target.target.entity=nil self.target.target.x = self.target.target.x - 1 self.target.target.y = self.target.target.y + 1 end,
		[{"_KP3","ctrl","shift"}] = function() self.target.target.entity=nil self.target.target.x = self.target.target.x + 1 self.target.target.y = self.target.target.y + 1 end,
		[{"_KP7","ctrl","shift"}] = function() self.target.target.entity=nil self.target.target.x = self.target.target.x - 1 self.target.target.y = self.target.target.y - 1 end,
		[{"_KP9","ctrl","shift"}] = function() self.target.target.entity=nil self.target.target.x = self.target.target.x + 1 self.target.target.y = self.target.target.y - 1 end,
		[{"_LEFT","ctrl"}] = function() self.target:scan(4) end,
		[{"_RIGHT","ctrl"}] = function() self.target:scan(6) end,
		[{"_UP","ctrl"}] = function() self.target:scan(8) end,
		[{"_DOWN","ctrl"}] = function() self.target:scan(2) end,
		[{"_KP4","ctrl"}] = function() self.target:scan(4) end,
		[{"_KP6","ctrl"}] = function() self.target:scan(6) end,
		[{"_KP8","ctrl"}] = function() self.target:scan(8) end,
		[{"_KP2","ctrl"}] = function() self.target:scan(2) end,
		[{"_KP1","ctrl"}] = function() self.target:scan(1) end,
		[{"_KP3","ctrl"}] = function() self.target:scan(3) end,
		[{"_KP7","ctrl"}] = function() self.target:scan(7) end,
		[{"_KP9","ctrl"}] = function() self.target:scan(9) end,
	}
--]]
	self.key:setCurrent()
end

function _M:setupMouse()
	-- Those 2 locals will be "absorbed" into the mouse event handler function, this is a closure
	local derivx, derivy = 0, 0
	local zoom = 1
	local moving_around = false

	self.mouse:registerZone(Map.display_x, Map.display_y, Map.viewport.width, Map.viewport.height, function(button, mx, my, xrel, yrel)
		-- Move tooltip
		self.tooltip_x, self.tooltip_y = mx, my
		local tmx, tmy = self.level.map:getMouseTile(mx, my)

		if self.key == self.targetmode_key then
			-- Target with mouse
			if button == "none" and xrel and yrel then
				self.target:setSpot(tmx, tmy)
			-- Cancel target
			elseif button ~= "left" and not xrel and not yrel then
				self:targetMode(false, false)
				self.tooltip_x, self.tooltip_y = nil, nil
			-- Accept target
			elseif not xrel and not yrel then
				self.target.target.entity = nil
				self.target.target.x = nil
				self.target.target.y = nil
				self:targetMode(false, false)
				self.tooltip_x, self.tooltip_y = nil, nil
			end
			return
		end

		-- Move
		if button == "left" and not core.key.modState("shift") and not moving_around then
			if self.key == self.normal_key then self.player:mouseMove(tmx, tmy) end

		-- Move map around
		elseif button == "left" and xrel and yrel and core.key.modState("shift") then
			derivx = derivx + xrel
			derivy = derivy + yrel
			game.level.map.changed = true
			if derivx >= game.level.map.tile_w then
				game.level.map.mx = game.level.map.mx - 1
				derivx = derivx - game.level.map.tile_w
			elseif derivx <= -game.level.map.tile_w then
				game.level.map.mx = game.level.map.mx + 1
				derivx = derivx + game.level.map.tile_w
			end
			if derivy >= game.level.map.tile_h then
				game.level.map.my = game.level.map.my - 1
				derivy = derivy - game.level.map.tile_h
			elseif derivy <= -game.level.map.tile_h then
				game.level.map.my = game.level.map.my + 1
				derivy = derivy + game.level.map.tile_h
			end
			game.level.map._map:setScroll(game.level.map.mx, game.level.map.my)
			moving_around = true
		-- Zoom map
--		elseif button == "wheelup" then
--			game.level.map:setZoom(0.1, tmx, tmy)
--		elseif button == "wheeldown" then
--			game.level.map:setZoom(-0.1, tmx, tmy)
		-- Pass any other buttons to the keybinder
		elseif button ~= "none" and not xrel and not yrel then
			self.key:receiveKey(
				button,
				core.key.modState("ctrl") and true or false,
				core.key.modState("shift") and true or false,
				core.key.modState("alt") and true or false,
				core.key.modState("meta") and true or false,
				nil, false, true
			)
		end

		if not xrel and not yrel then moving_around = false end
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
	self.mouse:setCurrent()
end

--- Ask if we realy want to close, if so, save the game first
function _M:onQuit()
	self.player:restStop()

	if not self.quit_dialog then
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
