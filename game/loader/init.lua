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

-- Setup the user directory
local homepath = fs.getUserPath()..fs.getPathSeparator()..fs.getHomePath()..fs.getPathSeparator().."4.0"
fs.mount(homepath, "/")

local load load = function(...)
	-- Look for the required engine and load it
	local args = {...}
	local req_engine = args[1] or "te4"
	local req_version = args[2] or "LATEST"
	__load_module = args[3] or "boot"
	__player_name = args[4] or "player"
	__player_new = args[5] and true or false
	if args[6] then
		print('===', args[6])
		local f = loadstring(args[6])
		__module_extra_info = {}
		setfenv(f, __module_extra_info)
		pcall(f)
		for k, e in pairs(__module_extra_info) do print(" * Module extra info", k, ":=:", e) end
	else
		__module_extra_info = {}
	end
	__request_profile = args[7] or "default"

	print("Reboot using", req_engine, req_version, __load_module, __player_name, __player_new)

	local engines = { __byname={} }

	local function tryLoadEngine(ff, dir, teae)
		local env = {engine={}}
		setfenv(ff, env)
		pcall(ff)
		if env.engine.version and env.engine.require_c_core == core.game.VERSION then
			local name = env.engine.version[4]
			local vstr = ("%s-%d.%d.%d"):format(name, env.engine.version[1], env.engine.version[2], env.engine.version[3])
			engines[name] = engines[name] or {}
			engines.__byname[vstr] = true
			engines[name][#engines[name]+1] = {env.engine.version[1], env.engine.version[2], env.engine.version[3], name, env.engine.version[5], load_dir=dir, load_teae=teae}

			print("[ENGINE LOADER] available from "..(dir and "dir" or "teae")..": ", vstr)
		end
	end

	-- List all available engines
	for i, f in ipairs(fs.list("/engines/")) do
		if fs.exists("/engines/"..f.."/engine/version.lua") then
			local ff, err = loadfile("/engines/"..f.."/engine/version.lua")
			if ff and not err then tryLoadEngine(ff, "/engines/"..f.."/", nil) end
		else
			local _, _, name, vM, vm, vp = f:find("^([a-z0-9-]+)%-(%d+)%.(%d+)%.(%d+).teae$")
			if name then
				local eng_path = fs.getRealPath("/engines/"..f)
				fs.mount(eng_path, "/tmp")
				local ff, err = loadfile("/tmp/engine/version.lua")
				if ff and not err then tryLoadEngine(ff, nil, "/engines/"..f) end
				fs.umount(eng_path)
			end
		end
	end

	__available_engines = engines

	print("[ENGINE LOADER] found engines", table.serialize(engines, nil, true))
	print("[ENGINE LOADER] looked in:")
	for i, m in ipairs(fs.getSearchPath()) do print('', m) end

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

	if not use_engine then print("[ENGINE LOADER] no engines found! rebooting to default!") return load() end
	print("[ENGINE LOADER] loading engine:", use_engine[1], use_engine[2], use_engine[3], use_engine[4])

	-- Now load it, either from a directory or from a teae(T-Engine Archived Engine) file
	if use_engine.load_teae then
		print("[ENGINE LOADER] using archived engine:", use_engine.load_teae)
		fs.mount(fs.getRealPath(use_engine.load_teae), "/")
	elseif use_engine.load_dir then
		print("[ENGINE LOADER] using directory engine:", use_engine.load_dir)
		fs.mount(fs.getRealPath(use_engine.load_dir), "/")
	end
end
load(...)

fs.umount(homepath)

__addons_superload_order = {}
local te4_loader = function(name)
	local bname = name

	-- Base loader
	local prev = loadfile("/"..bname:gsub("%.", "/")..".lua")

	name = name:gsub("%.", "/")
	for i = 1, #__addons_superload_order do
		local addon = __addons_superload_order[i]
		local fn = "/mod/addons/"..addon.."/superload/"..name..".lua"
		if fs.exists(fn) then
			local f, err = loadfile(fn)
			if not f and err then 
				error("Error while superloading '"..fn.."':\n"..tostring(err))
			end
			local base = prev
			setfenv(f, setmetatable({
				loadPrevious = function()
					print("FROM ", fn, "loading previous!")
					base(bname)
					return package.loaded[bname]
				end
			}, {__index=_G}))
			prev = f
		end
	end
	return prev
end

table.insert(package.loaders, 2, te4_loader)

local oldload = loadfile
local dlcd_loader = function(name)
	if not fs.exists("/"..name:gsub("%.", "/")..".lua.stub") then return end
	print("===DLCLOADER:class", "/"..name:gsub("%.", "/")..".lua.stub")
	local d = oldload("/"..name:gsub("%.", "/")..".lua.stub")()
	local data
	if profile.dlc_files.classes[name] then
		data = profile.dlc_files.classes[name]
		print("===DLCLOADER:class using preloaded file")
	else
		data = profile:getDLCD(d.name, d.version, name:gsub("%.", "/")..".lua")
		print("===DLCLOADER:class loaded", (data or ""):len())
	end
	return loadstring(data)
end
table.insert(package.loaders, 2, dlcd_loader)

loadfile = function(name)
	if not fs.exists(name..".stub") then return oldload(name) end
	print("===DLCLOADER:file", name..".stub")
	local d = oldload(name..".stub")()
	local data = profile:getDLCD(d.name, d.version, name)
	return loadstring(data)
end


-- RUN engine RUN !!
dofile("/engine/init.lua")
