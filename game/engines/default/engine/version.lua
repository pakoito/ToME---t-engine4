-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

-- Engine Version
engine.version = {1,0,5,"te4",17}
engine.require_c_core = engine.version[5]
engine.version_id = ("%s-%d_%d.%d.%d"):format(engine.version[4], engine.require_c_core, engine.version[1], engine.version[2], engine.version[3])

function engine.version_check(v)
	local ev = engine.version
	if v[5] ~= core.game.VERSION then return "bad C core" end
	if v[4] ~= ev[4] then return "different engine" end
	if v[1] > ev[1] then return "newer" end
	if v[1] == ev[1] and v[2] > ev[2] then return "newer" end
	if v[1] == ev[1] and v[2] == ev[2] and v[3] > ev[3] then return "newer" end
	if v[1] == ev[1] and v[2] == ev[2] and v[3] == ev[3] then return "same" end
	return "lower"
end

function engine.version_string(v)
	return ("%s-%d.%d.%d"):format(v[4] or "te4", v[1], v[2], v[3])
end

function engine.version_compare(v, ev)
	if v[1] > ev[1] then return "newer" end
	if v[1] == ev[1] and v[2] > ev[2] then return "newer" end
	if v[1] == ev[1] and v[2] == ev[2] and v[3] > ev[3] then return "newer" end
	if v[1] == ev[1] and v[2] == ev[2] and v[3] == ev[3] then return "same" end
	return "lower"
end

function engine.version_nearly_same(v, ev)
	if v[1] == ev[1] and v[2] == ev[2] and v[3] >= ev[3] then return true end
	return false
end
