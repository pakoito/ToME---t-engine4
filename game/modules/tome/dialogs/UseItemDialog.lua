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
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor, object, item, inven, onuse)
	self.actor = actor
	self.object = object
	self.inven = inven
	self.item = item
	self.onuse = onuse

	self.font = core.display.newFont("/data/font/Vera.ttf", 12)
	self:generateList()
	local name = object:getName()
	local nw, nh = self.font:size(name)
	engine.Dialog.init(self, name, math.max(nw, self.max) + 10, self.maxh + 10 + 25, nil, nil, nil, self.font)

	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 45) / self.font_h) - 1

	self:keyCommands(nil, {
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		ACCEPT = function() self:use() end,
		EXIT = function() game:unregisterDialog(self) end,
	})
	self:mouseZones{
		{ x=0, y=0, w=350, h=self.ih, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.changed = true
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" then self:use()
			end
		end },
	}
end

function _M:use()
	if not self.list[self.sel] then return end
	game:unregisterDialog(self)

	local act = self.list[self.sel].action

	local stop = false
	if act == "use" then self.actor:playerUseItem(self.object, self.item, self.inven, self.onuse) stop = true
	elseif act == "drop" then self.actor:doDrop(self.inven, self.item)
	elseif act == "wear" then self.actor:doWear(self.inven, self.item, self.object)
	elseif act == "takeoff" then self.actor:doTakeoff(self.inven, self.item, self.object)
	end

	self.onuse(self.inven, self.item, self.object, stop)
end

function _M:generateList()
	local list = {}

	if self.object:canUseObject() then list[#list+1] = {name="Use", action="use"} end
	if self.inven == self.actor.INVEN_INVEN and self.object:wornInven() then list[#list+1] = {name="Wield/Wear", action="wear"} end
	if self.inven ~= self.actor.INVEN_INVEN and self.object:wornInven() then list[#list+1] = {name="Take off", action="takeoff"} end
	if self.inven == self.actor.INVEN_INVEN then list[#list+1] = {name="Drop", action="drop"} end

	self.max = 0
	self.maxh = 0
	for i, v in ipairs(list) do
		local w, h = self.font:size(v.name)
		self.max = math.max(self.max, w)
		self.maxh = self.maxh + h
	end

	self.list = list
end

function _M:drawDialog(s)
	local h = 2
	self:drawSelectionList(s, 2, h, self.font_h, self.list, self.sel, "name")
	self.changed = false
end
