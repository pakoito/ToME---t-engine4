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

load("/data/general/npcs/orc.lua", rarity(0))
load("/data/general/npcs/troll.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

-- The boss of Reknor, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "GOLBUG",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "orc", unique = true,
	faction = "orc-pride",
	name = "Golbug the Destroyer",
	display = "o", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_golbug_the_destroyer.png", display_h=2, display_y=-1}}},
	desc = [[A huge and muscular orc of unknown breed. He looks both menacing and cunning...]],
	level_range = {28, nil}, exp_worth = 2,
	max_life = 350, life_rating = 16, fixed_rating = true,
	max_stamina = 245,
	rank = 5,
	size_category = 3,
	infravision = 10,
	instakill_immune = 1,
	stats = { str=22, dex=19, cun=34, mag=10, con=16 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, HEAD=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="mace", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="shield", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="head", autoreq=true},
		{type="armor", subtype="massive", force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {type="jewelry", subtype="orb", defined="ORB_MANY_WAYS"} },

	stun_immune = 1,
	see_invisible = 5,

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=4, every=6, max=8},
		[Talents.T_WEAPON_COMBAT]={base=3, every=10, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=3, every=10, max=5},
		[Talents.T_SHIELD_PUMMEL]={base=4, every=5, max=6},
		[Talents.T_RUSH]={base=4, every=5, max=6},
		[Talents.T_RIPOSTE]={base=4, every=5, max=6},
		[Talents.T_BLINDING_SPEED]={base=4, every=5, max=6},
		[Talents.T_OVERPOWER]={base=3, every=5, max=5},
		[Talents.T_ASSAULT]={base=3, every=5, max=5},
		[Talents.T_SHIELD_WALL]={base=3, every=5, max=5},
		[Talents.T_SHIELD_EXPERTISE]={base=2, every=5, max=5},

		[Talents.T_BELLOWING_ROAR]={base=3, every=5, max=5},
		[Talents.T_WING_BUFFET]={base=2, every=5, max=5},
		[Talents.T_FIRE_BREATH]={base=4, every=5, max=7},

		[Talents.T_ICE_CLAW]={base=3, every=5, max=5},
		[Talents.T_ICY_SKIN]={base=4, every=5, max=7},
		[Talents.T_ICE_BREATH]={base=4, every=5, max=7},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(3, "infusion"),

	on_acquire_target = function(self, who)
		-- Doesn't matter who, just assume the player is there
		if not self.has_chatted then
			self.has_chatted = true
			local Chat = require("engine.Chat")
			local chat = Chat.new("golbug-explains", self, game.player)
			chat:invoke()
		end
	end,

	on_die = function(self, who)
		game.state:activateBackupGuardian("LITHFENGEL", 4, 35, "They say that after it has been confirmed orcs still inhabited Reknor, they found a mighty demon there.", function(gen)
			if gen then require("engine.ui.Dialog"):simpleLongPopup("Danger...", "When last you saw it, this cavern was littered with the corpses of orcs that you had slain. Now many, many more corpses carpet the floor, all charred and reeking of sulfur. An orange glow dimly illuminates the far reaches of the cavern to the east.", 400) end
		end)

		world:gainAchievement("DESTROYER_BANE", game.player:resolveSource())
		game.player:setQuestStatus("orc-hunt", engine.Quest.DONE)
		game.player:grantQuest("wild-wild-east")

		-- Add the herald, at the end of tick because we might have changed levels (like with a Demon Plane spell)
		game:onTickEnd(function()
			local harno = game.zone:makeEntityByName(game.level, "actor", "HARNO")
			game.zone:addEntity(game.level, harno, "actor", 0, 13)
		end)
	end,
}

-- The messenger sent by last-hope
newEntity{ define_as = "HARNO",
	type = "humanoid", subtype = "human", unique = true,
	faction = "allied-kingdoms",
	name = "Harno, Herald of Last Hope",
	display = "@", color=colors.LIGHT_BLUE,
	desc = [[This is one of the heralds of Last Hope. He seems to be looking for you.]],
	global_speed_base = 2,
	level_range = {40, 40}, exp_worth = 0,
	max_life = 150, life_rating = 12,
	rank = 3,
	infravision = 10,
	stats = { str=10, dex=29, cun=43, mag=10, con=10 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, HEAD=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="knife", autoreq=true},
		{type="weapon", subtype="knife", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {type="scroll", subtype="scroll", defined="NOTE_FROM_LAST_HOPE"} },

	stun_immune = 1,
	see_invisible = 100,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_target="target_player", ai_move="move_astar", },
	resolvers.inscriptions(2, {"speed rune", "speed rune"}),

	can_talk = "message-last-hope",
	can_talk_only_once = true,

	on_die = function(self, who)
		game.logPlayer(game.player, "#LIGHT_RED#You hear a death cry. '%s I have a messag... ARG!'", game.player.name:capitalize())
		game.player:setQuestStatus("orc-hunt", engine.Quest.DONE, "herald-died")
	end,
}

newEntity{ define_as = "LITHFENGEL", -- Lord of Ash; backup guardian
	allow_infinite_dungeon = true,
	type = "demon", subtype = "major", unique = true,
	name = "Lithfengel",
	display = "U", color=colors.VIOLET,
	desc = [[A terrible demon of decay and atrophy, drawn to the energy of the farportal. A beast of blight!]],
	level_range = {35, nil}, exp_worth = 3,
	max_life = 400, life_rating = 25, fixed_rating = true,
	rank = 4,
	size_category = 5,
	infravision = 30,
	-- The artifact he wields drains life a little, so to compensate:
	life_regen = 0.3,
	stats = { str=20, dex=15, cun=25, mag=25, con=20 },
	poison_immune = 1,
	fear_immune = 1,
	instakill_immune = 1,
	no_breath = 1,
	move_others=true,
	demon = 1,

	on_melee_hit = { [DamageType.BLIGHT] = 45, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="waraxe", defined="MALEDICTION", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=4, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="ATHAME_WEST"} },
	resolvers.drops{chance=100, nb=1, {defined="RESONATING_DIAMOND_WEST"} },

	resolvers.talents{
		[Talents.T_ROTTING_DISEASE]={base=5, every=6, max=8},
		[Talents.T_DECREPITUDE_DISEASE]={base=5, every=6, max=8},
		[Talents.T_WEAKNESS_DISEASE]={base=5, every=6, max=8},
		[Talents.T_CATALEPSY]={base=5, every=6, max=8},
		[Talents.T_RUSH]={base=5, every=6, max=8},
		[Talents.T_MORTAL_TERROR]={base=5, every=6, max=8},
		[Talents.T_WEAPON_COMBAT]=5,
		[Talents.T_WEAPONS_MASTERY]={base=3, every=10, max=5},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(3, {}),

	on_die = function(self, who)
		if who.resolveSource and who:resolveSource().player and who:resolveSource():hasQuest("east-portal") then
			require("engine.ui.Dialog"):simpleLongPopup("Back and there again", "A careful examination of the demon's body turns up a Blood-Runed Athame and a Resonating Diamond, both covered in soot and gore but otherwise in good condition.", 400)
		end
	end,
}
