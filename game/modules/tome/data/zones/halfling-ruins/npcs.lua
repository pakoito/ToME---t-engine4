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

load("/data/general/npcs/skeleton.lua", rarity(0))
load("/data/general/npcs/ghoul.lua", rarity(2))
load("/data/general/npcs/bone-giant.lua", rarity(8))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as="SUBJECT_Z",
	name = "Subject Z", color=colors.VIOLET, display = "p",
	desc = "This seems to be the 'subject Z' the notes spoke about. He looks human, but this can not be, he would be about five thousands years old!",
	type = "humanoid", subtype = "human",
	level_range = {10, nil}, exp_worth = 2,
	rank = 4,
	autolevel = "roguemage",
	max_life = 100, life_rating = 14,
	combat_armor = 0, combat_def = 15,
	open_door = 1,
	never_act = true,

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1, FINGER=1 },

	see_invisible = 20,

	resolvers.equip{
		{type="weapon", subtype="dagger", autoreq=true, ego_chance=100},
		{type="weapon", subtype="dagger", autoreq=true, ego_chance=100},
		{type="armor", subtype="light", autoreq=true, ego_chance=100},
		{defined="NIGHT_SONG", random_art_replace={chance=65}, autoreq=true},
	},

	resolvers.talents{
		[Talents.T_DUAL_WEAPON_DEFENSE]=3,
		[Talents.T_DUAL_WEAPON_TRAINING]=3,
		[Talents.T_FLURRY]=3,
		[Talents.T_DIRTY_FIGHTING]=3,
		[Talents.T_LETHALITY]=3,
		[Talents.T_WEAPON_COMBAT]=2,
		[Talents.T_KNIFE_MASTERY]=6,
		[Talents.T_SHADOW_COMBAT]=5,
		[Talents.T_SHADOWSTEP]=1,
		[Talents.T_PHASE_DOOR]=3,
		[Talents.T_SECOND_WIND]=4,
		[Talents.T_DARK_TENDRILS]=2,
	},
	resolvers.inscriptions(1, {"manasurge rune"}),
	resolvers.inscriptions(1, "infusion"),

	resolvers.sustains_at_birth(),

	seen_by = function(self, who)
		if not game.party:hasMember(who) then return end
		self.seen_by = nil
		self.never_act = nil

		local wayist = nil
		for uid, e in pairs(game.level.entities) do if e.define_as == "YEEK_WAYIST" then wayist = e break end end
		if not wayist then return end
		wayist.never_act = nil

		wayist:setTarget(self)
		self:setTarget(wayist)
		wayist:doEmote("Sacrifice for the Way!", 60)
	end,

	on_die = function(self, who)
		local wayist = nil
		for uid, e in pairs(game.level.entities) do if e.define_as == "YEEK_WAYIST" then wayist = e break end end
		if not wayist then return end

		local p = game.party:findMember{main=true}
		-- Yeeks really, really, really, hate halflings
		if p.descriptor.race == "Halfling" then
			wayist:doEmote("Halfling?! DIE!!!!!", 70)
			wayist:checkAngered(p, false, -200)
		elseif p.descriptor.race == "Yeek" then
			wayist:doEmote("The Way sent you?", 70)
			wayist.can_talk = "yeek-wayist"
		else
			wayist:doEmote("You.. saved me?", 70)
			wayist.can_talk = "yeek-wayist"
		end
	end,
}

newEntity{ define_as="YEEK_WAYIST",
	name = "Yeek Wayist", color=colors.VIOLET, display = "y",
	desc = "This seems to be the 'subject Z' the notes spoke about. He looks human, but this can not be, he would be about five thousands years old!",
	type = "humanoid", subtype = "yeek",
	level_range = {10, nil},
	rank = 3,
	autolevel = "wildcaster",
	max_life = 100, life_rating = 8,
	faction = "the-way",
	combat_armor = 0, combat_def = 0,
	psi_regen = 5,
	open_door = 1,
	never_act = true,

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, PSIONIC_FOCUS=1 },

	resolvers.equip{
		{type="weapon", subtype="greatsword", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_KINETIC_SHIELD]=3,
		[Talents.T_MINDHOOK]=1,
		[Talents.T_PYROKINESIS]=3,
		[Talents.T_MINDLASH]=2,
		[Talents.T_REACH]=4,
		[Talents.T_CHARGED_AURA]=2,
		[Talents.T_TELEKINETIC_SMASH]=2,
	},
	resolvers.inscriptions(1, "infusion"),

	resolvers.sustains_at_birth(),
}
