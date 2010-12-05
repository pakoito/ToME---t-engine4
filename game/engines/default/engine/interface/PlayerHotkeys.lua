-- TE4 - T-Engine 4
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

--- Handles player hotkey interface
-- This provides methods to bind and manage hotkeys as well as using them<br/>
-- This interface is designed to work with the engine.HotkeysDisplay class to display current hotkeys to the player
module(..., package.seeall, class.make)

function _M:init(t)
	self.hotkey = {}
	self.hotkey_page = 1
end

function _M:sortHotkeys()
	print("[SORTING HOTKEYS]")

	local old = self.hotkey
	self.hotkey = {}

	if self.quickhotkeys then
		for known_t_id, i in pairs(self.quickhotkeys) do
			if self.talents[known_t_id] then
				print("[SORTING HOTKEYS] pairing",known_t_id,i)
				self.hotkey[i] = {"talent", known_t_id}
				-- Remove from old
				for z = 1, 36 do if old[z] and old[z][1] == "talent" and old[z][2] == known_t_id then old[z] = nil break end end
			end
		end
	end

	-- Readd all the rest
	for j = 1, 36 do
		if old[j] then
			for i = 1, 36 do if not self.hotkey[i] then
				self.hotkey[i] = old[j]
				print("[SORTING HOTKEYS] added back", old[j][2], i)
				break
			end end
		end
	end
	self.changed = true
end

--- Uses an hotkeyed talent
-- This requires the ActorTalents interface to use talents and a method player:playerUseItem(o, item, inven) to use inventory objects
function _M:activateHotkey(id)
	if self.hotkey[id] then
		self["hotkey"..self.hotkey[id][1]:capitalize()](self, self.hotkey[id][2])
	else
		Dialog:simplePopup("Hotkey not defined", "You may define a hotkey by pressing 'm' and following the instructions there.")
	end
end

--- Activates a hotkey with a type "talent"
function _M:hotkeyTalent(tid)
	self:useTalent(tid)
end

--- Activates a hotkey with a type "inventory"
function _M:hotkeyInventory(name)
	local o, item, inven = self:findInAllInventories(name)
	if not o then
		Dialog:simplePopup("Item not found", "You do not have any "..name..".")
	else
		self:playerUseItem(o, item, inven)
	end
end

--- Switch to previous hotkey page
function _M:prevHotkeyPage()
	self.hotkey_page = util.boundWrap(self.hotkey_page - 1, 1, 3)
	self.changed = true
end
--- Switch to next hotkey page
function _M:nextHotkeyPage()
	self.hotkey_page = util.boundWrap(self.hotkey_page + 1, 1, 3)
	self.changed = true
end
--- Switch to hotkey page
function _M:setHotkeyPage(v)
	self.hotkey_page = v
	self.changed = true
end

-- Autoadd talents to hotkeys
function _M:hotkeyAutoTalents()
	for tid, _ in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
		if t.mode == "activated" or t.mode == "sustained" then
			for i = 1, 36 do
				if not self.hotkey[i] then
					self.hotkey[i] = {"talent", tid}
					break
				end
			end
		end
	end
end
