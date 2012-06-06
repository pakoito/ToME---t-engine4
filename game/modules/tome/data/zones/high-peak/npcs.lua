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

-- Orcs & trolls
load("/data/general/npcs/orc-grushnak.lua", rarity(0))
load("/data/general/npcs/orc-vor.lua", rarity(0))
load("/data/general/npcs/orc-gorbat.lua", rarity(0))
load("/data/general/npcs/orc-rak-shor.lua", rarity(6))
load("/data/general/npcs/orc.lua", rarity(8))
--load("/data/general/npcs/troll.lua", rarity(0))

-- Others
load("/data/general/npcs/naga.lua", rarity(6))
load("/data/general/npcs/snow-giant.lua", rarity(6))

-- Demons
load("/data/general/npcs/minor-demon.lua", rarity(3))
load("/data/general/npcs/major-demon.lua", rarity(3))

-- Drakes
load("/data/general/npcs/fire-drake.lua", rarity(10))
load("/data/general/npcs/cold-drake.lua", rarity(10))
load("/data/general/npcs/multihued-drake.lua", rarity(10))

-- Undeads
load("/data/general/npcs/bone-giant.lua", rarity(10))
load("/data/general/npcs/vampire.lua", rarity(10))
load("/data/general/npcs/ghoul.lua", rarity(10))
load("/data/general/npcs/skeleton.lua", rarity(10))
load("/data/general/npcs/ghost.lua", rarity(4))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

-- Alatar & Palando, the final bosses
newEntity{
	define_as = "ELANDAR",
	type = "humanoid", subtype = "shalore",
	name = "Elandar",
	display = "@", color=colors.AQUAMARINE,
	faction = "sorcerers",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_shalore_elandar.png", display_h=2, display_y=-1}}},

	desc = [[Renegade mages from Angolwen, the Sorcerers have set up in the Far East, slowly growing corrupt. Now they must be stopped.]],
	level_range = {75, nil}, exp_worth = 15,
	max_life = 1000, life_rating = 36, fixed_rating = true,
	max_mana = 10000,
	mana_regen = 10,
	negative_regen = 10,
	rank = 5,
	size_category = 3,
	stats = { str=40, dex=30, cun=60, mag=60, con=40 },

	see_invisible = 100,
	instakill_immune = 1,
	stun_immune = 0.5,
	confusion_immune = 0.5,
	blind_immune = 1,

	combat_armor = 20,
	combat_def = 20,

	no_auto_resists = true,
	resists = { all = 40, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, FEET=1 },
	resolvers.equip{
		{type="weapon", subtype="staff", defined="STAFF_ABSORPTION_AWAKENED", autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="head", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="feet", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_STONE_SKIN]={base=7, every=6},
		[Talents.T_QUICKEN_SPELLS]={base=7, every=6},
		[Talents.T_SPELLCRAFT]={base=7, every=6},
		[Talents.T_ARCANE_POWER]={base=7, every=6},
		[Talents.T_ESSENCE_OF_SPEED]={base=7, every=6},
		[Talents.T_HYMN_OF_SHADOWS]={base=7, every=6},

		[Talents.T_FLAME]={base=7, every=6},
		[Talents.T_FREEZE]={base=7, every=6},
		[Talents.T_LIGHTNING]={base=7, every=6},
		[Talents.T_MANATHRUST]={base=7, every=6},
		[Talents.T_FLAMESHOCK]={base=7, every=6},
		[Talents.T_STRIKE]={base=7, every=6},
		[Talents.T_HEAL]={base=7, every=6},
		[Talents.T_REGENERATION]={base=7, every=6},
		[Talents.T_ILLUMINATE]={base=7, every=6},
		[Talents.T_METAFLOW]={base=7, every=6},
		[Talents.T_PHASE_DOOR]={base=7, every=6},

		[Talents.T_MOONLIGHT_RAY]={base=7, every=6},
		[Talents.T_STARFALL]={base=7, every=6},
		[Talents.T_TWILIGHT_SURGE]={base=7, every=6},
	},
	resolvers.sustains_at_birth(),

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(6, {"healing infusion", "regeneration infusion", "shielding rune", "invisibility rune", "movement infusion", "wild infusion"}),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("high-peak", engine.Quest.COMPLETED, "elandar-dead")
	end,
}

newEntity{
	define_as = "ARGONIEL",
	type = "humanoid", subtype = "human",
	name = "Argoniel",
	display = "@", color=colors.ROYAL_BLUE,
	faction = "sorcerers",
	female = true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_argoniel.png", display_h=2, display_y=-1}}},

	desc = [[Renegade mages from Angolwen, the Sorcerers have set up in the Far East, slowly growing corrupt. Now they must be stopped.]],
	level_range = {75, nil}, exp_worth = 15,
	max_life = 1000, life_rating = 42, fixed_rating = true,
	max_mana = 10000,
	mana_regen = 10,
	vim_regen = 50,
	rank = 5,
	size_category = 3,
	stats = { str=40, dex=60, cun=60, mag=30, con=40 },

	see_invisible = 100,
	instakill_immune = 1,
	stun_immune = 0.5,
	confusion_immune = 0.5,
	blind_immune = 1,

	combat_armor = 20,
	combat_def = 20,

	no_auto_resists = true,
	resists = { all = 45, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FEET=1, HEAD=1, HANDS=1 },
	resolvers.equip{
		{type="weapon", subtype="sword", force_drop=true,  forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
		{type="weapon", subtype="waraxe", force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
		{type="armor", subtype="massive", force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
		{type="armor", subtype="feet", name="pair of voratun boots", force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
		{type="armor", subtype="head", name="voratun helm", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="hands", name="voratun gauntlets", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {defined="PEARL_LIFE_DEATH"} },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_RUSH]=6,
		[Talents.T_BONE_GRAB]={base=7, every=6},
		[Talents.T_BONE_SPEAR]={base=7, every=6},
		[Talents.T_BONE_SHIELD]={base=7, every=6},
		[Talents.T_BURNING_HEX]={base=7, every=6},
		[Talents.T_EMPATHIC_HEX]={base=7, every=6},
		[Talents.T_CURSE_OF_VULNERABILITY]={base=7, every=6},
		[Talents.T_CURSE_OF_DEFENSELESSNESS]={base=7, every=6},
		[Talents.T_CURSE_OF_DEATH]={base=7, every=6},
		[Talents.T_VIRULENT_DISEASE]={base=7, every=6},
		[Talents.T_CYST_BURST]={base=7, every=6},
		[Talents.T_CATALEPSY]={base=7, every=6},
		[Talents.T_EPIDEMIC]={base=7, every=6},
		[Talents.T_REND]={base=7, every=6},
		[Talents.T_RUIN]={base=7, every=6},
		[Talents.T_DARK_SURPRISE]={base=7, every=6},
		[Talents.T_CORRUPTED_STRENGTH]={base=7, every=6},
		[Talents.T_BLOODLUST]={base=7, every=6},
		[Talents.T_ACID_BLOOD]={base=7, every=6},
		[Talents.T_DRAIN]={base=7, every=6},

		[Talents.T_WEAPON_COMBAT]=5,
		[Talents.T_WEAPONS_MASTERY]={base=4, every=10},
		[Talents.T_ARMOUR_TRAINING]={base=7, every=6},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(2, {"shielding rune", "shielding rune"}),
	resolvers.inscriptions(3, {}),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("high-peak", engine.Quest.COMPLETED, "argoniel-dead")
	end,
}

-- Aeryn trying to kill the player if charred scar quest failed
newEntity{ define_as = "FALLEN_SUN_PALADIN_AERYN",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "human",
	display = "p",
	faction = "sorcerers",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_fallen_sun_paladin_aeryn.png", display_h=2, display_y=-1}}},
	name = "Fallen Sun Paladin Aeryn", color=colors.VIOLET, unique = true,
	desc = [[A beautiful woman, clad in shining plate armour. Power radiates from her.]],
	level_range = {56, nil}, exp_worth = 2,
	rank = 5,
	size_category = 3,
	female = true,
	max_life = 250, life_rating = 30, fixed_rating = true,
	infravision = 10,
	stats = { str=15, dex=10, cun=12, mag=16, con=14 },
	instakill_immune = 1,
	move_others=true,

	open_door = true,

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(4, {}),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, FEET=1 },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.equip{
		{type="weapon", subtype="mace", force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
		{type="armor", subtype="shield", force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
		{type="armor", subtype="massive", force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
		{type="armor", subtype="feet", force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
		{type="armor", subtype="head", force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss", autoreq=true},
	},

	die = function(self, src)
		if game.zone.short_name ~= "high-peak" then
			return mod.class.NPC.die(self, src)
		end
		self.die = function() end
		local Chat = require "engine.Chat"
		local chat = Chat.new("fallen-aeryn", self, game.player)
		chat:invoke()
	end,

	positive_regen = 25,

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=7,
		[Talents.T_WEAPON_COMBAT]=5,
		[Talents.T_WEAPONS_MASTERY]=5,
		[Talents.T_RUSH]=3,

		[Talents.T_CHANT_OF_FORTITUDE]=7,
		[Talents.T_SEARING_LIGHT]=7,
		[Talents.T_MARTYRDOM]=7,
		[Talents.T_BARRIER]=7,
		[Talents.T_WEAPON_OF_LIGHT]=7,
		[Talents.T_MARTYRDOM]=7,
		[Talents.T_HEALING_LIGHT]=7,
		[Talents.T_CRUSADE]=8,
		[Talents.T_SUN_FLARE]=7,
		[Talents.T_FIREBEAM]=7,
		[Talents.T_SUNBURST]=8,
		[Talents.T_SHIELD_OF_LIGHT]=6,
		[Talents.T_SECOND_LIFE]=7,
		[Talents.T_BATHE_IN_LIGHT]=7,
		[Talents.T_PROVIDENCE]=7,
	},
	resolvers.sustains_at_birth(),
}

-- Aeryn coming back to help the player in the fight with the Sorcerers
newEntity{ define_as = "HIGH_SUN_PALADIN_AERYN",
	type = "humanoid", subtype = "human",
	display = "p",
	faction = "sunwall",
	name = "High Sun Paladin Aeryn", color=colors.VIOLET, unique = "High Sun Paladin Aeryn High Peak Help",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_high_sun_paladin_aeryn.png", display_h=2, display_y=-1}}},
	desc = [[A beautiful woman, clad in shining plate armour. Power radiates from her.]],
	level_range = {56, 56}, exp_worth = 2,
	rank = 5,
	size_category = 3,
	female = true,
	max_life = 250, life_rating = 30, fixed_rating = true,
	infravision = 10,
	stats = { str=15, dex=10, cun=12, mag=16, con=14 },
	instakill_immune = 1,
	stun_immune = 0.5,
	move_others=true,
	never_anger = true,

	open_door = true,

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(4, {}),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, FEET=1 },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.equip{
		{type="weapon", subtype="mace", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="shield", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="massive", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="feet", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="head", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},

	positive_regen = 25,

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=5,
		[Talents.T_WEAPON_COMBAT]=5,
		[Talents.T_WEAPONS_MASTERY]=5,
		[Talents.T_RUSH]=8,

		[Talents.T_CHANT_OF_FORTITUDE]=5,
		[Talents.T_SEARING_LIGHT]=5,
		[Talents.T_MARTYRDOM]=5,
		[Talents.T_BARRIER]=5,
		[Talents.T_WEAPON_OF_LIGHT]=5,
		[Talents.T_HEALING_LIGHT]=5,
		[Talents.T_CRUSADE]=8,
		[Talents.T_FIREBEAM]=7,
		[Talents.T_SUNBURST]=8,
		[Talents.T_SHIELD_OF_LIGHT]=6,
		[Talents.T_SECOND_LIFE]=5,
		[Talents.T_BATHE_IN_LIGHT]=5,
		[Talents.T_PROVIDENCE]=5,
	},
	resolvers.sustains_at_birth(),
}
