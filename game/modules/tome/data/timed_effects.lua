-- ToME - Tales of Maj'Eyal
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

--	All timed effects are divided into physical, mental, magical, or other types.  Timed effect types are organized based on what saving throw or dispel would be most appropriate
--	along with consideration based on how it can be applied.  There's a lot of overlap between natural and magical timed effects so when in doubt an effect will not be magical.
--	Frozen is a good example of this because of Frost Breath.  Effects falling into the other category have no save and generally can not be removed unless they're specifically called.

--	All subtype organization is based off the root cause if one is available or effect if not.  For example burning is a fire effect, caused by fire.
--	Stun is a more general effect and can have many causes, thus it's subtype is based off its effect, so in this case the subtype is simply 'stun'.
--	Burning Shock could easily fall into either of these subtypes.  First we ask if it has a cause, it does, fire.  Therefore it is subtype 'fire' rather then subtype 'stun'.


local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

local resolveSource = function(self)
	if self.src then
		return self.src:resolveSource()
	else
		return self
	end
end

--gets the full name of the effect
local getName = function(self)
	local name = self.effect_id and mod.class.Actor.tempeffect_def[self.effect_id].desc or "effect"
	if self.src and self.src.name then
		return name .." from "..self.src.name:capitalize()
	else
		return name
	end
end

local oldNewEffect = TemporaryEffects.newEffect
TemporaryEffects.newEffect = function(self, t)
	if not t.image then
		t.image = "effects/"..(t.name):lower():gsub("[^a-z0-9_]", "_")..".png"
	end
	if fs.exists("/data/gfx/"..t.image) then t.display_entity = Entity.new{image=t.image, is_effect=true}
	else t.display_entity = Entity.new{image="effects/default.png", is_effect=true} print("===", t.type, t.name)
	end
	t.getName = getName
	t.resolveSource = resolveSource
	return oldNewEffect(self, t)
end

load("/data/timed_effects/magical.lua")
load("/data/timed_effects/physical.lua")
load("/data/timed_effects/mental.lua")
load("/data/timed_effects/other.lua")
load("/data/timed_effects/floor.lua")
