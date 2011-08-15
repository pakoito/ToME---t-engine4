-- ToME - Tales of Maj'Eyal
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

load("/data/general/npcs/skeleton.lua")
load("/data/general/npcs/ghoul.lua")
load("/data/general/npcs/vampire.lua")
load("/data/general/npcs/bone-giant.lua")
load("/data/general/npcs/lich.lua")

newEntity{ define_as = "CELIA",
	name = "Celia",
	type = "humanoid", subtype = "human", image = "npc/humanoid_human_celia.png",
	female = true,
	display = "p", color=colors.GREY,
	desc = [[A tall woman stands before you in a stained robe. Her sallow skin is marked by pox and open sores, but her eyes are bright and keen. The bulge around her abdomen would indicate that she is several months pregnant.]],
	autolevel = "caster",
	stats = { str=12, dex=17, mag=22, wil=22, con=12 },

	infravision = 10,
	move_others = true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	rank = 3.5,
	exp_worth = 2,
	level_range = {20, nil},

	max_life = 200, life_regen = 0,
	life_rating = 16,

	resolvers.talents{
		[Talents.T_INVOKE_DARKNESS]=4,
		[Talents.T_FLAME]=5,
		[Talents.T_MANATHRUST]=3,
	},
	resolvers.sustains_at_birth(),

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(2, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),

	on_takehit = function(self, val)
		self.on_takehit = nil
		game.zone.open_all_coffins(game.player, self)
		return val
	end,

	on_die = function(self)
		if not game.level.turn_counter then return end
		game.level.turn_counter = game.level.turn_counter + 6 * 10

		local nb = 0
		local melinda
		for uid, e in pairs(game.level.entities) do
			if e.define_as and e.define_as == "ACOLYTE" and not e.dead then nb = nb + 1 end
			if e.define_as and e.define_as == "MELINDA" then melinda = e end
		end
		if nb == 0 then
			game.level.turn_counter = nil

			local spot = game.level:pickSpot{type="locked-door", subtype="locked-door"}
			local g = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
			game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)

			if melinda then
				melinda:removeEffect(melinda.EFF_TIME_PRISON)
				melinda.display_w = nil
				melinda.image = "npc/woman_redhair_naked.png"
				if melinda._mo then melinda._mo:invalidate() melinda._mo = nil end
				game.level.map:updateMap(melinda.x, melinda.y)
				require("engine.ui.Dialog"):simpleLongPopup("Melinda", "The woman seems to be freed from her bonds.\nShe stumbles on her feet, her naked body still dripping in blood. 'Please get me out of here!'", 400)
			end
		end
	end,
}
