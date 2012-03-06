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

load("/data/general/npcs/all.lua", rarity(0))
load("/data/general/npcs/elven-caster.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "TUT_GUIDE",
	type = "humanoid", subtype = "human",
	display = "p",
	faction = "angolwen",
	name = "Nain the Guide", color=colors.VIOLET, unique = true,
	image="npc/humanoid_human_human_farmer.png",
	desc = [[A pitchfork-wielding human with a welcoming smile.]],
	level_range = {50, nil}, exp_worth = 2,
	rank = 4,
	size_category = 3,
	max_life = 750, life_rating = 34, fixed_rating = true,
	infravision = 10,
	stats = { str=10, dex=15, cun=42, mag=26, con=14 },
	instakill_immune = 1,
	teleport_immune = 1,
	move_others=true,
	never_move = 1,

	open_door = true,

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },


	can_talk = "tutorial-start",
}

newEntity{ base = "BASE_NPC_SKELETON", define_as = "TUTORIAL_NPC_MAGE", image="npc/skeleton_mage.png",
	name = "skeleton mage", color=colors.LIGHT_RED,
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(50,60),
	max_mana = resolvers.rngavg(70,80),
	combat_armor = 3, combat_def = 1,
	stats = { str=10, dex=12, cun=14, mag=14, con=10 },
	resolvers.talents{ [Talents.T_MANATHRUST]=3 },

	resolvers.equip{ {type="weapon", subtype="staff", autoreq=true} },

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
}

newEntity{ base = "BASE_NPC_TROLL", define_as = "TUTORIAL_NPC_TROLL",
	name = "half-dead forest troll", color=colors.YELLOW_GREEN,
	desc = [[Green-skinned and ugly, this massive humanoid glares at you, clenching wart-covered green fists.
He looks hurt.]],
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(10,20),
	combat_armor = 3, combat_def = 0,
}

newEntity{ base = "BASE_NPC_CANINE", define_as = "TUTORIAL_NPC_LONE_WOLF",
	name = "Lone Wolf", color=colors.VIOLET, unique=true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/animal_canine_lone_wolf.png", display_h=2, display_y=-1}}},
	desc = [[It is a large wolf with eyes full of cunning, only 3 times bigger than a normal wolf. It looks hungry. You look tasty!]],
	level_range = {3, nil}, exp_worth = 2,
	rank = 4,
	size_category = 4,
	max_life = 220,
	combat_armor = 8, combat_def = 0,
	combat = { dam=20, atk=15, apr=4 },

	stats = { str=25, dex=20, cun=15, mag=10, con=15 },

	resolvers.talents{
		[Talents.T_GLOOM]=1,
		[Talents.T_RUSH]=1,
		[Talents.T_CRIPPLE]=1,
	},
	resolvers.sustains_at_birth(),

	ai = "dumb_talented_simple", ai_state = { talent_in=4, ai_move="move_astar", },

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("tutorial", engine.Quest.COMPLETED, "finished-basic-gameplay")
		local d = require("engine.dialogs.ShowText").new("Basic Gameplay: Finished", "tutorial/basic-done")
		game:registerDialog(d)
		local g = game.zone:makeEntityByName(game.level, "terrain", "PORTAL_BACK")
		game.zone:addEntity(game.level, g, "terrain", self.x, self.y)
		local q = game.player:hasQuest("tutorial")
		--q:final_message()
	end,
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "TUTORIAL_ORC",
	name = "Orc", color=colors.LIGHT_UMBER,
	image="npc/humanoid_orc_orc_soldier.png",
	--desc = [[He is a hardy, well-weathered survivor.]],
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
--	resolvers.equip{
--		{type="weapon", subtype="waraxe", autoreq=true},
--		{type="armor", subtype="shield", autoreq=true},
--	},
	--resolvers.inscriptions(1, "infusion"),
	combat_armor = 2, combat_def = 0,
	resolvers.talents{
		[Talents.T_WEAPONS_MASTERY]={base=1, every=5, max=10},
		[Talents.T_SHIELD_PUMMEL]={base=1, every=6, max=5},
	},
	--resolvers.racial(),
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "PACIFIST_ORC",
	name = "Orc", color=colors.LIGHT_UMBER,
	image="npc/humanoid_orc_orc_child.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	combat_atk = 6,
	combat_def = 86,
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "PACIFIST_ORC_2",
	name = "Orc", color=colors.LIGHT_UMBER,
	image="npc/humanoid_orc_orc_child.png",
	level_range = {1, nil}, exp_worth = 1,
	combat_atk = 6,
	max_life = 100,
	combat_def = 83,
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "REGENERATING_ORC",
	name = "Quick-healing orc", color=colors.LIGHT_UMBER,
	image="npc/humanoid_orc_orc_child.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	combat_atk = -4,
	combat_def = 51,
	combat_physresist = 48,
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	define_as = "FEEBLE_ELF",
	name = "Robe-clad elf", color=colors.DARK_SEA_GREEN,
	image="npc/humanoid_shalore_elven_blood_mage.png",
	desc = [[An elf that looks as though he spends a good amount of his time wiggling his fingers and chanting.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	mana_regen = 20,
	positive_regen = 20,
	max_life = resolvers.rngavg(100, 110), life_rating = 13,
	combat_physresist = 26,
	combat_spellpower = 130,
	combat_armor = 0, combat_def = 0,
	never_move = 1,
	combat = false,
	ai = "tactical", ai_state = { talent_in=1, },
	resolvers.talents{
		[Talents.T_ARCANE_SHIELD]={base=5, every=8, max=6},
		[Talents.T_HEAL]={base=5, every=8, max=5},
		[Talents.T_SHIELDING]={base=5, every=8, max=6},
		[Talents.T_AEGIS]={base=5, every=8, max=5},
		[Talents.T_HEALING_LIGHT]={base=5, every=8, max=6},
		[Talents.T_BARRIER]={base=5, every=8, max=5},
		[Talents.T_QUICKEN_SPELLS]={base=5, every=8, max=6},
		[Talents.T_METAFLOW]={base=5, every=8, max=5},
	},
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "ROOTED_ORC",
	name = "Stubborn orc", color=colors.LIGHT_UMBER,
	image="npc/humanoid_orc_orc_child.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	combat_atk = -4,
	combat_def = 51,
	combat_physresist = 100,
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "OBSTINATE_ORC",
	name = "Obstinate orc", color=colors.LIGHT_UMBER,
	image="npc/humanoid_orc_orc_child.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	combat_atk = -4,
	combat_def = 51,
	combat_physresist = 150,
	combat_spellresist = 144,
	combat_mentalresist = 38,
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "PUSHY_ORC",
	name = "Pushy orc", color=colors.LIGHT_UMBER,
	image="npc/humanoid_orc_orc_child.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	ai = "tactical", ai_state = { talent_in=1, },
	combat_mindpower = 145,
	resolvers.talents{
		[Talents.T_TUTORIAL_MIND_KB]={base=5, every=8, max=6},
	},
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "RUDE_ORC",
	name = "Rude orc", color=colors.LIGHT_UMBER,
	image="npc/humanoid_orc_orc_child.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	combat_atk = -4,
	combat_def = 51,
	combat_physresist = 180,
	combat_spellresist = 144,
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_TROLL",
	define_as = "AVERAGE_TROLL",
	name = "Troll", color=colors.LIGHT_UMBER,
	image="npc/troll_c.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	combat_atk = -4,
	combat_def = 51,
	combat_physresist = 97,
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_TROLL",
	define_as = "UGLY_TROLL",
	name = "Ugly troll", color=colors.LIGHT_UMBER,
	image="npc/troll_c_02.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	combat_atk = -4,
	combat_def = 51,
	combat_physresist = 113,
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_TROLL",
	define_as = "GROSS_TROLL",
	name = "Gross troll", color=colors.LIGHT_UMBER,
	image="npc/troll_f.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	combat_atk = -4,
	combat_def = 51,
	combat_physresist = 133,
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_TROLL",
	define_as = "GHASTLY_TROLL",
	name = "Ghastly troll", color=colors.LIGHT_UMBER,
	image="npc/troll_m.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	combat_atk = -4,
	combat_def = 51,
	combat_physresist = 153,
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_TROLL",
	define_as = "FORUM_TROLL",
	name = "Forum troll", color=colors.LIGHT_UMBER,
	image="npc/troll_mt.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	combat_atk = -4,
	combat_def = 51,
	combat_physresist = 269,
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	define_as = "PUSHY_ELF",
	name = "Pushy elf", color=colors.LIGHT_UMBER,
	image="npc/humanoid_shalore_elven_cultist.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	ai = "tactical", ai_state = { talent_in=1, },
	combat_spellpower = 47,
	combat_mentalresist = -7,
	resolvers.talents{
		[Talents.T_TUTORIAL_SPELL_KB]={base=3, every=8, max=6},
	},
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	define_as = "BLUSTERING_ELF",
	name = "Blustering elf", color=colors.LIGHT_UMBER,
	image="npc/humanoid_shalore_elven_blood_mage.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	ai = "tactical", ai_state = { talent_in=1, },
	combat_spellpower = 28,
	combat_mentalresist = 42,
	resolvers.talents{
		[Talents.T_TUTORIAL_SPELL_KB]={base=3, every=8, max=6},
	},
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	define_as = "BREEZY_ELF",
	name = "Breezy elf", color=colors.LIGHT_UMBER,
	image="npc/humanoid_shalore_elven_mage.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	ai = "tactical", ai_state = { talent_in=1, },
	combat_spellpower = 30,
	combat_mentalresist = 30,
	resolvers.talents{
		[Talents.T_TUTORIAL_SPELL_KB]={base=3, every=8, max=6},
	},
	never_move = 1,
	combat = false,
}


newEntity{
	define_as = "BASE_TUTORIAL_SPIDER",
	type = "spiderkin", subtype = "spider",
	display = "S", color=colors.WHITE,
	desc = [[Arachnophobia...]],

	combat = false,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	size_category = 2,
	rank = 1,

	autolevel = "spider",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
	global_speed_base = 1,
	stats = { str=15, dex=15, mag=8, con=10 },
	resolvers.tmasteries{ ["technique/other"]=0.3 },
	resolvers.sustains_at_birth(),
	poison_immune = 0.9,
	never_move = 1,
	resists = { [DamageType.NATURE] = 20, [DamageType.LIGHT] = -20 },
}

newEntity{ base = "BASE_TUTORIAL_SPIDER",
	define_as = "TUT_SPIDER_1",
	name = "giant spider", color=colors.LIGHT_DARK,
	desc = [[A huge arachnid.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 100,
	life_regen = 50,
	life_rating = 10,
	ai = "tactical", ai_state = { talent_in=1, },
	combat_armor = 30, 
	combat_def = 5,
	combat_physresist = 0,
	combat_spellresist = 0,
	combat_mentalresist = 0,
}

newEntity{ base = "BASE_TUTORIAL_SPIDER",
	define_as = "TUT_SPIDER_2",
	name = "chittering spider", color=colors.LIGHT_DARK,
	image="npc/spiderkin_spider_chitinous_spider.png",
	desc = [[A huge, chittering arachnid.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 100,
	life_regen = 50,
	life_rating = 10,
	ai = "tactical", ai_state = { talent_in=1, },
	combat_armor = 30, 
	combat_def = 5,
	combat_physresist = 30,
	combat_spellresist = 25,
	combat_mentalresist = 20,
}

newEntity{ base = "BASE_TUTORIAL_SPIDER",
	define_as = "TUT_SPIDER_3",
	name = "hairy spider", color=colors.LIGHT_DARK,
	image="npc/spiderkin_spider_ninurlhing.png",
	desc = [[A huge, hairy arachnid.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 100,
	life_regen = 50,
	life_rating = 10,
	ai = "tactical", ai_state = { talent_in=1, },
	combat_armor = 30, 
	combat_def = 5,
	combat_physresist = 60,
	combat_spellresist = 61,
	combat_mentalresist = 79,
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	define_as = "BORED_ELF_1",
	name = "Bored elf", color=colors.LIGHT_UMBER,
	image="npc/humanoid_shalore_elven_cultist.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	ai = "tactical", ai_state = { talent_in=1, },
	combat_spellpower = 247,
	combat_mentalresist = -7,
	resolvers.talents{
		[Talents.T_TUTORIAL_SPELL_KB]={base=3, every=8, max=6},
	},
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	define_as = "BORED_ELF_2",
	name = "Idle elf", color=colors.LIGHT_UMBER,
	image="npc/humanoid_shalore_elven_mage.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	ai = "tactical", ai_state = { talent_in=1, },
	combat_mindpower = 247,
	combat_mentalresist = -7,
	resolvers.talents{
		[Talents.T_TUTORIAL_MIND_FEAR]={base=3, every=8, max=6},
	},
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ELVEN_CASTER",
	define_as = "BORED_ELF_3",
	name = "Loitering elf", color=colors.LIGHT_UMBER,
	image="npc/humanoid_shalore_elven_blood_mage.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	ai = "tactical", ai_state = { talent_in=1, },
	combat_spellpower = 247,
	combat_mentalresist = -7,
	resolvers.talents{
		[Talents.T_TUTORIAL_SPELL_BLINK]={base=3, every=8, max=6},
	},
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "ACCURACY_ORC_2",
	name = "Dull-eyed orc", color=colors.LIGHT_UMBER,
	image="npc/humanoid_orc_orc_child.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	combat_atk = 24,
	combat_def = 51,
	combat_physcrit = 50,
	never_move = 1,
	combat = false,
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "ACCURACY_ORC_5",
	name = "Keen-eyed orc", color=colors.LIGHT_UMBER,
	image="npc/humanoid_orc_orc_child.png",
	level_range = {1, nil}, exp_worth = 1,
	max_life = 100,
	life_regen = 50,
	combat_atk = 800,
	combat_def = 51,
	combat_physcrit = 50,
	never_move = 1,
	combat = false,
}