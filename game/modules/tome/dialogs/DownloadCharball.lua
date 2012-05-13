-- ToME - Tales of Maj'Eyal
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
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"
local Image = require "engine.ui.Image"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "Download charball", game.w * 0.8, game.h * 0.8)

	self:generateList()

	self.c_list = ListColumns.new{width=math.floor(self.iw - 10), height=self.ih - 10, scrollbar=true, sortable=true, columns={
		{name="Player", width=30, display_prop="player", sort="player"},
		{name="Character", width=70, display_prop="character", sort="character"},
	}, list=self.list, fct=function(item) self:importCharball(item) end, select=function(item, sel) self:select(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
	}
	self:setFocus(self.c_list)
	self:setupUI()
	self:select(self.list[1])

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:generateList()
	profile.chat:selectChannel("tome")

	-- Makes up the list
	local list = {}
	for login, user in pairs(profile.chat.channels.tome.users) do
		if user.valid == "validate" and user.current_char_data and user.current_char_data.uuid then
			list[#list+1] = { player=user.name, character=user.current_char, id=user.id, uuid=user.current_char_data.uuid }
		end
	end
	-- Add known artifacts
	table.sort(list, function(a, b) return a.character < b.character end)
	self.list = list
end

function _M:select(item)
	if item then
	end
end

function _M:importCharball(item)
	if not item or not item.uuid then return end

	local data = profile:getCharball(item.id, item.uuid)
	local f = fs.open("/charballs/__import.charball", "w")
	f:write(data)
	f:close()

	savefile_pipe:ignoreSaveToken(true)
	local ep = savefile_pipe:doLoad("__import", "entity", "engine.CharacterBallSave", "__import")
	savefile_pipe:ignoreSaveToken(false)
	for a, _ in pairs(ep.members) do
		if a.__CLASSNAME == "mod.class.Player" then
			mod.class.NPC.castAs(a)
			engine.interface.ActorAI.init(a, a)
			a.quests = {}
			a.ai = "tactical"
			a.ai_state = {talent_in=1}
			a.no_drops = true
			a.energy.value = 0
			a.player = nil
			a.faction = "enemies"
			game.zone:addEntity(game.level, a, "actor", game.player.x, game.player.y-1)

			game:unregisterDialog(self)
		end
	end
end
