-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
require "engine.ui.Dialog"
local List = require "engine.ui.List"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(engine.ui.Dialog))

function _M:init(mx, my, tmx, tmy)
	self.tmx, self.tmy = util.bound(tmx, 0, game.level.map.w - 1), util.bound(tmy, 0, game.level.map.h - 1)
	if tmx == game.player.x and tmy == game.player.y then self.on_player = true end

	self:generateList()
	self.__showup = false

	local name = "Actions"
	local w = self.font_bold:size(name)
	engine.ui.Dialog.init(self, name, 1, 100, mx, my)

	local list = List.new{width=math.max(w, self.max) + 10, nb_items=#self.list, list=self.list, fct=function(item) self:use(item) end}

	self:loadUI{
		{left=0, top=0, ui=list},
	}

	self:setupUI(true, true, function(w, h)
		self.force_x = mx - w / 2
		self.force_y = my - (self.h - self.ih + list.fh / 3)
	end)

	self.mouse:reset()
	self.mouse:registerZone(0, 0, game.w, game.h, function(button, x, y, xrel, yrel, bx, by, event) if (button == "left" or button == "right") and event == "button" then self.key:triggerVirtual("EXIT") end end)
	self.mouse:registerZone(self.display_x, self.display_y, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event) if button == "right" and event == "button" then self.key:triggerVirtual("EXIT") else self:mouseEvent(button, x, y, xrel, yrel, bx, by, event) end end)
	self.key:addBinds{ EXIT = function() game:unregisterDialog(self) end, }
end

function _M:use(item)
	if not item then return end
	game:unregisterDialog(self)

	local act = item.action

	if act == "move_to" then game.player:mouseMove(self.tmx, self.tmy)
	elseif act == "change_level" then game.key:triggerVirtual("CHANGE_LEVEL")
	elseif act == "talent" then
		local d = item
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
	if g and not self.on_player then list[#list+1] = {name="Move to", action="move_to", color=colors.simple(colors.ANTIQUE_WHITE)} end

	-- Talents
	if game.zone and not game.zone.wilderness then
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
