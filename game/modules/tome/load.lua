-- ToME - Tales of Maj'Eyal
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

-- Configure Map
--dofile("/mod/map_config.lua")

-- Entities that are ASCII are outline
local Entity = require "engine.Entity"
Entity.ascii_outline = {x=2, y=2, r=0, g=0, b=0, a=0.8}

-- This file loads the game module, and loads data
local KeyBind = require "engine.KeyBind"
local DamageType = require "engine.DamageType"
local Faction = require "engine.Faction"
local Map = require "engine.Map"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorAI = require "engine.interface.ActorAI"
local ActorInventory = require "engine.interface.ActorInventory"
local ActorLevel = require "engine.interface.ActorLevel"
local Birther = require "engine.Birther"
local Store = require "mod.class.Store"
local WorldAchievements = require "mod.class.interface.WorldAchievements"
local PlayerLore = require "mod.class.interface.PlayerLore"
local Quest = require "engine.Quest"
local UIBase = require "engine.ui.Base"

config.settings.tome = config.settings.tome or {}
profile.mod.allow_build = profile.mod.allow_build or {}

-- Create some noise textures
local n = core.noise.new(3)
_3DNoise = n:makeTexture3D(64, 64, 64)
local n = core.noise.new(2)
_2DNoise = n:makeTexture2D(64, 64)
--local n = core.noise.new(3)
--_2DNoise = n:makeTexture2DStack(64, 64, 64)

-- Dialogs fonts
UIBase.font = core.display.newFont("/data/font/USENET_.ttf", 16)
UIBase.font_bold = core.display.newFont("/data/font/USENET_.ttf", 16)
UIBase.font_bold:setStyle("bold")
UIBase.font_h = UIBase.font:lineSkip()
UIBase.font_bold_h = UIBase.font_bold:lineSkip()

-- Achievements
WorldAchievements:loadDefinition("/data/achievements/")

-- Lore
PlayerLore:loadDefinition("/data/lore/lore.lua")

-- Useful keybinds
KeyBind:load("move,hotkeys,inventory,actions,interface,tome,debug")

-- Additional entities resolvers
dofile("/mod/resolvers.lua")

-- Body parts
ActorInventory:defineInventory("MAINHAND", "In main hand", true, "Most weapons are wielded in the main hand.")
ActorInventory:defineInventory("OFFHAND", "In off hand", true, "You can use shields or a second weapon in your off-hand, if you have the talents for it.")
ActorInventory:defineInventory("PSIONIC_FOCUS", "Psionic Focus", true, "Object help in your telekinetic grasp. It can be a weapon or some other item to provide a benefit to your psionic powers.")
ActorInventory:defineInventory("FINGER", "On fingers", true, "Rings are worn on fingers.")
ActorInventory:defineInventory("NECK", "Around neck", true, "Amulets are worn around the neck.")
ActorInventory:defineInventory("LITE", "Light source", true, "A light source allows you to see in the dark places of the world.")
ActorInventory:defineInventory("BODY", "Main armor", true, "Armor protects you from physical attacks. The heavier the armor the more it hinders the use of talents and spells.")
ActorInventory:defineInventory("CLOAK", "Cloak", true, "A cloak can simply keep you warm or grant you wondrous powers should you find a magical one.")
ActorInventory:defineInventory("HEAD", "On head", true, "You can wear helmets or crowns on your head.")
ActorInventory:defineInventory("BELT", "Around waist", true, "Belts are worn around your waist.")
ActorInventory:defineInventory("INBELT", "In your belt", true, "Put small objects in your belt. Using them from the belt only uses 60% of the normal time.")
ActorInventory:defineInventory("HANDS", "On hands", true, "Various gloves can be worn on your hands.")
ActorInventory:defineInventory("FEET", "On feet", true, "Sandals or boots can be worn on your feet.")
ActorInventory:defineInventory("TOOL", "Tool", true, "This is your readied tool, always available immediately.")
ActorInventory:defineInventory("QUIVER", "Quiver", true, "Your readied ammo.")
ActorInventory:defineInventory("GEM", "Socketed Gems", true, "Socketed gems.")
ActorInventory:defineInventory("MOUNT", "Mount", false, "Your mount.")
ActorInventory:defineInventory("QS_MAINHAND", "Second weapon set: In main hand", false, "Weapon Set 2: Most weapons are wielded in the main hand. Press 'x' to switch weapon sets.", true)
ActorInventory:defineInventory("QS_OFFHAND", "Second weapon set: In off hand", false, "Weapon Set 2: You can use shields or a second weapon in your off-hand, if you have the talents for it. Press 'x' to switch weapon sets.", true)

-- Damage types
DamageType:loadDefinition("/data/damage_types.lua")

-- Talents
ActorTalents:loadDefinition("/data/talents.lua")

-- Timed Effects
ActorTemporaryEffects:loadDefinition("/data/timed_effects.lua")

-- Actor resources
ActorResource:defineResource("Air", "air", nil, "air_regen", "Air capacity in your lungs. Entities that need not breath are not affected.")
ActorResource:defineResource("Stamina", "stamina", ActorTalents.T_STAMINA_POOL, "stamina_regen", "Stamina represents your physical fatigue. Each physical ability used reduces it.")
ActorResource:defineResource("Mana", "mana", ActorTalents.T_MANA_POOL, "mana_regen", "Mana represents your reserve of magical energies. Each spell cast consumes mana and each sustained spell reduces your maximum mana.")
ActorResource:defineResource("Equilibrium", "equilibrium", ActorTalents.T_EQUILIBRIUM_POOL, "equilibrium_regen", "Equilibrium represents your standing in the grand balance of nature. The closer it is to 0 the more balanced you are. Being out of equilibrium will negatively affect your ability to use Wild Gifts.", 0, false)
ActorResource:defineResource("Vim", "vim", ActorTalents.T_VIM_POOL, "vim_regen", "Vim represents the amount of life energy/souls you have stolen. Each corruption talent requires some.")
ActorResource:defineResource("Positive", "positive", ActorTalents.T_POSITIVE_POOL, "positive_regen", "Positive energy represents your reserve of positive power. It slowly decreases.")
ActorResource:defineResource("Negative", "negative", ActorTalents.T_NEGATIVE_POOL, "negative_regen", "Negative energy represents your reserve of negative power. It slowly decreases.")
ActorResource:defineResource("Hate", "hate", ActorTalents.T_HATE_POOL, "hate_regen", "Hate represents the level of frenzy of a cursed soul.")
ActorResource:defineResource("Paradox", "paradox", ActorTalents.T_PARADOX_POOL, "paradox_regen", "Paradox represents how much damage you've done to the space-time continuum. A high Paradox score makes Chronomancy less reliable and more dangerous to use but also amplifies the effects.", 0, false)
ActorResource:defineResource("Psi", "psi", ActorTalents.T_PSI_POOL, "psi_regen", "Psi represents the power available to your mind.")
-- Actor stats

ActorStats:defineStat("Strength",	"str", 10, 1, 100, "Strength defines your character's ability to apply physical force. It increases your melee damage, damage done with heavy weapons, your chance to resist physical effects, and carrying capacity.")
ActorStats:defineStat("Dexterity",	"dex", 10, 1, 100, "Dexterity defines your character's ability to be agile and alert. It increases your chance to hit, your ability to avoid attacks, and your damage with light or ranged weapons.")
ActorStats:defineStat("Magic",		"mag", 10, 1, 100, "Magic defines your character's ability to manipulate the magical energy of the world. It increases your spell power, and the effect of spells and other magic items.")
ActorStats:defineStat("Willpower",	"wil", 10, 1, 100, "Willpower defines your character's ability to concentrate. It increases your mana and stamina capacity, and your chance to resist mental attacks.")
ActorStats:defineStat("Cunning",	"cun", 10, 1, 100, "Cunning defines your character's ability to learn, think, and react. It allows you to learn many worldly abilities, and increases your mental resistance, armor penetration, and chance of critical hits.")
ActorStats:defineStat("Constitution",	"con", 10, 1, 100, "Constitution defines your character's ability to withstand and resist damage. It increases your maximum life and physical resistance.")
-- Luck is hidden and starts at half max value (50) which is considered the standard
ActorStats:defineStat("Luck",		"lck", 50, 1, 100, "Luck defines your character's fortune when dealing with unknown events. It increases your critical strike chance, your chance of random encounters, ...")

-- Actor leveling, player is restricted to 50 but npcs can go higher
ActorLevel:defineMaxLevel(nil)
ActorLevel.exp_chart = function(level)
	local exp = 10
	local mult = 8.5
	local min = 3
	for i = 2, level do
		exp = exp + level * mult
		if level < 30 then
			mult = util.bound(mult - 0.2, min, mult)
		else
			mult = util.bound(mult - 0.1, min, mult)
		end
	end
	return math.ceil(exp)
end
--[[
local tnb, tznb = 0, 0
for i = 2, 50 do
	local nb = math.ceil(ActorLevel.exp_chart(i) / i)
	local znb = math.ceil(nb/25)
	tnb = tnb + nb
	tznb = tznb + znb
	print("level", i, "::", ActorLevel.exp_chart(i), "must kill", nb, "actors of same level; which is about ", znb, "zone levels")
end
print("total", tnb, "::", tznb)
os.exit()
--]]

-- Factions
dofile("/data/factions.lua")

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

-- Init settings
if type(config.settings.tome.autosave) == "nil" then config.settings.tome.autosave = true end
if not config.settings.tome.smooth_move then config.settings.tome.smooth_move = 3 end
if not config.settings.tome.gfx then config.settings.tome.gfx = {size="32x32", tiles="mushroom"} end
if type(config.settings.tome.weather_effects) == "nil" then config.settings.tome.weather_effects = true end
if type(config.settings.tome.smooth_fov) == "nil" then config.settings.tome.smooth_fov = true end
Map.smooth_scroll = config.settings.tome.smooth_move

return {require "mod.class.Game", require "mod.class.World"}
