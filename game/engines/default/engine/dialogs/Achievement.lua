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
local Image = require "engine.ui.Image"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, a)
	local c_image = Image.new{file=a.image or "trophy_gold.png", shadow=true, width=64, height=64}
	local c_desc = Textzone.new{width=500, auto_height=true, text=a.desc}

	Dialog.init(self, title, 10, 10)

	self:loadUI{
		{left=0, vcenter=0, ui=c_image},
		{right=0, vcenter=0, ui=c_desc},
	}
	self:setupUI(true, true, nil, nil, math.max(c_image.h, c_desc.h))

	self.key:addBinds{
		ACCEPT = "EXIT",
		EXIT = function()
			game:unregisterDialog(self)
			if on_exit then on_exit() end
		end,
	}
end
