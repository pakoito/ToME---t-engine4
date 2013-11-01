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
	local chunks = {}
	if sub then
		chunks[1] = "{"
	end
	for k, e in pairs(src) do
		local nk = nil
		local nkC = {}
		local tk, te = type(k), type(e)
		if no_G then
			if tk == "table" then
				nkC[#nkC+1] = "["
				nkC[#nkC+1] = table.serialize(k, true)
				nkC[#nkC+1] = "]"
			elseif tk == "string" then
				nkC[#nkC+1] = k
			else
				nkC[#nkC+1] = "["
				nkC[#nkC+1] = tostring(k)
				nkC[#nkC+1] = "]"
			end
		else
			if not sub then
				nkC[#nkC+1] = (base and tostring(base) or "_G")
			end
			nkC[#nkC+1] = "["
			if tk == "table" then
				nkC[#nkC+1] = table.serialize(k, true)
			elseif tk == "string" then
				-- escaped quotes matter
				nkC[#nkC+1] = string.format("%q", k)
			else
				nkC[#nkC+1] = tostring(k)
			end
			nkC[#nkC+1] = "]"
		end

		nk = table.concat(nkC)

		-- These are the types of data we are willing to serialize
		if te == "table" or te == "string" or te == "number" or te == "boolean" then
			chunks[#chunks+1] = nk
			chunks[#chunks+1] = "="
			if te == "table" then
				chunks[#chunks+1] = table.serialize(e, true)
			elseif te == "number" then
				-- float output matters
				chunks[#chunks+1] = string.format("%f", e)
			elseif te == "string" then
				-- escaped quotes matter
				chunks[#chunks+1] = string.format("%q", e)
			else -- te == "boolean"
				chunks[#chunks+1] = tostring(e)
			end
			chunks[#chunks+1] = " "
		end
		
		if sub then
			chunks[#chunks+1] = ", "
		end
	end
	if sub then
		chunks[#chunks+1] = "}"
	end
			
	return table.concat(chunks)
end

function string.unserialize(str)
	local f, err = loadstring(str)
	if not f then print("[UNSERIALIZE] error", err) return nil end
	local t = {}
	setfenv(f, setmetatable(t, {__index={_G=t}}))
	local ok, err = pcall(f)
	if ok then return setmetatable(t, nil) else print("[UNSERIALIZE] error", err) return nil end
end
