require "engine.class"
local Dialog = require "engine.Dialog"

--- Handles player resting
module(..., package.seeall, class.make)

--- Initializes resting
function _M:restInit()
	self.resting = {
		cnt = 1,
		dialog = Dialog:simplePopup("Resting...", "You are resting, press any key to stop.", function()
			self:restStop()
		end),
	}
	self:useEnergy()
	game.log("Resting starts...")
end

--- Rest a turn
-- For a turn based game you want in you player's act() something like that:<br/>
-- <pre>
-- if not self:restStep() then game.paused = true end
-- </pre>
-- @return true if we can continue to rest, false otherwise
function _M:restStep()
	if not self.resting then return false end

	if not self:restCheck() then
		self:restStop()
		return false
	else
		self:useEnergy()
		self.resting.cnt = self.resting.cnt + 1
		return true
	end
end

--- Can we continue resting ?
-- Rewrite this method to check for mana, life, whatever. By default we alawys return false so resting will never work
-- @return true if we can continue to rest, false otherwise
function _M:restCheck()
	return false
end

--- Stops resting
function _M:restStop()
	if not self.resting then return false end

	game:unregisterDialog(self.resting.dialog)

	game.log("Rested for %d turns.", self.resting.cnt)

	self.resting = nil
	return true
end
