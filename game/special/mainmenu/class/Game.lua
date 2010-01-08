require "engine.class"
require "engine.Game"
require "engine.Module"
require "engine.KeyCommand"
local Savefile = require "engine.Savefile"
local Dialog = require "engine.Dialog"
local ButtonList = require "engine.ButtonList"

module(..., package.seeall, class.inherit(engine.Game))

function _M:init()
	engine.Game.init(self, engine.KeyCommand.new())

	self.background = core.display.loadImage("/data/gfx/mainmenu/background.jpg")
end

function _M:run()
	self.mod_list = engine.Module:listModules()
	self.save_list = engine.Module:listSavefiles()

	-- Setup display
	self:selectStepMain()

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()

	self.particle = core.display.loadImage("/data/gfx/particle.png")
	self.gl = self.particle:glTexture()
	self.test = core.particles.newEmitter(1000, {
		base = 1000,

		angle = { 10, 60 }, anglev = { 3, 3000 }, anglea = { 1, 1000 },

		life = { 30, 30 },
		size = { 3, 50 }, sizev = {0, 0}, sizea = {0, 0},

--		x_min = 0, x_max = 0,
--		y_min = 0, y_max = 0,

		r = {0, 0}, rv = {0, 0}, ra = {0, 0},
		g = {0, 0}, gv = {0, 0}, ga = {0, 0},
		b = {255, 255}, bv = {0, 0}, ba = {10, 50},
		a = {0, 0}, av = {0, 0}, aa = {0, 0},
	}, self.gl)
	self.cnt = 0
end

function _M:display()
--[[
	if self.background then
		local bw, bh = self.background:getSize()
		self.background:toScreen((self.w - bw) / 2, (self.h - bh) / 2)
	end

]]
	self.step:display()
	self.step:toScreen(self.step.display_x, self.step.display_y)
	engine.Game.display(self)

	self.cnt = self.cnt + 1
--	if self.cnt < 10 then
	self.test:emit(100)
--	end
	self.test:toScreen(600, 600)
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
		local mod = engine.Module:loadDefinition("/modules/"..req_mod)
		if mod then
			local M = mod.load()
			_G.game = M.new()

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
		local lines = game.mod_list[game.step.selected].description:splitLines(self.w - 8, self.font)
		for i = 1, #lines do
			s:drawColorString(self.font, lines[i], 0, i * self.font:lineSkip())
		end
	end
	self:registerDialog(display_module)

	self.step = ButtonList.new(self.mod_list, 10, 10, self.w * 0.24, (5 + 35) * #self.mod_list, nil, 5)
	self.step:setKeyHandling()
	self.step:setMouseHandling()
	self.step.key:addCommand("_ESCAPE", function() self:unregisterDialog(display_module) self:selectStepMain() end)
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
				mod.load()
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
		local lines = list[game.step.selected].description:splitLines(self.w - 8, self.font)
		for i = 1, #lines do
			s:drawColorString(self.font, lines[i], 0, i * self.font:lineSkip())
		end
	end
	self:registerDialog(display_module)

	self.step = ButtonList.new(list, 10, 10, self.w * 0.24, (5 + 35) * #self.mod_list, nil, 5)
	self.step:select(2)
	self.step:setKeyHandling()
	self.step:setMouseHandling()
	self.step.key:addCommand("_ESCAPE", function() self:unregisterDialog(display_module) self:selectStepMain() end)
end
