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

	-- Setup display
	self:selectStepMain()

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()
end

function _M:display()
	self.step:display():toScreen(self.step.display_x, self.step.display_y)

	engine.Game.display(self)
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
				print("load")
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
			print("plop")
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
