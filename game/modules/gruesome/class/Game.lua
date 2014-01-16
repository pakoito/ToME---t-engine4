-- ToME - Tales of Middle-Earth
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

require "engine.class"
require "engine.GameTurnBased"
require "engine.interface.GameTargeting"
require "engine.KeyBind"
local Savefile = require "engine.Savefile"
local DamageType = require "engine.DamageType"
local Zone = require "engine.Zone"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Birther = require "engine.Birther"

local PlayerDisplay = require "mod.class.PlayerDisplay"
local Grid = require "mod.class.Grid"
local Actor = require "mod.class.Actor"
local Player = require "mod.class.Player"
local NPC = require "mod.class.NPC"

local LogFlasher = require "engine.LogFlasher"
local DebugConsole = require "engine.DebugConsole"
local FlyingText = require "engine.FlyingText"
local Tooltip = require "engine.Tooltip"
local MapMenu = require "mod.dialogs.MapMenu"

local QuitDialog = require "mod.dialogs.Quit"

module(..., package.seeall, class.inherit(engine.GameTurnBased, engine.interface.GameTargeting))

function _M:init()
	engine.GameTurnBased.init(self, engine.KeyBind.new(), 1000, 100)

	-- Pause at birth
	self.paused = true

	-- Same init as when loaded from a savefile
	self:loaded()
end

function _M:run()
	self.flash = LogFlasher.new(0, 0, self.w, 20, nil, nil, nil, {255,255,255}, {0,0,0})
	self.player_display = PlayerDisplay.new()
	self.tooltip = Tooltip.new(nil, nil, {255,255,255}, {30,30,30})
	self.flyers = FlyingText.new()
	self:setFlyingText(self.flyers)

	self.log = function(style, ...) if type(style) == "number" then self.flash(style, ...) else self.flash(self.flash.NEUTRAL, style, ...) end end
	self.logSeen = function(e, style, ...) if e and self.level.map.seens(e.x, e.y) then self.log(style, ...) end end
	self.logPlayer = function(e, style, ...) if e == self.player then self.log(style, ...) end end

	self.log(self.flash.GOOD, "Welcome to #GREY##{bold}#Gruesome!#{normal}#")

	-- Setup inputs
	self:setupCommands()
	self:setupMouse()

	-- Starting from here we create a new game
	if not self.player then self:newGame() end

	-- Setup the targetting system
	engine.interface.GameTargeting.init(self)

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()

	if self.level then self:setupDisplayMode() self:onTurn() end
end

function _M:newGame()
	self.player = Player.new{name=self.player_name, game_ender=true}
	Map:setViewerActor(self.player)
	self:setupDisplayMode()

	self.creating_player = true
	local birth = Birther.new(nil, self.player, {"base"}, function()
		self:changeLevel(20, "dungeon")
		print("[PLAYER BIRTH] resolve...")
		self.player:resolve()
		self.player:resolve(nil, true)
		self.player.energy.value = self.energy_to_act
		self.paused = true
		self.creating_player = false
		self:onTurn()
		print("[PLAYER BIRTH] resolved!")
	end)
	self:registerDialog(birth)
end

function _M:loaded()
	engine.GameTurnBased.loaded(self)
	Zone:setup{npc_class="mod.class.NPC", grid_class="mod.class.Grid", }
	Map:setViewerActor(self.player)
	Map:setViewPort(0, 20, self.w, math.floor(self.h * 0.80) - 20, 12, 16, "/data/font/FSEX300.ttf", 16, true)
	self.key = engine.KeyBind.new()
end

function _M:setupDisplayMode()
	Map:setViewPort(0, 20, self.w, math.floor(self.h * 0.80) - 20, 12, 16, "/data/font/FSEX300.ttf", 16, true)
	Map:resetTiles()
	Map.tiles.use_images = false

	if self.level then
		self.level.map:recreate()
		engine.interface.GameTargeting.init(self)
		self.level.map:moveViewSurround(self.player.x, self.player.y, 8, 8)
	end
end

function _M:save()
	return class.save(self, self:defaultSavedFields{}, true)
end

function _M:getSaveDescription()
	return {
		name = self.player.name,
		description = ([[Exploring level %d of %s.]]):format(self.level.level, self.zone.name),
	}
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

	if lev > old_lev then
		self.player:move(self.level.default_up.x, self.level.default_up.y, true)
	else
		self.player:move(self.level.default_down.x, self.level.default_down.y, true)
	end
	self.level:addEntity(self.player)
end

function _M:getPlayer()
	return self.player
end

function _M:tick()
	if self.level then
		self:targetOnTick()

		engine.GameTurnBased.tick(self)
		-- Fun stuff: this can make the game realtime, although calling it in display() will make it work better
		-- (since display is on a set FPS while tick() ticks as much as possible
		-- engine.GameEnergyBased.tick(self)
	end
	-- When paused (waiting for player input) we return true: this means we wont be called again until an event wakes us
	if self.paused and not savefile_pipe.saving then return true end
end

--- Called every game turns
-- Does nothing, you can override it
function _M:onTurn()
	-- The following happens only every 10 game turns (once for every turn of 1 mod speed actors)
	if self.turn % 10 ~= 0 then return end

	-- Process overlay effects
	self.level.map:processEffects()
end

function _M:display(nb_keyframe)
	-- If switching resolution, blank everything but the dialog
	if self.change_res_dialog then engine.GameTurnBased.display(self, nb_keyframe) return end

	-- Now the map, if any
	if self.level and self.level.map and self.level.map.finished then
		if self.level.map.changed then
			-- Clean FOV before computing it
			self.level.map:cleanFOV()
			self.player:playerFOV()
			for uid, a in pairs(game.level.entities) do
				if a ~= self.player and not a:attr("blind") then
					-- Compute both the normal and the lite FOV, using cache
					a:computeFOVBeam(a.lite, a.dir, a.angle, "block_sight", function(x, y, dx, dy, sqdist)
						if self.level.map.seens(x, y) then
							self.level.map:applyLite(x, y, 1)
							if self.level.map(x, y, Map.ACTOR) == self.player then
								self.player:takeHit(1, a)
							end
						end
					end, true, false, true)
				end
			end
		end

		self.level.map:display(nil, nil, nb_keyframe)

		-- Display the targetting system if active
		self.target:display()
	end

	-- We display the player's interface
	self.flash:toScreen(nb_keyframe)
	self.player_display:toScreen()
	if self.player then self.player.changed = false end

	-- Tooltip is displayed over all else
	self:targetDisplayTooltip(self.w, self.h)

	engine.GameTurnBased.display(self, nb_keyframe)
end

--- Setup the keybinds
function _M:setupCommands()
	-- Make targeting work
	self.normal_key = self.key
	self:targetSetupKey()

	-- One key handled for normal function
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
		HOTKEY_1 = function() self.player:activateHotkey(1) end,
		HOTKEY_2 = function() self.player:activateHotkey(2) end,
		HOTKEY_3 = function() self.player:activateHotkey(3) end,

		-- Actions
		CHANGE_LEVEL = function()
			local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
			if self.player:enoughEnergy() and e.change_level then
				self:changeLevel(e.change_zone and e.change_level or self.level.level + e.change_level, e.change_zone)
			else
				self.log("There is no way out of this level here.")
			end
		end,

		USE_TALENTS = function()
			self.player:useTalents()
		end,

		SAVE_GAME = function()
			self:saveGame()
		end,

		-- Exit the game
		QUIT_GAME = function()
			self:onQuit()
		end,

		EXIT = function()
			local menu menu = require("engine.dialogs.GameMenu").new{
				"resume",
				"keybinds",
				"video",
				"save",
				"quit"
			}
			self:registerDialog(menu)
		end,

		-- Lua console, you probably want to disable it for releases
		LUA_CONSOLE = function()
			self:registerDialog(DebugConsole.new())
		end,

		LOOK_AROUND = function()
			self.flash:empty(true)
			self.flash(self.flash.GOOD, "Looking around... (direction keys to select interesting things, shift+direction keys to move freely)")
			local co = coroutine.create(function() self.player:getTarget{type="hit", no_restrict=true, range=2000} end)
			local ok, err = coroutine.resume(co)
			if not ok and err then print(debug.traceback(co)) error(err) end
		end,
	}
	self.key:setCurrent()
end

function _M:setupMouse(reset)
	if reset then self.mouse:reset() end
	self.mouse:registerZone(Map.display_x, Map.display_y, Map.viewport.width, Map.viewport.height, function(button, mx, my, xrel, yrel, bx, by, event)
		-- Handle targeting
		if self:targetMouse(button, mx, my, xrel, yrel, event) then return end

		-- Handle Use menu
		if button == "right" and not xrel and not yrel and event == "button" then self:mouseRightClick(mx, my) return end

		-- Handle the mouse movement/scrolling
		self.player:mouseHandleDefault(self.key, self.key == self.normal_key, button, mx, my, xrel, yrel, event)
	end)
	self.mouse:setCurrent()
end

--- Right mouse click on the map
function _M:mouseRightClick(mx, my)
	local tmx, tmy = self.level.map:getMouseTile(mx, my)
	self:registerDialog(MapMenu.new(mx, my, tmx, tmy))
end


--- Ask if we really want to close, if so, save the game first
function _M:onQuit()
	self.player:restStop()

	if not self.quit_dialog then
		self.quit_dialog = QuitDialog.new()
		self:registerDialog(self.quit_dialog)
	end
end

--- Requests the game to save
function _M:saveGame()
	-- savefile_pipe is created as a global by the engine
	savefile_pipe:push(self.save_name, "game", self)
	self.log("Saving game...")
end
