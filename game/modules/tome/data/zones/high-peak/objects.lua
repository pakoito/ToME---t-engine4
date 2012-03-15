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

load("/data/general/objects/objects-far-east.lua")
load("/data/general/objects/lore/sunwall.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- The staff of absorption, the reason the game exists!
newEntity{ define_as = "STAFF_ABSORPTION_AWAKENED", base="BASE_STAFF",
	power_source = {unknown=true},
	unique = true, godslayer=true, flavor_name = "magestaff",
	name = "Awakened Staff of Absorption", identified=true, force_lore_artifact=true,
	display = "\\", color=colors.VIOLET, image = "object/artifact/staff_absorption.png",
	encumber = 7,
	desc = [[Carved with runes of power, this staff seems to have been made long ago. Yet it bears no signs of tarnishment.
Light around it seems to dim and you can feel its tremendous power simply by touching it.
The Sorcerers seem to have awakened its power.
#{italic}#"And lo they came to Amakthel himself, and thousands were killed in the assault on his throne, and three of the Godslayers were broken beneath his feet. But Falion with his dying breath pierced the great god on his knee with the icy sword Arkil, and seeing his opportunity Caldizar, leader of the Godslayers, advanced with the Staff of Absorption and struck a terrifying blow against Amakthel. So fell the greatest of the gods by the hands of his own children, and his face was forced into the dust."#{normal}#]],

	modes = {"fire", "cold", "lightning", "arcane"},
	require = { stat = { mag=60 }, },
	combat = {
		dam = 60,
		apr = 60,
		atk = 30,
		dammod = {mag=1.3},
		damtype = DamageType.ARCANE,
		is_greater = true,
		of_breaching = true,
	--	of_retribution = true,
	},
	wielder = {
		combat_spellpower = 48,
		combat_spellcrit = 15,
		max_mana = 100,
		max_positive = 50,
		max_negative = 50,
		inc_stats = { [Stats.STAT_MAG] = 10, [Stats.STAT_WIL] = 10 },
		inc_damage={
			[DamageType.FIRE] = 60,
			[DamageType.LIGHTNING] = 60,
			[DamageType.COLD] = 60,
			[DamageType.ARCANE] = 60,
		},
		resists_pen={
			[DamageType.FIRE] = 30,
			[DamageType.LIGHTNING] = 30,
			[DamageType.COLD] = 30,
			[DamageType.ARCANE] = 30,
		},
		--[[elemental_retribution = {
			[DamageType.FIRE] = 1,
			[DamageType.LIGHTNING] = 1,
			[DamageType.COLD] = 1,
			[DamageType.ARCANE] = 1,
		},]]
		learn_talent = { [Talents.T_COMMAND_STAFF] = 1, }, --[Talents.T_ELEMENTAL_RETRIBUTION] = 5,},
		speaks_shertul = 1,
	},

	-- This is not a simple artifact, it is a godslayer, show off!
	resolvers.generic(function(e) e:addParticles(engine.Particles.new("godslayer_swirl", 1, {})) end),
	moddable_tile_particle = {"godslayer_swirl", {size=64, x=-16}},

	max_power = 200, power_regen = 1,
	use_power = { name = "absorb energies", power = 200,
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
			who:setEffect(who.EFF_POWER_OVERLOAD, 7, {power=30})
			target:takeHit(target.life * 0.3, who)
			return {id=true, used=true}
		end
	},
}

newEntity{ define_as = "PEARL_LIFE_DEATH",
	power_source = {nature=true},
	unique = true,
	type = "gem", subtype="white",
	unided_name = "shining pearl",
	name = "Pearl of Life and Death",
	display = "*", color=colors.WHITE, image = "object/artifact/pearl_of_life.png",
	encumber = 2,
	desc = [[A pearl, three times a normal sized one, that glitters in infinite colours, with slight patterns ever shifting away.]],

	carrier = {
		lite = 1,
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 5, [Stats.STAT_CON] = 5, [Stats.STAT_LCK] = 10 },
		inc_damage = {all = 7},
		resists = {all = 7},
		stun_immune = 1,
	},
}
