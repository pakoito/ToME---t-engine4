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

-- Configure Map
--dofile("/mod/map_config.lua")

-- Entities that are ASCII are outline
local Entity = require "engine.Entity"
Entity.ascii_outline = {x=2, y=2, r=0, g=0, b=0, a=0.8}

-- This file loads the game module, and loads data
local Savefile = require "engine.Savefile"
local KeyBind = require "engine.KeyBind"
local DamageType = require "engine.DamageType"
local Faction = require "engine.Faction"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Tiles = require "engine.Tiles"
local InventoryUI = require "engine.ui.Inventory"
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
local PartyIngredients = require "mod.class.interface.PartyIngredients"
local PlayerHotkeys = require "engine.interface.PlayerHotkeys"
local Quest = require "engine.Quest"
local UIBase = require "engine.ui.Base"

Savefile:setSaveMD5Type("game")
Savefile:setSaveMD5Type("level")
Savefile:setSaveMD5Type("zone")

-- Init settings
config.settings.tome = config.settings.tome or {}
profile.mod.allow_build = profile.mod.allow_build or {}
--if type(config.settings.tome.autosave) == "nil" then
config.settings.tome.autosave = true
--end
if not config.settings.tome.smooth_move then config.settings.tome.smooth_move = 3 end
if not config.settings.tome.gfx then
	local w, h = core.display.size()
	if w >= 1000 then config.settings.tome.gfx = {size="64x64", tiles="shockbolt"}
	else config.settings.tome.gfx = {size="48x48", tiles="shockbolt"}
	end
end
if config.settings.tome.gfx.tiles == "mushroom" then config.settings.tome.gfx.tiles="shockbolt" end
if type(config.settings.tome.weather_effects) == "nil" then config.settings.tome.weather_effects = true end
if type(config.settings.tome.smooth_fov) == "nil" then config.settings.tome.smooth_fov = true end
if type(config.settings.tome.daynight) == "nil" then config.settings.tome.daynight = true end
if type(config.settings.tome.hotkey_icons) == "nil" then config.settings.tome.hotkey_icons = true end
if type(config.settings.tome.effects_icons) == "nil" then config.settings.tome.effects_icons = true end
if type(config.settings.tome.autoassign_talents_on_birth) == "nil" then config.settings.tome.autoassign_talents_on_birth = true end
if type(config.settings.tome.chat_log) == "nil" then config.settings.tome.chat_log = true end
if type(config.settings.tome.actor_based_movement_mode) == "nil" then config.settings.tome.actor_based_movement_mode = true end
if not config.settings.tome.fonts then config.settings.tome.fonts = {type="fantasy", size="normal"} end
if not config.settings.tome.ui_theme2 then config.settings.tome.ui_theme2 = "metal" end
if not config.settings.tome.uiset_mode then config.settings.tome.uiset_mode = "Minimalist" end
if not config.settings.tome.log_lines then config.settings.tome.log_lines = 5 end
if not config.settings.tome.log_fade then config.settings.tome.log_fade = 3 end
if not config.settings.tome.scroll_dist then config.settings.tome.scroll_dist = 20 end
if not config.settings.tome.hotkey_icons_rows then config.settings.tome.hotkey_icons_rows = 1 end
if not config.settings.tome.hotkey_icons_size then config.settings.tome.hotkey_icons_size = 48 end
Map.smooth_scroll = config.settings.tome.smooth_move
Map.faction_danger2 = "tactical_danger.png"
Map.faction_danger1 = "tactical_enemy_strong.png"
Map.faction_danger_check = function(self, e, max) return (not max and e.rank > 3) or (max and e.rank >= 3.5) end
Level.remove_old_entity_on_duplicate = true

-- Dialog UI
UIBase.ui = config.settings.tome.ui_theme2
UIBase:setTextShadow(0.6)

-- Dialogs fonts
if config.settings.tome.fonts.type == "fantasy" then
	local size = ({normal=16, small=12, big=18})[config.settings.tome.fonts.size]
	UIBase.font = core.display.newFont("/data/font/DroidSans.ttf", size)
	UIBase.font_bold = core.display.newFont("/data/font/DroidSans.ttf", size)
	UIBase.font_mono = core.display.newFont("/data/font/DroidSansMono.ttf", size)
	UIBase.font_bold:setStyle("bold")
	UIBase.font_h = UIBase.font:lineSkip()
	UIBase.font_bold_h = UIBase.font_bold:lineSkip()
	UIBase.font_mono_w = UIBase.font_mono:size(" ")
	UIBase.font_mono_h = UIBase.font_mono:lineSkip()+2
else
	local size = ({normal=12, small=10, big=14})[config.settings.tome.fonts.size]
	UIBase.font = core.display.newFont("/data/font/Vera.ttf", size)
	UIBase.font_mono = core.display.newFont("/data/font/VeraMono.ttf", size)
	UIBase.font_bold = core.display.newFont("/data/font/VeraBd.ttf", size)
	UIBase.font_h = 	UIBase.font:lineSkip()
	UIBase.font_mono_w = 	UIBase.font_mono:size(" ")
	UIBase.font_mono_h = 	UIBase.font_mono:lineSkip()
	UIBase.font_bold_h = 	UIBase.font_bold:lineSkip()
end

-- Define how quick hotkeys are saved
PlayerHotkeys.quickhotkeys_specifics = {
	function(a)
		local race = ((a.descriptor and a.descriptor.race) and a.descriptor.race or (a.type and a.type:capitalize() or "No Race"))
		local subrace = ((a.descriptor and a.descriptor.subrace) and (" (%s)"):format(a.descriptor.subrace) or (a.type and "" or " (No Subrace)"))
		return ("%s"):format(race .. subrace)
	end,
	function(a)
		local class = ((a.descriptor and a.descriptor.class) and a.descriptor.class or (a.subtype and a.subtype:capitalize() or "No Class"))
		local subclass = ((a.descriptor and a.descriptor.subclass) and (" (%s)"):format(a.descriptor.subclass) or (a.subtype and "" or " (No Subclass)"))
		return ("%s"):format(class .. subclass)
	end,
}


-- Create some noise textures
local n = core.noise.new(3)
_3DNoise = n:makeTexture3D(64, 64, 64)
local n = core.noise.new(2)
_2DNoise = n:makeTexture2D(64, 64)
--local n = core.noise.new(3)
--_2DNoise = n:makeTexture2DStack(64, 64, 64)

-- Achievements
WorldAchievements:loadDefinition("/data/achievements/")

-- Lore
PlayerLore:loadDefinition("/data/lore/lore.lua")

-- Useful keybinds
KeyBind:load("move,hotkeys,inventory,actions,interface,tome,debug")

-- Additional entities resolvers
dofile("/mod/resolvers.lua")

-- Body parts
ActorInventory:defineInventory("MAINHAND", "In main hand", true, "Most weapons are wielded in the main hand.", nil, {equipdoll_back="ui/equipdoll/mainhand_inv.png"})
ActorInventory:defineInventory("OFFHAND", "In off hand", true, "You can use shields or a second weapon in your off-hand, if you have the talents for it.", nil, {equipdoll_back="ui/equipdoll/offhand_inv.png"})
ActorInventory:defineInventory("PSIONIC_FOCUS", "Psionic focus", true, "Object held in your telekinetic grasp. It can be a weapon or some other item to provide a benefit to your psionic powers.", nil, {equipdoll_back="ui/equipdoll/psionic_inv.png"})
ActorInventory:defineInventory("FINGER", "On fingers", true, "Rings are worn on fingers.", nil, {equipdoll_back="ui/equipdoll/ring_inv.png"})
ActorInventory:defineInventory("NECK", "Around neck", true, "Amulets are worn around the neck.", nil, {equipdoll_back="ui/equipdoll/amulet_inv.png"})
ActorInventory:defineInventory("LITE", "Light source", true, "A light source allows you to see in the dark places of the world.", nil, {equipdoll_back="ui/equipdoll/light_inv.png"})
ActorInventory:defineInventory("BODY", "Main armor", true, "Armor protects you from physical attacks. The heavier the armor the more it hinders the use of talents and spells.", nil, {equipdoll_back="ui/equipdoll/body_inv.png"})
ActorInventory:defineInventory("CLOAK", "Cloak", true, "A cloak can simply keep you warm or grant you wondrous powers should you find a magical one.", nil, {equipdoll_back="ui/equipdoll/cloak_inv.png"})
ActorInventory:defineInventory("HEAD", "On head", true, "You can wear helmets or crowns on your head.", nil, {equipdoll_back="ui/equipdoll/head_inv.png"})
ActorInventory:defineInventory("BELT", "Around waist", true, "Belts are worn around your waist.", nil, {equipdoll_back="ui/equipdoll/belt_inv.png"})
ActorInventory:defineInventory("HANDS", "On hands", true, "Various gloves can be worn on your hands.", nil, {equipdoll_back="ui/equipdoll/hands_inv.png"})
ActorInventory:defineInventory("FEET", "On feet", true, "Sandals or boots can be worn on your feet.", nil, {equipdoll_back="ui/equipdoll/boots_inv.png"})
ActorInventory:defineInventory("TOOL", "Tool", true, "This is your readied tool, always available immediately.", nil, {equipdoll_back="ui/equipdoll/tool_inv.png"})
ActorInventory:defineInventory("QUIVER", "Quiver", true, "Your readied ammo.", nil, {equipdoll_back="ui/equipdoll/ammo_inv.png"})
ActorInventory:defineInventory("GEM", "Socketed Gems", true, "Socketed gems.", nil, {equipdoll_back="ui/equipdoll/gem_inv.png"})
ActorInventory:defineInventory("QS_MAINHAND", "Second weapon set: In main hand", false, "Weapon Set 2: Most weapons are wielded in the main hand. Press 'x' to switch weapon sets.", true)
ActorInventory:defineInventory("QS_OFFHAND", "Second weapon set: In off hand", false, "Weapon Set 2: You can use shields or a second weapon in your off-hand, if you have the talents for it. Press 'x' to switch weapon sets.", true)
ActorInventory:defineInventory("QS_PSIONIC_FOCUS", "Second weapon set: psionic focus", false, "Weapon Set 2: Object held in your telekinetic grasp. It can be a weapon or some other item to provide a benefit to your psionic powers. Press 'x' to switch weapon sets.", true)
ActorInventory:defineInventory("QS_QUIVER", "Second weapon set: Quiver", false, "Weapon Set 2: Your readied ammo.", true)
ActorInventory.equipdolls = {
	default = { w=48, h=48, itemframe="ui/equipdoll/itemframe48.png", itemframe_sel="ui/equipdoll/itemframe-sel48.png", ix=3, iy=3, iw=42, ih=42, doll_x=116, doll_y=168+64, list={
		PSIONIC_FOCUS = {{weight=1, x=48, y=48}},
		MAINHAND = {{weight=2, x=48, y=120}},
		OFFHAND = {{weight=3, x=48, y=192}},
		BODY = {{weight=4, x=48, y=264}},
		QUIVER = {{weight=5, x=48, y=336}},
		FINGER = {{weight=6, x=48, y=408}, {weight=7, x=120, y=408, text="bottom"}},
		LITE = {{weight=8, x=192, y=408}},
		TOOL = {{weight=9, x=264, y=408, text="bottom"}},
		FEET = {{weight=10, x=264, y=336}},
		BELT = {{weight=11, x=264, y=264}},
		HANDS = {{weight=12, x=264, y=192}},
		CLOAK = {{weight=13, x=264, y=120}},
		NECK = {{weight=14, x=192, y=48, text="topright"}},
		HEAD = {{weight=15, x=120, y=48, text="topleft"}},
	}},
	alchemist_golem = { w=48, h=48, itemframe="ui/equipdoll/itemframe48.png", itemframe_sel="ui/equipdoll/itemframe-sel48.png", ix=3, iy=3, iw=42, ih=42, doll_x=116, doll_y=168+64, list={
		MAINHAND = {{weight=1, x=48, y=120}},
		OFFHAND = {{weight=2, x=48, y=192}},
		BODY = {{weight=3, x=48, y=264}},
		GEM = {{weight=4, x=264, y=120}, {weight=5, x=264, y=192}},
	}},
}

-- Ingredients
PartyIngredients:loadDefinition("/data/ingredients.lua")

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
ActorStats:defineStat("Willpower",	"wil", 10, 1, 100, "Willpower defines your character's ability to concentrate. It increases your mana ,stamina and PSI capacity, and your chance to resist mental attacks.")
ActorStats:defineStat("Cunning",	"cun", 10, 1, 100, "Cunning defines your character's ability to learn, think, and react. It allows you to learn many worldly abilities, and increases your mental capabilities and chance of critical hits.")
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

-- Load tilesets, to speed up image loads
--Tiles:loadTileset("/data/gfx/ts-shockbolt-all.lua")

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

-- Configure chat dialogs
require("engine.dialogs.Chat").show_portraits = true

-- Inventory tabs
InventoryUI.default_tabslist = function(self)
	local tabslist = {
		{image="metal-ui/inven_tabs/weapons.png", 	kind="weapons",		desc="All kinds of weapons",		filter=function(o) return not o.__transmo and (o.type == "weapon") end},
		{image="metal-ui/inven_tabs/armors.png", 	kind="armors",		desc="All kinds of armours",		filter=function(o) return not o.__transmo and (o.type == "armor") end},
		{image="metal-ui/inven_tabs/jewelry.png", 	kind="jewelry",		desc="Rings and Amulets",		filter=function(o) return not o.__transmo and (o.type == "jewelry") end},
		{image="metal-ui/inven_tabs/gems.png", 		kind="gems",		desc="Gems"		,		filter=function(o) return not o.__transmo and (o.type == "gem" or o.type == "alchemist-gem") end},
		{image="metal-ui/inven_tabs/inscriptions.png", 	kind="inscriptions",	desc="Infusions, Runes, ...",		filter=function(o) return not o.__transmo and (o.type == "scroll") end},
		{image="metal-ui/inven_tabs/misc.png", 		kind="misc",		desc="Miscellaneous",			filter="others"},
		{image="metal-ui/inven_tabs/quests.png", 	kind="quests",		desc="Quest and plot related items",	filter=function(o) return not o.__transmo and (o.plot or o.quest) end},
	}
	if self.actor:attr("has_transmo") then tabslist[#tabslist+1] = {image="metal-ui/inven_tabs/chest.png", kind="transmo", desc="Transmogrification Chest", filter=function(o) return o.__transmo end} end
	tabslist[#tabslist+1] = {image="metal-ui/inven_tabs/all.png", kind="all", desc="All", filter="all"}
	return tabslist
end

class:triggerHook{"ToME:load"}

------------------------------------------------------------------------
-- Count the number of talents per types
------------------------------------------------------------------------
--[[
local type_tot = {}
for i, t in pairs(ActorTalents.talents_def) do
	type_tot[t.type[1] ] = (type_tot[t.type[1] ] or 0) + t.points
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
]]
------------------------------------------------------------------------
return {require "mod.class.Game", require "mod.class.World"}
