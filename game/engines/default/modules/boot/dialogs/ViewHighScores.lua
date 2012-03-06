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
local Module = require "engine.Module"
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local Button = require "engine.ui.Button"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local Savefile = require "engine.Savefile"
local HighScores = require "engine.HighScores"

require "engine.PlayerProfile"


module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "View High Scores", game.w * 0.8, game.h * 0.8)

	-- high score table on right
	self.c_desc = Textzone.new{width=math.floor(self.iw / 3 * 2 - 10), height=self.ih, text=""}

	-- list of modules on left (top)

	self:generateList()

	self.c_list = ListColumns.new{width=math.floor(self.iw / 3 - 10), height=math.floor(self.ih / 2), scrollbar=true, columns={
		{name="Game Module", width=80, display_prop="name"},
		{name="Version", width=20, display_prop="version_txt"},
	}, list=self.list, fct=function(item) end, select=function(item, sel) self:changemodules(item) end}

	-- list of campaigns/worlds on left (bottom)
	self.c_sublist = ListColumns.new{width=math.floor(self.iw / 3 - 10), height=math.floor(self.ih / 2),
		columns = {{name="World",width=100,display_prop="world"}},
		list={}, select=function(item,sel) self:changeworlds(item) end, fct=function(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=0, ui=self.c_desc},
		{left=0, bottom=0, ui=self.c_sublist},
		{left=self.c_list.w + 5, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self:changemodules(self.list[1])

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:generateList()
	local list = Module:listModules()
	self.list = {}

	for i = 1, #list do
		for j, mod in ipairs(list[i].versions) do
			if j > 1 then break end
			if not mod.is_boot then
				mod.name = tstring{{"font","bold"}, {"color","GOLD"}, mod.name, {"font","normal"}}
				mod.version_txt = ("%d.%d.%d"):format(mod.version[1], mod.version[2], mod.version[3])

				-- Have to load the profile to get the highscores
				profile:addStatFields(unpack(mod.profile_stats_fields or {}))
				profile:loadModuleProfile(mod.short_name)
				print ("Loaded profile for "..mod.short_name.."\n")
				mod.highscores = {}
				if (profile.mod.scores and profile.mod.scores.sc) then
					-- one formatter for each world
					for world,formatter in pairs(mod.score_formatters) do
						-- call module-provided formatter on each element in list
						-- to generate a table for that world
						print ("Preparing scores for ",world,"with",formatter)
						mod.highscores[world] = HighScores.createHighScoreTable(world,formatter)
					end
				end
				mod.zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text="#{bold}##GOLD#"..mod.long_name.."#GREEN# High Scores#WHITE##{normal}#\n\n"}
				table.insert(self.list, mod)
			end
		end
	end
end

function _M:changemodules(item)
	if item and self.uis[2] then
		self.uis[2].ui = item.zone
		self.cur_sel = item

		local worlds = {}
		for k,_ in pairs(item.highscores) do table.insert(worlds,{world=k}) end
		self.c_sublist:setList(worlds)
		if #worlds > 0 then
			-- show text from first world
			item.zone.text = "#{bold}##GOLD#"..item.long_name.."("..worlds[1].world..")".."#GREEN# High Scores#WHITE##{normal}#\n\n"
			item.zone.text = item.zone.text .. item.highscores[worlds[1].world]
			item.zone:generate()
		end
	end
end

function _M:changeworlds(item)
	if item and self.uis[2] then
		world = item.world;
		self.cur_sel.zone.text = "#{bold}##GOLD#"..self.cur_sel.long_name.."("..world..")".."#GREEN# High Scores#WHITE##{normal}#\n\n"
		self.cur_sel.zone.text = self.cur_sel.zone.text .. self.cur_sel.highscores[world]
		self.cur_sel.zone:generate()
	end
end