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
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.grid_list = zone.grid_list
	self.subgen = {}
	self.spots = {}
	self.data = data

	if data.adjust_level then
		self.adjust_level = {base=zone.base_level, lev = self.level.level, min=data.adjust_level[1], max=data.adjust_level[2]}
	else
		self.adjust_level = {base=zone.base_level, lev = self.level.level, min=0, max=0}
	end

	self:loadMap(data.map)
end

function _M:loadMap(file)
	local t = {}

	print("Static generator using file", "/data/maps/"..file..".lua")
	local f, err = loadfile("/data/maps/"..file..".lua")
	if not f and err then error(err) end
	local g = {
		Map = require("engine.Map"),
		subGenerator = function(g)
			self.subgen[#self.subgen+1] = g
		end,
		defineTile = function(char, grid, obj, actor, trap, status)
			t[char] = {grid=grid, obj=obj, actor=actor, trap=trap, status=status}
		end,
		quickEntity = function(char, e)
			if type(e) == "table" then
				local e = self.zone.grid_class.new(e)
				t[char] = {grid=e}
			else
				t[char] = t[e]
			end
		end,
		prepareEntitiesList = function(type, class, file)
			local list = require(class):loadList(file)
			self.level:setEntitiesList(type, list)
		end,
		addData = function(t)
			table.merge(self.level.data, t, true)
		end,
		getMap = function(t)
			return self.map
		end,
		checkConnectivity = function(dst, src, type, subtype)
			self.spots[#self.spots+1] = {x=dst[1], y=dst[2], check_connectivity=src, type=type or "static", subtype=subtype or "static"}
		end,
		addSpot = function(dst, type, subtype)
			self.spots[#self.spots+1] = {x=dst[1], y=dst[2], type=type or "static", subtype=subtype or "static"}
		end,
	}
	setfenv(f, setmetatable(g, {__index=_G}))
	local ret, err = f()
	if not ret and err then error(err) end
	if type(ret) == "string" then ret = ret:split("\n") end

	local m = { w=ret[1]:len(), h=#ret }

	-- Read the map
	for j, line in ipairs(ret) do
		local i = 1
		for c in line:gmatch(".") do
			m[i] = m[i] or {}
			m[i][j] = c
			i = i + 1
		end
	end

	m.startx = g.startx or math.floor(m.w / 2)
	m.starty = g.starty or math.floor(m.h / 2)
	m.endx = g.endx or math.floor(m.w / 2)
	m.endy = g.endy or math.floor(m.h / 2)

	self.gen_map = m
	self.tiles = t

	self.map.w = m.w
	self.map.h = m.h
	print("[STATIC MAP] size", m.w, m.h)
end

function _M:resolve(typ, c)
	if not self.tiles[c] or not self.tiles[c][typ] then return end
	local res = self.tiles[c][typ]
	if type(res) == "function" then
		return self.grid_list[res()]
	elseif type(res) == "table" and res.__CLASSNAME then
		return res
	elseif type(res) == "table" then
		return self.grid_list[res[rng.range(1, #res)]]
	else
		return self.grid_list[res]
	end
end

function _M:generate(lev, old_lev)
	local spots = {}

	for i = 1, self.gen_map.w do for j = 1, self.gen_map.h do
		local c = self.gen_map[i][j]
		local g = self:resolve("grid", c)
		if g then
			g = g:clone()
			g:resolve()
			g:resolve(nil, true)
			self.map(i-1, j-1, Map.TERRAIN, g)
		end

		local actor = self.tiles[c] and self.tiles[c].actor
		local trap = self.tiles[c] and self.tiles[c].trap
		local object = self.tiles[c] and self.tiles[c].object
		local status = self.tiles[c] and self.tiles[c].status

		if object then
			local o = type(object) == "string" and self.zone:makeEntityByName(self.level, "object", object) or self.zone:finishEntity(self.level, "object", object)
			if o then
				self.zone:addEntity(self.level, o, "object", i-1, j-1)
			end
		end

		if trap then
			local t = type(trap) == "string" and self.zone:makeEntityByName(self.level, "trap", trap) or self.zone:finishEntity(self.level, "trap", trap)
			if t then
				self.zone:addEntity(self.level, t, "trap", i-1, j-1)
			end
		end

		if actor then
			local m
			if type(actor) == "string" then
				m = self.zone:makeEntityByName(self.level, "actor", actor)
			else
				m = self.zone:finishEntity(self.level, "actor", actor)
			end
			if m then
				self.zone:addEntity(self.level, m, "actor", i-1, j-1)
			end
		end

		if status then
			if status.lite then self.level.map.lites(i-1, j-1, true) end
			if status.remember then self.level.map.remembers(i-1, j-1, true) end
		end
	end end

	for i = 1, #self.subgen do
		local g = self.subgen[i]
		local data = g.data
		if type(data) == "string" and data == "pass" then data = self.data end

		local map = self.zone.map_class.new(g.w, g.h)
		local generator = require(g.generator).new(
			self.zone,
			map,
			self.level,
			data
		)
		local ux, uy, dx, dy, subspots = generator:generate(lev, old_lev)

		self.map:import(map, g.x, g.y)
		map:close()

		table.append(self.spots, subspots)

		if g.define_up then self.gen_map.startx, self.gen_map.starty = ux + g.x, uy + g.y end
		if g.define_down then self.gen_map.endx, self.gen_map.endy = dx + g.x, dy + g.y end
	end

	if self.gen_map.startx and self.gen_map.starty then
		self.map.room_map[self.gen_map.startx][self.gen_map.starty].special = "exit"
	end
	if self.gen_map.startx and self.gen_map.starty then
		self.map.room_map[self.gen_map.endx][self.gen_map.endy].special = "exit"
	end
	return self.gen_map.startx, self.gen_map.starty, self.gen_map.endx, self.gen_map.endy, self.spots
end
