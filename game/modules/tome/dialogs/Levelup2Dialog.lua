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
local Textzone = require "engine.ui.Textzone"
local TalentTrees = require "mod.dialogs.elements.TalentTrees"
local Separator = require "engine.ui.Separator"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.inherit(Dialog, mod.class.interface.TooltipsData))

local _points_text = "Stats points left: #00FF00#%d#LAST#"

local _points_left = [[
Category points left: #00FF00#%d#LAST#
Class talent points left: #00FF00#%d#LAST#
Generic talent points left: #00FF00#%d#LAST#]]

function _M:init(actor, on_finish, on_birth)
	self.on_birth = on_birth
	actor.no_last_learnt_talents_cap = true
	self.actor = actor
	self.unused_stats = self.actor.unused_stats
	self.new_stats_changed = false
	self.new_talents_changed = false

	self.talents_changed = {}
	self.on_finish = on_finish
	self.running = true
	self.prev_stats = {}
	self.font_h = self.font:lineSkip()
	self.talents_learned = {}
	self.talent_types_learned = {}
	self.stats_increased = {}

	self.font = core.display.newFont("/data/font/DroidSansMono.ttf", 12)
	self.font_h = self.font:lineSkip()

	self.actor.__hidden_talent_types = self.actor.__hidden_talent_types or {}
	self.actor.__increased_talent_types = self.actor.__increased_talent_types or {}

	self.actor_dup = actor:clone()
	self.actor_dup.uid = actor.uid -- Yes ...

	for _, v in pairs(game.engine.Birther.birth_descriptor_def) do
		if v.type == "subclass" and v.name == actor.descriptor.subclass then self.desc_def = v break end
	end

	Dialog.init(self, "Levelup: "..actor.name, game.w * 0.9, game.h * 0.9, game.w * 0.05, game.h * 0.05)

	self:generateList()

	self:loadUI(self:createDisplay())
	self:setupUI()

	self.key:addBinds{
		EXIT = function()
			if self.actor.unused_stats~=self.actor_dup.unused_stats or self.actor.unused_talents_types~=self.actor_dup.unused_talents_types or
			self.actor.unused_talents~=self.actor_dup.unused_talents or self.actor.unused_generics~=self.actor_dup.unused_generics then
				self:yesnocancelPopup("Finish","Do you accept changes?", function(yes, cancel)
				if cancel then
					return nil
				else
					if yes then ok = self:finish() else ok = true self:cancel() end
				end
				if ok then
					game:unregisterDialog(self)
					self.actor_dup = {}
					if self.on_finish then self.on_finish() end
				end
				end)
			else
				game:unregisterDialog(self)
				self.actor_dup = {}
				if self.on_finish then self.on_finish() end
			end
		end,
	}
end

function _M:unload()
	self.actor.no_last_learnt_talents_cap = nil
	self.actor:capLastLearntTalents("class")
	self.actor:capLastLearntTalents("generic")
end

function _M:cancel()
	local ax, ay = self.actor.x, self.actor.y
	self.actor_dup.replacedWith = false
	self.actor:replaceWith(self.actor_dup)
	self.actor.replacedWith = nil
	self.actor.x, self.actor.y = ax, ay
	self.actor.changed = true
	self.actor:removeAllMOs()
	if game.level and self.actor.x then game.level.map:updateMap(self.actor.x, self.actor.y) end
end

function _M:getMaxTPoints(t)
	if t.points == 1 then return 1 end
	return t.points + math.max(0, math.floor((self.actor.level - 50) / 10))
end

function _M:finish()
	local ok, dep_miss = self:checkDeps(true)
	if not ok then
		self:simpleLongPopup("Impossible", "You cannot learn this talent(s): "..dep_miss, game.w * 0.4)
		return nil
	end

	local txt = "#LIGHT_BLUE#Warning: You have increased some of your statistics or talent. Talent(s) actually sustained: \n %s If these are dependent on one of the stats you changed, you need to re-use them for the changes to take effect."
	local talents = ""
	local reset = {}
	for tid, act in pairs(self.actor.sustain_talents) do
		if act then
			local t = self.actor:getTalentFromId(tid)
			if t.no_sustain_autoreset and self.actor:knowTalent(tid) then
				talents = talents.."#GOLD# - "..t.name.."#LAST#\n"
			else
				reset[#reset+1] = tid
			end
		end
	end
	if talents ~= "" then
		game.logPlayer(self.actor, txt:format(talents))
	end
	for i, tid in ipairs(reset) do
		self.actor:forceUseTalent(tid, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
		if self.actor:knowTalent(tid) then self.actor:forceUseTalent(tid, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true, talent_reuse=true}) end
	end

	if not self.on_birth then
		for t_id, _ in pairs(self.talents_learned) do
			local t = self.actor:getTalentFromId(t_id)
			if not self.actor:isTalentCoolingDown(t) and not self.actor_dup:knowTalent(t_id) then self.actor:startTalentCooldown(t) end
		end
	end
	return true
end

function _M:incStat(sid, v)
	if v == 1 then
		if self.actor.unused_stats <= 0 then
			self:simplePopup("Not enough stat points", "You have no stat points left!")
			return
		end
		if self.actor:getStat(sid, nil, nil, true) >= self.actor.level * 1.4 + 20 then
			self:simplePopup("Stat is at the maximum for your level", "You cannot increase this stat further until next level!")
			return
		end
		if self.actor:isStatMax(sid) or self.actor:getStat(sid, nil, nil, true) >= 60 + math.max(0, (self.actor.level - 50)) then
			self:simplePopup("Stat is at the maximum", "You cannot increase this stat further!")
			return
		end
	else
		if self.actor_dup:getStat(sid, nil, nil, true) == self.actor:getStat(sid, nil, nil, true) then
			self:simplePopup("Impossible", "You cannot take out more points!")
			return
		end
	end

	self.actor:incStat(sid, v)
	self.actor.unused_stats = self.actor.unused_stats - v

	self.stats_increased[sid] = (self.stats_increased[sid] or 0) + v
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

function _M:checkDeps(simple)
	local talents = ""
	local stats_ok = true

	local checked = {}

	local function check(t_id)
		if checked[t_id] then return end
		checked[t_id] = true

		local t = self.actor:getTalentFromId(t_id)
		local ok, reason = self.actor:canLearnTalent(t, 0)
		if not ok and self.actor:knowTalent(t) then talents = talents.."\n#GOLD##{bold}#    - "..t.name.."#{normal}##LAST#("..reason..")" end
		if reason == "not enough stat" then
			stats_ok = false
		end

		local dlist = self.talents_deps[t_id]
		if dlist and not simple then for dtid, _ in pairs(dlist) do check(dtid) end end
	end

	for t_id, _ in pairs(self.talents_changed) do check(t_id) end

	if talents ~="" then
		return false, talents, stats_ok
	else
		return true, "", stats_ok
	end
end

function _M:isUnlearnable(t, limit)
	if not self.actor.last_learnt_talents then return end
	if self.on_birth and self.actor:knowTalent(t.id) and not t.no_unlearn_last then return 1 end -- On birth we can reset any talents except a very few
	local list = self.actor.last_learnt_talents[t.generic and "generic" or "class"]
	local max = self.actor:lastLearntTalentsMax(t.generic and "generic" or "class")
	local min = 1
	if limit then min = math.max(1, #list - (max - 1)) end
	for i = #list, min, -1 do
		if list[i] == t.id then return i end
	end
	return nil
end

function _M:learnTalent(t_id, v)
	self.talents_learned[t_id] = self.talents_learned[t_id] or 0
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
			if self.actor:getTalentLevelRaw(t_id) >= self:getMaxTPoints(t) then
				self:simplePopup("Already known", "You already fully know this talent!")
				return
			end
			self.actor:learnTalent(t_id, true)
			self.actor.unused_talents = self.actor.unused_talents - 1
			self.talents_changed[t_id] = true
			self.talents_learned[t_id] = self.talents_learned[t_id] + 1
			self.new_talents_changed = true
		else
			if not self.actor:knowTalent(t_id) then
				self:simplePopup("Impossible", "You do not know this talent!")
				return
			end
			if not self:isUnlearnable(t, true) and self.actor_dup:getTalentLevelRaw(t_id) >= self.actor:getTalentLevelRaw(t_id) then
				self:simplePopup("Impossible", "You cannot unlearn talents!")
				return
			end
			self.actor:unlearnTalent(t_id, nil, true)
			self.talents_changed[t_id] = true
			local _, reason = self.actor:canLearnTalent(t, 0)
			local ok, dep_miss, stats_ok = self:checkDeps()
			if ok or reason == "not enough stat" or not stats_ok then
				self.actor.unused_talents = self.actor.unused_talents + 1
				self.talents_learned[t_id] = self.talents_learned[t_id] - 1
				self.new_talents_changed = true
			else
				self:simpleLongPopup("Impossible", "You cannot unlearn this talent because of talent(s): "..dep_miss, game.w * 0.4)
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
			if self.actor:getTalentLevelRaw(t_id) >= self:getMaxTPoints(t) then
				self:simplePopup("Already known", "You already fully know this talent!")
				return
			end
			self.actor:learnTalent(t_id)
			self.actor.unused_generics = self.actor.unused_generics - 1
			self.talents_changed[t_id] = true
			self.talents_learned[t_id] = self.talents_learned[t_id] + 1
			self.new_talents_changed = true
		else
			if not self.actor:knowTalent(t_id) then
				self:simplePopup("Impossible", "You do not know this talent!")
				return
			end
			if not self:isUnlearnable(t, true) and self.actor_dup:getTalentLevelRaw(t_id) >= self.actor:getTalentLevelRaw(t_id) then
				self:simplePopup("Impossible", "You cannot unlearn talents!")
				return
			end
			self.actor:unlearnTalent(t_id, nil, true)
			self.talents_changed[t_id] = true
			local _, reason = self.actor:canLearnTalent(t, 0)
			local ok, dep_miss, stats_ok = self:checkDeps()
			if ok or reason == "not enough stat" or not stats_ok then
				self.actor.unused_generics = self.actor.unused_generics + 1
				self.talents_learned[t_id] = self.talents_learned[t_id] - 1
				self.new_talents_changed = true
			else
				self:simpleLongPopup("Impossible", "You can not unlearn this talent because of talent(s): "..dep_miss, game.w * 0.4)
				self.actor:learnTalent(t_id)
				return
			end
		end
	end
	self:updateTooltip()
end

function _M:learnType(tt, v)
	self.talent_types_learned[tt] = self.talent_types_learned[tt] or {}
	if v then
		if self.actor:knowTalentType(tt) and self.actor.__increased_talent_types[tt] and self.actor.__increased_talent_types[tt] >= 1 then
			self:simplePopup("Impossible", "You can only improve a category mastery once!")
			return
		end
		if self.actor.unused_talents_types <= 0 then
			self:simplePopup("Not enough talent category points", "You have no category points left!")
			return
		end
		if not self.actor.talents_types_def[tt] or (self.actor.talents_types_def[tt].min_lev or 0) > self.actor.level then
			self:simplePopup("Too low level", ("This talent tree only provides talents starting at level %d. Learning it now would be useless."):format(self.actor.talents_types_def[tt].min_lev))
			return
		end
		if not self.actor:knowTalentType(tt) then
			self.actor:learnTalentType(tt)
			self.talent_types_learned[tt][1] = true
		else
			self.actor.__increased_talent_types[tt] = (self.actor.__increased_talent_types[tt] or 0) + 1
			self.actor:setTalentTypeMastery(tt, self.actor:getTalentTypeMastery(tt) + 0.2)
			self.talent_types_learned[tt][2] = true
		end
		self:triggerHook{"PlayerLevelup:addTalentType", actor=self.actor, tt=tt}
		self.actor.unused_talents_types = self.actor.unused_talents_types - 1
		self.new_talents_changed = true
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
			self.new_talents_changed = true
			self.talent_types_learned[tt][2] = nil
		else
			self.actor:unlearnTalentType(tt)
			local ok, dep_miss = self:checkDeps()
			if ok then
				self.actor.unused_talents_types = self.actor.unused_talents_types + 1
				self.new_talents_changed = true
				self.talent_types_learned[tt][1] = nil
			else
				self:simpleLongPopup("Impossible", "You cannot unlearn this category because of: "..dep_miss, game.w * 0.4)
				self.actor:learnTalentType(tt)
				return
			end
		end
		self:triggerHook{"PlayerLevelup:subTalentType", actor=self.actor, tt=tt}
	end
	self:updateTooltip()
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
			local isgeneric = self.actor.talents_types_def[tt.type].generic
			local tshown = (self.actor.__hidden_talent_types[tt.type] == nil and ttknown) or (self.actor.__hidden_talent_types[tt.type] ~= nil and not self.actor.__hidden_talent_types[tt.type])
			local node = {
				name=function(item) return tstring{{"font", "bold"}, cat:capitalize().." / "..tt.name:capitalize() ..(" (%s)"):format((isgeneric and "generic" or "class")), {"font", "normal"}} end,
				rawname=function(item) return cat:capitalize().." / "..tt.name:capitalize() ..(" (%s, mastery %.2f)"):format((isgeneric and "generic" or "class"), self.actor:getTalentTypeMastery(item.type)) end,
				type=tt.type,
				color=function(item) return ((self.actor:knowTalentType(item.type) ~= self.actor_dup:knowTalentType(item.type)) or ((self.actor.__increased_talent_types[item.type] or 0) ~= (self.actor_dup.__increased_talent_types[item.type] or 0))) and {255, 215, 0} or self.actor:knowTalentType(item.type) and {0,200,0} or {175,175,175} end,
				shown = tshown,
				status = function(item) return self.actor:knowTalentType(item.type) and tstring{{"font", "bold"}, ((self.actor.__increased_talent_types[item.type] or 0) >=1) and {"color", 255, 215, 0} or {"color", 0x00, 0xFF, 0x00}, ("%.2f"):format(self.actor:getTalentTypeMastery(item.type)), {"font", "normal"}} or tstring{{"color",  0xFF, 0x00, 0x00}, "unknown"} end,
				nodes = {},
				isgeneric = isgeneric and 0 or 1,
				order_id = i,
			}
			tree[#tree+1] = node

			local list = node.nodes

			-- Find all talents of this school
			for j, t in ipairs(tt.talents) do
				if not t.hide or self.actor.__show_special_talents[t.id] then
					self:computeDeps(t)
					local isgeneric = self.actor.talents_types_def[tt.type].generic

					-- Pregenenerate icon with the Tiles instance that allows images
					if t.display_entity then t.display_entity:getMapObjects(game.uiset.hotkeys_display_icons.tiles, {}, 1) end

					list[#list+1] = {
						__id=t.id,
						name=t.name:toTString(),
						rawname=t.name..(isgeneric and " (generic talent)" or " (class talent)"),
						entity=t.display_entity,
						talent=t.id,
						_type=tt.type,
						color=function(item)
							if ((self.actor.talents[item.talent] or 0) ~= (self.actor_dup.talents[item.talent] or 0)) then return {255, 215, 0}
							elseif self:isUnlearnable(t, true) then return colors.simple(colors.LIGHT_BLUE)
							elseif self.actor:knowTalentType(item._type) then return {255,255,255}
							else return {175,175,175}
							end
						end,
					}
					list[#list].status = function(item)
						local t = self.actor:getTalentFromId(item.talent)
						local ttknown = self.actor:knowTalentType(item._type)
						if self.actor:getTalentLevelRaw(t.id) == self:getMaxTPoints(t) then
							return tstring{{"color", 0x00, 0xFF, 0x00}, self.actor:getTalentLevelRaw(t.id).."/"..self:getMaxTPoints(t)}
						else
							if not self.actor:canLearnTalent(t) then
								return tstring{(ttknown and {"color", 0xFF, 0x00, 0x00} or {"color", 0x80, 0x80, 0x80}), self.actor:getTalentLevelRaw(t.id).."/"..self:getMaxTPoints(t)}
							else
								return tstring{(ttknown and {"color", "WHITE"} or {"color", 0x80, 0x80, 0x80}), self.actor:getTalentLevelRaw(t.id).."/"..self:getMaxTPoints(t)}
							end
						end
					end
				end
			end
		end
	end
	table.sort(tree, function(a, b)
		if a.isgeneric == b.isgeneric then
			return a.order_id < b.order_id
		else
			return a.isgeneric < b.isgeneric
		end
	end)
	self.tree = tree

	-- Makes up the stats list
	local phys, mind = {}, {}
	self.tree_stats = {{shown=true, nodes=phys, name="Physical Stats", type_stat=true}, {shown=true, nodes=mind, name="Mental Stats", type_stat=true}}

	for i, sid in ipairs{self.actor.STAT_STR, self.actor.STAT_DEX, self.actor.STAT_CON, self.actor.STAT_MAG, self.actor.STAT_WIL, self.actor.STAT_CUN } do
		local s = self.actor.stats_def[sid]
		local e = engine.Entity.new{image="stats/"..s.short_name:lower()..".png", is_stat=true}
		e:getMapObjects(game.uiset.hotkeys_display_icons.tiles, {}, 1)

		local stats = (i <= 3) and phys or mind
		stats[#stats+1] = {
			name=s.name,
			rawname=s.name,
			entity=e,
			stat=sid,
			desc=s.description,
			color=function(item)
				if self.actor:getStat(sid, nil, nil, true) >= self.actor.level * 1.4 + 20 or
				   self.actor:isStatMax(sid) or
				   self.actor:getStat(sid, nil, nil, true) >= 60 + math.max(0, (self.actor.level - 50)) then
					return {0, 255, 0}
				else
					return {175,175,175}
				end
			end,
			status = function(item)
				if self.actor:getStat(sid, nil, nil, true) >= self.actor.level * 1.4 + 20 or
				   self.actor:isStatMax(sid) or
				   self.actor:getStat(sid, nil, nil, true) >= 60 + math.max(0, (self.actor.level - 50)) then
					return tstring{{"color", 175, 175, 175}, tostring(self.actor:getStat(sid))}
				else
					return tstring{{"color", 0x00, 0xFF, 0x00}, tostring(self.actor:getStat(sid))}
				end
			end,
		}
	end
end

-----------------------------------------------------------------
-- UI Stuff
-----------------------------------------------------------------

local _points_left = [[
Stats points left: #00FF00#%d#LAST#
Category points left: #00FF00#%d#LAST#
Class talent points left: #00FF00#%d#LAST#
Generic talent points left: #00FF00#%d#LAST#]]

function _M:createDisplay()
	self.c_tree = TalentTrees.new{
		tiles=game.uiset.hotkeys_display_icons,
		tree=self.tree,
		width=self.iw-200-10, height=self.ih-10,
		tooltip=function(item) return self:getTalentDesc(item), self.uis[3].x - game.tooltip.max, nil end,
		on_use = function(item, inc) self:onUseTalent(item, inc) end,
		scrollbar = true,
	}

	self.c_stat = TalentTrees.new{
		tiles=game.uiset.hotkeys_display_icons,
		tree=self.tree_stats, no_cross = true,
		width=200, height=210,
		tooltip=function(item) return item.desc end,
		on_use = function(item, inc) self:onUseTalent(item, inc) end,
		on_expand = function(item) self.actor.__hidden_talent_types[item.type] = not item.shown end,
	}

	self.c_points = Textzone.new{
		width=200, height=1, auto_height=true,
		text=_points_left:format(self.actor.unused_stats, self.actor.unused_talents_types, self.actor.unused_talents, self.actor.unused_generics)
	}

	local vsep = Separator.new{dir="horizontal", size=self.ih - 20}
	local hsep = Separator.new{dir="vertical", size=180}

	return {
		{left=0, top=0, ui=self.c_stat},
		{left=self.c_stat, top=10, ui=vsep},
		{left=vsep, top=0, ui=self.c_tree},

		{left=10, top=210, ui=hsep},
		{left=0, top=hsep, ui=self.c_points},
	}
end

function _M:getTalentDesc(item)
	local text = tstring{}

	text:add({"color", "GOLD"}, {"font", "bold"}, util.getval(item.rawname, item), {"color", "LAST"}, {"font", "normal"})
	text:add(true, true)

	if item.type then
		text:add({"color",0x00,0xFF,0xFF}, "Talent Category", true)
		text:add({"color",0x00,0xFF,0xFF}, "A talent category contains talents you may learn. You gain a talent category point at level 10, 20 and 30. You may also find trainers or artifacts that allow you to learn more.\nA talent category point can be used either to learn a new category or increase the mastery of a known one.", true, true, {"color", "WHITE"})

		if self.actor.talents_types_def[item.type].generic then
			text:add({"color",0x00,0xFF,0xFF}, "Generic talent tree", true)
			text:add({"color",0x00,0xFF,0xFF}, "A generic talent allows you to perform various utility actions and improve your character. It represents a skill anybody can learn (should you find a trainer for it). You gain one point every level (except every 5th level). You may also find trainers or artifacts that allow you to learn more.", true, true, {"color", "WHITE"})
		else
			text:add({"color",0x00,0xFF,0xFF}, "Class talent tree", true)
			text:add({"color",0x00,0xFF,0xFF}, "A class talent allows you to perform new combat moves, cast spells, and improve your character. It represents the core function of your class. You gain one point every level and two every 5th level. You may also find trainers or artifacts that allow you to learn more.", true, true, {"color", "WHITE"})
		end

		text:add(self.actor:getTalentTypeFrom(item.type).description)

	else
		local t = self.actor:getTalentFromId(item.talent)

		if self:isUnlearnable(t, true) then
			local max = tostring(self.actor:lastLearntTalentsMax(t.generic and "generic" or "class"))
			text:add({"color","LIGHT_BLUE"}, "This talent was recently learnt, you can still unlearn it.", true, "The last ", max, t.generic and " generic" or " class", " talents you learnt are always unlearnable.", {"color","LAST"}, true, true)
		elseif t.no_unlearn_last then
			text:add({"color","YELLOW"}, "This talent can alter the world in a permanent way, as such you can never unlearn it once known.", {"color","LAST"}, true, true)
		end

		local traw = self.actor:getTalentLevelRaw(t.id)
		local diff = function(i2, i1, res)
			res:add({"color", "LIGHT_GREEN"}, i1, {"color", "LAST"}, " [->", {"color", "YELLOW_GREEN"}, i2, {"color", "LAST"}, "]")
		end
		if traw == 0 and self:getMaxTPoints(t) >= 2 then
			local req = self.actor:getTalentReqDesc(item.talent, 1):toTString():tokenize(" ()[]")
			local req2 = self.actor:getTalentReqDesc(item.talent, 2):toTString():tokenize(" ()[]")
			text:add{"color","WHITE"}
			text:add({"font", "bold"}, "First talent level: ", tostring(traw+1), " [-> ", tostring(traw + 2), "]", {"font", "normal"})
			text:add(true)
			text:merge(req2:diffWith(req, diff))
			text:merge(self.actor:getTalentFullDescription(t, 2):diffWith(self.actor:getTalentFullDescription(t, 1), diff))
		elseif traw < self:getMaxTPoints(t) then
			local req = self.actor:getTalentReqDesc(item.talent):toTString():tokenize(" ()[]")
			local req2 = self.actor:getTalentReqDesc(item.talent, 1):toTString():tokenize(" ()[]")
			text:add{"color","WHITE"}
			text:add({"font", "bold"}, traw == 0 and "Next talent level" or "Current talent level: ", tostring(traw), " [-> ", tostring(traw + 1), "]", {"font", "normal"})
			text:add(true)
			text:merge(req2:diffWith(req, diff))
			text:merge(self.actor:getTalentFullDescription(t, 1):diffWith(self.actor:getTalentFullDescription(t), diff))
		else
			local req = self.actor:getTalentReqDesc(item.talent)
			text:add({"font", "bold"}, "Current talent level: "..traw, {"font", "normal"})
			text:add(true)
			text:merge(req)
			text:merge(self.actor:getTalentFullDescription(t))
		end
	end

	return text
end

function _M:onUseTalent(item, inc)
	if item.type then
		self:learnType(item.type, inc)
		item.shown = (self.actor.__hidden_talent_types[item.type] == nil and self.actor:knowTalentType(item.type)) or (self.actor.__hidden_talent_types[item.type] ~= nil and not self.actor.__hidden_talent_types[item.type])
		self.c_tree:redrawAllItems()
	elseif item.talent then
		self:learnTalent(item.talent, inc)
		self.c_tree:redrawAllItems()
	elseif item.stat then
		self:incStat(item.stat, inc and 1 or -1)
		self.c_stat:redrawAllItems()
		self.c_tree:redrawAllItems()
	end

	self.c_points.text = _points_left:format(self.actor.unused_stats, self.actor.unused_talents_types, self.actor.unused_talents, self.actor.unused_generics)
	self.c_points:generate()
end

function _M:updateTooltip()
	self.c_tree:updateTooltip()
end
