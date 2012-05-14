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

name = "T.o.M.E"
long_name = "Tales of Maj'Eyal: Age of Ascendancy"
short_name = "tome"
author = { "DarkGod", "darkgod@te4.org" }
homepage = "http://tome.te4.org/"
version = {3,9,41}
engine = {0,9,41,"te4"}
description = [[
Welcome to Maj'Eyal.

This is the Age of Ascendancy. After over ten thousand years of strife, pain and chaos the known world is at last at relative peace.
The last effects of the #FF0000#Spellblaze#WHITE# have been tamed. The land slowly heals itself and the civilisations rebuild themselves after the Age of Pyre.

It has been one hundred and twenty-two years since the Allied Kingdoms were established under the rule of #14fffc#Toknor#ffffff# and his wife #14fffc#Mirvenia#ffffff#.
Together they ruled the kingdoms with fairness and brought prosperity to both Halflings and Humans.
The King died of old age fourteen years ago, and his son #14fffc#Tolak#ffffff# is now King.

The Elven kingdoms are quiet. The Shaloren Elves in their home of Elvala are trying to make the world forget about their role in the Spellblaze and are living happy lives under the leadership of #14fffc#Aranion Gayaeil#ffffff#.
The Thaloren Elves keep to their ancient tradition of living in the woods, ruled as always by #14fffc#Nessilla Tantaelen#ffffff# the wise.

The Dwarves of the Iron Throne have maintained a careful trade relationship with the Allied Kingdoms for nearly one hundred years, yet not much is known about them, not even their leader's name.

While the people of Maj'Eyal know that the mages helped put an end to the terrors of the Spellblaze, they also did not forget that it was magic that started those events. As such, mages are still shunned from society, if not outright hunted down.
Still, this is a golden age. Civilisations are healing the wounds of thousands of years of conflict, and the Humans and the Halflings have made a lasting peace.

You are an adventurer, set out to discover wonders, explore old places, and venture into the unknown for wealth and glory.
]]
starter = "mod.load"

-- List of additional team files required
teams = {
	{ "#name#-#version#-music.team", "optional", {"/data/music/"} },
	{ "#name#-#version#-gfx-shockbolt.team", "optional", {"/data/gfx/shockbolt/"} },
}

loading_wait_ticks = 260
profile_stats_fields = {"artifacts", "characters", "deaths", "uniques", "scores", "lore", "escorts"}
allow_userchat = true -- We can talk to the online community
no_get_name = true -- Name setting for new characters is done by the module itself

-- Define the fields that are sync'ed online, and how they are sync'ed
profile_defs = {
	allow_build = { {name="index:string:30"}, receive=function(data, save) save[data.name] = true end, export=function(env) for k, _ in pairs(env) do add{name=k} end end },
	lore = { {name="index:string:30"}, receive=function(data, save) save.lore = save.lore or {} save.lore[data.name] = true end, export=function(env) for k, v in pairs(env.lore or {}) do add{name=k} end end },
	escorts = { {fate="index:enum(lost,betrayed,zigur,saved)"}, {nb="number"}, receive=function(data, save) inc_set(save, data.fate, data, "nb") end, export=function(env) for k, v in pairs(env) do add{fate=k, nb=v} end end },
	artifacts = { {cid="index:string:50"}, {name="index:string:40"}, {nb="number"}, receive=function(data, save) save.artifacts = save.artifacts or {} save.artifacts[data.cid] = save.artifacts[data.cid] or {} inc_set(save.artifacts[data.cid], data.name, data, "nb") end, export=function(env) for cid, d in pairs(env.artifacts or {}) do for name, v in pairs(d) do add{cid=cid, name=name, nb=v} end end end },
	characters = { {cid="index:string:50"}, {nb="number"}, receive=function(data, save) save.characters = save.characters or {} inc_set(save.characters, data.cid, data, "nb") end, export=function(env) for k, v in pairs(env.characters or {}) do add{cid=k, nb=v} end end },
	uniques = { {cid="index:string:50"}, {victim="index:string:50"}, {nb="number"}, receive=function(data, save) save.uniques = save.uniques or {} save.uniques[data.cid] = save.uniques[data.cid] or {} inc_set(save.uniques[data.cid], data.victim, data, "nb") end, export=function(env) for cid, d in pairs(env.uniques or {}) do for name, v in pairs(d) do add{cid=cid, victim=name, nb=v} end end end },
	deaths = { {cid="index:string:50"}, {source="index:string:50"}, {nb="number"}, receive=function(data, save) save.sources = save.sources or {} save.sources[data.cid] = save.sources[data.cid] or {} inc_set(save.sources[data.cid], data.source, data, "nb") end, export=function(env) for cid, d in pairs(env.sources or {}) do for name, v in pairs(d) do add{cid=cid, source=name, nb=v} end end end },
	achievements = { {id="index:string:40"}, {gained_on="timestamp"}, {who="string:50"}, {turn="number"}, receive=function(data, save) save[data.id] = {who=data.who, when=data.gained_on, turn=data.turn} end, export=function(env) for id, v in pairs(env) do add{id=id, who=v.who, gained_on=v.when, turn=v.turn} end end },
	donations = { no_sync=true, {last_ask="timestamp"}, receive=function(data, save) save.last_ask = data.last_ask end, export=function(env) add{last_ask=env.last_ask} end },
	scores = {
		nosync=true,
		receive=function(data,save)
			save.sc = save.sc or {}
			save.sc[data.world] = save.sc[data.world] or {}
			save.sc[data.world].alive = save.sc[data.world].alive or {}
			save.sc[data.world].dead = save.sc[data.world].dead or {}
			if data.type == "alive" then
				save.sc[data.world].alive = save.sc[data.world].alive or {}
				save.sc[data.world].alive[data.name] = data
			else
				-- clear any 'alive' entry with this name
				save.sc[data.world].alive[data.name] = nil
				save.sc[data.world].dead = save.sc[data.world].dead or {}
				save.sc[data.world].dead[#save.sc[data.world].dead+1] = data
			end
		end
	},
}

-- Formatter for scores
score_formatters = {
	["Maj'Eyal"] = {
		alive="#LIGHT_GREEN#{score} : #BLUE#{name}#LAST# the #LIGHT_RED#level {level} {subrace} {subclass}#LAST# is still alive and well on #GREEN#{where}#LAST##WHITE#",
		dead="{score} : #BLUE#{name}#LAST# the #LIGHT_RED#level {level} {subrace} {subclass}#LAST# died on #GREEN#{where}#LAST#, killed by a #RED#{killedby}#LAST#"
	},
	["Infinite"] = {
		alive="#LIGHT_GREEN#{score} : #BLUE#{name}#LAST# the #LIGHT_RED#level {level} {subrace} {subclass}#LAST# is still alive and well on level #GREEN#{dlvl}#LAST##WHITE#",
		dead="{score} : #BLUE#{name}#LAST# the #LIGHT_RED#level {level} {subrace} {subclass}#LAST# died on level #GREEN#{dlvl}#LAST#, killed by a #RED#{killedby}#LAST#"
	},
	["Arena"] = {
		alive="#LIGHT_GREEN#{score} : #BLUE#{name}#LAST# the #LIGHT_RED#level {level} {subrace} {subclass}#LAST# is still alive and well on wave #GREEN#{dlvl}#LAST##WHITE#",
		dead="{score} : #BLUE#{name}#LAST# the #LIGHT_RED#level {level} {subrace} {subclass}#LAST# died on wave #GREEN#{dlvl}#LAST#, killed by a #RED#{killedby}#LAST#"
	}
}

