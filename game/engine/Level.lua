require "engine.class"
module(..., package.seeall, class.make)

function _M:init(map)
	self.map = map
	self.entities = {}
end

function _M:activate()
	self.map:setCurrent()
end

function _M:addEntity(e)
	if self.entities[e.uid] then error("Entity "..e.uid.." already present on the level") end
	self.entities[e.uid] = e
end
