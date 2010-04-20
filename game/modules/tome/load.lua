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

-- This file loads the game module, and loads data
local KeyBind = require "engine.KeyBind"
local DamageType = require "engine.DamageType"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorAI = require "engine.interface.ActorAI"
local ActorInventory = require "engine.interface.ActorInventory"
local ActorLevel = require "engine.interface.ActorLevel"
local Birther = require "engine.Birther"
local Store = require "mod.class.Store"
local WorldAchievements = require "engine.interface.WorldAchievements"

config.settings.tome = config.settings.tome or {}
config.settings.tome.allow_build = config.settings.tome.allow_build or {}

-- Achievements
WorldAchievements:loadDefinition("/data/achievements/")

-- Usefull keybinds
KeyBind:load("move,hotkeys,inventory,actions,debug")

-- Additional entities resolvers
dofile("/mod/resolvers.lua")

-- Body parts
ActorInventory:defineInventory("MAINHAND", "In main hand", true, "Most weapons are wielded in the main hand.")
ActorInventory:defineInventory("OFFHAND", "In off hand", true, "You can use shields or a second weapon in your off hand, if you have the talents for it.")
ActorInventory:defineInventory("FINGER", "On fingers", true, "Rings are worn on fingers.")
ActorInventory:defineInventory("NECK", "Around neck", true, "Amulets are worn around the neck.")
ActorInventory:defineInventory("LITE", "Light source", true, "Light source allows you to see in the dark places of the world.")
ActorInventory:defineInventory("BODY", "Main armor", true, "Armor protects your from physical attacks. The heavier the armor the more it hinders the use of talents and spells.")
ActorInventory:defineInventory("CLOAK", "Cloak", true, "A cloak can simply keep you warn or grant you wonderous powers should you find a magic one.")
ActorInventory:defineInventory("HEAD", "On head", true, "You can wear helmets or crowns on your head")
ActorInventory:defineInventory("BELT", "Around waist", true, "Belts are worn around waist.")
ActorInventory:defineInventory("HANDS", "On hands", true, "Various gloves can be worn on your hands.")
ActorInventory:defineInventory("FEET", "On feet", true, "Sandals or boots can be worn on your feet.")
ActorInventory:defineInventory("TOOL", "Tool", true, "This is your readied tool, always available immediately.")
ActorInventory:defineInventory("QUIVER", "Quiver", true, "Your readied ammo.")

-- Damage types
DamageType:loadDefinition("/data/damage_types.lua")

-- Talents
ActorTalents:loadDefinition("/data/talents.lua")

-- Timed Effects
ActorTemporaryEffects:loadDefinition("/data/timed_effects.lua")

-- Actor resources
ActorResource:defineResource("Air", "air", nil, "air_regen", "Air capacity in your lungs. Entities that need not to breath are not affected.")
ActorResource:defineResource("Stamina", "stamina", ActorTalents.T_STAMINA_POOL, "stamina_regen", "Stamina represents your physical fatigue. Each physical ability used reduces it.")
ActorResource:defineResource("Mana", "mana", ActorTalents.T_MANA_POOL, "mana_regen", "Mana represents your reserve of magical energies. Each spell cast consumes mana and each sustained spell reduces your maximun mana.")
ActorResource:defineResource("Equilibrium", "equilibrium", ActorTalents.T_EQUILIBRIUM_POOL, "equilibrium_regen", "Equilibrium represents your stand in the grand balance of nature. The closer it is to 0 the more inbalance you are. Higher equilibrium states will impact negatively your ability to use Wild Gifts.")
ActorResource:defineResource("Vim", "vim", ActorTalents.T_VIM_POOL, "vim_regen", "Vim represents the amount of life energies/souls you have stolen. Each corruption talents requires some.")

-- Actor stats
ActorStats:defineStat("Strength",	"str", 10, 1, 100, "Strength defines your character's ability to apply physical force. It increases your melee damage, damage with heavy weapons, your chance to resist physical effects, and carrying capacity.")
ActorStats:defineStat("Dexterity",	"dex", 10, 1, 100, "Dexterity defines your character's ability to be agile and alert. It increases your chance to hit, your ability to avoid attacks and your damage with light weapons.")
ActorStats:defineStat("Magic",		"mag", 10, 1, 100, "Magic defines your character's ability to manipulate the magic of the world. It increases your spell power, the effect of spells and other magic items.")
ActorStats:defineStat("Willpower",	"wil", 10, 1, 100, "Willpower defines your character's ability to concentrate. It increases your mana and stamina capacity, and your chance to resist mental attacks.")
ActorStats:defineStat("Cunning",	"cun", 10, 1, 100, "Cunning defines your character's ability to learn, think and react. It allows you to learn many wordly abilities, increases your mental resistance, armor penetration and critical chance.")
ActorStats:defineStat("Constitution",	"con", 10, 1, 100, "Constitution defines your character's ability to withstand and resist damage. It increases your maximun life and physical resistance.")
-- Luck is hidden and start at half max value (50) which is considered the standard
ActorStats:defineStat("Luck",		"lck", 50, 1, 100, "Luck defines your character's chance when dealing with unknown events. It increases your critical strike chances, your chance for random encounters, ...")

-- Actor leveling
ActorLevel:defineMaxLevel(50)

-- Actor autolevel schemes
dofile("/data/autolevel_schemes.lua")

-- Actor AIs
ActorAI:loadDefinition("/engine/ai/")
ActorAI:loadDefinition("/mod/ai/")

-- Birther descriptor
Birther:loadDefinition("/data/birth/descriptors.lua")

-- Stores
Store:loadStores("/data/general/stores/basic.lua")

------------------------------------------------------------------------
-- Count the number of talents per types
------------------------------------------------------------------------
local type_tot = {}
for i, t in ipairs(ActorTalents.talents_def) do
	type_tot[t.type[1]] = (type_tot[t.type[1]] or 0) + t.points
	local b = t.type[1]:gsub("/.*", "")
	type_tot[b] = (type_tot[b] or 0) + t.points
end
local stype_tot = {}
for tt, nb in pairs(type_tot) do
	stype_tot[#stype_tot+1] = {tt,nb}
end
table.sort(stype_tot, function(a, b) return a[1] < b[1] end)
for i, t in ipairs(stype_tot) do
	print("[SCHOOL TOTAL]", t[2], t[1])
end
------------------------------------------------------------------------

return {require "mod.class.Game", require "mod.class.World"}
