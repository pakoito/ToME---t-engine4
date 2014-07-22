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
local Shader = require "engine.Shader"

--- handles targetting
module(..., package.seeall, class.make)

function _M:init(map, source_actor)
	self.display_x, self.display_y = map.display_x, map.display_y
	self.w, self.h = map.viewport.width, map.viewport.height
	self.tile_w, self.tile_h = map.tile_w, map.tile_h
	self.active = false
	self.target_type = {}
	self.cursor_rotate = 0

	self.cursor = engine.Tiles:loadImage("target_cursor.png"):glTexture()
	self.arrow = engine.Tiles:loadImage("target_arrow.png"):glTexture()

	self:createTextures()

	self.source_actor = source_actor

	-- Setup the tracking target table
	-- Notice its values are set to weak references, this has no effects on the number for x and y
	-- but it means if the entity field is set to an entity, when it disappears this link wont prevent
	-- the garbage collection
	self.target = {x=self.source_actor.x, y=self.source_actor.y, entity=nil}
--	setmetatable(self.target, {__mode='v'})
end

function _M:createTextures()
	--Use power of two (pot) width and height, rounded up
	local pot_width = math.pow(2, math.ceil(math.log(self.tile_w-0.1) / math.log(2.0)))
	local pot_height = math.pow(2, math.ceil(math.log(self.tile_h-0.1) / math.log(2.0)))
	self.sr = core.display.newSurface(pot_width, pot_height)
	self.sr:erase(255, 0, 0, self.fbo and 150 or 90)
	self.sr = self.sr:glTexture()
	self.sb = core.display.newSurface(pot_width, pot_height)
	self.sb:erase(0, 0, 255, self.fbo and 150 or 90)
	self.sb = self.sb:glTexture()
	self.sg = core.display.newSurface(pot_width, pot_height)
	self.sg:erase(0, 255, 0, self.fbo and 150 or 90)
	self.sg = self.sg:glTexture()
	self.sy = core.display.newSurface(pot_width, pot_height)
	self.sy:erase(255, 255, 0, self.fbo and 150 or 90)
	self.sy = self.sy:glTexture()
	self.syg = core.display.newSurface(pot_width, pot_height)
	self.syg:erase(153, 204, 50, self.fbo and 150 or 90)
	self.syg = self.syg:glTexture()
end

function _M:enableFBORenderer(texture, shader)
	if not shader or not core.display.fboSupportsTransparency then 
		self.fbo = nil
		self:createTextures()
		return
	end
	self.fbo = core.display.newFBO(Map.viewport.width, Map.viewport.height)
	if not self.fbo then
		self:createTextures()
		return
	end

	self.fbo_shader = Shader.new(shader)
	if not self.fbo_shader.shad then
		self.fbo = nil
		self:createTextures()
		return
	end

	self.targetshader = engine.Tiles:loadImage(texture):glTexture()
	self:createTextures()
end

function _M:displayArrow(sx, sy, tx, ty, full)
	local x, y = (tx*2.5 + sx) / 3.5, (ty*2.5 + sy) / 3.5

	if full then x, y = (tx*3.5 + sx) / 4.5, (ty*3.5 + sy) / 4.5 end

	core.display.glMatrix(true)
	core.display.glTranslate(self.display_x + (x - game.level.map.mx) * self.tile_w * Map.zoom + self.tile_w * Map.zoom / 2, self.display_y + (y - game.level.map.my + util.hexOffset(x)) * self.tile_h * Map.zoom + self.tile_h * Map.zoom / 2, 0)
	core.display.glRotate(180, 1, 0, 0)
	core.display.glRotate(90+util.dirToAngle(util.getDir(tx, ty, sx, sy)), 0, 0, 1)

	self.arrow:toScreenFull(- self.tile_w * Map.zoom / 2, - self.tile_h * Map.zoom / 2, self.tile_w * Map.zoom, self.tile_h * Map.zoom, self.tile_w * Map.zoom, self.tile_h * Map.zoom, 1, 1, 1, full and 1 or 0.85)

	core.display.glMatrix(false)
end

function _M:display(dispx, dispy, prevfbo, rotate_keyframes)
	local ox, oy = self.display_x, self.display_y
	local sx, sy = game.level.map._map:getScroll()
	sx = sx + game.level.map.display_x
	sy = sy + game.level.map.display_y
	self.display_x, self.display_y = dispx or sx or self.display_x, dispy or sy or self.display_y
	
	if self.active then
		if not self.fbo then
			self:realDisplay(self.display_x, self.display_y)
		else
			self.fbo:use(true, 0, 0, 0, 0)
			self:realDisplay(0, 0)
			self.fbo:use(false, prevfbo)
			self.targetshader:bind(1, false)
			self.fbo_shader.shad:use(true)
			self.fbo_shader.shad:uniTileSize(self.tile_w, self.tile_h)
			self.fbo_shader.shad:uniScrollOffset(0, 0)
			self.fbo:toScreen(self.display_x, self.display_y, Map.viewport.width, Map.viewport.height, self.fbo_shader.shad, 1, 1, 1, 1, true)
			self.fbo_shader.shad:use(false)
		end

		if not self.target_type.immediate_keys or firstx then
			core.display.glMatrix(true)
			core.display.glTranslate(self.display_x + (self.target.x - game.level.map.mx) * self.tile_w * Map.zoom + self.tile_w * Map.zoom / 2, self.display_y + (self.target.y - game.level.map.my + util.hexOffset(self.target.x)) * self.tile_h * Map.zoom + self.tile_h * Map.zoom / 2, 0)
			if rotate_keyframes then
				self.cursor_rotate = self.cursor_rotate - rotate_keyframes / 2
				core.display.glRotate(self.cursor_rotate, 0, 0, 1)
			end
			self.cursor:toScreen(-self.tile_w * Map.zoom / 2, -self.tile_h * Map.zoom / 2, self.tile_w * Map.zoom, self.tile_h * Map.zoom)
			core.display.glMatrix(false)
		end

		if self.target_type.immediate_keys then
			for dir, spot in pairs(util.adjacentCoords(self.target_type.start_x, self.target_type.start_y)) do
				self:displayArrow(self.target_type.start_x, self.target_type.start_y, spot[1], spot[2], firstx == spot[1] and firsty == spot[2])
			end
		end
	end

	self.display_x, self.display_y = ox, oy
end

function _M:realDisplay(dispx, dispy, display_highlight)
	if not display_highlight then
		if util.isHex() then
			display_highlight = function(texture, tx, ty, count)
				count = count or 1
				for i = 1, count do
					texture:toScreenHighlightHex(
						dispx + (tx - game.level.map.mx) * self.tile_w * Map.zoom,
						dispy + (ty - game.level.map.my + util.hexOffset(tx)) * self.tile_h * Map.zoom,
						self.tile_w * Map.zoom,
						self.tile_h * Map.zoom)
				end
			end
		else
			display_highlight = function(texture, tx, ty, count)
				count = count or 1
				for i = 1, count do
					texture:toScreen(
						dispx + (tx - game.level.map.mx) * self.tile_w * Map.zoom,
						dispy + (ty - game.level.map.my) * self.tile_h * Map.zoom,
						self.tile_w * Map.zoom,
						self.tile_h * Map.zoom)
				end
			end
		end
	end

	if self.target_type.multiple then
		local make_display_highlight = function(collector)
			return function(texture, tx, ty, count)
				count = count or 1
				collector[tx] = collector[tx] or {}
				collector[tx][ty] = {texture, count}
			end
		end
		local draw_highlight = function(collector)
			for x, ys in pairs(collector) do
				for y, tex in pairs(ys) do
					display_highlight(tex[1], x, y, tex[2])
				end
			end
		end

		local target_type = self.target_type

		local textures = {}
		local sub_display_highlight = make_display_highlight(textures)
		for _, tt in ipairs(target_type) do
			self.target_type = tt
			self:realDisplay(dispx, dispy, sub_display_highlight)
		end
		draw_highlight(textures)

		self.target_type = target_type
		return
	end

	-- Make sure we have a source
	if not self.target_type.source_actor then
		self.target_type.source_actor = self.source_actor
	end
	-- Entity tracking, if possible and if visible
	if self.target.entity and self.target.entity.x and self.target.entity.y and game.level.map.seens(self.target.entity.x, self.target.entity.y) then
		self.target.x, self.target.y = self.target.entity.x, self.target.entity.y
	end
	self.target.x = self.target.x or self.source_actor.x
	self.target.y = self.target.y or self.source_actor.y

	self.target_type.start_x = self.target_type.start_x or self.target_type.x or self.target_type.source_actor and self.target_type.source_actor.x or self.x
	self.target_type.start_y = self.target_type.start_y or self.target_type.y or self.target_type.source_actor and self.target_type.source_actor.y or self.y


--	self.cursor:toScreen(dispx + (self.target.x - game.level.map.mx) * self.tile_w * Map.zoom, dispy + (self.target.y - game.level.map.my) * self.tile_h * Map.zoom, self.tile_w * Map.zoom, self.tile_h * Map.zoom)

	-- Do not display if not requested
	if not self.active then return end

	local s = self.sb
	local l
	if self.target_type.source_actor.lineFOV then
		l = self.target_type.source_actor:lineFOV(self.target.x, self.target.y, nil, nil, self.target_type.start_x, self.target_type.start_y)
	else
		l = core.fov.line(self.target_type.start_x, self.target_type.start_y, self.target.x, self.target.y)
	end
	local block_corner = self.target_type.block_path and function(_, bx, by) local b, h, hr = self.target_type:block_path(bx, by, true) ; return b and h and not hr end
		or function(_, bx, by) return false end

	l:set_corner_block(block_corner)
	local lx, ly, blocked_corner_x, blocked_corner_y = l:step()

	local stop_x, stop_y = self.target_type.start_x, self.target_type.start_y
	local stop_radius_x, stop_radius_y = self.target_type.start_x, self.target_type.start_y
	local stopped = false
	local block, hit, hit_radius

	local firstx, firsty = lx, ly

	-- Being completely blocked by the corner of an adjacent tile is annoying, so let's make it a special case and hit it instead
	if blocked_corner_x then
		block = true
		hit = true
		hit_radius = false
		stopped = true
		if self.target_type.min_range and core.fov.distance(self.target_type.start_x, self.target_type.start_y, lx, ly) < self.target_type.min_range then
			s = self.sr
		end
		if game.level.map:isBound(blocked_corner_x, blocked_corner_y) then
			display_highlight(s, blocked_corner_x, blocked_corner_y)
		end
		s = self.sr
	end

	while lx and ly do
		if not stopped then
			block, hit, hit_radius = false, true, true
			if self.target_type.block_path then
				block, hit, hit_radius = self.target_type:block_path(lx, ly, true)
			end

			-- Update coordinates and set color
			if hit then
				stop_x, stop_y = lx, ly
				if not block and hit == "unknown" then s = self.sy end
			else
				s = self.sr
			end
			if hit_radius then
				stop_radius_x, stop_radius_y = lx, ly
			end
			if self.target_type.min_range then
				-- Check if we should be "red"
				if core.fov.distance(self.target_type.start_x, self.target_type.start_y, lx, ly) < self.target_type.min_range then
					s = self.sr
				-- Check if we were only "red" because of minimum distance
				elseif s == self.sr then
					s = self.sb
				end
			end
		end
		display_highlight(s, lx, ly)
		if block then
			s = self.sr
			stopped = true
		end

		lx, ly, blocked_corner_x, blocked_corner_y = l:step()

		if blocked_corner_x and not stopped then
			block = true
			stopped = true
			hit_radius = false
			s = self.sr
			-- double the fun :-P
			if game.level.map:isBound(blocked_corner_x, blocked_corner_y) then
				display_highlight(s, blocked_corner_x, blocked_corner_y, 2)
			end
		end

	end

	if self.target_type.ball and self.target_type.ball > 0 then
		core.fov.calc_circle(
			stop_radius_x,
			stop_radius_y,
			game.level.map.w,
			game.level.map.h,
			self.target_type.ball,
			function(_, px, py)
				if self.target_type.block_radius and self.target_type:block_radius(px, py, true) then return true end
			end,
			function(_, px, py)
				if not self.target_type.no_restrict and not game.level.map.remembers(px, py) and not game.level.map.seens(px, py) then
					display_highlight(self.syg, px, py)
				else
					display_highlight(self.sg, px, py)
				end
			end,
		nil)
	elseif self.target_type.cone and self.target_type.cone > 0 then
		--local dir_angle = math.deg(math.atan2(self.target.y - self.source_actor.y, self.target.x - self.source_actor.x))
		core.fov.calc_beam_any_angle(
			stop_radius_x,
			stop_radius_y,
			game.level.map.w,
			game.level.map.h,
			self.target_type.cone,
			self.target_type.cone_angle,
			self.target_type.start_x,
			self.target_type.start_y,
			self.target.x - self.target_type.start_x,
			self.target.y - self.target_type.start_y,
			function(_, px, py)
				if self.target_type.block_radius and self.target_type:block_radius(px, py, true) then return true end
			end,
			function(_, px, py)
				if not self.target_type.no_restrict and not game.level.map.remembers(px, py) and not game.level.map.seens(px, py) then
					display_highlight(self.syg, px, py)
				else
					display_highlight(self.sg, px, py)
				end
			end,
		nil)
	elseif self.target_type.wall and self.target_type.wall > 0 then
		core.fov.calc_wall(
			stop_radius_x,
			stop_radius_y,
			game.level.map.w,
			game.level.map.h,
			self.target_type.wall,
			self.target_type.halfmax_spots,
			self.target_type.start_x,
			self.target_type.start_y,
			self.target.x - self.target_type.start_x,
			self.target.y - self.target_type.start_y,
			function(_, px, py)
				if self.target_type.block_radius and self.target_type:block_radius(px, py, true) then return true end
			end,
			function(_, px, py)
				if not self.target_type.no_restrict and not game.level.map.remembers(px, py) and not game.level.map.seens(px, py) then
					display_highlight(self.syg, px, py)
				else
					display_highlight(self.sg, px, py)
				end
			end,
		nil)
	end
end

-- @return t The target table used by ActorProject, Projectile, GameTargeting, etc.
-- @param t Target table used to generate the
-- @param t.type The engine-defined type, populates other more complex variables (see below)
-- Hit: simple project in LOS<br/>
-- Beam: hits everything in LOS<br/>
-- Bolt: hits first thing in path<br/>
-- Ball: hits everything in a ball around the target<br/>
-- Cone: hits everything in a cone in the direction<br/>
-- @param t.radius The radius of the ball/cone AoE
-- @param t.cone_angle The angle for the cone AoE (default 55°)
-- @param t.grid_exclude = {[x1][y1]=true,...[x2][y2]=true...} Grids to exclude - for making holes in the AOE
-- @param t.act_exclude = {[uid] = true,...} exclude grids containing actor(s) with the matching uid(s)
-- @param t.selffire = boolean or % chance to project against grids with self
-- @param t.friendlyfire = boolean or % chance to project against grids with friendly Actors (based on 			Actor:reactionToward(target)>0)
-- @param t.no_restrict Boolean that removes all restrictions in the t.type defined block functions.
-- @param t.stop_block Boolean that stops the target on the first tile that has an entity that blocks move.
-- @param t.range The range the target can be from the origin.
-- @param t.pass_terrain Boolean that allows the target to pass through terrain to remembered tiles on the other side.
-- @param t.block_path(typ, lx, ly) Function called on each tile to determine if the targeting is blocked.  Automatically set when using t.typ, but the user can provide their own if they know what they are doing.  It should return three arguments: block, hit, hit_radius
-- @param t.block_radius(typ, lx, ly) Function called on each tile when projecting the radius to determine if the radius projection is blocked.  Automatically set when using t.typ, but the user can provide their own if they know what they are doing.
function _M:getType(t)
	if not t then return {} end

	-- Allow multiple targeting types.
	if t.multiple then
		for k, v in ipairs(t) do
			t[k] = self:getType(v)
		end
		return t
	end

	-- Add the default values
	t = table.clone(t)
	-- Default type def
	local target_type = {
		range = 20,
		selffire = true,
		friendlyfire = true,
		friendlyblock = true,
		--- Determines how a path is blocked for a target type
		--@param typ The target type table
		block_path = function(typ, lx, ly, for_highlights)
			if not game.level.map:isBound(lx, ly) then
				return true, false, false
			elseif not typ.no_restrict then
				if typ.range and typ.start_x then
					local dist = core.fov.distance(typ.start_x, typ.start_y, lx, ly)
					if dist > typ.range then return true, false, false end
				elseif typ.range and typ.source_actor and typ.source_actor.x then
					local dist = core.fov.distance(typ.source_actor.x, typ.source_actor.y, lx, ly)
					if dist > typ.range then return true, false, false end
				end
				local is_known = game.level.map.remembers(lx, ly) or game.level.map.seens(lx, ly)
				if typ.requires_knowledge and not is_known then
					return true, false, false
				end
				if not typ.pass_terrain and game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") and not game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "pass_projectile") then
					if for_highlights and not is_known then
						return false, "unknown", true
					else
						return true, true, false
					end
				-- If we explode due to something other than terrain, then we should explode ON the tile, not before it
				elseif typ.stop_block then
					local nb = game.level.map:checkAllEntitiesCount(lx, ly, "block_move")
					-- Reduce for pass_projectile or pass_terrain, which was handled above
					if game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") and (typ.pass_terrain or game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "pass_projectile")) then
						nb = nb - 1
					end
					-- Reduce the nb blocking for friendlies
					if not typ.friendlyblock and typ.source_actor and typ.source_actor.reactionToward then
						local a = game.level.map(lx, ly, engine.Map.ACTOR)
						if a and typ.source_actor:reactionToward(a) > 0 then
							nb = nb - 1
						end
					end
					if nb > 0 then
						if for_highlights then
							-- Targeting highlight should be yellow if we don't know what we're firing through
							if not is_known then
								return false, "unknown", true
							-- Don't show the path as blocked if it's blocked by an actor we can't see
							elseif nb == 1 and typ.source_actor and typ.source_actor.canSee and not typ.source_actor:canSee(game.level.map(lx, ly, engine.Map.ACTOR)) then
								return false, true, true
							end
						end
						return true, true, true
					end
				end
				if for_highlights and not is_known then
					return false, "unknown", true
				end
			end
			-- If we don't block the path, then the explode point should be here
			return false, true, true
		end,
		block_radius = function(typ, lx, ly, for_highlights)
			return not typ.no_restrict and game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") and not game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "pass_projectile") and not (for_highlights and not (game.level.map.remembers(lx, ly) or game.level.map.seens(lx, ly)))
		end
	}

	-- And now modify for the default types
	if t.type then
		if t.type:find("ball") then
			target_type.ball = t.radius
		end
		if t.type:find("cone") then
			target_type.cone = t.radius
			target_type.cone_angle = t.cone_angle or 55
			target_type.selffire = false
		end
		if t.type:find("wall") then
			if util.isHex() then
				--with a hex grid, a wall should only be defined by the number of spots
				t.halfmax_spots = t.halflength
				t.halflength = 2*t.halflength
			end
			target_type.wall = t.halflength
		end
		if t.type:find("bolt") then
			target_type.stop_block = true
		elseif t.type:find("beam") then
			target_type.line = true
		end
	end
	table.update(t, target_type)
	return t
end

function _M:setActive(v, type)
	if v == nil then
		return self.active
	else
		self.active = v
		if v and type then
			self.target_type = self:getType(type)
			-- Targeting will generally want to stop at unseen/remembered tiles
--			table.update(self.target_type, {requires_knowledge=true})
		else
			self.target_type = {}
		end
	end
end

function _M:freemove(dir)
	local dx, dy = util.dirToCoord(dir, self.target.x, self.target.y)
	self.target.x = self.target.x + dx
	self.target.y = self.target.y + dy
	self.target.entity = game.level.map(self.target.x, self.target.y, engine.Map.ACTOR)
	if self.on_set_target then self:on_set_target("freemove") end
end

function _M:setDirFrom(dir, src)
	local dx, dy = util.dirToCoord(dir, src.x, src.y)
	self.target.x = src.x + dx
	self.target.y = src.y + dy
	self.target.entity = game.level.map(self.target.x, self.target.y, engine.Map.ACTOR)
	if self.on_set_target then self:on_set_target("dir_from") end
end

function _M:setSpot(x, y, how)
	self.target.x = x
	self.target.y = y
	self.target.entity = game.level.map(self.target.x, self.target.y, engine.Map.ACTOR)
end

function _M:setSpotInMotion(x, y, how)
	if self.on_set_target then self:on_set_target(how) end
end

function _M:scan(dir, radius, sx, sy, filter, kind)
	sx = sx or self.target.x
	sy = sy or self.target.y
	if not sx or not sy then return end
	
	kind = kind or engine.Map.ACTOR
	radius = radius or 20
	local actors = {}
	local checker = function(_, x, y)
		if sx == x and sy == y then return false end
		if game.level.map.seens(x, y) and game.level.map(x, y, kind) then
			local a = game.level.map(x, y, kind)

			if (not self.source_actor or self.source_actor:canSee(a)) and (not filter or filter(a)) then
				table.insert(actors, {
					a = a,
					dist = math.abs(sx - x)*math.abs(sx - x) + math.abs(sy - y)*math.abs(sy - y)
				})
				actors[a] = true
			end
		end
		return false
	end

	if dir ~= 5 then
		-- Get a list of actors in the direction given
		core.fov.calc_beam(sx, sy, game.level.map.w, game.level.map.h, radius, dir, 55, checker, function()end, nil)
	else
		-- Get a list of actors all around
		core.fov.calc_circle(sx, sy, game.level.map.w, game.level.map.h, radius, checker, function()end, nil)
	end

	table.sort(actors, function(a,b) return a.dist<b.dist end)
	if #actors > 0 then
		self.target.entity = actors[1].a
		self.target.x = self.target.entity.x
		self.target.y = self.target.entity.y
		if self.on_set_target then self:on_set_target("scan") end
	end
end

--- Returns the point at distance from the source on a line to the destination
function _M:pointAtRange(srcx, srcy, destx, desty, dist)
	local l = line.new(srcx, srcy, destx, desty)
	local lx, ly = l()
	while lx and ly do
		if core.fov.distance(srcx, srcy, lx, ly) >= dist then break end
		lx, ly = l()
	end
	if not lx then
		return destx, desty
	else
		return lx, ly
	end
end

