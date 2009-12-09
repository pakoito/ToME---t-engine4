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

function _M:tooltip()
	local mx, my = core.mouse.get()
	local tmx, tmy = game.level.map:getMouseTile(mx, my)
	return ("%d:%d\nSeen %s\nRemember %s\nLite %s"):format(tmx,tmy,tostring(game.level.map.seens(tmx, tmy)), tostring(game.level.map.remembers(tmx, tmy)), tostring(game.level.map.lites(tmx, tmy)))
end
