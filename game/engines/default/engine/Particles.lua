-- TE4 - T-Engine 4
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

--- Handles a particles system
-- Used by engine.Map
module(..., package.seeall, class.make)

local __particles_gl = {}

--- Make a particle emitter
function _M:init(def, radius, args, shader)
	self.args = args
	self.def = def
	self.radius = radius or 1
	self.shader = shader

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

local foo = {}
function _M:loaded()
	local base_size = nil
	local gl = nil
	if type(self.def) == "string" then
		local f, err = loadfile("/data/gfx/particles/"..self.def..".lua")
		if not f and err then error(err) end
		local t = self.args or {}
		local _
		setfenv(f, setmetatable(t, {__index=_G}))
		_, _ , _, gl, _ = f()

		if t.use_shader then self.shader = t.use_shader end
	else error("unsupported particle type: "..type(self.def))
	end

	gl = gl or "particle"
	if not __particles_gl[gl] then __particles_gl[gl] = core.display.loadImage("/data/gfx/"..gl..".png"):glTexture() end
	gl = __particles_gl[gl]

	-- Zoom accordingly
	self.base_size = base_size
	self:updateZoom()

	-- Serialize arguments for passing into the particles threads
	local args = table.serialize(self.args or {}, nil, true)
	args = args.."tile_w="..engine.Map.tile_w.."\ntile_h="..engine.Map.tile_h

	self.update = fct

	local sha = nil
	if self.shader then
		if not self._shader then
			local Shader = require 'engine.Shader'
			self._shader = Shader.new(self.shader.type, self.shader)
		end

		sha = self._shader.shad
	end

	self.ps = core.particles.newEmitter("/data/gfx/particles/"..self.def..".lua", args, self.zoom, config.settings.particles_density or 100, gl, sha)
end

function _M:updateZoom()
	self.zoom = self.zoom or 1
	if self.base_size then
		self.zoom = ((engine.Map.tile_w + engine.Map.tile_h) / 2) / self.base_size
	end
end

function _M:checkDisplay()
	if self.ps then return end
	self:loaded()
end

function _M:dieDisplay()
	if not self.ps then return end
	self.ps:die()
	self.ps = nil
end
