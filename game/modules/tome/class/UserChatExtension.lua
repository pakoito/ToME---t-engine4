-- TE4 - T-Engine 4
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
local Dialog = require "engine.ui.Dialog"

--- Module that handles multiplayer chats extensions, automatically loaded by engine.UserChat if found
module(..., package.seeall, class.make)

function _M:init(chat)
	self.chat = chat
	chat:enableShadow(0.6)
end

function _M:sendObjectLink(o)
	local name = o:getName{do_color=true}:removeUIDCodes()
	local desc = tostring(o:getDesc(nil, nil, true)):removeUIDCodes()
	local ser = zlib.compress(table.serialize{kind="object-link", name=name, desc=desc})
	core.profile.pushOrder(string.format("o='ChatSerialData' channel=%q msg=%q", self.chat.cur_channel, ser))
end

function _M:sendActorLink(m)
	if m == game:getPlayer(true) then
		world:gainAchievement("SELF_CENTERED", game.player)
	end

	local rank, rank_color = m:TextRank()
	local name = rank_color..m.name:removeUIDCodes().."#LAST#"
	local desc = tostring(m:tooltip(m.x, m.y, game.player) or "???"):removeUIDCodes()
	if not desc then return end
	local ser = zlib.compress(table.serialize{kind="actor-link", name=name, desc=desc})
	core.profile.pushOrder(string.format("o='ChatSerialData' channel=%q msg=%q", self.chat.cur_channel, ser))
end

function _M:sendKillerLink(msg, src)
	local desc = nil
	if src.tooltip then desc = tostring(src:tooltip(src.x, src.y, game.player) or "???"):removeUIDCodes() end
	local ser = zlib.compress(table.serialize{kind="killer-link", msg=msg, desc=desc})
	core.profile.pushOrder(string.format("o='ChatSerialData' channel=%q msg=%q", self.chat.cur_channel, ser))
end

-- Receive a custom event
function _M:event(e)
	if e.se == "SerialData" then
		local data = zlib.decompress(e.msg)
		if not data then return end
		data = data:unserialize()
		if not data then return end

		local color = colors.WHITE
		if e.status == 'dev' then color = colors.CRIMSON
		elseif e.status == 'mod' then color = colors.GOLD
		elseif e.donator == "oneshot" then color = colors.LIGHT_GREEN
		elseif e.donator == "recurring" then color = colors.ROYAL_BLUE end

		if data.kind == "object-link" then
			self.chat:addMessage("link", e.channel, e.login, {e.name, color}, "#ANTIQUE_WHITE#has linked an item: #WHITE# "..data.name, {mode="tooltip", tooltip=data.desc})
		elseif data.kind == "actor-link" then
			self.chat:addMessage("link", e.channel, e.login, {e.name, color}, "#ANTIQUE_WHITE#has linked a creature: #WHITE# "..data.name, {mode="tooltip", tooltip=data.desc})
		elseif data.kind == "killer-link" then
			self.chat:addMessage("death", e.channel, e.login, {e.name, color}, "#CRIMSON#"..data.msg.."#WHITE#", data.desc and {mode="tooltip", tooltip=data.desc} or nil)
		elseif data.kind == "donator-update" and data.donated > 0 then
			if data.donated <= 5 then world:gainAchievement("BRONZE_DONATOR", game:getPlayer(true))
			elseif data.donated <= 15 then world:gainAchievement("SILVER_DONATOR", game:getPlayer(true))
			elseif data.donated <= 30 then world:gainAchievement("GOLD_DONATOR", game:getPlayer(true))
			elseif data.donated <= 60 then world:gainAchievement("STRALITE_DONATOR", game:getPlayer(true))
			else world:gainAchievement("VORATUN_DONATOR", game:getPlayer(true))
			end

			local text = ([[#{bold}#Thank you#{normal}# for you donation, your support means a lot for the continued survival of this game.

Your current donation total is #LIGHT_GREEN#%0.2f euro#WHITE#.
Your Item's Vault has #TEAL#%d slots#WHITE#.

Again, thank you, and enjoy Eyal!

#{italic}#Your malevolent local god of darkness, #GOLD#DarkGod#{normal}#]]):format(data.donated, data.items_vault_slots)
			Dialog:simpleLongPopup("Thank you", text, 600)
		end
	end
end
