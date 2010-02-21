require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
local Random = require "engine.generator.actor.Random"

--- Very specialized generator that puts sandworms in interresting spots to dig tunnels
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, spots)
	engine.Generator.init(self, zone, map)
	self.level = level
	self.data = level.data.generator.actor
	self.spots = spots

	self.random = Random.new(zone, map, level)
end

function _M:generate()
	-- Make the random generaor place normal actors
	self.random:generate()

	-- Now place sandworm tunnelers
	local used= {}
	for i = 1, self.data.nb_tunnelers do
		local s, idx = rng.table(self.spots)
		while used[idx] do s, idx = rng.table(self.spots) end
		used[idx] = true

		self:placeWorm(s)
	end

	-- Always add one near the stairs
	self:placeWorm(self.level.ups[1])
	self:placeWorm(self.level.downs[1])
end

function _M:placeWorm(s)
	if not s.x or not s.y then return end
	local m = self.zone:makeEntityByName(self.level, "actor", "SANDWORM_TUNNELER")
	if m then
		local x, y = util.findFreeGrid(s.x, s.y, 5, true, {[Map.ACTOR]=true})
		if x and y then
			m:move(x, y, true)
			self.level:addEntity(m)
			m:added()
		end
	end
end
