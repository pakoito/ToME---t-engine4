-- TE4 - T-Engine 4
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
local RoomsLoader = require "engine.generator.map.RoomsLoader"
local Astar = require"engine.Astar"
local DirectPath = require"engine.DirectPath"
module(..., package.seeall, class.inherit(engine.Generator, RoomsLoader))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.data = data
	self.grid_list = self.zone.grid_list
	self.noise = data.noise or "fbm_perlin"
	self.zoom = data.zoom or 5
	self.max_percent = data.max_percent or 80
	self.sqrt_percent = data.sqrt_percent or 30
	self.sqrt_percent2 = data.sqrt_percent2
	self.hurst = data.hurst or nil
	self.lacunarity = data.lacunarity or nil
	self.octave = data.octave or 4
	self.nb_spots = data.nb_spots or 10
	self.do_ponds = data.do_ponds

	self.add_road = data.add_road or false
	self.end_road = data.end_road or false
	self.end_road_room = data.end_road_room

	if self.do_ponds then
		self.do_ponds.zoom = self.do_ponds.zoom or 5
		self.do_ponds.octave = self.do_ponds.octave or 5
		self.do_ponds.hurst = self.do_ponds.hurst or nil
		self.do_ponds.lacunarity = self.do_ponds.lacunarity or nil
	end

	RoomsLoader.init(self, data)
end

function _M:addPond(x, y, spots)
	local noise = core.noise.new(2, self.do_ponds.size.w, self.do_ponds.size.h)
	local nmap = {}
	local pmap = {}
	local lowest = {v=100, x=nil, y=nil}
	for i = 1, self.do_ponds.size.w do
		nmap[i] = {}
		pmap[i] = {}
		for j = 1, self.do_ponds.size.h do
			nmap[i][j] = noise:fbm_simplex(self.do_ponds.zoom * i / self.do_ponds.size.w, self.do_ponds.zoom * j / self.do_ponds.size.h, self.do_ponds.octave)
			if nmap[i][j] < lowest.v then lowest.v = nmap[i][j]; lowest.x = i; lowest.y = j end
		end
	end
--	print("Lowest pond point", lowest.x, lowest.y," ::", lowest.v)

	local quadrant = function(i, j)
		local highest = {v=-100, x=nil, y=nil}
		local l = line.new(lowest.x, lowest.y, i, j)
		local lx, ly = l()
		while lx do
--			print(lx, ly, nmap[lx][ly])
			if nmap[lx] and nmap[lx][ly] and nmap[lx][ly] > highest.v then highest.v = nmap[lx][ly]; highest.x = lx; highest.y = ly end
			lx, ly = l()
		end
--		print("Highest pond point", highest.x, highest.y," ::", highest.v)
		local split = (highest.v + lowest.v)

		local l = line.new(lowest.x, lowest.y, i, j)
		local lx, ly = l()
		while lx do
			local stop = true
			for _ = 1, #self.do_ponds.pond do
				if nmap[lx] and nmap[lx][ly] and nmap[lx][ly] < split * self.do_ponds.pond[_][1] then
					pmap[lx][ly] = self.do_ponds.pond[_][2]
					stop = false
					break
				end
			end
			if stop then break end
			lx, ly = l()
		end
	end
	for i = 1, self.do_ponds.size.w do
		quadrant(i, 1)
		quadrant(i, self.do_ponds.size.h)
	end
	for i = 1, self.do_ponds.size.h do
		quadrant(1, i)
		quadrant(self.do_ponds.size.w, i)
	end

	-- Smooth the pond
	for i = 1, self.do_ponds.size.w do for j = 1, self.do_ponds.size.h do
		local g1 = pmap[i-1] and pmap[i-1][j+1]
		local g2 = pmap[i] and pmap[i][j+1]
		local g3 = pmap[i+1] and pmap[i+1][j+1]
		local g4 = pmap[i-1] and pmap[i-1][j]
		local g6 = pmap[i+1] and pmap[i+1][j]
		local g7 = pmap[i-1] and pmap[i-1][j-1]
		local g8 = pmap[i] and pmap[i][j-1]
		local g9 = pmap[i+1] and pmap[i+1][j-1]
		local nb = (g1 and 1 or 0) + (g2 and 1 or 0) + (g3 and 1 or 0) + (g4 and 1 or 0) + (g6 and 1 or 0) + (g7 and 1 or 0) + (g8 and 1 or 0) + (g9 and 1 or 0)

		if nb < 4 then pmap[i][j] = nil end
	end end

	-- Draw the pond
	for i = 1, self.do_ponds.size.w do
		for j = 1, self.do_ponds.size.h do
			if pmap[i][j] then
				self.map(i-1+x, j-1+y, Map.TERRAIN, self:resolve(pmap[i][j], self.grid_list, true))
				if self.map.room_map[i-1+x] and self.map.room_map[i-1+x][j-1+y] then
					self.map.room_map[i-1+x][j-1+y].special = "pond"
				end
			end
		end
	end

	spots[#spots+1] = {x=x, y=y, type="pond", subtype="pond"}
end

function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self:resolve("floor"))
	end end

	-- make the noise
	local possible_spots = {}
	local noise = core.noise.new(2, self.hurst, self.lacunarity)
	for i = 1, self.map.w do
		for j = 1, self.map.h do
			local v = math.floor((noise[self.noise](noise, self.zoom * i / self.map.w, self.zoom * j / self.map.h, self.octave) / 2 + 0.5) * self.max_percent)
			if (v >= self.sqrt_percent and rng.percent(v)) or (v < self.sqrt_percent and rng.percent(math.sqrt(v))) then
				self.map(i-1, j-1, Map.TERRAIN, self:resolve("wall"))
			else
				if not self.sqrt_percent2 then
					self.map(i-1, j-1, Map.TERRAIN, self:resolve("floor"))
				else
					if (v >= self.sqrt_percent2) then
						self.map(i-1, j-1, Map.TERRAIN, self:resolve("floor2"))
					else
						self.map(i-1, j-1, Map.TERRAIN, self:resolve("floor"))
					end
				end

				if v >= self.sqrt_percent then possible_spots[#possible_spots+1] = {x=i-1, y=j-1, type="clearing", subtype="clearing"} end
			end
		end
	end

	local spots = {}
	local waypoints = {}
	self.spots = spots

	-- Add some spots
	for i = 1, self.nb_spots do
		local s = rng.tableRemove(possible_spots)
		if s then
			self.spots[#self.spots+1] = s
		end
	end

	if self.do_ponds then
		for i = 1, rng.range(self.do_ponds.nb[1], self.do_ponds.nb[2]) do
			self:addPond(rng.range(self.do_ponds.size.w, self.map.w - self.do_ponds.size.w), rng.range(self.do_ponds.size.h, self.map.h - self.do_ponds.size.h), spots)
		end
	end


	local nb_room = util.getval(self.data.nb_rooms or 0)
	local rooms = {}
	local end_room
	local axis = "x"
	local direction = 1
	local ending

	-- get the axis and direction
	if self.data.edge_entrances then
		if self.data.edge_entrances[1] == 2 or self.data.edge_entrances[1] == 8 then axis = "y"
		else axis = "x"
		end

		if self.data.edge_entrances[1] == 2 or self.data.edge_entrances[1] == 4 then direction = 1
		else direction = -1
		end
	end

	-- Add the "requested" end room first (must be at least 66% into the level)
	print("End Room:",self.end_road_room)
	if self.end_road_room then
		print("Trying to load",self.end_road_room)
		local rroom, end_room_load
		end_room_load = self:loadRoom(self.end_road_room)

		local r = self:roomAlloc(end_room_load, #rooms+1, lev, old_lev, function(room, x, y)
			local far_enough = false
			if     axis == "x" and direction == 1 then
				far_enough = x >= self.map.w*0.66
			elseif axis == "x" and direction == -1 then
				far_enough = x <= self.map.w*0.33
			elseif axis == "y" and direction == 1 then
				far_enough = y >= self.map.h*0.66
			elseif axis == "y" and direction == -1 then
				far_enough = y <= self.map.h*0.33
			end
			return far_enough
		end)
		if r then
			rooms[#rooms+1] = r
			end_room = r
			print("Successfully loaded the end room")
		end
	end

	while nb_room > 0 do
		local rroom
		while true do
			rroom = self.rooms[rng.range(1, #self.rooms)]
			if type(rroom) == "table" and rroom.chance_room then
				if rng.percent(rroom.chance_room) then rroom = rroom[1] break end
			else
				break
			end
		end

		local r = self:roomAlloc(rroom, #rooms+1, lev, old_lev)
		if r then rooms[#rooms+1] = r end
		nb_room = nb_room - 1
	end

	local ux, uy, dx, dy
	if self.data.edge_entrances then
		ux, uy, dx, dy, spots = self:makeStairsSides(lev, old_lev, self.data.edge_entrances, spots)
	else
		ux, uy, dx, dy, spots = self:makeStairsInside(lev, old_lev, spots)
	end

	-- Create a road between the stairs via "waypoints" on the map
	-- The rule is that no waypoint may further away (in terms of the directional axis) than the previous point
	if self.add_road then
		if self.end_road then
			ending = true
		else
			ending = false
		end

		-- Add the up stairs as waypoint 1
		if #waypoints > 0 then
			table.insert(waypoints,1,{x=ux,y=uy})
		else
			waypoints[#waypoints+1] = {x=ux,y=uy}
		end

		-- Get 30 random locations
		local possible_waypoints = {}
		for i = 1, 30 do
			local x = rng.range(0,self.map.w-1)
			local y = rng.range(0,self.map.h-1)
			possible_waypoints[i] = {x=x,y=y}
			--print("Possible waypoint",i,x,y)
		end

		-- sort all the spots in order of upstairs to downstairs
		local start, finish
		if     self.data.edge_entrances[1] == 2 then
			start = 0
			finish = self.map.h
			table.sort(possible_waypoints,function(a, b) return b.y > a.y end)
		elseif self.data.edge_entrances[1] == 4 then
			start = 0
			finish = self.map.w
			table.sort(possible_waypoints,function(a, b) return b.x > a.x end)
		elseif self.data.edge_entrances[1] == 6 then
			start = self.map.w
			finish = 0
			table.sort(possible_waypoints,function(a, b) return b.x < a.x end)
		elseif self.data.edge_entrances[1] == 8 then
			start = self.map.h
			finish = 0
			table.sort(possible_waypoints,function(a, b) return b.y < a.y end)
		end

		-- for i = 1, #possible_waypoints do
			-- spot = possible_waypoints[i]
			-- print("Possible waypoint",i,spot.x,spot.y)
		-- end

		print("Axis : ", axis, " from ", start," to ", finish)

		if ending and end_room then
			if axis == "x" then finish = end_room.x
			else finish = end_room.y
			end
		end

		for i = 1, #possible_waypoints do
			local s = possible_waypoints[i]
			print ("Possible waypoint",i,s.x,s.y)
			reason = self:checkValid(s,waypoints[#waypoints],axis,start,finish)
			if not self.map.room_map[s.x][s.y].special and reason == true then
				waypoints[#waypoints+1] = {x=s.x,y=s.y}
				print("Waypoint",i,s.x,s.y,"accepted")
			else
				print("Waypoint",i,s.x,s.y,"rejected: ",reason)
			end
		end

		-- if the downstairs exist, and the road's not ending here, add the downstairs
		if dx and not ending then
			waypoints[#waypoints+1] = {x=dx,y=dy}
		end

		if ending and self.end_road_room then
			waypoints[#waypoints+1] = {x=end_room.x,y=end_room.y}
		end

		--print("Amount of waypoints in road are: ", #waypoints)
		local i = 2
		while i <= #waypoints do
			print("tunnel waypoint ",i-1," from ", waypoints[i-1].x, waypoints[i-1].y, " to ", waypoints[i].x,waypoints[i].y)
			self:makeRoad(waypoints[i-1].x,waypoints[i-1].y,waypoints[i].x,waypoints[i].y,id,"road")
			i = i + 1
		end
	end

	return ux, uy, dx, dy, spots
end

function _M:makeRoad(x1,y1,x2,y2,id,terrain)
	local a = Astar.new(self.map, game:getPlayer())
	local recheck = false

	path = a:calc(x1, y1, x2, y2, true, nil,
		function(x, y)
			if game.level.map:checkEntity(x, y, Map.TERRAIN, "air_level") then
				return false
			else
				return true
			end
		end,
		true)
	--No Astar path ? just be dumb and try direct line
	if not path then
		local d = DirectPath.new(game.level.map, game:getPlayer())
		path = d:calc(x1, y1, x2, y2, false)
		print("A* couldn't find road to ",x2,y2,"from",x1,x2)
	end
	-- convert path to tunnel
	for i, pathnode in ipairs(path) do
		if not self.map.room_map[pathnode.x][pathnode.y].special then
			self.map(pathnode.x, pathnode.y, Map.TERRAIN, self:resolve(terrain))
		end
	end
end

function _M:checkValid(spot, lastspot, axis, start, finish)
	-- Get the axis
	local mindistance = 2
	--math.floor((start+finish)*0.07)
	local progress, measure, invert_measure,invert_progress, measure = 0,0,0,0
	if axis == "x" then
		progress = lastspot.x
		measure = spot.x
		invert_measure = spot.y
		invert_progress = lastspot.y
	else
		progress = lastspot.y
		measure = spot.y
		invert_measure = spot.x
		invert_progress = lastspot.x
	end

	-- Get the direction
	if finish < start then
		progess = progress * -1
		measure = measure * -1
		finish = finish * -1
		mindistance = mindistance * -1
	end

	-- every next one must be at least X squares closer to the end, and not closer than 2*X to the end,
	-- and on the other axis may not be further than 20% of the distance of the map away
	if not (measure > progress+mindistance) then
		return "not enough progress from previous waypoint"
	end
	if not (measure < finish-mindistance*2) then
		return "measure too close to finish"
	end
	if not (math.abs(invert_progress - invert_measure) < math.abs(start-finish)*0.2) then
		return "on non-progress axis, the measure was more than 20% different from previous"
	end

	return
		measure > progress+mindistance and
		measure < finish-mindistance*2 and
		math.abs(invert_progress - invert_measure) < math.abs(start-finish)*0.2
end

--- Create the stairs inside the level
function _M:makeStairsInside(lev, old_lev, spots)
	-- Put down stairs
	local dx, dy
	if lev < self.zone.max_level or self.data.force_last_stair then
		while true do
			dx, dy = rng.range(1, self.map.w - 1), rng.range(1, self.map.h - 1)
			if not self.map:checkEntity(dx, dy, Map.TERRAIN, "block_move") and not self.map.room_map[dx][dy].special then
				self.map(dx, dy, Map.TERRAIN, self:resolve("down"))
				self.map.room_map[dx][dy].special = "exit"
				break
			end
		end
	end

	-- Put up stairs
	local ux, uy
	while true do
		ux, uy = rng.range(1, self.map.w - 1), rng.range(1, self.map.h - 1)
		if not self.map:checkEntity(ux, uy, Map.TERRAIN, "block_move") and not self.map.room_map[ux][uy].special then
			self.map(ux, uy, Map.TERRAIN, self:resolve("up"))
			self.map.room_map[ux][uy].special = "exit"
			break
		end
	end

	return ux, uy, dx, dy, spots
end

--- Create the stairs on the sides
function _M:makeStairsSides(lev, old_lev, sides, spots)
	-- Put down stairs
	local dx, dy
	if lev < self.zone.max_level or self.data.force_last_stair then
		while true do
			if     sides[2] == 4 then dx, dy = 0, rng.range(0, self.map.h - 1)
			elseif sides[2] == 6 then dx, dy = self.map.w - 1, rng.range(0, self.map.h - 1)
			elseif sides[2] == 8 then dx, dy = rng.range(0, self.map.w - 1), 0
			elseif sides[2] == 2 then dx, dy = rng.range(0, self.map.w - 1), self.map.h - 1
			end

			if not self.map.room_map[dx][dy].special then
				self.map(dx, dy, Map.TERRAIN, self:resolve("down"))
				self.map.room_map[dx][dy].special = "exit"
				break
			end
		end
	end

	-- Put up stairs
	local ux, uy
	while true do
		if     sides[1] == 4 then ux, uy = 0, rng.range(0, self.map.h - 1)
		elseif sides[1] == 6 then ux, uy = self.map.w - 1, rng.range(0, self.map.h - 1)
		elseif sides[1] == 8 then ux, uy = rng.range(0, self.map.w - 1), 0
		elseif sides[1] == 2 then ux, uy = rng.range(0, self.map.w - 1), self.map.h - 1
		end

		if not self.map.room_map[ux][uy].special then
			self.map(ux, uy, Map.TERRAIN, self:resolve("up"))
			self.map.room_map[ux][uy].special = "exit"
			break
		end
	end

	return ux, uy, dx, dy, spots
end

