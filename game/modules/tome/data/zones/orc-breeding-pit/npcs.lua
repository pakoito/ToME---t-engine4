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

load("/data/general/npcs/orc.lua", rarity(40))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_ORC",
	name = "orc baby", color=colors.GREEN,
	desc = [[Crawling on all fours, this green-skinned creature is far from cute, with vicious little sharp teeth and nails, and mucusy slime still sticking to its skin.]],
	level_range = {25, nil}, exp_worth = 0,
	resolvers.generic(function(e) if rng.percent(50) then e.female = true end end),
	rarity = 3,
	max_life = resolvers.rngavg(30,50), life_rating = 4,
	rank = 2,
	movement_speed = 0.7,
	melee_project = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},
	on_melee_hit = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(15,50), 1, 0.5), atk=resolvers.rngavg(15,50), dammod={str=1} },
}

newEntity{ base = "BASE_NPC_ORC",
	name = "orc child", color=colors.LIGHT_GREEN,
	desc = [[This small orc has a malicious and greedy look in its eyes. Its veins pulse with new life and it moves with surprising speed. Though not fully developed you can still see the muscles forming on its long limbs, leading to clawed fingers and toes.]],
	resolvers.generic(function(e) if rng.percent(50) then e.female = true end end),
	level_range = {25, nil}, exp_worth = 0,
	rarity = 3,
	max_life = resolvers.rngavg(30,50), life_rating = 9, life_regen = 7,
	movement_speed = 1.3,
	size_category = 1,
	melee_project = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},
	on_melee_hit = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(15,50), 1, 0.5), atk=resolvers.rngavg(15,50), dammod={str=1} },
	resolvers.talents{
		[Talents.T_RUSH]=4,
	},
}

newEntity{ base = "BASE_NPC_ORC",
	name = "young orc", color=colors.TEAL,
	desc = [[This young orc is almost fully formed, with hard muscles prominently visible beneath its thick skin. Whilst it has lost some of the wild energy of its younger siblings you can see the gleams of intelligence and cold calculation behind its dark eyes.]],
	resolvers.generic(function(e) if rng.percent(50) then e.female = true end end),
	level_range = {25, nil}, exp_worth = 0,
	rarity = 3,

	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	resolvers.inscriptions(1, "infusion"),
	size_category = 2,
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_SHIELD_PUMMEL]={base=1, every=3, max=5}, },
}

newEntity{ base = "BASE_NPC_ORC",
	name = "orc mother", color=colors.YELLOW,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_orc_mother.png", display_h=2, display_y=-1}}},
	desc = [[This giant, bloated form towers above you. Mucus and slime ooze from every orifice, dripping onto the cavern floor. Orc children fight over the right to feed from her distended teats whilst small babies are regularly pushed out from her many pulsating vulvas. The sight and the smell make you retch.]],
	level_range = {25, nil}, exp_worth = 1,
	female = true,
	rarity = 8,
	never_move = 1,
	stun_immune = 1,
	size_category = 4,

	max_life = resolvers.rngavg(350,430), life_rating = 22,
	rank = 3,

	melee_project = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},
	on_melee_hit = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},

	summon = {
		{type="humanoid", subtype="orc", name="orc baby", number=1, hasxp=false},
	},

--	ai = "tactical",

	combat_armor = 45, combat_def = 0,

	talent_cd_reduction={[Talents.T_SUMMON]=-3, },
	resolvers.talents{
		[Talents.T_SUMMON]=10,
		[Talents.T_SLIME_SPIT]={base=3, every=5, max=8},
	},
}

newEntity{ base="BASE_NPC_ORC", define_as = "GREATMOTHER",
	name = "Orc Greatmother", color=colors.VIOLET, unique = true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_orc_greatmother.png", display_h=2, display_y=-1}}},
	desc = [[Here stands a tremendous form almost the size of a dragon.  Bloated skin rises in thick folds, seeping viscous slime from its wide pores.  Hundreds of hanging teats feed a small army of squabbling, fighting young orcs - only the toughest of them are able to gain the precious nutrients to grow stronger, the weaker ones left to wither on the mouldy floor.  Dozens of gaping vulvae squelch and pulsate, pushing out new young with alarming rapidity.  At the top of this towering hulk is a shrivelled head coated in long tangled hair.  Dazed eyes peer out with a mixture of sadness and pain, but as they fix on you they turn to anger, the creature's face contorted with the fierce desire to protect its young.]],
	killer_message = "and given to the children as a plaything",
	level_range = {40, nil}, exp_worth = 1,
	female = true,
	rank = 5,
	max_life = 700, life_rating = 25, fixed_rating = true,
	infravision = 10,
	move_others=true,
	never_move = 1,
	size_category = 5,

	instakill_immune = 1,
	stun_immune = 1,

	open_door = true,

	resolvers.inscriptions(2, "infusion"),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, FEET=1, FINGER=2, NECK=1 },

	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} },

	make_escort = {
		{type="humanoid", subtype="orc", name="orc baby", number=4, hasxp=false},
	},
	summon = {
		{type="humanoid", subtype="orc", name="orc baby", number=1, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_SUMMON]=10,
		[Talents.T_SLIME_SPIT]={base=3, every=5, max=8},
		[Talents.T_BATTLE_CALL]=5,
		[Talents.T_BONE_GRAB]=4,
		[Talents.T_BONE_SPEAR]={base=4, every=3, max=12},
		[Talents.T_SHATTERING_SHOUT]=5,
		[Talents.T_UNSTOPPABLE]=5,
	},
	resolvers.sustains_at_birth(),

	on_die = function(self, who)
		game.log("#PURPLE#As the orc greatmother falls you realize you have dealt a crippling blow to the orcs.")
		game.state:eastPatrolsReduce()
		world:gainAchievement("GREATMOTHER_DEAD", who)
	end,
}
