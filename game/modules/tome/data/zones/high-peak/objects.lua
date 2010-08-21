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

local Stats = require "engine.interface.ActorStats"

-- The staff of absorption, the reason the game exists!
newEntity{ define_as = "STAFF_ABSORPTION_AWAKENED", base="BASE_STAFF",
	unique = true,
	name = "Awakened Staff of Absorption", identified=true,
	display = "\\", color=colors.VIOLET, image = "object/staff_dragonbone.png",
	encumber = 7,
	desc = [[Carved with runes of power, this staff seems to have been made long ago. Yet it bears no signs of tarnishment.
Light around it seems to dim and you can feel its tremendous power simply by touching it.
The Istari seem to have awakened its power.]],

	require = { stat = { mag=60 }, },
	combat = {
		dam = 50,
		apr = 4,
		atk = 20,
		dammod = {mag=1},
	},
	wielder = {
		combat_spellpower = 34,
		combat_spellcrit = 10,
		max_mana = 50,
		max_positive = 50,
		max_negative = 50,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_WIL] = 6 },
	},

	max_power = 1000, power_regen = 1,
	use_power = { name = "absorb energies", power = 1000,
		use = function(self, who)
			local tg = {type="hit", range=8}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			local _ _, x, y = who:canProject(tg, x, y)
			local target = game.level.map(x, y, engine.Map.ACTOR)
			if not target then return nil end
			if target.staff_drained then
				game.logPlayer(who, "This foe has already been drained.")
			end

			game.logPlayer(who, "You brandish the staff, draining your foe.")
			who:setEffect(who.EFF_POWER_OVERLOAD, 7, {power=20})
			target:takeHit(target.life * 0.2, who)
		end
	},
}
