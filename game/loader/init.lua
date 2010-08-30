-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

-- Setup the user directory
local homepath = fs.getUserPath()..fs.getPathSeparator()..fs.getHomePath()..fs.getPathSeparator().."4.0"
fs.mount(homepath, "/")

-- Look for the required engine and load it
local args = {...}
local req_engine = args[1] or "te4"
local req_version = args[2] or "LATEST"

-- List all available engines
local engines = {}
for i, f in ipairs(fs.list("/engines/")) do
	if fs.exists("/engines/"..f.."/engine/version.lua") then
		local ff, err = loadfile("/engines/"..f.."/engine/version.lua")
		if ff and not err then
			local env = {engine={}}
			setfenv(ff, env)
			pcall(ff)
			if env.engine.version then
				print("[ENGINE LOADER] available from directory: ", env.engine.version[4], env.engine.version[1], env.engine.version[2], env.engine.version[3])

				local name = env.engine.version[4]
				engines[name] = engines[name] or {}
				engines[name][#engines[name]+1] = {env.engine.version[1], env.engine.version[2], env.engine.version[3], name, load_dir="/engines/"..f.."/"}
			end
		end
	else
		local _, _, name, vM, vm, vp = f:find("^([a-z0-9-]+)%-(%d+)%.(%d+)%.(%d+).teae$")
		if name then
			print("[ENGINE LOADER] available from teae: ", name, vM, vm, vp)
			engines[name] = engines[name] or {}
			engines[name][#engines[name]+1] = {tonumber(vM), tonumber(vm), tonumber(vp), name, load_teae="/engines/"..f}
		end
	end
end

local use_engine = nil
if req_version == "LATEST" then
	-- Sort engines
	local engs = engines[req_engine]
	if not engs then print("[ENGINE LOADER] no engines with id", req_engine) os.exit() end
	table.sort(engs, function(a, b)
		if a[1] ~= b[1] then return a[1] < b[1]
		else
			if a[2] ~= b[2] then return a[2] < b[2]
			else
				return a[3] < b[3]
			end
		end
	end)

	for i, v in ipairs(engs) do
		print("[ENGINE LOADER] sorted:", req_engine, v[1], v[2], v[3])
	end
	-- Use the latest one
	use_engine = engs[#engs]
else
	-- Look for the required engine
	local _, _, name, vM, vm, vp = (req_engine.."-"..req_version):find("([a-z0-9-]+)%-(%d+)%.(%d+)%.(%d+)")
	if name then
		if engines[name] then
			for i, eng in ipairs(engines[name]) do
				if eng[1] == tonumber(vM) and eng[2] == tonumber(vm) and eng[3] == tonumber(vp) then
					use_engine = eng
					break
				end
			end
		end
	end
end

if not use_engine then print("[ENGINE LOADER] no engines found! abording!") os.exit() end
print("[ENGINE LOADER] loading engine:", use_engine[1], use_engine[2], use_engine[3], use_engine[4])

-- Now load it, either from a directory or from a teae(T-Engine Archived Engine) file
if use_engine.load_teae then
	print("[ENGINE LOADER] using archived engine:", use_engine.load_teae)
	fs.mount(fs.getRealPath(use_engine.load_teae), "/")
elseif use_engine.load_dir then
	print("[ENGINE LOADER] using directory engine:", use_engine.load_dir)
	fs.mount(fs.getRealPath(use_engine.load_dir), "/")
end

fs.umount(homepath)

-- RUN engine RUN !!
dofile("/engine/init.lua")
