-- ToME - Tales of Maj'Eyal
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
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_LORE",
	define_as = "ARENA_SCORING",
	name = "Arena for dummies", lore="arena-scoring",
	desc = [[A note explaining the arena's scoring rules. Someone must have dropped it.]],
	rarity = false,
	is_magic_device = false,
	encumberance = 0,
}


-- Id stuff
newEntity{ define_as = "ORB_KNOWLEDGE",
	unique = true, quest=true,
	type = "jewelry", subtype="orb",
	unided_name = "orb", no_unique_lore = true,
	name = "Orb of Knowledge", identified = true,
	display = "*", color=colors.VIOLET, image = "object/ruby.png",
	encumber = 1,
	desc = [[This orb was given to you by Elisa the halfling scryer, it will automatically identify normal and rare items for you and can be activated to identify all others.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who)
			for inven_id, inven in pairs(who.inven) do
				for item, o in ipairs(inven) do
					if not o:isIdentified() then
						o:identify(true)
						game.logPlayer(who, "You have: %s", o:getName{do_colour=true})
					end
				end
			end
		end
	},

	carrier = {
		auto_id_mundane = 1,
	},
}

newEntity{
	define_as = "ARENA_BOOTS_DISE",
	slot = "FEET",
	type = "armor", subtype="feet",
	add_name = " (#ARMOR#)",
	display = "]", color=colors.UMBER, image = resolvers.image_material("boots", "leather"),
	encumber = 2,
	desc = [[A pair of boots made of leather. They seem to be of exceptional quality.]],
	name = "a pair of leather boots of disengagement", suffix=true, instant_resolve=true,
	egoed = true,
	greater_ego = true,
	identified = true,
	rarity = false,
	cost = 0,
	material_level = 1,
	wielder = {
		combat_armor = 2,
		fatigue = 1,
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_DISENGAGE, level = 2, power = 10 },
}

newEntity{
	define_as = "ARENA_BOOTS_PHAS",
	slot = "FEET",
	type = "armor", subtype="feet",
	add_name = " (#ARMOR#)",
	display = "]", color=colors.UMBER, image = resolvers.image_material("boots", "leather"),
	encumber = 2,
	desc = [[A pair of boots made of leather. They seem to be of exceptional quality.]],
	name = "a pair of leather boots of phasing", suffix=true, instant_resolve=true,
	egoed = true,
	greater_ego = true,
	identified = true,
	cost = 0,
	rarity = false,
	material_level = 1,
	wielder = {
		combat_armor = 2,
		fatigue = 1,
	},
	max_power = 25, power_regen = 1,
	use_power = { name = "blink to a nearby random location", power = 15, use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 10 + who:getMag(5))
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game:playSoundNear(who, "talents/teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}
}

newEntity{
	define_as = "ARENA_BOOTS_RUSH",
	slot = "FEET",
	type = "armor", subtype="feet",
	add_name = " (#ARMOR#)",
	display = "]", color=colors.UMBER, image = resolvers.image_material("boots", "leather"),
	encumber = 2,
	desc = [[A pair of boots made of leather. They seem to be of exceptional quality.]],
	name = "a pair of leather boots of rushing", suffix=true, instant_resolve=true,
	egoed = true,
	rarity = false,
	greater_ego = true,
	identified = true,
	cost = 0,
	material_level = 1,
	wielder = {
		combat_armor = 2,
		fatigue = 1,
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_RUSH, level = 2, power = 10 },
}

newEntity{
	define_as = "ARENA_DEBUG_CANNON",
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="cannon",
	name = "debug cannon",
	display = "}", color=colors.BLUE,
	encumber = 4,
	egoed = true,
	unique = true,
	greater_ego = true,
	identified = true,
	max_power = 20, power_regen = 1,
	cost = 0,
	material_level = 1,
	rarity = 9999999999999,
	metallic = true,
	twohanded = true,
	combat = { talented = "bow", sound = "actions/arrow", sound_miss = "actions/arrow",},
	archery = "bow",
	combat = {
		range = 16,
		physspeed = 1,
		talented = "mace",
		dam = resolvers.rngavg(22,30),
		apr = 2,
		physcrit = 1,
		dammod = {str=1.2},
		damrange = 1.5,
		sound = "actions/melee",
		sound_miss = "actions/melee_miss",
	},
	basic_ammo = {
		dam = 3000,
		apr = 5000,
		physcrit = 10,
		dammod = {wil = 2},
	},
	wielder = {
		ranged_project={
			[DamageType.LIGHTNING] = 3000,
			[DamageType.LIGHT] = 3000,
		},
		fatigue = 1,
	},
	desc = [[A powerful weapon from another world. It operates on a graviton engine.]],
	use_talent = { id = Talents.T_GRAVITY_SPIKE, level = 6, power = 10 },
}

newEntity{
	define_as = "ARENA_DEBUG_ARMOR",
	slot = "BODY",
	type = "armor", subtype="mechanic",
	add_name = " (#ARMOR#)",
	display = "[", color=colors.SLATE, image = resolvers.image_material("plate", "metal"),
	unique = true,
	name = "Full frame",
	unided_name = "Strange armor",
	desc = [[A powered armor from another world. Worn by fighters facing unstable dimensional fields.]],
	color = colors.BLACK,
	metallic = true,
	rarity = 99999999999,
	cost = 250,
	material_level = 3,
	max_power = 20, power_regen = 1,
	wielder = {
		combat_armor = 120,
		combat_def = 120,
		combat_def_ranged = 120,
		max_encumber = 300,
		life_regen = 1000,
		stamina_regen = 20,
		fatigue = 0,
		max_stamina = 500,
		max_life = 3000,
		knockback_immune = 1,
		stun_immune = 1,
		size_category = 2,
	},
	use_talent = { id = Talents.T_TWILIGHT_SURGE, level = 99, power = 10 },
}


newEntity{
	define_as = "ARENA_BOOTS_LSPEED",
	slot = "FEET",
	type = "armor", subtype="feet",
	add_name = " (#ARMOR#)",
	display = "]", color=colors.UMBER, image = resolvers.image_material("boots", "leather"),
	encumber = 2,
	desc = [[A pair of boots made of leather. They seem to be of exceptional quality.]],
	name = "a pair of leather boots of lightning speed", suffix=true, instant_resolve=true,
	egoed = true,
	greater_ego = true,
	identified = true,
	rarity = false,
	cost = 0,
	material_level = 1,
	wielder = {
		combat_armor = 2,
		fatigue = 1,
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_LIGHTNING_SPEED, level = 2, power = 10 },
}

newEntity{
	define_as = "ARENA_BOW",
	base = "BASE_LONGBOW",
	name = "elm longbow of steady shot",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	rarity = false,
	egoed = true,
	greater_ego = true,
	identified = true,
	cost = 0,
	material_level = 1,
	use_talent = { id = Talents.T_STEADY_SHOT, level = 2, power = 10 },
	max_power = 15, power_regen = 1,
	combat = {
		range = 8,
		physspeed = 0.8,
	},
	basic_ammo = {
		dam = 12,
		apr = 5,
		physcrit = 1,
		dammod = {dex=0.7, str=0.5},
	},
}

newEntity{
	define_as = "ARENA_SLING",
	base = "BASE_SLING",
	name = "rough leather sling of flare",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	rarity = false,
	egoed = true,
	greater_ego = true,
	identified = true,
	cost = 0,
	material_level = 1,
	use_talent = { id = Talents.T_FLARE, level = 2, power = 15 },
	max_power = 15, power_regen = 1,
	combat = {
		range = 8,
		physspeed = 0.8,
	},
	basic_ammo = {
		dam = 12,
		apr = 1,
		physcrit = 4,
		dammod = {dex=0.7, cun=0.5},
	},
}
