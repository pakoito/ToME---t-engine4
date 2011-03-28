-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

--- Make a particle emitter
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
--[[
function _M:loaded()
	local def, fct, max, gl, no_stop
	local base_size = nil
	if type(self.def) == "string" then
		if _M.particles_def[self.def] then
			local t = self.args or {}
			setfenv(_M.particles_def[self.def], setmetatable(t, {__index=_G}))
			def, fct, max, gl, no_stop = _M.particles_def[self.def]()
			base_size = t.base_size
		else
			local odef = self.def
			print("[PARTICLE] Loading from /data/gfx/particles/"..self.def..".lua")
			local f, err = loadfile("/data/gfx/particles/"..self.def..".lua")
			if not f and err then error(err) end
			local t = self.args or {}
			setfenv(f, setmetatable(t, {__index=_G}))
			def, fct, max, gl, no_stop = f()
			base_size = t.base_size
			_M.particles_def[odef] = f
		end
	else error("unsupported particle type: "..type(self.def))
	end

	gl = gl or "particle"
	if not self.__particles_gl[gl] then self.__particles_gl[gl] = core.display.loadImage("/data/gfx/"..gl..".png"):glTexture() end
	gl = self.__particles_gl[gl]

	-- Zoom accordingly
	self.base_size = base_size
	self:updateZoom()

	self.update = fct
	-- Make a gas cloud
	if def.gas then
		self.ps = core.gas.newEmitter(def.gas.w, def.gas.h, config.settings.particles_density or 100, def, gl)
	else
		self.ps = core.particles.newEmitter(max or 1000, no_stop, config.settings.particles_density or 100, def, gl)
	end
end
]]

local foo = {}
function _M:loaded()
	local base_size = nil
	if type(self.def) == "string" then
	else error("unsupported particle type: "..type(self.def))
	end

	-- Zoom accordingly
	self.base_size = base_size
	self:updateZoom()

	-- Serialize arguments for passing into the particles threads
	local args = table.serialize(self.args or {}, nil, true)
	args = args.."tile_w="..engine.Map.tile_w.."\ntile_h="..engine.Map.tile_h

	self.update = fct
	self.ps = core.particles.newEmitter("/data/gfx/particles/"..self.def..".lua", args, self.zoom, config.settings.particles_density or 100)
end

function _M:updateZoom()
	self.zoom = self.zoom or 1
	if self.base_size then
		self.zoom = ((engine.Map.tile_w + engine.Map.tile_h) / 2) / self.base_size
	end
end
