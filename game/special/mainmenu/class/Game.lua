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
local Module = require "engine.Module"
local Savefile = require "engine.Savefile"
local Dialog = require "engine.Dialog"
local ButtonList = require "engine.ButtonList"
local DownloadDialog = require "engine.dialogs.DownloadDialog"

module(..., package.seeall, class.inherit(engine.Game))

function _M:init()
	engine.Game.init(self, engine.KeyBind.new())

	self.background = core.display.loadImage("/data/gfx/mainmenu/background.jpg")
end

function _M:run()
	self.mod_list = Module:listModules()
	self.save_list = Module:listSavefiles()

	-- Setup display
	self:selectStepMain()

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()
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
			local M, W = mod.load()
			_G.game = M.new()

			-- Load the world, or make a new one
			if W then
				local save = Savefile.new("")
				_G.world = save:loadWorld()
				save:close()
				if not _G.world then
					_G.world = W.new()
				end
				_G.world:run()
			end

			-- Delete the corresponding savefile if any
			if req_save then _G.game:setPlayerName(req_save) end
			local save = engine.Savefile.new(_G.game.save_name)
			if save:check() and not req_new then
				_G.game = save:loadGame()
			else
				save:delete()
			end
			save:close()
			_G.game:run()
		else
			print("Error: module "..req_mod.." not found!")
		end
	end
end

--- Ask if we realy want to close, if so, save the game first
function _M:onQuit()
	os.exit()
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
--[[
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
	}, self.w * 0.3, self.h * 0.2, self.w * 0.4, self.h * 0.3)
	self.step:setKeyHandling()
	self.step:setMouseHandling()
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
			r, g, b = s:drawColorString(self.font, lines[i], 0, i * self.font:lineSkip(), r, g, b)
		end
	end
	self:registerDialog(display_module)

	self.step = ButtonList.new(self.mod_list, 10, 10, self.w * 0.24, (5 + 35) * #self.mod_list, nil, 5)
	self.step:setKeyHandling()
	self.step:setMouseHandling()
	self.step.key:addBind("EXIT", function() self:unregisterDialog(display_module) self:selectStepMain() end)
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
				local M, W = mod.load()

				-- Load the world, or make a new one
				if W then
					local save = Savefile.new("")
					_G.world = save:loadWorld()
					save:close()
					if not _G.world then
						_G.world = W.new()
					end
					_G.world:run()
				end

				local save = Savefile.new(save.short_name)
				_G.game = save:loadGame()
				save:close()
				_G.game:run()
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
			r, g, b = s:drawColorString(self.font, lines[i], 0, i * self.font:lineSkip(), r, g, b)
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
			r, g, b = s:drawColorString(self.font, lines[i], 0, i * self.font:lineSkip(), r, g, b)
		end
	end
	self:registerDialog(display_module)

	self.step = ButtonList.new(dllist, 10, 10, self.w * 0.24, (5 + 35) * #dllist, nil, 5)
	self.step:setKeyHandling()
	self.step:setMouseHandling()
	self.step.key:addBind("EXIT", function() self:unregisterDialog(display_module) self:selectStepMain() end)
end
