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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_HORROR_UNDEAD",
	type = "undead", subtype = "horror",
	display = "h", color=colors.WHITE,
	blood_color = colors.BLUE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },

	stats = { str=20, dex=20, wil=20, mag=20, con=20, cun=20 },
	combat_armor = 5, combat_def = 10,
	combat = { dam=5, atk=10, apr=5, dammod={str=0.6} },
	infravision = 10,
	max_life = resolvers.rngavg(10,20),
	rank = 2,
	size_category = 3,

	blind_immune = 1,
	fear_immune = 1,
	see_invisible = 2,
	undead = 1,
	not_power_source = {nature=true},
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "necrotic mass", color=colors.DARK_GREY,
	desc ="This putrid mass of rotting flesh shifts and quivers, but shows no signs of intelligence or mobility.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_horror_necrotic_mass.png", display_h=2, display_y=-1}}},
	level_range = {15, nil}, exp_worth = 1,
	rarity = 3,
	rank = 1,
	size_category = 2, life_rating = 7,
	combat_armor = 0, combat_def = 0,
	max_life=100,
	combat = {dam=resolvers.levelup(resolvers.mbonus(25, 15), 1, 1.1), apr=0, atk=resolvers.mbonus(30, 15), dammod={str=0.6}},

	never_move = 1,
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "necrotic abomination", color=colors.DARK_GREEN,
	desc ="This monstrous form of putrid, torn flesh and chipped bone drags its mass towards you, spurting blood and viscera along the way.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_horror_necrotic_abomination.png", display_h=2, display_y=-1}}},
	level_range = {30, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	size_category = 4,
	combat_armor = 0, combat_def = 40,
	max_life=400,
	disease_immune = 1,
	
	combat = {
		dam=resolvers.levelup(resolvers.rngavg(40,45), 1, 1.2),
		atk=resolvers.rngavg(60,80), apr=20,
		dammod={mag=1.2}, physcrit = 10,
		damtype=engine.DamageType.BLIGHT,
	},
	
	autolevel = "caster",
	
	summon = {
		{type="undead", number=4, hasxp=false},
	},
	
	resolvers.talents{
		[Talents.T_VIRULENT_DISEASE]={base=4, every=8, max=6},
		[Talents.T_EPIDEMIC]={base=4, every=8},
		[Talents.T_SOUL_ROT]={base=5, every=10, max=8},
		[Talents.T_CORROSIVE_WORM]={base=5, every=10, max=8},
		[Talents.T_BLIGHTZONE]={base=3, every=10, max=6},
		
		[Talents.T_SPIT_BLIGHT]={base=3, every=10, max=8},
	},
	
	on_die = function(self, who)
		game.logSeen(self, "#VIOLET#As the necrotic abomination is destroyed you see the remaining bones and flesh reassembling in the form of new foes!")
		self:forceUseTalent(self.T_SUMMON, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true, force_level=1})
	end,
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "bone horror", color=colors.WHITE,
	desc ="The massive ribcage in the middle beats with loud, audible cracks, as many a skeletal hand protrude forth, entwining, fusing, forming long skeletal appendages to support itself, while others crumble and collapse inward. During all this, somehow, it seems they grasp for you.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_horror_bone_horror.png", display_h=2, display_y=-1}}},
	level_range = {30, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	size_category = 4,
	combat_armor = 30, combat_def = 0,
	max_life=400, life_rating = 12,
	disease_immune = 1,
	cut_immune = 1,
	
	combat = {
		dam=resolvers.levelup(resolvers.rngavg(60,70), 1, 1.2),
		atk=resolvers.rngavg(60,80), apr=40,
		dammod={mag=1, str=0.5}, physcrit = 12,
		damtype=engine.DamageType.PHYSICALBLEED,
	},
	
	autolevel = "warriormage",
	
	summon = {
		{type="undead", subtype = "skeleton", number=4, hasxp=false},
	},
	
	resolvers.talents{
		[Talents.T_BONE_GRAB]={base=4, every=8, max=10},
		[Talents.T_BONE_NOVA]={base=2, every=8, max=8},
		[Talents.T_BONE_SPEAR]={base=5, every=5, max=12},
		
		[Talents.T_SKULLCRACKER]={base=7, every=15, max=10},
		[Talents.T_THROW_BONES]={base=4, every=10, max=8},
		
		[Talents.T_BONE_SHIELD]={base=6, every=30, max=11},
	},
	
	on_die = function(self, who)
		game.logSeen(self, "#VIOLET#As the bone horror is destroyed you see the remaining bones reassembling in the form of new foes!")
		self:forceUseTalent(self.T_SUMMON, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true, force_level=1})
	end,
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "sanguine horror", color=colors.RED,
	desc ="This pulsing, quivering form is a deep crimson, and appears to be composed entirely of thick, virulent blood. Waves rhythmically ripple across its surface, indicating a still beating heart somewhere in its body.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_horror_sanguine_horror.png", display_h=2, display_y=-1}}},
	level_range = {30, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	size_category = 4,
	combat_armor = 30, combat_def = 0,
	max_life=400,
	stats = { con=50, },
	
	combat = {
		dam=resolvers.levelup(resolvers.rngavg(50,60), 1, 1.2),
		atk=resolvers.rngavg(60,80), apr=20,
		dammod={mag=1.1}, physcrit = 12,
		damtype=engine.DamageType.CORRUPTED_BLOOD,
	},
	
	autolevel = "caster",
	
	summon = {
		{type="undead", subtype = "blood", number=2, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		
		[Talents.T_BLOOD_SPRAY]={base=4, every=6, max = 10},
		[Talents.T_BLOOD_GRASP]={base=3, every=5, max = 9},
		[Talents.T_BLOOD_BOIL]={base=2, every=7, max = 7},
		[Talents.T_BLOOD_FURY]={base=5, every=8, max = 6},
		
		[Talents.T_BLOOD_LOCK]={base=4, every=10, max=8},
		
		[Talents.T_BLOODSPRING]=1, --And to make things interesting...
	},
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "animated blood", color=colors.RED, subtype = "blood",
	desc ="This crimson shape drips ceaselessly, spattering the nearby ground. The droplets seem to continue moving of their own volition.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_horror_animated_blood.png", display_h=2, display_y=-1}}},
	level_range = {15, nil}, exp_worth = 1,
	rarity = 20, -- Appear alone but rarely.
	rank = 1,
	size_category = 2, life_rating = 7,
	combat_armor = 0, combat_def = 0,
	max_life=100,
	combat = {dam=resolvers.levelup(resolvers.mbonus(25, 15), 1, 1.1), apr=0, atk=resolvers.mbonus(30, 15), dammod={str=0.6}},
}