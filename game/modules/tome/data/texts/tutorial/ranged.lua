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

if not game.player.tutored_levels2 then
	game.player:learnTalent(game.player.T_SHOOT, true, 1)
	game.player.tutored_levels2 = true
end

return [[Ranged combat can take many forms, but most of the time it resolves either around firing arrows or slinging spells.
Archery requires a bow and some arrows. You must wield the bow (it requires both hands) and put the arrows in your quiver.
Then you can use the shoot talent to fire an arrow, the target interface will popup, just like for any other talents.
* Open your inventory
* Click on your sword, take it off
* Click on your shield, take it off
* Click on your bow and arrows, wield them
* Close inventory and shoot!

You have been given then Shoot talent, that allows to fire a bow (or a sling).
In front of you lies a bow and some arrows, pick them up, take off your weapon and shield, wield the bow and the arrows and go fight the trolls to the west.
]]
