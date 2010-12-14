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
local TreeList = require "engine.ui.TreeList"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

local _points_left = [[
Categories points left: #00FF00#%d#WHITE#
Class Talents points left: #00FF00#%d#WHITE#
Generic Talents points left: #00FF00#%d#WHITE#]]

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
	self.c_points = Textzone.new{width=math.floor(self.iw / 2 - 10), height=1, auto_height=true, no_color_bleed=true, text=_points_left:format(self.actor.unused_talents_types, self.actor.unused_talents, self.actor.unused_generics)}
	self.c_desc = TextzoneList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.c_tut.h - 20, scrollbar=true, no_color_bleed=true}

	self:generateList()

	self.c_tree = TreeList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 15 - self.c_points.h, all_clicks=true, scrollbar=true, columns={
		{width=80, display_prop="name"},
		{width=20, display_prop="status"},
	}, tree=self.tree,
		fct=function(item, sel, v) self:treeSelect(item, sel, v) end,
		select=function(item, sel) self:select(item) end,
		on_expand=function(item) self.actor.__hidden_talent_types[item.type] = not item.shown end,
		on_drawitem=function(item) if self.running then self:onDrawItem(item) end end,
	}

	self:loadUI{
		{left=0, top=0, ui=self.c_points},
		{left=5, top=self.c_points.h+5, ui=Separator.new{dir="vertical", size=math.floor(self.iw / 2) - 10}},
		{left=0, top=self.c_points.h+15, ui=self.c_tree},

		{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},

		{right=0, top=self.c_tut.h + 20, ui=self.c_desc},
		{right=0, top=0, ui=self.c_tut},
	}
	self:setFocus(self.c_tree)
	self:setupUI()

	self.talents_changed = {}
	self.running = true

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
	self.c_tree.key:addBind("ACCEPT", function() self.key:triggerVirtual("EXIT") end)
	self.key:addBinds{
		MOVE_LEFT = function() local item=self.c_tree.list[self.c_tree.sel] self:treeSelect(item, self.c_tree.sel, "right") end,
		MOVE_RIGHT = function() local item=self.c_tree.list[self.c_tree.sel] self:treeSelect(item, self.c_tree.sel, "left") end,
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

function _M:computeDeps(t)
	local d = {}
	self.talents_deps[t.id] = d

	-- Check prerequisites
	if rawget(t, "require") then
		local req = t.require
		if type(req) == "function" then req = req(self.actor, t) end

		if req.talent then
			for _, tid in ipairs(req.talent) do
				if type(tid) == "table" then
					d[tid[1]] = true
--					print("Talent deps: ", t.id, "depends on", tid[1])
				else
					d[tid] = true
--					print("Talent deps: ", t.id, "depends on", tid)
				end
			end
		end
	end

	-- Check number of talents
	for id, nt in pairs(self.actor.talents_def) do
		if nt.type[1] == t.type[1] then
			d[id] = true
--			print("Talent deps: ", t.id, "same category as", id)
		end
	end
end

function _M:generateList()
	self.actor.__show_special_talents = self.actor.__show_special_talents or {}

	-- Makes up the list
	local tree = {}
	self.talents_deps = {}
	for i, tt in ipairs(self.actor.talents_types_def) do
		if not tt.hide and not (self.actor.talents_types[tt.type] == nil) then
			local cat = tt.type:gsub("/.*", "")
			local ttknown = self.actor:knowTalentType(tt.type)
			local tshown = (self.actor.__hidden_talent_types[tt.type] == nil and ttknown) or (self.actor.__hidden_talent_types[tt.type] ~= nil and not self.actor.__hidden_talent_types[tt.type])
			local node = {
				name=function(item) return tstring{{"font", "bold"}, cat:capitalize().." / "..tt.name:capitalize() ..(" (mastery %.02f)"):format(self.actor:getTalentTypeMastery(tt.type)), {"font", "normal"}} end,
				rawname=function(item) return cat:capitalize().." / "..tt.name:capitalize() ..(" (mastery %.02f)"):format(self.actor:getTalentTypeMastery(tt.type)) end,
				type=tt.type,
				color=function(item) return self.actor:knowTalentType(item.type) and {0,200,0} or {175,175,175} end,
				shown = tshown,
				status = function(item) return self.actor:knowTalentType(item.type) and tstring{{"color", 0x00, 0xC8, 0x00}, "known"} or tstring{{"color", 0x00, 0xC8, 0x00}, "0/1"} end,
				nodes = {},
			}
			tree[#tree+1] = node

			local list = node.nodes

			-- Find all talents of this school
			for j, t in ipairs(tt.talents) do
				if not t.hide or self.actor.__show_special_talents[t.id] then
					self:computeDeps(t)

					local typename = "class"
					if t.generic then typename = "generic" end
					list[#list+1] = {
						__id=t.id,
						name=t.name.." ("..typename..")",
						rawname=t.name.." ("..typename..")",
						talent=t.id,
						_type=tt.type,
						color=function(item) return self.actor:knowTalentType(item._type) and {255,255,255} or {175,175,175} end,
					}
					list[#list].status = function(item)
						local t = self.actor:getTalentFromId(item.talent)
						local ttknown = self.actor:knowTalentType(item._type)
						if self.actor:getTalentLevelRaw(t.id) == t.points then
							if ttknown then
								return tstring{{"color", "LIGHT_GREEN"}, "known"}
							else
								return tstring{{"color", 0x80, 0x80, 0x80}, "known"}
							end
						else
							if not self.actor:canLearnTalent(t) then
								return tstring{(ttknown and {"color", 0xFF, 0x00, 0x00} or {"color", 0x80, 0x80, 0x80}), self.actor:getTalentLevelRaw(t.id).."/"..t.points}
							else
								return tstring{(ttknown and {"color", "WHITE"} or {"color", 0x80, 0x80, 0x80}), self.actor:getTalentLevelRaw(t.id).."/"..t.points}
							end
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
		self.actor:forceUseTalent(tid, {ignore_energy=true, ignore_cd=true})
		self.actor:forceUseTalent(tid, {ignore_energy=true, ignore_cd=true})
	end
end

function _M:onDrawItem(item)
	if not item then return end
	local text = tstring{}

	text:add({"color", "GOLD"}, {"font", "bold"}, util.getval(item.rawname, item), {"color", "LAST"}, {"font", "normal"})
	text:add(true, true)

	if item.type then
		text:add({"color",0x00,0xFF,0xFF}, "Talent Category", true)
		text:add({"color",0x00,0xFF,0xFF}, "A talent category allows you to learn talents of this category. You gain a talent category point at level 10, 20 and 30. You may also find trainers or artifacts that allow you to learn more.\nA talent category point can be used either to learn a new category or increase the mastery of a known one.", true, true, {"color", "WHITE"})
		text:add(self.actor:getTalentTypeFrom(item.type).description)
	else
		local t = self.actor:getTalentFromId(item.talent)

		local what
		if t.generic then
			what = "generic talent"
			text:add({"color",0x00,0xFF,0xFF}, "Generic Talent", true)
			text:add({"color",0x00,0xFF,0xFF}, "A generic talent allows you to perform various utility actions and improve your character. It represents talents anybody can learn (should they find a trainer for it). You gain one point every levels (except every 5th level). You may also find trainers or artifacts that allow you to learn more.", true, true, {"color", "WHITE"})
		else
			what = "class talent"
			text:add({"color",0x00,0xFF,0xFF}, "Class talent", true)
			text:add({"color",0x00,0xFF,0xFF}, "A class talent allows you to perform new combat moves, cast spells, and improve your character. It represents the core function of your class. You gain one point every level and two every 5th level. You may also find trainers or artifacts that allow you to learn more.", true, true, {"color", "WHITE"})
		end

		if self.actor:getTalentLevelRaw(t.id) > 0 then
			local req = self.actor:getTalentReqDesc(item.talent, 0)
			text:add{"color","WHITE"}
			text:add("Current "..what.." level: "..(self.actor:getTalentLevelRaw(t.id)))
			text:add(true)
			text:merge(req)
			text:merge(self.actor:getTalentFullDescription(t))
		end

		if self.actor:getTalentLevelRaw(t.id) < t.points then
			local req2 = self.actor:getTalentReqDesc(item.talent, 1)
			text:add("Next "..what.." level: "..(self.actor:getTalentLevelRaw(t.id)+1))
			text:add(true)
			text:merge(req2)
			text:merge(self.actor:getTalentFullDescription(t, 1))
		end
	end

	self.c_desc:createItem(item, text)

end

function _M:select(item)
	if not item or not self.uis or not self.uis[5] then return end

	if not self.c_desc:switchItem(item) then
		self:onDrawItem(item)
		self.c_desc:switchItem(item)
	end
end

function _M:treeSelect(item, sel, v)
	if not item then return end
	self:learn(v == "left" and true)
	if item.nodes then
		item.shown = (self.actor.__hidden_talent_types[item.type] == nil and self.actor:knowTalentType(item.type)) or (self.actor.__hidden_talent_types[item.type] ~= nil and not self.actor.__hidden_talent_types[item.type])
		self.c_tree:drawItem(item)
		for i, n in ipairs(item.nodes) do self.c_tree:drawItem(n) end
	elseif item.talent then
		for tid, _ in pairs(self.talents_deps[item.talent] or {}) do
			local it = self.c_tree.items_by_key[tid]
			if it then self.c_tree:drawItem(it) end
		end
	end
	self.c_desc:switchItem(item)
	self.c_tree:outputList()

	self.c_points.text = _points_left:format(self.actor.unused_talents_types, self.actor.unused_talents, self.actor.unused_generics)
	self.c_points:generate()
end

function _M:learn(v)
	local item = self.c_tree.list[self.c_tree.sel]
	if not item then return end
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
end

function _M:learnType(tt, v)
	if v then
		if self.actor:knowTalentType(tt) and self.actor.__increased_talent_types[tt] and self.actor.__increased_talent_types[tt] >= 1 then
			self:simplePopup("Impossible", "You can only improve a category mastery once!")
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
			self.actor:setTalentTypeMastery(tt, self.actor:getTalentTypeMastery(tt) + 0.2)
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
			self.actor:setTalentTypeMastery(tt, self.actor:getTalentTypeMastery(tt) - 0.2)
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
end
