-- TE4 - T-Engine 4
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
require "engine.Game"
require "engine.KeyBind"
require "engine.interface.GameMusic"
local Module = require "engine.Module"
local Savefile = require "engine.Savefile"
local Dialog = require "engine.Dialog"
local Tooltip = require "engine.Tooltip"
local ButtonList = require "engine.ButtonList"
local DownloadDialog = require "engine.dialogs.DownloadDialog"

module(..., package.seeall, class.inherit(engine.Game, engine.interface.GameMusic))

function _M:init()
	engine.interface.GameMusic.init(self)
	self.profile_font = core.display.newFont("/data/font/VeraIt.ttf", 14)
	engine.Game.init(self, engine.KeyBind.new())

	self.tooltip = Tooltip.new(nil, 14, nil, colors.DARK_GREY, 400)

	self.background = core.display.loadImage("/data/gfx/mainmenu/background.png")
	self.refuse_threads = true
end

function _M:run()
	self.mod_list = Module:listModules()
	self.save_list = Module:listSavefiles()

	self:checkLogged()
	self:engineVersion()

	-- Setup display
	self:selectStepMain()

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()

	-- Run the current music if any
	self:volumeMusic(config.settings.music.volume)
	self:playMusic("The saga begins.ogg")
end

function _M:checkLogged()
	if profile.auth then
		self.logged_url = "http://te4.org/players/"..profile.auth.page
		local str = "Online Profile: "..profile.auth.name.."[#LIGHT_BLUE##{underline}#"..self.logged_url.."#LAST##{normal}#]"
		local plain = str:removeColorCodes()
		local w, h = self.profile_font:size(plain)
		self.s_log = core.display.newSurface(w, h)
		self.s_log:erase(0, 0, 0)
		self.s_log:drawColorStringBlended(self.profile_font, str, 0, 0, 255, 255, 0)
	else
		self.logged_url = nil
		self.s_log = nil
	end
end

function _M:engineVersion()
	self.s_version = core.display.drawStringBlendedNewSurface(self.profile_font, ("T-Engine4 version: %d.%d.%d"):format(engine.version[1], engine.version[2], engine.version[3]), 185, 225, 0)
end

function _M:tick()
	return true
end

function _M:display()
	if self.background then
		local bw, bh = self.background:getSize()
		self.background:toScreen((self.w - bw) / 2, (self.h - bh) / 2)
	end
	self.step:display()
	self.step:toScreen(self.step.display_x, self.step.display_y)

	if self.s_log then
		local w, h = self.s_log:getSize()
		self.s_log:toScreen(self.w - w, self.h - h)
	end
	local w, h = self.s_version:getSize()
	self.s_version:toScreen(0, self.h - h)

	if self.step.do_tooltip then
		self.tooltip:display()
		self.tooltip:toScreen(5, 5)
	end

	engine.Game.display(self)
end

--- Skip to a module directly ?
function _M:commandLineArgs(args)
	local req_mod = nil
	local req_save = nil
	local req_new = false
	for i, arg in ipairs(args) do
		if arg:find("^%-M") then
			-- Force module loading
			req_mod = arg:sub(3)
		end
		if arg:find("^%-u") then
			-- Force save loading
			req_save = arg:sub(3)
		end
		if arg:find("^%-n") then
			-- Force save loading
			req_new = true
		end
	end

	if req_mod then
		local mod = self.mod_list[req_mod]
		if mod then
			Module:instanciate(mod, req_save or "player", req_new)
		else
			print("Error: module "..req_mod.." not found!")
		end
	end
end

--- Ask if we realy want to close, if so, save the game first
function _M:onQuit()
	os.exit()
end

profile_help_text = [[#LIGHT_GREEN#T-Engine4#LAST# allows you to sync your player profile with the website #LIGHT_BLUE#http://te4.org/#LAST#

This allows you to:
* Play from several computers without having to copy unlocks and achievements.
* Keep track of your modules progression, kill count, ...
* Cool statistics for each module to help sharpen your gameplay style
* Help the game developers balance and refine the game

Later on you will have an online profile page you can show to people to brag.
This is all optional, you are not forced to use this feature at all, but the developers would thank you if you did as it will
make balancing easier.
Online profile requires an internet connection, if not available it will wait and sync when it finds one.]]

function _M:checkFirstTime()
	if not profile.generic.firstrun then
		profile:checkFirstRun()
		Dialog:yesnoLongPopup("First run profile notification", profile_help_text, 400, function(ret)
			if ret then
				self:selectStepOnlineProfile()
			else
				self:selectStepMain()
			end
		end)
	else
		self:selectStepMain()
	end
end

function _M:selectStepMain()
	if self.step and self.step.close then self.step:close() end

	self.step = ButtonList.new({
		{
			name = "Play a new game",
			fct = function()
				self:selectStepNew()
			end,
		},
		{
			name = "Load a saved game",
			fct = function()
				self:selectStepLoad()
			end,
		},
		{
			name = "Player Profile",
			fct = function()
				self:selectStepProfile()
			end,
		},
-- [[
		{
			name = "Install a game module",
			fct = function()
				self:selectStepInstall()
			end,
		},
--]]
		{
			name = "Exit",
			fct = function()
				core.game.exit_engine()
			end,
		},
	}, 400 + 8 + 10, self.h * 0.2, self.w * 0.4, self.h * 0.3)

	if not self.news then
		self.news = profile:getNews()

		if self.news then
			local f = loadstring(self.news.text)
			if f then
				local env = {}
				setfenv(f, env)
				pcall(f)
				if env.text and env.version then
					self.news.text = env.text
					print("Latest engine version available: ", env.version[4], env.version[1], env.version[2], env.version[3])
					self.latest_engine_version = env.version
					if env.link then self.news.link = env.link end
				else
					self.news = nil
				end
			end
		end

		if not self.news then
			self.news = {
				title = 'Welcome to T-Engine and the Tales of Middle-earth',
				text = [[From this interface you can create new characters for the game modules you want to play.

#GOLD#"Tales of Middle-earth"#WHITE# is the default game module, you can also install more by selecting "Install a game module" or by going to http://te4.org/

When inside a module remember you can press Escape to bring up a menu to change keybindings, resolution and other module specific options.

Remember that in most roguelikes death is usually permanent so be careful!

Now go and have some fun!]]
			}
		end

		if self.news.link then
			self.tooltip:set("#AQUAMARINE#%s#WHITE#\n---\n%s\n---\n#LIGHT_BLUE##{underline}#%s#LAST##{normal}#", self.news.title, self.news.text, self.news.link)
		else
			self.tooltip:set("#AQUAMARINE#%s#WHITE#\n---\n%s", self.news.title, self.news.text)
		end
	end
	self.step.do_tooltip = true

--	self:installNewEngine()

	if not self.firstrunchecked then
		-- Check first time run for online profile
		self.firstrunchecked = true
		self:checkFirstTime()
		return
	end

	self.step:setKeyHandling()
	self.step:setMouseHandling()

	if self.s_log then
		local w, h = self.s_log:getSize()
		self.mouse:registerZone(self.w - w, self.h - h, w, h, function(button)
			if button == "left" then util.browserOpenUrl(self.logged_url) end
		end, {button=true})
	end

	if self.news.link then
		self.mouse:registerZone(5, self.tooltip.h - 30, self.tooltip.w, 30, function(button)
			if button == "left" then util.browserOpenUrl(self.news.link) end
		end, {button=true})
	end
end

function _M:selectStepNew()
	if self.step and self.step.close then self.step:close() end

	local display_module = Dialog.new("", self.w * 0.73, self.h, self.w * 0.26, 0, 255)

	for i, mod in ipairs(self.mod_list) do
		mod.fct = function()
			self:registerDialog(require('special.mainmenu.dialogs.EnterName').new(mod))
		end
		mod.onSelect = function()
			display_module.title = mod.long_name
			display_module.changed = true
		end
	end

	display_module.drawDialog = function(self, s)
		if not game.step and not game.mod_list then return end
		local lines = game.mod_list[game.step.selected].description:splitLines(self.w - 8, self.font)
		local r, g, b
		for i = 1, #lines do
			r, g, b = s:drawColorStringBlended(self.font, lines[i], 0, i * self.font:lineSkip(), r, g, b)
		end
	end
	self:registerDialog(display_module)

	self.step = ButtonList.new(self.mod_list, 10, 10, self.w * 0.24, (5 + 35) * #self.mod_list, nil, 5)
	self.step.dialog = display_module
	self:bindKeysToStep()
end

function _M:bindKeysToStep()
	self.step:setKeyHandling()
	self.step:setMouseHandling()
	self.step.key:addBind("EXIT", function() self:unregisterDialog(self.step.dialog) self:selectStepMain() end)
end

function _M:selectStepLoad()
	local found = false
	for i, mod in ipairs(self.save_list) do for j, save in ipairs(mod.savefiles) do found = true break end end
	if not found then
		Dialog:simplePopup("No savefiles", "You do not have any savefiles for any of the installed modules. Play a new game!")
		return
	end

	local display_module = Dialog.new("", self.w * 0.73, self.h, self.w * 0.26, 0, 255)

	local mod_font = core.display.newFont("/data/font/VeraIt.ttf", 14)
	local list = {}
	for i, mod in ipairs(self.save_list) do
		table.insert(list, { name=mod.name, font=mod_font, description="", fct=function() end, onSelect=function() self.step:skipSelected() end})

		for j, save in ipairs(mod.savefiles) do
			save.fct = function()
				Module:instanciate(mod, save.name, false)
			end
			save.onSelect = function()
				display_module.title = save.name
				display_module.changed = true
			end
			table.insert(list, save)
			found = true
		end
	end

	-- Ok some saves to see, proceed
	if self.step and self.step.close then self.step:close() end

	display_module.drawDialog = function(self, s)
		if not game.step and not game.mod_list then return end
		local lines = list[game.step.selected].description:splitLines(self.w - 8, self.font)
		local r, g, b
		for i = 1, #lines do
			r, g, b = s:drawColorStringBlended(self.font, lines[i], 0, i * self.font:lineSkip(), r, g, b)
		end
	end
	self:registerDialog(display_module)

	self.step = ButtonList.new(list, 10, 10, self.w * 0.24, (5 + 25) * #list, nil, 5)
	self.step:select(2)
	self.step:setKeyHandling()
	self.step:setMouseHandling()
	self.step.key:addBind("EXIT", function() self:unregisterDialog(display_module) self:selectStepMain() end)
end

function _M:selectStepInstall()
	local linda, th = Module:loadRemoteList()
	local rawdllist = linda:receive("moduleslist")
	th:join()

	local dllist = {}
	for i, mod in ipairs(rawdllist) do
		if not self.mod_list[mod.short_name] then
			dllist[#dllist+1] = mod
		else
			local lmod = self.mod_list[mod.short_name]
			if mod.version[1] * 1000000 + mod.version[2] * 1000 + mod.version[3] > lmod.version[1] * 1000000 + lmod.version[2] * 1000 + lmod.version[3] then
				dllist[#dllist+1] = mod
			end
		end
	end

	if #dllist == 0 then
		Dialog:simplePopup("No modules available", "There are no modules to install or upgrade.")
		return
	end

	local display_module = Dialog.new("", self.w * 0.73, self.h, self.w * 0.26, 0, 255)

	for i, mod in ipairs(dllist) do
		mod.fct = function()
			local d = DownloadDialog.new("Downloading: "..mod.long_name, mod.download, function(di, data)
				fs.mkdir("/modules")
				local f = fs.open("/modules/"..mod.short_name..".team", "w")
				for i, v in ipairs(data) do f:write(v) end
				f:close()

				-- Relist modules and savefiles
				self.mod_list = Module:listModules()
				self.save_list = Module:listSavefiles()

				if self.mod_list[mod.short_name] then
					Dialog:simplePopup("Success!", "Your new game is now installed, you can play!", function() self:unregisterDialog(display_module) self:selectStepMain() end)
				else
					Dialog:simplePopup("Error!", "The downloaded game does not seem to respond to the test. Please contact contact@te4.org")
				end
			end)
			self:registerDialog(d)
			d:startDownload()
		end
		mod.onSelect = function()
			display_module.title = mod.long_name
			display_module.changed = true
		end
	end

	display_module.drawDialog = function(self, s)
		local lines = dllist[game.step.selected].description:splitLines(self.w - 8, self.font)
		local r, g, b
		for i = 1, #lines do
			r, g, b = s:drawColorStringBlended(self.font, lines[i], 0, i * self.font:lineSkip(), r, g, b)
		end
	end
	self:registerDialog(display_module)

	self.step = ButtonList.new(dllist, 10, 10, self.w * 0.24, (5 + 35) * #dllist, nil, 5)
	self.step:setKeyHandling()
	self.step:setMouseHandling()
	self.step.key:addBind("EXIT", function() self:unregisterDialog(display_module) self:selectStepMain() end)
end

function _M:createProfile(loginItem)
	if self.justlogin then
		profile:performlogin(loginItem.login, loginItem.pass)
		if profile.auth then
			Dialog:simplePopup("Profile logged in!", "Your online profile is active now...", function() self:checkLogged() self:selectStepProfile() end )
		else
			Dialog:simplePopup("Log in rejected", "Couldn't log you...", function() self:selectStepProfile() end )
		end
		return
	end
	profile:newProfile(loginItem.login, loginItem.name, loginItem.pass, loginItem.email)
	if (profile.auth) then
		Dialog:simplePopup("Profile created!", "Your online profile is active now...", function() self:checkLogged() self:selectStepProfile() end )
	else
		Dialog:simplePopup("Profile Failed to authenticate!", "Try logging in in a few moments", function() self:selectStepProfile() end )
	end

end

function _M:selectStepProfile()
	self.step = ButtonList.new({
		{
			name = "Online Profile",
			fct = function()
				self:selectStepOnlineProfile()
			end,
		},
--[[
		{
			name = "Browse Generic Profile",
			fct = function()
				self:selectGenericProfile()
			end,
		},
		{
			name = "Browse Module Profiles",
			fct = function()
				self:selectModuleProfile()
			end,
		},
]]
		{
			name = "Exit",
			fct = function()
				game:unregisterDialog(self)
				self:selectStepMain()
			end,
		},
	}, self.w * 0.3, self.h * 0.2, self.w * 0.4, self.h * 0.3)
	self.step:setKeyHandling()
	self.step:setMouseHandling()
	self.step.key:addBind("EXIT", function() self:unregisterDialog(display_module) self:selectStepMain() end)
end

function _M:selectStepOnlineProfile()
	if (profile.auth) then
		Dialog:yesnoPopup("You are logged in", "Do you want to log out?", function(ret)
			if ret then
				profile:logOut()
				self:checkLogged()
			end
		end)
	else
	local dialogdef = { }
	dialogdef.short = "Login";
	dialogdef.fct = function(login) self:setPlayerLogin(login) end
	Dialog:yesnoLongPopup("You are not registered", "You have no active online profile.\nDo you want to #LIGHT_GREEN#login#LAST# to an existing profile or #LIGHT_GREEN#create#LAST# a new one?", 400, function(ret)
			ret = not ret
			self.justlogin = ret
			dialogdef.name = ret and "login" or "creation"
			dialogdef.justlogin = ret
			self:registerDialog(require('special.mainmenu.dialogs.ProfileLogin').new(dialogdef, profile_help_text))
		end, "Create", "Login")
	end
end

function _M:installNewEngine()
	if not self.latest_engine_version then return end
	print("te4.org told us latest engine is", self.latest_engine_version[4], self.latest_engine_version[5], self.latest_engine_version[1], self.latest_engine_version[2], self.latest_engine_version[3])
	if engine.version_check(self.latest_engine_version) == "newer" then
		local url = ("http://te4.org/dl/engines/%s_%d:%d.%d.%d.teae"):format(self.latest_engine_version[4], self.latest_engine_version[5], self.latest_engine_version[1], self.latest_engine_version[2], self.latest_engine_version[3])
		local d = DownloadDialog.new(("Downloading: T-Engine 4 %d.%d.%d"):format(self.latest_engine_version[1], self.latest_engine_version[2], self.latest_engine_version[3]), url, function(di, data)
			fs.mkdir("/engines")
			local f = fs.open(("/engines/%s-%d_%d.%d.%d.teae"):format(self.latest_engine_version[4], self.latest_engine_version[5], self.latest_engine_version[1], self.latest_engine_version[2], self.latest_engine_version[3]), "w")
			for i, v in ipairs(data) do f:write(v) end
			f:close()

			Dialog:simplePopup("Success!", "The new engine is installed, it will now restart using it.", function() util.showMainMenu() end)
		end)
		self:registerDialog(d)
		d:startDownload()
	end
end
