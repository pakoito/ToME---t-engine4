-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

local LevelupTalentsDialog = require "mod.dialogs.LevelupTalentsDialog"

module(..., package.seeall, class.inherit(Dialog))

local _points_text = "Stats points left: #00FF00#%d#WHITE#"

function _M:init(actor, on_finish)
	self.actor = actor
	self.actor_dup = actor:clone()
	self.unused_stats = self.actor.unused_stats
	Dialog.init(self, "Stats Levelup: "..actor.name, 600, 500)

	self.sel = 1

	self.c_tut = Textzone.new{width=math.floor(self.iw / 2 - 10), auto_height=true, no_color_bleed=true, text=[[
Keyboard: #00FF00#up key/down key#FFFFFF# to select a stat; #00FF00#right key#FFFFFF# to increase stat; #00FF00#left key#FFFFFF# to decrease a stat.
Mouse: #00FF00#Left click#FFFFFF# to increase a stat; #00FF00#right click#FFFFFF# to decrease a stat.
]]}
	self.c_desc = TextzoneList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.c_tut.h - 20, no_color_bleed=true}
	self.c_points = Textzone.new{width=math.floor(self.iw / 2 - 10), auto_height=true, no_color_bleed=true, text=_points_text:format(self.actor.unused_stats)}

	self.c_list = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, all_clicks=true, columns={
		{name="Stat", width=50, display_prop="name"},
		{name="Base", width=25, display_prop="base"},
		{name="Value", width=25, display_prop="val"},
	}, list={
		{name="Strength",     base=self.actor:getStr(nil, nil, true), val=self.actor:getStr(), stat_id=self.actor.STAT_STR},
		{name="Dexterity",    base=self.actor:getDex(nil, nil, true), val=self.actor:getDex(), stat_id=self.actor.STAT_DEX},
		{name="Magic",        base=self.actor:getMag(nil, nil, true), val=self.actor:getMag(), stat_id=self.actor.STAT_MAG},
		{name="Willpower",    base=self.actor:getWil(nil, nil, true), val=self.actor:getWil(), stat_id=self.actor.STAT_WIL},
		{name="Cunning",      base=self.actor:getCun(nil, nil, true), val=self.actor:getCun(), stat_id=self.actor.STAT_CUN},
		{name="Constitution", base=self.actor:getCon(nil, nil, true), val=self.actor:getCon(), stat_id=self.actor.STAT_CON},
	}, fct=function(item, _, v)
		self:incStat(v == "left" and 1 or -1)
	end, select=function(item, sel) self.sel = sel self.c_desc:switchItem(item, self.actor.stats_def[item.stat_id].description) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_points},
		{left=5, top=self.c_points.h+5, ui=Separator.new{dir="vertical", size=math.floor(self.iw / 2) - 10}},
		{left=0, top=self.c_points.h+15, ui=self.c_list},

		{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},

		{right=0, top=self.c_tut.h + 20, ui=self.c_desc},
		{right=0, top=0, ui=self.c_tut},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self:update()

	self.key:addBinds{
		EXIT = function()
			game:unregisterDialog(self)
			self:finish()

			-- if talents to spend, do it now
			if self.actor.unused_generics > 0 or self.actor.unused_talents > 0 or self.actor.unused_talents_types > 0 then
				local dt = LevelupTalentsDialog.new(self.actor, on_finish)
				game:registerDialog(dt)
			end
		end,
	}
end

function _M:finish()
	if self.actor.unused_stats == self.unused_stats then return end
	local reset = {}
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
		self.actor:forceUseTalent(tid, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
		self.actor:forceUseTalent(tid, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
	end
end

function _M:incStat(v)
	if v == 1 then
		if self.actor.unused_stats <= 0 then
			self:simplePopup("Not enough stat points", "You have no stat points left!")
			return
		end
		if self.actor:getStat(self.sel, nil, nil, true) >= self.actor.level * 1.4 + 20 then
			self:simplePopup("Stat is at the maximum for your level", "You cannot increase this stat further until next level!")
			return
		end
		if self.actor:isStatMax(self.sel) or self.actor:getStat(self.sel, nil, nil, true) >= 60 then
			self:simplePopup("Stat is at the maximum", "You cannot increase this stat further!")
			return
		end
	else
		if self.actor_dup:getStat(self.sel, nil, nil, true) == self.actor:getStat(self.sel, nil, nil, true) then
			self:simplePopup("Impossible", "You cannot take out more points!")
			return
		end
	end

	local sel = self.sel
	self.actor:incStat(sel, v)
	self.actor.unused_stats = self.actor.unused_stats - v
	self.c_list.list[sel].base = self.actor:getStat(sel, nil, nil, true)
	self.c_list.list[sel].val = self.actor:getStat(sel)
	self.c_list:generate()
	self.c_list.sel = sel
	self.c_list:onSelect()
	self.c_points.text = _points_text:format(self.actor.unused_stats)
	self.c_points:generate()
	self:update()
end

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
