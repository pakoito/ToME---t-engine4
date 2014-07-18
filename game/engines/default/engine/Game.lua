-- TE4 - T-Engine 4
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
require "engine.Mouse"
require "engine.DebugConsole"
local tween = require "tween"
local Shader = require "engine.Shader"

--- Represent a game
-- A module should subclass it and initialize anything it needs to play inside
module(..., package.seeall, class.make)

--- Constructor
-- Sets up the default keyhandler.
-- Also requests the display size and stores it in "w" and "h" properties
function _M:init(keyhandler)
	self.key = keyhandler
	self.level = nil
	self.w, self.h, self.fullscreen = core.display.size()
	self.dialogs = {}
	self.save_name = ""
	self.player_name = ""

	self.mouse = engine.Mouse.new()
	self.mouse:setCurrent()

	self.uniques = {}

	self.__savefile_version_tokens = {}

	self:defaultMouseCursor()
end

function _M:log() end
function _M:logSeen() end

--- Default mouse cursor
function _M:defaultMouseCursor()
	local UIBase = require "engine.ui.Base"
	if fs.exists("/data/gfx/"..UIBase.ui.."-ui/mouse.png") and fs.exists("/data/gfx/"..UIBase.ui.."-ui/mouse-down.png") then
		self:setMouseCursor("/data/gfx/"..UIBase.ui.."-ui/mouse.png", "/data/gfx/"..UIBase.ui.."-ui/mouse-down.png", -4, -4)
	else
		self:setMouseCursor("/data/gfx/ui/mouse.png", "/data/gfx/ui/mouse-down.png", -4, -4)
	end
end

function _M:setMouseCursor(mouse, mouse_down, offsetx, offsety)
	if type(mouse) == "string" then mouse = core.display.loadImage(mouse) end
	if type(mouse_down) == "string" then mouse_down = core.display.loadImage(mouse_down) end
	if mouse then
		self.__cursor = { up=mouse, down=(mouse_down or mouse), ox=offsetx, oy=offsety }
		if config.settings.mouse_cursor then
			core.display.setMouseCursor(self.__cursor.ox, self.__cursor.oy, self.__cursor.up, self.__cursor.down)
		else
			core.display.setMouseCursor(0, 0, nil, nil)
		end
	end
end

function _M:updateMouseCursor()
	if self.__cursor then
		if config.settings.mouse_cursor then
			core.display.setMouseCursor(self.__cursor.ox, self.__cursor.oy, self.__cursor.up, self.__cursor.down)
		else
			core.display.setMouseCursor(0, 0, nil, nil)
		end
	end
end

function _M:loaded()
	self.w, self.h, self.fullscreen = core.display.size()
	self.dialogs = {}
	self.key = engine.Key.current
	self.mouse = engine.Mouse.new()
	self.mouse:setCurrent()

	self.__coroutines = self.__coroutines or {}

	self:setGamma(config.settings.gamma_correction / 100)
end

--- Defines the default fields to be saved by the savefile code
function _M:defaultSavedFields(t)
	local def = {
		w=true, h=true, zone=true, player=true, level=true, entities=true,
		energy_to_act=true, energy_per_tick=true, turn=true, paused=true, save_name=true,
		always_target=true, gfxmode=true, uniques=true, object_known_types=true,
		memory_levels=true, achievement_data=true, factions=true, playing_musics=true,
		state=true,
		__savefile_version_tokens = true, bad_md5_loaded = true,
		__persistent_hooks=true,
	}
	table.merge(def, t)
	return def
end

--- Sets the player name
function _M:setPlayerName(name)
	self.save_name = name
	self.player_name = name
end

--- Do not touch
function _M:prerun()
	if self.__persistent_hooks then for _, h in ipairs(self.__persistent_hooks) do
		self:bindHook(h.hook, h.fct)
	end end
end

--- Starts the game
-- Modules should reimplement it to do whatever their game needs
function _M:run()
end

--- Checks if the current character is "tainted" by cheating
function _M:isTainted()
	return false
end

--- Sets the current level
-- @param level an engine.Level (or subclass) object
function _M:setLevel(level)
	self.level = level
end

--- Tells the game engine to play this game
function _M:setCurrent()
	core.game.set_current_game(self)
	_M.current = self
end

--- Displays the screen
-- Called by the engine core to redraw the screen every frame
-- @param nb_keyframes The number of elapsed keyframes since last draw (this can be 0). This is set by the engine
function _M:display(nb_keyframes)
	nb_keyframes = nb_keyframes or 1
	if self.flyers then
		self.flyers:display(nb_keyframes)
	end

	if not self.suppressDialogs and #self.dialogs then
		local last = self.dialogs[#self.dialogs]
		for i = last and last.__show_only and #self.dialogs or 1, #self.dialogs do
			local d = self.dialogs[i]
			d:display()
			d:toScreen(d.display_x, d.display_y, nb_keyframes)
		end
	end

	-- Check profile thread events
	local evt = profile:popEvent()
	while evt do
		self:handleProfileEvent(evt)
		evt = profile:popEvent()
	end

	-- Check timers
	if self._timers_cb and nb_keyframes > 0 then
		local new = {}
		local exec = {}
		for cb, frames in pairs(self._timers_cb) do
			frames = frames - nb_keyframes
			if frames <= 0 then exec[#exec+1] = cb
			else new[cb] = frames end
		end
		if next(new) then self._timers_cb = new
		else self._timers_cb = nil end
		for _, cb in ipairs(exec) do cb() end
	end

	-- Update tweening engine
	if nb_keyframes > 0 then tween.update(nb_keyframes) end
end

--- Register a timer
-- The callback function will be called in the given number of seconds
function _M:registerTimer(seconds, cb)
	self._timers_cb = self._timers_cb or {}
	self._timers_cb[cb] = seconds * 30
end

--- Called when the game is focused/unfocused
function _M:idling(focus)
	self.has_os_focus = focus
--	print("Game got focus/unfocus", focus)
end

--- Receives a profile event
-- Usualy this just transfers it to the PlayerProfile class but you can overload it to handle special stuff
function _M:handleProfileEvent(evt)
	return profile:handleEvent(evt)
end

--- Returns the player
-- Reimplement it in your module, this can just return nil if you dont want/need
-- the engine adjusting stuff to the player or if you have many players or whatever
-- @param main if true the game should try to return the "main" player, if any
function _M:getPlayer(main)
	return nil
end

--- Returns current "campaign" name
-- Defaults to "default"
function _M:getCampaign()
	return "default"
end

--- Says if this savefile is usable or not
-- Reimplement it in your module, returning false when the player is dead
function _M:isLoadable()
	return true
end

--- Gets/increment the savefile version
-- @param token if "new" this will create a new allowed save token and return it. Otherwise this checks the token against the allowed ones and returns true if it is allowed
function _M:saveVersion(token)
	if token == "new" then
		token = util.uuid()
		self.__savefile_version_tokens[token] = true
		return token
	end
	return self.__savefile_version_tokens[token]
end

--- This is the "main game loop", do something here
function _M:tick()
	-- Check out any possible errors
	local errs = core.game.checkError()
	if errs then
		self:registerDialog(require("engine.dialogs.ShowErrorStack").new(errs))
	end

	local stop = {}
	local id, co = next(self.__coroutines)
	while id do
		local ok, err = coroutine.resume(co)
		if not ok then
			print(debug.traceback(co))
			print("[COROUTINE] error", err)
		end
		if coroutine.status(co) == "dead" then
			stop[#stop+1] = id
		end
		id, co = next(self.__coroutines, id)
	end
	if #stop > 0 then
		for i = 1, #stop do
			self.__coroutines[stop[i]] = nil
			print("[COROUTINE] dead", stop[i])
		end
	end

	Shader:cleanup()

	if self.cleanSounds then self:cleanSounds() end

	self:onTickEndExecute()
end

--- Run all registered tick end functions
-- Usualy jsut let the engine call it
function _M:onTickEndExecute()
	if self.on_tick_end and #self.on_tick_end > 0 then
		local fs = self.on_tick_end
		self.on_tick_end = {}
		for i = 1, #fs do fs[i]() end
	end
	self.on_tick_end_names = nil
end

--- Register things to do on tick end
function _M:onTickEnd(f, name)
	self.on_tick_end = self.on_tick_end or {}

	if name then
		self.on_tick_end_names = self.on_tick_end_names or {}
		if self.on_tick_end_names[name] then return end
		self.on_tick_end_names[name] = f
	end

	self.on_tick_end[#self.on_tick_end+1] = f
end

--- Called when a zone leaves a level
-- Going from "old_lev" to "lev", leaving level "level"
function _M:leaveLevel(level, lev, old_lev)
end

--- Called by the engine when the user tries to close the module
function _M:onQuit()
end

--- Called by the engine when the user tries to close the window
function _M:onExit()
	if core.steam then core.steam.exit() end
	core.game.exit_engine()
end

--- Sets up a text flyers
function _M:setFlyingText(fl)
	self.flyers = fl
end

--- Registers a dialog to display
function _M:registerDialog(d)
	table.insert(self.dialogs, d)
	self.dialogs[d] = #self.dialogs
	d.__stack_id = #self.dialogs
	if d.key then d.key:setCurrent() end
	if d.mouse then d.mouse:setCurrent() end
	if d.on_register then d:on_register() end
	if self.onRegisterDialog then self:onRegisterDialog(d) end
end

--- Registers a dialog to display somewher in the stack
-- @param d the dialog
-- @param pos the stack position (1=top, 2=second, ...)
function _M:registerDialogAt(d, pos)
	if pos == 1 then return self:registerDialog(d) end
	table.insert(self.dialogs, #self.dialogs - (pos - 2), d)
	for i = 1, #self.dialogs do
		local dd = self.dialogs[i]
		self.dialogs[dd] = i
		dd.__stack_id = i
	end
	if d.on_register then d:on_register() end
	if self.onRegisterDialog then self:onRegisterDialog(d) end
end

--- Replaces a dialog to display with an other
function _M:replaceDialog(src, dest)
	local id = src.__stack_id

	-- Remove old one
	self.dialogs[src] = nil

	-- Update
	self.dialogs[id] = dest
	self.dialogs[dest] = id
	dest.__stack_id = id

	-- Give focus
	if id == #self.dialogs then
		if dest.key then dest.key:setCurrent() end
		if dest.mouse then dest.mouse:setCurrent() end
	end
	if dest.on_register then dest:on_register(src) end
end

--- Undisplay a dialog, removing its own keyhandler if needed
function _M:unregisterDialog(d)
	if not self.dialogs[d] then return end
	table.remove(self.dialogs, self.dialogs[d])
	self.dialogs[d] = nil
	d:cleanup()
	d:unload()
	-- Update positions
	for i, id in ipairs(self.dialogs) do id.__stack_id = i self.dialogs[id] = i end

	local last = (#self.dialogs > 0) and self.dialogs[#self.dialogs] or self
	if last.key then last.key:setCurrent() end
	if last.mouse then last.mouse:setCurrent() end
	if self.onUnregisterDialog then self:onUnregisterDialog(d) end
	if last.on_recover_focus then last:on_recover_focus() end
end

--- Do we have a specific dialog
function _M:hasDialog(d)
	return self.dialogs[d] and true or false
end

--- Do we have a dialog running
function _M:hasDialogUp(nb)
	nb = nb or 0
	return #self.dialogs > nb
end

--- The C core gives us command line arguments
function _M:commandLineArgs(args)
	for i, a in ipairs(args) do
		print("Command line: ", a)
	end
end

--- Called by savefile code to describe the current game
function _M:getSaveDescription()
	return {
		name = "player",
		description = [[Busy adventuring!]],
	}
end

--- Save a settings file
function _M:saveSettings(file, data)
	core.game.resetLocale()
	local restore = fs.getWritePath()
	fs.setWritePath(engine.homepath)
	local f, msg = fs.open("/settings/"..file..".cfg", "w")
	if f then
		f:write(data)
		f:close()
	else
		print("WARNING: could not save settings in ", file, "::", data, "::", msg)
	end
	if restore then fs.setWritePath(restore) end
end

available_resolutions =
{
	["800x600 Windowed"] 	= {800, 600, false},
	["1024x768 Windowed"] 	= {1024, 768, false},
	["1200x1024 Windowed"] 	= {1200, 1024, false},
	["1280x720 Windowed"] 	= {1280, 720, false},
	["1600x900 Windowed"] 	= {1600, 900, false},
	["1600x1200 Windowed"] = {1600, 1200, false},
--	["800x600 Fullscreen"] = {800, 600, true},
--	["1024x768 Fullscreen"] = {1024, 768, true},
--	["1200x1024 Fullscreen"] = {1200, 1024, true},
--	["1600x1200 Fullscreen"] = {1600, 1200, true},
}
local list = core.display.getModesList()
for _, m in ipairs(list) do
	local ms = m.w.."x"..m.h.." Fullscreen"
	if m.w >= 800 and m.h >= 600 and not available_resolutions[ms] then
		available_resolutions[ms] = {m.w, m.h, true}
	end
end

--- Change screen resolution
function _M:setResolution(res, force)
	local r = available_resolutions[res]
	if force and not r then
		local b = false
		local _, _, w, h, f = res:find("([0-9][0-9][0-9]+)x([0-9][0-9][0-9]+)(.*)")
		w = tonumber(w)
		h = tonumber(h)
		if f == " Fullscreen" then
			f = true
		elseif f == " Borderless" then
			f = false
			b = true
		elseif f ~= " Windowed" then
			-- If no windowed/fullscreen option sent, use the old value.
			-- If no old value, opt for windowed mode.
			f = self.fullscreen
		else
			f = false
		end 
		if w and h then r = {w, h, f, b} end
	end
	if not r then return false, "unknown resolution" end

	-- Change the window size
	print("setResolution: switching resolution to", res, r[1], r[2], r[3], r[4], force and "(forced)")
	local old_w, old_h, old_f, old_b = self.w, self.h, self.fullscreen, self.borderless
	core.display.setWindowSize(r[1], r[2], r[3], r[4])
	
	-- Don't write self.w/h/fullscreen yet
	local new_w, new_h, new_f, new_b = core.display.size()

	-- Check if a resolution change actually happened
	if new_w ~= old_w or new_h ~= old_h or new_f ~= old_f or new_b ~= old_b then
		print("setResolution: performing onResolutionChange...\n")
		self:onResolutionChange()
		-- onResolutionChange saves settings...
		-- self:saveSettings("resolution", ("window.size = %q\n"):format(res))
	else
		print("setResolution: resolution change requested from same resolution!\n")
	end
end

--- Called when screen resolution changes
function _M:onResolutionChange()
	local ow, oh, of, ob = self.w, self.h, self.fullscreen, self.borderless

	-- Save old values for a potential revert
	if game and not self.change_res_dialog_oldw then
		print("onResolutionChange: saving current resolution for potential revert.")
		self.change_res_dialog_oldw, self.change_res_dialog_oldh, self.change_res_dialog_oldf = ow, oh, of
	end
	
	-- Get new resolution and save
	self.w, self.h, self.fullscreen, self.borderless = core.display.size()
	config.settings.window.size = ("%dx%d%s"):format(self.w, self.h, self.fullscreen and " Fullscreen" or (self.borderless and " Borderless" or " Windowed"))	
	
	self:saveSettings("resolution", ("window.size = '%s'\n"):format(config.settings.window.size))
	print("onResolutionChange: resolution changed to ", self.w, self.h, "from", ow, oh)

	-- We do not even have a game yet
	if not game then
		print("onResolutionChange: no game yet!") 
		return 
	end
	
	-- Redraw existing dialogs
	self:updateVideoDialogs()

	-- No actual resize
	if ow == self.w and oh == self.h 
		and of == self.fullscreen and ob == self.borderless then 
		print("onResolutionChange: no actual resize, no confirm dialog.")
		return 
	end

	-- Extra game logic to be updated on a resize
	if not self:checkResolutionChange(self.w, self.h, ow, oh) then
		print("onResolutionChange: checkResolutionChange returned false, no confirm dialog.")
		return
	end

	-- Do not repop if we just revert back
	if self.change_res_dialog and type(self.change_res_dialog) == "string" and self.change_res_dialog == "revert" then
		print("onResolutionChange: Reverting, no popup.")
		return 
	end
	
	-- Unregister old dialog if there was one
	if self.change_res_dialog and type(self.change_res_dialog) == "table" then 
		print("onResolutionChange: Unregistering dialog")
		self:unregisterDialog(self.change_res_dialog) 
	end
	
	-- Are you sure you want to save these settings?  Somewhat obnoxious...
--	self.change_res_dialog = require("engine.ui.Dialog"):yesnoPopup("Resolution changed", "Accept the new resolution?", function(ret)
--		if ret then
--			if not self.creating_player then self:saveGame() end
--			util.showMainMenu(false, nil, nil, self.__mod_info.short_name, self.save_name, false)
--		else
--			self.change_res_dialog = "revert"
--			self:setResolution(("%dx%d%s"):format(self.change_res_dialog_oldw, self.change_res_dialog_oldh, self.change_res_dialog_oldf and " Fullscreen" or " Windowed"), true)
--			self.change_res_dialog = nil
--			self.change_res_dialog_oldw, self.change_res_dialog_oldh, self.change_res_dialog_oldf = nil, nil, nil
--		end
--	end, "Accept", "Revert")
	print("onResolutionChange: (Would have) created popup.")
	
end

--- Checks if we must reload to change resolution
function _M:checkResolutionChange(w, h, ow, oh)
	return false
end

--- Called when the game window is moved around
function _M:onWindowMoved(x, y)
	config.settings.window.pos = config.settings.window.pos or {}
	config.settings.window.pos.x = x
	config.settings.window.pos.y = y
	self:saveSettings("window_pos", ("window.pos = {x=%d, y=%d}\n"):format(x, y))
	
	-- Redraw existing dialogs
	self:updateVideoDialogs()
end

--- Update any registered video options dialogs with the latest changes.
function _M:updateVideoDialogs()
	-- Update the video settings dialogs if any are registered.
	-- We don't know which dialog (if any) is VideoOptions, so iterate through.
	--
	-- Note: If the title of the video options dialog changes, this
	-- functionality will break.
	for i, v in ipairs(self.dialogs) do
		if v.title == "Video Options" then
			v.c_list:drawTree()
		end
	end
end

--- Sets the gamma of the window
-- By default it uses SDL gamma settings, but it can also use a fullscreen shader if available
function _M:setGamma(gamma)
	if self.support_shader_gamma and self.full_fbo_shader then
		-- Tell the shader which gamma to use
		self.full_fbo_shader:setUniform("gamma", gamma)
		-- Remove SDL gamma correction
		core.display.setGamma(1)
		print("[GAMMA] Setting gamma correction using fullscreen shader", gamma)
	else
		core.display.setGamma(gamma)
		print("[GAMMA] Setting gamma correction using SDL", gamma)
	end
end

--- Requests the game to save
function _M:saveGame()
end

--- Saves the highscore of the current char
function _M:registerHighscore()
end

--- Add a coroutine to the pool
-- Coroutines registered will be run each game tick
function _M:registerCoroutine(id, co)
	print("[COROUTINE] registering", id, co)
	self.__coroutines[id] = co
end

--- Get the coroutine corresponding to the id
function _M:getCoroutine(id)
	return self.__coroutines[id]
end

--- Ask a registered coroutine to cancel
-- The coroutine must accept a "cancel" action
function _M:cancelCoroutine(id)
	local co = self.__coroutines[id]
	if not co then return end
	local ok, err = coroutine.resume(co, "cancel")
	if not ok then
		print(debug.traceback(co))
		print("[COROUTINE] error", err)
	end
	if coroutine.status(co) == "dead" then
		self.__coroutines[id] = nil
	else
		error("Told coroutine "..id.." to cancel, but it is not dead!")
	end
end

--- Take a screenshot of the game
-- @param for_savefile The screenshot will be used for savefile display
function _M:takeScreenshot(for_savefile)
	if for_savefile then
		self.suppressDialogs = true
		core.display.forceRedraw()
		local sc = core.display.getScreenshot(self.w / 4, self.h / 4, self.w / 2, self.h / 2)
		self.suppressDialogs = nil
		core.display.forceRedraw()
		return sc
	else
		return core.display.getScreenshot(0, 0, self.w, self.h)
	end
end

--- Take a screenshot of the game
-- @param for_savefile The screenshot will be used for savefile display
function _M:saveScreenshot()
	local s = self:takeScreenshot()
	if not s then return end
	fs.mkdir("/screenshots")

	local file = ("/screenshots/%s-%d.png"):format(self.__mod_info.version_string, os.time())
	local f = fs.open(file, "w")
	f:write(s)
	f:close()

	local Dialog = require "engine.ui.Dialog"

	if core.steam then
		local desc = self:getSaveDescription()
		core.steam.screenshot(file, self.w, self.h, desc.description)
		Dialog:simpleLongPopup("Screenshot taken!", "Screenshot should appear in your Steam client's #LIGHT_GREEN#Screenshots Library#LAST#.\nAlso available on disk: "..fs.getRealPath(file), 600)
	else
		Dialog:simplePopup("Screenshot taken!", "File: "..fs.getRealPath(file))
	end
end

--- Register a hook that will be saved in the savefile
-- Obviously only run it once per hook per save
function _M:registerPersistentHook(hook, fct)
	self.__persistent_hooks = self.__persistent_hooks or {}
	table.insert(self.__persistent_hooks, {hook=hook, fct=fct})
	self:bindHook(hook, fct)
end

-- get a text-compatible texture for a game entity (overload in module)
function _M:getGenericTextTiles(en)
	return "" 
end
