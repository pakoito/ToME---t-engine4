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

--- Handles actors stats
module(..., package.seeall, class.make)

_M.dam_def = {}

-- Default damage projector
function _M.defaultProject(src, x, y, type, dam)
	print("implement a projector!")
end

--- Defines new damage type
-- Static!
function _M:loadDefinition(file)
	local f, err = loadfile(file)
	if not f and err then error(err) end
	setfenv(f, setmetatable({
		DamageType = _M,
		Map = require("engine.Map"),
		setDefaultProjector = function(fct) self.defaultProjector = fct end,
		newDamageType = function(t) self:newDamageType(t) end,
	}, {__index=_G}))
	f()
end

--- Defines one ability type(group)
-- Static!
function _M:newDamageType(t)
	assert(t.name, "no ability type name")
	assert(t.type, "no ability type type")
	t.type = t.type:upper()
	t.projector = t.projector or self.defaultProjector

	if not t.color and type(t.text_color) == "string" then
		local ts = t.text_color:toTString()
		if type(ts[2]) == "table" and ts[2][1] == "color" then
			if type(ts[2][2]) == "string" then
				t.color = colors[ts[2][2]]
			elseif type(ts[2][2]) == "string" then
				t.color = {r=ts[2][2], g=ts[2][3], b=ts[2][4]}
			end
		end
	end

	table.insert(self.dam_def, t)
	self[t.type] = #self.dam_def
end

function _M:get(id)
	assert(_M.dam_def[id], "damage type "..tostring(id).." used but undefined")
	return _M.dam_def[id]
end

function _M:projectingFor(src, v)
	src.__projecting_for = v
end

function _M:getProjectingFor(src)
	return src.__projecting_for
end
