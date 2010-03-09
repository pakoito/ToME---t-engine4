require "engine.class"
require "engine.generator.map.Static"

--- Make the wilderness map, loaded from the player's current wilderness
module(..., package.seeall, class.inherit(engine.generator.map.Static))

function _M:init(zone, map, level, data)
	print("Loading wilderness map: ", game.player.current_wilderness)
	data.map = game.player.current_wilderness

	engine.generator.map.Static.init(self, zone, map, level, data)
end
