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
load("/data/general/npcs/shertul.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_SHERTUL", define_as = "CALDIZAR",
	name = "Caldizar", color=colors.LIGHT_RED, unique="Caldizar Unknown Fortress",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_sher_tul_caldizar.png", display_h=2, display_y=-1}}},
	desc ="A creature stands before you, with long tentacle-like appendages and a squat bump in place of a head. An intense aura of power radiates from this being unlike anything you've ever felt before. It can only be a Sher'Tul. A living Sher'Tul!",
	level_range = {100, nil}, exp_worth = 5,
	life_rating = 40,
	rank = 5,
	size_category = 4,
	faction = "sher'tul",
	autolevel = "caster",
	combat_armor = 1, combat_def = 0,
	combat = {dam=resolvers.levelup(resolvers.mbonus(25, 15), 1, 1.1), apr=0, atk=resolvers.mbonus(30, 15), dammod={mag=0.6}},

	never_move = 1,
	invulnerable = 1,

	resists = {all = 70},
	can_talk = "shertul-fortress-caldizar",

	seen_by = function(self, who)
		if not game.party:hasMember(who) or not who.player then return end
		self.seen_by = nil
		local chat = require("engine.Chat").new(self.can_talk, self, who, {player=who})
		local d = chat:invoke()
		local level = game.level
		d.innerDisplay = function(d, x, y, nb_keyframes)
			if level == game.level and who.life >= who.max_life * 0.1 then
				who:takeHit(who.max_life * 0.01 * nb_keyframes * 0.5, self)
				if who.updateMainShader then who:updateMainShader() end
			end
		end
	end
}
