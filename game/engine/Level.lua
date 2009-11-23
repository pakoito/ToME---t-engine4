require "engine.class"

--- Define a level
module(..., package.seeall, class.make)

--- Initializes the level with a "level" and a map
function _M:init(level, map)
	self.level = level
	self.map = map
	self.entities = {}
end


--- Adds an entity to the level
-- Only entities that need to act need to be added. Terrain features do not need this usualy
function _M:addEntity(e)
	if self.entities[e.uid] then error("Entity "..e.uid.." already present on the level") end
	self.entities[e.uid] = e
end
