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
local Module = require "engine.Module"
local Dialog = require "engine.ui.Dialog"
local TreeList = require "engine.ui.TreeList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "Load Game", game.w, game.h)

	local list = table.clone(game.save_list, true)

	self.c_desc = Textzone.new{width=math.floor(self.iw / 3 * 2 - 10), height=self.ih, text=""}

	self.tree = {}
	local found = false
	for i, mod in ipairs(list) do
		local nodes = {}

		for j, save in ipairs(mod.savefiles) do
			save.fct = function()
				Module:instanciate(mod, save.name, false)
			end
			save.zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text="#{bold}##GOLD#"..mod.long_name..": "..save.name.."#WHITE##{normal}#\n\n"..save.description}
			table.insert(nodes, save)
			found = true
		end

		if #nodes > 0 then
			table.insert(self.tree, {
				name="#{bold}##GOLD#"..mod.name.."#WHITE##{normal}#",
				fct=function() end,
				shown=true,
				nodes=nodes,
				zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text="#{bold}##GOLD#"..mod.long_name.."#WHITE##{normal}#\n\n"..mod.description}
			})
		end
	end

	self.c_tree = TreeList.new{width=math.floor(self.iw / 3 - 10), height=self.ih, scrollbar=true, columns={
		{width=100, display_prop="name"},
	}, tree=self.tree,
		fct=function(item, sel, v) end,
		select=function(item, sel) self:select(item) end,
	}

	self:loadUI{
		{left=0, top=0, ui=self.c_tree},
		{right=0, top=0, ui=self.c_desc},
		{left=self.c_tree.w + 5, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_tree)
	self:setupUI()

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:select(item)
	if item and self.uis[2] then
		self.uis[2].ui = item.zone
	end
end
