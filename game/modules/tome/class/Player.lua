require "engine.class"
require "mod.class.Actor"

module(..., package.seeall, class.inherit(mod.class.Actor))

function _M:init(t)
	mod.class.Actor.init(self, t)
	self.player = true
	self.faction = "players"
	self.combat = { dam=10, atk=40, apr=2, def=6, armor=4 }
end

function _M:move(x, y, force)
	local moved = mod.class.Actor.move(self, x, y, force)
	if moved then
		game.level.map:moveViewSurround(self.x, self.y, 4, 4)
	end
	return moved
end

function _M:act()
	game.paused = true
end

function _M:die()
	-- a tad brutal
	os.exit()
end

function _M:setName(name)
	self.name = name
	game.save_name = name
end

--- Tries to get a target from the user
-- *WARNING* If used inside a coroutine it will yield and resume it later when a target is found.
-- This is usualy just what you want so dont think too much about it :)
function _M:getTarget(typ)
	if coroutine.running() then
		local msg
		if type(typ) == "string" then msg, typ = typ, nil
		elseif type(typ) == "table" then msg = typ.msg end
		game:targetMode("exclusive", msg, coroutine.running(), typ)
		return coroutine.yield()
	end
	return game.target.target.x, game.target.target.y
end

--- Quick way to check if the player can see the target
function _M:canSee(entity)
	if entity.x and entity.y and game.level.map.seens(entity.x, entity.y) then return true end
end
