require "engine.class"

--- Handles autoleveling schemes
-- Proably used mainly for NPCS, although it could also be used for player allies
-- or players themselves for lazy players/modules
module(..., package.seeall, class.make)

_M.schemes = {}

function _M:registerScheme(t)
	assert(t.name, "no autolevel name")
	assert(t.levelup, "no autolevel levelup function")
	_M.schemes[t.name] = t
end

function _M:autoLevel(actor)
	if not actor.autolevel then return end
	assert(_M.schemes[actor.autolevel], "no autoleveling scheme "..actor.autolevel)

	_M.schemes[actor.autolevel].levelup(actor)
end
