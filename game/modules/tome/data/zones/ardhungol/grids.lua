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

load("/data/general/grids/basic.lua")
load("/data/general/grids/cave.lua")
load("/data/general/grids/water.lua")

newEntity{ base="CAVEFLOOR", define_as = "WORMHOLE", nice_tiler = false,
	name = "unstable wormhole",
	display = '*', color = colors.GREY,
	force_clone = true,
	damage_project = function(self, src, x, y, type, dam)
		local source_talent = src.__projecting_for and src.__projecting_for.project_type and (src.__projecting_for.project_type.talent_id or src.__projecting_for.project_type.talent) and src.getTalentFromId and src:getTalentFromId(src.__projecting_for.project_type.talent or src.__projecting_for.project_type.talent_id)
		if _G.type(dam) == "table" and _G.type(dam.dam) == "number" then dam = dam.dam end
		if dam and source_talent and source_talent.is_spell and rng.percent(dam / 3) and not game.__tmp_ardhungol_projecting then
			local a = game.level.map(x, y, engine.Map.ACTOR)
			if a then
				game.logSeen(src, "#VIOLET#The wormhole absorbs the energy of the spell and teleports %s away!", a.name)
				a:teleportRandom(x, y, 20)
			else
				game.logSeen({x=x,y=y}, "#VIOLET#The wormhole absorbs the energy of the spell and explodes in a burst of nullmagic!")
				local DT = engine.DamageType

				local grids = core.fov.circle_grids(x, y, 2, true)
				game.__tmp_ardhungol_projecting = true -- OMFG this is fugly :/
				for x, yy in pairs(grids) do for y, _ in pairs(yy) do
					DT:get(DT.MANABURN).projector(self, x, y, DT.MANABURN, util.bound(dam / 2, 1, 200))					
				end end
				game.__tmp_ardhungol_projecting = nil

				game.level.map:particleEmitter(x, y, 2, "generic_sploom", {rm=150, rM=180, gm=20, gM=60, bm=180, bM=200, am=80, aM=150, radius=2, basenb=120})
			end
		end
	end,
	resolvers.generic(function(e) e:addParticles(engine.Particles.new("wormhole", 1, {})) end),
}
