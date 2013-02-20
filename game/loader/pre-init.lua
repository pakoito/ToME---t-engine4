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

-- Turn on LuaJIT if available
pcall(require, "jit")
if jit then
	local jit_on, err = pcall(jit.on)
	if jit_on then
		require("jit.opt").start(2)
	else
		pcall(jit.off)
		print("Disabling JIT compiler because of:", err)
	end
	print("LuaVM:", jit.version, jit.arch)

else
	print("LuaVM:", _VERSION)
end

-- Setup the GC
collectgarbage("setpause",100)
collectgarbage("setstepmul",400)
collectgarbage("restart")

-- Setup correct lua path
package.path = "/?.lua"
package.moonpath = "/?.moon"

math.randomseed(os.time())

-- Some more vital rng functions
function rng.mbonus(max, level, max_level)
	if level > max_level - 1 then level = max_level - 1 end

	local bonus = (max * level) / max_level
	local extra = (max * level) % max_level
	if rng.range(0, max_level - 1) < extra then bonus = bonus + 1 end

	local stand = max / 4
	extra = max % 4
	if rng.range(0, 3) < extra then stand = stand + 1 end

	local val = rng.normal(bonus, stand)
	if val < 0 then val = 0 end
	if val > max then val = max end

	return val
end

function rng.table(t)
	local id = rng.range(1, #t)
	return t[id], id
end

function rng.tableRemove(t)
	local id = rng.range(1, #t)
	return table.remove(t, id)
end

function rng.tableIndex(t, ignore)
	local rt = {}
	if not ignore then ignore = {} end
	for k, e in pairs(t) do if not ignore[k] then rt[#rt+1] = k end end
	return rng.table(rt)
end

--- This is a really naive algorithm, it will not handle objects and such.
-- Use only for small tables
function table.serialize(src, sub, no_G, base)
	local str = ""
	if sub then str = "{" end
	for k, e in pairs(src) do
		local nk, ne = k, e
		local tk, te = type(k), type(e)

		if no_G then
			if tk == "table" then nk = "["..table.serialize(nk, true).."]"
			elseif tk == "string" then -- nothing
			else nk = "["..nk.."]"
			end
		else
			if tk == "table" then nk = "["..table.serialize(nk, true).."]"
			elseif tk == "string" then nk = string.format("[%q]", nk)
			else nk = "["..nk.."]"
			end
			if not sub then nk = (base or "_G")..nk end
		end

		if te == "table" then
			str = str..string.format("%s=%s ", nk, table.serialize(ne, true))
		elseif te == "number" then
			str = str..string.format("%s=%f ", nk, ne)
		elseif te == "string" then
			str = str..string.format("%s=%q ", nk, ne)
		elseif te == "boolean" then
			str = str..string.format("%s=%s ", nk, tostring(ne))
		end
		if sub then str = str..", " end
	end
	if sub then str = str.."}" end
	return str
end

function string.unserialize(str)
	local f, err = loadstring(str)
	if not f then print("[UNSERIALIZE] error", err, str) return nil end
	local t = {}
	setfenv(f, setmetatable(t, {__index={_G=t}}))
	local ok, err = pcall(f)
	if ok then return setmetatable(t, nil) else print("[UNSERIALIZE] error", err, str) return nil end
end
