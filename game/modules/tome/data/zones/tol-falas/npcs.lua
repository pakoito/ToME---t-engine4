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
load("/data/general/npcs/ghoul.lua", rarity(1))
load("/data/general/npcs/wight.lua", rarity(3))
load("/data/general/npcs/vampire.lua", rarity(3))
load("/data/general/npcs/ghost.lua", rarity(3))

load("/data/general/npcs/all.lua", rarity(4, 35))

-- Not normaly appearing, used for the Pale Drake summons
load("/data/general/npcs/bone-giant.lua", function(e) if e.rarity then e.bonegiant_rarity = e.rarity; e.rarity = nil end end)

local Talents = require("engine.interface.ActorTalents")

-- The boss of Tol Falas, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "THE_MASTER",
	faction = "tol-falas",
	type = "undead", subtype = "vampire", unique = true,
	name = "The Master",
	display = "V", color=colors.VIOLET,
	desc = [[This elder vampire seems to be in control here and does not seem very happy about you.]],
	level_range = {23, 45}, exp_worth = 2,
	max_life = 350, life_rating = 19, fixed_rating = true,
	max_mana = 145,
	max_stamina = 145,
	rank = 5,
	size_category = 3,
	infravision = 20,
	stats = { str=19, dex=19, cun=34, mag=25, con=16 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="greatsword", ego_chance=100, autoreq=true},
		{type="armor", subtype="heavy", ego_chance=50, autoreq=true},
		{type="jewelry", subtype="amulet", defined="AMULET_DREAD", random_art_replace={chance=75, rarity=210, level_range={25, 35}}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },
	resolvers.drops{chance=100, nb=1, {type="weapon", subtype="staff", defined="STAFF_ABSORPTION"} },

	summon = {
		{type="undead", number=2, hasxp=true},
	},

	instakill_immune = 1,
	blind_immune = 1,
	stun_immune = 0.7,
	see_invisible = 20,
	undead = 1,
	self_resurrect = 1,
	open_door = 1,

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_HEAVY_ARMOUR_TRAINING]=1,
		[Talents.T_MANA_POOL]=1,
			[Talents.T_CONGEAL_TIME]=2,
			[Talents.T_MANATHRUST]=4,
			[Talents.T_FREEZE]=4,
			[Talents.T_PHASE_DOOR]=2,
			[Talents.T_STRIKE]=3,
		[Talents.T_STAMINA_POOL]=1,
			[Talents.T_WEAPONS_MASTERY]=3,
			[Talents.T_STUNNING_BLOW]=1,
			[Talents.T_RUSH]=4,
			[Talents.T_SPELL_SHIELD]=4,
			[Talents.T_BLINDING_SPEED]=4,
			[Talents.T_PERFECT_STRIKE]=3,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar", },

	on_die = function(self, who)
		game.state:activateBackupGuardian("PALE_DRAKE", 1, 40, "It has been month since the hero cleansed Tol Falas, yet rumours are growing: evil is back.")

		world:gainAchievement("VAMPIRE_CRUSHER", game.player:resolveSource())
		game.player:resolveSource():grantQuest("tol-falas")
		game.player:resolveSource():setQuestStatus("tol-falas", engine.Quest.DONE)

		local ud = {}
		if not profile.mod.allow_build.undead_skeleton then ud[#ud+1] = "undead_skeleton" end
		if not profile.mod.allow_build.undead_ghoul then ud[#ud+1] = "undead_ghoul" end
		if #ud == 0 then return end
		game:setAllowedBuild("undead")
		game:setAllowedBuild(rng.table(ud), true)
	end,
}

-- The boss of Tol Falas, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "PALE_DRAKE",
	faction = "tol-falas",
	type = "undead", subtype = "skeleton", unique = true,
	name = "Pale Drake",
	display = "s", color=colors.VIOLET,
	desc = [[A malevolent skeleton archmage that has taken control of Tol Falas since the Master's demise.]],
	level_range = {40, 50}, exp_worth = 3,
	max_life = 450, life_rating = 21, fixed_rating = true,
	rank = 4,
	size_category = 3,
	infravision = 20,
	stats = { str=19, dex=19, cun=44, mag=25, con=16 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="staff", ego_chance=100, autoreq=true},
		{type="armor", subtype="cloth", ego_chance=50, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },
	resolvers.drops{chance=100, nb=1, {defined="RUNED_SKULL", random_art_replace={chance=75, rarity=250, level_range={40, 50}}} },

	summon = {
		{type="undead", subtype="bone giant", special_rarity="bonegiant_rarity", number=2, hasxp=true},
	},

	instakill_immune = 1,
	blind_immune = 1,
	stun_immune = 0.7,
	see_invisible = 100,
	undead = 1,
	self_resurrect = 1,
	open_door = 1,

	resists = { [DamageType.FIRE] = 100, },

	resolvers.talents{
		[Talents.T_SUMMON]=1,

		[Talents.T_WILDFIRE]=5,

		[Talents.T_FLAME]=5,
		[Talents.T_FLAMESHOCK]=5,
		[Talents.T_INFERNO]=5,
		[Talents.T_MANATHRUST]=5,

		[Talents.T_CURSE_OF_DEATH]=5,
		[Talents.T_CURSE_OF_VULNERABILITY]=5,
		[Talents.T_BONE_SPEAR]=5,
		[Talents.T_DRAIN]=5,

		[Talents.T_PHASE_DOOR]=2,
	},
	resolvers.sustains_at_birth(),

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar", },
}
