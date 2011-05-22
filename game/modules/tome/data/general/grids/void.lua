-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

------------------------------------------------------------
-- For inside the sea
------------------------------------------------------------

newEntity{
	define_as = "VOID",
	name = "void",
	display = ' ',
	_noalpha = false,
}

newEntity{
	define_as = "VOID_WALL",
	name = "void",
	display = ' ',
	_noalpha = false,
	always_remember = true,
	does_block_move = true,
	pass_projectile = true,
	air_level = -40,
	is_void = true,
	--- Called when we are targeted by a projectile
	on_projectile_move = function(self, x, y, p)
		p:useEnergy(game.energy_to_act * 5) -- Projectiles move much slower in the void
	end,
}

newEntity{
	define_as = "SPACE_TURBULENCE1",
	name = "space turbulence",
	display = '#', color=colors.YELLOW, image="terrain/temporal_instability_yellow.png",
	always_remember = true,
	does_block_move = true,
	_noalpha = false,
}

newEntity{
	define_as = "SPACE_TURBULENCE2",
	name = "space turbulence",
	display = '#', color=colors.BLUE, image="terrain/temporal_instability_blue.png",
	always_remember = true,
	does_block_move = true,
	_noalpha = false,
}
