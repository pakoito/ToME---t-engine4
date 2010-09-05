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

function _M:init(title, file, replace, w, h)
	w = math.floor(w or game.w * 0.6)
	h = math.floor(h or game.h * 0.8)

	self.iw = w - 2 * 5 -- Cheat, this is normaly done by Dialog:init but we need it to generate the list and we needto generate it before init
	self.font = core.display.newFont("/data/font/Vera.ttf", 12)
	self:generateList(file, replace)
	h = math.min(4 + 30 + (#self.list) * self.font:lineSkip(), h)

	engine.Dialog.init(self, title or "Text", w, h, nil, nil, nil, self.font)

	self.sel = 1
	self.max = math.floor((self.ih - 5) / self.font_h) - 1

	self:keyCommands({
	},{
--		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.changed = true end,
--		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.changed = true end,
		ACCEPT = function() game:unregisterDialog(self) end,
		EXIT = "ACCEPT",
	})
	self:mouseZones{
		{ x=0, y=0, w=self.w, h=self.h, fct=function(button, x, y, xrel, yrel, tx, ty)
		end },
	}
end

function _M:generateList(file, replace)
	local f, err = loadfile("/data/texts/"..file..".lua")
	if not f and err then error(err) end
	setfenv(f, setmetatable({}, {__index=_G}))
	local str = f()

	str = str:gsub("@([^@]+)@", function(what)
		if not replace[what] then return "" end
		return util.getval(replace[what])
	end)

	self.list = str:splitLines(self.iw - 10, self.font)
	return true
end

function _M:drawDialog(s)
	for ii = self.sel, #self.list do
		local i = ii - self.sel + 1
		if not self.list[i] or 4 + (i) * self.font:lineSkip() >= self.ih then break end
		s:drawColorStringBlended(self.font, self.list[i], 5, 4 + (i-1) * self.font:lineSkip())
	end
	self.changed = false
end
