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
	self.name = name or "default"
	self:loadGenericProfile()

	self.auth = false

	if self.generic.online and self.generic.online.login and self.generic.online.pass then
		self.login = self.generic.online.login
		self.pass = self.generic.online.pass
		self:tryAuth()
		self:getConfigs("generic")
		self:syncOnline("generic")
	end
end

function _M:loadData(f, where)
	setfenv(f, where)
	local ok, err = pcall(f)
	if not ok and err then error(err) end
end

--- Loads profile generic profile from disk
function _M:loadGenericProfile()
	local d = "/profiles/"..self.name.."/generic/"
	fs.mount(engine.homepath, "/")
	for i, file in ipairs(fs.list(d)) do

		if file:find(".profile$") then
			local f, err = loadfile(d..file)
			if not f and err then error(err) end
			local field = file:gsub(".profile$", "")
			self.generic[field] = self.generic[field] or {}
			self:loadData(f, self.generic[field])
			if not self.generic[field].__uuid then self.generic[field].__uuid = util.uuid() end
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
			if not f and err then error(err) end
			local field = file:gsub(".profile$", "")
			self.modules[short_name][field] = self.modules[short_name][field] or {}
			self:loadData(f, self.modules[short_name][field])
			if not self.modules[short_name][field].__uuid then self.modules[short_name][field].__uuid = util.uuid() end
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
	if not f then print("[PROFILES] cannot save generic data ", name, data, "it does not parse:") error(err) end
	local ok, err = pcall(f)
	if not ok and err then print("[PROFILES] cannot save generic data", name, data, "it does not parse") error(err) end

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
	if not f then print("[PROFILES] cannot save module data ", name, data, "it does not parse:") error(err) end
	local ok, err = pcall(f)
	if not ok and err then print("[PROFILES] cannot save module data", name, data, "it does not parse") error(err) end

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


-----------------------------------------------------------------------
-- Online stuff
-----------------------------------------------------------------------

function _M:rpc(data)
	print("[ONLINE PROFILE] rpc called", "http://te4.org/lua/profilesrpc.ws/"..data.action)
	local body, status = http.request("http://te4.org/lua/profilesrpc.ws/"..data.action, "json="..url.escape(json.encode(data)))
	if not body then return end
	return json.decode(body)
end

function _M:tryAuth()
	print("[ONLINE PROFILE] auth")
	local data = self:rpc{action="TryAuth", login=self.login, pass=self.pass}
	if not data then print("[ONLINE PROFILE] not auth") return end
	print("[ONLINE PROFILE] auth as ", data.name, data.hash)
	self.auth = data
end

function _M:getConfigs(module)
	if not self.auth then return end
	local data = self:rpc{action="GetConfigs", login=self.login, hash=self.auth.hash, module=module}
	if not data then print("[ONLINE PROFILE] get configs") return end
	for name, val in pairs(data) do
		print("[ONLINE PROFILE] config ", name)

		local field = name
		local f, err = loadstring(val)
		if not f and err then error(err) end
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

function _M:setConfigs(module, name, val)
	if not self.auth then return end

	if type(val) ~= "string" then val = serialize(val) end

	local data = self:rpc{action="SetConfigs", login=self.login, hash=self.auth.hash, module=module, data={[name] = val}}
	if not data then return end
	print("[ONLINE PROFILE] saved ", module, name, val)
end

function _M:syncOnline(module)
	if not self.auth then return end
	local sync = self.generic
	if module ~= "generic" then sync = self.modules[module] end
	if not sync then return end

	local data = {}
	for k, v in pairs(sync) do if k ~= "online" then data[k] = serialize(v) end end

	local data = self:rpc{action="SetConfigs", login=self.login, hash=self.auth.hash, module=module, data=data}
	if not data then return end
	print("[ONLINE PROFILE] saved ", module)
end

function _M:newProfile(Login, Name, Password, Email)
	print("[ONLINE PROFILE] profile options ", Login, Email, Name, Password)
	local data = self:rpc{action="NewProfile", login=Login, email=Email, name=Name, pass=Password}
	if not data then print("[ONLINE PROFILE] could not create") return end
	print("[ONLINE PROFILE] profile id ", data.id)
	self:performlogin(Login, Password, Name, Email)
end

function _M:performlogin(login, pass, name, email)
	self.login=login
	self.pass=pass
	print("[ONLINE PROFILE] attempting log in ", self.login, self.pass)
	self:tryAuth()
	if (profile.auth) then
		self.generic.online = { login=login, pass=pass,name=name or "", email=email or "" }
		self:saveGenericProfile("online", self.generic.online)
		self:getConfigs("generic")
		self:syncOnline("generic")
	end
end

function _M:logOut()
	profile.generic.online = nil
	profile.auth = nil
	local d = "/profiles/"..self.name.."/generic/"
	fs.mount(engine.homepath, "/")
	fs.delete(d.."online.profile")
end

function _M:checkFirstRun()
	local result = self.generic.firstrun
	if not result then
		firstrun = { When=os.time() }
		self:saveGenericProfile("firstrun", firstrun, false)
	end
	return result
end