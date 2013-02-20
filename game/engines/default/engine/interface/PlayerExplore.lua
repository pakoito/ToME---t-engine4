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

--- This file implements a simple auto-explore whereby a single command can explore unseen tiles and objects.
-- To see how a module can make auto-explore more robust, see "game/modules/tome/class/interface/PlayerExplore.lua"
--
-- Note that the floodfill algorithm in this file assumes that the movement costs for all grids are equal

require "engine.class"
local Map = require "engine.Map"
local Dialog = require "engine.ui.Dialog"

module(..., package.seeall, class.make)

local function toSingle(x, y)
	return x + y * game.level.map.w
end

local function toDouble(c)
	local y = math.floor(c / game.level.map.w)
	return c - y * game.level.map.w, y
end

local function listAdjacentTiles(node, no_diagonal, no_cardinal)
	local tiles = {}
	local x, y, c
	if type(node) == "table" then
		x, y, c = unpack(node)
	elseif type(node) == "number" then
		x, y = toDouble(node)
		c = node
	else
		return tiles
	end

	local left_okay = x > 0
	local right_okay = x < game.level.map.w - 1
	local lower_okay = y > 0
	local upper_okay = y < game.level.map.h - 1

	if not no_cardinal then
		if upper_okay then tiles[1]        = {x,     y + 1, c + game.level.map.w, 2 } end
		if left_okay  then tiles[#tiles+1] = {x - 1, y,     c - 1,                4 } end
		if right_okay then tiles[#tiles+1] = {x + 1, y,     c + 1,                6 } end
		if lower_okay then tiles[#tiles+1] = {x,     y - 1, c - game.level.map.w, 8 } end
	end
	if not no_diagonal then
		if left_okay  and upper_okay then tiles[#tiles+1] = {x - 1, y + 1, c - 1 + game.level.map.w, 1 } end
		if right_okay and upper_okay then tiles[#tiles+1] = {x + 1, y + 1, c + 1 + game.level.map.w, 3 } end
		if left_okay  and lower_okay then tiles[#tiles+1] = {x - 1, y - 1, c - 1 - game.level.map.w, 7 } end
		if right_okay and lower_okay then tiles[#tiles+1] = {x + 1, y - 1, c + 1 - game.level.map.w, 9 } end
	end
	return tiles
end

-- Performing a flood-fill algorithm in lua with robust logic is going to be relatively slow, so we
-- need to make things more efficient wherever we can.  "adjacentTiles" below is an example of this.
-- Every node knows from which direction it was explored, and it only explores adjacent tiles that
-- may not have previously been explored.  Nodes that were explored from a cardinal direction only
-- have three new adjacent tiles to iterate over, and diagonal directions have five new tiles.
-- Therefore, we should favor cardinal direction tile propagation for speed whenever possible.
local adjacentTiles = {
	-- Dir 1
	function(node, cardinal_tiles, diagonal_tiles)
		local x, y, c = unpack(node)

		if y < game.level.map.h - 1 then
			cardinal_tiles[#cardinal_tiles+1]         = {x,     y + 1, c     + game.level.map.w, 2 }
			diagonal_tiles[#diagonal_tiles+1]         = {x + 1, y + 1, c + 1 + game.level.map.w, 3 }
			if x > 0 then
				diagonal_tiles[#diagonal_tiles+1] = {x - 1, y + 1, c - 1 + game.level.map.w, 1 }
				cardinal_tiles[#cardinal_tiles+1] = {x - 1, y,     c - 1,                    4 }
				diagonal_tiles[#diagonal_tiles+1] = {x - 1, y - 1, c - 1 - game.level.map.w, 7 }
			end
		elseif x > 0 then
			cardinal_tiles[#cardinal_tiles+1]         = {x - 1, y,     c - 1,                    4 }
			diagonal_tiles[#diagonal_tiles+1]         = {x - 1, y - 1, c - 1 - game.level.map.w, 7 }
		end
	end,
	--Dir 2
	function(node, cardinal_tiles, diagonal_tiles)
		local x, y, c = unpack(node)
		if y > game.level.map.h - 2 then return end

		if x > 0 then diagonal_tiles[#diagonal_tiles+1]                    = {x - 1, y + 1, c - 1 + game.level.map.w, 1 } end
		cardinal_tiles[#cardinal_tiles+1]                                  = {x,     y + 1, c     + game.level.map.w, 2 }
		if x < game.level.map.w - 1 then diagonal_tiles[#diagonal_tiles+1] = {x + 1, y + 1, c + 1 + game.level.map.w, 3 } end
	end,
	-- Dir 3
	function(node, cardinal_tiles, diagonal_tiles)
		local x, y, c = unpack(node)

		if y < game.level.map.h - 1 then
			diagonal_tiles[#diagonal_tiles+1]         = {x - 1, y + 1, c - 1 + game.level.map.w, 1 }
			cardinal_tiles[#cardinal_tiles+1]         = {x,     y + 1, c     + game.level.map.w, 2 }
			if x < game.level.map.w - 1 then
				diagonal_tiles[#diagonal_tiles+1] = {x + 1, y + 1, c + 1 + game.level.map.w, 3 }
				cardinal_tiles[#cardinal_tiles+1] = {x + 1, y,     c + 1,                    6 }
				diagonal_tiles[#diagonal_tiles+1] = {x + 1, y - 1, c + 1 - game.level.map.w, 9 }
			end
		elseif x < game.level.map.w - 1 then
			cardinal_tiles[#cardinal_tiles+1]         = {x + 1, y,     c + 1,                    6 }
			diagonal_tiles[#diagonal_tiles+1]         = {x + 1, y - 1, c + 1 - game.level.map.w, 9 }
		end
	end,
	--Dir 4
	function(node, cardinal_tiles, diagonal_tiles)
		local x, y, c = unpack(node)
		if x < 1 then return end

		if y < game.level.map.h - 1 then diagonal_tiles[#diagonal_tiles+1] = {x - 1, y + 1, c - 1 + game.level.map.w, 1 } end
		cardinal_tiles[#cardinal_tiles+1]                                  = {x - 1, y,     c - 1,                    4 }
		if y > 0 then diagonal_tiles[#diagonal_tiles+1]                    = {x - 1, y - 1, c - 1 - game.level.map.w, 7 } end
	end,
	--Dir 5 (all adjacent, slow)
	function(node, cardinal_tiles, diagonal_tiles)
		local x, y, c = unpack(node)
	
		local left_okay = x > 0
		local right_okay = x < game.level.map.w - 1
		local lower_okay = y > 0
		local upper_okay = y < game.level.map.h - 1
	
		if upper_okay then cardinal_tiles[#cardinal_tiles+1] = {x,     y + 1, c + game.level.map.w, 2 } end
		if left_okay  then cardinal_tiles[#cardinal_tiles+1] = {x - 1, y,     c - 1,                4 } end
		if right_okay then cardinal_tiles[#cardinal_tiles+1] = {x + 1, y,     c + 1,                6 } end
		if lower_okay then cardinal_tiles[#cardinal_tiles+1] = {x,     y - 1, c - game.level.map.w, 8 } end

		if left_okay  and upper_okay then diagonal_tiles[#diagonal_tiles+1] = {x - 1, y + 1, c - 1 + game.level.map.w, 1 } end
		if right_okay and upper_okay then diagonal_tiles[#diagonal_tiles+1] = {x + 1, y + 1, c + 1 + game.level.map.w, 3 } end
		if left_okay  and lower_okay then diagonal_tiles[#diagonal_tiles+1] = {x - 1, y - 1, c - 1 - game.level.map.w, 7 } end
		if right_okay and lower_okay then diagonal_tiles[#diagonal_tiles+1] = {x + 1, y - 1, c + 1 - game.level.map.w, 9 } end
	end,
	--Dir 6
	function(node, cardinal_tiles, diagonal_tiles)
		local x, y, c = unpack(node)
		if x > game.level.map.w - 2 then return end

		if y < game.level.map.h - 1 then diagonal_tiles[#diagonal_tiles+1] = {x + 1, y + 1, c + 1 + game.level.map.w, 3 } end
		cardinal_tiles[#cardinal_tiles+1]                                  = {x + 1, y,     c + 1,                    6 }
		if y > 0 then diagonal_tiles[#diagonal_tiles+1]                    = {x + 1, y - 1, c + 1 - game.level.map.w, 9 } end
	end,
	-- Dir 7
	function(node, cardinal_tiles, diagonal_tiles)
		local x, y, c = unpack(node)

		if x > 0 then
			diagonal_tiles[#diagonal_tiles+1]         = {x - 1, y + 1, c - 1 + game.level.map.w, 1 }
			cardinal_tiles[#cardinal_tiles+1]         = {x - 1, y,     c - 1,                    4 }
			if y > 0 then
				diagonal_tiles[#diagonal_tiles+1] = {x - 1, y - 1, c - 1 - game.level.map.w, 7 }
				cardinal_tiles[#cardinal_tiles+1] = {x,     y - 1, c     - game.level.map.w, 8 }
				diagonal_tiles[#diagonal_tiles+1] = {x + 1, y - 1, c + 1 - game.level.map.w, 9 }
			end
		elseif y > 0 then
			cardinal_tiles[#cardinal_tiles+1]         = {x,     y - 1, c     - game.level.map.w, 8 }
			diagonal_tiles[#diagonal_tiles+1]         = {x + 1, y - 1, c + 1 - game.level.map.w, 9 }
		end
	end,
	--Dir 8
	function(node, cardinal_tiles, diagonal_tiles)
		local x, y, c = unpack(node)
		if y < 1 then return end

		if x > 0 then diagonal_tiles[#diagonal_tiles+1]                    = {x - 1, y - 1, c - 1 - game.level.map.w, 7 } end
		cardinal_tiles[#cardinal_tiles+1]                                  = {x,     y - 1, c     - game.level.map.w, 8 }
		if x < game.level.map.w - 1 then diagonal_tiles[#diagonal_tiles+1] = {x + 1, y - 1, c + 1 - game.level.map.w, 9 } end
	end,
	-- Dir 9
	function(node, cardinal_tiles, diagonal_tiles)
		local x, y, c = unpack(node)

		if x < game.level.map.w - 1 then
			diagonal_tiles[#diagonal_tiles+1]         = {x + 1, y + 1, c + 1 + game.level.map.w, 3 }
			cardinal_tiles[#cardinal_tiles+1]         = {x + 1, y,     c + 1,                    6 }
			if y > 0 then
				diagonal_tiles[#diagonal_tiles+1] = {x - 1, y - 1, c - 1 - game.level.map.w, 7 }
				cardinal_tiles[#cardinal_tiles+1] = {x,     y - 1, c     - game.level.map.w, 8 }
				diagonal_tiles[#diagonal_tiles+1] = {x + 1, y - 1, c + 1 - game.level.map.w, 9 }
			end
		elseif y > 0 then
			diagonal_tiles[#diagonal_tiles+1]         = {x - 1, y - 1, c - 1 - game.level.map.w, 7 }
			cardinal_tiles[#cardinal_tiles+1]         = {x,     y - 1, c     - game.level.map.w, 8 }
		end
	end
}

function _M:autoExplore()
	local node = { self.x, self.y, toSingle(self.x, self.y), 5 }
	local current_tiles = { node }
	local unseen_tiles = {}
	local unseen_singlets = {}
	local unseen_items = {}
	local exits = {}
	local values = {}
	values[node[3]] = 0
	local iter = 1
	local running = true
	local minval = 999999999999999
	local minval_items = 999999999999999
	local val, _, anode, tile_list

	-- a few tunable parameters
	local extra_iters = 5     -- number of extra iterations to do after we found an item or unseen tile
	local singlet_greed = 5   -- number of additional moves we're willing to do to explore a single unseen tile
	local item_greed = 5      -- number of additional moves we're willing to do to visit an unseen item rather than an unseen tile

	-- Create a distance map array via flood-fill to locate unseen tiles and unvisited items
	while running do
		-- construct lists of adjacent tiles to iterate over, and iterate in cardinal directions first
		local current_tiles_next = {}
		local cardinal_tiles = {}
		local diagonal_tiles = {}
		for _, node in ipairs(current_tiles) do
			adjacentTiles[node[4]](node, cardinal_tiles, diagonal_tiles)
		end

		for _, tile_list in ipairs({cardinal_tiles, diagonal_tiles}) do
			for _, node in ipairs(tile_list) do
				local x, y, c = unpack(node)

				if not values[c] then
					if not game.level.map.has_seens(x, y) then
						unseen_tiles[#unseen_tiles + 1] = c
						values[c] = iter
						if iter < minval then
							minval = iter
						end
						-- Try to not abandon lone unseen tiles
						local is_singlet = true
						for _, anode in ipairs(listAdjacentTiles(node)) do
							if not game.level.map.has_seens(anode[1], anode[2]) then
								is_singlet = false
								break
							end
						end
						if is_singlet then
							unseen_singlets[#unseen_singlets + 1] = c
						end
					else
						-- propagate "current_tiles" for next iteration
						local trap = game.level.map(x, y, Map.TRAP)
						if not (game.level.map:checkAllEntities(x, y, "block_move", self) or trap and trap:knownBy(self)) then
							values[c] = iter
							current_tiles_next[#current_tiles_next + 1] = node
						end
						-- only go to objects we haven't walked over yet
						local obj = game.level.map:getObject(x, y, 1)
						if obj and not game.level.map.attrs(x, y, "obj_seen") then
							unseen_items[#unseen_items + 1] = c
							values[c] = iter
							if iter < minval_items then
								minval_items = iter
							end
						end
					end
				end
			end
		end
		-- Continue the loop if we haven't found any destination tiles
		running = #unseen_tiles == 0 and #unseen_items == 0
		-- performing a few extra iteration will help us find items and "singlets"
		if not running and extra_iters > 0 then
			running = true
			extra_iters = extra_iters - 1
		end

		-- stop the loop if there are no more tiles to iterate over
		running = running and #current_tiles_next > 0
		current_tiles = current_tiles_next

		iter = iter + 1
	end

	-- Choose target
	if #unseen_tiles > 0 or #unseen_items > 0 then
		local target_type
		local choices = {}
		local distances = {}
		local mindist = 999999999999999
		-- try to explore cleanly--don't leave single unseen tiles by themselves
		for _, c in ipairs(unseen_singlets) do
			if values[c] <= minval + singlet_greed then
				target_type = "unseen"
				choices[#choices + 1] = c
				local x, y = toDouble(c)
				local dist = core.fov.distance(self.x, self.y, x, y, true)
				distances[c] = dist
				if dist < mindist then
					mindist = dist
				end
			end
		end
		-- go to closest items first
		if #choices == 0 and minval_items <= minval + item_greed then
			for _, c in ipairs(unseen_items) do
				if values[c] == minval_items then
					target_type = "item"
					choices[#choices + 1] = c
					local x, y = toDouble(c)
					local dist = core.fov.distance(self.x, self.y, x, y, true)
					distances[c] = dist
					if dist < mindist then
						mindist = dist
					end
				end
			end
		end
		-- if no nearby items, go to nearest unseen tile
		if #choices == 0 then
			for _, c in ipairs(unseen_tiles) do
				if values[c] == minval then
					target_type = "unseen"
					choices[#choices + 1] = c
					local x, y = toDouble(c)
					local dist = core.fov.distance(self.x, self.y, x, y, true)
					distances[c] = dist
					if dist < mindist then
						mindist = dist
					end
				end
			end
		end

		-- if multiple choices, then choose nearest one based on fov distance metric
		if #choices > 1 then
			local choices2 = {}
			for _, c in ipairs(choices) do
				if distances[c] == mindist then
					choices2[#choices2 + 1] = c
				end
			end
			choices = choices2
		end
		-- if still multiple choices, then choose one randomly
		local target = #choices > 0 and rng.table(choices) or nil

		-- Now create the path to the target (constructed from target to source)
		if target then
			local target_x, target_y = toDouble(target)
			local x, y = toDouble(target)
			local path = {{x=x, y=y}}
			local current_val = values[target]
			-- the idiot check condition should NEVER occur, but, well, if it does, it'll save us from being stuck in an infinite loop
			local idiot_counter = 0
			local idiot_check = current_val + 5
			while (path[#path].x ~= self.x or path[#path].y ~= self.y) and idiot_counter <= idiot_check do
				idiot_counter = idiot_counter + 1
				-- perform a greedy minimization that prefers cardinal directions
				local cardinals = {}
				local min_cardinal = current_val
				for _, node in ipairs(listAdjacentTiles(target, true)) do
					local c = node[3]
					if values[c] and values[c] <= min_cardinal then
						min_cardinal = values[c]
						cardinals[#cardinals + 1] = node
					end
				end
				local diagonals = {}
				local min_diagonal = current_val
				for _, node in ipairs(listAdjacentTiles(target, false, true)) do
					local c = node[3]
					if values[c] and values[c] < min_diagonal then
						min_diagonal = values[c]
						diagonals[#diagonals + 1] = node
					end
				end

				-- Favor cardinal directions since we are constructing the path in reverse.
				-- This results in dog-leg (or hockey stick)-like movement.  If desired, we could try adding an A*-like heuristic
				-- to favor straighter line movement (i.e., alternate between diagonal and cardinal moves), but, meh, whatever ;)
				if #cardinals == 0 or min_diagonal < min_cardinal then
					current_val = min_diagonal
					for _, node in ipairs(diagonals) do
						if values[node[3]] == min_diagonal then
							path[#path + 1] = {x=node[1], y=node[2]}
							target = node[3]
							break
						end
					end
				else
					current_val = min_cardinal
					for _, node in ipairs(cardinals) do
						if values[node[3]] == min_cardinal then
							path[#path + 1] = {x=node[1], y=node[2]}
							target = node[3]
							break
						end
					end
				end
			end

			-- sanity check.  This should NEVER occur, but if it does by freak accident, let's be prepared
			if path[#path].x ~= self.x or path[#path].y ~= self.y then
				path = {}
			else
				-- un-reverse the path
				local temp_path = {}
				for i = #path-1, 1, -1 do temp_path[#temp_path + 1] = path[i] end
				path = temp_path
			end

			if #path > 0 then
				if self.running and self.running.explore then
					self.running.path = path
					self.running.cnt = 1
					self.running.explore = target_type
				else
					self.running = {
						path = path,
						cnt = 1,
						dialog = Dialog:simplePopup("Running...", "You are exploring, press any key to stop.", function()
							self:runStop()
						end, false, true),
						explore = target_type,
					}
					self.running.dialog.__showup = nil
					self.running.dialog.__hidden = true
				
					self:runStep()
				end
				return true
			end
		end
	end
	return false
end

function _M:checkAutoExplore()
	if not self.running or not self.running.explore then return false end

	-- if we're at the end of the path and we're searching for unseen tiles, then continue with a new path
	local x, y = self.running.path[#self.running.path].x, self.running.path[#self.running.path].y
	local obj = game.level.map:getObject(x, y, 1)
	local node = self.running.path[self.running.cnt]
	if not node then
		if self.running.explore == "unseen" or self.running.explore == "item" and not obj then
			return self:autoExplore()
		else
			return false
		end
	end

	-- if the next spot in the path is blocked, explore a new path if we are searching for unseen tiles, otherwise stop
	if game.level.map.has_seens(node.x, node.y) and game.level.map:checkEntity(node.x, node.y, Map.TERRAIN, "block_move", self, nil, true) then
	-- game.level.map:checkAllEntities(node.x, node.y, "block_move", self) then
		if self.running.explore == "unseen" then 
			return self:autoExplore()
		else
			self:runStop("the path is blocked")
			return false
		end
	end

	-- One more kindness to the player: take advantage of asymmetric LoS in this one specific case.
	-- If an enemy is at '?', the player is able to prevent an ambush by moving to 'x' instead of 't'.
	-- This is the only sensibly preventable ambush (that I know of) in which the player can move
	-- in a way to see the would-be ambusher and the would-be ambusher can't see the player.
	-- 
	--   .tx      Moving onto 't' puts us adjacent to an unseen tile, '?'
	--   ?#@      --> Pick 'x' instead
	if math.abs(self.x - node.x) == 1 and math.abs(self.y - node.y) == 1 then
		if game.level.map:checkAllEntities(self.x, node.y, "block_move", self) and not game.level.map:checkAllEntities(node.x, self.y, "block_move", self) and
				game.level.map:isBound(self.x, 2*node.y - self.y) and not game.level.map.has_seens(self.x, 2*node.y - self.y) then
			table.insert(self.running.path, self.running.cnt, {x=node.x, y=self.y})
		elseif game.level.map:checkAllEntities(node.x, self.y, "block_move", self) and not game.level.map:checkAllEntities(self.x, node.y, "block_move", self) and
				game.level.map:isBound(2*node.x - self.x, self.y) and not game.level.map.has_seens(2*node.x - self.x, self.y) then
			table.insert(self.running.path, self.running.cnt, {x=self.x, y=node.y})
		end
	end

	-- continue current path if we haven't seen the target tile or object yet
	if not game.level.map.has_seens(x, y) then return true end
	if obj and not game.level.map.attrs(x, y, "obj_seen") then return true end

	-- if we have explored the unseen node, then continue auto-exploring somewhere else
	if self.running.explore == "unseen" or self.running.explore == "item" and not obj then
		return self:autoExplore()
	else
	-- otherwise, try to continue running on the current path to reach our target
		return true
	end
end

