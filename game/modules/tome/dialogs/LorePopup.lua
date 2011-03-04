-- ToME - Tales of Maj'Eyal
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
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(l, w, force_height)
	local text = util.getval(l.lore).."\n"
	local list = text:splitLines(w - 10, self.font)

	self.title_shadow = false
	self.color = {r=0x3a, g=0x35, b=0x33}

	self.ui = ""
	self.frame = {
		shadow = {x = 10, y = 10, a = 0.5},
		ox1 = -16, ox2 = 16,
		oy1 = -16, oy2 = 16,
		b7 = "ui/parchment7.png",
		b9 = "ui/parchment9.png",
		b1 = "ui/parchment1.png",
		b3 = "ui/parchment3.png",
		b4 = "ui/parchment4.png",
		b6 = "ui/parchment6.png",
		b8 = "ui/parchment8.png",
		b2 = "ui/parchment2.png",
		b5 = "ui/parchment5.png",
	}
	if l.bloodstains then
		local ovs = {}
		for i = 1, l.bloodstains do
			ovs[#ovs+1] = {image="ui/parchmentblood"..rng.range(1, 5)..".png", gen=function(self, dialog)
				self.x = rng.range(30, dialog.w - 60)
				self.y = rng.range(30, dialog.h - 60)
				self.a = rng.float(0.5, 0.8)
			end}
		end
		self.frame.overlays = ovs
	end

	Dialog.init(self, "Lore found: #0080FF#"..l.name, 1, 1)

	local h = math.min(force_height and (force_height * game.h) or 999999999, self.font_h * #list)
	self:loadUI{
		{left = 3, top = 3, ui=require("engine.ui.Textzone").new{
				width=w+10, height=h, scrollbar=(h < self.font_h * #list) and true or false, text=text, color={r=0x3a, g=0x35, b=0x33},
			}
		}
	}
	if not no_leave then
		self.key:addBind("EXIT", function() game:unregisterDialog(self) if fct then fct() end end)
	end
	self:setupUI(true, true)
	game:registerDialog(self)
end
