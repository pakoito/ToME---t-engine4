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

--- Handles player hotkey interface
-- This provides methods to bind and manage hotkeys as well as using them<br/>
-- This interface is designed to work with the engine.HotkeysDisplay class to display current hotkeys to the player
module(..., package.seeall, class.make)

_M.quickhotkeys = {}
_M.quickhotkeys_specifics = {}

_M.nb_hotkey_pages = 5

function _M:init(t)
	self.hotkey = self.hotkey or {}
	self.hotkey_page = self.hotkey_page or 1
end

function _M:sortHotkeys()
	print("[SORTING HOTKEYS] actor = " .. ("%q"):format(self.name))

	local old = self.hotkey
	self.hotkeys_sorted = true -- It's only important that we attempted to sort the hotkeys.

	local quickhotkeys_type_table
	if self == game:getPlayer(true) then
		quickhotkeys_type_table = self:get_qhk_hotkeys(_M.quickhotkeys["Player: Specific"])
		if not quickhotkeys_type_table then
			quickhotkeys_type_table = _M.quickhotkeys["Player: Global"]
		end
	else
		quickhotkeys_type_table = self:get_qhk_hotkeys(_M.quickhotkeys[self.name])
	end
	if not quickhotkeys_type_table then return end

	self.hotkey = {}

	local sorted = {}
	local function sort_hotkeys(arg)
		if arg then
			for hotkey_type, hotkey_position_table in pairs(arg) do
				sorted[hotkey_type] = sorted[hotkey_type] or {}
				for hotkey_name, position in pairs(hotkey_position_table) do
					local success = false

					if not self.hotkey[position] then
						if hotkey_type == "talent" and self.talents[hotkey_name] then success = true
						elseif hotkey_type == "inventory" and self:findInAllInventories(hotkey_name) then success = true
						end
					end

					if success and not sorted[hotkey_type][hotkey_name] then
						print("[SORTING HOTKEYS]" .. " actor = " .. ("%q"):format(self.name) .. " - pairing",hotkey_name,i)
						self.hotkey[position] = {hotkey_type, hotkey_name}
						sorted[hotkey_type][hotkey_name] = true

						-- Remove from old
						for z = 1, 12 * self.nb_hotkey_pages do if old[z] and old[z][1] == hotkey_type and old[z][2] == hotkey_name then old[z] = nil break end end
					end
				end
			end
		end
	end

	sort_hotkeys(quickhotkeys_type_table)

	-- Even if we have a "Player: Specific" entry for the player, make sure to
	-- check "Player: Global" for any hotkeys the player might want sorted.
	if self == game:getPlayer(true) then sort_hotkeys(_M.quickhotkeys["Player: Global"]) end

	-- Read all the rest
	for j = 1, 12 * self.nb_hotkey_pages do
		if old[j] then
			for i = 1, 12 * self.nb_hotkey_pages do if not self.hotkey[i] then
				self.hotkey[i] = old[j]
				print("[SORTING HOTKEYS]" .. " actor = " .. ("%q"):format(self.name) .. " - added back", old[j][2], i)
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

--- Check if something is bound, and return the spot if it is
function _M:isHotkeyBound(kind, id)
	for position, hotkey_info in pairs(self.hotkey) do 
		if hotkey_info[1] == kind and hotkey_info[2] == id then return position end
	end
end

--- Switch to previous hotkey page
function _M:prevHotkeyPage()
	self.hotkey_page = util.boundWrap(self.hotkey_page - 1, 1, self.nb_hotkey_pages)
	self.changed = true
end
--- Switch to next hotkey page
function _M:nextHotkeyPage()
	self.hotkey_page = util.boundWrap(self.hotkey_page + 1, 1, self.nb_hotkey_pages)
	self.changed = true
end
--- Switch to hotkey page
function _M:setHotkeyPage(v)
	self.hotkey_page = v
	self.changed = true
end

-- Auto-add talents to hotkeys
function _M:hotkeyAutoTalents()
	local already_hotkeyed = {}

	-- Ensure we don't have endless duplicates of hotkeys on the bar
	for position, hotkey_info in pairs(self.hotkey) do if hotkey_info[1] == "talent" then already_hotkeyed[hotkey_info[2]] = true end end

	for tid, _ in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
		if (t.mode == "activated" or t.mode == "sustained") and not already_hotkeyed[tid] and not t.ignored_by_hotkeyautotalents then
			for i = 1, 12 * self.nb_hotkey_pages do
				if not self.hotkey[i] then
					self.hotkey[i] = {"talent", tid}
					break
				end
			end
		end
	end
end

-- TODO: Replace this with loading quickhotkeys from the profile.
function _M:loadQuickHotkeys(module_short_name, file)
	local f = loadfile(file)

	print("[QUICK HOTKEYS] Loading quick hotkey settings for module " .. ("%q"):format(module_short_name) .. " from " .. file .. "...")
	if f then
		setfenv(f, _M)
		if pcall(f) then
			print("[QUICK HOTKEYS] Successfully loaded quick hotkey settings.")
			return true
		end
	end

	print("[QUICK HOTKEYS] Failed to load quick hotkey settings.")
	return false
end

function _M:get_qhk_hotkeys(src, hotkey_type)
	local ret = src

	if ret and (not hotkey_type or (hotkey_type and not ret[hotkey_type])) then for i, f in ipairs(_M.quickhotkeys_specifics) do ret = ret[f(self)] if not ret then break end end end

	if ret then if hotkey_type then return ret[hotkey_type] else return ret end end
end

function _M:findQuickHotkey(owner, hotkey_type, hotkey)
	if _M.quickhotkeys[owner] then
		local hotkey_table = self:get_qhk_hotkeys(_M.quickhotkeys[owner], hotkey_type)

		if hotkey_table then return hotkey_table[hotkey] end
	end
end

function _M:updateQuickHotkey(actor, hotkey_position)
	local hotkey = actor and (actor.hotkey and actor.hotkey[hotkey_position] or nil) or nil

	if hotkey then
		local is_main_player = (actor == game:getPlayer(true))

		local ownerString = is_main_player and "Player: Specific" or actor.name
		_M.quickhotkeys[ownerString] = _M.quickhotkeys[ownerString] or {}

		_M.quickhotkeys["Player: Global"] = _M.quickhotkeys["Player: Global"] or {}
		local qhk_global = _M.quickhotkeys["Player: Global"]

		local qhk_current = _M.quickhotkeys[ownerString]
		for i, f in ipairs(_M.quickhotkeys_specifics) do
			local key = f(actor)
			qhk_current[key] = qhk_current[key] or {}
			qhk_current = qhk_current[key]
		end

		qhk_current[hotkey[1]] = qhk_current[hotkey[1]] or {}
		qhk_current[hotkey[1]][hotkey[2]] = hotkey_position

		-- Only save global hotkeys for the main character.
		if is_main_player then
			qhk_global[hotkey[1]] = qhk_global[hotkey[1]] or {}
			qhk_global[hotkey[1]][hotkey[2]] = hotkey_position
		end
	end
end

function _M:updateQuickHotkeys(actor)
	-- Make sure the actor's hotkeys have been sorted at least once so we
	-- don't overwrite the player's preferred hotkey order with defaults.
	if actor.hotkeys_sorted then
		if actor == game:getPlayer(true) or actor.save_hotkeys then
			for position, hotkey in pairs(actor.hotkey) do
				local save_quickhotkey = false

				if hotkey[1] == "talent" then
					save_quickhotkey = true
				elseif hotkey[1] == "inventory" then
					local item = actor:findInAllInventories(hotkey[2])

					if item and item.save_hotkey then save_quickhotkey = true end
				end

				if save_quickhotkey then self:updateQuickHotkey(actor, position) end
			end
		end
	end
end

local page_to_hotkey = {"", "SECOND_", "THIRD_", "FOURTH_", "FIFTH_"}

function _M:bindAllHotkeys(key, fct)
	for page = 1, self.nb_hotkey_pages do for x = 1, 12 do
		local i = x + (page - 1) * 12
		local k = "HOTKEY_"..page_to_hotkey[page]..x
		key:addBind(k, function() fct(i) end)
	end end
end
