require "engine.class"
require "engine.GameTurnBased"
require "engine.KeyBind"
local Savefile = require "engine.Savefile"
local DamageType = require "engine.DamageType"
local Zone = require "engine.Zone"
local Map = require "engine.Map"
local Target = require "engine.Target"
local Level = require "engine.Level"
local Birther = require "engine.Birther"

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

local QuitDialog = require "mod.dialogs.Quit"

module(..., package.seeall, class.inherit(engine.GameTurnBased))

collectgarbage("stop")

function _M:init()
	engine.GameTurnBased.init(self, engine.KeyBind.new(), 1000, 100)

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

	if self.level then self:setupDisplayMode() end
end

function _M:newGame()
	self.player = Player.new{name=self.player_name}
	Map:setViewerActor(self.player)
	self:setupDisplayMode()

	local birth = Birther.new(self.player, {"base", "race", "subrace", "sex", "class", "subclass" }, function()
		self.player.wild_x, self.player.wild_y = self.player.default_wilderness[2], self.player.default_wilderness[3]
		self.player.current_wilderness = self.player.default_wilderness[1]
		self:changeLevel(1, self.player.starting_zone)
		print("[PLAYER BIRTH] resolve...")
		self.player:resolve()
		self.player:resolve(nil, true)
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
	Zone:setup{npc_class="mod.class.NPC", grid_class="mod.class.Grid", object_class="mod.class.Object", trap_class="mod.class.Trap"}
	Map:setViewerActor(self.player)
	Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 32, 32, nil, 20, true)
	self.key = engine.KeyBind.new()
end

function _M:onResolutionChange()
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
		print("[DISPLAY MODE] 32x32")
		Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 32, 32, nil, 20, true)
		Map:resetTiles()
		Map.tiles.use_images = true
	elseif self.gfxmode == 2 then
		print("[DISPLAY MODE] 16x16")
		Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 16, 16, nil, 14, true)
		Map:resetTiles()
		Map.tiles.use_images = true
	elseif self.gfxmode == 3 then
		print("[DISPLAY MODE] ASCII")
		Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 16, 16, nil, 14, false)
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
	self:saveSettings("tome.gfxmode", ("tome.gfxmode = %d\n"):format(self.gfxmode))
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
		level:removeEntity(self.player)
	end
end

function _M:changeLevel(lev, zone)
	local old_lev = (self.level and not zone) and self.level.level or -1000
	if zone then
		if self.zone then self.zone:leaveLevel(false, lev, old_lev) end
		self.zone = Zone.new(zone)
	end
	self.zone:getLevel(self, lev, old_lev)

	-- Move back to old wilderness position
	if self.zone.short_name == "wilderness" then
		self.player:move(self.player.wild_x, self.player.wild_y, true)
	else
		if lev > old_lev then
			self.player:move(self.level.ups[1].x, self.level.ups[1].y, true)
		else
			self.player:move(self.level.downs[1].x, self.level.downs[1].y, true)
		end
	end
	self.level:addEntity(self.player)
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
end

--- Called every game turns
-- Does nothing, you can override it
function _M:onTurn()
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

	-- Now the map, if any
	if self.level and self.level.map and self.level.map.finished then
		-- Display the map and compute FOV for the player if needed
		if self.level.map.changed then
			self.level.map:fovESP(self.player.x, self.player.y, self.player.esp.range or 10)
			self.level.map:fov(self.player.x, self.player.y, 20)
			if self.player.lite > 0 then self.level.map:fovLite(self.player.x, self.player.y, self.player.lite) end

			--
			-- Handle Sense spell
			--
			if self.player:attr("detect_range") then
				core.fov.calc_circle(self.player.x, self.player.y, self.player:attr("detect_range"), function(map, lx, ly)
					if game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_sense") then return true end
				end, function(map, lx, ly)
					local ok = false
					if game.player:attr("detect_actor") and game.level.map(lx, ly, game.level.map.ACTOR) then ok = true end
					if game.player:attr("detect_object") and game.level.map(lx, ly, game.level.map.OBJECT) then ok = true end
					if game.player:attr("detect_trap") and game.level.map(lx, ly, game.level.map.TRAP) then
						game.level.map(lx, ly, game.level.map.TRAP):setKnown(self.player, true)
						ok = true
					end

					if ok then
						game.level.map.seens(lx, ly, true)
					end
				end, self)
				game.level.map:redisplay()
			end
		end
		self.level.map:display()

		-- Display the targetting system if active
		self.target:display()

		-- Display a tooltip if available
		local mx, my = core.mouse.get()
		local tmx, tmy = self.level.map:getMouseTile(mx, my)
		local tt = self.level.map:checkEntity(tmx, tmy, Map.ACTOR, "tooltip") or
				self.level.map:checkEntity(tmx, tmy, Map.OBJECT, "tooltip") or
				self.level.map:checkEntity(tmx, tmy, Map.TRAP, "tooltip") or
				self.level.map:checkEntity(tmx, tmy, Map.TERRAIN, "tooltip")
		if tt and self.level.map.seens(tmx, tmy) then
			self.tooltip:set("%s", tt)
			local t = self.tooltip:display()
			mx = mx - self.tooltip.w
			my = my - self.tooltip.h
			if mx < 0 then mx = 0 end
			if my < 0 then my = 0 end
			if t then t:toScreen(mx, my) end
		end
		if self.old_tmx ~= tmx or self.old_tmy ~= tmy then
			self.target.target.x, self.target.target.y = tmx, tmy
		end
		self.old_tmx, self.old_tmy = tmx, tmy
	end

	engine.GameTurnBased.display(self)
end

function _M:targetMode(v, msg, co, typ)
	local old = self.target_mode
	self.target_mode = v

	if not v then
		Map:setViewerFaction(self.always_target and "players" or nil)
		if msg then self.log(type(msg) == "string" and msg or "Tactical display disabled. Press shift+'t' or right mouse click to enable.") end
		self.level.map.changed = true
		self.target:setActive(false)

		if tostring(old) == "exclusive" then
			self.key = self.normal_key
			self.key:setCurrent()
			if self.target_co then
				local co = self.target_co
				self.target_co = nil
				local ok, err = coroutine.resume(co, self.target.target.x, self.target.target.y, self.target.target.entity)
				if not ok and err then error(err) end
			end
		end
	else
		Map:setViewerFaction("players")
		if msg then self.log(type(msg) == "string" and msg or "Tactical display enabled. Press shift+'t' to disable.") end
		self.level.map.changed = true
		self.target:setActive(true, typ)
		self.target_style = "lock"

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
	end
end

function _M:setupCommands()
	self.targetmode_key = engine.KeyBind.new()
	self.targetmode_key:addCommands{ _SPACE=function() self:targetMode(false, false) end, }
	self.targetmode_key:addBinds
	{
		TACTICAL_DISPLAY = function() self:targetMode(false, false) end,
		ACCEPT = function() self:targetMode(false, false) end,
		EXIT = function()
			self.target.target.entity = nil
			self.target.target.x = nil
			self.target.target.y = nil
			self:targetMode(false, false)
		end,
		-- Targeting movement
		RUN_LEFT = function() self.target:freemove(4) end,
		RUN_RIGHT = function() self.target:freemove(6) end,
		RUN_UP = function() self.target:freemove(8) end,
		RUN_DOWN = function() self.target:freemove(2) end,
		RUN_LEFT_DOWN = function() self.target:freemove(1) end,
		RUN_RIGHT_DOWN = function() self.target:freemove(3) end,
		RUN_LEFT_UP = function() self.target:freemove(7) end,
		RUN_RIGHT_UP = function() self.target:freemove(9) end,

		MOVE_LEFT = function() if self.target_style == "lock" then self.target:scan(4) else self.target:freemove(4) end end,
		MOVE_RIGHT = function() if self.target_style == "lock" then self.target:scan(6) else self.target:freemove(6) end end,
		MOVE_UP = function() if self.target_style == "lock" then self.target:scan(8) else self.target:freemove(8) end end,
		MOVE_DOWN = function() if self.target_style == "lock" then self.target:scan(2) else self.target:freemove(2) end end,
		MOVE_LEFT_DOWN = function() if self.target_style == "lock" then self.target:scan(1) else self.target:freemove(1) end end,
		MOVE_RIGHT_DOWN = function() if self.target_style == "lock" then self.target:scan(3) else self.target:freemove(3) end end,
		MOVE_LEFT_UP = function() if self.target_style == "lock" then self.target:scan(7) else self.target:freemove(7) end end,
		MOVE_RIGHT_UP = function() if self.target_style == "lock" then self.target:scan(9) else self.target:freemove(9) end end,
	}

	self.normal_key = self.key
	-- Activate profiler keybinds
	self.key:setupProfiler()

	self.key:addCommands{
		[{"_d","ctrl"}] = function()
			if config.settings.tome.cheat then self:changeLevel(5, "tower-amon-sul") end
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
		HOTKEY_1 = function() self.player:activateHotkey(1) end,
		HOTKEY_2 = function() self.player:activateHotkey(2) end,
		HOTKEY_3 = function() self.player:activateHotkey(3) end,
		HOTKEY_4 = function() self.player:activateHotkey(4) end,
		HOTKEY_5 = function() self.player:activateHotkey(5) end,
		HOTKEY_6 = function() self.player:activateHotkey(6) end,
		HOTKEY_7 = function() self.player:activateHotkey(7) end,
		HOTKEY_8 = function() self.player:activateHotkey(8) end,
		HOTKEY_9 = function() self.player:activateHotkey(9) end,
		HOTKEY_10 = function() self.player:activateHotkey(10) end,
		HOTKEY_11 = function() self.player:activateHotkey(11) end,
		HOTKEY_12 = function() self.player:activateHotkey(12) end,
		HOTKEY_SECOND_1 = function() self.player:activateHotkey(13) end,
		HOTKEY_SECOND_2 = function() self.player:activateHotkey(14) end,
		HOTKEY_SECOND_3 = function() self.player:activateHotkey(15) end,
		HOTKEY_SECOND_4 = function() self.player:activateHotkey(16) end,
		HOTKEY_SECOND_5 = function() self.player:activateHotkey(17) end,
		HOTKEY_SECOND_6 = function() self.player:activateHotkey(18) end,
		HOTKEY_SECOND_7 = function() self.player:activateHotkey(19) end,
		HOTKEY_SECOND_8 = function() self.player:activateHotkey(20) end,
		HOTKEY_SECOND_9 = function() self.player:activateHotkey(21) end,
		HOTKEY_SECOND_10 = function() self.player:activateHotkey(22) end,
		HOTKEY_SECOND_11 = function() self.player:activateHotkey(23) end,
		HOTKEY_SECOND_12 = function() self.player:activateHotkey(24) end,
		HOTKEY_THIRD_1 = function() self.player:activateHotkey(25) end,
		HOTKEY_THIRD_2 = function() self.player:activateHotkey(26) end,
		HOTKEY_THIRD_3 = function() self.player:activateHotkey(27) end,
		HOTKEY_THIRD_4 = function() self.player:activateHotkey(28) end,
		HOTKEY_THIRD_5 = function() self.player:activateHotkey(29) end,
		HOTKEY_THIRD_6 = function() self.player:activateHotkey(30) end,
		HOTKEY_THIRD_7 = function() self.player:activateHotkey(31) end,
		HOTKEY_THIRD_8 = function() self.player:activateHotkey(31) end,
		HOTKEY_THIRD_9 = function() self.player:activateHotkey(33) end,
		HOTKEY_THIRD_10 = function() self.player:activateHotkey(34) end,
		HOTKEY_THIRD_11 = function() self.player:activateHotkey(35) end,
		HOTKEY_THIRD_12 = function() self.player:activateHotkey(36) end,
		HOTKEY_PREV_PAGE = function() self.player:prevHotkeyPage() end,
		HOTKEY_NEXT_PAGE = function() self.player:nextHotkeyPage() end,

		-- Actions
		CHANGE_LEVEL = function()
			local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
			if self.player:enoughEnergy() and e.change_level then
				-- Do not unpause, the player is allowed first move on next level
				self:changeLevel(e.change_zone and e.change_level or self.level.level + e.change_level, e.change_zone)
			else
				self.log("There is no way out of this level here.")
			end
		end,

		REST = function()
			self.player:restInit()
		end,

		PICKUP_FLOOR = function()
			self.player:playerPickup()
		end,
		DROP_FLOOR = function()
			self.player:playerDrop()
		end,
		SHOW_INVENTORY = function()
			self.player:showInventory(nil, self.player:getInven(self.player.INVEN_INVEN), nil, function() end)
		end,
		SHOW_EQUIPMENT = function()
			self.player:showEquipment(nil, nil, function() end)
		end,
		WEAR_ITEM = function()
			self.player:playerWear()
		end,
		TAKEOFF_ITEM = function()
			self.player:playerTakeoff()
		end,
		USE_ITEM = function()
			self.player:playerUseItem()
		end,

		USE_TALENTS = function()
			self.player:useTalents()
		end,

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
			self.gfxmode = util.boundWrap(self.gfxmode + 1, 1, 3)
			self:setupDisplayMode()
		end,

		EXIT = function()
			local menu = require("engine.dialogs.GameMenu").new{"resume", "keybinds", "resolution", "save", "quit"}
			self:registerDialog(menu)
		end,

		TACTICAL_DISPLAY = function()
			if Map.view_faction then
				self.always_target = nil
				Map:setViewerFaction(nil)
			else
				self.always_target = true
				Map:setViewerFaction("players")
			end
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
	-- Those 2 locals will be "absorbed" into the mosue event handler function, this is a closure
	local derivx, derivy = 0, 0

	self.mouse:registerZone(Map.display_x, Map.display_y, Map.viewport.width, Map.viewport.height, function(button, mx, my, xrel, yrel)
		-- Target stuff
		if button == "right" then
			local tmx, tmy = self.level.map:getMouseTile(mx, my)
			-- DEBUG
			if config.settings.tome.cheat then
				game.player:move(tmx, tmy, true)
			end
		-- Move map around
		elseif button == "left" and xrel and yrel then
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
		end
	end)
	-- Scroll message log
	self.mouse:registerZone(self.logdisplay.display_x, self.logdisplay.display_y, self.w, self.h, function(button)
		if button == "wheelup" then self.logdisplay:scrollUp(1) end
		if button == "wheeldown" then self.logdisplay:scrollUp(-1) end
	end, {button=true})
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
	self.log("Saved game.")
end
