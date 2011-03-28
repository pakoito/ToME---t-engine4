-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

module(..., package.seeall, class.make)


-------------------------------------------------------------
-- Ressources
-------------------------------------------------------------
TOOLTIP_GOLD = [[#GOLD#Gold#LAST#
Money!
With gold you can buy items in the various stores in town.
You can gain money by looting it from your foes, by selling items and by doing some quests.
]]

TOOLTIP_LIFE = [[#GOLD#Life#LAST#
This is your life force, when you take damage this is reduced more and more.
If it reaches below zero you die.
Death is usualy permanent so beware!
It is increased by Constitution.]]

TOOLTIP_MANA = [[#GOLD#Mana#LAST#
Mana represents your reserve of magical energies. Each spell cast consumes mana and each sustained spell reduces your maximum mana.
It is increased by Willpower.]]

TOOLTIP_LEVEL = [[#GOLD#Level and experience#LAST#
Each time you kill a creature that is over your own level - 5 you gain some experience.
When you reach enough experience you advance to the next level. There is a maximum of 50 levels you can gain.
Each time you level you gain stat and talent points to use to improve your character.
]]

-------------------------------------------------------------
-- Stats
-------------------------------------------------------------
TOOLTIP_STR = [[#GOLD#Strength#LAST#
Strength defines your character's ability to apply physical force. It increases your melee damage, damage done with heavy weapons, your chance to resist physical effects, and carrying capacity.
]]
TOOLTIP_DEX = [[#GOLD#Dexterity#LAST#
Dexterity defines your character's ability to be agile and alert. It increases your chance to hit, your ability to avoid attacks, and your damage with light weapons.
]]
TOOLTIP_CON = [[#GOLD#Constitution#LAST#
Constitution defines your character's ability to withstand and resist damage. It increases your maximum life and physical resistance.
]]
TOOLTIP_INT = [[#GOLD#Intelligence#LAST#
Intelligence defines how well you can handle complex spells and magical devices.
]]
TOOLTIP_WIS = [[#GOLD#Wisdom#LAST#
Wisdom defines your character's mental resistance.
]]
TOOLTIP_CHA = [[#GOLD#Charisma#LAST#
Charisma defines your character's good looks.
]]
TOOLTIP_STRDEXCON = "#AQUAMARINE#Physical stats#LAST#\n---\n"..TOOLTIP_STR.."\n---\n"..TOOLTIP_DEX.."\n---\n"..TOOLTIP_CON
TOOLTIP_INTWISCHA = "#AQUAMARINE#Mental stats#LAST#\n---\n"..TOOLTIP_INT.."\n---\n"..TOOLTIP_WIS.."\n---\n"..TOOLTIP_CHA

