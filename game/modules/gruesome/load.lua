-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorAI = require "engine.interface.ActorAI"
local ActorLevel = require "engine.interface.ActorLevel"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"

-- Useful keybinds
KeyBind:load("move,hotkeys,inventory,actions,interface,debug")

-- Damage types
DamageType:loadDefinition("/data/damage_types.lua")

-- Talents
ActorTalents:loadDefinition("/data/talents.lua")

-- Timed Effects
ActorTemporaryEffects:loadDefinition("/data/timed_effects.lua")

-- Actor resources
ActorResource:defineResource("Shadow", "shadow", nil, "shadow_regen", "Power represent your ability to use special talents.")
ActorResource:defineResource("Lurk", "lurk", nil, "lurk_regen", "Power represent your ability to use special talents.")

-- Actor AIs
ActorAI:loadDefinition("/engine/ai/")
ActorAI:loadDefinition("/mod/ai/")

-- Birther descriptor
Birther:loadDefinition("/data/birth/descriptors.lua")

return {require "mod.class.Game" }
