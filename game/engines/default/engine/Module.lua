
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

require "engine.class"
local lanes = require "lanes"
local Dialog = require "engine.ui.Dialog"
local Savefile = require "engine.Savefile"
require "engine.PlayerProfile"

--- Handles dialog windows
module(..., package.seeall, class.make)

--- Create a version string for the module version
-- Static
function _M:versionString(mod)
	return ("%s-%d.%d.%d"):format(mod.short_name, mod.version[1], mod.version[2], mod.version[3])
end

--- List all available modules
-- Static
function _M:listModules(incompatible, moddir_filter)
	local ms = {}
	local allmounts = fs.getSearchPath(true)
	fs.mount(engine.homepath, "/")

	local knowns = {}
	for i, short_name in ipairs(fs.list("/modules/")) do
		if not moddir_filter or moddir_filter(short_name) then
			local mod = self:createModule(short_name, incompatible)
			if mod then
				if not knowns[mod.short_name] then
					table.insert(ms, {short_name=mod.short_name, name=mod.name, versions={}})
					knowns[mod.short_name] = ms[#ms]
				end
				local v = knowns[mod.short_name].versions
				v[#v+1] = mod
			end
		end
	end

	table.sort(ms, function(a, b)
	print(a.short_name,b.short_name)
		if a.short_name == "tome" then return 1
		elseif b.short_name == "tome" then return nil
		else return a.name < b.name
		end
	end)

	for i, m in ipairs(ms) do
		table.sort(m.versions, function(b, a)
			return a.version[1] * 1000000 + a.version[2] * 1000 + a.version[3] * 1 < b.version[1] * 1000000 + b.version[2] * 1000 + b.version[3] * 1
		end)
		print("* Module: "..m.short_name)
		for i, mod in ipairs(m.versions) do
			print(" ** "..mod.version[1].."."..mod.version[2].."."..mod.version[3])
			ms[mod.version_string] = mod
		end
		ms[m.short_name] = m.versions[1]
	end

	fs.reset()
	fs.mountAll(allmounts)

	return ms
end

function _M:createModule(short_name, incompatible)
	local dir = "/modules/"..short_name
	print("Creating module", short_name, ":: (as dir)", fs.exists(dir.."/init.lua"), ":: (as team)", short_name:find(".team$"), "")
	if fs.exists(dir.."/init.lua") then
		local mod = self:loadDefinition(dir, nil, incompatible)
		if mod and mod.short_name then
			return mod
		end
	elseif short_name:find(".team$") then
		fs.mount(fs.getRealPath(dir), "/testload", false)
		local mod
		if fs.exists("/testload/mod/init.lua") then
			mod = self:loadDefinition("/testload", dir, incompatible)
		end
		fs.umount(fs.getRealPath(dir))
		if mod and mod.short_name then return mod end
	end
end

--- Get a module definition from the module init.lua file
function _M:loadDefinition(dir, team, incompatible)
	local mod_def = loadfile(team and (dir.."/mod/init.lua") or (dir.."/init.lua"))
--	print("Loading module definition from", team and (dir.."/mod/init.lua") or (dir.."/init.lua"))
	if mod_def then
		-- Call the file body inside its own private environment
		local mod = {rng=rng, config=config}
		setfenv(mod_def, mod)
		mod_def()
		mod.rng = nil

		if not mod.long_name or not mod.name or not mod.short_name or not mod.version or not mod.starter then
			print("Bad module definition", mod.long_name, mod.name, mod.short_name, mod.version, mod.starter)
			return
		end

		-- Test engine version
		local eng_req = engine.version_string(mod.engine)
		mod.version_string = self:versionString(mod)
		if not __available_engines.__byname[eng_req] then
			print("Module mismatch engine version "..mod.version_string.." using engine "..eng_req)
			if incompatible then mod.incompatible = true
			else return end
		end

		-- Make a function to activate it
		mod.load = function(mode)
			if mode == "setup" then
				core.display.setWindowTitle(mod.long_name)
				self:setupWrite(mod)
				if not team then
					fs.mount(fs.getRealPath(dir), "/mod", false)
					fs.mount(fs.getRealPath(dir).."/data/", "/data", false)
					if fs.exists(dir.."/engine") then fs.mount(fs.getRealPath(dir).."/engine/", "/engine", false) end
				else
					local src = fs.getRealPath(team)
					fs.mount(src, "/", false)

					-- Addional teams
					for i, t in ipairs(mod.teams or {}) do
						local base = team:gsub("/[^/]+$", "/")
						local file = base..t[1]:gsub("#name#", mod.short_name):gsub("#version#", ("%d.%d.%d"):format(mod.version[1], mod.version[2], mod.version[3]))
						if fs.exists(file) then
							print("Mounting additional team file:", file)
							local src = fs.getRealPath(file)
							fs.mount(src, "/", false)
						end
					end
				end

				-- Load moonscript support
				if mod.moonscript then
					require "moonscript"
					require "moonscript.errors"
				end
			elseif mode == "init" then
				local m = require(mod.starter)
				m[1].__session_time_played_start = os.time()
				m[1].__mod_info = mod
				print("[MODULE LOADER] loading module", mod.long_name, "["..mod.starter.."]", "::", m[1] and m[1].__CLASSNAME, m[2] and m[2].__CLASSNAME)
				return m[1], m[2]
			end
		end

		print("Loaded module definition for "..mod.version_string.." using engine "..eng_req)
		return mod
	end
end

--- List all available savefiles
-- Static
function _M:listSavefiles(moddir_filter)
	local allmounts = fs.getSearchPath(true)
	fs.mount(engine.homepath..fs.getPathSeparator(), "/tmp/listsaves")

	local mods = self:listModules(nil, moddir_filter)
	for _, mod in ipairs(mods) do
		local lss = {}
		print("Listing saves for module", mod.short_name)
		for i, short_name in ipairs(fs.list("/tmp/listsaves/"..mod.short_name.."/save/")) do
			local dir = "/tmp/listsaves/"..mod.short_name.."/save/"..short_name
			if fs.exists(dir.."/game.teag") then
				local def = self:loadSavefileDescription(dir)
				if def then
					if fs.exists(dir.."/cur.png") then
						def.screenshot = core.display.loadImage(dir.."/cur.png")
					end

					table.insert(lss, def)
				end
			end
		end
		mod.savefiles = lss

		table.sort(lss, function(a, b)
			return a.name < b.name
		end)
	end

	fs.reset()
	fs.mountAll(allmounts)

	return mods
end

--- List all available vault characters
-- Static
function _M:listVaultSaves()
--	fs.mount(engine.homepath, "/tmp/listsaves")

	local mods = self:listModules()
	for _, mod in ipairs(mods) do
		local lss = {}
		for i, short_name in ipairs(fs.list("/"..mod.short_name.."/vault/")) do
			local dir = "/"..mod.short_name.."/vault/"..short_name
			if fs.exists(dir.."/character.teac") then
				local def = self:loadSavefileDescription(dir)
				if def then
					table.insert(lss, def)
				end
			end
		end
		mod.savefiles = lss

		table.sort(lss, function(a, b)
			return a.name < b.name
		end)
	end

--	fs.umount(engine.homepath)

	return mods
end

--- List all available vault characters for the currently running module
-- Static
function _M:listVaultSavesForCurrent()
	local lss = {}
	for i, short_name in ipairs(fs.list("/vault/")) do
		local dir = "/vault/"..short_name
		if fs.exists(dir.."/character.teac") then
			local def = self:loadSavefileDescription(dir)
			if def then
				table.insert(lss, def)
			end
		end
	end

	table.sort(lss, function(a, b)
		return a.name < b.name
	end)
	return lss
end

--- List all available addons
function _M:listAddons(mod, ignore_compat)
	local adds = {}
	local load = function(dir, teaa)
		local add_def = loadfile(dir.."/init.lua")
		if add_def then
			local add = {}
			setfenv(add_def, add)
			add_def()

			if (ignore_compat or engine.version_string(add.version) == engine.version_string(mod.version)) and add.for_module == mod.short_name then
				add.dir = dir
				add.teaa = teaa
				add.natural_compatible = engine.version_string(add.version) == engine.version_string(mod.version)
				add.version_txt = ("%d.%d.%d"):format(add.version[1], add.version[2], add.version[3])
				if add.dlc and not profile:isDonator(add.dlc) then add.dlc = "no" end
				adds[#adds+1] = add
			end
		end
	end

	for i, short_name in ipairs(fs.list("/addons/")) do if short_name:find("^"..mod.short_name.."%-") then
		local dir = "/addons/"..short_name
		print("Checking addon", short_name, ":: (as dir)", fs.exists(dir.."/init.lua"), ":: (as teaa)", short_name:find(".teaa$"), "")
		if fs.exists(dir.."/init.lua") then
			load(dir, nil)
		elseif short_name:find(".teaa$") then
			fs.mount(fs.getRealPath(dir), "/testload", false)
			local mod
			if fs.exists("/testload/init.lua") then
				load("/testload", dir)
			end
			fs.umount(fs.getRealPath(dir))
		end
	end end

	table.sort(adds, function(a, b) return a.weight < b.weight end)
	return adds
end

function _M:loadAddons(mod, saveuse)
	local adds = self:listAddons(mod, true)

	if saveuse then saveuse = table.reverse(saveuse) end

	-- Filter based on settings
	for i = #adds, 1, -1 do
		local add = adds[i]
		local removed = false
		if saveuse then
			if not saveuse[add.short_name] then
				print("Removing addon "..add.short_name..": not allowed by savefile")
				table.remove(adds, i) removed = true
			end
		else
			if add.dlc == "no" then
				print("Removing addon "..add.short_name..": DLC required")
				table.remove(adds, i) removed = true
			elseif config.settings.addons[add.for_module] and config.settings.addons[add.for_module][add.short_name] ~= nil then
				-- Forbidden by config
				if config.settings.addons[add.for_module][add.short_name] == false then
					print("Removing addon "..add.short_name..": not allowed by config")
					table.remove(adds, i) removed = true
				end
			else
				-- Forbidden by version
				if not add.natural_compatible then
					table.remove(adds, i) removed = true
				end
			end
		end

		if add.dlc and add.dlc_files then
			if not removed and add.dlc_files.classes then
				for _, name in ipairs(add.dlc_files.classes) do
					print("Preloading DLC class", name)
					local data = profile:getDLCD(add.for_module.."-"..add.short_name, ("%d.%d.%d"):format(add.version[1],add.version[2],add.version[3]), name:gsub("%.", "/")..".lua")
					if data and data ~= '' then
						profile.dlc_files.classes[name] = data
					else
						print("Removing addon "..add.short_name..": DLC class not received")
						table.remove(adds, i) removed = true
						break
					end
				end
			end
		end
	end

	mod.addons = {}
	for i, add in ipairs(adds) do
		add.version_name = ("%s-%s-%d.%d.%d"):format(mod.short_name, add.short_name, add.version[1], add.version[2], add.version[3])

		print("Binding addon", add.long_name, add.teaa, add.version_name)
		local base, vbase
		if add.teaa then
			fs.mount(fs.getRealPath(add.teaa), "/loaded-addons/"..add.short_name, true)
			base = "bind::/loaded-addons/"..add.short_name
			vbase = "/loaded-addons/"..add.short_name
		else
			base = fs.getRealPath(add.dir)
			fs.mount(base, "/loaded-addons/"..add.short_name, true)
			vbase = "/loaded-addons/"..add.short_name
		end

		if add.data then fs.mount(base.."/data", "/data-"..add.short_name, true) print(" * with data") end
		if add.superload then fs.mount(base.."/superload", "/mod/addons/"..add.short_name.."/superload", true) print(" * with superload") end
		if add.overload then fs.mount(base.."/overload", "/", false) print(" * with overload") end
		if add.hooks then
			fs.mount(base.."/hooks", "/hooks/"..add.short_name, true)
			self:setCurrentHookDir("/hooks/"..add.short_name.."/")
			dofile("/hooks/"..add.short_name.."/load.lua")
			self:setCurrentHookDir(nil)
			print(" * with hooks")
		end

		-- Compute addon md5
		local md5 = require "md5"
		local md5s = {}
		local function fp(dir)
			for i, file in ipairs(fs.list(dir)) do
				local f = dir.."/"..file
				if fs.isdir(f) then
					fp(f)
				elseif f:find("%.lua$") then
					local fff = fs.open(f, "r")
					if fff then
						local data = fff:read(10485760)
						if data and data ~= "" then
							md5s[#md5s+1] = f..":"..md5.sumhexa(data)
						end
						fff:close()
					end
				end
			end
		end
		local hash_valid, hash_err
		local t = core.game.getTime()
		if config.settings.cheat then
			hash_valid, hash_err = false, "cheat mode skipping addon validation"
		else
			fp(vbase)
			table.sort(md5s)
			table.print(md5s)
			local fmd5 = md5.sumhexa(table.concat(md5s))
			print("[MODULE LOADER] addon ", add.short_name, " MD5", fmd5, "computed in ", core.game.getTime() - t, vbase)
			hash_valid, hash_err = profile:checkAddonHash(mod.short_name, add.version_name, fmd5)
		end

		if hash_err then hash_err = hash_err .. " [addon: "..add.short_name.."]" end
		add.hash_valid, add.hash_err = hash_valid, hash_err

		mod.addons[add.short_name] = add
	end
--	os.exit()
end

-- Grab some fun facts!
function _M:selectFunFact(ffdata)
	local l = {}

	print("Computing fun facts")
	print(pcall(function()

		if ffdata.total_time then l[#l+1] = "Total playtime of all registered players:\n"..ffdata.total_time end
		if ffdata.top_five_races then l[#l+1] = ("#LIGHT_BLUE#%s#WHITE# is one of the top five played races"):format(rng.table(ffdata.top_five_races).name) end
		if ffdata.top_five_classes then l[#l+1] = ("#LIGHT_BLUE#%s#WHITE# is one of the top five played classes"):format(rng.table(ffdata.top_five_classes).name) end
		if ffdata.top_ten_killer then l[#l+1] = ("#CRIMSON#%s#WHITE# is one of the top ten killers"):format(rng.table(ffdata.top_ten_killer).name:capitalize()) end
		if ffdata.top_ten_raceclass then l[#l+1] = ("#LIGHT_BLUE#%s#WHITE# is one of the top ten race/class combo"):format(rng.table(ffdata.top_ten_raceclass).name:capitalize()) end
		if ffdata.nb_players then l[#l+1] = ("There are currently %d people playing online"):format(ffdata.nb_players) end
		if ffdata.total_deaths then l[#l+1] = ("The character's vault has registered a total of #RED#%d#WHITE# character's deaths"):format(ffdata.total_deaths) end
		if ffdata.wins_this_version then l[#l+1] = ("The character's vault has registered a total of #LIGHT_BLUE#%d#WHITE# winners for the current version"):format(ffdata.wins_this_version) end
		if ffdata.latest_donator then l[#l+1] = ("The latest donator is #LIGHT_GREEN#%s#WHITE#. Many thanks to all donators, you are keeping this game alive!"):format(ffdata.latest_donator) end

	end))
	table.print(l)

	return #l > 0 and rng.table(l) or false
end

--- Make a module loadscreen
function _M:loadScreen(mod)
	core.display.forceRedraw()
	core.wait.enable(10000, function()
		local has_max = mod.loading_wait_ticks
		if has_max then core.wait.addMaxTicks(has_max) end
		local i, max, dir = has_max or 20, has_max or 20, -1
		local backname = util.getval(mod.background_name) or "tome"

		local bkgs = core.display.loadImage("/data/gfx/background/"..backname..".png") or core.display.loadImage("/data/gfx/background/tome.png")
		local sw, sh = core.display.size()
		local bw, bh = bkgs:getSize()
		local bkg = {bkgs:glTexture()}

		local logo = {(core.display.loadImage("/data/gfx/background/"..backname.."-logo.png") or core.display.loadImage("/data/gfx/background/tome-logo.png")):glTexture()}

		local left = {core.display.loadImage("/data/gfx/waiter/left.png"):glTexture()}
		local right = {core.display.loadImage("/data/gfx/waiter/right.png"):glTexture()}
		local middle = {core.display.loadImage("/data/gfx/waiter/middle.png"):glTexture()}
		local bar = {core.display.loadImage("/data/gfx/waiter/bar.png"):glTexture()}

		local font = core.display.newFont("/data/font/DroidSans.ttf", 12)
		local bfont = core.display.newFont("/data/font/DroidSans.ttf", 16)

		local dw, dh = math.floor(sw / 2), left[7]
		local dx, dy = math.floor((sw - dw) / 2), sh - dh

		local funfacts = nil
		local ffdata = profile.funfacts

		local tip = nil
		if mod.load_tips then pcall(function()
			local l = rng.table(mod.load_tips)
			local img = nil
			if l.image then
				local i = core.display.loadImage(l.image)
				if i then img = {i:glTexture()} end
			end
			local text = bfont:draw(l.text, dw - (img and img[6] or 0), 255, 255, 255)
			local text_h = #text * text[1].h

			local Base = require "engine.ui.Base"
			local frame = Base:makeFrame("ui/tooltip/", dw + 30, math.max((img and img[7] or 0) + (l.img_y_off or 0), text_h) + 30)

			tip = function(x, y)
				y = y - frame.h - 30
				Base:drawFrame(frame, x+1, y+1, 0, 0, 0, 0.3)
				Base:drawFrame(frame, x-3, y-3, 1, 1, 1, 0.75)
				x = x + 10
				y = y + 10

				if img then
					img[1]:toScreenFull(x, y + (l.img_y_off or 0), img[6], img[7], img[2], img[3])
					x = x + img[6] + 7
				end

				y = y - 10 + math.floor((frame.h - text_h) / 2)
				for i = 1, #text do
					local item = text[i]
					if not item then break end
					item._tex:toScreenFull(x+2, y+2, item.w, item.h, item._tex_w, item._tex_h, 0, 0, 0, 0.8)
					item._tex:toScreenFull(x, y, item.w, item.h, item._tex_w, item._tex_h)
					y = y + item.h
				end
			end
		end) end

		local ffw = math.ceil(sw / 4)
		if ffdata then
			local str = self:selectFunFact(ffdata)
			if str then pcall(function()
				local text, _, tw = font:draw(str, ffw, 255, 255, 255)
				local text_h = #text * text[1].h
				ffw = math.min(ffw, tw)

				local Base = require "engine.ui.Base"
				local frame = Base:makeFrame("ui/tooltip/", ffw + 30, text_h + 30)
				funfacts = function(x, y)
					x = x - ffw - 30
					Base:drawFrame(frame, x+1, y+1, 0, 0, 0, 0.3)
					Base:drawFrame(frame, x-3, y-3, 1, 1, 1, 0.5)
					x = x + 10
					y = y + 10

					y = y - 10 + math.floor((frame.h - text_h) / 2)
					for i = 1, #text do
						local item = text[i]
						if not item then break end
						item._tex:toScreenFull(x+2, y+2, item.w, item.h, item._tex_w, item._tex_h, 0, 0, 0, 0.5)
						item._tex:toScreenFull(x, y, item.w, item.h, item._tex_w, item._tex_h, 1, 1, 1, 0.85)
						y = y + item.h
					end
				end
			end) end
		end

		return function()
			-- Background
			local x, y = 0, 0
			if bw > bh then
				bh = sw * bh / bw
				bw = sw
				y = (sh - bh) / 2
			else
				bw = sh * bw / bh
				bh = sh
				x = (sw - bw) / 2
			end
			bkg[1]:toScreenFull(x, y, bw, bh, bw * bkg[4], bh * bkg[5])

			-- Logo
			logo[1]:toScreenFull(0, 0, logo[6], logo[7], logo[2], logo[3])

			-- Progressbar
			local x
			if has_max then
				i, max = core.wait.getTicks()
				i = util.bound(i, 0, max)
			else
				i = i + dir
				if dir > 0 and i >= max then dir = -1
				elseif dir < 0 and i <= -max then dir = 1
				end
			end

			local x = dw * (i / max)
			local x2 = x + dw
			x = util.bound(x, 0, dw)
			x2 = util.bound(x2, 0, dw)
			if has_max then x, x2 = 0, x end
			local w, h = x2 - x, dh

			middle[1]:toScreenFull(dx, dy, dw, middle[7], middle[2], middle[3])
			bar[1]:toScreenFull(dx + x, dy, w, bar[7], bar[2], bar[3])
			left[1]:toScreenFull(dx - left[6] + 5, dy + (middle[7] - left[7]) / 2, left[6], left[7], left[2], left[3])
			right[1]:toScreenFull(dx + dw - 5, dy + (middle[7] - right[7]) / 2, right[6], right[7], right[2], right[3])

			if has_max then
				font:setStyle("bold")
				local txt = {core.display.drawStringBlendedNewSurface(font, math.min(100, math.floor(core.wait.getTicks() * 100 / max)).."%", 255, 255, 255):glTexture()}
				font:setStyle("normal")
				txt[1]:toScreenFull(dx + (dw - txt[6]) / 2 + 2, dy + (bar[7] - txt[7]) / 2 + 2, txt[6], txt[7], txt[2], txt[3], 0, 0, 0, 0.6)
				txt[1]:toScreenFull(dx + (dw - txt[6]) / 2, dy + (bar[7] - txt[7]) / 2, txt[6], txt[7], txt[2], txt[3])
			end

			if tip then tip(dw / 2, dy) end
			if funfacts then funfacts(sw, 10) end
		end
	end)
	core.display.forceRedraw()
end


--- Instanciate the given module, loading it and creating a new game / loading an existing one
-- @param mod the module definition as given by Module:loadDefinition()
-- @param name the savefile name
-- @param new_game true if the game must be created (aka new character)
function _M:instanciate(mod, name, new_game, no_reboot)
	if not no_reboot then
		local eng_v = nil
		if not mod.incompatible then eng_v = ("%d.%d.%d"):format(mod.engine[1], mod.engine[2], mod.engine[3]) end
		util.showMainMenu(false, mod.engine[4], eng_v, mod.version_string, name, new_game)
		return
	end

	if mod.short_name == "boot" then profile.hash_valid = true end

	mod.version_name = ("%s-%d.%d.%d"):format(mod.short_name, mod.version[1], mod.version[2], mod.version[3])

	-- Turn based by default
	core.game.setRealtime(0)

	-- FOV Shape
	core.fov.set_algorithm("large_ass")
	core.fov.set_permissiveness("square")
	core.fov.set_actor_vision_size(1)
	core.fov.set_vision_shape("circle")

	-- Init the module directories
	fs.mount(engine.homepath, "/")
	mod.load("setup")

	-- Check the savefile if possible, to add to the progress bar size
	local savesize = 0
	local save = Savefile.new("")
	savesize = save:loadWorldSize() or 0
	save:close()

	-- Load the savefile if it exists, or create a new one if not (or if requested)
	local save = engine.Savefile.new(name)
	local save_desc
	if save:check() and not new_game then
		savesize = savesize + save:loadGameSize()
		save_desc = self:loadSavefileDescription(save.save_dir)
	end
	save:close()

	-- Display the loading bar
	profile.waiting_auth_no_redraw = true
	self:loadScreen(mod)
	core.wait.addMaxTicks(savesize)

	-- Check MD5sum with the server
	local md5 = require "md5"
	local md5s = {}
	local function fp(dir)
		for i, file in ipairs(fs.list(dir)) do
			local f = dir.."/"..file
			if fs.isdir(f) then
				fp(f)
			elseif f:find("%.lua$") then
				local fff = fs.open(f, "r")
				if fff then
					local data = fff:read(10485760)
					if data and data ~= "" then
						md5s[#md5s+1] = f..":"..md5.sumhexa(data)
					end
					fff:close()
				end
			end
		end
	end
	local hash_valid, hash_err
	local t = core.game.getTime()
	if config.settings.cheat then
		hash_valid, hash_err = false, "cheat mode skipping validation"
	else
		if mod.short_name ~= "boot" then
			fp("/mod")
			fp("/data")
			fp("/engine")
			table.sort(md5s)
			local fmd5 = md5.sumhexa(table.concat(md5s))
			print("[MODULE LOADER] module MD5", fmd5, "computed in ", core.game.getTime() - t)
			hash_valid, hash_err = profile:checkModuleHash(mod.version_name, fmd5)
		end
	end

	self:loadAddons(mod, save_desc and save_desc.addons)

	-- Check addons
	if hash_valid then
		for name, add in pairs(mod.addons) do
			if not add.hash_valid then
				hash_valid = false
				hash_err = add.hash_err or "?????? unknown ...."
				profile.hash_valid = false
				break
			end
		end
	end

	local addl = {}
	for name, add in pairs(mod.addons) do
		addl[#addl+1] = add.version_name
	end
	mod.full_version_string = mod.version_string.." ["..table.concat(addl, ';').."]"

	profile:addStatFields(unpack(mod.profile_stats_fields or {}))
	profile:setConfigsBatch(true)
	profile:loadModuleProfile(mod.short_name, mod)
	profile:currentCharacter(mod.full_version_string, "game did not tell us")

	-- Init the module code
	local M, W = mod.load("init")
	class:runInherited()
	_G.game = M.new()
	_G.game:setPlayerName(name)

	-- Load the world, or make a new one
	core.wait.enableManualTick(true)
	if W then
		local save = Savefile.new("")
		_G.world = save:loadWorld()
		save:close()
		if not _G.world then
			_G.world = W.new()
		end
		_G.world:run()
	end

	-- Load the savefile if it exists, or create a new one if not (or if requested)
	local save = engine.Savefile.new(_G.game.save_name)
	if save:check() and not new_game then
		local delay
		_G.game, delay = save:loadGame()
		delay()
	else
		save:delete()
	end
	save:close()
	core.wait.enableManualTick(false)

	-- And now run it!
	_G.game:prerun()
	_G.game:run()

	-- Try to bind some debug keys
	if _G.game.key and _G.game.key.setupRebootKeys then _G.game.key:setupRebootKeys() end

	-- Add user chat if needed
	if mod.allow_userchat and _G.game.key then
		profile.chat:setupOnGame()
		profile.chat:join("global")
		profile.chat:join(mod.short_name)
		profile.chat:join(mod.short_name.."-spoiler")
		profile.chat:selectChannel(mod.short_name)
	end

	-- Disable the profile if ungood
	if mod.short_name ~= "boot" then
		if not hash_valid then
			game.log("#LIGHT_RED#Online profile disabled(switching to offline profile) due to %s.", hash_err or "???")
		end
	end
	print("[MODULE LOADER] done loading module", mod.long_name)

	profile:saveGenericProfile("modules_loaded", {name=mod.short_name, nb={"inc", 1}})
	profile:setConfigsBatch(false)

	-- TODO: Replace this with loading quickhotkeys from the profile.
	if engine.interface.PlayerHotkeys then engine.interface.PlayerHotkeys:loadQuickHotkeys(mod.short_name, Savefile.hotkeys_file) end

	core.wait.disable()
	profile.waiting_auth_no_redraw = false

	core.display.resetAllFonts("normal")

	if mod.short_name ~= "boot" then profile:noMoreAuthWait() end
end

--- Setup write dir for a module
-- Static
function _M:setupWrite(mod)
	-- Create module directory
	fs.setWritePath(engine.homepath)
	fs.mkdir(mod.short_name)
	fs.mkdir(mod.short_name.."/save")

	-- Enter module directory
	local base = engine.homepath .. fs.getPathSeparator() .. mod.short_name
	fs.setWritePath(base)
	fs.mount(base, "/", false)
	return base
end

--- Get a savefile description from the savefile desc.lua file
function _M:loadSavefileDescription(dir)
	local ls_def = loadfile(dir.."/desc.lua")
	if ls_def then
		-- Call the file body inside its own private environment
		local ls = {}
		setfenv(ls_def, ls)
		ls_def()

		if not ls.name or not ls.description then return end
		ls.dir = dir
		print(" * save", ls.dir)
		return ls
	end
end

--- Loads a list of modules from te4.org/modules.lualist
-- Calling this function starts a background thread, which can be waited on by the returned lina object
-- @param src the url to load the list from, if nil it will default to te4.org
-- @return a linda object (see lua lanes documentation) which should be waited upon like this <code>local mylist = l:receive("moduleslist")</code>. Also returns a thread handle
function _M:loadRemoteList(src)
	local DownloadDialog = require "engine.dialogs.DownloadDialog"
	local d = DownloadDialog.new("Fetching updates", "http://te4.org/dl/t-engine/t-engine4-windows-1.0.0beta21.zip")
	d:startDownload()
end
