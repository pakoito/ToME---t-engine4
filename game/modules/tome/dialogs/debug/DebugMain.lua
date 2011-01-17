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
require "engine.ui.Dialog"
local List = require "engine.ui.List"
local GetQuantity = require "engine.dialogs.GetQuantity"

module(..., package.seeall, class.inherit(engine.ui.Dialog))

function _M:init()
	self:generateList()
	engine.ui.Dialog.init(self, "Debug/Cheat! It's BADDDD!", 1, 1)

	local list = List.new{width=400, height=500, list=self.list, fct=function(item) self:use(item) end}

	self:loadUI{
		{left=0, top=0, ui=list},
	}
	self:setupUI(true, true)

	self.key:addCommands{ __TEXTINPUT = function(c) if self.list and self.list.chars[c] then self:use(self.list[self.list.chars[c]]) end end}
	self.key:addBinds{ EXIT = function() game:unregisterDialog(self) end, }
end

function _M:use(item)
	if not item then return end
	game:unregisterDialog(self)

	if item.dialog then
		local d = require("mod.dialogs.debug."..item.dialog).new()
		game:registerDialog(d)
		return
	end

	local act = item.action

	local stop = false
	if act == "godmode" then
		game.player:forceLevelup(50)
		game.player.invulnerable = 1
		game.player.esp.all = 1
		game.player.esp.range = 50
		game.player.no_breath = 1
		game.player.invulnerable = 1
		game.player.money = 500
		game.player.esp.all = 1
		game.player.esp.range = 50
		game.player.auto_id = 100
		game.player.inc_damage.all = 100000
		game.player:incStat("str", 100) game.player:incStat("dex", 100) game.player:incStat("mag", 100) game.player:incStat("wil", 100) game.player:incStat("cun", 100) game.player:incStat("con", 100)
	elseif act == "all_arts" then
		for i, e in ipairs(game.zone.object_list) do
			if e.unique and e.define_as ~= "VOICE_SARUMAN" and e.define_as ~= "ORB_MANY_WAYS_DEMON" then
				local a = game.zone:finishEntity(game.level, "object", e)
				a.no_unique_lore = true -- to not spam
				a:identify(true)
				if a.name == a.unided_name then print("=================", a.name) end
				game.zone:addEntity(game.level, a, "object", game.player.x, game.player.y)
			end
		end
	elseif act == "magic_map" then
		game.level.map:liteAll(0, 0, game.level.map.w, game.level.map.h)
		game.level.map:rememberAll(0, 0, game.level.map.w, game.level.map.h)
	elseif act == "change_level" then
		game:registerDialog(GetQuantity.new("Zone: "..game.zone.name, "Level 1-"..game.zone.max_level, game.level.level, game.zone.max_level, function(qty)
			game:changeLevel(qty)
		end), 1)
	end
end

function _M:generateList()
	local list = {}

	list[#list+1] = {name="Change Zone", dialog="ChangeZone"}
	list[#list+1] = {name="Change Level", action="change_level"}
	list[#list+1] = {name="Reveal all map", action="magic_map"}
	list[#list+1] = {name="Godmode", action="godmode"}
	list[#list+1] = {name="Create all artifacts", action="all_arts"}
	list[#list+1] = {name="Grant/Alter Quests", dialog="GrantQuest"}
	list[#list+1] = {name="Summon Creature", dialog="SummonCreature"}
	list[#list+1] = {name="Create Item", dialog="CreateItem"}

	local chars = {}
	for i, v in ipairs(list) do
		v.name = self:makeKeyChar(i)..") "..v.name
		chars[self:makeKeyChar(i)] = i
	end
	list.chars = chars

	self.list = list
end
