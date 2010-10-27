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

load("/data/general/objects/objects-far-east.lua")

newEntity{ base = "BASE_WHIP",
	define_as = "WHIP_GOTHMOG",
	unided_name = "fiery whip",
	name = "Whip of Gothmog, High Captain of the Balrogs", color=colors.PURPLE, unique = true,
	desc = [[With this unbearably bright whip of flame, the Balrog Gothmog has become known for never having lost in combat.
But nothing lasts forever and he was finally defeated by Echtelion in the First Age. His whip must have been taken by the other balrogs from his corpse.]],
	require = { stat = { dex=48 }, },
	cost = 250,
	material_level = 5,
	combat = {
		dam = resolvers.rngavg(40,45),
		apr = 0,
		physcrit = 9,
		dammod = {dex=1},
		damtype = DamageType.FIREKNOCKBACK,
	},
	wielder = {
		esp = {["demon/minor"]=1, ["demon/major"]=1},
		see_invisible = 2,
	},
	carrier = {
		inc_damage={
			[DamageType.BLIGHT] = 8,
		},
	},
}
