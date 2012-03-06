-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local List = require "engine.ui.List"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
	self.actor = actor
	Dialog.init(self, "Cursed Aura Selection", 1, 1)

	self:generateList()

	local c_desc = Textzone.new{width=350, auto_height=true, text="A malevolent aura begins to form around you. Choose your curse:"}
	local c_list = List.new{width=350, height=400, nb_items=#self.list, list=self.list, fct=function(item) self:use(item) end}
	self:loadUI{
		{left=0, top=0, ui=c_desc},
		{left=0, bottom=0, ui=c_list},
	}
	self:setFocus(c_list)
	self:setupUI(true, true)

	self.key:addCommands{ __TEXTINPUT = function(c) if self.list and self.list.chars[c] then self:use(self.list[self.list.chars[c]]) end end}
	self.key:addBinds{ EXIT = function() game:unregisterDialog(self) end, }
end

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

function _M:use(item)
	if not item then return end
	
	game:unregisterDialog(self)
	
	local t = self.actor:getTalentFromId(self.actor.T_DEFILING_TOUCH)
	t.setCursedAura(self.actor, t, item.curse)
end

function _M:generateList()
	local list = {}
	
	local t = self.actor:getTalentFromId(self.actor.T_DEFILING_TOUCH)
	local curses = t.getCurses(self.actor, t)
	for i, curse in pairs(curses) do
		list[#list+1] = {name=self.actor.tempeffect_def[curse].desc, curse=curse}
	end
	print("* CAS", #list, list[1].name, list[5].name)
	
	local chars = {}
	for i, v in ipairs(list) do
		v.name = self:makeKeyChar(i)..") "..v.name
		chars[self:makeKeyChar(i)] = i
	end
	list.chars = chars
	
	self.list = list
end
