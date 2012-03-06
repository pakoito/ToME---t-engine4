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
require "engine.ui.Dialog"
local List = require "engine.ui.List"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(engine.ui.Dialog))

function _M:init(center_mouse, actor, object, item, inven, onuse)
	self.actor = actor
	self.object = object
	self.inven = inven
	self.item = item
	self.onuse = onuse

	self:generateList()
	local name = object:getName()
	local w = self.font_bold:size(name)
	engine.ui.Dialog.init(self, name, 1, 1)

	local list = List.new{width=math.max(w, self.max) + 10, nb_items=#self.list, list=self.list, fct=function(item) self:use(item) end}

	self:loadUI{
		{left=0, top=0, ui=list},
	}
	self:setupUI(true, true, function(w, h)
		if center_mouse then
			local mx, my = core.mouse.get()
			self.force_x = mx - w / 2
			self.force_y = my - (self.h - self.ih + list.fh / 3)
		end
	end)

	self.key:addBinds{ EXIT = function() game:unregisterDialog(self) end, }
end

function _M:use(item)
	if not item then return end
	game:unregisterDialog(self)

	local act = item.action

	if act == "use" then
		if self.object:wornInven() and not self.object.wielded and not self.object.use_no_wear then
			self:simplePopup("Impossible", "You must wear this object to use it!")
		else
			self.actor:playerUseItem(self.object, self.item, self.inven, self.onuse)
			self.onuse(self.inven, self.item, self.object, true)
		end
	elseif act == "drop" then
		self.actor:doDrop(self.inven, self.item, function() self.onuse(self.inven, self.item, self.object, false) end)
	elseif act == "wear" then
		self.actor:doWear(self.inven, self.item, self.object)
		self.onuse(self.inven, self.item, self.object, false)
	elseif act == "takeoff" then
		self.actor:doTakeoff(self.inven, self.item, self.object)
		self.onuse(self.inven, self.item, self.object, false)
	elseif act == "transmo" then
		self:yesnoPopup("Transmogrify", "Really transmogrify "..self.object:getName{}, function(ret)
			if not ret then return end
			self.actor:transmoInven(self.inven, self.item, self.object)
			self.onuse(self.inven, self.item, self.object, false)
		end)
	elseif act == "toinven" then
		self.object.__transmo = false
		self.onuse(self.inven, self.item, self.object, false)
	elseif act == "chat-link" then
		profile.chat.uc_ext:sendObjectLink(self.object)
	end
end

function _M:generateList()
	local list = {}

	local transmo_chest = self.actor:attr("has_transmo")

	if not self.object.__transmo then
		if self.object:canUseObject() then list[#list+1] = {name="Use", action="use"} end
		if self.inven == self.actor.INVEN_INVEN and self.object:wornInven() and self.actor:getInven(self.object:wornInven()) then list[#list+1] = {name="Wield/Wear", action="wear"} end
		if self.inven ~= self.actor.INVEN_INVEN and self.object:wornInven() then list[#list+1] = {name="Take off", action="takeoff"} end
	else
		list[#list+1] = {name="Move to normal inventory", action="toinven"}
	end
	if self.inven == self.actor.INVEN_INVEN then list[#list+1] = {name="Drop", action="drop"} end
	if self.inven == self.actor.INVEN_INVEN and transmo_chest and self.actor:transmoFilter(self.object) then list[#list+1] = {name="Transmogrify now", action="transmo"} end
	if profile.auth and profile.hash_valid then list[#list+1] = {name="Link item in chat", action="chat-link"} end

	self.max = 0
	self.maxh = 0
	for i, v in ipairs(list) do
		local w, h = self.font:size(v.name)
		self.max = math.max(self.max, w)
		self.maxh = self.maxh + self.font_h
	end

	self.list = list
end
