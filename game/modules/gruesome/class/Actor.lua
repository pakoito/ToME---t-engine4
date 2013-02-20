-- ToME - Tales of Middle-Earth
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
require "engine.Actor"
require "engine.Autolevel"
require "engine.interface.ActorTemporaryEffects"
require "engine.interface.ActorLife"
require "engine.interface.ActorProject"
require "engine.interface.ActorTalents"
require "engine.interface.ActorResource"
require "engine.interface.ActorFOV"
require "mod.class.interface.Combat"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(
	engine.Actor,
	engine.interface.ActorTemporaryEffects,
	engine.interface.ActorLife,
	engine.interface.ActorProject,
	engine.interface.ActorTalents,
	engine.interface.ActorResource,
	engine.interface.ActorFOV,
	mod.class.interface.Combat
))

function _M:init(t, no_default)
	-- Default regen
	t.max_shadow = 2
	t.max_lurk = 2

	engine.Actor.init(self, t, no_default)
	engine.interface.ActorTemporaryEffects.init(self, t)
	engine.interface.ActorLife.init(self, t)
	engine.interface.ActorProject.init(self, t)
	engine.interface.ActorTalents.init(self, t)
	engine.interface.ActorResource.init(self, t)
	engine.interface.ActorFOV.init(self, t)

	self:incShadow(1000)
	self:incLurk(1000)
end

function _M:act()
	if not engine.Actor.act(self) then return end

	self.changed = true

	-- Cooldown talents
	self:cooldownTalents()
	-- Regen resources
	self:regenLife()
	self:regenResources()
	-- Compute timed effects
	self:timedEffects()

	-- Still enough energy to act ?
	if self.energy.value < game.energy_to_act then return false end

	return true
end

function _M:move(x, y, force)
	local moved = false
	if force or self:enoughEnergy() then
		moved = engine.Actor.move(self, x, y, force)
		if not force and moved and not self.did_energy then self:useEnergy() end
	end
	self.did_energy = nil
	return moved
end

function _M:tooltip()
	return ([[%s%s]]):format(
	self:getDisplayString(),
	self.name
	)
end

function _M:onTakeHit(value, src)
	return value
end

function _M:die(src)
	engine.interface.ActorLife.die(self, src)

	game.level.map:particleEmitter(self.x, self.y, 1, "blood")
	if src.player then
		src.kills = src.kills + 1
		if not self:attr("blind") then src.lurkkills = src.lurkkills + 1 end

		src.max_shadow = math.floor((src.kills + src.lurkkills * 2) / 8) + 3
		src.max_lurk = math.floor((src.kills + src.lurkkills * 2) / 10) + 2
		if src.kills > 59 then src.max_lurk = src.max_lurk - 1 end
		if src.kills + src.lurkkills * 2 > 50 then src.sight = 9 end
		src:incShadow(2 + (self:attr("blind") and 0 or 2))
		src.changed = true
	end

	return true
end

function _M:attack(target)
	self:bumpInto(target)
end


--- Called before a talent is used
-- Check the actor can cast it
-- @param ab the talent (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseTalent(ab, silent)
	if not self:enoughEnergy() then print("fail energy") return false end

	if ab.mode == "sustained" then
		if ab.sustain_shadow and self.max_shadow < ab.sustain_shadow and not self:isTalentActive(ab.id) then
			game.logPlayer(self, "You do not have enough shadow to activate %s.", ab.name)
			return false
		end
	else
		if ab.shadow and self:getShadow() < ab.shadow then
			game.logPlayer(self, "You do not have enough shadow to cast %s.", ab.name)
			return false
		end
	end

	if not silent then
		-- Allow for silent talents
		if ab.message ~= nil then
			if ab.message then
				game.logSeen(self, "%s", self:useTalentMessage(ab))
			end
		elseif ab.mode == "sustained" and not self:isTalentActive(ab.id) then
			game.logSeen(self, "%s activates %s.", self.name:capitalize(), ab.name)
		elseif ab.mode == "sustained" and self:isTalentActive(ab.id) then
			game.logSeen(self, "%s deactivates %s.", self.name:capitalize(), ab.name)
		else
			game.logSeen(self, "%s uses %s.", self.name:capitalize(), ab.name)
		end
	end
	return true
end

--- Called before a talent is used
-- Check if it must use a turn, mana, stamina, ...
-- @param ab the talent (not the id, the table)
-- @param ret the return of the talent action
-- @return true to continue, false to stop
function _M:postUseTalent(ab, ret)
	if not ret then return end

	self:useEnergy()

	if ab.mode == "sustained" then
		if not self:isTalentActive(ab.id) then
			if ab.sustain_shadow then
				self.max_shadow = self.max_shadow - ab.sustain_shadow
			end
		else
			if ab.sustain_shadow then
				self.max_shadow = self.max_shadow + ab.sustain_shadow
			end
		end
	else
		if ab.shadow then
			self:incShadow(-ab.shadow)
		end
	end

	return true
end

--- Return the full description of a talent
-- You may overload it to add more data (like shadow usage, ...)
function _M:getTalentFullDescription(t)
	local d = {}

	if t.mode == "passive" then d[#d+1] = "#6fff83#Use mode: #00FF00#Passive"
	elseif t.mode == "sustained" then d[#d+1] = "#6fff83#Use mode: #00FF00#Sustained"
	else d[#d+1] = "#6fff83#Use mode: #00FF00#Activated"
	end

	if t.shadow or t.sustain_shadow then d[#d+1] = "#6fff83#Shadow Power cost: #7fffd4#"..(t.shadow or t.sustain_shadow) end
	if self:getTalentRange(t) > 1 then d[#d+1] = "#6fff83#Range: #FFFFFF#"..self:getTalentRange(t)
	else d[#d+1] = "#6fff83#Range: #FFFFFF#melee/personal"
	end
	if t.cooldown then d[#d+1] = "#6fff83#Cooldown: #FFFFFF#"..t.cooldown end

	return table.concat(d, "\n").."\n#6fff83#Description: #FFFFFF#"..t.info(self, t)
end

--- Can the actor see the target actor
-- This does not check LOS or such, only the actual ability to see it.<br/>
-- Check for telepathy, invisibility, stealth, ...
function _M:canSee(actor, def, def_pct)
	if not actor then return false, 0 end

	-- Check for stealth. Checks against the target cunning and level
	if actor:attr("stealth") and actor ~= self then
		local def = self.level / 2 + self:getCun(25)
		local hit, chance = self:checkHit(def, actor:attr("stealth") + (actor:attr("inc_stealth") or 0), 0, 100)
		if not hit then
			return false, chance
		end
	end

	if def ~= nil then
		return def, def_pct
	else
		return true, 100
	end
end

--- Can the target be applied some effects
-- @param what a string describing what is being tried
function _M:canBe(what)
	return true
end
