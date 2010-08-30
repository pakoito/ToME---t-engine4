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

function _M:init(title, prompt, act)
	engine.Dialog.init(self, title or "Quantity?", 300, 100)
	self.prompt = prompt
	self.act = act
	self.qty = 0
	self.first = true
	self:keyCommands{
		_ESCAPE = function()
			game:unregisterDialog(self)
		end,
		_RETURN = function()
			game:unregisterDialog(self)
			act(self.qty)
		end,
		_BACKSPACE = function()
			local b = tostring(self.qty)
			b = b:sub(1, b:len() - 1)
			if b == '' then self.qty = 0
			else self.qty = tonumber(b)
			end
			self.changed = true
		end,
		__TEXTINPUT = function(c)
			if not (c == '0' or c == '1' or c == '2' or c == '3' or c == '4' or c == '5' or c == '6' or c == '7' or c == '8' or c == '9') then return end
			if self.qty >= 10000000 then return end
			local b = tostring(self.qty)
			if self.qty == 0 then b = "" end
			if self.first then
				self.qty = tonumber(c)
				self.first = false
			else
				self.qty = tonumber(b .. c)
			end
			self.changed = true
		end,
	}
end

function _M:drawDialog(s, w, h)
	s:drawColorStringBlendedCentered(self.font, self.prompt or "Quantity:", 2, 2, self.iw - 2, self.ih - 2 - self.font:lineSkip())
	s:drawColorStringBlendedCentered(self.font, tostring(self.qty), 2, 2 + self.font:lineSkip(), self.iw - 2, self.ih - 2 - self.font:lineSkip())
	self.changed = false
end
