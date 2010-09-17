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

function _M:init(mx, my, tmx, tmy)
	self.tmx, self.tmy = util.bound(tmx, 0, game.level.map.w - 1), util.bound(tmy, 0, game.level.map.h - 1)
	if tmx == game.player.x and tmy == game.player.y then self.on_player = true end

	self.font = core.display.newFont("/data/font/Vera.ttf", 12)
	self:generateList()
	self.__showup = false

	mx = mx - (self.max + 20) / 2
	my = my - 30

	engine.Dialog.init(self, "Actions", self.max + 20, self.maxh + 10 + 25, mx, my, nil, self.font)

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

	if act == "move_to" then game.player:mouseMove(self.tmx, self.tmy)
	elseif act == "change_level" then game.key:triggerVirtual("CHANGE_LEVEL")
	elseif act == "pickup" then game.key:triggerVirtual("PICKUP_FLOOR")
	elseif act == "character_sheet" then game.key:triggerVirtual("SHOW_CHARACTER_SHEET")
	elseif act == "inventory" then game.key:triggerVirtual("SHOW_INVENTORY")
	end
end

function _M:generateList()
	local list = {}

	local g = game.level.map(self.tmx, self.tmy, Map.TERRAIN)
	local t = game.level.map(self.tmx, self.tmy, Map.TRAP)
	local o = game.level.map(self.tmx, self.tmy, Map.OBJECT)
	local a = game.level.map(self.tmx, self.tmy, Map.ACTOR)

	if g and g.change_level and self.on_player then list[#list+1] = {name="Change level", action="change_level"} end
	if o and self.on_player then list[#list+1] = {name="Pickup item", action="pickup"} end
	if g and not self.on_player then list[#list+1] = {name="Move to", action="move_to"} end
	if self.on_player then list[#list+1] = {name="Inventory", action="inventory"} end
	if self.on_player then list[#list+1] = {name="Character Sheet", action="character_sheet"} end

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
	if #self.list == 0 then game:unregisterDialog(self) return end

	local h = 2
	self:drawSelectionList(s, 2, h, self.font_h, self.list, self.sel, "name")
	self.changed = false
end
