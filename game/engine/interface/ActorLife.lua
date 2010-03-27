require "engine.class"
local Map = require "engine.Map"
local Target = require "engine.Target"
local DamageType = require "engine.DamageType"

--- Handles actors life and death
module(..., package.seeall, class.make)

function _M:init(t)
	self.max_life = t.max_life or 100
	self.life = t.life or self.max_life
	self.life_regen = t.life_regen or 0
end

--- Checks if something bumps in us
-- If it happens the method attack is called on the target with the attacker as parameter.
-- Do not touch!
function _M:block_move(x, y, e, can_attack)
	-- Dont bump yourself!
	if e and e ~= self and can_attack then
		e:attack(self)
	end
	return true
end

--- Regenerate life, call it from your actor class act() method
function _M:regenLife()
	if self.life_regen then
		self.life = util.bound(self.life + self.life_regen, 0, self.max_life)
	end
end

--- Heal some
function _M:heal(value, src)
	self.life = util.bound(self.life + value, 0, self.max_life)
end

--- Remove some HP from an actor
-- If HP is reduced to 0 then remove from the level and call the die method.<br/>
-- When an actor dies its dead property is set to true, to wait until garbage collection deletes it
function _M:takeHit(value, src)
	if self.onTakeHit then value = self:onTakeHit(value, src) end
	self.life = self.life - value
	if self.life <= 0 then
		game.logSeen(self, "%s killed %s!", src.name:capitalize(), self.name)
		return self:die(src)
	end
end

--- Called when died
function _M:die(src)
	game.level:removeEntity(self)
	self.dead = true

	self:check("on_die", src)
end

--- Actor is being attacked!
-- Module authors should rewrite it to handle combat, dialog, ...
-- @param target the actor attacking us
function _M:attack(target)
	game.logSeen(target, "%s attacks %s.", self.name:capitalize(), target.name:capitalize())
	target:takeHit(10, self)
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

	if type(dam) == "number" and dam < 0 then return end
	local typ = Target:getType(t)

	local grids = {}
	local function addGrid(x, y)
		if not grids[x] then grids[x] = {} end
		grids[x][y] = true
	end

	-- Stop at range or on block
	local lx, ly = x, y
	local l = line.new(self.x, self.y, x, y)
	lx, ly = l()
	local initial_dir = lx and coord_to_dir[lx - self.x][ly - self.y] or 5
	while lx and ly do
		if not typ.no_restrict then
			if typ.stop_block and game.level.map:checkAllEntities(lx, ly, "block_move") then break
			elseif game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move") then break end
			if typ.range and math.sqrt((self.x-lx)^2 + (self.y-ly)^2) > typ.range then break end
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
	if type(damtype) == "function" then
		for px, ys in pairs(grids) do
			for py, _ in pairs(ys) do
				damtype(px, py)
				if particles then
					game.level.map:particleEmitter(px, py, 1, particles.type)
				end
			end
		end
	else
		for px, ys in pairs(grids) do
			for py, _ in pairs(ys) do
				-- Call the projected method of the target grid if possible
				if not game.level.map:checkAllEntities(x, y, "projected", self, t, x, y, damtype, dam, particles) then
					-- Friendly fire ?
					if px == self.x and py == self.y then
						if t.friendlyfire then
							DamageType:get(damtype).projector(self, px, py, damtype, dam)
							if particles then
								game.level.map:particleEmitter(px, py, 1, particles.type)
							end
						end
					else
						DamageType:get(damtype).projector(self, px, py, damtype, dam)
						if particles then
							game.level.map:particleEmitter(px, py, 1, particles.type)
						end
					end
				end
			end
		end
	end
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
