-- ToME - Tales of Middle-Earth
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
local TreeList = require "engine.ui.TreeList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor, on_finish)
	self.actor = actor
	self.actor.__hidden_talent_types = self.actor.__hidden_talent_types or {}
	self.actor.__increased_talent_types = self.actor.__increased_talent_types or {}

	self.actor_dup = actor:clone()
	Dialog.init(self, "Talents Levelup: "..actor.name, math.max(game.w * 0.85, 800), math.max(game.h * 0.85, 600))

	self.c_tut = Textzone.new{width=math.floor(self.iw / 2 - 10), height=1, auto_height=true, no_color_bleed=true, text=[[
Keyboard: #00FF00#up key/down key#FFFFFF# to select a stat; #00FF00#right key#FFFFFF# to learn; #00FF00#left key#FFFFFF# to unlearn; #00FF00#+#FFFFFF# to expand a category; #00FF00#-#FFFFFF# to reduce a category.
Mouse: #00FF00#Left click#FFFFFF# to learn; #00FF00#right click#FFFFFF# to unlearn.
]]}
	self.c_desc = Textzone.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.c_tut.h - 20, no_color_bleed=true, text=""}

	self:generateList()

	self.c_tree = TreeList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, all_clicks=true, scrollbar=true, columns={
		{name="Talent", width=80, display_prop="name"},
		{name="Status", width=20, display_prop="status"},
	}, tree=self.tree,
		fct=function(item, sel, v) self:treeSelect(item, sel, v) end,
		select=function(item, sel) self:select(item) end,
		on_expand=function(item) self.actor.__hidden_talent_types[item.type] = item.shown end,
	}

	self:loadUI{
		{left=0, top=0, ui=self.c_tree},
		{right=0, top=self.c_tut.h + 20, ui=self.c_desc},
		{right=0, top=0, ui=self.c_tut},
		{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_tree)
	self:setupUI()

	self.talents_changed = {}

	self.key:addCommands{
		__TEXTINPUT = function(c)
			local item = self.c_tree.list[self.c_tree.sel]
			if not item or not item.type then return end
			if c == "+" then
				self.c_tree:treeExpand(true)
			end
			if c == "-" then
				self.c_tree:treeExpand(false)
			end
		end,
	}
	self.key:addBinds{
		ACCEPT = "EXIT",
		EXIT = function() game:unregisterDialog(self)
			-- Achievements checks
			world:gainAchievement("ELEMENTALIST", self.actor)
			world:gainAchievement("WARPER", self.actor)

			self:finish()
			if on_finish then on_finish() end
		end,
	}
end

function _M:generateList()
	self.actor.__show_special_talents = self.actor.__show_special_talents or {}

	-- Makes up the list
	local tree = {}
	for i, tt in ipairs(self.actor.talents_types_def) do
		if not tt.hide and not (self.actor.talents_types[tt.type] == nil) then
			local cat = tt.type:gsub("/.*", "")
			local ttknown = self.actor:knowTalentType(tt.type)
			local tshown = (self.actor.__hidden_talent_types[tt.type] == nil and ttknown) or (self.actor.__hidden_talent_types[tt.type] ~= nil and not self.actor.__hidden_talent_types[tt.type])
			local node = {
				name="#{bold}#"..cat:capitalize().." / "..tt.name:capitalize() ..(" (mastery %.02f)"):format(self.actor:getTalentTypeMastery(tt.type)).."#{normal}#",
				type=tt.type,
				color=ttknown and {0,200,0} or {128,128,128},
				shown = tshown,
				status = ttknown and "#00C800#known#WHITE#" or "#00C800#0/1#WHITE#",
				nodes = {},
			}
			tree[#tree+1] = node

			local list = node.nodes

			-- Find all talents of this school
			for j, t in ipairs(tt.talents) do
				if not t.hide or self.actor.__show_special_talents[t.id] then
					local typename = "class"
					if t.generic then typename = "generic" end
					list[#list+1] = {
						name=t.name.." ("..typename..")",
						talent=t.id,
						color=not ttknown and {128,128,128},
					}
					if self.actor:getTalentLevelRaw(t.id) == t.points then
						if ttknown then
							list[#list].status = "#LIGHT_GREEN#known#WHITE#"
						else
							list[#list].status = "#808080#known#WHITE#"
						end
					else
						if not self.actor:canLearnTalent(t) then
							list[#list].status = (ttknown and "#FF0000#" or "#808080#")..self.actor:getTalentLevelRaw(t.id).."/"..t.points.."#WHITE#"
						else
							list[#list].status = (ttknown and "#WHITE#" or "#808080#")..self.actor:getTalentLevelRaw(t.id).."/"..t.points.."#WHITE#"
						end
					end
				end
			end
		end
	end
	self.tree = tree
end

function _M:finish()
	-- Go through all sustained spells
	local reset = {}
	for tid, act in pairs(self.actor.sustain_talents) do
		if act then
			local t = self.actor:getTalentFromId(tid)
			if self.actor:getTalentLevelRaw(tid) ~= self.actor_dup:getTalentLevelRaw(tid) then
				if t.no_sustain_autoreset then
					game.logPlayer(self.actor, "#LIGHT_BLUE#Warning: You have increased your level in %s, but it cannot be auto-reactivated. The new level will only take effect when you re-use it.", t.name)
				else
					reset[#reset+1] = tid
				end
			end
		end
	end
	for i, tid in ipairs(reset) do
		local old = self.actor.energy.value
		self.actor:useTalent(tid)
		self.actor.energy.value = old
		self.actor.talents_cd[tid] = nil
		self.actor:useTalent(tid)
		self.actor.energy.value = old
	end
end

function _M:treeSelect(item, sel, v)
	self:learn(v == "left" and true)
end

function _M:learn(v)
	local item = self.c_tree.list[self.c_tree.sel]
	if not item then return end
	print("===learn", item.name, v)
	if item.type then
		self:learnType(item.type, v)
	else
		self:learnTalent(item.talent, v)
	end
end

function _M:checkDeps()
	for t_id, _ in pairs(self.talents_changed) do
		local t = self.actor:getTalentFromId(t_id)
		if not self.actor:canLearnTalent(t, 0) and self.actor:knowTalent(t) then return false, t.name end
	end
	return true
end

function _M:learnTalent(t_id, v)
	local t = self.actor:getTalentFromId(t_id)
	if not t.generic then
		if v then
			if self.actor.unused_talents < 1 then
				self:simplePopup("Not enough class talent points", "You have no class talent points left!")
				return
			end
			if not self.actor:canLearnTalent(t) then
				self:simplePopup("Cannot learn talent", "Prerequisites not met!")
				return
			end
			if self.actor:getTalentLevelRaw(t_id) >= t.points then
				self:simplePopup("Already known", "You already fully know this talent!")
				return
			end
			self.actor:learnTalent(t_id)
			self.actor.unused_talents = self.actor.unused_talents - 1
			self.talents_changed[t_id] = true
		else
			if not self.actor:knowTalent(t_id) then
				self:simplePopup("Impossible", "You do not know this talent!")
				return
			end
			if self.actor_dup:getTalentLevelRaw(t_id) == self.actor:getTalentLevelRaw(t_id) then
				self:simplePopup("Impossible", "You cannot unlearn talents!")
				return
			end
			self.actor:unlearnTalent(t_id)
			local ok, dep_miss = self:checkDeps()
			if ok then
				self.actor.unused_talents = self.actor.unused_talents + 1
			else
				self:simplePopup("Impossible", "You can not unlearn this talent because of talent: "..dep_miss)
				self.actor:learnTalent(t_id)
				return
			end
		end
	else
		if v then
			if self.actor.unused_generics < 1 then
				self:simplePopup("Not enough generic talent points", "You have no generic talent points left!")
				return
			end
			if not self.actor:canLearnTalent(t) then
				self:simplePopup("Cannot learn talent", "Prerequisites not met!")
				return
			end
			if self.actor:getTalentLevelRaw(t_id) >= t.points then
				self:simplePopup("Already known", "You already fully know this talent!")
				return
			end
			self.actor:learnTalent(t_id)
			self.actor.unused_generics = self.actor.unused_generics - 1
			self.talents_changed[t_id] = true
		else
			if not self.actor:knowTalent(t_id) then
				self:simplePopup("Impossible", "You do not know this talent!")
				return
			end
			if self.actor_dup:getTalentLevelRaw(t_id) == self.actor:getTalentLevelRaw(t_id) then
				self:simplePopup("Impossible", "You cannot unlearn talents!")
				return
			end
			self.actor:unlearnTalent(t_id)
			local ok, dep_miss = self:checkDeps()
			if ok then
				self.actor.unused_generics = self.actor.unused_generics + 1
			else
				self:simplePopup("Impossible", "You can not unlearn this talent because of talent: "..dep_miss)
				self.actor:learnTalent(t_id)
				return
			end
		end
	end
	self:generateList()
end

function _M:learnType(tt, v)
	if v then
		if self.actor:knowTalentType(tt) and self.actor.__increased_talent_types[tt] and self.actor.__increased_talent_types[tt] >= 2 then
			self:simplePopup("Impossible", "You can only improve a category mastery twice!")
			return
		end
		if self.actor.unused_talents_types == 0 then
			self:simplePopup("Not enough talent category points", "You have no category points left!")
			return
		end
		if not self.actor:knowTalentType(tt) then
			self.actor:learnTalentType(tt)
		else
			self.actor.__increased_talent_types[tt] = (self.actor.__increased_talent_types[tt] or 0) + 1
			self.actor:setTalentTypeMastery(tt, self.actor:getTalentTypeMastery(tt) + 0.1)
		end
		self.actor.unused_talents_types = self.actor.unused_talents_types - 1
	else
		if self.actor_dup:knowTalentType(tt) == true and self.actor:knowTalentType(tt) == true and (self.actor_dup.__increased_talent_types[tt] or 0) >= (self.actor.__increased_talent_types[tt] or 0) then
			self:simplePopup("Impossible", "You cannot take out more points!")
			return
		end
		if self.actor_dup:knowTalentType(tt) == true and self.actor:knowTalentType(tt) == true and (self.actor.__increased_talent_types[tt] or 0) == 0 then
			self:simplePopup("Impossible", "You cannot unlearn this category!")
			return
		end
		if not self.actor:knowTalentType(tt) then
			self:simplePopup("Impossible", "You do not know this category!")
			return
		end

		if (self.actor.__increased_talent_types[tt] or 0) > 0 then
			self.actor.__increased_talent_types[tt] = (self.actor.__increased_talent_types[tt] or 0) - 1
			self.actor:setTalentTypeMastery(tt, self.actor:getTalentTypeMastery(tt) - 0.1)
			self.actor.unused_talents_types = self.actor.unused_talents_types + 1
		else
			self.actor:unlearnTalentType(tt)
			local ok, dep_miss = self:checkDeps()
			if ok then
				self.actor.unused_talents_types = self.actor.unused_talents_types + 1
			else
				self:simplePopup("Impossible", "You can not unlearn this category because of: "..dep_miss)
				self.actor:learnTalentType(tt)
				return
			end
		end
	end

	self:generateList()
end

function _M:drawDialog(s)
	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)

	local talentshelp = ([[Keyboard: #00FF00#up key/down key#FFFFFF# to select a stat; #00FF00#right key#FFFFFF# to learn; #00FF00#left key#FFFFFF# to unlearn; #00FF00#+#FFFFFF# to expand a category; #00FF00#-#FFFFFF# to reduce a category.
Mouse: #00FF00#Left click#FFFFFF# to learn; #00FF00#right click#FFFFFF# to unlearn.
]]):splitLines(self.iw / 2 - 10, self.font)

	local lines, helplines, reqlines = nil, {}, nil
	local lines2, reqlines2 = nil, nil
	if self.list[self.sel].type then
		local str = ""
		str = str .. "#00FFFF#Talent Category\n"
		str = str .. "#00FFFF#A talent category allows you to learn talents of this category. You gain a talent category point at level 10, 20 and 30. You may also find trainers or artifacts that allow you to learn more.\nA talent category point can be used either to learn a new category or increase the mastery of a known one.\n\n"
		helplines = str:splitLines(self.iw / 2 - 10, self.font)
		lines = self.actor:getTalentTypeFrom(self.list[self.sel].type).description:splitLines(self.iw / 2 - 10, self.font)
	else
		local t = self.actor:getTalentFromId(self.list[self.sel].talent)

		local str = ""
		local what
		if t.generic then
			what = "generic talent"
			str = str .. "#00FFFF#Generic Talent\n"
			str = str .. "#00FFFF#A generic talent allows you to perform various utility actions and improve your character. It reprents talents anybody can learn (should they find a trainer for it). You gain one point every levels (except every 5th level). You may also find trainers or artifacts that allow you to learn more.\n\n"
		else
			what = "class talent"
			str = str .. "#00FFFF#Class talent\n"
			str = str .. "#00FFFF#A class talent allows you to perform new combat moves, cast spells, and improve your character. It represents the core function of your class. You gain one point every level and two every 5th level. You may also find trainers or artifacts that allow you to learn more.\n\n"
		end
		helplines = str:splitLines(self.iw / 2 - 10, self.font)

		if self.actor:getTalentLevelRaw(t.id) > 0 then
			lines = self.actor:getTalentFullDescription(t):splitLines(self.iw / 2 - 10, self.font)
			local req = self.actor:getTalentReqDesc(self.list[self.sel].talent, 0)
			req = "Current "..what.." level: "..self.actor:getTalentLevelRaw(t.id).."\n"..req
			reqlines = req:splitLines(self.iw / 2 - 10, self.font)
		end

		if self.actor:getTalentLevelRaw(t.id) < t.points then
			local req2 = self.actor:getTalentReqDesc(self.list[self.sel].talent, 1)
			req2 = "Next "..what.." level: "..(self.actor:getTalentLevelRaw(t.id)+1).."\n"..req2
			reqlines2 = req2:splitLines(self.iw / 2 - 10, self.font)
			lines2 = self.actor:getTalentFullDescription(t, 1):splitLines(self.iw / 2 - 10, self.font)
		end
	end
	local h = 2
	for i = 1, #talentshelp do
		s:drawColorStringBlended(self.font, talentshelp[i], self.iw / 2 + 5, h)
		h = h + self.font:lineSkip()
	end

	h = h + self.font:lineSkip()
	self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
	for i = 1, #helplines do
		s:drawColorStringBlended(self.font, helplines[i], self.iw / 2 + 5, h)
		h = h + self.font:lineSkip()
	end

	if reqlines2 and lines2 then
		self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
		for i = 1, #reqlines2 do
			s:drawColorStringBlended(self.font, reqlines2[i], self.iw / 2 + 5, h)
			h = h + self.font:lineSkip()
		end

		for i = 1, #lines2 do
			s:drawColorStringBlended(self.font, lines2[i], self.iw / 2 + 5, 2 + h)
			h = h + self.font:lineSkip()
		end
	end

	if reqlines and lines then
		h = h + self.font:lineSkip()
		self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
		for i = 1, #reqlines do
			s:drawColorStringBlended(self.font, reqlines[i], self.iw / 2 + 5, h)
			h = h + self.font:lineSkip()
		end

		for i = 1, #lines do
			s:drawColorStringBlended(self.font, lines[i], self.iw / 2 + 5, 2 + h)
			h = h + self.font:lineSkip()
		end
	end

	-- Talents
	s:drawColorStringBlended(self.font, "Categories points left: #00FF00#"..self.actor.unused_talents_types, 2, 2)
	s:drawColorStringBlended(self.font, "Class Talents points left: #00FF00#"..self.actor.unused_talents, 2, 2 + self.font_h)
	s:drawColorStringBlended(self.font, "Generic Talents points left: #00FF00#"..self.actor.unused_generics, 2, 2 + self.font_h * 2)
	self:drawWBorder(s, 2, 60, 200)

	self:drawSelectionList(s, 2, 65, self.font_h, self.list, self.sel, "name"     , self.scroll, self.max)
	self:drawSelectionList(s, self.iw / 2 - 70, 65, self.font_h, self.list_known, self.sel, "name", self.scroll, self.max)

	self.changed = false
end
