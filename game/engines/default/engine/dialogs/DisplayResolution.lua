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

function _M:init()
	self:generateList()

	engine.Dialog.init(self, "Switch Resolution", 300, #self.list * 30 + 20)

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
		EXIT = function() game:unregisterDialog(self) end,
	})
	self:mouseZones{
		{ x=0, y=0, w=game.w, h=game.h, mode={button=true}, norestrict=true, fct=function(button) if button == "left" then game:unregisterDialog(self) end end},
		{ x=2, y=5, w=350, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty, event)
			self.changed = true
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" and event == "button" then self:use()
			elseif button == "right" and event == "button" then
			end
		end },
	}
end

function _M:use()
	game:setResolution(self.list[self.sel].r)
	game:unregisterDialog(self)
end

function _M:generateList()
	local l = {}
	for r, _ in pairs(game.available_resolutions) do
		l[#l+1] = r
	end
	table.sort(l, function(a,b)
		if game.available_resolutions[a][2] == game.available_resolutions[b][2] then
			return (game.available_resolutions[a][3] and 1 or 0) < (game.available_resolutions[b][3] and 1 or 0)
		elseif game.available_resolutions[a][1] == game.available_resolutions[b][1] then
			return game.available_resolutions[a][2] < game.available_resolutions[b][2]
		else
			return game.available_resolutions[a][1] < game.available_resolutions[b][1]
		end
	end)

	-- Makes up the list
	local list = {}
	local i = 0
	for _, r in ipairs(l) do
		list[#list+1] = { name=string.char(string.byte('a') + i)..")  "..r, r=r }
		i = i + 1
	end
	self.list = list
end

function _M:drawDialog(s)
	self:drawSelectionList(s, 2, 5, self.font_h, self.list, self.sel, "name", self.scroll, self.max)
	self.chanegd = false
end
