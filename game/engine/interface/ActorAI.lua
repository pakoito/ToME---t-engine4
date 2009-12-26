require "engine.class"
local Map = require "engine.Map"

--- Handles actors artificial intelligence (or dumbness ... ;)
module(..., package.seeall, class.make)

_M.ai_def = {}

--- Deinfe AI
function _M:newAI(name, fct)
	_M.ai_def[name] = fct
end

--- Defines AIs
-- Static!
function _M:loadDefinition(dir)
	for i, file in ipairs(fs.list(dir)) do
		if file:find("%.lua$") then
			local f, err = loadfile(dir.."/"..file)
			if not f and err then error(err) end
			setfenv(f, setmetatable({
				Map = require("engine.Map"),
				newAI = function(name, fct) self:newAI(name, fct) end,
			}, {__index=_G}))
			f()
		end
	end
end

function _M:init(t)
	self.ai_state = {}
	self.ai_target = {}
	-- Make the table with weak values, so that threat list does not prevent garbage collection
	setmetatable(self.ai_target, {__mode='v'})
end

local coords = {
	[1] = { 4, 2, 7, 3 },
	[2] = { 1, 3, 4, 6 },
	[3] = { 2, 6, 1, 9 },
	[4] = { 7, 1, 8, 2 },
	[5] = {},
	[6] = { 9, 3, 8, 2 },
	[7] = { 4, 8, 1, 9 },
	[8] = { 7, 9, 4, 6 },
	[9] = { 8, 6, 7, 3 },
}

--- Move one step to the given target if possible
-- This tries the most direct route, if not available it checks sides and always tries to get closer
function _M:moveDirection(x, y)
	local l = line.new(self.x, self.y, x, y)
	local lx, ly = l()
	if lx and ly then
		-- if we are blocked, try some other way
		if game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move") then
			local dirx = lx - self.x
			local diry = ly - self.y
			local dir = coord_to_dir[dirx][diry]

			local list = coords[dir]
			local l = {}
			-- Find posiblities
			for i = 1, #list do
				local dx, dy = self.x + dir_to_coord[list[i]][1], self.y + dir_to_coord[list[i]][2]
				if not game.level.map:checkEntity(dx, dy, Map.TERRAIN, "block_move") then
					l[#l+1] = {dx,dy, (dx-x)^2 + (dy-y)^2}
				end
			end
			-- Move to closest
			if #l > 0 then
				table.sort(l, function(a,b) return a[3]<b[3] end)
				return self:move(l[1][1], l[1][2])
			end
		else
			return self:move(lx, ly)
		end
	end
end

--- Main entry point for AIs
function _M:doAI()
	if not self.ai then return end
	if self.x < game.player.x - 10 or self.x > game.player.x + 10 or self.y < game.player.y - 10 or self.y > game.player.y + 10 then return end

	-- If we have a target but it is dead (it was not yet garbage collected but it'll come)
	-- we forget it
	if self.ai_target.actor and self.ai_target.actor.dead then self.ai_target.actor = nil end

	return self:runAI(self.ai)
end

function _M:runAI(ai)
	return _M.ai_def[ai](self)
end

--- Returns the current target
function _M:getTarget(typ)
	return self.ai_target.actor.x, self.ai_target.actor.y, self.ai_target.actor
end
