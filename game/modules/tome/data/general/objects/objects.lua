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

local loadIfNot = function(f)
	if loaded[f] then return end
	load(f, entity_mod)
end

-- Misc
loadIfNot("/data/general/objects/money.lua")
loadIfNot("/data/general/objects/gem.lua")
loadIfNot("/data/general/objects/lites.lua")

-- Usable stuff
loadIfNot("/data/general/objects/potions.lua")
loadIfNot("/data/general/objects/scrolls.lua")
loadIfNot("/data/general/objects/rods.lua")
loadIfNot("/data/general/objects/wands.lua")
loadIfNot("/data/general/objects/totems.lua")
loadIfNot("/data/general/objects/torques.lua")

-- Tools
loadIfNot("/data/general/objects/digger.lua")
loadIfNot("/data/general/objects/misc-tools.lua")

-- Jewelry stuff
loadIfNot("/data/general/objects/jewelry.lua")

-- Weapons
loadIfNot("/data/general/objects/staves.lua")
loadIfNot("/data/general/objects/mindstars.lua")
loadIfNot("/data/general/objects/knifes.lua")

loadIfNot("/data/general/objects/whips.lua")

loadIfNot("/data/general/objects/swords.lua")
loadIfNot("/data/general/objects/2hswords.lua")

loadIfNot("/data/general/objects/maces.lua")
loadIfNot("/data/general/objects/2hmaces.lua")

loadIfNot("/data/general/objects/axes.lua")
loadIfNot("/data/general/objects/2haxes.lua")

loadIfNot("/data/general/objects/2htridents.lua")

loadIfNot("/data/general/objects/bows.lua")
loadIfNot("/data/general/objects/slings.lua")

-- Armours
loadIfNot("/data/general/objects/shields.lua")
loadIfNot("/data/general/objects/cloth-armors.lua")
loadIfNot("/data/general/objects/light-armors.lua")
loadIfNot("/data/general/objects/heavy-armors.lua")
loadIfNot("/data/general/objects/massive-armors.lua")

-- Head, feet, hands, ...
loadIfNot("/data/general/objects/leather-caps.lua")
loadIfNot("/data/general/objects/helms.lua")
loadIfNot("/data/general/objects/wizard-hat.lua")
loadIfNot("/data/general/objects/leather-boots.lua")
loadIfNot("/data/general/objects/heavy-boots.lua")
loadIfNot("/data/general/objects/gloves.lua")
loadIfNot("/data/general/objects/gauntlets.lua")
loadIfNot("/data/general/objects/cloak.lua")
loadIfNot("/data/general/objects/leather-belt.lua")

-- Lore
loadIfNot("/data/general/objects/lore/spellhunt.lua")
loadIfNot("/data/general/objects/lore/fun.lua")
loadIfNot("/data/general/objects/lore/misc.lua")

-- Artifacts
loadIfNot("/data/general/objects/world-artifacts.lua")
loadIfNot("/data/general/objects/quest-artifacts.lua")
loadIfNot("/data/general/objects/special-artifacts.lua")
loadIfNot("/data/general/objects/boss-artifacts.lua")
