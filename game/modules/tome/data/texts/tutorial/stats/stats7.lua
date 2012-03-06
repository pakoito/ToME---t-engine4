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

return [[
Suppose you're an archmage, and you blast somebody with the Flameshock spell. 

This spell does fire damage, which is determined by your #LIGHT_GREEN#Spellpower#WHITE#. #GOLD#Combat stats#WHITE# are not used to mitigate damage, so the defender is going to take the full force of the spell, barring fire resistance (which is a subject for another tutorial).

The spell will also attempt to stun the target. Stunning, you recall, is a physical effect, so the target defends with their #LIGHT_GREEN#Physical save#WHITE#. However, unlike the previous example, the source of this stun is a spell. You will thus compare your #LIGHT_GREEN#Spellpower#WHITE# to the target's #LIGHT_GREEN#Physical save#WHITE# to determine the success of the stun.
]]
