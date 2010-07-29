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
local Target = require "engine.Target"
local DamageType = require "engine.DamageType"

--- Handles actors projecting damage to zones/targets
module(..., package.seeall, class.make)

function _M:init(t)
end

--- Project damage to a distance
-- @param t a type table describing the attack, passed to engine.Target:getType() for interpretation
-- @param x target coords
-- @param y target coords
-- @param damtype a damage type ID from the DamageType class
-- @param dam damage to be done
-- @param particles particles effect configuration, or nil
function _M:project(t, x, y, damtype, dam, particles)
	-- Call the on project of the target grid if possible
	if not t.bypass and game.level.map:checkAllEntities(x, y, "on_project", self, t, x, y, damtype, dam, particles) then
		return
	end

	if type(particles) ~= "table" then particles = nil end

--	if type(dam) == "number" and dam < 0 then return end
	local typ = Target:getType(t)

	local grids = {}
	local function addGrid(x, y)
		if not grids[x] then grids[x] = {} end
		grids[x][y] = true
	end

	local srcx, srcy = t.x or self.x, t.y or self.y

	-- Stop at range or on block
	local lx, ly = x, y
	local l = line.new(srcx, srcy, x, y)
	lx, ly = l()
	local initial_dir = lx and coord_to_dir[lx - srcx][ly - srcy] or 5
	while lx and ly do
		if not typ.no_restrict then
			if typ.stop_block and game.level.map:checkAllEntities(lx, ly, "block_move") then break
			elseif game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move") then break end
			if typ.range and math.sqrt((srcx-lx)^2 + (srcy-ly)^2) > typ.range then break end
		end

		-- Deam damage: beam
		if typ.line then addGrid(lx, ly) end

		lx, ly = l()
	end
	-- Ok if we are at the end reset lx and ly for the next code
	if not lx and not ly then lx, ly = x, y end

	if typ.ball then
		core.fov.calc_circle(lx, ly, typ.ball, function(_, px, py)
			-- Deal damage: ball
			addGrid(px, py)
			if not typ.no_restrict and game.level.map:checkEntity(px, py, Map.TERRAIN, "block_move") then return true end
		end, function()end, nil)
		addGrid(lx, ly)
	elseif typ.cone then
		core.fov.calc_beam(lx, ly, typ.cone, initial_dir, typ.cone_angle, function(_, px, py)
			-- Deal damage: cone
			addGrid(px, py)
			if not typ.no_restrict and game.level.map:checkEntity(px, py, Map.TERRAIN, "block_move") then return true end
		end, function()end, nil)
		addGrid(lx, ly)
	else
		-- Deam damage: single
		addGrid(lx, ly)
	end

	-- Now project on each grid, one type
	local tmp = {}
	if type(damtype) == "function" then
		local stop = false
		for px, ys in pairs(grids) do
			for py, _ in pairs(ys) do
				if particles then
					game.level.map:particleEmitter(px, py, 1, particles.type)
				end
				if damtype(px, py) then stop=true break end
			end
			if stop then break end
		end
	else
		for px, ys in pairs(grids) do
			for py, _ in pairs(ys) do
				-- Call the projected method of the target grid if possible
				if not game.level.map:checkAllEntities(x, y, "projected", self, t, x, y, damtype, dam, particles) then
					-- Friendly fire ?
					if px == self.x and py == self.y then
						if t.friendlyfire then
							DamageType:get(damtype).projector(self, px, py, damtype, dam, tmp)
							if particles then
								game.level.map:particleEmitter(px, py, 1, particles.type)
							end
						end
					else
						DamageType:get(damtype).projector(self, px, py, damtype, dam, tmp)
						if particles then
							game.level.map:particleEmitter(px, py, 1, particles.type)
						end
					end
				end
			end
		end
	end
	return grids
end

--- Can we project to this grid ?
-- @param t a type table describing the attack, passed to engine.Target:getType() for interpretation
-- @param x target coords
-- @param y target coords
function _M:canProject(t, x, y)
	local typ = Target:getType(t)

	-- Stop at range or on block
	local lx, ly = x, y
	local l = line.new(self.x, self.y, x, y)
	lx, ly = l()
	while lx and ly do
		if not typ.no_restrict then
			if typ.stop_block and game.level.map:checkAllEntities(lx, ly, "block_move") then break
			elseif game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move") then break end
			if typ.range and math.sqrt((self.x-lx)^2 + (self.y-ly)^2) > typ.range then break end
		end

		lx, ly = l()
	end
	-- Ok if we are at the end reset lx and ly for the next code
	if not lx and not ly then lx, ly = x, y end

	if lx == x and ly == y then return true, lx, ly end
	return false, lx, ly
end

_M.projectile_class = "engine.Projectile"

--- Project damage to a distance using a moving projectile
-- @param t a type table describing the attack, passed to engine.Target:getType() for interpretation
-- @param x target coords
-- @param y target coords
-- @param damtype a damage type ID from the DamageType class
-- @param dam damage to be done
-- @param particles particles effect configuration, or nil
function _M:projectile(t, x, y, damtype, dam, particles)
	-- Call the on project of the target grid if possible
--	if not t.bypass and game.level.map:checkAllEntities(x, y, "on_project", self, t, x, y, damtype, dam, particles) then
--		return
--	end

	if type(particles) ~= "function" and type(particles) ~= "table" then particles = nil end

--	if type(dam) == "number" and dam < 0 then return end
	local typ = Target:getType(t)

	local proj = require(self.projectile_class):makeProject(self, t.display, {x=x, y=y, start_x = t.x or self.x, start_y = t.y or self.y, damtype=damtype, tg=t, typ=typ, dam=dam, particles=particles})
	game.zone:addEntity(game.level, proj, "projectile", self.x, self.y)
end

function _M:projectDoMove(typ, tgtx, tgty, x, y, srcx, srcy)
	-- Stop at range or on block
	local l = line.new(srcx, srcy, tgtx, tgty)
	local lx, ly = srcx, srcy
	-- Look for our current position
	while lx and ly and not (lx == x and ly == y) do lx, ly = l() end
	-- Now get the next position
	if lx and ly then lx, ly = l() end

	if lx and ly then
		if not typ.no_restrict then
			if typ.stop_block and game.level.map:checkAllEntities(lx, ly, "block_move") then return lx, ly, false, true
			elseif game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move") then return lx, ly, false, true end
			if typ.range and math.sqrt((srcx-lx)^2 + (srcy-ly)^2) > typ.range then return lx, ly, false, true end
		end

		-- Deam damage: beam
		if typ.line then return lx, ly, true, false end
	end
	-- Ok if we are at the end
	if (not lx and not ly) then return lx, ly, false, true end
	return lx, ly, false, false
end


function _M:projectDoAct(typ, tg, damtype, dam, particles, px, py, tmp)
	-- Now project on each grid, one type
	if type(damtype) == "function" then
		if particles and type(particles) == "table" then
			game.level.map:particleEmitter(px, py, 1, particles.type)
		end
		if damtype(px, py) then return true end
		return false
	else
		-- Call the projected method of the target grid if possible
		if not game.level.map:checkAllEntities(px, py, "projected", self, typ, px, py, damtype, dam, particles) then
			-- Friendly fire ?
			if px == self.x and py == self.y then
				if tg.friendlyfire then
					DamageType:get(damtype).projector(self, px, py, damtype, dam, tmp)
					if particles and type(particles) == "table" then
						game.level.map:particleEmitter(px, py, 1, particles.type)
					end
				end
			else
				DamageType:get(damtype).projector(self, px, py, damtype, dam, tmp)
				if particles and type(particles) == "table" then
					game.level.map:particleEmitter(px, py, 1, particles.type)
				end
			end
		end
	end
end

function _M:projectDoStop(typ, tg, damtype, dam, particles, lx, ly, tmp)
	local grids = {}
	local function addGrid(x, y)
		if not grids[x] then grids[x] = {} end
		grids[x][y] = true
	end

	if typ.ball then
		core.fov.calc_circle(lx, ly, typ.ball, function(_, px, py)
			-- Deal damage: ball
			addGrid(px, py)
			if not typ.no_restrict and game.level.map:checkEntity(px, py, Map.TERRAIN, "block_move") then return true end
		end, function()end, nil)
		addGrid(lx, ly)
	elseif typ.cone then
		local initial_dir = lx and util.getDir(lx, ly, x, y) or 5
		core.fov.calc_beam(lx, ly, typ.cone, initial_dir, typ.cone_angle, function(_, px, py)
			-- Deal damage: cone
			addGrid(px, py)
			if not typ.no_restrict and game.level.map:checkEntity(px, py, Map.TERRAIN, "block_move") then return true end
		end, function()end, nil)
		addGrid(lx, ly)
	else
		-- Deam damage: single
		addGrid(lx, ly)
	end

	for px, ys in pairs(grids) do
		for py, _ in pairs(ys) do
			if self:projectDoAct(typ, tg, damtype, dam, particles, px, py, tmp) then break end
		end
	end
	if particles and type(particles) == "function" then
		particles(self, tg, lx, ly, grids)
	end
end
