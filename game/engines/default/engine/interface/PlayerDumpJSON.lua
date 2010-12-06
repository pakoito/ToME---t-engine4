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
require "Json2"

--- Handles player json "char dump"
-- This is used for auto uploads to te4.org, could be for other stuff too
module(..., package.seeall, class.make)

--- Register the character on te4.org and return a UUID for it
function _M:getUUID()
	local uuid = profile:registerNewCharacter(game.__mod_info.short_name)
	if uuid then
		self.__te4_uuid = uuid
	end
end

--- Call this when a character is saved to upload data to te4.org
function _M:saveUUID()
	if not self.__te4_uuid then return end
	local data = {sections={}}
	setmetatable(data, {__index={
		newSection = function(self, display, table, type, column, sectable)
			self.sections[#self.sections+1] = {display=display, table=table, type=type, column=column}
			self[table] = sectable or {}
			return self[table]
		end,
	}})
	local title = self:dumpToJSON(data)
	data = json.encode(data)
	if not data or not title then return end

	profile:registerSaveChardump(game.__mod_info.short_name, self.__te4_uuid, title, core.zlib.compress(data))
end

--- Override this method to define dump sections
function _M:dumpToJSON(js)
	if not self.__te4_uuid then return end
	return self.name
end
