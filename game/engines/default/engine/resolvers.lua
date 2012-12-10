-- TE4 - T-Engine 4
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

resolvers = {}
resolvers.calc = {}

--- Resolves a rng range
function resolvers.rngrange(x, y)
	return {__resolver="rngrange", x, y}
end
function resolvers.calc.rngrange(t)
	return rng.range(t[1], t[2])
end

--- Average random
function resolvers.rngavg(x, y)
	return {__resolver="rngavg", x, y}
end
function resolvers.calc.rngavg(t)
	return rng.avg(t[1], t[2])
end

--- Dice roll
function resolvers.dice(x, y)
	return {__resolver="dice", x, y}
end
function resolvers.calc.dice(t)
	return rng.dice(t[1], t[2])
end

--- Random table element
function resolvers.rngtable(t)
	return {__resolver="rngtable", t}
end
function resolvers.calc.rngtable(t)
	return rng.table(t[1])
end

--- Random color
function resolvers.rngcolor(t)
	return {__resolver="rngcolor", t}
end
function resolvers.calc.rngcolor(t, e)
	local c = rng.table(t[1])
	e.color_r = c.r
	e.color_g = c.g
	e.color_b = c.b
end

--- Random bonus based on level
resolvers.current_level = 1
resolvers.mbonus_max_level = 50
function resolvers.mbonus(max, add)
	return {__resolver="mbonus", max, add}
end
function resolvers.calc.mbonus(t)
	return rng.mbonus(t[1], resolvers.current_level, resolvers.mbonus_max_level) + (t[2] or 0)
end

--- Talents resolver
function resolvers.talents(list)
	return {__resolver="talents", list}
end
function resolvers.calc.talents(t, e)
	local lvls = false
	local levelup_talents = e._levelup_talents or {}
	for tid, level in pairs(t[1]) do
		if type(level) == "table" then
			levelup_talents[tid] = level
			level = level.base
			lvls = true
		end
--		print("Talent resolver for", e.name, ":", tid, "=>", level)
		e:learnTalent(tid, true, level)
	end
	if lvls then e._levelup_talents = levelup_talents end
	return nil
end

--- Talents resolver, random choice of one
function resolvers.rngtalent(list)
	return {__resolver="rngtalent", list}
end
function resolvers.calc.rngtalent(t, e)
	local lvls = false
	local levelup_talents = e._levelup_talents or {}
	local tid = rng.table(table.keys(t[1]))
	local level = t[1][tid]

	if type(level) == "table" then
		levelup_talents[tid] = level
		level = level.base
		lvls = true
	end
--	print("RNG Talent resolver for", e.name, ":", tid, "=>", level)
	e:learnTalent(tid, true, level)

	if lvls then e._levelup_talents = levelup_talents end
	return nil
end

--- Talents masteries
function resolvers.tmasteries(list)
	return {__resolver="tmasteries", list}
end
function resolvers.calc.tmasteries(t, e)
	local ts = {}
	for tt, level in pairs(t[1]) do
		assert(e.talents_types_def[tt], "unknown talent type "..tt)
		e.talents_types[tt] = true
		e.talents_types_mastery[tt] = level
	end
	return nil
end

--- Levelup resolver
function resolvers.levelup(base, every, inc, max)
	return {__resolver="levelup", base, every, inc, max}
end
function resolvers.calc.levelup(t, e, _, _, k, kchain)
	if not e._levelup_info then e._levelup_info = {} end
	local li = {every=t[2], inc=t[3], max=t[4], kchain=table.clone(kchain), k=k}
	e._levelup_info[#e._levelup_info+1] = li
	return t[1]
end

--- Generic resolver, takes a function
function resolvers.generic(fct)
	return {__resolver="generic", fct}
end
function resolvers.calc.generic(t, e)
	return t[1](e)
end
