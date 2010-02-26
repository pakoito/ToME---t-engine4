require "engine.class"
require "engine.Grid"

module(..., package.seeall, class.inherit(engine.Grid))

function _M:init(t, no_default)
	engine.Grid.init(self, t, no_default)
end

function _M:block_move(x, y, e, act)
	-- Open doors
	if self.door_opened and act then
		game.level.map(x, y, engine.Map.TERRAIN, game.zone.grid_list.DOOR_OPEN)
		return true
	elseif self.door_opened then
		return true
	end
	return false
end

function _M:tooltip()
--	local mx, my = core.mouse.get()
--	local tmx, tmy = game.level.map:getMouseTile(mx, my)
--	return tmx.."x"..tmy
end
