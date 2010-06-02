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

_M.verts = {}
_M.frags = {}
_M.progs = {}

--- Make a shader
function _M:init(name, args)
	self.args = args or {}
	self.name = name

	self:loaded()
end

--- Serialization
function _M:save()
	return class.save(self, {
		shad = true,
	})
end

function _M:getFragment(name)
	if not name then return nil end
	if self.frags[name] then return self.frags[name] end
	local f = fs.open("/data/gfx/shaders/"..name..".frag", "r")
	local code = {}
	while true do
		local l = f:read()
		if not l then break end
		code[#code+1] = l
	end
	f:close()
	self.frags[name] = core.shader.newShader(table.concat(code, "\n"))
	print("[SHADER] created fragment shader from /data/gfx/shaders/"..name..".frag")
	return self.frags[name]
end

function _M:getVertex(name)
	if not name then return nil end
	if self.verts[name] then return self.verts[name] end
	local f = fs.open("/data/gfx/shaders/"..name..".vert", "r")
	local code = {}
	while true do
		local l = f:read()
		if not l then break end
		code[#code+1] = l
	end
	f:close()
	self.verts[name] = core.shader.newShader(table.concat(code, "\n"))
	print("[SHADER] created vertex shader from /data/gfx/shaders/"..name..".vert")
	return self.verts[name]
end

function _M:createProgram(def)
	local shad = core.shader.newProgram()
	if def.vert then shad:attach(self:getVertex(def.vert)) end
	if def.frag then shad:attach(self:getFragment(def.frag)) end
	shad:compile()
	return shad
end

function _M:loaded()
	if _M.progs[self.name] then
		self.shad = _M.progs[self.name]
		print("[SHADER] using cached shader "..self.name)
	else
		print("[SHADER] Loading from /data/gfx/shaders/"..self.name..".lua")
		local f, err = loadfile("/data/gfx/shaders/"..self.name..".lua")
		if not f and err then error(err) end
		setfenv(f, setmetatable(self.args or {}, {__index=_G}))
		local def = f()
		_M.progs[self.name] = self:createProgram(def)
	end

	self.shad = _M.progs[self.name]

	for k, v in pairs(self.args) do
		if type(v) == "number" then
			self.shad:paramNumber(k, v)
		elseif type(v) == "table"
			if v.texture then
				self.shad:paramNumber(k, v.texture, v.is3d)
			end
		end
	end
end
