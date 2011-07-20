-- TE4 - T-Engine 4
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
local Tiles = require "engine.Tiles"
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"
local Image = require "engine.ui.Image"
local Checkbox = require "engine.ui.Checkbox"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, player)
	self.player = player
	local total = #world.achiev_defs
	local nb = 0
	for id, data in pairs(world.achieved) do nb = nb + 1 end

	Dialog.init(self, (title or "Achievements").." ("..nb.."/"..total..")", game.w * 0.8, game.h * 0.8)

	self.c_self = Checkbox.new{title="Yours only", default=false, fct=function() end, on_change=function(s) if s then self:switchTo("self") end end}
	self.c_main = Checkbox.new{title="All achieved", default=true, fct=function() end, on_change=function(s) if s then self:switchTo("main") end end}
	self.c_all = Checkbox.new{title="Everything", default=false, fct=function() end, on_change=function(s) if s then self:switchTo("all") end end}

	self.c_image = Image.new{file="trophy_gold.png", width=64, height=64, shadow=true}
	self.c_desc = TextzoneList.new{width=math.floor(self.iw * 0.4 - 10), height=self.ih - self.c_self.h}

	self:generateList("main")

	self.c_list = ListColumns.new{width=math.floor(self.iw * 0.6 - 10), height=self.ih - 10 - self.c_self.h, scrollbar=true, sortable=true, columns={
		{name="", width={24,"fixed"}, display_prop="--", direct_draw=function(item, x, y) if item.tex then item.tex[1]:toScreen(x+4, y, 16, 16) end end},
		{name="Achievement", width=60, display_prop="name", sort="name"},
		{name="When", width=20, display_prop="when", sort="when"},
		{name="Who", width=20, display_prop="who", sort="who"},
	}, list=self.list, fct=function(item) end, select=function(item, sel) self:select(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_self},
		{left=self.c_self.w, top=0, ui=self.c_main},
		{left=self.c_self.w+self.c_main.w, top=0, ui=self.c_all},

		{left=0, top=self.c_self.h, ui=self.c_list},
		{left=self.iw * 0.6 + 10, top=self.c_self.h, ui= self.c_image},
		{right=0, top=self.c_image.h + self.c_self.h, ui=self.c_desc},
		{left=self.iw * 0.6 - 5, top=self.c_self.h + 5, ui=Separator.new{dir="horizontal", size=self.ih - 10 - self.c_self.h}},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:switchTo(kind)
	self:generateList(kind)
	if kind == "self" then self.c_main.checked = false self.c_all.checked = false
	elseif kind == "main" then self.c_self.checked = false self.c_all.checked = false
	elseif kind == "all" then self.c_main.checked = false self.c_self.checked = false
	end

	self.c_list.list = self.list
	self.c_list:generate()
	self.c_desc.items = {}
	self.c_desc:switchItem(nil)
end

function _M:select(item)
	if item then
		local also = ""
		if self.player and self.player.achievements and self.player.achievements[item.id] then
			also = "#GOLD#Also achieved by your current character#LAST#\n"
		end
		self.c_image.item = item.tex
		local track = self:getTrack(item.a)
		local desc = ("#GOLD#Achieved on:#LAST# %s\n#GOLD#Achieved by:#LAST# %s\n%s\n#GOLD#Description:#LAST# %s"):format(item.when, item.who, also, item.desc):toTString()
		if track then
			desc:add(true, true, {"color","GOLD"}, "Progress: ", {"color","LAST"})
			desc:merge(track)
		end
		self.c_desc:switchItem(item, desc)
	end
end

function _M:getTrack(a)
	if a.track then
		local src = self.player
		local id = a.id
		local data = nil
		if a.mode == "world" then
			world.achievement_data = world.achievement_data or {}
			world.achievement_data[id] = world.achievement_data[id] or {}
			data = world.achievement_data[id]
		elseif a.mode == "game" then
			game.achievement_data = game.achievement_data or {}
			game.achievement_data[id] = game.achievement_data[id] or {}
			data = game.achievement_data[id]
		elseif a.mode == "player" then
			src.achievement_data = src.achievement_data or {}
			src.achievement_data[id] = src.achievement_data[id] or {}
			data = src.achievement_data[id]
		end
		return a.track(data, src)
	end
	return nil
end

function _M:generateList(kind)
	local tiles = Tiles.new(16, 16, nil, nil, true)
	local cache = {}

	-- Makes up the list
	local list = {}
	local i = 0
	local function handle(id, data)
		local a = world:getAchievementFromId(id)
		local color = nil
		if self.player and self.player.achievements and self.player.achievements[id] then
			color = colors.simple(colors.LIGHT_GREEN)
		end
		local img = a.image or "trophy_gold.png"
		local tex = cache[img]
		if not tex then
			local image = tiles:loadImage(img)
			if image then
				tex = {image:glTexture()}
				cache[img] = tex
			end
		end
		if data and (not data.notdone or a.show) then
			if a.show == "full" or not data.notdone then
				list[#list+1] = { name=a.name, color=color, desc=a.desc, when=data.when, who=data.who, order=a.order, id=id, tex=tex, a=a }
			elseif a.show == "none" then
				list[#list+1] = { name="???", color=color, desc="-- Unknown --", when=data.when, who=data.who, order=a.order, id=id, tex=tex, a=a }
			elseif a.show == "name" then
				list[#list+1] = { name=a.name, color=color, desc="-- Unknown --", when=data.when, who=data.who, order=a.order, id=id, tex=tex, a=a }
			else
				list[#list+1] = { name=a.name, color=color, desc=a.desc, when=data.when, who=data.who, order=a.order, id=id, tex=tex, a=a }
			end
			i = i + 1
		end
	end
	if kind == "self" and self.player and self.player.achievements then
		for id, data in pairs(self.player.achievements) do handle(id, world.achieved[id]) end
	elseif kind == "main" then
		for id, data in pairs(world.achieved) do handle(id, data) end
	elseif kind == "all" then
		for _, a in ipairs(world.achiev_defs) do handle(a.id, world.achieved[id] or {notdone=true, when="--", who="--"}) end
	end
	table.sort(list, function(a, b) return a.name < b.name end)
	self.list = list
end
