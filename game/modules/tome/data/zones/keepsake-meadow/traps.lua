-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	type = "event",	subtype = "event", id_by_type=false, unided_name = "trap",
	display = ' ', color=colors.WHITE,
	name = "creeping darkness",
	detect_power = 99999, disarm_power = 99999,
	rarity = 3, level_range = {1, nil},
	pressure_trap = false,
	message = "A creeping darkness spreads through the air!",
	triggered = function(self, x, y, who)
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			name = "creeping darkness trap",
			type = "trap", subtype = "psionic",
			combatMindpower = function(self) return self.level end,
			getTarget = function(self) return self.x, self.y end,
			x = x, y = y,
			faction = self.faction,
		}
		m:forceUseTalent(m.T_CREEPING_DARKNESS, {ignore_cd=true, ignore_energy=true, force_level=3, ignore_ressources=true, silent=true})
		return false, true -- not revealed, deleted
	end,
}

newEntity{
	type = "event",	subtype = "event", id_by_type=false, unided_name = "trap",
	display = ' ', color=colors.WHITE,
	name = "summon shadow",
	detect_power = 99999, disarm_power = 99999,
	rarity = 3, level_range = {1, nil},
	pressure_trap = false,
	message = "A shadow traces across the floor.",
	triggered = function(self, x, y, who)
		if (game.level.remaining_summons or 5) <= 0 then return false end
	
		local x, y = util.findFreeGrid(sx, sy, 5, true, {[game.level.map.ACTOR]=true})
		if not x then return false end

		local name
		local which = rng.range(1, 3)
		if which == 1 then
			name = "SHADOW_CLAW"
		elseif which == 2 then
			name = "SHADOW_CASTER"
		else
			name = "SHADOW_STALKER"
		end
		local m = game.zone:makeEntityByName(self.level, "actor", name)
		if m then
			game.level.remaining_summons = (game.level.remaining_summons or 5) - 1
			game.zone:addEntity(game.level, m, "actor", x, y)
		end
		
		return false, true -- not revealed, deleted
	end,
}