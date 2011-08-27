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

load("/data/general/npcs/skeleton.lua", rarity(0))
load("/data/general/npcs/ghoul.lua", rarity(1))
load("/data/general/npcs/wight.lua", rarity(3))
load("/data/general/npcs/vampire.lua", rarity(3))
load("/data/general/npcs/ghost.lua", rarity(3))

load("/data/general/npcs/all.lua", rarity(4, 35))

-- Not normally appearing, used for the Pale Drake summons
load("/data/general/npcs/bone-giant.lua", function(e) if e.rarity then e.bonegiant_rarity = e.rarity; e.rarity = nil end end)

local Talents = require("engine.interface.ActorTalents")

-- The boss of Dreadfell, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "THE_MASTER",
	allow_infinite_dungeon = true,
	faction = "dreadfell",
	type = "undead", subtype = "vampire", unique = true, image = "npc/the_master.png",
	name = "The Master",
	display = "V", color=colors.VIOLET,
	desc = [[A terrifying vampiric figure of power, with flowing robes and an intense aura of fright.  His cold, sinewy flesh seems to cling to this world through greed and malice, and his eyes betray a strength of mind beyond any puny mortal.  All nearby are utterly subservient to his will, though he stands aloof from them, as if to say he needs not the pathetic meddling of minions to help him overcome his foes.  Your eyes are drawn to a dark staff in his hands which seems to suck the very life from the air around it.  It looks ancient and dangerous and terrible, and the sight of it fills you with fervent desire.]],
	killer_message = "and raised as his tortured undead thrall",
	level_range = {23, nil}, exp_worth = 2,
	max_life = 350, life_rating = 19, fixed_rating = true,
	max_mana = 145,
	max_stamina = 145,
	rank = 5,
	size_category = 3,
	infravision = 10,
	stats = { str=19, dex=19, cun=34, mag=25, con=16 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="greatsword", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="heavy", force_drop=true, tome_drops="boss", autoreq=true},
		{type="jewelry", subtype="amulet", defined="AMULET_DREAD", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
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
	necrotic_aura_base_souls = 10,

	resolvers.talents{
		[Talents.T_NECROTIC_AURA] = 1,
		[Talents.T_AURA_MASTERY] = 6,
		[Talents.T_CREATE_MINIONS]={base=4, every=5, max=7},
		[Talents.T_RIGOR_MORTIS]={base=3, every=5, max=5},
		[Talents.T_CIRCLE_OF_DEATH]={base=3, every=5, max=5},
		[Talents.T_SURGE_OF_UNDEATH]={base=3, every=5, max=5},
		[Talents.T_WILL_O__THE_WISP]={base=3, every=5, max=5},

		[Talents.T_CONGEAL_TIME]={base=2, every=5, max=5},
		[Talents.T_MANATHRUST]={base=4, every=5, max=8},
		[Talents.T_FREEZE]={base=4, every=5, max=8},
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_STRIKE]={base=3, every=5, max=7},

		[Talents.T_ARMOUR_TRAINING]={base=3, every=5, max=10},
		[Talents.T_WEAPONS_MASTERY]={base=3, every=4, max=7},
		[Talents.T_STUNNING_BLOW]={base=1, every=5, max=5},
		[Talents.T_RUSH]={base=4, every=5, max=8},
		[Talents.T_SPELL_SHIELD]={base=4, every=5, max=8},
		[Talents.T_BLINDING_SPEED]={base=4, every=5, max=8},
		[Talents.T_PERFECT_STRIKE]={base=3, every=5, max=7},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(3, {"shielding rune", "shielding rune", "invisibility rune", "speed rune"}),
	resolvers.inscriptions(1, {"manasurge rune"}),

	on_act = function(self)
		if rng.percent(10) and self:isTalentActive(self.T_NECROTIC_AURA) then
			local p = self:isTalentActive(self.T_NECROTIC_AURA)
			p.souls = util.bound(p.souls + 1, 0, p.souls_max)
		end
	end,

	on_die = function(self, who)
		game.state:activateBackupGuardian("PALE_DRAKE", 1, 40, "It has been months since the hero cleansed the Dreadfell, yet rumours are growing: evil is back.")

		world:gainAchievement("VAMPIRE_CRUSHER", game.player:resolveSource())
		game.player:resolveSource():grantQuest("dreadfell")
		game.player:resolveSource():setQuestStatus("dreadfell", engine.Quest.COMPLETED)

		local ud = {}
		if not profile.mod.allow_build.undead_skeleton then ud[#ud+1] = "undead_skeleton" end
		if not profile.mod.allow_build.undead_ghoul then ud[#ud+1] = "undead_ghoul" end
		if #ud == 0 then return end
		game:setAllowedBuild("undead")
		game:setAllowedBuild(rng.table(ud), true)
	end,
}

-- The boss of Dreadfell, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "PALE_DRAKE",
	allow_infinite_dungeon = true,
	faction = "dreadfell",
	type = "undead", subtype = "skeleton", unique = true,
	name = "Pale Drake",
	display = "s", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_skeleton_pale_drake.png", display_h=2, display_y=-1}}},
	desc = [[A malevolent skeleton archmage that has taken control of the Dreadfell since the Master's demise.]],
	level_range = {40, nil}, exp_worth = 3,
	max_life = 450, life_rating = 21, fixed_rating = true,
	rank = 4,
	size_category = 3,
	infravision = 10,
	stats = { str=19, dex=19, cun=44, mag=25, con=16 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="RUNED_SKULL", random_art_replace={chance=75}} },

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

		[Talents.T_WILDFIRE]={base=5, every=5, max=8},

		[Talents.T_FLAME]={base=5, every=5, max=8},
		[Talents.T_FLAMESHOCK]={base=5, every=5, max=8},
		[Talents.T_INFERNO]={base=5, every=5, max=8},
		[Talents.T_MANATHRUST]={base=5, every=5, max=8},

		[Talents.T_CURSE_OF_DEATH]={base=5, every=5, max=8},
		[Talents.T_CURSE_OF_VULNERABILITY]={base=5, every=5, max=8},
		[Talents.T_BONE_SPEAR]={base=5, every=5, max=8},
		[Talents.T_DRAIN]={base=5, every=5, max=8},

		[Talents.T_PHASE_DOOR]=2,
	},
	resolvers.sustains_at_birth(),

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(4, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),
}
