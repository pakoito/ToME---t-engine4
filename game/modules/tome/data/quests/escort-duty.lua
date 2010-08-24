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

local Talents = require("engine.interface.ActorTalents")
local Stats = require("engine.interface.ActorStats")
local NameGenerator = require("engine.NameGenerator")
local Astar = require("engine.Astar")

--------------------------------------------------------------------------------
-- Quest data
--------------------------------------------------------------------------------
local name_rules = {
	phonemesVocals = "a, e, i, o, u, y",
	phonemesConsonants = "b, c, ch, ck, cz, d, dh, f, g, gh, h, j, k, kh, l, m, n, p, ph, q, r, rh, s, sh, t, th, ts, tz, v, w, x, z, zh",
	syllablesStart = "Aer, Al, Am, An, Ar, Arm, Arth, B, Bal, Bar, Be, Bel, Ber, Bok, Bor, Bran, Breg, Bren, Brod, Cam, Chal, Cham, Ch, Cuth, Dag, Daim, Dair, Del, Dr, Dur, Duv, Ear, Elen, Er, Erel, Erem, Fal, Ful, Gal, G, Get, Gil, Gor, Grin, Gun, H, Hal, Han, Har, Hath, Hett, Hur, Iss, Khel, K, Kor, Lel, Lor, M, Mal, Man, Mard, N, Ol, Radh, Rag, Relg, Rh, Run, Sam, Tarr, T, Tor, Tul, Tur, Ul, Ulf, Unr, Ur, Urth, Yar, Z, Zan, Zer",
	syllablesMiddle = "de, do, dra, du, duna, ga, go, hara, kaltho, la, latha, le, ma, nari, ra, re, rego, ro, rodda, romi, rui, sa, to, ya, zila",
	syllablesEnd = "bar, bers, blek, chak, chik, dan, dar, das, dig, dil, din, dir, dor, dur, fang, fast, gar, gas, gen, gorn, grim, gund, had, hek, hell, hir, hor, kan, kath, khad, kor, lach, lar, ldil, ldir, leg, len, lin, mas, mnir, ndil, ndur, neg, nik, ntir, rab, rach, rain, rak, ran, rand, rath, rek, rig, rim, rin, rion, sin, sta, stir, sus, tar, thad, thel, tir, von, vor, yon, zor",
	rules = "$s$v$35m$10m$e",
}

local possible_types = {
	{ name="lost warrior",
		types = {
			["technique/combat-training"] = 0.7,
			["technique/combat-techniques-active"] = 0.7,
			["technique/combat-techniques-passive"] = 0.7,
		},
		talents = {
			[Talents.T_RUSH] = 1,
		},
		stats = {
			[Stats.STAT_STR] = 2,
			[Stats.STAT_DEX] = 1,
			[Stats.STAT_CON] = 2,
		},
		actor = {
			type = "humanoid", subtype = "human",
			display = "@", color=colors.UMBER,
			name = "%s, the lost warrior",
			desc = [[He looks tired and wounded.]],
			autolevel = "warrior",
			ai = "summoned", ai_real = "escort_quest", ai_state = { talent_in=4, },
			stats = { str=18, dex=13, mag=5, con=15 },

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
			resolvers.equip{ {type="weapon", subtype="greatsword", autoreq=true} },
			resolvers.talents{ [Talents.T_STUNNING_BLOW]=1, },
			lite = 4,
			rank = 2,
			exp_worth = 0,

			max_life = 50, life_regen = 0,
			life_rating = 5,
			combat_armor = 3, combat_def = 3,
			inc_damage = {all=-50},
		},
	},
}


--------------------------------------------------------------------------------
-- Quest code
--------------------------------------------------------------------------------

-- Random escort
id = "escort-duty-"..game.zone.short_name.."-"..game.level.level

kind = {}

name = ""
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Escort the "..self.kind.name.." to the recall portal on level "..self.level_name.."."
	return table.concat(desc, "\n")
end

local function getPortalSpot(npc, dist, min_dist)
	local astar = Astar.new(game.level.map, npc)
	local poss = {}
	dist = math.floor(dist)
	min_dist = math.floor(min_dist or 0)

	for i = npc.x - dist, npc.x + dist do
		for j = npc.y - dist, npc.y + dist do
			if game.level.map:isBound(i, j) and
			   core.fov.distance(npc.x, npc.y, i, j) <= dist and
			   core.fov.distance(npc.x, npc.y, i, j) >= min_dist and
			   npc:canMove(i, j) then
				poss[#poss+1] = {i,j}
			end
		end
	end

	while #poss > 0 do
		local pos = rng.tableRemove(poss)
		if astar:calc(npc.x, npc.y, pos[1], pos[2]) then
			print("Placing portal at ", pos[1], pos[2])
			return pos[1], pos[2]
		end
	end
end


on_grant = function(self, who)
	self.on_grant = nil

	local ng = NameGenerator.new(name_rules)

	self.kind = rng.table(possible_types)
	self.kind.actor.level_range = {game.level.level, game.level.level}
	self.kind.actor.name = self.kind.actor.name:format(ng:generate())
	self.kind.actor.faction = who.faction
	self.kind.actor.summoner = who
	self.kind.actor.quest_id = self.id
	self.kind.actor.escort_quest = true
	self.kind.actor.on_die = function(self, who)
		game.logPlayer(game.player, "#LIGHT_RED#%s is dead, quest failed!", self.name:capitalize())
		game.player:setQuestStatus(self.quest_id, engine.Quest.FAILED)
	end

	-- Spawn actor
	local x, y = util.findFreeGrid(who.x, who.y, 10, true, {[engine.Map.ACTOR]=true})
	if not x then return end
	local npc = mod.class.NPC.new(self.kind.actor)
	npc:resolve() npc:resolve(nil, true)
	game.zone:addEntity(game.level, npc, "actor", x, y)
	self.kind.actor = nil

	-- Spawn the portal, far enough from the escort
	local gx, gy = getPortalSpot(npc, 150, (game.level.map.w + game.level.map.h) / 2 / 2)
	if not gx then return end
	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="Recall Portal: "..npc.name,
		display='&', color=colors.VIOLET,
		notice = true,
		on_move = function(self, x, y, who)
			if not who.escort_quest then return end
			game.player:setQuestStatus(who.quest_id, engine.Quest.DONE)
			npc:disappear()
			local Chat = require "engine.Chat"
			Chat.new("escort-quest", who, game.player):invoke()
		end,
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.level, g, "terrain", gx, gy)
	npc.escort_target = {x=gx, y=gy}

	-- Setup quest
	self.level_name = game.level.level.." of "..game.zone.name
	self.name = "Escort: "..self.kind.name.." (level "..self.level_name..")"
end
