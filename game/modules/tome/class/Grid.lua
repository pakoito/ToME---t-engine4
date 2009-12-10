require "engine.class"
require "engine.Grid"

module(..., package.seeall, class.inherit(engine.Grid))

function _M:init(t)
	engine.Grid.init(self, t)
end

function _M:block_move(x, y, e)
	-- Open doors
	if self.door_opened then
		game.level.map(x, y, engine.Map.TERRAIN, game.zone.grid_list.DOOR_OPEN)
		return true
	end
	return false
end
