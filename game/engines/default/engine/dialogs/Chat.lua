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

function _M:init(chat, id)
	self.cur_id = id
	self.chat = chat
	self.npc = chat.npc
	self.player = chat.player
	engine.Dialog.init(self, self.npc.name, 500, 400)

	self:generateList()

	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 5) / self.font_h) - 1

	self:keyCommands({
		__TEXTINPUT = function(c)
			if c:find("^[a-z]$") then
				self.sel = util.bound(1 + string.byte(c) - string.byte('a'), 1, #self.list)
				self:use()
			end
		end,
	},{
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		ACCEPT = function() self:use() end,
	})
	self:mouseZones{
		{ x=0, y=0, w=self.w, h=self.h, fct=function(button, x, y, xrel, yrel, tx, ty)
			if y >= self.start_answer_y then
				ty = ty - self.start_answer_y
				self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
				self.changed = true
				if button == "left" then self:use()
				elseif button == "right" then
				end
			end
		end },
	}
end

function _M:use(a)
	a = a or self.chat:get(self.cur_id).answers[self.list[self.sel].answer]
	if not a then return end

	self.changed = true

	print("[CHAT] selected", a[1], a.action, a.jump)
	if a.action then
		local id = a.action(self.npc, self.player, self)
		if id then
			self.cur_id = id
			self:regen()
			return
		end
	end
	if a.jump then
		self.cur_id = a.jump
		self:regen()
	else
		game:unregisterDialog(self)
		return
	end
end

function _M:regen()
	self.changed = true
	self:generateList()
	self.sel = 1
	self.scroll = 1
end

function _M:resolveAuto()
	if not self.chat:get(self.cur_id).auto then return end
	for i, a in ipairs(self.chat:get(self.cur_id).answers) do
		if not a.cond or a.cond(self.npc, self.player) then
			if not self:use(a) then return
			else return self:resolveAuto()
			end
		end
	end
end

function _M:generateList()
	self:resolveAuto()

	-- Makes up the list
	local list = {}
	local nb = 1
	for i, a in ipairs(self.chat:get(self.cur_id).answers) do
		if not a.cond or a.cond(self.npc, self.player) then
			list[#list+1] = { name=string.char(string.byte('a')+nb-1)..") "..a[1], answer=i, color=a.color}
			nb = nb + 1
		end
	end
	self.list = list
	return true
end

function _M:drawDialog(s)
	local h = 5
	local lines = self.chat:replace(self.chat:get(self.cur_id).text):splitLines(self.iw - 10, self.font)
	local r, g, b
	for i = 1, #lines do
		r, g, b = s:drawColorStringBlended(self.font, lines[i], 5, 2 + h, r, g, b)
		h = h + self.font:lineSkip()
	end

	self:drawWBorder(s, 5, h + 0.5 * self.font:lineSkip(), self.iw - 10)

	-- Answers
	self.start_answer_y = h + 1.5 * self.font:lineSkip()
	self:drawSelectionList(s, 5, h + 1.5 * self.font:lineSkip(), self.font_h, self.list, self.sel, "name", self.scroll, self.max, nil, nil, self.iw - 10)
	self.changed = false
end
