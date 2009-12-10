-- This file loads the game module, and loads data
local DamageType = require "engine.DamageType"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorAI = require "engine.interface.ActorAI"
local ActorInventory = require "engine.interface.ActorInventory"
local Birther = require "engine.Birther"

-- Damage types
DamageType:loadDefinition("/data/damage_types.lua")
-- Talents
ActorTalents:loadDefinition("/data/talents.lua")
-- Timed Effects
ActorTemporaryEffects:loadDefinition("/data/timed_effects.lua")
-- Actor resources
ActorResource:defineResource("Mana", "mana", ActorTalents.T_MANA_POOL, "mana_regen", "Mana represents your reserve of magical energies. Each spell cast consumes mana and each sustained spell reduces your maximun mana.")
ActorResource:defineResource("Stamina", "stamina", ActorTalents.T_STAMINA_POOL, "stamina_regen", "Stamina represents your physical fatigue. Each physical ability used reduces it.")
-- Actor stats
ActorStats:defineStat("Strength",	"str", 10, 1, 100, "Strength defines your character's ability to apply physical force. It increases your melee damage, damage with heavy weapons, your chance to resist physical effects, and carrying capacity.")
ActorStats:defineStat("Dexterity",	"dex", 10, 1, 100, "Dexterity defines your character's ability to be agile and alert. It increases your chance to hit, your ability to avoid attacks and your damage with light weapons.")
ActorStats:defineStat("Magic",		"mag", 10, 1, 100, "Magic defines your character's ability to manipulate the magic of the world. It increases your spell power, the effect of spells and other magic items.")
ActorStats:defineStat("Willpower",	"wil", 10, 1, 100, "Willpower defines your character's ability to concentrate. It increases your mana and stamina capacity, and your chance to resist mental attacks.")
ActorStats:defineStat("Cunning",	"cun", 10, 1, 100, "Cunning defines your character's ability to learn and think. It allows you to learn many wordly abilities, increases your mental resistance and armor penetration.")
ActorStats:defineStat("Constitution",	"con", 10, 1, 100, "Constitution defines your character's ability to withstand and resist damage. It increases your maximun life and physical resistance.")
-- Luck is hidden and start at half max value (50) which is considered the standard
ActorStats:defineStat("Luck",		"lck", 50, 1, 100, "Luck defines your character's chance when dealing with unknown events. It increases yoru critical strike chances, your chance for random encounters, ...")
-- Actor autolevel schemes
dofile("/data/autolevel_schemes.lua")
-- Actor AIs
ActorAI:loadDefinition("/engine/ai/")

-- Body parts
ActorInventory:defineInventory("MAIN_HAND", "In main hand", true, "")
ActorInventory:defineInventory("OFF_HAND", "In off hand", true, "")
ActorInventory:defineInventory("FINGER", "On fingers", true, "")
ActorInventory:defineInventory("NECK", "Around neck", true, "")
ActorInventory:defineInventory("LITE", "Light source", true, "")
ActorInventory:defineInventory("BODY", "Main armor", true, "")
ActorInventory:defineInventory("CLOAK", "Cloak", true, "")
ActorInventory:defineInventory("HEAD", "On head", true, "")
ActorInventory:defineInventory("HANDS", "On hands", true, "")
ActorInventory:defineInventory("FEET", "On feet", true, "")
ActorInventory:defineInventory("TOOL", "Tool", true, "")

-- Birther descriptor
Birther:loadDefinition("/data/birth/descriptors.lua")


return require "mod.class.Game"
