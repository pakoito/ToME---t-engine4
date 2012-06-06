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


local Talents = require("engine.interface.ActorTalents")

newEntity{ name = "gladiator",
	define_as = "GLADIATOR",
	type = "humanoid", subtype = "human",
	color=colors.GOLD, display = "p",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=25, nb=1, {} },
	resolvers.drops{chance=100, nb=1, {type="money"} },
	resolvers.inscriptions(1, "wild infusion"),
	life_rating = 15,
	rank = 3,
	infravision = 10,
	lite = 2,
	open_door = true,
	stun_immune = 0.4,
	autolevel = "warrior",
	ai = "tactical", ai_state = { ai_move = "move_dmap", talent_in = 1 },

	stats = { str=15, dex=15, mag=1, con=15 },
	desc = [[A menacing man in heavy armor, wielding a mace. He looks battle-hardened.]],
	level_range = {5, 19}, exp_worth = 2,
	rarity = false,
	max_life = resolvers.rngavg(100,125),
	resolvers.equip{
		{type="weapon", subtype="mace", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true},
		{type="armor", subtype="feet", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_SHIELD_PUMMEL]=2,
		[Talents.T_RUSH]=3,
		[Talents.T_REPULSION]=2,
		[Talents.T_ARMOUR_TRAINING] = 3,
		[Talents.T_WEAPON_COMBAT] = 1,
	},
	on_die = function (self)
		local m = game.zone:makeEntityByName(game.level, "actor", "ARCANEBLADE")
		if m then
			local y = 2
			if game.player.y < 3 then y = 11 end
			game.zone:addEntity(game.level, m, "actor", 8, y)
		end
	end
}

newEntity{ name = "halfling slinger",
	define_as = "SLINGER",
	type = "humanoid", subtype = "halfling",
	color=colors.GOLD, display = "p",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=25, nb=1, {} },
	resolvers.drops{chance=100, nb=1, {type="money"} },
	resolvers.inscriptions(1, "phase door rune"),
	stun_immune = 0.4,
	life_rating = 8,
	rank = 3,
	infravision = 10,
	lite = 2,
	open_door = true,
	autolevel = "slinger",
	ai = "tactical", ai_state = { ai_move = "move_dmap", talent_in = 1 },

	stats = { str=10, dex=15, cun=15, con=8 },
	desc = [[A halfling slinger. He seems adept at combat.]],
	level_range = {6, 20}, exp_worth = 1,
	rarity = false,
	max_life = resolvers.rngavg(100,110),
	resolvers.equip{
		{type="weapon", subtype="sling", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
		{type="ammo", subtype="shot"},
		{type="armor", subtype="shield", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_SHOOT]=1,
		[Talents.T_DISENGAGE]=2,
		[Talents.T_RAPID_SHOT]=3,
		[Talents.T_INERTIAL_SHOT]=2,
		[Talents.T_HEAVE]=3,
		[Talents.T_WEAPON_COMBAT] = 2,
	},
	on_added = function (self)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		game:playSoundNear(game.player, "talents/teleport")
	end,
	on_die = function (self)
		local m = game.zone:makeEntityByName(game.level, "actor", "GLADIATOR")
		if m then
			local y = 2
			if game.player.y < 3 then y = 11 end
			game.zone:addEntity(game.level, m, "actor", 8, y)
		end
	end
}

newEntity{ name = "arcane blade",
	define_as = "ARCANEBLADE",
	type = "humanoid", subtype = "human",
	color=colors.GOLD, display = "p",

	combat = { dam=resolvers.rngavg(6,12), atk=3, apr=6, physspeed=2 },
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=100, nb=1, {type="weapon", tome_drops="boss"}},
	resolvers.drops{chance=100, nb=2, {type="money"} },
	resolvers.inscriptions(1, "shielding rune"),
	stun_immune = 0.4,
	life_rating = 15,
	rank = 3,
	infravision = 10,
	lite = 2,
	open_door = true,
	autolevel = "warrior",
	ai = "tactical", ai_state = { ai_move = "move_dmap", talent_in = 1 },

	stats = { str=20, dex=20, mag=8, con=16 },
	desc = [[A human Arcane Blade. His body shows multiple scars from battle.]],
	level_range = {6, 21}, exp_worth = 2,
	rarity = false,
	max_life = resolvers.rngavg(100,130),
	resolvers.equip{
		{type="weapon", subtype="greatsword", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="heavy", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="feet", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_ARCANE_COMBAT]=2,
		[Talents.T_ARCANE_FEED]=2,
		[Talents.T_FLAME]=1,
		[Talents.T_ARMOUR_TRAINING] = 2,
		[Talents.T_WEAPON_COMBAT] = 2,
	},
	on_added = function (self)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		game:playSoundNear(game.player, "talents/teleport")
	end,
	on_die = function (self)
		local Chat = require "engine.Chat"
		local npc = {name="Cornac rogue"}
		local chat = Chat.new("arena-unlock", npc, game.player, {npc=npc})
		chat:invoke("win")
	end
}
