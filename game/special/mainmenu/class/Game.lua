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
end

function _M:run()
	self.mod_list = engine.Module:listModules()
	self.save_list = engine.Module:listSavefiles()

	-- Setup display
	self:selectStepMain()

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()
end

function _M:display()
	self.step:display():toScreen(self.step.display_x, self.step.display_y)

	engine.Game.display(self)
end

--- Skip to a module directly ?
function _M:commandLineArgs(args)
	local req_mod = nil
	for i, arg in ipairs(args) do
		if arg:find("^%-M") then
			-- Force module loading
			req_mod = arg:sub(3)
		end
	end

	if req_mod then
		local mod = engine.Module:loadDefinition("/modules/"..req_mod)
		if mod then
			local M = mod.load()
			_G.game = M.new()
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
				os.exit()
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
			local M = mod.load()
			_G.game = M.new()
			_G.game:run()
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
	local display_module = Dialog.new("", self.w * 0.73, self.h, self.w * 0.26, 0, 255)

	local mod_font = core.display.newFont("/data/font/VeraIt.ttf", 14)
	local list = {}
	local found = false
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

	if not found then
		Dialog:simplePopup("No savefiles", "You do not have any savefiles for any of the installed modules. Play a new game!")
		return
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
