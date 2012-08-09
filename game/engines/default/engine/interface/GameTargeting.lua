-- TE4 - T-Engine 4
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
require "engine.KeyBind"
local Dialog = require "engine.ui.Dialog"
local Map = require "engine.Map"
local Target = require "engine.Target"

--- Handles default targeting interface & display
module(..., package.seeall, class.make)

--- Initializes targeting
function _M:init()
	self.target = Target.new(Map, self.player)
	self.target.target.entity = self.player
	self.old_tmx, self.old_tmy = 0, 0
	self.target_style = "lock"

	-- Allow scrolling when targetting
	self.target.on_set_target = function(self, how)
		if self.key ~= self.targetmode_key then return end
		local dx, dy = game.level.map:moveViewSurround(self.target.x, self.target.y, 1, 1, true)
		if how == "mouse" then
			local cx, cy = core.mouse.get()
			core.mouse.set(cx - game.level.map.tile_w * dx, cy - game.level.map.tile_h * dy)
		end
	end
end

--- Maintain the current target each tick
-- Make sure the target still exists
function _M:targetOnTick()
	if self.target.target.entity and not self.level:hasEntity(self.target.target.entity) then self.target.target.entity = false end
end

--- Display the tooltip, if any

function _M:targetDisplayTooltip(dx, dy, force, nb_keyframes)
	-- Tooltip is displayed over all else
	if self.level and self.level.map and self.level.map.finished then
		local tmx, tmy
		-- Display a tooltip if available
		if self.tooltip_x then
			if type(self.tooltip_x) == "table" then
				self.tooltip:toScreen(self.tooltip.last_display_x, self.tooltip.last_display_y, nb_keyframes)
			else
				tmx, tmy = self.level.map:getMouseTile(self.tooltip_x , self.tooltip_y)
				self.tooltip:displayAtMap(tmx, tmy, dx, dy, nil, force, nb_keyframes)
			end
		end

		-- Move target around
		if self.old_tmx ~= tmx or self.old_tmy ~= tmy then
			self.target.target.x, self.target.target.y = tmx, tmy
		end
		self.old_tmx, self.old_tmy = tmx, tmy
	end
end

--- Forces the tooltip to pop with the given text
function _M:tooltipDisplayAtMap(x, y, text, extra, force, nb_keyframes)
	self.tooltip:displayAtMap(nil, nil, x, y, text, force, nb_keyframes)
	if extra and type(extra) == "table" then
		if extra.up then self.tooltip.last_display_y = self.tooltip.last_display_y - self.tooltip.h end
	end
	self.tooltip_x = {}
end

--- Enter/leave targeting mode
-- This is the "meat" of this interface, do not expect to understand it easily, it mixes some nasty stuff
-- This require the Game to have both a "key" field (this is the default) and a "normal_key" field<br/>
-- It will switch over to a special keyhandler and then restore the "normal_key" one
function _M:targetMode(v, msg, co, typ)
	local old = self.target_mode
	self.target_mode = v

	if not v then
		Map:setViewerFaction(self.always_target == true and self.player.faction or nil)
		if msg then self.log(type(msg) == "string" and msg or "Tactical display disabled. Press shift+'t' to enable.") end
		self.level.map.changed = true
		self.target:setActive(false)

		if tostring(old) == "exclusive" then
			local fct = function(notok)
				if notok then
					self.target.target.entity = nil
					self.target.target.x = nil
					self.target.target.y = nil
				end

				self.key = self.normal_key
				self.key:setCurrent()
				if self.target_co then
					local co = self.target_co
					self.target_co = nil
					local ok, err = coroutine.resume(co, self.target.target.x, self.target.target.y, self.target.target.entity)
					if not ok and err then print(debug.traceback(co)) error(err) end
				end
			end
			if self.target_warning and self.target.target.x == self.player.x and self.target.target.y == self.player.y then
				Dialog:yesnoPopup(type(self.target_warning) == "string" and self.target_warning or "Target yourself?", "Are you sure you want to target yourself?", fct, "No", "Yes", nil, true)
			else
				fct(false)
			end
		end
	else
		Map:setViewerFaction(self.player.faction)
		if msg then self.log(type(msg) == "string" and msg or "Tactical display enabled. Press shift+'t' to disable.") end
		self.level.map.changed = true
		self.target:setActive(true, typ)
		self.target_style = "lock"
		self.target_warning = true
		if type(typ) == "table" and typ.talent then
			self.target_warning = typ.talent.name
		elseif type(typ) == "table" and typ.__name then
			self.target_warning = typ.__name
		end

		-- Exclusive mode means we disable the current key handler and use a specific one
		-- that only allows targetting and resumes talent coroutine when done
		if tostring(v) == "exclusive" then
			self.target_co = co
			self.key = self.targetmode_key
			self.key:setCurrent()

			local do_scan = true
			if self.target_no_star_scan
			   or (
			       self.target.target.entity and
			       self.level.map.seens(self.target.target.entity.x, self.target.target.entity.y) and
			       self.player ~= self.target.target.entity
			      ) then

				if type(typ) == "table" and typ.first_target ~= "friend" and self.player:reactionToward(self.target.target.entity) >= 0 then
				else
					do_scan = false
				end
			end
			if do_scan then
				local filter = nil
				if type(typ) == "table" and typ.first_target and typ.first_target == "friend" then
					filter = function(a) return self.player:reactionToward(a) >= 0 end
				else
					filter = function(a) return self.player:reactionToward(a) < 0 end
				end
				self.target:scan(5, nil, self.player.x, self.player.y, filter)
			end
		end
		if self.target.target.x then
			self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y)
		end
	end
end

--- This setups the default keybindings for targeting
function _M:targetSetupKey()
	self.targetmode_key = engine.KeyBind.new()
	self.targetmode_key:addCommands{ _SPACE=function() self:targetMode(false, false) self.tooltip_x, self.tooltip_y = nil, nil end, }
	self.targetmode_key:addBinds
	{
		TACTICAL_DISPLAY = function()
			self:targetMode(false, false)
			self.tooltip_x, self.tooltip_y = nil, nil
		end,
		ACCEPT = function()
			self:targetMode(false, false)
			self.tooltip_x, self.tooltip_y = nil, nil
		end,
		EXIT = function()
			self.target.target.entity = nil
			self.target.target.x = nil
			self.target.target.y = nil
			self:targetMode(false, false)
			self.tooltip_x, self.tooltip_y = nil, nil
		end,
		-- Targeting movement
		RUN_LEFT = function() self.target:freemove(4) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_RIGHT = function() self.target:freemove(6) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_UP = function() self.target:freemove(8) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_DOWN = function() self.target:freemove(2) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_LEFT_DOWN = function() self.target:freemove(1) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_RIGHT_DOWN = function() self.target:freemove(3) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_LEFT_UP = function() self.target:freemove(7) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		RUN_RIGHT_UP = function() self.target:freemove(9) self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,

		MOVE_LEFT = function() if self.target_style == "lock" then self.target:scan(4) elseif self.target_style == "immediate" then self.target:setDirFrom(4, self.target.target.entity or self.player) self.targetmode_key:triggerVirtual("ACCEPT") return else self.target:freemove(4) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_RIGHT = function() if self.target_style == "lock" then self.target:scan(6) elseif self.target_style == "immediate" then self.target:setDirFrom(6, self.target.target.entity or self.player) self.targetmode_key:triggerVirtual("ACCEPT") return else self.target:freemove(6) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_UP = function() if self.target_style == "lock" then self.target:scan(8) elseif self.target_style == "immediate" then self.target:setDirFrom(8, self.target.target.entity or self.player) self.targetmode_key:triggerVirtual("ACCEPT") return else self.target:freemove(8) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_DOWN = function() if self.target_style == "lock" then self.target:scan(2) elseif self.target_style == "immediate" then self.target:setDirFrom(2, self.target.target.entity or self.player) self.targetmode_key:triggerVirtual("ACCEPT") return else self.target:freemove(2) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_LEFT_DOWN = function() if self.target_style == "lock" then self.target:scan(1) elseif self.target_style == "immediate" then self.target:setDirFrom(1, self.target.target.entity or self.player) self.targetmode_key:triggerVirtual("ACCEPT") return else self.target:freemove(1) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_RIGHT_DOWN = function() if self.target_style == "lock" then self.target:scan(3) elseif self.target_style == "immediate" then self.target:setDirFrom(3, self.target.target.entity or self.player) self.targetmode_key:triggerVirtual("ACCEPT") return else self.target:freemove(3) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_LEFT_UP = function() if self.target_style == "lock" then self.target:scan(7) elseif self.target_style == "immediate" then self.target:setDirFrom(7, self.target.target.entity or self.player) self.targetmode_key:triggerVirtual("ACCEPT") return else self.target:freemove(7) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_RIGHT_UP = function() if self.target_style == "lock" then self.target:scan(9) elseif self.target_style == "immediate" then self.target:setDirFrom(9, self.target.target.entity or self.player) self.targetmode_key:triggerVirtual("ACCEPT") return else self.target:freemove(9) end self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y) end,
		MOVE_STAY = function()
			self.target:setSpot(self.target.source_actor.x, self.target.source_actor.y, "freemove")
			self.tooltip_x, self.tooltip_y = self.level.map:getTileToScreen(self.target.target.x, self.target.target.y)
		end,
		SCREENSHOT = function() self.normal_key:triggerVirtual("SCREENSHOT") end,
	}
end

--- Handle mouse event for targeting
-- @return true if the event was handled
function _M:targetMouse(button, mx, my, xrel, yrel, event)
	if not self.level then return end

	-- Move tooltip
	self.tooltip_x, self.tooltip_y = mx, my
	local tmx, tmy = self.level.map:getMouseTile(mx, my)
	self.target:setSpot(tmx, tmy, "mouse")
	if self.key == self.targetmode_key then
		-- Target with mouse
		if button == "none" and xrel and yrel and event == "motion" then
			self.target:setSpotInMotion(tmx, tmy, "mouse")
		-- Accept target
		elseif button == "left" and not xrel and not yrel and event == "button" then
			self:targetMode(false, false)
			self.tooltip_x, self.tooltip_y = nil, nil
		-- Cancel target
		elseif not xrel and not yrel and event == "button" then
			self.target.target.entity = nil
			self.target.target.x = nil
			self.target.target.y = nil
			self:targetMode(false, false)
			self.tooltip_x, self.tooltip_y = nil, nil
		end
		return true
	end
end

--- Player requests a target
-- This method should be called by your Player:getTarget() method, it will handle everything
-- @param typ the targeting parameters
function _M:targetGetForPlayer(typ)
	if self.target.forced then return unpack(self.target.forced) end
	if coroutine.running() and typ then
		local msg
		self.target_no_star_scan = nil
		if type(typ) == "string" then msg, typ = typ, nil
		elseif type(typ) == "table" then
			if typ.default_target then
				self.target.target.entity = typ.default_target
				self.target_no_star_scan = true
			end
			msg = typ.msg
		end
		self:targetMode("exclusive", msg, coroutine.running(), typ)
		if typ.immediate_keys then self.target_style = "immediate" end
		if typ.nolock then self.target_style = "free" end
		if typ.nowarning then self.target_warning = false end
		return coroutine.yield()
	end
	return self.target.target.x, self.target.target.y, self.target.target.entity
end

--- Player wants to set its target
-- This method should be called by your Player:setTarget() method, it will handle everything
function _M:targetSetForPlayer(target)
	self.target.target.entity = target
	self.target.target.x = (type(target) == "table" and target.x) or nil
	self.target.target.y = (type(target) == "table" and target.y) or nil
end
