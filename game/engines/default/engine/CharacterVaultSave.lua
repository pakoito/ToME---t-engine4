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

require "engine.class"
local Savefile = require "engine.Savefile"

--- Handles a local characters vault saves
module(..., package.seeall, class.inherit(Savefile))

function _M:init(savefile, coroutine)
	Savefile.init(self, savefile, coroutine)

	fs.mkdir("/vault")
	self.short_name = savefile:gsub("[^a-zA-Z0-9_-.]", "_")
	self.save_dir = "/vault/"..self.short_name.."/"
	self.quickbirth_file = "/vault/"..self.short_name..".quickbirth"
	self.load_dir = "/tmp/loadsave/"
end

--- Get a savename for an entity
function _M:nameSaveEntity(e)
	e.__version = game.__mod_info.version
	return "character.teac"
end
--- Get a savename for an entity
function _M:nameLoadEntity(name)
	return "character.teac"
end

--- Save an entity
function _M:saveEntity(e, no_dialog)
	Savefile.saveEntity(self, e, no_dialog)

	local desc = game:getVaultDescription(e)
	local f = fs.open(self.save_dir.."desc.lua", "w")
	f:write(("module = %q\n"):format(game.__mod_info.short_name))
	f:write(("module_version = {%d,%d,%d}\n"):format(game.__mod_info.version[1], game.__mod_info.version[2], game.__mod_info.version[3]))
	f:write(("name = %q\n"):format(desc.name))
	f:write(("short_name = %q\n"):format(self.short_name))
	f:write("descriptors = {\n")
	for k, e in pairs(desc.descriptors or {}) do
		f:write(("\t[%q] = %q,\n"):format(k, e))
	end
	f:write("}\n")
	f:write(("description = %q\n"):format(desc.description))
	f:close()
end
