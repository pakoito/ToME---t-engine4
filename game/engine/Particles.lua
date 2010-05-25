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

_M.default_particle = core.display.loadImage("/data/gfx/particle.png"):glTexture()

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

function _M:loaded()
	local def, fct, max
	if type(self.def) == "string" then
		if _M.particles_def[self.def] then
			def, fct, max = _M.particles_def[self.def]()
		else
			local odef = self.def
			print("[PARTICLE] Loading from /data/gfx/particles/"..self.def..".lua")
			local f = loadfile("/data/gfx/particles/"..self.def..".lua")
			setfenv(f, setmetatable(self.args or {}, {__index=_G}))
			def, fct, max = f()
			max = max or 1000
			_M.particles_def[odef] = f
		end
	else error("unsupported particle type: "..type(self.def))
	end

	self.update = fct
	self.ps = core.particles.newEmitter(max or 1000, def, self.default_particle)
end
