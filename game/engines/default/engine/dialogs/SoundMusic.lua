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

	engine.Dialog.init(self, "Sound & Music", 300, #self.list * 30 + 40)

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
		MOVE_LEFT = function() self:changeVol(-5) self.changed = true end,
		MOVE_RIGHT = function() self:changeVol(5) self.changed = true end,
		ACCEPT = function() self:use() end,
		EXIT = function() game:unregisterDialog(self) end,
	})
	self:mouseZones{
		{ x=0, y=0, w=game.w, h=game.h, mode={button=true}, norestrict=true, fct=function(button) if button == "left" then game:unregisterDialog(self) end end},
		{ x=2, y=5, w=350, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty, event)
			self.changed = true
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" and event == "button" then self:use(true)
			elseif button == "right" and event == "button" then self:use(false)
			end
		end },
	}
end

function _M:changeVol(v)
	if self.list[self.sel].act == "music_volume" then
		game:volumeMusic(game:volumeMusic() + v)
		self:generateList()
	elseif self.list[self.sel].act == "sound_volume" then
--		self:changeVol(v and 5 or -5)
	end
end

function _M:use(v)
	if self.list[self.sel].act == "enable" then
		game:soundSystemStatus(true)
		self:generateList()
	elseif self.list[self.sel].act == "disable" then
		game:soundSystemStatus(false)
		self:generateList()
	elseif self.list[self.sel].act == "music_volume" then
		self:changeVol(v and 5 or -5)
	elseif self.list[self.sel].act == "sound_volume" then
		self:changeVol(v and 5 or -5)
	end
--	game:unregisterDialog(self)
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local i = 0

	if game:soundSystemStatus() then
		list[#list+1] = { name=string.char(string.byte('a') + i)..")  Disable sound & music", act="disable" } i = i + 1
	else
		list[#list+1] = { name=string.char(string.byte('a') + i)..")  Enable sound & music", act="enable" } i = i + 1
	end
	list[#list+1] = { name=string.char(string.byte('a') + i)..")  Music volume ("..game:volumeMusic().."%)", act="music_volume" } i = i + 1
--	list[#list+1] = { name=string.char(string.byte('a') + i)..")  Sound volume", act="sound_volume" } i = i + 1

	self.list = list
	self.changed = true
end

function _M:drawDialog(s)
	self:drawSelectionList(s, 2, 5, self.font_h, self.list, self.sel, "name", self.scroll, self.max)
	self.changed = false
end
