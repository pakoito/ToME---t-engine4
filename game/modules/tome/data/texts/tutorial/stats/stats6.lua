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
Suppose you're a berserker, and you attempt to stun an enemy. If you're to succeed, two things must happen:

First, your attack needs to hit! That means comparing your #LIGHT_GREEN#Accuracy#WHITE# to the target's #LIGHT_GREEN#Defense#WHITE#.

Second, the stun must take effect. The source of the stun is you, a rampaging berserker, so we use your #LIGHT_GREEN#Physical power#WHITE#.
A stun is a physical effect, so we use the target's #LIGHT_GREEN#Physical save#WHITE#. Thus we'll be comparing your #LIGHT_GREEN#Physical power#WHITE# to the target's #LIGHT_GREEN#Physical save#WHITE#.

It seems quite natural to always compare #LIGHT_GREEN#Physical power#WHITE# with #LIGHT_GREEN#Physical save#WHITE#, but let's consider another example. 
]]
