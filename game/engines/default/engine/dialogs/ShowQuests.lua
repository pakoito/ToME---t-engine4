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

function _M:init(actor)
	self.actor = actor
	actor.hotkey = actor.hotkey or {}
	engine.Dialog.init(self, "Quest Log for "..actor.name, game.w, game.h)

	self:generateList()

	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 5) / self.font_h) - 1

	self:keyCommands({
		_t = function()
			self.sel = 1
			self.scroll = 1
			self.show_ended = not self.show_ended
			self:generateList()
			self.changed = true        print("plop")
		end,
	},{
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		EXIT = function() game:unregisterDialog(self) end,
	})
	self:mouseZones{
		{ x=0, y=0, w=game.w, h=game.h, mode={button=true}, norestrict=true, fct=function(button) if button ~= "none" then game:unregisterDialog(self) end end},
		{ x=2, y=5, w=350, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty, event)
			self.changed = true
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" and event == "button" then
			elseif button == "right" and event == "button" then
			end
		end },
	}
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	for id, q in pairs(self.actor.quests or {}) do
		if not q:isEnded() or self.show_ended then
			list[#list+1] = { name=q.name, quest=q, color = q:isCompleted() and {0,255,0} or nil }
		end
	end
	if game.turn then
		table.sort(list, function(a, b) return a.quest.gained_turn < b.quest.gained_turn end)
	else
		table.sort(list, function(a, b) return a.quest.name < b.quest.name end)
	end
	self.list = list
end

function _M:drawDialog(s)
	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)

	local r, g, b
	local help = [[Keyboard: #00FF00#up key/down key#FFFFFF# to select a quest; #00FF00#t#FFFFFF# to toggle finished quests.
]]
	local talentshelp = help:splitLines(self.iw / 2 - 10, self.font)

	local lines = {}
	if self.list[self.sel] then
		lines = self.list[self.sel].quest:desc(self.actor):splitLines(self.iw / 2 - 10, self.font)
	end

	local h = 2
	for i = 1, #talentshelp do
		s:drawColorStringBlended(self.font, talentshelp[i], self.iw / 2 + 5, h)
		h = h + self.font:lineSkip()
	end

	h = h + self.font:lineSkip()
	self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
	for i = 1, #lines do
		r, g, b = s:drawColorStringBlended(self.font, lines[i], self.iw / 2 + 5, 2 + h, r, g, b)
		h = h + self.font:lineSkip()
	end

	-- Talents
	self:drawSelectionList(s, 2, 5, self.font_h, self.list, self.sel, "name", self.scroll, self.max, nil, nil, nil, self.iw / 2 - 5)
	self.changed = false
end
