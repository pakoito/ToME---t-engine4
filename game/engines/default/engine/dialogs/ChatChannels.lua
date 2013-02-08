-- TE4 - T-Engine 4
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
local Checkbox = require "engine.ui.Checkbox"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(chat)
	Dialog.init(self, "Chat channels", 500, 400)
	local mod = game.__mod_info.short_name

	local list = {
		{name = "Global", kind = "global"},
		{name = game.__mod_info.long_name, kind = mod},
		{name = game.__mod_info.long_name.." [spoilers]", kind = mod.."-spoiler"},
	}
	for i, l in pairs(profile.chat.channels) do
		if i ~= "global" and i ~= mod and i ~= mod.."-spoiler" then
			list[#list+1] = {name=i, kind=i}
		end
	end

	local c_desc = Textzone.new{width=self.iw - 10, height=1, auto_height=true, text="Select which channels to listen to. You can join new channels by typing '/join <channelname>' in the talkbox and leave channels by typing '/part <channelname>'"}
	local uis = { {left=0, top=0, ui=c_desc} }
	for i, l in ipairs(list) do
		local l = l
		uis[#uis+1] = {left=0, top=uis[#uis].top+uis[#uis].ui.h + 6, ui=Checkbox.new{title=l.name, default=profile.chat.channels[l.kind], fct=function() end, on_change=function(s)
			if s then profile.chat:join(l.kind)
			else profile.chat:part(l.kind)
			end
		end} }
	end

	self:loadUI(uis)
	self:setupUI(false, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:unload()
	profile.chat:saveChannels()
end
