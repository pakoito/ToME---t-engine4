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

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor)
	self.actor = actor
	engine.Dialog.init(self, "Welcome to ToME", 500, 400)

	self:keyCommands(nil, {
		ACCEPT = "EXIT",
		EXIT = function()
			game:unregisterDialog(self)
		end,
	})
end

function _M:drawDialog(s)
	local f, err = loadfile("/data/texts/intro-"..self.actor.starting_intro..".lua")
	if not f and err then error(err) end
	setfenv(f, {name=self.actor.name})
	local str = f()
	local lines = str:splitLines(self.iw - 10, self.font)
	for i = 1, #lines do
		s:drawColorString(self.font, lines[i], 5, 4 + i * self.font:lineSkip())
	end
	self.changed = false
end
