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

load("/data/general/objects/objects.lua")

local Stats = require"engine.interface.ActorStats"


newEntity{ base = "BASE_LEATHER_CAP",
	define_as = "CROWN_ELEMENTS", rarity=false,
	name = "Crown of the Elements", unique=true,
	unided_name = "jeweled crown", color=colors.DARK_GREY,
	desc = [[Jeweled crown]],
	cost = 500,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 5, [Stats.STAT_WIL] = 3, },
		resists={
			[DamageType.FIRE] = 15,
			[DamageType.COLD] = 15,
			[DamageType.ACID] = 15,
			[DamageType.LIGHTNING] = 15,
		},
		melee_project={
			[DamageType.FIRE] = 10,
			[DamageType.COLD] = 10,
			[DamageType.ACID] = 10,
			[DamageType.LIGHTNING] = 10,
		},
		see_invisible = 15,
		combat_armor = 5,
		fatigue = 5,
	},
}

-- Artifact, randomly dropped in Vor Pride, and only there
newEntity{ base = "BASE_SCROLL", subtype="tome",
	name = "Tome of Wildfire", unided_name = "burning book", unique=true,
	color = colors.VIOLET,
	level_range = {35, 45},
	rarity = 200,
	cost = 100,

	use_simple = { name="learn the ancient secrets", use = function(self, who)
		if not who:knowTalent(who.T_FLAME) then
			who:learnTalent(who.T_FLAME, true, 3)
			game.logPlayer(who, "#00FFFF#You read the tome and learn about ancient forgotten fire magic!")
		else
			who.talents_types_mastery["spell/fire"] = (who.talents_types_mastery["spell/fire"] or 1) + 0.1
			who.talents_types_mastery["spell/wildfire"] = (who.talents_types_mastery["spell/wildfire"] or 1) + 0.1
			game.logPlayer(who, "#00FFFF#You read the tome and perfect your mastery of fire magic!")
		end

--		game:setAllowedBuild("mage_pyromancer", true)

		return "destroy", true
	end}
}

-- Artifact, randomly dropped in Vor Pride, and only there
newEntity{ base = "BASE_SCROLL", subtype="tome",
	name = "Tome of Uttercold", unided_name = "frozen book", unique=true,
	color = colors.VIOLET,
	level_range = {35, 45},
	rarity = 200,
	cost = 100,

	use_simple = { name="learn the ancient secrets", use = function(self, who)
		if not who:knowTalent(who.T_ICE_STORM) then
			who:learnTalent(who.T_ICE_STORM, true, 3)
			game.logPlayer(who, "#00FFFF#You read the tome and learn about ancient forgotten ice magic!")
		else
			who.talents_types_mastery["spell/water"] = (who.talents_types_mastery["spell/water"] or 1) + 0.1
			who.talents_types_mastery["spell/ice"] = (who.talents_types_mastery["spell/ice"] or 1) + 0.1
			game.logPlayer(who, "#00FFFF#You read the tome and perfect your mastery of ice magic!")
		end

--		game:setAllowedBuild("mage_cryomancer", true)

		return "destroy", true
	end}
}
