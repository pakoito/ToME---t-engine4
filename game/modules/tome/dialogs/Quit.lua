-- ToME - Tales of Middle-Earth
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
local Savefile = require "engine.Savefile"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init()
	engine.Dialog.init(self, "Realy exit ToME?", 300, 100)
	self:keyCommands({
		__DEFAULT = function()
			game:unregisterDialog(self)
			game.quit_dialog = false
		end,
	}, {
		ACCEPT = function()
			local save = Savefile.new(game.save_name)
			save:saveGame(game)
			save:close()
			util.showMainMenu()
		end,
	})
end

function _M:drawDialog(s, w, h)
	s:drawColorStringCentered(self.font, "Press enter to quit, any other keys to stay", 2, 2, self.iw - 2, self.ih - 2)
end
