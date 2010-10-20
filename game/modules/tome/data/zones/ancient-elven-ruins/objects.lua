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
load("/data/general/objects/mummy-wrappings.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_LONGSWORD",
	define_as = "LONGSWORD_RINGIL", rarity=false, unided_name = "glittering longsword",
	name = "Ringil, the glittering sword of Fingolfin", unique=true,
	desc = [[The sword of Fingolfin, said to have glittered like ice. With it he wounded Morgoth in single combat after the Dagor Bragollach.]],
	require = { stat = { str=35 }, },
	cost = 2000,
	material_level = 5,
	combat = {
		dam = 45,
		apr = 10,
		physcrit = 10,
		dammod = {str=1},
		damrange = 1.4,
	},
	wielder = {
		lite = 1,
		see_invisible = 2,
		resists={[DamageType.COLD] = 25},
		inc_damage = { [DamageType.COLD] = 20 },
		melee_project={[DamageType.ICE] = 15},
	},
	max_power = 18, power_regen = 1,
	use_power = { name = "generate a burst of ice", power = 8,
		use = function(self, who)
			local tg = {type="ball", range=0, radius=4, friendlyfire=false}
			who:project(tg, who.x, who.y, engine.DamageType.ICE, 10 + (who:getMag() + who:getWil()) / 2, {type="freeze"})
			game:playSoundNear(who, "talents/ice")
			game.logSeen(who, "%s invokes the power of Ringil!", who.name:capitalize())
			return true
		end
	},
}

-- Random artifact
newEntity{ base = "BASE_MUMMY_WRAPPING",
	unique = true,
	name = "Bindings of Eternal Night",
	unided_name = "blackened, slithering mummy wrappings",
	desc = [[Woven through with fell magics of undeath, these bindings suck the light and life out of everything they touch. Any who don them will find themselves suspended in a nightmarish limbo between life and death.]],
	color = colors.DARK_GREY,
	level_range = {1, 50},
	rarity = 130,
	cost = 200,
	material_level = 1,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 5, [Stats.STAT_MAG] = 5, },
		resists = {
			[DamageType.BLIGHT] = 30,
			[DamageType.LIGHT] = 30,
			[DamageType.FIRE] = 30,
		},
		on_melee_hit={[DamageType.BLIGHT] = 10},
		life_regen = -0.3,
		lite = -1,
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_SPIT_POISON, level = 2, power = 50 },
}
