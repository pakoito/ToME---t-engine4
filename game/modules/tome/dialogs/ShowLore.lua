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

function _M:init(title, actor)
	self.actor = actor
	local total = #actor.lore_defs
	local nb = 0
	for id, data in pairs(actor.lore_known) do nb = nb + 1 end

	engine.Dialog.init(self, (title or "Lore").." ("..nb.."/"..total..")", game.w * 0.8, game.h * 0.8, nil, nil, nil, core.display.newFont("/data/font/VeraMono.ttf", 12))

	self:generateList()

	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 5) / self.font_h) - 1

	self:keyCommands({},{
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		EXIT = function() game:unregisterDialog(self) end,
	})
	self:mouseZones{
		{ x=2, y=5, w=350, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.changed = true
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
		end },
	}
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local i = 0
	for id, _ in pairs(self.actor.lore_known) do
		local l = self.actor:getLore(id)
		list[#list+1] = { name=l.name, desc=l.lore, cat=l.category, order=l.order }
		i = i + 1
	end
	table.sort(list, function(a, b) return a.order < b.order end)
	self.list = list
end

function _M:drawDialog(s)
	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)

	local h = 2
	if self.list[self.sel] then
		local str = ("#GOLD#Category:#AQUAMARINE# %s\n#GOLD#Found as:#0080FF# %s\n#GOLD#Text:#ANTIQUE_WHITE# %s"):format(self.list[self.sel].cat, self.list[self.sel].name, self.list[self.sel].desc)
		lines = str:splitLines(self.iw / 2 - 10, self.font)
	else
		lines = {}
	end
	self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
	for i = 1, #lines do
		s:drawColorStringBlended(self.font, lines[i], self.iw / 2 + 5, 2 + h)
		h = h + self.font:lineSkip()
	end

	self:drawSelectionList(s, 2, 5, self.font_h, self.list, self.sel, "name", self.scroll, self.max)
	self.changed = false
end
