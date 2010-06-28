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

-- Random escort
id = "escort-duty-"..game.zone.short_name.."-"..game.level.level

kind = {}

name = ""
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Escort the "..self.kind.name.." to the recall portal on level "..self.level_name.."."
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	self.on_grant = nil
	local types = {
		{ name="lost warrior",
			types = {
				["technique/combat-training"] = 0.7,
				["technique/combat-techniques-active"] = 0.7,
				["technique/combat-techniques-passive"] = 0.7,
			},
			talents =
			{
				[who.T_RUSH] = 1,
			},
			stats =
			{
				[who.STAT_STR] = 2,
				[who.STAT_DEX] = 1,
				[who.STAT_CON] = 2,
			},
			actor = {
				type = "humanoid", subtype = "human",
				display = "@", color=colors.UMBER,
				name = "lost warrior", faction = who.faction,
				desc = [[He looks tired and wounded.]],
				autolevel = "warrior",
				ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=3, },
				stats = { str=18, dex=13, mag=5, con=15 },

				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
				resolvers.equip{ {type="weapon", subtype="greatsword", autoreq=true} },
				resolvers.talents{ [who.T_STUNNING_BLOW]=1, },
				lite = 4,
				rank = 2,

				level_range = {game.level.level, game.level.level}, exp_worth = 0,

				max_life = 50,
				life_rating = 5,
				combat_armor = 3, combat_def = 3,

				summoner = who,
				quest_id = self.id,
				on_die = function(self, who)
					game.logPlayer(game.player, "#LIGHT_RED#The %s is dead, quest failed!", self.name)
					game.player:setQuestStatus(self.quest_id, engine.Quest.FAILED)
				end,
			},
		},
	}
	self.kind = rng.table(types)

	-- Spawn actor
	local x, y = util.findFreeGrid(who.x, who.y, 10, true, {[engine.Map.ACTOR]=true})
	if not x then return end
	local npc = mod.class.NPC.new(self.kind.actor)
	npc:resolve()
	npc:resolve(nil, true)
	game.zone:addEntity(game.level, npc, "actor", x, y)

	-- Setup quest
	self.name = "Escort: "..self.kind.name
	self.level_name = game.level.level.." of "..game.zone.name
end
