require "engine.class"
local Entity = require "engine.Entity"
local Map = require "engine.Map"
local Faction = require "engine.Faction"

module(..., package.seeall, class.inherit(Entity))

function _M:init(t)
	t = t or {}

	self.name = t.name or "unknown actor"
	self.level = t.level or 1
	self.sight = t.sight or 20
	self.energy = t.energy or { value=0, mod=1 }
	self.energy.value = self.energy.value or 0
	self.energy.mod = self.energy.mod or 0
	self.faction = t.faction or "enemies"
	self.changed = true
	Entity.init(self, t)

	self.compute_vals = {}
end

--- Called when it is time to act
function _M:act()
	if self.dead then return false end
	return true
end

--- Moves an actor on the map
-- *WARNING*: changing x and y properties manualy is *WRONG* and will blow up in your face. Use this method. Always.
-- @param map the map to move onto
-- @param x coord of the destination
-- @param y coord of the destination
-- @param force if true do not check for the presence of an other entity. *Use wisely*
-- @return true if a move was *ATTEMPTED*. This means the actor will proably want to use energy
function _M:move(map, x, y, force)
	if self.dead then return true end
	if not force and map:checkAllEntities(x, y, "block_move", self) then return true end

	if self.x and self.y then
		map:remove(self.x, self.y, Map.ACTOR)
	end
	if x < 0 then x = 0 end
	if x >= map.w then x = map.w - 1 end
	if y < 0 then y = 0 end
	if y >= map.h then y = map.h - 1 end
	self.x, self.y = x, y
	map(x, y, Map.ACTOR, self)
	game.level:idleProcessActor(self)

	return true
end

--- Can the actor go there
-- @param terrain_only if true checks only the terrain, otherwise checks all entities
function _M:canMove(x, y, terrain_only)
	if terrain_only then
		return not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move")
	else
		return not game.level.map:checkAllEntities(x, y, "block_move")
	end
end

--- Teleports randomly to a passable grid
-- @param x the coord of the teleporatation
-- @param y the coord of the teleporatation
-- @param dist the radius of the random effect, if set to 0 it is a precise teleport
-- @return true if the teleport worked
function _M:teleportRandom(x, y, dist)
	local poss = {}

	for i = x - dist, x + dist do
		for j = y - dist, y + dist do
			if game.level.map:isBound(i, j) and
			   core.fov.distance(x, y, i, j) <= dist and
			   self:canMove(i, j) then
				poss[#poss+1] = {i,j}
			end
		end
	end

	if #poss == 0 then return false end
	local pos = poss[rng.range(1, #poss)]
	return self:move(pos[1], pos[2], true)
end

function _M:deleteFromMap(map)
	if self.x and self.y and map then
		map:remove(self.x, self.y, engine.Map.ACTOR)
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
	if self.player and self.energy.value < game.energy_to_act then game.paused = false end
end

--- What is our reaction toward the target
-- See Faction:factionReaction()
function _M:reactionToward(target)
	return Faction:factionReaction(self.faction, target.faction)
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
	self.compute_vals[prop] = self.compute_vals[prop] or {}
	local t = self.compute_vals[prop]
	t[#t+1] = v

	-- Update the base prop
	if not noupdate then
		if type(v) == "number" then
			-- Simple addition
			self[prop] = (self[prop] or 0) + v
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

	return #t
end

--- Removes a temporary value, see addTemporaryValue()
-- @param prop the property to affect
-- @param id the id of the increase to delete
-- @param noupdate if true the actual property is not changed and needs to be changed by the caller
function _M:removeTemporaryValue(prop, id, noupdate)
	local oldval = self.compute_vals[prop][id]
	self.compute_vals[prop][id] = nil
	if not noupdate then
		if type(oldval) == "number" then
			self[prop] = self[prop] - oldval
--		elseif type(oldval) == "boolean" then
		else
			error("unsupported temporary value type: "..type(oldval))
		end
	end
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
		if fix then self.prop = v
		else self.prop = (self.prop or 0) + v
		end
	else
		if self.prop and self.prop ~= 0 then
			return self.prop
		else
			return nil
		end
	end
end
