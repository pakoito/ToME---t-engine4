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

dofile("/mod/map_config.lua")

-- This file loads the game module, and loads data
local KeyBind = require "engine.KeyBind"
local DamageType = require "engine.DamageType"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorAI = require "engine.interface.ActorAI"
local ActorLevel = require "engine.interface.ActorLevel"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local ActorInventory = require "engine.interface.ActorInventory"

-- Usefull keybinds
KeyBind:load("move,hotkeys,inventory,actions,interface,debug")

-- Additional entities resolvers
dofile("/mod/resolvers.lua")

-- Body parts
ActorInventory:defineInventory("WEAPON", "Weapon", true, "Most weapons are wielded in the main hand.")
ActorInventory:defineInventory("SHOOTER", "Shooter", true, "You can use shields or a second weapon in your off-hand, if you have the talents for it.")
ActorInventory:defineInventory("FINGER", "On fingers", true, "Rings are worn on fingers.")
ActorInventory:defineInventory("NECK", "Around neck", true, "Amulets are worn around the neck.")
ActorInventory:defineInventory("LITE", "Light source", true, "A light source allows you to see in the dark places of the world.")
ActorInventory:defineInventory("BODY", "Main armor", true, "Armor protects you from physical attacks. The heavier the armor the more it hinders the use of talents and spells.")
ActorInventory:defineInventory("CLOAK", "Cloak", true, "A cloak can simply keep you warm or grant you wonderous powers should you find a magical one.")
ActorInventory:defineInventory("HEAD", "On head", true, "You can wear helmets or crowns on your head")
ActorInventory:defineInventory("SHIELD", "Shield", true, "Various gloves can be worn on your hands.")
ActorInventory:defineInventory("HANDS", "On hands", true, "Various gloves can be worn on your hands.")
ActorInventory:defineInventory("FEET", "On feet", true, "Sandals or boots can be worn on your feet.")
ActorInventory:defineInventory("QUIVER", "Quiver", true, "Your readied ammo.")

-- Damage types
DamageType:loadDefinition("/data/damage_types.lua")

-- Talents
ActorTalents:loadDefinition("/data/talents.lua")

-- Timed Effects
ActorTemporaryEffects:loadDefinition("/data/timed_effects.lua")

-- Actor resources
ActorResource:defineResource("Power", "power", nil, "power_regen", "Power represent your ability to use special talents.")

-- Actor stats
ActorStats:defineStat("Strength",	"str", 10, 1, 100, "Strength defines your character's ability to apply physical force.")
ActorStats:defineStat("Dexterity",	"dex", 10, 1, 100, "Dexterity defines your character's ability to be agile and alert.")
ActorStats:defineStat("Intelligence",	"int", 10, 1, 100, "Intelligence defines your character's intellect.")
ActorStats:defineStat("Wisdom",		"wis", 10, 1, 100, "Wisdom defines your character's moral and mental strength.")
ActorStats:defineStat("Constitution",	"con", 10, 1, 100, "Constitution defines your character's ability to withstand and resist damage.")
ActorStats:defineStat("Charisma",	"cha", 10, 1, 100, "Charisma defines your character's good looks.")

-- Actor AIs
ActorAI:loadDefinition("/engine/ai/")
ActorAI:loadDefinition("/mod/ai/")

ActorLevel:defineExperienceChart{
	0,
	10,
	25,
	45,
	70,
	100,
	140,
	200,
	280,
	380,
	500,
	650,
	850,
	1100,
	1400,
	1800,
	2300,
	2900,
	3600,
	4400,
	5400,
	6800,
	8400,
	10200,
	12500,
	17500,
	25000,
	35000,
	50000,
	75000,
	100000,
	150000,
	200000,
	275000,
	350000,
	450000,
	550000,
	700000,
	850000,
	1000000,
	1250000,
	1500000,
	1800000,
	2100000,
	2400000,
	2700000,
	3000000,
	3500000,
	4000000,
	4500000,
	5000000
}

-- Birther descriptor
Birther:loadDefinition("/data/birth/descriptors.lua")

return {require "mod.class.Game" }
