-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

local tacticals = {}
local Entity = require "engine.Entity"

local oldNewTalent = Talents.newTalent
Talents.newTalent = function(self, t)
	local tt = engine.interface.ActorTalents.talents_types_def[t.type[1]]
	assert(tt, "No talent category "..tostring(t.type[1]).." for talent "..t.name)
	if tt.generic then t.generic = true end
	if tt.no_silence then t.no_silence = true end
	if tt.is_spell then t.is_spell = true end
	if tt.is_mind then t.is_mind = true end
	if tt.is_nature then t.is_nature = true end
	if tt.is_antimagic then t.is_antimagic = true end
	if tt.is_unarmed then t.is_unarmed = true end
	if tt.autolearn_mindslayer then t.autolearn_mindslayer = true end
	if tt.speed and not t.speed then t.speed = tt.speed end

	if t.tactical then
		local tacts = {}
		for tact, val in pairs(t.tactical) do
			tact = tact:lower()
			tacts[tact] = val
			tacticals[tact] = true
		end
		t.tactical = tacts
	end

	if not t.image then
		t.image = "talents/"..(t.short_name or t.name):lower():gsub("[^a-z0-9_]", "_")..".png"
	end
	if fs.exists("/data/gfx/"..t.image) then t.display_entity = Entity.new{image=t.image, is_talent=true}
	else t.display_entity = Entity.new{image="talents/default.png", is_talent=true}
	end
	return oldNewTalent(self, t)
end

damDesc = function(self, type, dam)
	-- Increases damage
	if self.inc_damage then
		local inc = self:combatGetDamageIncrease(type)
		dam = dam + (dam * inc / 100)
	end
	return dam
end

Talents.damDesc = damDesc
Talents.main_env = getfenv(1)

load("/data/talents/misc/misc.lua")
load("/data/talents/techniques/techniques.lua")
load("/data/talents/cunning/cunning.lua")
load("/data/talents/spells/spells.lua")
load("/data/talents/gifts/gifts.lua")
load("/data/talents/celestial/celestial.lua")
load("/data/talents/corruptions/corruptions.lua")
load("/data/talents/undeads/undeads.lua")
load("/data/talents/cursed/cursed.lua")
load("/data/talents/chronomancy/chronomancer.lua")
load("/data/talents/psionic/psionic.lua")
load("/data/talents/uber/uber.lua")

print("[TALENTS TACTICS]")
for k, _ in pairs(tacticals) do print(" * ", k) end

