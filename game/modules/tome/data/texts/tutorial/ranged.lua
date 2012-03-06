-- ToME - Tales of Maj'Eyal
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

if not game.player.tutored_levels2 then
	game.player:learnTalent(game.player.T_SHOOT, true, 1, {no_unlearn=true})
	game.player.tutored_levels2 = true
end

return [[Ranged combat typically revolves around firing arrows, slinging stones, or casting spells.
You have been given a bow, which you wield with both hands.
You have infinite normal arrows, but you can add special arrows to your quiver for extra damage and/or effects.
To fire an arrow, use the shoot talent. The target interface will pop-up, just like for other talents.

To equip your bow and arrows:
* Open your inventory.
* Select your sword, take it off.
* Select your shield, take it off.
* Select your bow and arrows, wield them.

There are trolls to the west. Go use your bow and arrows to kill them!
]]
