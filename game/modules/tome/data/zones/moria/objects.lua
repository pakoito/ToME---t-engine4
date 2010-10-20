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

newEntity{ base = "BASE_SCROLL", define_as = "NOTE_FROM_MINAS_TIRITH",
	name = "Sealed Scroll of Minas Tirith", identified=true, unique=true,
	fire_proof = true,

	use_simple = { name="open the seal and read the message", use = function(self, who)
		game:registerDialog(require("engine.dialogs.ShowText").new(self:getName{do_color=true}, "message-minas-tirith", {playername=who.name}, game.w * 0.6))
	end}
}

newEntity{ base = "BASE_WARAXE",
	define_as = "MALEDICTION", rarity=false,
	unided_name = "pestilent waraxe",
	name = "Malediction", unique=true,
	desc = [[The land withers and crumbles wherever this cursed axe rests.]],
	require = { stat = { str=55 }, },
	cost = 375,
	combat = {
		dam = 55,
		apr = 15,
		physcrit = 10,
		dammod = {str=1},
		damrange = 1.2,
	},
	wielder = {
		life_regen = -0.3,
		inc_damage = { [DamageType.BLIGHT] = 20 },
		melee_project={[DamageType.BLIGHT] = 20},
	},
}

newEntity{ base = "BASE_GEM",
	define_as = "RESONATING_DIAMOND_WEST",
	name = "Resonating Diamond", color=colors.VIOLET, quest=true, unique="Resonating Diamond West", identified=true,

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}

newEntity{ define_as = "ATHAME_WEST",
	quest=true, unique="Blood-Runed Athame West", identified=true,
	type = "misc", subtype="misc",
	unided_name = "athame",
	name = "Blood-Runed Athame",
	level_range = {50, 50},
	display = "|", color=colors.VIOLET,
	encumber = 1,
	desc = [[An athame, covered in blood runes. It radiates power.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}
