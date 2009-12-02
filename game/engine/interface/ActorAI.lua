require "engine.class"

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
--	setmetatable(self.ai_target, {__mode='v'})
end

function _M:aiFindTarget()
	self.ai_target.actor = game.player
end

function _M:onTakeHit(value, src)
end

--- Main entry point for AIs
function _M:doAI()
--	if not self.ai then return end

	-- If we have a target but it is dead (it was not yet garbage collected but it'll come)
	-- we forget it
--	if self.ai_target.actor and self.ai_target.actor.dead then self.ai_target.actor = nil end

--	self:runAI(self.ai)

	-- Find closer ennemy and target it
	local tgt = nil
	-- Get list of actors ordered by distance
	local arr = game.level:getDistances(self)
	local act
	if not arr or #arr == 0 then
--		print("target abording, waiting on distancer")
		return
	end
	for i = 1, #arr do
		act = __uids[arr[i].uid]
		-- find the closest ennemy
		if self:reactionToward(act) < 0 then
			tgt = act.uid
--			print("selected target", act.uid, "at dist", arr[i].dist)
			break
		end
	end

	if tgt then
		local act = __uids[tgt]
		local l = line.new(self.x, self.y, act.x, act.y)
		local lx, ly = l()
		if lx and ly then
			self:move(lx, ly)
		end
	end
end

function _M:runAI(ai)
	return _M.ai_def[ai](self)
end
