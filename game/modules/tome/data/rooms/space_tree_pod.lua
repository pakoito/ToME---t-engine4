-- ToME - Tales of Maj'Eyal
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

local function check_borders(room_map, x, y, id)
	local nb = 0
	local own = false
	for i = -1, 1 do for j = -1, 1 do
		if room_map[x+i] and room_map[x+i][y+j] and room_map[x+i][y+j].room == id then
			nb = nb + 1
			if i == 0 and j == 0 then own = true end
		end
	end end
	return nb, own
end

return function(gen, id)
	local rad = rng.range(2, 4)
	local mw = 10
	local mh = 10

	if type(gen.level.data.first_pod) == "nil" then gen.level.data.first_pod = true end

	local is_first = false
	if gen.level.data.first_pod then
		gen.level.data.first_pod = false
		is_first = true
		mw = 16
		mh = 16
		rad = 8
	end

	local w = rad * 2
	local h = rad * 2
	gen.level.pods = gen.level.pods or {}
	local function make_pod(self, x, y, is_lit)
		gen:makePod(x + rad + 1, y + rad + 1, rad, id, {noise="fbm_perlin", zoom=5, base_breakpoint=0.4, octave=4})
		local pod = {}
		local wormholes = {}
		for i = x, x + mw do
			for j = y, y + mh do
				local nb, own = check_borders(gen.map.room_map, i, j, id)
				if nb > 0 then pod[#pod+1] = {x=i-x, y=j-y} end
				if nb >= 4 and own and rng.percent(10) then
					gen.map(i, j, Map.TERRAIN, gen:resolve('T'))
				end
				if is_first and nb >= 5 and own then wormholes[#wormholes+1] = {i,j} end
			end
		end
		if is_first then
			if #wormholes >= 1 then
				local g = rng.table(wormholes)
				gen.map(g[1], g[2], Map.TERRAIN, gen:resolve('wormhole'))
			else
				gen.map(x, y, Map.TERRAIN, gen:resolve('wormhole'))
			end
		end

		gen.level.pods[#(gen.level.pods)+1] = {x1=x, x2=x+mw, y1=y, y2=y+mh, w=mw, h=mh, pod=pod, dir=rng.table{2,4,6,8}}
		print(table.serialize(pod,nil,true))
	end

	return { name="space_tree_prod"..w.."x"..h, w=mw, h=mh, generator = make_pod}
end
