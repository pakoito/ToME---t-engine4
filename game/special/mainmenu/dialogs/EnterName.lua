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
require "engine.Savefile"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(runmod)
	engine.Dialog.init(self, "Enter your character's name?", 300, 100)
	self.runmod = runmod
	self.name = ""
	self:keyCommands({
		_RETURN = function()
			if self.name:len() >= 3 then
				game:unregisterDialog(self)

				-- Ok run the module
				local M = self.runmod.load()
				_G.game = M.new()
				_G.game:setPlayerName(self.name)

				-- Delete the corresponding savefile if any
				local save = engine.Savefile.new(_G.game.save_name)
				save:delete()
				save:close()

				-- And now run it!
				_G.game:run()
			else
				engine.Dialog:simplePopup("Error", "Character name must be between 3 and 25 characters.")
			end
		end,
		_BACKSPACE = function()
			self.name = self.name:sub(1, self.name:len() - 1)
		end,
		__TEXTINPUT = function(c)
			if self.name:len() < 25 then
				self.name = self.name .. c
				self.changed = true
			end
		end,
	},{
		EXIT = function()
			game:unregisterDialog(self)
		end
	})
end

function _M:drawDialog(s, w, h)
	s:drawColorStringCentered(self.font, "Enter your characters name:", 2, 2, self.iw - 2, self.ih - 2 - self.font:lineSkip())
	s:drawColorStringCentered(self.font, self.name, 2, 2 + self.font:lineSkip(), self.iw - 2, self.ih - 2 - self.font:lineSkip())
end
