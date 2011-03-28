-- TE4 - T-Engine 4
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

require "engine.class"

--- Handles actors temporary effects (temporary boost of a stat, ...)
module(..., package.seeall, class.make)

_M.tempeffect_def = {}

--- Defines actor temporary effects
-- Static!
function _M:loadDefinition(file)
	local f, err = loadfile(file)
	if not f and err then error(err) end
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
	self.tmp = self.tmp or {}
end

--- Counts down timed effects, call from your actors "act" method
--
function _M:timedEffects()
	local todel = {}
	for eff, p in pairs(self.tmp) do
		if p.dur <= 0 then
			todel[#todel+1] = eff
		else
			if _M.tempeffect_def[eff].on_timeout then
				if _M.tempeffect_def[eff].on_timeout(self, p) then
					todel[#todel+1] = eff
				end
			end
		end
		p.dur = p.dur - 1
	end

	while #todel > 0 do
		self:removeEffect(table.remove(todel))
	end
end

--- Sets a timed effect on the actor
-- @param eff_id the effect to set
-- @param dur the number of turns to go on
-- @param p a table containing the effects parameters
-- @parm silent true to suppress messages
function _M:setEffect(eff_id, dur, p, silent)
	-- Beware, setting to 0 means removing
	if dur <= 0 then return self:removeEffect(eff_id) end
	dur = math.floor(dur)

	for k, e in pairs(_M.tempeffect_def[eff_id].parameters) do
		if not p[k] then p[k] = e end
	end
	p.dur = dur

	-- If we already have it, we check if it knows how to "merge", or else we remove it and re-add it
	if self:hasEffect(eff_id) then
		if _M.tempeffect_def[eff_id].on_merge then
			self.tmp[eff_id] = _M.tempeffect_def[eff_id].on_merge(self, self.tmp[eff_id], p)
			self.changed = true
			return
		else
			self:removeEffect(eff_id, true)
		end
	end

	self.tmp[eff_id] = p
	if _M.tempeffect_def[eff_id].on_gain then
		local ret, fly = _M.tempeffect_def[eff_id].on_gain(self, p)
		if not silent then
			if ret then
				game.logSeen(self, ret:gsub("#Target#", self.name:capitalize()):gsub("#target#", self.name))
			end
			if fly and game.flyers and game.level.map.seens(self.x, self.y) then
				local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
				if game.level.map.seens(self.x, self.y) then game.flyers:add(sx, sy, 20, (rng.range(0,2)-1) * 0.5, -3, fly, {255,100,80}) end
			end
		end
	end
	if _M.tempeffect_def[eff_id].activate then _M.tempeffect_def[eff_id].activate(self, p) end
	self.changed = true
end

--- Check timed effect
-- @param eff_id the effect to check for
-- @return either nil or the parameters table for the effect
function _M:hasEffect(eff_id)
	return self.tmp[eff_id]
end

--- Removes the effect
function _M:removeEffect(eff, silent)
	local p = self.tmp[eff]
	if not p then return end
	self.tmp[eff] = nil
	self.changed = true
	if _M.tempeffect_def[eff].on_lose then
		local ret, fly = _M.tempeffect_def[eff].on_lose(self, p)
		if not silent then
			if ret then
				game.logSeen(self, ret:gsub("#Target#", self.name:capitalize()):gsub("#target#", self.name))
			end
			if fly and game.flyers then
				local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
				if game.level.map.seens(self.x, self.y) then game.flyers:add(sx, sy, 20, (rng.range(0,2)-1) * 0.5, -3, fly, {255,100,80}) end
			end
		end
	end
	if _M.tempeffect_def[eff].deactivate then _M.tempeffect_def[eff].deactivate(self, p) end
end

--- Removes the effect
function _M:removeAllEffects()
	local todel = {}
	for eff, p in pairs(self.tmp) do
		todel[#todel+1] = eff
	end

	while #todel > 0 do
		self:removeEffect(table.remove(todel))
	end
end
