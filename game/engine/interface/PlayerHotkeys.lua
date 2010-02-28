require "engine.class"
local Dialog = require "engine.Dialog"

--- Handles player hotkey interface
-- This provides methods to bind and manage hotkeys as well as using them<br/>
-- This interface is designed to work with the engine.HotkeysDisplay class to display current hotkeys to the player
module(..., package.seeall, class.make)

function _M:init(t)
	self.hotkey = {}
	self.hotkey_page = 1
end

--- Uses an hotkeyed talent
-- This requires the ActorTalents interface to use talents and a method player:playerUseItem(o, item) to use inventory objects
function _M:activateHotkey(id)
	if self.hotkey[id] then
		if self.hotkey[id][1] == "talent" then
			self:useTalent(self.hotkey[id][2])
		elseif self.hotkey[id][1] == "inventory" then
			local o, item = self:findInInventory(self:getInven("INVEN"), self.hotkey[id][2])
			if not o then
				Dialog:simplePopup("Item not found", "You do not have any "..self.hotkey[id][2]..".")
			else
				self:playerUseItem(o, item)
			end
		end
	else
		Dialog:simplePopup("Hotkey not defined", "You may define a hotkey by pressing 'm' and following the inscructions there.")
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
