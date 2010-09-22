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
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actions)
	self:generateList(actions)

	engine.Dialog.init(self, "Game Menu", 300, #self.list * 30 + 20)

	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 5) / self.font_h) - 1

	self:keyCommands({
		__TEXTINPUT = function(c)
			if c:find("^[a-z]$") then
				self.sel = util.bound(1 + string.byte(c) - string.byte('a'), 1, #self.list)
				self.changed = true
				self:use()
			end
		end,
	},{
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		ACCEPT = function() self:use() end,
		EXIT = function() game:unregisterDialog(self) end,
	})
	self:mouseZones{
		{ x=0, y=0, w=game.w, h=game.h, mode={button=true}, norestrict=true, fct=function(button) if button == "left" then game:unregisterDialog(self) end end},
		{ x=2, y=5, w=350, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty, event)
			self.changed = true
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" and event == "button" then self:use()
			elseif button == "right" and event == "button" then
			end
		end },
	}
end

function _M:use()
	self.list[self.sel].fct()
end

function _M:generateList(actions)
	local default_actions = {
		resume = { "Resume", function() game:unregisterDialog(self) end },
		keybinds = { "Key Bindings", function()
			game:unregisterDialog(self)
			local menu = require("engine.dialogs.KeyBinder").new(game.normal_key)
			game:registerDialog(menu)
		end },
		resolution = { "Display Resolution", function()
			game:unregisterDialog(self)
			local menu = require("engine.dialogs.DisplayResolution").new()
			game:registerDialog(menu)
		end },
		achievements = { "Show Achievements", function()
			game:unregisterDialog(self)
			local menu = require("engine.dialogs.ShowAchievements").new()
			game:registerDialog(menu)
		end },
		sound = { "Sound & Music", function()
			game:unregisterDialog(self)
			local menu = require("engine.dialogs.SoundMusic").new()
			game:registerDialog(menu)
		end },
		save = { "Save Game", function() game:saveGame() end },
		quit = { "Save and Exit", function() game:onQuit() end },
	}

	-- Makes up the list
	local list = {}
	local i = 0
	for _, act in ipairs(actions) do
		if type(act) == "string" then
			local a = default_actions[act]
			list[#list+1] = { name=string.char(string.byte('a') + i)..")  "..a[1], fct=a[2] }
			i = i + 1
		else
			local a = act
			list[#list+1] = { name=string.char(string.byte('a') + i)..")  "..a[1], fct=a[2] }
			i = i + 1
		end
	end
	self.list = list
end

function _M:drawDialog(s)
	self:drawSelectionList(s, 2, 5, self.font_h, self.list, self.sel, "name", self.scroll, self.max)
	self.changed = false
end
