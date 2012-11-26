-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	data.__import_offset_x = data.__import_offset_x or 0
	data.__import_offset_y = data.__import_offset_y or 0

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
		level = self.level,
		zone = self.zone,
		data = self.data,
		Map = require("engine.Map"),
		specialList = function(kind, files)
			if kind == "terrain" then
				self.grid_list = self.zone.grid_class:loadList(files)
			elseif kind == "trap" then
				self.trap_list = self.zone.trap_class:loadList(files)
			elseif kind == "object" then
				self.object_list = self.zone.object_class:loadList(files)
			elseif kind == "actor" then
				self.npc_list = self.zone.npc_class:loadList(files)
			else
				error("kind unsupported")
			end
		end,
		subGenerator = function(g)
			self.subgen[#self.subgen+1] = g
		end,
		defineTile = function(char, grid, obj, actor, trap, status, spot)
			t[char] = {grid=grid, object=obj, actor=actor, trap=trap, status=status, define_spot=spot}
		end,
		quickEntity = function(char, e, status, spot)
			if type(e) == "table" then
				local e = self.zone.grid_class.new(e)
				t[char] = {grid=e, status=status, define_spot=spot}
			else
				t[char] = t[e]
			end
		end,
		prepareEntitiesList = function(type, class, file)
			local list = require(class):loadList(file)
			self.level:setEntitiesList(type, list, true)
		end,
		prepareEntitiesRaritiesList = function(type, class, file)
			local list = require(class):loadList(file)
			list = game.zone:computeRarities(type, list, game.level, nil)
			self.level:setEntitiesList(type, list, true)
		end,
		setStatusAll = function(s) self.status_all = s end,
		addData = function(t)
			table.merge(self.level.data, t, true)
		end,
		getMap = function(t)
			return self.map
		end,
		checkConnectivity = function(dst, src, type, subtype)
			self.spots[#self.spots+1] = {x=dst[1], y=dst[2], check_connectivity=src, type=type or "static", subtype=subtype or "static"}
		end,
		addSpot = function(dst, type, subtype, additional)
			local spot = {x=self.data.__import_offset_x+dst[1], y=self.data.__import_offset_y+dst[2], type=type or "static", subtype=subtype or "static"}
			table.update(spot, additional or {})
			self.spots[#self.spots+1] = spot
		end,
		addZone = function(dst, type, subtype, additional)
			local zone = {x1=self.data.__import_offset_x+dst[1], y1=self.data.__import_offset_y+dst[2], x2=self.data.__import_offset_x+dst[3], y2=self.data.__import_offset_y+dst[4], type=type or "static", subtype=subtype or "static"}
			table.update(zone, additional or {})
			self.level.custom_zones = self.level.custom_zones or {}
			self.level.custom_zones[#self.level.custom_zones+1] = zone
		end,
	}
	setfenv(f, setmetatable(g, {__index=_G}))
	local ret, err = f()
	if not ret and err then error(err) end
	if type(ret) == "string" then ret = ret:split("\n") end

	local m = { w=#(ret[1]), h=#ret }

	local rotate = util.getval(g.rotates or "default")
	local function populate(i, j, c)
		local ii, jj = i, j

		if rotate == "flipx" then ii, jj = m.w - i + 1, j
		elseif rotate == "flipy" then ii, jj = i, m.h - j + 1
		elseif rotate == "90" then ii, jj = j, m.w - i + 1
		elseif rotate == "180" then ii, jj = m.w - i + 1, m.h - j + 1
		elseif rotate == "270" then ii, jj = m.h - j + 1, i
		end

		m[ii] = m[ii] or {}
		m[ii][jj] = c
	end

	-- Read the map
	if type(ret[1]) == "string" then
		for j, line in ipairs(ret) do
			local i = 1
			for c in line:gmatch(".") do
				populate(i, j, c)
				i = i + 1
			end
		end
	else
		for j, line in ipairs(ret) do
			for i, c in ipairs(line) do
				populate(i, j, c)
			end
		end
	end

	m.startx = g.startx or math.floor(m.w / 2)
	m.starty = g.starty or math.floor(m.h / 2)
	m.endx = g.endx or math.floor(m.w / 2)
	m.endy = g.endy or math.floor(m.h / 2)

	if rotate == "flipx" then
		m.startx = m.w - m.startx + 1
		m.endx   = m.w - m.endx   + 1
	elseif rotate == "flipy" then
		m.starty = m.h - m.starty + 1
		m.endy   = m.h - m.endy   + 1
	elseif rotate == "90" then
		m.startx, m.starty = m.starty, m.w - m.startx + 1
		m.endx,   m.endy   = m.endy,   m.w - m.endx   + 1
		m.w, m.h = m.h, m.w
	elseif rotate == "180" then
		m.startx, m.starty = m.w - m.startx + 1, m.h - m.starty + 1
		m.endx,   m.endy   = m.w - m.endx   + 1, m.h - m.endy   + 1
	elseif rotate == "270" then
		m.startx, m.starty = m.h - m.starty + 1, m.startx
		m.endx,   m.endy   = m.h - m.endy   + 1, m.endx
		m.w, m.h = m.h, m.w
	end

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
			if g.force_clone then g = g:clone() end
			g:resolve()
			g:resolve(nil, true)
			self.map(i-1, j-1, Map.TERRAIN, g)
			g:check("addedToLevel", self.level, i-1, j-1)
			g:check("on_added", self.level, i-1, j-1)
		end

		if self.status_all then
			local s = table.clone(self.status_all)
			if s.lite then self.level.map.lites(i-1, j-1, true) s.lite = nil end
			if s.remember then self.level.map.remembers(i-1, j-1, true) s.remember = nil end
			if s.special then self.map.room_map[i-1][j-1].special = s.special s.special = nil end
			if s.room_map then for k, v in pairs(s.room_map) do self.map.room_map[i-1][j-1][k] = v end s.room_map = nil end
			if pairs(s) then for k, v in pairs(s) do self.level.map.attrs(i-1, j-1, k, v) end end
		end
	end end

	-- generate the rest after because they might need full map data to be correctly made
	for i = 1, self.gen_map.w do for j = 1, self.gen_map.h do
		local c = self.gen_map[i][j]
		local actor = self.tiles[c] and self.tiles[c].actor
		local trap = self.tiles[c] and self.tiles[c].trap
		local object = self.tiles[c] and self.tiles[c].object
		local status = self.tiles[c] and self.tiles[c].status
		local define_spot = self.tiles[c] and self.tiles[c].define_spot

		if object then
			local o, mod
			if type(object) == "string" then o = self.zone:makeEntityByName(self.level, "object", object)
			elseif type(object) == "table" and object.random_filter then mod = object.entity_mod o = self.zone:makeEntity(self.level, "object", object.random_filter, nil, true)
			else o = self.zone:finishEntity(self.level, "object", object)
			end

			if o then if mod then o = mod(o) end self:roomMapAddEntity(i-1, j-1, "object", o) end
		end

		if trap then
			local t, mod
			if type(trap) == "string" then t = self.zone:makeEntityByName(self.level, "trap", trap)
			elseif type(trap) == "table" and trap.random_filter then mod = trap.entity_mod t = self.zone:makeEntity(self.level, "trap", trap.random_filter, nil, true)
			else t = self.zone:finishEntity(self.level, "trap", trap)
			end
			if t then if mod then t = mod(t) end self:roomMapAddEntity(i-1, j-1, "trap", t) end
		end

		if actor then
			local m, mod
			if type(actor) == "string" then m = self.zone:makeEntityByName(self.level, "actor", actor)
			elseif type(actor) == "table" and actor.random_filter then mod = actor.entity_mod m = self.zone:makeEntity(self.level, "actor", actor.random_filter, nil, true)
			else m = self.zone:finishEntity(self.level, "actor", actor)
			end
			if m then if mod then m = mod(m) end self:roomMapAddEntity(i-1, j-1, "actor", m) end
		end

		if status then
			local s = table.clone(status)
			if s.lite then self.level.map.lites(i-1, j-1, true) s.lite = nil end
			if s.remember then self.level.map.remembers(i-1, j-1, true) s.remember = nil end
			if s.special then self.map.room_map[i-1][j-1].special = s.special s.special = nil end
			if s.room_map then for k, v in pairs(s.room_map) do self.map.room_map[i-1][j-1][k] = v end s.room_map = nil end
			if pairs(s) then for k, v in pairs(s) do self.level.map.attrs(i-1, j-1, k, v) end end
		end

		if define_spot then
			define_spot = table.clone(define_spot)
			assert(define_spot.type, "defineTile auto spot without type field")
			assert(define_spot.subtype, "defineTile auto spot without subtype field")
			define_spot.x = self.data.__import_offset_x+i-1
			define_spot.y = self.data.__import_offset_y+j-1
			self.spots[#self.spots+1] = define_spot
		end
	end end

	self:triggerHook{"mapGeneratorStatic:subgenRegister", mapfile=self.data.map, list=self.subgen}

	for i = 1, #self.subgen do
		local g = self.subgen[i]
		local data = g.data
		if type(data) == "string" and data == "pass" then data = self.data end

		local map = self.zone.map_class.new(g.w, g.h)
		data.__import_offset_x = self.data.__import_offset_x+g.x
		data.__import_offset_y = self.data.__import_offset_y+g.y
		local generator = require(g.generator).new(
			self.zone,
			map,
			self.level,
			data
		)
		local ux, uy, dx, dy, subspots = generator:generate(lev, old_lev)

		self.map:import(map, g.x, g.y)

		table.append(self.spots, subspots)

		if g.define_up then self.gen_map.startx, self.gen_map.starty = ux + self.data.__import_offset_x+g.x, uy + self.data.__import_offset_y+g.y end
		if g.define_down then self.gen_map.endx, self.gen_map.endy = dx + self.data.__import_offset_x+g.x, dy + self.data.__import_offset_y+g.y end
	end

	if self.gen_map.startx and self.gen_map.starty then
		self.map.room_map[self.gen_map.startx][self.gen_map.starty].special = "exit"
	end
	if self.gen_map.startx and self.gen_map.starty then
		self.map.room_map[self.gen_map.endx][self.gen_map.endy].special = "exit"
	end
	return self.gen_map.startx, self.gen_map.starty, self.gen_map.endx, self.gen_map.endy, self.spots
end
