require "engine.class"

--- Handles actors stats
module(..., package.seeall, class.make)

_M.dam_def = {}

-- Default damage projector
function _M.defaultProject(x, y, type, dam)
	print("implement a projector!")
end

--- Defines new damage type
-- Static!
function _M:loadDefinition(file)
	local f = loadfile(file)
	setfenv(f, setmetatable({
		DamageType = _M,
		Map = require("engine.Map"),
		defaultProjector = function(fct) self.defaultProjector = fct end,
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

	table.insert(self.dam_def, t)
	self[t.type] = #self.dam_def
end

function _M:get(id)
	assert(_M.dam_def[id], "damage type "..tostring(id).." used but undefined")
	return _M.dam_def[id]
end
