-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"

--local LevelupTalentsDialog = require "mod.dialogs.LevelupTalentsDialog"

module(..., package.seeall, class.inherit(Dialog))

local _points_text = "Points left: #00FF00#%d#WHITE#"


-- This stuff is quite the mess.  I preserved Sus' Voice of Telos dialogues as much as possible but some of his stats we're simply not using
-- I'm also not sure about some of this code and someone else with more understanding should go over it at some point and clean it up 
-- (Or I'll go over it at some point when I have more understanding of it)
-- For now though it's working, Voice of Telos can swap spellpower for spellcrit
function _M:init(actor, on_finish)
	self.actor = actor.actor

	self.o = actor.o
--	print("Incoming factory settings:", self.o.factory_settings.dam) --self.o.factory_settings.critical_power, self.o.factory_settings.max_acc)
--	print("Incoming factory setting mins:", self.o.factory_settings.mins.dam) --self.o.factory_settings.mins.critical_power, self.o.factory_settings.mins.max_acc)
--	print("Incoming factory setting maxes:", self.o.factory_settings.maxes.dam)-- self.o.factory_settings.maxes.critical_power, self.o.factory_settings.maxes.max_acc)
	self.actor_dup = actor.actor:clone()
	self.unused_stats = self.o.unused_stats
	--Dialog.init(self, self.o.name, 500, 300)
	Dialog.init(self, self.o.name, 300, 200)

	self.sel = 1

	self.c_tut = Textzone.new{width=math.floor(self.iw / 2 - 10), auto_height=true, no_color_bleed=true, text=[[
Keyboard: #00FF00#up key/down key#FFFFFF# to select a stat; #00FF00#right key#FFFFFF# to increase stat; #00FF00#left key#FFFFFF# to decrease a stat.
Mouse: #00FF00#Left click#FFFFFF# to increase a stat; #00FF00#right click#FFFFFF# to decrease a stat.
]]}
	self.c_desc = TextzoneList.new{width=math.floor(self.iw - 10), height=self.ih - self.c_tut.h - 20, no_color_bleed=true}
	self.c_points = Textzone.new{width=math.floor(self.iw - 10), auto_height=true, no_color_bleed=true, text=_points_text:format(self.unused_stats)}

	self.c_list = ListColumns.new{width=math.floor(self.iw - 10), height=self.ih - 10, all_clicks=true, columns={
		{name="Stat", width=70, display_prop="name"},
		{name="Value", width=30, display_prop="val"},
	}, list={
		{name="Spellpower", val=self.o.wielder.combat_spellpower, stat_id = "combat_spellpower", delta = 3},
		{name="Spellcrit", val=self.o.wielder.combat_spellcrit, stat_id = "combat_spellcrit", delta = 1},
		--{name="Critical power", val=self.o.combat.critical_power, stat_id = "critical_power", delta = 0.1},
		--{name="Maximum hit chance", val=self.o.combat.max_acc, stat_id = "max_acc", delta = 5},
		--{name="Strength", val=self.actor:getStr(), stat_id=self.actor.STAT_STR},
		--{name="Dexterity", val=self.actor:getDex(), stat_id=self.actor.STAT_DEX},
		--{name="Magic", val=self.actor:getMag(), stat_id=self.actor.STAT_MAG},
		--{name="Willpower", val=self.actor:getWil(), stat_id=self.actor.STAT_WIL},
		--{name="Cunning", val=self.actor:getCun(), stat_id=self.actor.STAT_CUN},
		--{name="Constitution", val=self.actor:getCon(), stat_id=self.actor.STAT_CON},
	}, fct=function(item, _, v)
		self:incStat(v == "left" and 1 or -1, item.stat_id)
	--end, select=function(item, sel) self.sel = sel self.c_desc:switchItem(item, self.actor.stats_def[item.stat_id].description) end}
	--end, select=function(item, sel) self.sel = sel game.logPlayer(game.player, "just selected %s", sel)  end}
	--end, select=function(item, sel) self.sel = sel game.logPlayer(game.player, "just selected %s", item.stat_id)  end}
	end, select=function(item, sel) self.sel = sel self.id = item.stat_id self.delta = item.delta end}
	self:loadUI{
		{left=0, top=0, ui=self.c_points},
		--{left=5, top=self.c_points.h+5, ui=Separator.new{dir="vertical", size=math.floor(self.iw / 2) - 10}},
		{left=0, top=self.c_points.h+15, ui=self.c_list},

		--{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},

		--{right=0, top=self.c_tut.h + 20, ui=self.c_desc},
		--{right=0, top=0, ui=self.c_tut},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self:update()

	self.key:addBinds{
		EXIT = function()
			game:unregisterDialog(self)
			self:finish()
		end,
	}
end

function _M:finish()
	local inven = game.player:getInven("MAINHAND")
	local o = game.player:takeoffObject(inven, 1)
	game.player:addObject(inven, o)

	--if self.actor.unused_stats == self.unused_stats then return end
--[=[	local reset = {}
	for tid, act in pairs(self.actor.sustain_talents) do
		if act then
			local t = self.actor:getTalentFromId(tid)
			if t.no_sustain_autoreset then
				game.logPlayer(self.actor, "#LIGHT_BLUE#Warning: You have increased some of your statistics. Talent %s is actually sustained; if it is dependent on one of the stats you changed, you need to re-use it for the changes to take effect.", t.name)
			else
				reset[#reset+1] = tid
			end
		end
	end
	for i, tid in ipairs(reset) do
		self.actor:forceUseTalent(tid, {ignore_energy=true, ignore_cd=true})
		self.actor:forceUseTalent(tid, {ignore_energy=true, ignore_cd=true})
	end
	]=]
end

function _M:incStat(v, id)
	print("inside incStat. self.sel is", self.sel)
	print("inside incStat. id is", self.id)
	local id = self.id
	local delta = self.delta * v
	if v == 1 then
		if self.o.unused_stats <= 0 then
			self:simplePopup("Not enough stat points", "You have no stat points left!")
			return
		end
		print(self.o.wielder[id] or "false", self.o.factory_settings.maxes[id] or "false")
		if self.o.wielder[id] >= self.o.factory_settings.maxes[id] then
			self:simplePopup("Stat is at the maximum", "You can not increase this stat further!")
			return
		end
	else
		print(self.o.wielder[id] or "false", self.o.factory_settings.mins[id] or "false")
		if self.o.wielder[id] <= self.o.factory_settings.mins[id] then
			self:simplePopup("Impossible", "You cannot take out more points!")
			return
		end
		if self.o.wielder[id] + delta <= 0 then
			self:simplePopup("Impossible", "You cannot take out more points!")
			return
		end
	end

	local sel = self.sel
	self.o.wielder[id] = self.o.wielder[id] + delta
	if id == "dam" then 
		for k, v in pairs(self.o.wielder["inc_damage"]) do
			self.o.wielder["inc_damage"][k] = v + delta
		end
		if self.o.combat.of_breaching then
			for k, v in pairs(self.o.wielder["resists_pen"]) do
				self.o.wielder["resists_pen"][k] = v + (delta/2)
			end
		end
		--update_secondary(self.o, delta/2, "resists_pen") 
	end
	--self.actor:incStat(sel, v)
	self.o.unused_stats = self.o.unused_stats - v
	self.c_list.list[sel].val = self.o.wielder[id]
	self.c_list:generate()
	self.c_list.sel = sel
	self.c_list:onSelect()
	self.c_points.text = _points_text:format(self.o.unused_stats)
	self.c_points:generate()
	self:update()
end

--local function update_secondary(o, d, tab)
--	for k, v in pairs(o.wielder[tab]) do
--		o.wielder[tab][k] = v + d
--	end
--end

function _M:update()
	self.c_list.key:addBinds{
		ACCEPT = function() self.key:triggerVirtual("EXIT") end,
		MOVE_LEFT = function() self:incStat(-1) end,
		MOVE_RIGHT = function() self:incStat(1) end,
	}
end

function _M:drawDialog(s)
	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)
	local statshelp = ([[Keyboard: #00FF00#up key/down key#FFFFFF# to select a stat; #00FF00#right key#FFFFFF# to increase stat; #00FF00#left key#FFFFFF# to decrease a stat.
Mouse: #00FF00#Left click#FFFFFF# to increase a stat; #00FF00#right click#FFFFFF# to decrease a stat.
]]):splitLines(self.iw / 2 - 10, self.font)
	local lines = self.actor.stats_def[self.sel].description:splitLines(self.iw / 2 - 10, self.font)
	for i = 1, #statshelp do
		s:drawColorStringBlended(self.font, statshelp[i], self.iw / 2 + 5, 2 + (i-1) * self.font:lineSkip())
	end
	for i = 1, #lines do
		s:drawColorStringBlended(self.font, lines[i], self.iw / 2 + 5, 2 + (i + #statshelp + 1) * self.font:lineSkip())
	end

	-- Stats
	s:drawColorStringBlended(self.font, "Stats points left: #00FF00#"..self.actor.unused_stats, 2, 2)
	self:drawWBorder(s, 2, 20, 200)

	self:drawSelectionList(s, 2, 25, self.font_h, {
		"Strength", "Dexterity", "Magic", "Willpower", "Cunning", "Constitution"
	}, self.sel)
	self:drawSelectionList(s, 100, 25, self.font_h, {
		self.actor:getStr(), self.actor:getDex(), self.actor:getMag(), self.actor:getWil(), self.actor:getCun(), self.actor:getCon(),
	}, self.sel)
	self.changed = false
end
