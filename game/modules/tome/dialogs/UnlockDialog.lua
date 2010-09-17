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

function _M:init(what)
	self.what = what

	local f, err = loadfile("/data/texts/unlock-"..self.what..".lua")
	if not f and err then error(err) end
	setfenv(f, {})
	self.name, self.str = f()

	game.logPlayer(game.player, "#VIOLET#Option unlocked: "..self.name)

	engine.Dialog.init(self, "Option unlocked: "..self.name, 600, 400)

	self:keyCommands(nil, {
		ACCEPT = "EXIT",
		EXIT = function()
			game:unregisterDialog(self)
		end,
	})
	self:mouseZones{
		{ x=0, y=0, w=game.w, h=game.h, mode={button=true}, norestrict=true, fct=function(button) if button ~= "none" then game:unregisterDialog(self) end end},
	}
end

function _M:drawDialog(s)
	local lines = self.str:splitLines(self.iw - 10, self.font)
	local r, g, b
	for i = 1, #lines do
		r, g, b = s:drawColorStringBlended(self.font, lines[i], 5, 4 + i * self.font:lineSkip(), r, g, b)
	end
	self.changed = false
end
