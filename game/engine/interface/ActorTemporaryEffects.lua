require "engine.class"

--- Handles actors temporary effects (temporary boost of a stat, ...)
module(..., package.seeall, class.make)

_M.tempeffect_def = {}

--- Defines actor temporary effects
-- Static!
function _M:loadDefinition(file)
	local f = loadfile(file)
	setfenv(f, setmetatable({
		DamageType = require "engine.DamageType",
		newEffect = function(t) self:newEffect(t) end,
		load = function(f) self:loadDefinition(f) end
	}, {__index=_G}))
	f()
end

--- Defines one effect
-- Static!
function _M:newEffect(t)
	assert(t.name, "no effect name")
	assert(t.desc, "no effect desc")
	assert(t.type, "no effect type")
	t.name = t.name:upper()
	t.activation = t.activation or function() end
	t.deactivation = t.deactivation or function() end
	t.parameters = t.parameters or {}
	t.type = t.type or "physical"
	t.status = t.status or "detrimental"

	table.insert(self.tempeffect_def, t)
	t.id = #self.tempeffect_def
	self["EFF_"..t.name] = #self.tempeffect_def
end


function _M:init(t)
	self.tmp = {}
end

--- Counts down timed effects, call from your actors "act" method
--
function _M:timedEffects()
	for eff, p in pairs(self.tmp) do
		p.dur = p.dur - 1
		if p.dur <= 0 then
--			self:removeEffect(eff)
		else
			if _M.tempeffect_def[eff].on_timeout then
				_M.tempeffect_def[eff].on_timeout(self, p)
			end
		end
	end
end

--- Sets a timed effect on the actor
-- @param eff_id the effect to set
-- @param dur the number of turns to go on
-- @param p a table containing the effects parameters
function _M:setEffect(eff_id, dur, p)
	-- Beware, setting to 0 means removing
	if dur <= 0 then return self:removeEffect(eff_id) end

	for k, e in pairs(_M.tempeffect_def[eff_id].parameters) do
		if not p[k] then p[k] = e end
	end
	p.dur = dur
	self.tmp[eff_id] = p
	if _M.tempeffect_def[eff_id].on_gain then
		local ret, fly = _M.tempeffect_def[eff_id].on_gain(self, p)
		if ret then
			game.logSeen(self, ret:gsub("#Target#", self.name:capitalize()):gsub("#target#", self.name))
		end
		if fly and game.flyers then
			local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
			game.flyers:add(sx, sy, 20, (rng.range(0,2)-1) * 0.5, -3, fly, {255,100,80})
		end
		if _M.tempeffect_def[eff_id].activate then _M.tempeffect_def[eff_id].activate(self, p) end
		self.changed = true
	end
end

--- Check timed effect
-- @param eff_id the effect to check for
-- @return either nil or the parameters table for the effect
function _M:hasEffect(eff_id)
	return self.tmp[eff_id]
end

--- Removes the effect
function _M:removeEffecf(eff)
	local p = self.tmp[eff]
	self.tmp[eff] = nil
	self.changed = true
	if _M.tempeffect_def[eff].on_lose then
		local ret, fly = _M.tempeffect_def[eff].on_lose(self, p)
		if ret then
			game.logSeen(self, ret:gsub("#Target#", self.name:capitalize()):gsub("#target#", self.name))
		end
		if fly and game.flyers then
			local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
			game.flyers:add(sx, sy, 20, (rng.range(0,2)-1) * 0.5, -3, fly, {255,100,80})
		end
	end
	if _M.tempeffect_def[eff].deactivate then _M.tempeffect_def[eff].deactivate(self, p) end
end
