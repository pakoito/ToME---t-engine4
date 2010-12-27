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

local oldNewTalent = newTalent
newTalent = function(t)
	assert(engine.interface.ActorTalents.talents_types_def[t.type[1]], "No talent category "..tostring(t.type[1]).." for talent "..t.name)
	if engine.interface.ActorTalents.talents_types_def[t.type[1]].generic then t.generic = true end
	if engine.interface.ActorTalents.talents_types_def[t.type[1]].no_silence then t.no_silence = true end
	if engine.interface.ActorTalents.talents_types_def[t.type[1]].is_spell then t.is_spell = true end

	if t.image then
		if type(t.image) == "boolean" then
			local name = t.name:gsub(" ", ""):lower()
			t.image = core.display.loadImage("data/gfx/talents/"..name..".png")
			assert(t.image, "talent auto image requested by not found for: "..t.name)
		else
			t.image = core.display.loadImage("data/gfx/"..t.image..".png")
			assert(t.image, "talent image requested by not found for: "..t.name)
		end
		t.image_texture = t.image:glTexture()
	end

	return oldNewTalent(t)
end

damDesc = function(self, type, dam)
	-- Increases damage
	if self.inc_damage then
		local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
		dam = dam + (dam * inc / 100)
	end
	return dam
end

load("/data/talents/misc/misc.lua")
load("/data/talents/techniques/techniques.lua")
load("/data/talents/cunning/cunning.lua")
load("/data/talents/spells/spells.lua")
load("/data/talents/gifts/gifts.lua")
load("/data/talents/divine/divine.lua")
load("/data/talents/corruptions/corruptions.lua")
load("/data/talents/undeads/undeads.lua")
load("/data/talents/cursed/cursed.lua")
load("/data/talents/chronomancy/chronomancer.lua")
load("/data/talents/psionic/psionic.lua")
