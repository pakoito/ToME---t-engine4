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
	if self.trail_particle then
		local ps = Particles.new(self.trail_particle, 1, nil)
		ps.x = x
		ps.y = y
		game.level.map:addParticleEmitter(ps)
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
	for i = 1, #del do self.__particles[del[i] ] = nil end

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

local coords = {
	[1] = { 4, 2, 7, 3 },
	[2] = { 1, 3, 4, 6 },
	[3] = { 2, 6, 1, 9 },
	[4] = { 7, 1, 8, 2 },
	[5] = {},
	[6] = { 9, 3, 8, 2 },
	[7] = { 4, 8, 1, 9 },
	[8] = { 7, 9, 4, 6 },
	[9] = { 8, 6, 7, 3 },
}

--- Move one step to the given target if possible
-- This tries the most direct route, if not available it checks sides and always tries to get closer
function _M:moveDirection(x, y)
	local l = line.new(self.x, self.y, x, y)
	local lx, ly = l()
	if lx and ly then
		-- if we are blocked, try some other way
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			local dirx = lx - self.x
			local diry = ly - self.y
			local dir = coord_to_dir[dirx][diry]

			local list = coords[dir]
			local l = {}
			-- Find posiblities
			for i = 1, #list do
				local dx, dy = self.x + dir_to_coord[list[i]][1], self.y + dir_to_coord[list[i]][2]
				if not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
					l[#l+1] = {dx,dy, (dx-x)^2 + (dy-y)^2}
				end
			end
			-- Move to closest
			if #l > 0 then
				table.sort(l, function(a,b) return a[3]<b[3] end)
				return self:move(l[1][1], l[1][2])
			end
		else
			return self:move(lx, ly)
		end
	end
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
				-- Correct the explosion source position if we exploded on terrain
				local radius_x, radius_y
				if self.project.def.typ.block_path then
					_, radius_x, radius_y = self.project.def.typ:block_path(self.x, self.y)
				end
				if not radius_x then
					radius_x, radius_y = self.old_x, self.old_y
				end
				game.level:removeEntity(self)
				self.dead = true
				self.src:projectDoStop(self.project.def.typ, self.project.def.tg, self.project.def.damtype, self.project.def.dam, self.project.def.particles, self.x, self.y, self.tmp_proj, radius_x, radius_y)
			end
		elseif self.homing then
			self:moveDirection(self.homing.target.x, self.homing.target.y)
			self.homing.count = self.homing.count - 1
			if (self.x == self.homing.target.x and self.y == self.homing.target.y) or self.homing.count <= 0 then
				game.level:removeEntity(self)
				self.dead = true
				self.homing.on_hit(self, self.src, self.homing.target)
			else
				self.homing.on_move(self, self.src)
			end
		end
	end

	return true
end

--- Something moved in the same spot as us, hit ?
function _M:on_move(x, y, target)
	if self.project and self.project.def.typ.stop_block then
		game.level:removeEntity(self)
		self.dead = true
		self.src:projectDoStop(self.project.def.typ, self.project.def.tg, self.project.def.damtype, self.project.def.dam, self.project.def.particles, self.x, self.y, self.tmp_proj)
	end
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
	speed = speed or 10
	local p =_M.new{
		name = name,
		display = display.display or ' ', color = display.color or colors.WHITE, image = display.image or nil,
		travel_particle = display.particle,
		trail_particle = display.trail,
		src = src,
		src_x = src.x, src_y = src.y,
		project = {def=def},
		energy = {mod=speed},
		tmp_proj = {},
	}

	game.level.map:checkAllEntities(def.x, def.y, "on_projectile_target", p)

	return p
end

--- Generate a projectile for an homing projectile
function _M:makeHoming(src, display, def, target, count, on_move, on_hit)
	display = display or {display='*'}
	local speed = def.speed
	local name = def.name
	speed = speed or 10
	local p =_M.new{
		name = name,
		display = display.display or ' ', color = display.color or colors.WHITE, image = display.image or nil,
		travel_particle = display.particle,
		trail_particle = display.trail,
		src = src,
		def = def,
		homing = {target=target, count=count, on_move=on_move, on_hit=on_hit},
		energy = {mod=speed},
	}

	game.level.map:checkAllEntities(target.x, target.y, "on_projectile_target", p)

	return p
end
