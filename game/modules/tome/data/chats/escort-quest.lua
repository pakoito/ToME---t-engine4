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

local reward_types = {
	warrior = {
		types = {
			["technique/combat-training"] = 0.7,
		},
		talents = {
			[Talents.T_WEAPON_COMBAT] = 1,
			[Talents.T_SWORD_MASTERY] = 1,
			[Talents.T_AXE_MASTERY] = 1,
			[Talents.T_MACE_MASTERY] = 1,
			[Talents.T_EXOTIC_WEAPONS_MASTERY] = 1,
		},
		stats = {
			[Stats.STAT_STR] = 1,
			[Stats.STAT_CON] = 1,
		},
	},
	divination = {
		types = {
			["spell/divination"] = 0.7,
		},
		talents = {
			[Talents.T_SENSE] = 1,
			[Talents.T_IDENTIFY] = 1,
			[Talents.T_VISION] = 1,
		},
		stats = {
			[Stats.STAT_MAG] = 1,
			[Stats.STAT_WIL] = 1,
		},
	},
	alchemy = {
		types = {
			["spell/staff-combat"] = 0.7,
			["spell/stone-alchemy"] = 0.7,
		},
		talents = {
			[Talents.T_CHANNEL_STAFF] = 1,
			[Talents.T_STAFF_MASTERY] = 1,
			[Talents.T_STONE_TOUCH] = 1,
			[Talents.T_IMBUE_ITEM] = 1,
		},
		stats = {
			[Stats.STAT_MAG] = 1,
			[Stats.STAT_DEX] = 1,
		},
	},
	survival = {
		types = {
			["cunning/survival"] = 0.7,
		},
		talents = {
			[Talents.T_HEIGHTENED_SENSES] = 1,
			[Talents.T_TRAP_DETECTION] = 1,
			[Talents.T_TRAP_DISARM] = 1,
		},
		stats = {
			[Stats.STAT_DEX] = 1,
			[Stats.STAT_CUN] = 1,
		},
	},
	sun_paladin = {
		types = {
			["divine/chants"] = 0.7,
		},
		talents = {
			[Talents.T_CHANT_OF_FORTITUDE] = 1,
			[Talents.T_CHANT_OF_FORTRESS] = 1,
		},
		stats = {
			[Stats.STAT_STR] = 1,
			[Stats.STAT_MAG] = 1,
		},
	},
	anorithil = {
		types = {
			["divine/hymns"] = 0.7,
		},
		talents = {
			[Talents.T_HYMN_OF_DETECTION] = 1,
			[Talents.T_HYMN_OF_PERSEVERANCE] = 1,
		},
		stats = {
			[Stats.STAT_CUN] = 1,
			[Stats.STAT_MAG] = 1,
		},
	},
	exotic = {
		talents = {
			[Talents.T_DISARM] = 1,
			[Talents.T_WATER_JET] = 1,
			[Talents.T_SPIT_POISON] = 1,
			[Talents.T_MIND_SEAR] = 1,
		},
		stats = {
			[Stats.STAT_STR] = 1,
			[Stats.STAT_DEX] = 1,
			[Stats.STAT_MAG] = 1,
			[Stats.STAT_WIL] = 1,
			[Stats.STAT_CUN] = 1,
			[Stats.STAT_CON] = 1,
		},
	},
}
local reward = reward_types[npc.reward_type]

local function generate_rewards()
	local answers = {}
	if reward.stats then
		for i = 1, #npc.stats_def do if reward.stats[i] then
			local doit = function(npc, player) player.inc_stats[i] = (player.inc_stats[i] or 0) + reward.stats[i]; player.changed = true end
			answers[#answers+1] = {("[Improve %s by +%d]"):format(npc.stats_def[i].name, reward.stats[i]), jump="done", action=doit}
		end end
	end
	if reward.talents then
		for tid, level in pairs(reward.talents) do
			local t = npc:getTalentFromId(tid)
			level = math.min(t.points - npc:getTalentLevelRaw(tid), level)
			if level > 0 then
				local doit = function(npc, player)
					player:learnTalent(tid, true, level)
					if t.hide then player.__show_special_talents[tid] = true end
				end
				answers[#answers+1] = {("[%s talent %s (+%d level(s))]"):format(npc:knowTalent(tid) and "Improve" or "Learn", t.name, level), jump="done", action=doit}
			end
		end
	end
	if reward.types then
		for tt, mastery in pairs(reward.types) do if not npc:knowTalentType(tt) then
			local tt_def = npc:getTalentTypeFrom(tt)
			local doit = function(npc, player)
				player:learnTalentType(tt, false)
				player:setTalentTypeMastery(tt, mastery)
			end
			local cat = tt_def.type:gsub("/.*", "")
			answers[#answers+1] = {("[Allow training of talent category %s (at mastery %0.2f)]"):format(cat:capitalize().." / "..tt_def.name:capitalize(), mastery), jump="done", action=doit}
		end end
	end
	return answers
end

newChat{ id="welcome",
	text = [[Thank you my friend, I do not think I would have survived without you.
Please let me reward you:]],
	answers = generate_rewards(),
}

newChat{ id="done",
	text = [[There you go, farewell!]],
	answers = {
		{"Thank you."},
	},
}

print(plop)

return "welcome"
