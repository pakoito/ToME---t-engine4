-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
local List = require "engine.ui.List"
local GetQuantity = require "engine.dialogs.GetQuantity"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(Dialog))

local tiles_packs = {
	shockbolt = {name= "Shockbolt", order=1},
--	mushroom = {name= "Mushroom", order=2},
	ascii = {name= "ASCII", order=5},
	ascii_full = {name= "ASCII with background", order=6},
}
if fs.exists("/data/gfx/altefcat") then tiles_packs.altefcat = {name= "Altefcat/Gervais", order=3} end
if fs.exists("/data/gfx/oldrpg") then tiles_packs.oldrpg = {name= "Old RPG", order=4} end


function _M:init()
	self.cur_sel = "main"
	self:generateList()
	self.changed = false

	Dialog.init(self, "Change graphic mode", 300, 20)

	self.c_list = List.new{width=self.iw, nb_items=7, list=self.list, fct=function(item) self:use(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
	}
	self:setFocus(self.c_list)
	self:setupUI(false, true)

	self.key:addBinds{
		EXIT = function()
			if self.changed then game:setupDisplayMode(true) end
			game:unregisterDialog(self)
		end,
	}
end

function _M:use(item)
	if not item then return end

	if item.sub and item.val then
		if item.val == "customsize" then
			game:registerDialog(GetQuantity.new("Tile size", "From 10 to 128", Map.tile_w or 64, 128, function(qty)
				qty = math.floor(util.bound(qty, 10, 128))
				self:use{name=qty.."x"..qty, sub=item.sub, val=qty.."x"..qty}
			end, 10))
		else
			config.settings.tome.gfx[item.sub] = item.val
			self.changed = true
			item.change_sel = "main"
		end
	end

	if item.change_sel then
		self.cur_sel = item.change_sel
		self:generateList()
		self.c_list.list = self.list
		self.c_list:generate()
	end
end

function _M:generateList()
	local list

	if self.cur_sel == "main" then
		local cur = tiles_packs[config.settings.tome.gfx.tiles]
		list = {
			{name="Select style [current: "..(cur and cur.name or "???").."]", change_sel="tiles"},
			{name="Select tiles size [current: "..config.settings.tome.gfx.size.."]", change_sel="size"},
		}
	elseif self.cur_sel == "tiles" then
		list = {}
		for s, n in pairs(tiles_packs) do
			list[#list+1] = {name=n.name, order=n.order, sub="tiles", val=s}
		end
		table.sort(list, function(a, b) return a.order < b.order end)
	elseif self.cur_sel == "size" then
		list = {
			{name="64x64", sub="size", val="64x64"},
			{name="48x48", sub="size", val="48x48"},
			{name="32x32", sub="size", val="32x32"},
			{name="16x16", sub="size", val="16x16"},
			{name="Custom", sub="size", val="customsize"},
		}
	end

	self.list = list
end
