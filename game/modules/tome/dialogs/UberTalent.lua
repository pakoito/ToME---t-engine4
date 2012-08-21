-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even th+e implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.class"
require "mod.class.interface.TooltipsData"

local Dialog = require "engine.ui.Dialog"
local Button = require "engine.ui.Button"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local UIContainer = require "engine.ui.UIContainer"
local ImageList = require "engine.ui.ImageList"
local Separator = require "engine.ui.Separator"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.inherit(Dialog, mod.class.interface.TooltipsData))

function _M:init(actor, on_finish)
	self.actor = actor

	self.font = core.display.newFont("/data/font/DroidSansMono.ttf", 12)
	self.font_h = self.font:lineSkip()

	self.actor_dup = actor:clone()
	self.actor_dup.uid = actor.uid -- Yes ...

	Dialog.init(self, "Prodigies: "..actor.name, game.w * 0.9, game.h * 0.9, game.w * 0.05, game.h * 0.05)

	self:generateList()

	self:loadUI(self:createDisplay())
	self:setupUI()

	self.key:addCommands{
	}
	self.key:addBinds{
		EXIT = function()
			game:unregisterDialog(self)
		end,
	}

	self.actor:learnTalentType("uber/strength", true)
	self.actor:learnTalentType("uber/dexterity", true)
	self.actor:learnTalentType("uber/constitution", true)
	self.actor:learnTalentType("uber/magic", true)
	self.actor:learnTalentType("uber/willpower", true)
	self.actor:learnTalentType("uber/cunning", true)
end

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

function _M:generateList()

	-- Makes up the list
	local list = {}
	for tid, t in pairs(self.actor.talents_def) do
		if t.uber then
			list[#list+1] = {
				image=t.image,
				talent = tid,
				rawname = t.name,
			}
		end
	end
	table.print(list)
	self.list = list
end

-----------------------------------------------------------------
-- UI Stuff
-----------------------------------------------------------------

function _M:createDisplay()
	self.c_list = ImageList.new{width=self.iw, height=self.ih, tile_w=48, tile_h=48, padding=10, scrollbar=true, list=self.list, fct=function(item) self:use(item) end, on_select=function(item) self:onSelect(item) end}

	local ret = {
		{left=0, top=0, ui=self.c_list},
	}


	return ret
end

function _M:onSelect(item)
	if item == self.cur_sel then return end

	game:tooltipDisplayAtMap(item.last_display_x+item.w, item.last_display_y, self:getTalentDesc(item.data))
	self.cur_sel = item
end

function _M:use(item)
end

function _M:getTalentDesc(item)
	local text = tstring{}

 	text:add({"color", "GOLD"}, {"font", "bold"}, util.getval(item.rawname, item), {"color", "LAST"}, {"font", "normal"})
	text:add(true, true)

	if item.talent then
		local t = self.actor:getTalentFromId(item.talent)
		local req = self.actor:getTalentReqDesc(item.talent)
		text:merge(req)
		text:merge(self.actor:getTalentFullDescription(t, 1))
	end

	return text
end
