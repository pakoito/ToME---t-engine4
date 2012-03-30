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
local Map = require "engine.Map"
local Target = require "engine.Target"
local DamageType = require "engine.DamageType"

--- Handles actors life and death
module(..., package.seeall, class.make)

function _M:init(t)
	self.max_life = t.max_life or 100
	self.life = t.life or self.max_life
	self.life_regen = t.life_regen or 0
	self.die_at = t.die_at or 0
end

--- Checks if something bumps in us
-- If it happens the method attack is called on the target with the attacker as parameter.
-- Do not touch!
function _M:block_move(x, y, e, can_attack)
	-- Dont bump yourself!
	if e and e ~= self and can_attack then
		e:attack(self, x, y)
		return "attack"
	end
	return true
end

--- Regenerate life, call it from your actor class act() method
function _M:regenLife()
	if self.life_regen then
		self.life = util.bound(self.life + self.life_regen, self.die_at, self.max_life)
	end
end

--- Heal some
function _M:heal(value, src)
	if self.onHeal then value = self:onHeal(value, src) end
	self.life = util.bound(self.life + value, self.die_at, self.max_life)
	self.changed = true
end

--- Remove some HP from an actor
-- If HP is reduced to 0 then remove from the level and call the die method.<br/>
-- When an actor dies its dead property is set to true, to wait until garbage collection deletes it
-- @return true/false if the actor died and the actual damage done
function _M:takeHit(value, src, death_note)
	if self.onTakeHit then value = self:onTakeHit(value, src) end
	self.life = self.life - value
	self.changed = true
	if self.life <= self.die_at then
		if src.on_kill and src:on_kill(self) then return false, value end
		game.logSeen(self, "#{bold}#%s killed %s!#{normal}#", src.name:capitalize(), self.name)
		return self:die(src, death_note), value
	end
	return false, value
end

--- Called when died
function _M:die(src, death_note)
	if game.level:hasEntity(self) then game.level:removeEntity(self) end
	self.dead = true
	self.changed = true

	self:check("on_die", src, death_note)

	return true
end

--- Actor is being attacked!
-- Module authors should rewrite it to handle combat, dialog, ...
-- @param target the actor attacking us
function _M:attack(target, x, y)
	game.logSeen(target, "%s attacks %s.", self.name:capitalize(), target.name:capitalize())
	target:takeHit(10, self)
end
