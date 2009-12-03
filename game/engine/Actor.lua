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
end

function _M:move(map, x, y, force)
	if not force and map:checkAllEntities(x, y, "block_move", self) then return true end

	if self.x and self.y then
		map:remove(self.x, self.y, Map.ACTOR)
	end
	if x < 0 then x = 0 end
	if x >= map.w then x = map.w - 1 end
	if y < 0 then y = 0 end
	if y >= map.h then y = map.h - 1 end
	self.x, self.y = x, y
--	if self.levelid then
--		game.level.c_level:moveActor(self.levelid, x, y)
--	end
	map(x, y, Map.ACTOR, self)
	game.level:idleProcessActor(self)

	return true
end

function _M:canMove(x, y, terrain_only)
	if terrain_only then
		return not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move")
	else
		return not game.level.map:checkAllEntities(x, y, "block_move")
	end
end

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

function _M:enoughEnergy(val)
	val = val or game.energy_to_act
	return self.energy.value >= val
end

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
