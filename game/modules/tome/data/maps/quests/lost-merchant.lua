-- ToME - Tales of Middle-Earth
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

defineTile('<', "UP_WILDERNESS")
defineTile(' ', "FLOOR")
defineTile('#', "WALL")
defineTile('+', "DOOR")
defineTile('a', "FLOOR", nil, "THIEF_ASSASSIN")
defineTile('p', "FLOOR", nil, "THIEF_BANDIT")

defineTile('P', "FLOOR", nil, mod.class.NPC.new{
	type = "humanoid", subtype = "human",
	display = "p", color=colors.VIOLET,
	name = "Assassin Lord",
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	resolvers.drops{chance=20, nb=1, {} },
	resolvers.equip{
		{type="weapon", subtype="dagger", autoreq=true, ego_change=50},
		{type="weapon", subtype="dagger", autoreq=true, ego_change=50},
		{type="armor", subtype="light", autoreq=true}
	},
	resolvers.drops{chance=100, nb=2, {type="money"} },

	rank = 4,
	size_category = 3,

	open_door = true,

	autolevel = "rogue",
	ai = "dumb_talented_simple", ai_state = { talent_in=5, },
	energy = { mod=1 },
	stats = { str=8, dex=15, mag=6, cun=15, con=7 },

	resolvers.tmasteries{ ["technique/other"]=0.3, ["cunning/stealth"]=1.3, ["cunning/dirty"]=0.3, ["technique/dualweapon-training"]=0.3 },

	desc = [[He is the leader of a gang of bandits, watch out for his men.]],
	level_range = {8, 50}, exp_worth = 1,
	rarity = 12,
	combat_armor = 5, combat_def = 7,
	max_life = resolvers.rngavg(90,100),
	resolvers.talents{ [engine.interface.ActorTalents.T_LETHALITY]=3,[engine.interface.ActorTalents.T_STEALTH]=3, [engine.interface.ActorTalents.T_LETHALITY]=3, },

	can_talk = "assassin-lord",

	on_die = function(self, who)
		game.level.map(self.x, self.y, game.level.map.TERRAIN, game.zone.grid_list.UP_WILDERNESS)
		game.logSeen(who, "As the assassin dies the magical veil protecting the stairs out vanishes.")
	end,
})

defineTile('@', "FLOOR", nil, mod.class.NPC.new{
	type = "humanoid", subtype = "human",
	display = "@", color=colors.UMBER,
	name = "Lost Merchant",
	size_category = 3,
	ai = "simple",
	faction = "reunited-kingdom",
	is_merchant = true,
})

startx = 2
starty = 9

return [[
####################
####################
##                ##
## ######         ##
## #    #   #+### ##
## #    #   #   # ##
## ####+# p ##### ##
##            a   ##
##              @ ##
##              P ##
##            a   ##
##  p     #+##### ##
## #####  #     # ##
## #   #  ####### ##
## #   #          ##
## #   +          ##
## #####          ##
##                ##
####################
####################]]
