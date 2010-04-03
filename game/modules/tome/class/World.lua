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
require "engine.World"
require "engine.interface.WorldAchievements"
local Savefile = require "engine.Savefile"

module(..., package.seeall, class.inherit(engine.World, engine.interface.WorldAchievements))

function _M:init()
	engine.World.init(self)
	engine.interface.WorldAchievements.init(self)
end

--- Requests the world to save
function _M:saveWorld()
	local save = Savefile.new("")
	save:saveWorld(self)
	save:close()
	game.log("Saved world.")
end

--- Format an achievement source
-- @param src the actor who did it
function _M:achievementWho(src)
	return src.name.." the "..game.player.descriptor.subrace.." "..game.player.descriptor.subclass
end
