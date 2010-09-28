-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

--- Handles a particles system
-- Used by engine.Map
module(..., package.seeall, class.make)

_M.particles_def = {}

_M.__particles_gl = { particle = core.display.loadImage("/data/gfx/particle.png"):glTexture() }

--- Make a particle emiter
function _M:init(def, radius, args)
	self.args = args
	self.def = def
	self.radius = radius or 1

	self:loaded()
end

--- Serialization
function _M:save()
	return class.save(self, {
		ps = true,
	})
end

function _M:cloned()
	self:loaded()
end

function _M:loaded()
	local def, fct, max, gl, no_stop
	if type(self.def) == "string" then
		if _M.particles_def[self.def] then
			setfenv(_M.particles_def[self.def], setmetatable(self.args or {}, {__index=_G}))
			def, fct, max, gl, no_stop = _M.particles_def[self.def]()
		else
			local odef = self.def
			print("[PARTICLE] Loading from /data/gfx/particles/"..self.def..".lua")
			local f, err = loadfile("/data/gfx/particles/"..self.def..".lua")
			if not f and err then error(err) end
			setfenv(f, setmetatable(self.args or {}, {__index=_G}))
			def, fct, max, gl, no_stop = f()
			_M.particles_def[odef] = f
		end
	else error("unsupported particle type: "..type(self.def))
	end

	gl = gl or "particle"
	if not self.__particles_gl[gl] then self.__particles_gl[gl] = core.display.loadImage("/data/gfx/"..gl..".png"):glTexture() end
	gl = self.__particles_gl[gl]

	self.update = fct
	self.ps = core.particles.newEmitter(max or 1000, no_stop, def, gl)
end
