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
	setmetatable(self.ai_target, {__mode='v'})
end

function _M:aiFindTarget()
	self.ai_target.actor = game.player
end

--- Main entry point for AIs
function _M:doAI()
	if not self.ai then return end
	if self.x < game.player.x - 10 or self.x > game.player.x + 10 or self.y < game.player.y - 10 or self.y > game.player.y + 10 then return end

	-- If we have a target but it is dead (it was not yet garbage collected but it'll come)
	-- we forget it
	if self.ai_target.actor and self.ai_target.actor.dead then self.ai_target.actor = nil end

	self:runAI(self.ai)
end

function _M:runAI(ai)
	return _M.ai_def[ai](self)
end
