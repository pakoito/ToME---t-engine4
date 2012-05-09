-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

local Entity = require "engine.Entity"

module(..., package.seeall, class.make)

_M.__ingredients_def = {}

local INFINITY = -1

--- Defines actor talents
-- Static!
function _M:loadDefinition(file, env)
	local f, err = util.loadfilemods(file, setmetatable(env or {
		INFINITY = INFINITY,
		newIngredient = function(t) self:newIngredient(t) end,
		load = function(f) self:loadDefinition(f, getfenv(2)) end
	}, {__index=_G}))
	if not f and err then error(err) end
	f()
end

--- Defines a new ingredient
-- Static!
function _M:newIngredient(t)
	assert(t.id, "no ingredient id")
	assert(t.name, "no ingredient name")
	assert(t.desc, "no ingredient desc")
	assert(t.icon, "no ingredient icon")
	assert(t.max, "no ingredient max")
	assert(t.min, "no ingredient min")

	t.display_entity = Entity.new{image=t.icon, is_ingredient=true}

	_M.__ingredients_def[t.id] = t
end


function _M:init(t)
	self.ingredients = {}
end

function _M:getIngredient(id)
	if not self.__ingredients_def[id] then return end
	return self.__ingredients_def[id]
end

function _M:collectIngredient(id, nb, silent)
	if not self.ingredients then return end
	if not self.__ingredients_def[id] then return end
	local d = self.__ingredients_def[id]
	nb = nb or 1

	if self.ingredients[id] == INFINITY then return end

	if d.min == INFINITY then
		self.ingredients[id] = INFINITY
	else
		self.ingredients[id] = math.max((self.ingredients[id] or 0) + nb, d.min)
		if d.max ~= INFINITY then
			self.ingredients[id] = math.min(self.ingredients[id], d.max)
		end

		game.log("You collect a new ingredient: #LIGHT_GREEN#%s%s#WHITE#.", d.display_entity:getDisplayString(), d.name)
	end
end

function _M:hasIngredient(id, nb)
	if not self.ingredients then return end
	if not self.__ingredients_def[id] then return false end
	local d = self.__ingredients_def[id]
	nb = nb or 1

	if not self.ingredients[id] then return false end
	if self.ingredients[id] == INFINITY then return true end
	if self.ingredients[id] >= nb then return true end
	return false
end

function _M:useIngredient(id, nb)
	if not self.ingredients then return end
	if not self.__ingredients_def[id] then return false end
	local d = self.__ingredients_def[id]
	nb = nb or 1

	if self.ingredients[id] == INFINITY then return true end
	if self.ingredients[id] >= nb then
		self.ingredients[id] = math.max(self.ingredients[id] - nb, d.min)
		if self.ingredients[id] <= 0 then self.ingredients[id] = nil end
		return true
	end
	return false
end
