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

require "engine.class"
local http = require "socket.http"
local url = require "socket.url"
local ltn12 = require "ltn12"
local lanes = require "lanes"
local Dialog = require "engine.ui.Dialog"
require "Json2"

------------------------------------------------------------
-- some simple serialization stuff
------------------------------------------------------------
local function basicSerialize(o)
	if type(o) == "number" or type(o) == "boolean" then
		return tostring(o)
	elseif type(o) == "function" then
		return string.format("loadstring(%q)", string.dump(o))
	else   -- assume it is a string
		return string.format("%q", o)
	end
end

local function serialize_data(outf, name, value, saved, filter, allow, savefile, force)
	saved = saved or {}       -- initial value
	outf(name, " = ")
	if type(value) == "number" or type(value) == "string" or type(value) == "boolean" or type(value) == "function" then
		outf(basicSerialize(value), "\n")
	elseif type(value) == "table" then
			saved[value] = name   -- save name for next time
			outf("{}\n")     -- create a new table

			for k,v in pairs(value) do      -- save its fields
				local fieldname
				fieldname = string.format("%s[%s]", name, basicSerialize(k))
				serialize_data(outf, fieldname, v, saved, {new=true}, false, savefile, false)
			end
	else
		error("cannot save a " .. type(value) .. " ("..name..")")
	end
end

local function serialize(data)
	local tbl = {}
	local outf = function(...) for i,str in ipairs{...} do table.insert(tbl, str) end end
	for k, e in pairs(data) do
		serialize_data(outf, tostring(k), e)
	end
	return table.concat(tbl)
end
------------------------------------------------------------


--- Handles the player profile, possibly online
module(..., package.seeall, class.make)

function _M:init(name)
	self.generic = {}
	self.modules = {}
	self.evt_cbs = {}
	self.name = name or "default"
	self:loadGenericProfile()

	self.auth = false

	if self.generic.online and self.generic.online.login and self.generic.online.pass then
		self.login = self.generic.online.login
		self.pass = self.generic.online.pass
		self:tryAuth()
	end
end

function _M:loadData(f, where)
	setfenv(f, where)
	local ok, err = pcall(f)
	if not ok and err then print("Error executing data", err) end
end

--- Loads profile generic profile from disk
function _M:loadGenericProfile()
	local d = "/profiles/"..self.name.."/generic/"
	fs.mount(engine.homepath, "/")
	for i, file in ipairs(fs.list(d)) do

		if file:find(".profile$") then
			local f, err = loadfile(d..file)
			if not f and err then
				print("Error loading data profile", file, err)
			else
				local field = file:gsub(".profile$", "")
				self.generic[field] = self.generic[field] or {}
				self:loadData(f, self.generic[field])
				if not self.generic[field].__uuid then self.generic[field].__uuid = util.uuid() end
			end
		end
	end

	fs.umount(engine.homepath)
end

--- Loads profile module profile from disk
function _M:loadModuleProfile(short_name)
	local d = "/profiles/"..self.name.."/modules/"..short_name.."/"
	fs.mount(engine.homepath, "/")
	print("[Module Profile] ", engine.homepath.."/"..d)
	self.modules[short_name] = self.modules[short_name] or {}
	for i, file in ipairs(fs.list(d)) do
		if file:find(".profile$") then
			local f, err = loadfile(d..file)
			if not f and err then
				print("Error loading data profile", file, err)
			else
				local field = file:gsub(".profile$", "")
				self.modules[short_name][field] = self.modules[short_name][field] or {}
				self:loadData(f, self.modules[short_name][field])
				if not self.modules[short_name][field].__uuid then self.modules[short_name][field].__uuid = util.uuid() end
			end
		end
	end

	fs.umount(engine.homepath)

	self:getConfigs(short_name)
	self:syncOnline(short_name)

	self.mod = self.modules[short_name]
	self.mod_name = short_name
end

--- Saves a profile data
function _M:saveGenericProfile(name, data, nosync)
	data = serialize(data)

	-- Check for readability
	local f, err = loadstring(data)
	if not f then print("[PROFILES] cannot save generic data ", name, data, "it does not parse:") print(err) return end
	setfenv(f, {})
	local ok, err = pcall(f)
	if not ok and err then print("[PROFILES] cannot save generic data", name, data, "it does not parse") print(err) return end

	local restore = fs.getWritePath()
	fs.setWritePath(engine.homepath)
	fs.mkdir("/profiles/"..self.name.."/generic/")
	local f = fs.open("/profiles/"..self.name.."/generic/"..name..".profile", "w")
	f:write(data)
	f:close()
	if restore then fs.setWritePath(restore) end

	if not nosync then self:setConfigs("generic", name, data) end
end

--- Saves a module profile data
function _M:saveModuleProfile(name, data, module, nosync)
	data = serialize(data)
	module = module or self.mod_name

	-- Check for readability
	local f, err = loadstring(data)
	if not f then print("[PROFILES] cannot save module data ", name, data, "it does not parse:") print(err) return end
	setfenv(f, {})
	local ok, err = pcall(f)
	if not ok and err then print("[PROFILES] cannot save module data", name, data, "it does not parse") print(err) return end

	local restore = fs.getWritePath()
	fs.setWritePath(engine.homepath)
	fs.mkdir("/profiles/"..self.name.."/modules/")
	fs.mkdir("/profiles/"..self.name.."/modules/"..module.."/")
	local f = fs.open("/profiles/"..self.name.."/modules/"..module.."/"..name..".profile", "w")
	f:write(data)
	f:close()
	if restore then fs.setWritePath(restore) end

	if not nosync then self:setConfigs(module, name, data) end
end

function _M:checkFirstRun()
	local result = self.generic.firstrun
	if not result then
		firstrun = { When=os.time() }
		self:saveGenericProfile("firstrun", firstrun, false)
	end
	return result
end

function _M:performlogin(login, pass)
	self.login=login
	self.pass=pass
	print("[ONLINE PROFILE] attempting log in ", self.login)
	self.auth_tried = nil
	self:tryAuth()
	self:waitFirstAuth()
	if (profile.auth) then
		self.generic.online = { login=login, pass=pass }
		self:saveGenericProfile("online", self.generic.online)
		self:getConfigs("generic")
		self:syncOnline("generic")
	end
end

-----------------------------------------------------------------------
-- Events from the profile thread
-----------------------------------------------------------------------

function _M:waitEvent(name, cb)
	-- Wait anwser, this blocks thegame but cant really be avoided :/
	local stop = false
	local first = true
	while not stop do
		if not first then
			core.display.forceRedraw()
			core.game.sleep(50)
		end
		local evt = core.profile.popEvent()
		while evt do
			if type(game) == "table" then evt = game:handleProfileEvent(evt)
			else evt = self:handleEvent(evt) end
--			print("==== waiting event", name, evt.e)
			if evt.e == name then
				stop = true
				cb(evt)
				break
			end
			evt = core.profile.popEvent()
		end
		first = false
	end
end

function _M:waitFirstAuth(timeout)
	if self.auth_tried and self.auth_tried >= 1 then return end
	if not self.waiting_auth then return end
	print("[PROFILE] waiting for first auth")
	local first = true
	timeout = timeout or 20
	while self.waiting_auth and timeout > 0 do
		if not first then
			core.display.forceRedraw()
			core.game.sleep(50)
		end
		local evt = core.profile.popEvent()
		while evt do
			if type(game) == "table" then game:handleProfileEvent(evt)
			else self:handleEvent(evt) end
			if not self.waiting_auth then break end
			evt = core.profile.popEvent()
		end
		first = false
		timeout = timeout - 1
	end
end

function _M:eventAuth(e)
	self.waiting_auth = false
	self.auth_tried = (self.auth_tried or 0) + 1
	if e.ok then
		self.auth = e.ok:unserialize()
		print("[PROFILE] Main thread got authed", self.auth.name, self.auth.email, self.auth.drupid)
		self:getConfigs("generic", function(e) self:syncOnline(e.module) end)
	end
end

function _M:eventGetNews(e)
	if e.news and self.evt_cbs.GetNews then
		self.evt_cbs.GetNews(e.news:unserialize())
		self.evt_cbs.GetNews = nil
	end
end

function _M:eventGetConfigs(e)
	local data = e.data:unserialize()
	local module = e.module
	if not data then print("[ONLINE PROFILE] get configs") return end
	for name, val in pairs(data) do
		print("[ONLINE PROFILE] config ", name)

		local field = name
		local f, err = loadstring(val)
		if not f and err then
			print("Error loading profile config: ", err)
		else
			if module == "generic" then
				self.generic[field] = self.generic[field] or {}
				self:loadData(f, self.generic[field])
				self:saveGenericProfile(field, self.generic[field], true)
			else
				self.modules[module] = self.modules[module] or {}
				self.modules[module][field] = self.modules[module][field] or {}
				self:loadData(f, self.modules[module][field])
				self:saveModuleProfile(field, self.modules[module][field], module, true)
			end
		end
	end
	if self.evt_cbs.GetConfigs then self.evt_cbs.GetConfigs(e) self.evt_cbs.GetConfigs = nil end
end

--- Got an event from the profile thread
function _M:handleEvent(e)
	e = e:unserialize()
	if not e then return end
	if self["event"..e.e] then self["event"..e.e](self, e) end
	return e
end

-----------------------------------------------------------------------
-- Orders for the profile thread
-----------------------------------------------------------------------

function _M:getNews(callback)
	print("[ONLINE PROFILE] get news")
	self.evt_cbs.GetNews = callback
	core.profile.pushOrder("o='GetNews'")
end

function _M:tryAuth()
	print("[ONLINE PROFILE] auth")
	core.profile.pushOrder(table.serialize{o="Login", l=self.login, p=self.pass})
	self.waiting_auth = true
end

function _M:logOut()
	core.profile.pushOrder(table.serialize{o="Logoff"})
	profile.generic.online = nil
	profile.auth = nil

	local restore = fs.getWritePath()
	fs.setWritePath(engine.homepath)
	fs.delete("/profiles/"..self.name.."/generic/online.profile")
	if restore then fs.setWritePath(restore) end
end

function _M:getConfigs(module, cb)
	self:waitFirstAuth()
	if not self.auth then return end
	self.evt_cbs.GetConfigs = cb
	core.profile.pushOrder(table.serialize{o="GetConfigs", module=module})
end

function _M:setConfigs(module, name, val)
	self:waitFirstAuth()
	if not self.auth then return end
	if name == "online" then return end
	if type(val) ~= "string" then val = serialize(val) end
	core.profile.pushOrder(table.serialize{o="SetConfigs", module=module, data=table.serialize{[name] = val}})
end

function _M:syncOnline(module)
	self:waitFirstAuth()
	if not self.auth then return end
	local sync = self.generic
	if module ~= "generic" then sync = self.modules[module] end
	if not sync then return end

	local data = {}
	for k, v in pairs(sync) do if k ~= "online" then data[k] = serialize(v) end end

	core.profile.pushOrder(table.serialize{o="SetConfigs", module=module, data=table.serialize(data)})
end

function _M:checkModuleHash(module, md5)
	self.hash_valid = false
--	if not self.auth then return nil, "no online profile active" end
	if config.settings.cheat then return nil, "cheat mode active" end
	if game and game:isTainted() then return nil, "savefile tainted" end
	core.profile.pushOrder(table.serialize{o="CheckModuleHash", module=module, md5=md5})

	self:waitEvent("CheckModuleHash", function(e) ok = e.ok end)

	if not ok then return nil, "bad game version" end
	print("[ONLINE PROFILE] module hash is valid")
	self.hash_valid = true
	return true
end

function _M:sendError(what, err)
	print("[ONLINE PROFILE] sending error")
	core.profile.pushOrder(table.serialize{o="SendError", login=self.login, what=what, err=err, module=game.__mod_info.short_name, version=game.__mod_info.version_name})
end

function _M:registerNewCharacter(module)
	if not self.auth or not self.hash_valid then return end
	local dialog = Dialog:simplePopup("Registering character", "Character is being registered on http://te4.org/") dialog.__showup = nil core.display.forceRedraw()

	core.profile.pushOrder(table.serialize{o="RegisterNewCharacter", module=module})
	local uuid = nil
	self:waitEvent("RegisterNewCharacter", function(e) uuid = e.uuid end)

	game:unregisterDialog(dialog)
	if not uuid then return end
	print("[ONLINE PROFILE] new character UUID ", uuid)
	return uuid
end

function _M:registerSaveChardump(module, uuid, title, tags, data)
	if not self.auth or not self.hash_valid then return end
	core.profile.pushOrder(table.serialize{o="SaveChardump",
		module=module,
		uuid=uuid,
		data=data,
		metadata=table.serialize{tags=tags, title=title},
	})
	print("[ONLINE PROFILE] saved character ", uuid)
end

function _M:newProfile(Login, Name, Password, Email)
	print("[ONLINE PROFILE] profile options ", Login, Email, Name)

	core.profile.pushOrder(table.serialize{o="NewProfile2", login=Login, email=Email, name=Name, pass=Password})
	local id = nil
	self:waitEvent("NewProfile2", function(e) id = e.uid end)

	if not id then print("[ONLINE PROFILE] could not create") return end
	print("[ONLINE PROFILE] profile id ", id)
	self:performlogin(Login, Password)
end
