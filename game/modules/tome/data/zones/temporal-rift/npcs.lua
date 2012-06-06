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

load("/data/general/npcs/telugoroth.lua", rarity(0))
load("/data/general/npcs/horror_temporal.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "BEN_CRUTHDAR_ABOMINATION",
	type = "humanoid", subtype = "temporal", unique = true,
	name = "Ben Cruthdar, the Abomination", image = "npc/humanoid_human_ben_cruthdar__the_cursed.png",
	display = "p", color=colors.VIOLET,
	desc = [[This crazed madman seems twisted and corrupted by temporal energy, his body shifting and phasing in and out of reality.]],
	level_range = {15, nil}, exp_worth = 2,
	max_life = 270, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	stats = { str=20, dex=15, wil=18, con=20 },
	rank = 3.5,
	size_category = 3,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	resists = { [DamageType.COLD] = 25,  [DamageType.TEMPORAL] = 25},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{ {type="weapon", subtype="battleaxe", force_drop=true, tome_drops="boss", autoreq=true}, },
	resolvers.drops{chance=100, nb=1, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_GLOOM]=3,
		[Talents.T_WEAKNESS]=3,
		[Talents.T_DISMAY]=3,
		[Talents.T_UNNATURAL_BODY]=4,
		[Talents.T_DOMINATE]=1,
		[Talents.T_BLINDSIDE]=3,
		[Talents.T_SLASH]=3,
		[Talents.T_RECKLESS_CHARGE]=1,

		[Talents.T_DAMAGE_SMEARING]=5,
		[Talents.T_WEAPON_FOLDING]=3,
		[Talents.T_DISPLACE_DAMAGE]=3,
		[Talents.T_TEMPORAL_WAKE]=3,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriorwill",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(1, "healing infusion"),

	-- On die needs to make stairs back to the Rift
	on_die = function(self, who)
		game.level.data.portal_next(self)
	end,
}

newEntity{ define_as = "ABOMINATION_RANTHA",
	type = "dragon", subtype = "temporal", unique = true,
	name = "Rantha the Abomination",
	display = "D", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/dragon_temporal_rantha_the_abomination.png", display_h=2, display_y=-1}}},
	desc = [[Claws and teeth. Ice and death. Dragons are not all extinct it seems...  and this one seems to have been corrupted by the time rift.]],
	level_range = {15, nil}, exp_worth = 2,
	max_life = 220, life_rating = 15, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 3.5,
	size_category = 5,
	combat_armor = 17, combat_def = 14,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	resists = { [DamageType.FIRE] = -20, [DamageType.COLD] = 100,  [DamageType.TEMPORAL] = 25, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	-- Frost Treads drop should be changed.
	resolvers.drops{chance=100, nb=5, {type="gem"} },
	resolvers.drops{chance=100, nb=10, {type="money"} },

	resolvers.talents{
		[Talents.T_KNOCKBACK]=3,

		[Talents.T_ICE_STORM]=2,
		[Talents.T_FREEZE]=3,

		[Talents.T_ICE_CLAW]=4,
		[Talents.T_ICY_SKIN]=3,
		[Talents.T_ICE_BREATH]=4,

		[Talents.T_CELERITY]=4,
		[Talents.T_SLOW]=4,
		[Talents.T_STOP]=4,
		[Talents.T_HASTE]=4,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(1, "infusion"),

	-- On die needs to make stairs back to the Rift
	on_die = function(self, who)
		game.level.data.portal_next(self)
	end,
}

local twin_take_hit = function(self, value, src)
	value = mod.class.Actor.onTakeHit(self, value, src)
	value = value / 2
	if value > 0 and self.brother then
		local o = self.brother.onTakeHit
		self.brother.onTakeHit = nil
		self.brother:takeHit(value, src)
		self.brother.onTakeHit = o
	end
	return value
end

newEntity{ base="BASE_NPC_HORROR_TEMPORAL", define_as = "CHRONOLITH_TWIN",
	name = "Chronolith Twin", color=colors.VIOLET, unique = true,
	subtype = "temporal",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_temporal_cronolith_twin.png", display_h=2, display_y=-1}}},
	desc = [[A six armed creature with black insect-like eyes dressed in robes.]],
	level_range = {20, nil}, exp_worth = 1,
	max_life = 150, life_rating = 15, fixed_rating = true,
	rank = 4,
	size_category = 3,
	stats = { str=10, dex=12, cun=14, mag=25, wil=25, con=16 },

	instakill_immune = 1,
	blind_immune = 0.5,
	silence_immune = 0.5,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=2, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {unique=true} },

	resists = { [DamageType.TEMPORAL] = 50, },

	resolvers.talents{
		[Talents.T_DUST_TO_DUST]=3,
		[Talents.T_REPULSION_BLAST]=3,
		[Talents.T_DESTABILIZE]=3,
		[Talents.T_ECHOES_FROM_THE_PAST]=3,
		[Talents.T_HASTE]=3,
		[Talents.T_STATIC_HISTORY]=5,
		[Talents.T_ENERGY_ABSORPTION]=5,
		[Talents.T_REPULSION_FIELD]=5,
	},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic "ranged",
	resolvers.inscriptions(1, {"shielding rune"}),

	onTakeHit = twin_take_hit,

	on_die = function(self, who)
		self.brother = nil
		game.player:resolveSource():setQuestStatus("temporal-rift", engine.Quest.COMPLETED, "twin")
	end,
}

newEntity{ base="BASE_NPC_HORROR_TEMPORAL", define_as = "CHRONOLITH_CLONE",
	name = "Chronolith Clone", color=colors.VIOLET, unique = true,
	subtype = "temporal",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_temporal_cronolith_clone.png", display_h=2, display_y=-1}}},
	desc = [[A six armed creature with black insect-like eyes dressed in robes.]],
	level_range = {20, nil}, exp_worth = 1,
	max_life = 150, life_rating = 15, fixed_rating = true,
	rank = 4,
	size_category = 3,
	stats = { str=10, dex=12, cun=14, mag=25, wil=25, con=16 },

	instakill_immune = 1,
	blind_immune = 0.5,
	silence_immune = 0.5,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=2, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {unique=true} },

	resists = { [DamageType.TEMPORAL] = 50, },

	resolvers.talents{
		[Talents.T_RETHREAD]=3,
		[Talents.T_FADE_FROM_TIME]=3,
		[Talents.T_TEMPORAL_FUGUE]=3,
		[Talents.T_TURN_BACK_THE_CLOCK]=3,
		[Talents.T_HASTE]=3,
		[Talents.T_BANISH]=5,
		[Talents.T_STATIC_HISTORY]=5,
		[Talents.T_ENTROPIC_FIELD]=5,
	},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic "ranged",
	resolvers.inscriptions(1, {"invisibility rune"}),

	onTakeHit = twin_take_hit,

	on_die = function(self, who)
		self.brother = nil
		game.player:resolveSource():setQuestStatus("temporal-rift", engine.Quest.COMPLETED, "clone")
	end,
}
