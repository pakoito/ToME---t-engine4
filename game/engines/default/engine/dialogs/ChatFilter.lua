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

function _M:init(adds)
	Dialog.init(self, "Chat filters", 500, 400)

	local list = {
		{name = "Public chat", kind = "talk"},
		{name = "Private whispers", kind = "whisper"},
		{name = "Join/part messages", kind = "join"},
		{name = "Achievements", kind = "achievement"},
	}
	for i, l in ipairs(adds or {}) do list[#list+1] = l end

	local c_desc = Textzone.new{width=self.iw - 10, height=1, auto_height=true, text="Select which types of chat events to see or not."}
	local uis = { {left=0, top=0, ui=c_desc} }
	for i, l in ipairs(list) do
		local l = l
		uis[#uis+1] = {left=0, top=uis[#uis].top+uis[#uis].ui.h + 6, ui=Checkbox.new{title=l.name, default=not config.settings.chat.filter[l.kind], fct=function() end, on_change=function(s) config.settings.chat.filter[l.kind] = not s end} }
	end

	self:loadUI(uis)
	self:setupUI(false, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:unload()
	local l = {}
	for k, v in pairs(config.settings.chat.filter) do
		if v then l[#l+1] = "chat.filter."..k.."=true" end
	end
	table.print(config.settings.chat.filter)
	print("===", table.concat(l, "\n"))
	game:saveSettings("chat.filter", table.concat(l, "\n"))
end
