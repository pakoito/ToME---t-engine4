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

-- Globals to all instances of the console
offset = 0
history = {}
line = ""
com_sel = 0
commands = {}

function _M:init()
	engine.Dialog.init(self, "Lua Console", core.display.size())
	self:keyCommands{
		_RETURN = function()
			table.insert(self.commands, self.line)
			self.com_sel = #self.commands + 1
			table.insert(self.history, self.line)
			-- Handle assignment and simple printing
			if self.line:match("^=") then self.line = "return "..self.line:sub(2) end
			local f, err = loadstring(self.line)
			if err then
				table.insert(self.history, err)
			else
				local res = {pcall(f)}
				for i, v in ipairs(res) do
					if i > 1 then
						table.insert(self.history, "    "..(i-1).." :=: "..tostring(v))
						-- Handle printing a table
						if type(v) == "table" then
							for k, vv in pairs(v) do
								table.insert(self.history, "        "..tostring(k).." :=: "..tostring(vv) )
							end
						end
					end
				end
			end
			self.line = ""
			self.offset = 0
			self.changed = true
		end,
		_UP = function()
			self.com_sel = util.bound(self.com_sel - 1, 1, #self.commands)
			if self.commands[self.com_sel] then
				self.line = self.commands[self.com_sel]
			end
			self.changed = true
		end,
		_DOWN = function()
			self.com_sel = util.bound(self.com_sel + 1, 1, #self.commands)
			if self.commands[self.com_sel] then
				self.line = self.commands[self.com_sel]
			end
			self.changed = true
		end,
		_ESCAPE = function()
			game:unregisterDialog(self)
		end,
		_BACKSPACE = function()
			self.line = self.line:sub(1, self.line:len() - 1) self.changed = true
		end,
		__TEXTINPUT = function(c)
			self.line = self.line .. c
			self.changed = true
		end,
	}
	-- Scroll message log
	self:mouseZones{
		{ x=0, y=0, w=game.w, h=game.h, mode={button=true}, norestrict=true, fct=function(button) if button ~= "none" then game:unregisterDialog(self) end end},
		{ x=0, y=0, w=self.iw, h=self.ih, mode={button=true}, fct=function(button, x, y, xrel, yrel, tx, ty)
			if button == "wheelup" then self:scrollUp(1) end
			if button == "wheeldown" then self:scrollUp(-1) end
		end },
	}
end

function _M:drawDialog(s, w, h)
	local buffer = (self.ih % self.font_h) / 2
	local i, dh = #self.history - self.offset, self.ih - buffer - self.font:lineSkip()
	-- Start at the bottom and work up
	-- Draw the current command
	s:drawStringBlended(self.font, self.line, 0, dh, 255, 255, 255)
	dh = dh - self.font:lineSkip()
	-- Now draw the history with any ofset
	while dh > buffer do
		if not self.history[i] then break end
		s:drawStringBlended(self.font, self.history[i], 0, dh, 255, 255, 255)
		i = i - 1
		dh = dh - self.font:lineSkip()
	end
	self.changed = false
end

--- Scroll the zone
-- @param i number representing how many lines to scroll
function _M:scrollUp(i)
	self.offset = self.offset + i
	if self.offset > #self.history - 1 then self.offset = #self.history - 1 end
	if self.offset < 0 then self.offset = 0 end
	self.changed = true
end
