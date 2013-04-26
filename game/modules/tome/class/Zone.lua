-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.class"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(Zone))

--- Called when the zone file is loaded
function _M:onLoadZoneFile(basedir)
	-- Load events if they exist
	if fs.exists(basedir.."events.lua") then
		local f = loadfile(basedir.."events.lua")
		setfenv(f, setmetatable({self=self}, {__index=_G}))
		self.events = f()
	end
end

--- Make it work for high levels
function _M:adjustComputeRaritiesLevel(level, type, lev)
	return 500*lev/(lev+450) -- Prevent probabilities from vanishing at high levels
end

--- Quake a zone
-- Moves randomly each grid to an other grid
function _M:doQuake(rad, x, y, check)
	local w = game.level.map.w
	local locs = {}
	local ms = {}
	
	core.fov.calc_circle(x, y, game.level.map.w, game.level.map.h, rad,
		function(_, lx, ly) if not game.level.map:isBound(lx, ly) then return true end end,
		function(_, tx, ty)
			if check(tx, ty) then
				locs[#locs+1] = {x=tx,y=ty}
				ms[#ms+1] = {map=game.level.map.map[tx + ty * w], attrs=game.level.map.attrs[tx + ty * w]}
			end
		end,
	nil)

	local savelocs = table.clone(locs)
	while #locs > 0 do
		local l = rng.tableRemove(locs)
		local m = rng.tableRemove(ms)

		game.level.map.map[l.x + l.y * w] = m.map
		game.level.map.attrs[l.x + l.y * w] = m.attrs
		for z, e in pairs(m.map or {}) do
			if e.move then
				e.x = nil e.y = nil e:move(l.x, l.y, true)
			end
		end
	end

	locs = savelocs
	while #locs > 0 do
		local l = rng.tableRemove(locs)
		game.nicer_tiles:updateAround(game.level, l.x, l.y)
	end

	game.level.map:cleanFOV()
	game.level.map.changed = true
	game.level.map:redisplay()
end
