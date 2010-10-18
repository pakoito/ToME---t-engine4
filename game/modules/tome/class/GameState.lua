-- ToME - Tales of Middle-Earth
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
require "engine.Entity"

module(..., package.seeall, class.inherit(engine.Entity))

function _M:init(t, no_default)
	engine.Entity.init(self, t, no_default)

	self.allow_backup_guardians = {}
end

function _M:goneEast()
	self.gone_east = true
end

function _M:activateBackupGuardian(guardian, on_level, zonelevel, rumor)
	if self.gone_east then return end
	print("Zone guardian dead, setting up backup guardian", guardian, zonelevel)
	self.allow_backup_guardians[game.zone.short_name] =
	{
		name = game.zone.name,
		guardian = guardian,
		on_level = on_level,
		new_level = zonelevel,
		rumor = rumor,
	}
end

function _M:zoneCheckBackupGuardian()
	if not self.gone_east then print("Not gone east, no backup guardian") return end

	-- Adjust level of the zone
	if self.allow_backup_guardians[game.zone.short_name] then
		local data = self.allow_backup_guardians[game.zone.short_name]
		game.zone.base_level = data.new_level
	end

	-- Spawn the new guardian
	if self.allow_backup_guardians[game.zone.short_name] and self.allow_backup_guardians[game.zone.short_name].on_level == game.level.level then
		local data = self.allow_backup_guardians[game.zone.short_name]

		-- Place the guardian, we do not check for connectivity, vault or whatever, the player is suppoed to be strong enough to get there
		local m = game.zone:makeEntityByName(game.level, "actor", data.guardian)
		if m then
			local x, y = rng.range(0, game.level.map.w - 1), rng.range(0, game.level.map.h - 1)
			local tries = 0
			while not m:canMove(x, y) and tries < 100 do
				x, y = rng.range(0, game.level.map.w - 1), rng.range(0, game.level.map.h - 1)
				tries = tries + 1
			end
			if tries < 100 then
				game.zone:addEntity(game.level, m, "actor", x, y)
				print("Backup Guardian allocated: ", data.guardian, m.uid, m.name)
			end
		else
			print("WARNING: Backup Guardian not found: ", data.guardian)
		end

		self.allow_backup_guardians[game.zone.short_name] = nil
	end
end
