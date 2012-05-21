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
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"
local Tab = require "engine.ui.Tab"
local TreeList = require "engine.ui.TreeList"
local SurfaceZone = require "engine.ui.SurfaceZone"
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

	for _, v in pairs(game.engine.Birther.birth_descriptor_def) do
		if v.type == "subclass" and v.name == actor.descriptor.subclass then self.desc_def = v break end
	end

	Dialog.init(self, "Stats Levelup: "..actor.name, game.w * 0.9, game.h * 0.9, game.w * 0.05, game.h * 0.05)

	self.vs = Separator.new{dir="vertical", size=self.iw}
	self.vs2 = Separator.new{dir="vertical", size=math.floor(self.iw / 2) - 20}

	self.c_t_tut = Textzone.new{width=math.floor(self.iw / 2 - 10), height=1, auto_height=true, no_color_bleed=true, text=[[
Keyboard: #00FF00#up key/down key#FFFFFF# to select talent; #00FF00#right key#FFFFFF# to learn; #00FF00#left key#FFFFFF# to unlearn; #00FF00#+#FFFFFF# to expand a category; #00FF00#-#FFFFFF# to reduce a category. #00FF00#TAB key#FFFFFF# to switch between tabs.
Mouse: #00FF00#Left click#FFFFFF# to learn; #00FF00#right click#FFFFFF# to unlearn.
]]}
	self.c_t_points = Textzone.new{width=math.floor(self.iw / 2 - 10), height=1, auto_height=true, no_color_bleed=true, text=_points_left:format(self.actor.unused_talents_types, self.actor.unused_talents, self.actor.unused_generics)}

	self:generateList()

	self.stats = Tab.new{title="Stats", default=true, fct=function() end, on_change=function(s) if s then self:switchTo("Stats") end end}
	self.talents = Tab.new{title="Talents", default=false, fct=function() end, on_change=function(s) if s then self:switchTo("Talents") end end}
	self.summary = Tab.new{title="Summary", default=false, fct=function() end, on_change=function(s) if s then self:switchTo("Summary") end end}

	self.c_t_desc = TextzoneList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.c_t_tut.h - self.stats.h - 20 - self.vs.h, scrollbar=true, no_color_bleed=true}


	self.hoffset = 17 + self.stats.h + self.vs.h

	self.c_t_tree = TreeList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.stats.h - 20 - self.c_t_points.h - self.vs.h - self.vs2.h, all_clicks=true, scrollbar=true, columns={
		{width=80, display_prop="name"},
		{width=20, display_prop="status"},
	}, tree=self.tree,
		fct=function(item, sel, v) self:treeSelect(item, sel, v) end,
		select=function(item, sel) self:select(item) end,
		on_expand=function(item) self.actor.__hidden_talent_types[item.type] = not item.shown end,
		on_drawitem=function(item) if self.running then self:onDrawItem(item) end end,
	}
	self.c_t_tree.key:removeBind("ACCEPT") -- We want the main dialog to handle accept

	self.c_summary_desc = SurfaceZone.new{width=self.iw, height=math.min(game.h * 0.9, 400) - self.stats.h - 40 - self.vs.h,alpha=0}

	self.sel = 1

	self.c_tut = Textzone.new{width=math.floor(self.iw / 2 - 10), auto_height=true, no_color_bleed=true, text=[[
Keyboard: #00FF00#up key/down key#FFFFFF# to select a stat; #00FF00#right key#FFFFFF# to increase stat; #00FF00#left key#FFFFFF# to decrease a stat. #00FF00#TAB key#FFFFFF# to switch between tabs.
Mouse: #00FF00#Left click#FFFFFF# to increase a stat; #00FF00#right click#FFFFFF# to decrease a stat.
]]}

	self.c_desc = TextzoneList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.c_tut.h - 20, no_color_bleed=true}
	self.c_desc2 = TextzoneList.new{width=math.floor(self.iw / 4 - 10), height=self.ih - self.c_tut.h - 20, no_color_bleed=true}
	self.c_points = Textzone.new{width=math.floor(self.iw / 2 - 10), auto_height=true, no_color_bleed=true, text=_points_text:format(self.actor.unused_stats)}

	self.c_list = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10 - self.vs.h - self.vs2.h, all_clicks=true, columns={
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
	end, select=function(item, sel)
		self.sel = sel
		self:onSelectStat(item)
	end}
	self.c_list.key:removeBind("ACCEPT") -- We want the main dialog to handle accept

	self.tab = ""
	if self.actor.unused_stats > 0 then
		self.stats:select()
	else
		self.talents:select()
	end
end

function _M:unload()
	self.actor.no_last_learnt_talents_cap = nil
	self.actor:capLastLearntTalents("class")
	self.actor:capLastLearntTalents("generic")
end

local prev_sel = nil
function _M:onSelectStat(item, force)
	if item == prev_sel and not force then return end
	prev_sel = item
	local text , h = self:getStatDescription(item.stat_id)
	local fh = self.font:lineSkip()
	self.c_desc:createItem(item, text)
	self.c_desc:switchItem(item)
	local ui = self:getUIElement(self.c_desc)
	if ui then
		local top = ui.top
		self.c_desc2.h = self.ih - fh + h + top + self.vs.h
		self:moveUIElement(self.c_desc2, nil, nil, 2 * fh + h + top + self.vs.h, nil)
	end
	text = self:getStatNewTalents(item.stat_id)
	self.c_desc2:createItem(item, text)
	self.c_desc2:switchItem(item)
	self:setupUI()
	self:updateKeys(self.tab)
end

function _M:generateStatsList()
	self.c_list.list={
		{name="Strength",   	color = {(self.actor_dup:getStat(self.actor.STAT_STR, nil, nil, true) == self.actor:getStat(self.actor.STAT_STR, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
								(self.actor_dup:getStat(self.actor.STAT_STR, nil, nil, true) == self.actor:getStat(self.actor.STAT_STR, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
								(self.actor:getStat(self.actor.STAT_STR, nil, nil, true) - self.actor_dup:getStat(self.actor.STAT_STR, nil, nil, true) + self.actor_dup:getStat(self.actor.STAT_STR) == self.actor:getStat(self.actor.STAT_STR)) and {255, 255, 255} or {255, 215, 0}},
								base=math.floor(self.actor:getStr(nil, nil, true)),
								val=math.floor(self.actor:getStr()),
								stat_id=self.actor.STAT_STR},
		{name="Dexterity",  	color = {(self.actor_dup:getStat(self.actor.STAT_DEX, nil, nil, true) == self.actor:getStat(self.actor.STAT_DEX, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
								(self.actor_dup:getStat(self.actor.STAT_DEX, nil, nil, true) == self.actor:getStat(self.actor.STAT_DEX, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
								(self.actor:getStat(self.actor.STAT_DEX, nil, nil, true) - self.actor_dup:getStat(self.actor.STAT_DEX, nil, nil, true) + self.actor_dup:getStat(self.actor.STAT_DEX) == self.actor:getStat(self.actor.STAT_DEX)) and {255, 255, 255} or {255, 215, 0}},
								base=math.floor(self.actor:getDex(nil, nil, true)),
								val=math.floor(self.actor:getDex()),
								stat_id=self.actor.STAT_DEX},
		{name="Magic",        	color = {(self.actor_dup:getStat(self.actor.STAT_MAG, nil, nil, true) == self.actor:getStat(self.actor.STAT_MAG, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
								(self.actor_dup:getStat(self.actor.STAT_MAG, nil, nil, true) == self.actor:getStat(self.actor.STAT_MAG, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
								(self.actor:getStat(self.actor.STAT_MAG, nil, nil, true) - self.actor_dup:getStat(self.actor.STAT_MAG, nil, nil, true) + self.actor_dup:getStat(self.actor.STAT_MAG) == self.actor:getStat(self.actor.STAT_MAG)) and {255, 255, 255} or {255, 215, 0}},
								base=math.floor(self.actor:getMag(nil, nil, true)),
								val=math.floor(self.actor:getMag()),
								stat_id=self.actor.STAT_MAG},
		{name="Willpower",    	color = {(self.actor_dup:getStat(self.actor.STAT_WIL, nil, nil, true) == self.actor:getStat(self.actor.STAT_WIL, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
								(self.actor_dup:getStat(self.actor.STAT_WIL, nil, nil, true) == self.actor:getStat(self.actor.STAT_WIL, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
								(self.actor:getStat(self.actor.STAT_WIL, nil, nil, true) - self.actor_dup:getStat(self.actor.STAT_WIL, nil, nil, true) + self.actor_dup:getStat(self.actor.STAT_WIL) == self.actor:getStat(self.actor.STAT_WIL)) and {255, 255, 255} or {255, 215, 0}},
								base=math.floor(self.actor:getWil(nil, nil, true)),
								val=math.floor(self.actor:getWil()),
								stat_id=self.actor.STAT_WIL},
		{name="Cunning",      	color = {(self.actor_dup:getStat(self.actor.STAT_CUN, nil, nil, true) == self.actor:getStat(self.actor.STAT_CUN, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
								(self.actor_dup:getStat(self.actor.STAT_CUN, nil, nil, true) == self.actor:getStat(self.actor.STAT_CUN, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
								(self.actor:getStat(self.actor.STAT_CUN, nil, nil, true) - self.actor_dup:getStat(self.actor.STAT_CUN, nil, nil, true) + self.actor_dup:getStat(self.actor.STAT_CUN) == self.actor:getStat(self.actor.STAT_CUN)) and {255, 255, 255} or {255, 215, 0}},
								base=math.floor(self.actor:getCun(nil, nil, true)),
								val=math.floor(self.actor:getCun()),
								stat_id=self.actor.STAT_CUN},
		{name="Constitution", 	color = {(self.actor_dup:getStat(self.actor.STAT_CON, nil, nil, true) == self.actor:getStat(self.actor.STAT_CON, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
								(self.actor_dup:getStat(self.actor.STAT_CON, nil, nil, true) == self.actor:getStat(self.actor.STAT_CON, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
								(self.actor:getStat(self.actor.STAT_CON, nil, nil, true) - self.actor_dup:getStat(self.actor.STAT_CON, nil, nil, true) + self.actor_dup:getStat(self.actor.STAT_CON) == self.actor:getStat(self.actor.STAT_CON)) and {255, 255, 255} or {255, 215, 0}},
								base=math.floor(self.actor:getCon(nil, nil, true)),
								val=math.floor(self.actor:getCon()),
								stat_id=self.actor.STAT_CON},
	}
	self.c_list:onSelect(true)
end

function _M:switchTo(kind)
	if kind == "Stats" then
		if self.new_talents_changed == true then
			self:generateStatsList()
			self.c_list:generate()
			self.c_list.key:removeBind("ACCEPT") -- We want the main dialog to handle accept
			self.new_talents_changed = false
		end
		self.talents.selected = false
		self.summary.selected = false
	elseif kind == "Talents" then
		if self.new_stats_changed == true then
			self:regenerateList()
			self.new_stats_changed = false
		end
		self.stats.selected = false
		self.summary.selected = false

	elseif kind == "Summary" then
		self.talents.selected = false
		self.stats.selected = false
	end
	self:drawDialog(kind)
	self.tab = kind
end

function _M:updateKeys(kind)
	self.key:reset()
	self.key:unicodeInput(true)
	self.key:addBind("SCREENSHOT", function() if type(game) == "table" and game.key then game.key:triggerVirtual("SCREENSHOT") end end)

	if kind == "Stats" then
		self.key:addCommands{
			_TAB = function() self:tabTabs() end,
		}
		self.key:addBinds{
			MOVE_LEFT = function() self:incStat(-1) end,
			MOVE_RIGHT = function() self:incStat(1) end,
			ACCEPT = function() self:tabTabs() end,
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
	elseif kind == "Talents" then
		self.key:addCommands{
			_TAB = function() self:tabTabs() end,
			__TEXTINPUT = function(c)
				local item = self.c_t_tree.list[self.c_t_tree.sel]
				if not item or not item.type then return end
				if c == "+" then
					self.c_t_tree:treeExpand(true)
				end
				if c == "-" then
					self.c_t_tree:treeExpand(false)
				end
			end,
		}
		self.key:addBinds{
			MOVE_LEFT = function() local item=self.c_t_tree.list[self.c_t_tree.sel] self:treeSelect(item, self.c_t_tree.sel, "right") end,
			MOVE_RIGHT = function() local item=self.c_t_tree.list[self.c_t_tree.sel] self:treeSelect(item, self.c_t_tree.sel, "left") end,
			ACCEPT = function() self:tabTabs() end,
			EXIT = function()
				if self.actor.unused_stats~=self.actor_dup.unused_stats or self.actor.unused_talents_types~=self.actor_dup.unused_talents_types or
				self.actor.unused_talents~=self.actor_dup.unused_talents or self.actor.unused_generics~=self.actor_dup.unused_generics  then
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
	elseif kind == "Summary" then
		self.key:addCommands{
			_TAB = function() self:tabTabs() end,
		}
		self.key:addBinds{
			ACCEPT = "EXIT",
			EXIT = function()
				if self.actor.unused_stats~=self.actor_dup.unused_stats or self.actor.unused_talents_types ~= self.actor_dup.unused_talents_types or
				self.actor.unused_talents ~= self.actor_dup.unused_talents or self.actor.unused_generics~=self.actor_dup.unused_generics then
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
end

function _M:cancel()
--[[
	self.actor.unused_stats = self.actor_dup.unused_stats
	self.actor.unused_talents = self.actor_dup.unused_talents
	self.actor.unused_generics = self.actor_dup.unused_generics
	self.actor.unused_talents_types = self.actor_dup.unused_talents_types
	for stat, inc in pairs(self.stats_increased) do
		self.actor:incStat(stat, -inc)
	end
	for tt, inc in pairs(self.talent_types_learned) do
		if inc[2] then
			self.actor:setTalentTypeMastery(tt, self.actor:getTalentTypeMastery(tt) - 0.2)
			self.actor.__increased_talent_types[tt] = self.actor_dup.__increased_talent_types[tt]
		end

		if inc[1] then
			self.actor:unlearnTalentType(tt)
		end
	end
	for t_id, times in pairs(self.talents_learned) do
		for i=1,times do
			self.actor:unlearnTalent(t_id)
		end
	end
	self.actor.last_learnt_talents = self.actor_dup.last_learnt_talents
]]
	local ax, ay = self.actor.x, self.actor.y
	self.actor:replaceWith(self.actor_dup)
	self.actor.x, self.actor.y = ax, ay
	self.actor.changed = true
	self.actor:removeAllMOs()
	if game.level and self.actor.x then game.level.map:updateMap(self.actor.x, self.actor.y) end
end

function _M:tabTabs()
	if self.stats.selected == true then self.talents:select() elseif
	self.talents.selected == true then self.summary:select() elseif
	self.summary.selected == true then self.stats:select() end
end

function _M:getStatDescription(stat_id)
	local text = self.actor.stats_def[stat_id].description.."\n\n"
	local lines = text:splitLine(self.c_desc.w, self.font)
	local h = self.font:lineSkip()
	local diff = self.actor:getStat(stat_id, nil, nil, true) - self.actor_dup:getStat(stat_id, nil, nil, true)
	local color = diff >= 0 and "#LIGHT_GREEN#" or "#RED#"

	text = text.."#LIGHT_BLUE#Stat gives:#LAST#\n"
	if stat_id == self.actor.STAT_CON then
		text = text.."Max life: "..color..(diff * 4).."#LAST#\n"
		text = text.."Physical save: "..color..(diff * 0.35).."#LAST#\n"
	elseif stat_id == self.actor.STAT_WIL then
		if self.actor:knowTalent(self.actor.T_MANA_POOL) then
			text = text.."Max mana: "..color..(diff * 5).."#LAST#\n"
		end
		if self.actor:knowTalent(self.actor.T_STAMINA_POOL) then
			text = text.."Max stamina: "..color..(diff * 2.5).."#LAST#\n"
		end
		if self.actor:knowTalent(self.actor.T_PSI_POOL) then
			text = text.."Max PSI: "..color..(diff * 1).."#LAST#\n"
		end
		text = text.."Mindpower: "..color..(diff * 0.7).."#LAST#\n"
		text = text.."Mental save: "..color..(diff * 0.35).."#LAST#\n"
		text = text.."Spell save: "..color..(diff * 0.35).."#LAST#\n"
		if self.actor.use_psi_combat then
			text = text.."Accuracy: "..color..(diff * 0.35).."#LAST#\n"
		end
	elseif stat_id == self.actor.STAT_STR then
		text = text.."Physical power: "..color..(diff).."#LAST#\n"
		text = text.."Max encumberance: "..color..(diff * 1.8).."#LAST#\n"
		text = text.."Physical save: "..color..(diff * 0.35).."#LAST#\n"
	elseif stat_id == self.actor.STAT_CUN then
		text = text.."Spell/Physical crit. chance: "..color..(diff * 0.3).."#LAST#\n"
		text = text.."Mental save: "..color..(diff * 0.35).."#LAST#\n"
		text = text.."Mindpower: "..color..(diff * 0.4).."#LAST#\n"
		if self.actor.use_psi_combat then
			text = text.."Accuracy: "..color..(diff * 0.35).."#LAST#\n"
		end
	elseif stat_id == self.actor.STAT_MAG then
		text = text.."Spell save: "..color..(diff * 0.35).."#LAST#\n"
		text = text.."Spellpower: "..color..(diff * 1).."#LAST#\n"
	elseif stat_id == self.actor.STAT_DEX then
		text = text.."Defense: "..color..(diff * 0.35).."#LAST#\n"
		text = text.."Ranged defense: "..color..(diff * 0.35).."#LAST#\n"
		text = text.."Accuracy: "..color..(diff).."#LAST#\n"
	end

	if self.actor.player and self.desc_def and self.desc_def.getStatDesc and self.desc_def.getStatDesc(stat_id, self.actor) then
		text = text.."#LIGHT_BLUE#Class powers:#LAST#\n"
		text = text..self.desc_def.getStatDesc(stat_id, self.actor)
	end
	return text, h * #lines
end

function _M:getMaxTPoints(t)
	if t.points == 1 then return 1 end
	return t.points + math.max(0, math.floor((self.actor.level - 50) / 10))
end

function _M:getStatNewTalents(stat_id)
	local text = "#LIGHT_BLUE#New available talents: #LAST#\n"
	local stats = { "str", "dex", "mag", "wil", "cun", "con" }
	local diff = self.actor:getStat(stat_id) - self.actor_dup:getStat(stat_id)
	if diff ~= 0 and self.talent_stats_req[stats[stat_id]] then
		for j=1,#self.talent_stats_req[stats[stat_id]] do
			local t = self.actor:getTalentFromId(self.talent_stats_req[stats[stat_id]][j][1].talent)
			if self.actor:canLearnTalent(t) and not self.actor_dup:canLearnTalent(t) and self:getMaxTPoints(t) > self.actor:getTalentLevelRaw(t) then
				text = text.."#GOLD#  - "..t.name.."#LAST#\n"
			end
		end
	end

	return text
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
			if t.no_sustain_autoreset then
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

	-- Achievements checks
	world:gainAchievement("ELEMENTALIST", self.actor)
	world:gainAchievement("WARPER", self.actor)
	return true
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
		if self.actor:isStatMax(self.sel) or self.actor:getStat(self.sel, nil, nil, true) >= 60 + math.max(0, (self.actor.level - 50)) then
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
	self.c_list.list[sel].color = 	{(self.actor_dup:getStat(self.sel, nil, nil, true) == self.actor:getStat(self.sel, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
									(self.actor_dup:getStat(self.sel, nil, nil, true) == self.actor:getStat(self.sel, nil, nil, true)) and {255, 255, 255} or {255, 215, 0},
									(self.actor:getStat(self.sel, nil, nil, true) - self.actor_dup:getStat(self.sel, nil, nil, true) + self.actor_dup:getStat(self.sel) == self.actor:getStat(self.sel)) and {255, 255, 255} or {255, 215, 0}}
	self.c_list.sel = sel

	local stats = { "str", "dex", "mag", "wil", "cun", "con" }
	for i = 1,6 do
		stat_sel = stats[i]
		if self.talent_stats_req[stat_sel] then
			to_remove = {}
			for j=1,#self.talent_stats_req[stat_sel] do
				local t = self.talent_stats_req[stat_sel][j][2]
				if type(t.require) == "function" then
					stats_req = t.require(self.actor, t).stat
					for stat, _ in pairs(stats_req) do
						if stat ~= stat_sel then
							self.talent_stats_req[stat] = self.talent_stats_req[stat] or {}
							self.talent_stats_req[stat][#self.talent_stats_req[stat] + 1] = { self.talent_stats_req[stat_sel][j][1], t }
							to_remove[#to_remove+1] = j
						end
					end
				end
			end
			local off = 0
			for j=1,#to_remove do
				table.remove(self.talent_stats_req[stat_sel], to_remove[j] - off)
				off = off + 1
			end
		end
	end

	self.stats_increased[sel] = (self.stats_increased[sel] or 0) + v

	self.c_list:onSelect(true)
	self.c_list:drawItem(self.c_list.list[self.c_list.sel])
	self.c_points.text = _points_text:format(self.actor.unused_stats)
	self.c_points:generate()
	self.new_stats_changed = true
	self:onSelectStat(self.c_list.list[self.c_list.sel], true)
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

function _M:select(item)
	if not item or not self.uis or not self.uis[5] then return end

	if not self.c_t_desc:switchItem(item) then
		self:onDrawItem(item)
		self.c_t_desc:switchItem(item)
	end
	self.cur_item = item
end

function _M:treeSelect(item, sel, v)
	if not item then return end
	self:learn(v == "left" and true)
	if item.nodes then
		item.shown = (self.actor.__hidden_talent_types[item.type] == nil and self.actor:knowTalentType(item.type)) or (self.actor.__hidden_talent_types[item.type] ~= nil and not self.actor.__hidden_talent_types[item.type])
		self.c_t_tree:drawItem(item)
		for i, n in ipairs(item.nodes) do self.c_t_tree:drawItem(n) end
	elseif item.talent then
		for tid, _ in pairs(self.talents_deps[item.talent] or {}) do
			local it = self.c_t_tree.items_by_key[tid]
			if it then self.c_t_tree:drawItem(it) end
		end
		local t = self.actor:getTalentFromId(item.talent)
		for _, tid in ipairs(self.actor.last_learnt_talents[t.generic and "generic" or "class"]) do
			local it = self.c_t_tree.items_by_key[tid]
			if it then self.c_t_tree:drawItem(it) end
		end
	end
	self.c_t_desc:switchItem(item)
	self.c_t_tree:outputList()

	self.c_t_points.text = _points_left:format(self.actor.unused_talents_types, self.actor.unused_talents, self.actor.unused_generics)
	self.c_t_points:generate()
end

function _M:learn(v)
	local item = self.c_t_tree.list[self.c_t_tree.sel]
	if not item then return end
	if item.type then
		self:learnType(item.type, v)
	else
		self:learnTalent(item.talent, v)
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
			self.actor:unlearnTalent(t_id)
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
			self.actor:unlearnTalent(t_id)
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
	self:regenerateList()
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
end

function _M:onDrawItem(item)
	if not item then return end
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

	self.c_t_desc:createItem(item, text)
end

-- Display the player tile
function _M:innerDisplay(x, y, nb_keyframes)
	if self.cur_item and self.cur_item.entity and self.c_t_desc and self.ui_by_ui[self.c_t_desc] then
		self.cur_item.entity:toScreen(game.uiset.hotkeys_display_icons.tiles, x + self.iw - 64, y + self.iy + self.ui_by_ui[self.c_t_desc].y - 32, 64, 64)
	end
end

function _M:generateList()
	self.actor.__show_special_talents = self.actor.__show_special_talents or {}
	self.talent_stats_req = {}
	for i = 1, 6 do
		self.prev_stats[i] = self.actor:getStat(i)
	end

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
				color=function(item)
				return ((self.actor:knowTalentType(item.type) ~= self.actor_dup:knowTalentType(item.type)) or ((self.actor.__increased_talent_types[item.type] or 0) ~= (self.actor_dup.__increased_talent_types[item.type] or 0))) and {255, 215, 0} or self.actor:knowTalentType(item.type) and {0,200,0} or {175,175,175}
				end,
				shown = tshown,
				status = function(item) return self.actor:knowTalentType(item.type) and tstring{{"font", "bold"}, ((self.actor.__increased_talent_types[item.type] or 0) >=1) and {"color", 255, 215, 0} or {"color", 0x00, 0xFF, 0x00}, ("%.2f"):format(self.actor:getTalentTypeMastery(item.type)), {"font", "normal"}} or tstring{{"color",  0xFF, 0x00, 0x00}, "unknown"} end,
				nodes = {},
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
						name=((t.display_entity and t.display_entity:getDisplayString() or "")..t.name):toTString(),
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

					if t.require then
						local stats = {}
						if type(t.require) == "table" and t.require.stat then
							stats = t.require.stat
						elseif type(t.require) == "function" and t.require(self.actor,t).stat then
							stats = t.require(self.actor,t).stat
						end
						for stat, _ in pairs(stats) do
							self.talent_stats_req[stat] = self.talent_stats_req[stat] or {}
							self.talent_stats_req[stat][#self.talent_stats_req[stat] + 1] = { list[#list], t }
						end
					end
				end
			end
		end
	end
	self.tree = tree
end

function _M:regenerateList()
	local stats = { "str", "dex", "mag", "wil", "cun", "con" }
	local refreshed = {}
	for i = 1, 6 do
		local diff = self.actor:getStat(i) - self.prev_stats[i]
		if diff ~= 0 and self.talent_stats_req[stats[i]] then
			for j=1,#self.talent_stats_req[stats[i]] do
				if not refreshed[self.talent_stats_req[stats[i]][j]] then
					refreshed[self.talent_stats_req[stats[i]][j]] = true
					self.c_t_tree:drawItem(self.talent_stats_req[stats[i]][j][1])
				end
			end
		end
		self.prev_stats[i] = self.actor:getStat(i)
	end
end

function _M:mouseZones(t, no_new)
	-- Offset the x and y with the window position and window title
	if not t.norestrict then
		for i, z in ipairs(t) do
			if not z.norestrict then
				z.x = z.x + self.display_x + 5
				z.y = z.y + self.display_y + 20 + 3
			end
		end
	end

	if not no_new then self.mouse = engine.Mouse.new() end
	self.mouse:registerZones(t)
end

function _M:mouseTooltip(text, _, _, _, w, h, x, y)
	self:mouseZones({
		{ x=x, y=y + self.hoffset, w=w, h=h, fct=function(button) game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, text) end},
	}, true)
end

function _M:drawDialog(kind)
	self.mouse:reset()
	if game.tooltip then
		game.tooltip:erase()
	end

	if kind == "Stats" then
		self:resize(game.w * 0.9, math.min(game.h * 0.9, 500))

		self:loadUI{
			{left=0, top=self.stats.h, ui=self.vs},

			{left=15, top=0, ui=self.stats},
			{left=15+self.stats.w, top=0, ui=self.talents},
			{left=15+self.stats.w+self.talents.w, top=0, ui=self.summary},

			{left=0, top=self.stats.h + 10 + self.vs.h, ui=self.c_points},
			{left=5, top=self.stats.h + self.c_points.h + 10 + self.vs.h, ui=self.vs2},
			{left=0, top=self.stats.h + self.c_points.h + 20 + self.vs.h + self.vs2.h, ui=self.c_list},

			{hcenter=0, top=self.stats.h + 10 + self.vs.h, ui=Separator.new{dir="horizontal", size=self.ih - 15 - self.vs.h}},

			{right=0, top=self.stats.h + self.c_tut.h + 25 + self.vs.h, ui=self.c_desc},
			{right=0, top=self.stats.h + self.c_tut.h + 150 + self.vs.h, ui=self.c_desc2},

			{right=0, top=self.stats.h + 5 + self.vs.h, ui=self.c_tut},
		}
		self:setFocus(self.c_list)
		self.c_list:onSelect()

		self:setupUI()
		self:updateTitle("Stats Levelup: "..self.actor.name)
	elseif kind == "Talents" then
		self:resize(game.w * 0.9, game.h * 0.9)

		self:loadUI{
			{left=0, top=self.stats.h, ui=self.vs},

			{left=15, top=0, ui=self.stats},
			{left=15+self.stats.w, top=0, ui=self.talents},
			{left=15+self.stats.w+self.talents.w, top=0, ui=self.summary},

			{left=0, top=self.stats.h + self.vs.h, ui=self.c_t_points},
			{left=5, top=self.stats.h + self.c_t_points.h + 5 + self.vs.h, ui=self.vs2},
			{left=0, top=self.stats.h + self.c_t_points.h + 15 + self.vs.h + self.vs2.h, ui=self.c_t_tree},

			{hcenter=0, top=self.stats.h + 5 + self.vs.h, ui=Separator.new{dir="horizontal", size=self.ih - 15 - self.vs.h}},

			{right=0, top=self.stats.h + self.c_t_tut.h + 25 + self.vs.h, ui=self.c_t_desc},
			{right=0, top=self.stats.h + self.vs.h, ui=self.c_t_tut},
		}
		self:setFocus(self.c_t_tree)
		self:setupUI()
		self:updateTitle("Talents Levelup: "..self.actor.name)
	else
		self:resize(game.w * 0.9, math.min(game.h * 0.9, 400))
		self:loadUI{
			{left=0, top=self.stats.h, ui=self.vs},

			{left=15, top=0, ui=self.stats},
			{left=15+self.stats.w, top=0, ui=self.talents},
			{left=15+self.stats.w+self.talents.w, top=0, ui=self.summary},

			{left=0, top=self.stats.h + 5 + self.vs.h, ui=self.c_summary_desc},
		}

		self:setupUI()

		local s = self.c_summary_desc.s
		local h = 0
		local w = 0

		s:erase(0,0,0,0)

		local con_diff = self.actor:getCon() - self.actor_dup:getCon()
		local wil_diff = self.actor:getWil() - self.actor_dup:getWil()
		local mag_diff = self.actor:getMag() - self.actor_dup:getMag()
		local cun_diff = self.actor:getCun() - self.actor_dup:getCun()
		local str_diff = self.actor:getStr() - self.actor_dup:getStr()
		local dex_diff = self.actor:getDex() - self.actor_dup:getDex()

		s:drawColorStringBlended(self.font, ("#LIGHT_BLUE#Stats change:"):format(), w, h, 255, 255, 255, true) h = h + self.font_h
		s:drawColorStringBlended(self.font, ("Strength    : #00c000#%d"):format(str_diff), w, h, 255, 255, 255, true) h = h + self.font_h
		s:drawColorStringBlended(self.font, ("Dexterity   : #00c000#%d"):format(dex_diff), w, h, 255, 255, 255, true) h = h + self.font_h
		s:drawColorStringBlended(self.font, ("Magic       : #00c000#%d"):format(mag_diff), w, h, 255, 255, 255, true) h = h + self.font_h
		s:drawColorStringBlended(self.font, ("Willpower   : #00c000#%d"):format(wil_diff), w, h, 255, 255, 255, true) h = h + self.font_h
		s:drawColorStringBlended(self.font, ("Cunning     : #00c000#%d"):format(cun_diff), w, h, 255, 255, 255, true) h = h + self.font_h
		s:drawColorStringBlended(self.font, ("Constitution: #00c000#%d"):format(con_diff), w, h, 255, 255, 255, true) h = h + self.font_h
		h = h + self.font_h
		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Saves:", w, h, 255, 255, 255, true) h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_PHYS_SAVE, s:drawColorStringBlended(self.font,   ("Physical : #00c000#%.2f"):format(self.actor:combatPhysicalResist(true) - self.actor_dup:combatPhysicalResist(true)), w, h, 255, 255, 255, true)) h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_SPELL_SAVE, s:drawColorStringBlended(self.font,  ("Spell    : #00c000#%.2f"):format(self.actor:combatSpellResist(true) - self.actor_dup:combatSpellResist(true)), w, h, 255, 255, 255, true)) h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_MENTAL_SAVE, s:drawColorStringBlended(self.font, ("Mental   : #00c000#%.2f"):format(self.actor:combatMentalResist(true) - self.actor_dup:combatMentalResist(true)), w, h, 255, 255, 255, true)) h = h + self.font_h
		h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_RESIST_ALL, s:drawColorStringBlended(self.font, ("All resistance: #00c000#%.2f%%"):format((self.actor.resists.all or 0) - (self.actor_dup.resists.all or 0)), w, h, 255, 255, 255, true)) h = h + self.font_h

		for i, t in ipairs(DamageType.dam_def) do
			if self.actor.resists[DamageType[t.type]] and self.actor.resists[DamageType[t.type]] ~= 0 and self.actor.resists[DamageType[t.type]]~=self.actor_dup.resists[DamageType[t.type]] then
				self:mouseTooltip(self.TOOLTIP_RESIST, s:drawColorStringBlended(self.font, ("%s: #00ff00#%.1f%%"):format(t.name:capitalize(), self.actor:combatGetResist(DamageType[t.type]) - (self.actor_dup:combatGetResist(DamageType[t.type]) or 0)), w, h, 255, 255, 255, true)) h = h + self.font_h
			end
		end

		h = 0
		w = 200
		s:drawColorStringBlended(self.font, ("#LIGHT_BLUE#Stats effect:"):format(), w, h, 255, 255, 255, true) h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_LIFE, s:drawColorStringBlended(self.font, ("#c00000#Max life: #00ff00#%d"):format(self.actor.max_life - self.actor_dup.max_life), w, h, 255, 255, 255, true)) h = h + self.font_h
		h = h + self.font_h
		if self.actor:knowTalent(self.actor.T_MANA_POOL) then
			self:mouseTooltip(self.TOOLTIP_MANA,s:drawColorStringBlended(self.font, ("#7fffd4#Max mana :  #00ff00#%d"):format(self.actor.max_mana - self.actor_dup.max_mana), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		if self.actor:knowTalent(self.actor.T_STAMINA_POOL) then
			self:mouseTooltip(self.TOOLTIP_STAMINA, s:drawColorStringBlended(self.font, ("#ffcc80#Max stamina : #00ff00#%d"):format(self.actor.max_stamina - self.actor_dup.max_stamina), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		if self.actor:knowTalent(self.actor.T_PSI_POOL) then
			self:mouseTooltip(self.TOOLTIP_PSI, s:drawColorStringBlended(self.font, ("#7fffd4#Max PSI : #00ff00#%d"):format(self.actor.max_psi - self.actor_dup.max_psi), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_STR, s:drawColorStringBlended(self.font, ("Max encumberance: #00c000#%.1f"):format(self.actor:getMaxEncumbrance() - self.actor_dup:getMaxEncumbrance()), w, h, 255, 255, 255, true)) h = h + self.font_h
		if self.actor:knowTalent(self.actor.T_MANA_POOL) or self.actor:knowTalent(self.actor.T_POSITIVE_POOL) or self.actor:knowTalent(self.actor.T_NEGATIVE_POOL) or self.actor:knowTalent(self.actor.T_VIM_POOL) or self.actor:knowTalent(self.actor.T_PARADOX_POOL) then
			h = h + self.font_h
			s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Magical:", w, h, 255, 255, 255, true) h = h + self.font_h
			self:mouseTooltip(self.TOOLTIP_SPELL_POWER, s:drawColorStringBlended(self.font, ("Spellpower: #00c000#%d"):format(self.actor:combatSpellpower() - self.actor_dup:combatSpellpower()), w, h, 255, 255, 255, true)) h = h + self.font_h
			self:mouseTooltip(self.TOOLTIP_SPELL_CRIT, s:drawColorStringBlended(self.font, ("Crit. chance: #00c000#%.1f%%"):format(self.actor:combatSpellCrit() - self.actor_dup:combatSpellCrit()), w, h, 255, 255, 255, true)) h = h + self.font_h
			self:mouseTooltip(self.TOOLTIP_MINDPOWER, s:drawColorStringBlended(self.font, ("Mindpower: #00c000#%.1f"):format(self.actor:combatMindpower() - self.actor_dup:combatMindpower()), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		h = h + self.font_h
		local ArmorTxt = "#LIGHT_BLUE#"
		if self.actor:hasHeavyArmor() then
			ArmorTxt = ArmorTxt.."Heavy armor"
		elseif self.actor:hasMassiveArmor() then
			ArmorTxt = ArmorTxt.."Massive armor"
		else
			ArmorTxt = ArmorTxt.."Light armor"
		end

		ArmorTxt = ArmorTxt..":"

		s:drawColorStringBlended(self.font, ArmorTxt, w, h, 255, 255, 255, true) h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_ARMOR_HARDINESS, s:drawColorStringBlended(self.font, ("Armor hardiness: #00c000#%d%%"):format(self.actor:combatArmorHardiness() - self.actor_dup:combatArmorHardiness()), w, h, 255, 255, 255, true)) h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_ARMOR, s:drawColorStringBlended(self.font,           ("Armor          : #00c000#%d(%d)"):format(self.actor:combatArmor() - self.actor_dup:combatArmor(), self.actor:combatArmorHardiness() * (self.actor:combatArmor() - self.actor_dup:combatArmor()) * 0.01), w, h, 255, 255, 255, true)) h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_DEFENSE, s:drawColorStringBlended(self.font,         ("Defense        : #00c000#%d"):format(self.actor:combatDefense(true) - self.actor_dup:combatDefense(true)), w, h, 255, 255, 255, true)) h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_RDEFENSE, s:drawColorStringBlended(self.font,        ("Ranged defense : #00c000#%d"):format(self.actor:combatDefenseRanged(true) - self.actor_dup:combatDefenseRanged(true)), w, h, 255, 255, 255, true)) h = h + self.font_h
		h = 0
		w = 400
		local mainhand = self.actor:getInven(self.actor.INVEN_MAINHAND)
		if mainhand and (#mainhand > 0) then
			local WeaponTxt = "#LIGHT_BLUE#Main Hand"
			if self.actor:hasTwoHandedWeapon() then
				WeaponTxt = WeaponTxt.."(2-handed)"
			end
			WeaponTxt = WeaponTxt..":"

			for i, o in ipairs(self.actor:getInven(self.actor.INVEN_MAINHAND)) do
				local mean, dam = o.combat, o.combat
				if o.archery and mean then
					dam = (self.actor:getInven("QUIVER")[1] and self.actor:getInven("QUIVER")[1].combat)
				end
				if mean and dam then
					s:drawColorStringBlended(self.font, WeaponTxt, w, h, 255, 255, 255, true) h = h + self.font_h
					if self.actor.use_psi_combat then
						self:mouseTooltip(self.TOOLTIP_COMBAT_ATTACK, s:drawColorStringBlended(self.font, ("Accuracy(PSI): #00ff00#%.1f"):format(self.actor:combatAttack(mean) - self.actor_dup:combatAttack(mean)), w, h, 255, 255, 255, true)) h = h + self.font_h
					else
						self:mouseTooltip(self.TOOLTIP_COMBAT_ATTACK, s:drawColorStringBlended(self.font, ("Accuracy    : #00ff00#%.1f"):format(self.actor:combatAttack(mean) - self.actor_dup:combatAttack(mean)), w, h, 255, 255, 255, true)) h = h + self.font_h
					end
					self:mouseTooltip(self.TOOLTIP_COMBAT_DAMAGE, s:drawColorStringBlended(self.font, ("Damage      : #00ff00#%.1f"):format(self.actor:combatDamage(dam) - self.actor_dup:combatDamage(dam)), w, h, 255, 255, 255, true)) h = h + self.font_h
					self:mouseTooltip(self.TOOLTIP_COMBAT_APR, s:drawColorStringBlended(self.font,    ("APR         : #00ff00#%.1f"):format(self.actor:combatAPR(dam) - self.actor_dup:combatAPR(dam)), w, h, 255, 255, 255, true)) h = h + self.font_h
					self:mouseTooltip(self.TOOLTIP_COMBAT_CRIT, s:drawColorStringBlended(self.font,   ("Crit. chance: #00ff00#%.1f%%"):format(self.actor:combatCrit(dam) - self.actor_dup:combatCrit(dam)), w, h, 255, 255, 255, true)) h = h + self.font_h
					self:mouseTooltip(self.TOOLTIP_COMBAT_SPEED, s:drawColorStringBlended(self.font,  ("Speed       : #00ff00#%.2f%%"):format((self.actor:combatSpeed(mean) - self.actor_dup:combatSpeed(mean))*100), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
			end
		-- Handle bare-handed combat
		else
			s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Unarmed:", w, h, 255, 255, 255, true) h = h + self.font_h
			local mean = self.actor.combat
			if mean then
				if self.actor.use_psi_combat then
					self:mouseTooltip(self.TOOLTIP_COMBAT_ATTACK, s:drawColorStringBlended(self.font, ("Accuracy(PSI): #00ff00#%.1f"):format(self.actor:combatAttack(mean) - self.actor_dup:combatAttack(mean)), w, h, 255, 255, 255, true)) h = h + self.font_h
				else
					self:mouseTooltip(self.TOOLTIP_COMBAT_ATTACK, s:drawColorStringBlended(self.font, ("Accuracy    : #00ff00#%.1f"):format(self.actor:combatAttack(mean) - self.actor_dup:combatAttack(mean)), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
				self:mouseTooltip(self.TOOLTIP_COMBAT_DAMAGE, s:drawColorStringBlended(self.font, ("Damage      : #00ff00#%.1f"):format(self.actor:combatDamage(mean) - self.actor_dup:combatDamage(mean)), w, h, 255, 255, 255, true)) h = h + self.font_h
				self:mouseTooltip(self.TOOLTIP_COMBAT_APR, s:drawColorStringBlended(self.font,    ("APR         : #00ff00#%.1f"):format(self.actor:combatAPR(mean) - self.actor_dup:combatAPR(mean)), w, h, 255, 255, 255, true)) h = h + self.font_h
				self:mouseTooltip(self.TOOLTIP_COMBAT_CRIT, s:drawColorStringBlended(self.font,   ("Crit. chance: #00ff00#%.1f%%"):format(self.actor:combatCrit(mean) - self.actor_dup:combatCrit(mean)), w, h, 255, 255, 255, true)) h = h + self.font_h
				self:mouseTooltip(self.TOOLTIP_COMBAT_SPEED, s:drawColorStringBlended(self.font,  ("Speed       : #00ff00#%.2f%%"):format((self.actor:combatSpeed(mean) - self.actor_dup:combatSpeed(mean))*100), w, h, 255, 255, 255, true)) h = h + self.font_h
			end
		end
		h = h + self.font_h
		if self.actor:getInven(self.actor.INVEN_OFFHAND) then
			for i, o in ipairs(self.actor:getInven(self.actor.INVEN_OFFHAND)) do
				local act_offmult = self.actor:getOffHandMult(o.combat)
				local act_dup_offmult = self.actor_dup:getOffHandMult(o.combat)
				local mean, dam = o.combat, o.combat
				if o.archery and mean then
					dam = (self.actor:getInven("QUIVER")[1] and self.actor:getInven("QUIVER")[1].combat)
				end
				if mean and dam then
					s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Off Hand:", w, h, 255, 255, 255, true) h = h + self.font_h
					if self.actor.use_psi_combat then
						self:mouseTooltip(self.TOOLTIP_COMBAT_ATTACK, s:drawColorStringBlended(self.font, ("Accuracy(PSI): #00ff00#%.1f"):format(self.actor:combatAttack(mean) - self.actor_dup:combatAttack(mean)), w, h, 255, 255, 255, true)) h = h + self.font_h
					else
						self:mouseTooltip(self.TOOLTIP_COMBAT_ATTACK, s:drawColorStringBlended(self.font, ("Accuracy    : #00ff00#%.1f"):format(self.actor:combatAttack(mean) - self.actor_dup:combatAttack(mean)), w, h, 255, 255, 255, true)) h = h + self.font_h
					end
					self:mouseTooltip(self.TOOLTIP_COMBAT_DAMAGE, s:drawColorStringBlended(self.font, ("Damage      : #00ff00#%.1f"):format(self.actor:combatDamage(dam) * act_offmult - self.actor_dup:combatDamage(dam) * act_dup_offmult), w, h, 255, 255, 255, true)) h = h + self.font_h
					self:mouseTooltip(self.TOOLTIP_COMBAT_APR   , s:drawColorStringBlended(self.font, ("APR         : #00ff00#%.1f"):format(self.actor:combatAPR(dam) - self.actor_dup:combatAPR(dam)), w, h, 255, 255, 255, true)) h = h + self.font_h
					self:mouseTooltip(self.TOOLTIP_COMBAT_CRIT  , s:drawColorStringBlended(self.font, ("Crit. chance: #00ff00#%.1f%%"):format(self.actor:combatCrit(dam) - self.actor_dup:combatCrit(dam)), w, h, 255, 255, 255, true)) h = h + self.font_h
					self:mouseTooltip(self.TOOLTIP_COMBAT_SPEED , s:drawColorStringBlended(self.font, ("Speed       : #00ff00#%.2f%%"):format((self.actor:combatSpeed(mean) - self.actor_dup:combatSpeed(mean))*100), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
			end
		end
		h = 0
		w = 600
		s:drawColorStringBlended(self.font, ("#LIGHT_BLUE#Talents learned:"):format(), w, h, 255, 255, 255, true) h = h + self.font_h
		local stats = { "str", "dex", "mag", "wil", "cun", "con" }
		local talents_learned = {}

		for k, _ in pairs(self.talents_changed) do
			t = self.actor:getTalentFromId(k)
			if ((self.actor.talents[k] or 0) ~= (self.actor_dup.talents[k] or 0)) then
				talents_learned[k] = true
				local desc = "#GOLD##{bold}#"..t.name.."#{normal}##WHITE#\n"..tostring(self.actor:getTalentFullDescription(t))
				self:mouseTooltip(desc, s:drawColorStringBlended(self.font, ("#GOLD#%s"):format(t.name), w, h, 255, 255, 255, true)) h = h + self.font_h
			end
		end
		h = 0
		w = 800
		s:drawColorStringBlended(self.font, ("#LIGHT_BLUE#New available talents:"):format(), w, h, 255, 255, 255, true) h = h + self.font_h
		talents_added = {}
		for stat_id = 1,6 do
			if self.talent_stats_req[stats[stat_id]] then
				for j=1,#self.talent_stats_req[stats[stat_id]] do
					local t = self.actor:getTalentFromId(self.talent_stats_req[stats[stat_id]][j][1].talent)
					if self.actor:canLearnTalent(t) and not self.actor_dup:canLearnTalent(t) and self:getMaxTPoints(t) > self.actor:getTalentLevelRaw(t) and not talents_added[self.talent_stats_req[stats[stat_id]][j][1].talent] and not talents_learned[self.talent_stats_req[stats[stat_id]][j][1].talent] then
						talents_added[self.talent_stats_req[stats[stat_id]][j][1].talent] = true
						local desc = "#GOLD##{bold}#"..t.name.."#{normal}##WHITE#\n"..tostring(self.actor:getTalentFullDescription(t))
						self:mouseTooltip(desc, s:drawColorStringBlended(self.font, ("#GOLD#%s"):format(t.name), w, h, 255, 255, 255, true)) h = h + self.font_h
					end
				end
			end
		end

		self.c_summary_desc:generate()
		self.c_summary_desc.can_focus = true
		self:setFocus(self.c_summary_desc)

		self:updateTitle("Levelup summary: "..self.actor.name)
	end
	self:updateKeys(kind)
end
