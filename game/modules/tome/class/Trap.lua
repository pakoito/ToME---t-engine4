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
require "engine.Trap"
require "engine.interface.ActorProject"
require "engine.interface.ObjectIdentify"
local Faction = require "engine.Faction"

module(..., package.seeall, class.inherit(
	engine.Trap,
	engine.interface.ObjectIdentify,
	engine.interface.ActorProject
))

_M.projectile_class = "mod.class.Projectile"

function _M:init(t, no_default)
	self.faction = "enemies"
	engine.Trap.init(self, t, no_default)
	engine.interface.ObjectIdentify.init(self, t)
	engine.interface.ActorProject.init(self, t)
end

--- Gets the full name of the object
function _M:getName()
	local name = self.name
	if not self:isIdentified() and self:getUnidentifiedName() then name = self:getUnidentifiedName() end
	return name
end

--- Returns a tooltip for the trap
function _M:tooltip()
	if self:knownBy(game.player) then
		local res = tstring{{"uid", self.uid}, self:getName()}
		if self.is_store then res:add(true, {"font","italic"}, "<Store>", {"font","normal"}) end
		if config.settings.cheat then
			res:add(true, "UID: "..self.uid, true, "Detect: "..self.detect_power, true, "Disarm: "..self.disarm_power)
		end
		return res
	end
end

--- What is our reaction toward the target
-- See Faction:factionReaction()
function _M:reactionToward(target)
	return Faction:factionReaction(self.faction, target.faction)
end

--- Can we disarm this trap?
function _M:canDisarm(x, y, who)
	if not engine.Trap.canDisarm(self, x, y, who) then return false end

	-- do we know how to disarm?
	if (who:getTalentLevel(who.T_TRAP_HANDLING) >= 3) or who:attr("can_disarm") then
		local power = who:getTalentLevel(who.T_TRAP_HANDLING) * who:getCun(25, true) + (who:attr("disarm_bonus") or 0)
		if who:checkHit(power, self.disarm_power) and (not self.faction or who:reactionToward(self) < 0) then
			return true
		end
	end

	-- False by default
	return false
end

--- Called when disarmed
function _M:onDisarm(x, y, who)
	self:check("disarmed", x, y, who)
end

--- Called when triggered
function _M:canTrigger(x, y, who, no_random)
	if self.pressure_trap and who:attr("avoid_pressure_traps") then return false end
	if self.faction and who.reactionToward and who:reactionToward(self) >= 0 then return false end
	if not no_random and who.trap_avoidance and rng.percent(who.trap_avoidance) then
		if self:knownBy(who) then
			game.logPlayer(who, "You carefully avoid the trap (%s).", self:getName())
		end
		return false
	end
	return true
end

--- Trigger the trap
function _M:trigger(x, y, who)
	engine.Trap.trigger(self, x, y, who)

	if who.runStop then who:runStop("trap") end
end

function _M:resolveSource()
	if self.summoner_gain_exp and self.summoner then
		return self.summoner:resolveSource()
	else
		return self
	end
end

--- Identify the trap
function _M:identify(id)
	self.identified = id
end
