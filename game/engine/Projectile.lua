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
local Entity = require "engine.Entity"
local Particles = require "engine.Particles"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(Entity))

_M.display_on_seen = true
_M.display_on_remember = false
_M.display_on_unknown = false

function _M:init(t, no_default)
	t = t or {}
	self.name = t.name or "projectile"
	self.energy = t.energy or { value=game.energy_to_act, mod=2 }
	self.energy.value = self.energy.value or game.energy_to_act
	self.energy.mod = self.energy.mod or 10
	Entity.init(self, t, no_default)
end

--- Adds a particles emitter following the actor
function _M:addParticles(ps)
	self.__particles[ps] = true
	if self.x and self.y and game.level and game.level.map then
		ps.x = self.x
		ps.y = self.y
		game.level.map:addParticleEmitter(ps)
	end
	return ps
end

--- Removes a particles emitter following the actor
function _M:removeParticles(ps)
	self.__particles[ps] = nil
	if self.x and self.y and game.level and game.level.map then
		ps.x = nil
		ps.y = nil
		game.level.map:removeParticleEmitter(ps)
	end
end

--- Moves an actor on the map
-- *WARNING*: changing x and y properties manualy is *WRONG* and will blow up in your face. Use this method. Always.
-- @param map the map to move onto
-- @param x coord of the destination
-- @param y coord of the destination
-- @param force if true do not check for the presence of an other entity. *Use wisely*
-- @return true if a move was *ATTEMPTED*. This means the actor will proably want to use energy
function _M:move(x, y, force)
	if self.dead then return true end
	local map = game.level.map

	if x < 0 then x = 0 end
	if x >= map.w then x = map.w - 1 end
	if y < 0 then y = 0 end
	if y >= map.h then y = map.h - 1 end

	if self.x and self.y then
		map:remove(self.x, self.y, Map.PROJECTILE)
	else
--		print("[MOVE] projectile moved without a starting position", self.name, x, y)
	end
	self.old_x, self.old_y = self.x or x, self.y or y
	self.x, self.y = x, y
	map(x, y, Map.PROJECTILE, self)

	if self.travel_particle then
		self:addParticles(Particles.new(self.travel_particle, 1, nil))
		self.travel_particle = nil
	end

	-- Update particle emitters attached to that actor
	local del = {}
	for e, _ in pairs(self.__particles) do
		if e.dead then del[#del+1] = e
		else
			e.x = x
			e.y = y
			map.particles[e] = true
		end
	end
	for i = 1, #del do self.particles[del[i] ] = nil end

	self:useEnergy()

	return true
end

function _M:deleteFromMap(map)
	if self.x and self.y and map then
		map:remove(self.x, self.y, engine.Map.PROJECTILE)
		for e, _ in pairs(self.__particles) do
			e.x = nil
			e.y = nil
			map:removeParticleEmitter(e)
		end
	end
end

--- Do we have enough energy
function _M:enoughEnergy(val)
	val = val or game.energy_to_act
	return self.energy.value >= val
end

--- Use some energy
function _M:useEnergy(val)
	val = val or game.energy_to_act
	self.energy.value = self.energy.value - val
	self.energy.used = true
end

function _M:tooltip()
	return "Projectile: "..self.name
end


--- Called by the engine when the projectile can move
function _M:act()
	if self.dead then return false end

	while self:enoughEnergy() and not self.dead do
		if self.project then
			local x, y, act, stop = self.src:projectDoMove(self.project.def.typ, self.project.def.x, self.project.def.y, self.x, self.y, self.project.def.start_x, self.project.def.start_y)
			if x and y then self:move(x, y) end
			if act then self.src:projectDoAct(self.project.def.typ, self.project.def.tg, self.project.def.damtype, self.project.def.dam, self.project.def.particles, self.x, self.y, self.tmp_proj) end
			if stop then
				self.src:projectDoStop(self.project.def.typ, self.project.def.tg, self.project.def.damtype, self.project.def.dam, self.project.def.particles, self.x, self.y, self.tmp_proj)
				game.level:removeEntity(self)
				self.dead = true
			end
		end
	end

	return true
end

--- Generate a projectile for a project() call
function _M:makeProject(src, display, def, do_move, do_act, do_stop)
	display = display or {display='*'}
	local speed = def.tg.speed
	local name = def.tg.name
	if def.tg.talent then
		speed = src:getTalentProjectileSpeed(def.tg.talent)
		name = def.tg.talent.name
		def.tg.talent_id = def.tg.talent.id
		def.tg.talent = nil
	end
	return _M.new{
		name = name,
		display = display.display or ' ', color = display.color or colors.WHITE, image = display.image or nil,
		travel_particle = display.particle,
		src = src,
		src_x = src.x, src_y = src.y,
		project = {def=def},
		energy = {mod=speed or 10},
		tmp_proj = {},
	}
end
