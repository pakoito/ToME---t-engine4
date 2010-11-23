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
local Map = require "engine.Map"
local Faction = require "engine.Faction"

module(..., package.seeall, class.inherit(Entity))

_M.display_on_seen = true
_M.display_on_remember = false
_M.display_on_unknown = false
-- Allow actors to act as object carriers, if the interface is loaded
_M.__allow_carrier = true

function _M:init(t, no_default)
	t = t or {}

	if not self.targetable and self.targetable == nil then self.targetable = true end
	self.name = t.name or "unknown actor"
	self.level = t.level or 1
	self.sight = t.sight or 20
	self.energy = t.energy or { value=0, mod=1 }
	self.energy.value = self.energy.value or 0
	self.energy.mod = self.energy.mod or 0
	self.faction = t.faction or "enemies"
	self.changed = true
	Entity.init(self, t, no_default)

	self.compute_vals = {n=0}
end

--- Called when it is time to act
function _M:act()
	if self.dead then return false end
	return true
end

--- Gets the actor target
-- Does nothing, AI redefines it so should a "Player" class
function _M:getTarget()
end
--- Sets the actor target
-- Does nothing, AI redefines it so should a "Player" class
function _M:setTarget(target)
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

--- Set the current emote
function _M:setEmote(e)
	-- Remove previous
	if self.__emote then
		game.level.map:removeEmote(self.__emote)
	end
	self.__emote = e
	if e and self.x and self.y and game.level and game.level.map then
		e.x = self.x
		e.y = self.y
		game.level.map:addEmote(e)
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

	x = math.floor(x)
	y = math.floor(y)

	if x < 0 then x = 0 end
	if x >= map.w then x = map.w - 1 end
	if y < 0 then y = 0 end
	if y >= map.h then y = map.h - 1 end

	if not force and map:checkAllEntities(x, y, "block_move", self, true) then return true end

	if self.x and self.y then
		map:remove(self.x, self.y, Map.ACTOR)
	else
		print("[MOVE] actor moved without a starting position", self.name, x, y)
	end
	self.old_x, self.old_y = self.x or x, self.y or y
	self.x, self.y = x, y
	map(x, y, Map.ACTOR, self)

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
	for i = 1, #del do self.__particles[del[i]] = nil end

	-- Move emote
	if self.__emote then
		if self.__emote.dead then self.__emote = nil
		else
			self.__emote.x = x
			self.__emote.y = y
			map.emotes[self.__emote] = true
		end
	end

	map:checkAllEntities(x, y, "on_move", self, force)

	return true
end

--- Moves into the given direction (calls actor:move() internally)
function _M:moveDir(dir)
	local dx, dy = dir_to_coord[dir][1], dir_to_coord[dir][2]
	local x, y = self.x + dx, self.y + dy
	return self:move(x, y)
end

--- Can the actor go there
-- @param terrain_only if true checks only the terrain, otherwise checks all entities
function _M:canMove(x, y, terrain_only)
	if not game.level.map:isBound(x, y) then return false end
	if terrain_only then
		return not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move")
	else
		return not game.level.map:checkAllEntities(x, y, "block_move", self)
	end
end

--- Remove the actor from the level, marking it as dead but not using the death functions
function _M:disappear(src)
	if game.level:hasEntity(self) then game.level:removeEntity(self) end
	self.dead = true
	self.changed = true
end

--- Get the "path string" for this actor
-- See Map:addPathString() for more info
function _M:getPathString()
	return ""
end

--- Teleports randomly to a passable grid
-- @param x the coord of the teleporatation
-- @param y the coord of the teleporatation
-- @param dist the radius of the random effect, if set to 0 it is a precise teleport
-- @param min_dist the minimun radius of of the effect, will never teleport closer. Defaults to 0 if not set
-- @return true if the teleport worked
function _M:teleportRandom(x, y, dist, min_dist)
	local poss = {}
	dist = math.floor(dist)
	min_dist = math.floor(min_dist or 0)

	for i = x - dist, x + dist do
		for j = y - dist, y + dist do
			if game.level.map:isBound(i, j) and
			   core.fov.distance(x, y, i, j) <= dist and
			   core.fov.distance(x, y, i, j) >= min_dist and
			   self:canMove(i, j) and
			   not game.level.map.attrs(i, j, "no_teleport") then
				poss[#poss+1] = {i,j}
			end
		end
	end

	if #poss == 0 then return false end
	local pos = poss[rng.range(1, #poss)]
	return self:move(pos[1], pos[2], true)
end

--- Knock back the actor
function _M:knockback(srcx, srcy, dist, recursive)
	print("[KNOCKBACK] from", srcx, srcy, "over", dist)

	local l = line.new(srcx, srcy, self.x, self.y, true)
	local lx, ly = l(true)
	local ox, oy = lx, ly
	dist = dist - 1

	print("[KNOCKBACK] try", lx, ly, dist)

	if recursive then
		local target = game.level.map(lx, ly, Map.ACTOR)
		if target and recursive(target) then
			target:knockback(srcx, srcy, dist, recursive)
		end
	end

	while game.level.map:isBound(lx, ly) and not game.level.map:checkAllEntities(lx, ly, "block_move", self) and dist > 0 do
		dist = dist - 1
		ox, oy = lx, ly
		lx, ly = l(true)
		print("[KNOCKBACK] try", lx, ly, dist, "::", game.level.map:checkAllEntities(lx, ly, "block_move", self))

		if recursive then
			local target = game.level.map(lx, ly, Map.ACTOR)
			if target and recursive(target) then
				target:knockback(srcx, srcy, dist, recursive)
			end
		end
	end

	if game.level.map:isBound(lx, ly) and not game.level.map:checkAllEntities(lx, ly, "block_move", self) then
		print("[KNOCKBACK] ok knocked to", lx, ly, "::", game.level.map:checkAllEntities(lx, ly, "block_move", self))
		self:move(lx, ly, true)
	elseif game.level.map:isBound(ox, oy) and not game.level.map:checkAllEntities(ox, oy, "block_move", self) then
		print("[KNOCKBACK] failsafe knocked to", ox, oy, "::", game.level.map:checkAllEntities(ox, oy, "block_move", self))
		self:move(ox, oy, true)
	end
end

function _M:deleteFromMap(map)
	if self.x and self.y and map then
		map:remove(self.x, self.y, engine.Map.ACTOR)
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
	if self.player and self.energy.value < game.energy_to_act then game.paused = false end
--	print("USE ENERGY", self.name, self.uid, "::", self.energy.value, game.paused, "::", self.player)
end

--- What is our reaction toward the target
-- See Faction:factionReaction()
function _M:reactionToward(target)
	return Faction:factionReaction(self.faction, target.faction)
end

--- Can the actor see the target actor
-- This does not check LOS or such, only the actual ability to see it.<br/>
-- By default this returns true, but a module can override it to check for telepathy, invisibility, stealth, ...
-- @param actor the target actor to check
-- @param def the default
-- @param def_pct the default percent chance
-- @return true or false and a number from 0 to 100 representing the "chance" to be seen
function _M:canSee(actor, def, def_pct)
	return true, 100
end

--- Does the actor have LOS to the target
function _M:hasLOS(x, y, what)
	what = what or "block_sight"
	local l = line.new(self.x, self.y, x, y)
	local lx, ly = l()
	while lx and ly do
		if game.level.map:checkAllEntities(lx, ly, what) then break end

		lx, ly = l()
	end
	-- Ok if we are at the end reset lx and ly for the next code
	if not lx and not ly then lx, ly = x, y end

	if lx == x and ly == y then return true, lx, ly end
	return false, lx, ly
end

local function gettable(base, name)
	for w in name:gmatch("[^.]+") do
		base = base[w]
	end
	return base
end

--- Computes a "temporary" value into a property
-- Example: You cant to give an actor a boost to life_regen, but you do not want it to be permanent<br/>
-- You cannot simply increase life_regen, so you use this method which will increase it AND
-- store the increase. it will return an "increase id" that can be passed to removeTemporaryValue()
-- to remove the effect.
-- @param prop the property to affect
-- @param v the value to add (only numbers supported for now)
-- @param noupdate if true the actual property is not changed and needs to be changed by the caller
-- @return an id that can be passed to removeTemporaryValue() to delete this value
function _M:addTemporaryValue(prop, v, noupdate)
	local t = self.compute_vals
	local id = t.n + 1
	while t[id] ~= nil do id = id + 1 end
	t[id] = v
	t.n = id

	-- Update the base prop
	if not noupdate then
		if type(v) == "number" then
			-- Simple addition
			self[prop] = (self[prop] or 0) + v
			self:onTemporaryValueChange(prop, nil, v)
			print("addTmpVal", prop, v, " :=: ", #t, id)
		elseif type(v) == "table" then
			for k, e in pairs(v) do
				self[prop][k] = (self[prop][k] or 0) + e
				self:onTemporaryValueChange(prop, k, e)
				print("addTmpValTable", prop, k, e, " :=: ", #t, id)
				if #t == 0 then print("*******************************WARNING") end
			end
--		elseif type(v) == "boolean" then
--			-- False has precedence over true
--			if v == false then
--				self[prop] = false
--			elseif self[prop] ~= false then
--				self[prop] = true
--			end
		else
			error("unsupported temporary value type: "..type(v))
		end
	end

	return id
end

--- Removes a temporary value, see addTemporaryValue()
-- @param prop the property to affect
-- @param id the id of the increase to delete
-- @param noupdate if true the actual property is not changed and needs to be changed by the caller
function _M:removeTemporaryValue(prop, id, noupdate)
	local oldval = self.compute_vals[id]
	print("removeTempVal", prop, oldval, " :=: ", id)
	self.compute_vals[id] = nil
	if not noupdate then
		if type(oldval) == "number" then
			self[prop] = self[prop] - oldval
			self:onTemporaryValueChange(prop, nil, -oldval)
			print("delTmpVal", prop, oldval)
		elseif type(oldval) == "table" then
			for k, e in pairs(oldval) do
				self[prop][k] = self[prop][k] - e
				self:onTemporaryValueChange(prop, k, -e)
				print("delTmpValTable", prop, k, e)
			end
--		elseif type(oldval) == "boolean" then
		else
			error("unsupported temporary value type: "..type(oldval))
		end
	end
end

--- Called when a temporary value changes (added or deleted)
-- This does nothing by default, you can overload it to react to changes
-- @param prop the property changing
-- @param sub the sub element of the property if it is a table, or nil
-- @param v the value of the change
function _M:onTemporaryValueChange(prop, sub, v)
end

--- Increases/decreases an attribute
-- The attributes are just actor properties, but this ensures they are numbers and not booleans
-- thus making them compatible with temporary values system
-- @param prop the property to use
-- @param v the value to add, if nil this the function return
-- @param fix forces the value to v, do not add
-- @return nil if v was specified. If not then it returns the current value if it exists and is not 0 otherwise returns nil
function _M:attr(prop, v, fix)
	if v then
		if fix then self[prop] = v
		else self[prop] = (self[prop] or 0) + v
		end
	else
		if self[prop] and self[prop] ~= 0 then
			return self[prop]
		else
			return nil
		end
	end
end

--- Are we within a certain distance of the target
-- @param x the spot we test for near-ness
-- @param y the spot we test for near-ness
-- @param radius how close we should be (defaults to 1)
function _M:isNear(x, y, radius)
	radius = radius or 1
	if math.floor(core.fov.distance(self.x, self.y, x, y)) > radius then return false end
	return true
end
