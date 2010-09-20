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
require "engine.Dialog"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(mx, my, tmx, tmy)
	self.tmx, self.tmy = util.bound(tmx, 0, game.level.map.w - 1), util.bound(tmy, 0, game.level.map.h - 1)
	if tmx == game.player.x and tmy == game.player.y then self.on_player = true end

	self.font = core.display.newFont("/data/font/Vera.ttf", 12)
	self:generateList()
	self.__showup = false

	mx = mx - (self.max + 20) / 2
	my = my - 30

	engine.Dialog.init(self, "Actions", self.max + 20, self.maxh + 10 + 25, mx, my, nil, self.font)

	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 45) / self.font_h) - 1

	self:keyCommands(nil, {
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		ACCEPT = function() self:use() end,
		EXIT = function() game:unregisterDialog(self) end,
	})
	self:mouseZones{
		{ x=0, y=0, w=game.w, h=game.h, mode={button=true}, norestrict=true, fct=function(button) if button ~= "none" then game:unregisterDialog(self) end end},
		{ x=0, y=0, w=350, h=self.ih, fct=function(button, x, y, xrel, yrel, tx, ty, event)
			self.changed = true
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" and event == "button" then self:use()
			end
		end },
	}
end

function _M:use()
	if not self.list[self.sel] then return end
	game:unregisterDialog(self)

	local act = self.list[self.sel].action

	if act == "move_to" then game.player:mouseMove(self.tmx, self.tmy)
	elseif act == "change_level" then game.key:triggerVirtual("CHANGE_LEVEL")
	elseif act == "pickup" then game.key:triggerVirtual("PICKUP_FLOOR")
	elseif act == "character_sheet" then game.key:triggerVirtual("SHOW_CHARACTER_SHEET")
	elseif act == "quests" then game.key:triggerVirtual("SHOW_QUESTS")
	elseif act == "levelup" then game.key:triggerVirtual("LEVELUP")
	elseif act == "inventory" then game.key:triggerVirtual("SHOW_INVENTORY")
	elseif act == "rest" then game.key:triggerVirtual("REST")
	elseif act == "talent" then
		local d = self.list[self.sel]
		if d.set_target then
			local a = game.level.map(self.tmx, self.tmy, Map.ACTOR)
			if not a then a = {x=self.tmx, y=self.tmy, __no_self=true} end
			game.player:useTalent(d.talent.id, nil, nil, nil, a)
		else
			game.player:useTalent(d.talent.id)
		end
	end
end

function _M:generateList()
	local list = {}
	local player = game.player

	local g = game.level.map(self.tmx, self.tmy, Map.TERRAIN)
	local t = game.level.map(self.tmx, self.tmy, Map.TRAP)
	local o = game.level.map(self.tmx, self.tmy, Map.OBJECT)
	local a = game.level.map(self.tmx, self.tmy, Map.ACTOR)

	-- Generic actions
	if g and g.change_level and self.on_player then list[#list+1] = {name="Change level", action="change_level", color=colors.simple(colors.VIOLET)} end
	if o and self.on_player then list[#list+1] = {name="Pickup item", action="pickup", color=colors.simple(colors.ANTIQUE_WHITE)} end
	if g and not self.on_player then list[#list+1] = {name="Move to", action="move_to", color=colors.simple(colors.ANTIQUE_WHITE)} end
	if self.on_player then list[#list+1] = {name="Rest a while", action="rest", color=colors.simple(colors.ANTIQUE_WHITE)} end
	if self.on_player then list[#list+1] = {name="Inventory", action="inventory", color=colors.simple(colors.ANTIQUE_WHITE)} end
	if self.on_player then list[#list+1] = {name="Character Sheet", action="character_sheet", color=colors.simple(colors.ANTIQUE_WHITE)} end
	if self.on_player then list[#list+1] = {name="Quest Log", action="quests", color=colors.simple(colors.ANTIQUE_WHITE)} end
	if self.on_player and (player.unused_stats > 0 or player.unused_talents > 0 or player.unused_generics > 0 or player.unused_talents_types > 0) then list[#list+1] = {name="Levelup!", action="levelup", color=colors.simple(colors.YELLOW)} end

	-- Talents
	if self.zone and not self.zone.wilderness then
	       local tals = {}
		for tid, _ in pairs(player.talents) do
			local t = player:getTalentFromId(tid)
			if t.mode ~= "passive" and player:preUseTalent(t, true, true) and not player:isTalentCoolingDown(t) then
				local rt = util.getval(t.requires_target, player, t)
				if self.on_player and not rt then
					tals[#tals+1] = {name=t.name, talent=t, action="talent", color=colors.simple(colors.GOLD)}
				elseif not self.on_player and rt then
					tals[#tals+1] = {name=t.name, talent=t, action="talent", set_target=true, color=colors.simple(colors.GOLD)}
				end
			end
		end
		table.sort(tals, function(a, b)
			local ha, hb
			for i = 1, 36 do if player.hotkey[i] and player.hotkey[i][1] == "talent" and player.hotkey[i][2] == a.talent.id then ha = i end end
			for i = 1, 36 do if player.hotkey[i] and player.hotkey[i][1] == "talent" and player.hotkey[i][2] == b.talent.id then hb = i end end

			if ha and hb then return ha < hb
			elseif ha and not hb then return ha < 999999
			elseif hb and not ha then return hb > 999999
			else return a.talent.name < b.talent.name
			end
		end)
		for i = 1, #tals do list[#list+1] = tals[i] end
	end

	self.max = 0
	self.maxh = 0
	for i, v in ipairs(list) do
		local w, h = self.font:size(v.name)
		self.max = math.max(self.max, w)
		self.maxh = self.maxh + h
	end

	self.list = list
end

function _M:drawDialog(s)
	if #self.list == 0 then game:unregisterDialog(self) return end

	local h = 2
	self:drawSelectionList(s, 2, h, self.font_h, self.list, self.sel, "name")
	self.changed = false
end
