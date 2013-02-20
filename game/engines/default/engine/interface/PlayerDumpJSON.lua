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

require "engine.class"
require "Json2"

--- Handles player json "char dump"
-- This is used for auto uploads to te4.org, could be for other stuff too
module(..., package.seeall, class.make)

allow_late_uuid = false

--- Register the character on te4.org and return a UUID for it
function _M:getUUID()
	if self.__te4_uuid then return self.__te4_uuid end
	local uuid = profile:registerNewCharacter(game.__mod_info.short_name)
	if uuid then
		self.__te4_uuid = uuid
	end
end

--- Call this when a character is saved to upload data to te4.org
function _M:saveUUID(do_charball)
	if game:isTainted() then return end
	if not self.__te4_uuid then
		-- Try to grab an UUID even after char reg
		if self.allow_late_uuid and not game:isTainted() then self:getUUID() end
		if not self.__te4_uuid then return end
	end
	local data = {sections={}}
	setmetatable(data, {__index={
		version = function(self, v) self.version = v end,
		hiddenData = function(self, key, value)
			self.hidden = self.hidden or {}
			self.hidden[key] = value
		end,
		newSection = function(self, table, sectable)
			self.sections[#self.sections+1] = table
			self[table] = sectable or {}
			return self[table]
		end,
		subsheet = function(self, name)
			local s = {sections={}}
			setmetatable(s, getmetatable(self))
			self.subsheets = self.subsheets or {}
			self.subsheets[#self.subsheets+1] = {name=name, sheet=s}
			return s
		end,
	}})
	local title, tags = self:dumpToJSON(data)
	data = json.encode(data)
	if not data or not title then return end

	profile:registerSaveChardump(game.__mod_info.short_name, self.__te4_uuid, title, tags, core.zlib.compress(data))
	if do_charball then pcall(function()
		savefile_pipe:push(do_charball.name, "entity", do_charball, "engine.CharacterBallSave", function(save)
			f = fs.open("/charballs/"..save:nameSaveEntity(do_charball), "r")
			if f then
				local data = {}
				while true do
					local l = f:read()
					if not l then break end
					data[#data+1] = l
				end
				f:close()

				profile:registerSaveCharball(game.__mod_info.short_name, self.__te4_uuid, table.concat(data))
			end
		end)
	end) end
end

--- Override this method to define dump sections
function _M:dumpToJSON(js)
--	if not self.__te4_uuid then return end
	return self.name
end
