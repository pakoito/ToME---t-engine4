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

newEntity{
	name = "quick ", prefix=true,
	keywords = {quick=true},
	level_range = {1, 50},
	rarity = 15,
	cost = 5,
	resolvers.genericlast(function(e)
		if not e.use_power or not e.charm_power then return end
		e.use_power.power = math.ceil(e.use_power.power * rng.float(0.6, 0.8))
		e.charm_power = math.ceil(e.charm_power * rng.float(0.4, 0.7))
	end),
}

newEntity{
	name = "supercharded ", prefix=true,
	keywords = {['super.c']=true},
	level_range = {1, 50},
	rarity = 15,
	cost = 5,
	resolvers.genericlast(function(e)
		if not e.use_power or not e.charm_power then return end
		e.use_power.power = math.ceil(e.use_power.power * rng.float(1.2, 1.5))
		e.charm_power = math.ceil(e.charm_power * rng.float(1.3, 1.5))
	end),
}
