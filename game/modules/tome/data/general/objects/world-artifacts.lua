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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- This file describes artifacts not bound to a special location, they can be found anywhere
newEntity{ base = "BASE_STAFF",
	unique = true,
	name = "Staff of Destruction",
	unided_name = "ash staff",
	level_range = {20, 25},
	color=colors.VIOLET,
	rarity = 100,
	desc = [[This unique looking staff is carved with runes of destruction.]],
	cost = 500,
	material_level = 3,

	require = { stat = { mag=24 }, },
	combat = {
		dam = 15,
		apr = 4,
		dammod = {mag=1.5},
	},
	wielder = {
		combat_spellpower = 10,
		combat_spellcrit = 15,
		inc_damage={
			[DamageType.FIRE] = resolvers.mbonus(25, 8),
			[DamageType.LIGHTNING] = resolvers.mbonus(25, 8),
		},
	},
}

newEntity{ base = "BASE_RING",
	unique = true,
	name = "Ring of Ulmo", color = colors.LIGHT_BLUE,
	unided_name = "sea-blue ring",
	desc = [[This azure ring seems to be always moist to the touch.]],
	level_range = {10, 20},
	rarity = 150,
	cost = 500,
	material_level = 2,

	max_power = 60, power_regen = 1,
	use_power = { name = "summon a tidal wave", power = 60,
		use = function(self, who)
			local duration = 7
			local radius = 1
			local dam = 20
			-- Add a lasting map effect
			game.level.map:addEffect(who,
				who.x, who.y, duration,
				engine.DamageType.WAVE, dam,
				radius,
				5, nil,
				engine.Entity.new{alpha=100, display='', color_br=30, color_bg=60, color_bb=200},
				function(e)
					e.radius = e.radius + 1
				end,
				false
			)
			game.logSeen(who, "%s brandishes the %s, calling forth the might of the oceans!", who.name:capitalize(), self:getName())
		end
	},
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CON] = 3 },
		max_mana = 20,
		max_stamina = 20,
		resists = {
			[DamageType.COLD] = 25,
			[DamageType.NATURE] = 10,
		},
	},
}

newEntity{ base = "BASE_RING",
	unique = true,
	name = "Ring of Mandos", color = colors.DARK_GREY,
	unided_name = "dull black ring",
	desc = [[This dull black ring is completely featureless.]],
	level_range = {35, 42},
	rarity = 250,
	cost = 500,
	material_level = 4,

	wielder = {
		inc_stats = { [Stats.STAT_LCK] = 10, },
	},
	one_shot_life_saving = true,
}

newEntity{ base = "BASE_RING",
	unique = true,
	name = "Elemental Fury", color = colors.PURPLE,
	unided_name = "multi-hued ring",
	desc = [[This ring shines with many colors.]],
	level_range = {15, 30},
	rarity = 200,
	cost = 500,
	material_level = 3,

	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 3, },
		inc_damage = {
			[DamageType.ARCANE]    = 10,
			[DamageType.FIRE]      = 10,
			[DamageType.COLD]      = 10,
			[DamageType.ACID]      = 10,
			[DamageType.LIGHTNING] = 10,
		},
	},
}

newEntity{ base = "BASE_LITE", define_as = "PHIAL_GALADRIEL",
	unique = true,
	name = "Phial of Galadriel",
	unided_name = "glowing phial",
	level_range = {1, 10},
	color=colors.YELLOW,
	encumber = 1,
	rarity = 100,
	desc = [[A small crystal phial, with the light of Earendil's Star contained inside. Its light is imperishable, and near it darkness cannot endure.]],
	cost = 200,

	max_power = 15, power_regen = 1,
	use_power = { name = "call light", power = 10,
		use = function(self, who)
			who:project({type="ball", range=0, friendlyfire=false, radius=20}, who.x, who.y, engine.DamageType.LITE, 100)
			game.logSeen(who, "%s brandishes the %s and banishes all shadows!", who.name:capitalize(), self:getName())
		end
	},
	wielder = {
		lite = 4,
	},
}

newEntity{ base = "BASE_LITE",
	unique = true,
	name = "Arkenstone of Thrain",
	unided_name = "great jewel",
	level_range = {20, 30},
	color=colors.YELLOW,
	encumber = 1,
	rarity = 250,
	desc = [[A great globe seemingly filled with moonlight, the famed Heart of the Mountain, which splinters the light that falls upon it into a thousand glowing shards.]],
	cost = 400,

	max_power = 150, power_regen = 1,
	use_power = { name = "map surroundings", power = 100,
		use = function(self, who)
			who:magicMap(20)
			game.logSeen(who, "%s brandishes the %s which glitters in all directions!", who.name:capitalize(), self:getName())
		end
	},
	wielder = {
		lite = 5,
	},
}

newEntity{
	unique = true,
	type = "potion", subtype="potion",
	name = "Ever-Refilling Potion of Healing",
	unided_name = "strange potion",
	level_range = {35, 40},
	display = '!', color=colors.VIOLET, image="object/potion-0x3-violet.png",
	encumber = 0.4,
	rarity = 150,
	desc = [[Bottle containing healing magic. But the more you drink from it, the more it refills!]],
	cost = 80,

	max_power = 100, power_regen = 1,
	use_power = { name = "heal", power = 80,
		use = function(self, who)
			who:heal(150 + who:getMag())
			game.logSeen(who, "%s quaffs an %s!", who.name:capitalize(), self:getName())
		end
	},
}

newEntity{
	unique = true,
	type = "potion", subtype="potion",
	name = "Ever-Refilling Potion of Mana",
	unided_name = "strange potion",
	level_range = {35, 40},
	display = '!', color=colors.VIOLET, image="object/potion-0x3-violet.png",
	encumber = 0.4,
	rarity = 150,
	desc = [[Bottle containing raw magic. But the more you drink from it, the more it refills!]],
	cost = 80,

	max_power = 100, power_regen = 1,
	use_power = { name = "restore mana", power = 80,
		use = function(self, who)
			who:incMana(150 + who:getMag())
			game.logSeen(who, "%s quaffs an %s!", who.name:capitalize(), self:getName())
		end
	},
}

newEntity{
	unique = true,
	type = "potion", subtype="potion",
	name = "Blood of Life",
	unided_name = "bloody phial",
	level_range = {1, 50},
	display = '!', color=colors.VIOLET, image="object/potion-0x3-violet.png",
	encumber = 0.4,
	rarity = 350,
	desc = [[The Blood of Life! It can let a living being resurrect in case of an untimely demise. But only once!]],
	cost = 1000,

	use_simple = { name = "quaff the Blood of Life", use = function(self, who)
		game.logSeen(who, "%s quaffs the %s!", who.name:capitalize(), self:getName())
		if not who:attr("undead") then
			who.blood_life = true
			game.logPlayer(who, "#LIGHT_RED#You feel the Blood of Life rushing through your veins.")
		else
			game.logPlayer(who, "The Blood of Life seems to have no effect on you.")
		end
		return "destroy", true
	end},
}

newEntity{ base = "BASE_LONGBOW",
	name = "Gondor-Tree Longbow", unided_name = "glowing elven-wood longbow", unique=true,
	desc = [[In the aftermath of the wars against Sauron, the strength of the Trees of Gondor faded and one of the trees died despite the efforts of the men of the city to save it. Its wood was fashioned into a bow to be wielded against the darkness that poisoned Gondor's tree.]],
	level_range = {40, 50},
	rarity = 200,
	require = { stat = { dex=36 }, },
	cost = 800,
	material_level = 5,
	combat = {
		range = 18,
		physspeed = 0.7,
		apr = 12,
	},
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = 12, },
		lite = 1,
		inc_stats = { [Stats.STAT_DEX] = 5, [Stats.STAT_WIL] = 4,  },
		ranged_project={[DamageType.LIGHT] = 30},
	},
}

newEntity{ base = "BASE_SLING",
	unique = true,
	name = "Gift to the Shire",
	unided_name = "well-made sling",
	desc = [[A sling with an inscription on its handle 'Given in honour of the Friendship between the King of Men and the Mayor of the Shire, and token of the alliance shared thencefrom.']],
	level_range = {15, 25},
	rarity = 200,
	require = { stat = { dex=26 }, },
	cost = 350,
	material_level = 3,
	combat = {
		range = 18,
		physspeed = 0.7,
	},
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = 4, [Stats.STAT_CUN] = 3,  },
		inc_damage={ [DamageType.PHYSICAL] = 15 },
		talent_cd_reduction={[Talents.T_STEADY_SHOT]=1, [Talents.T_EYE_SHOT]=2},
	},
}

newEntity{ base = "BASE_LONGSWORD",
	unique = true,
	name = "Glamdring, the Long Sword 'Foe-Hammer'",
	unided_name = "glowing long sword",
	level_range = {40, 45},
	color=colors.AQUAMARINE,
	rarity = 250,
	desc = [[This fiery, shining blade earned its sobriquet "Foe-Hammer" from dying orcs who dared to come near hidden Gondolin. In the past it was used by both Turgon and Gandalf.]],
	cost = 1000,

	require = { stat = { mag=28, str=28, dex=28 }, },
	material_level = 5,
	combat = {
		dam = 50,
		apr = 2,
		physcrit = 5,
		dammod = {str=1},
	},
	wielder = {
		lite = 1,
		combat_spellpower = 20,
		combat_spellcrit = 9,
		inc_damage={
			[DamageType.PHYSICAL] = 18,
			[DamageType.FIRE] = 18,
			[DamageType.LIGHT] = 18,
		},
		inc_stats = { [Stats.STAT_MAG] = 4, [Stats.STAT_STR] = 4, },
		esp = {["humanoid/orc"]=1},
	},
}

newEntity{ base = "BASE_LEATHER_BOOT",
	unique = true,
	name = "Boots of Tom Bombadil",
	unided_name = "pair of yellow boots",
	desc = [[Old Tom Bombadil is a merry fellow.
Bright blue his jacket is, and his boots are yellow.]],
	color = colors.YELLOW,
	level_range = {1, 20},
	rarity = 200,
	cost = 100,
	material_level = 2,
	wielder = {
		combat_armor = 1,
		combat_def = 2,
		fatigue = 2,
		talents_types_mastery = { ["cunning/survival"] = 0.2 },
		inc_stats = { [Stats.STAT_CUN] = 3, },
	},

	max_power = 50, power_regen = 1,
	use_power = { name = "speed boost", power = 50,
		use = function(self, who)
			who:setEffect(who.EFF_SPEED, 8, {power=0.20 + who:getCun() / 80})
			game.logSeen(who, "%s speeds up!", who.name:capitalize())
		end
	},
}

newEntity{ base = "BASE_SHIELD",
	unique = true,
	name = "Dragon Shield of Smaug",
	unided_name = "dragon shield",
	desc = [[This large shield was made using scales of the dragon Smaug, killed in the Third Age by Bard I of Esgaroth.]],
	color = colors.LIGHT_RED,
	metallic = false,
	level_range = {27, 35},
	rarity = 300,
	require = { stat = { str=28 }, },
	cost = 350,
	material_level = 5,
	special_combat = {
		dam = 58,
		physcrit = 4.5,
		dammod = {str=1},
		damtype = DamageType.FIRE,
	},
	wielder = {
		resists={[DamageType.FIRE] = 35},
		on_melee_hit={[DamageType.FIRE] = 17},
		combat_armor = 4,
		combat_def = 16,
		combat_def_ranged = 15,
		fatigue = 20,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	unique = true,
	name = "Leather Armour of Eowen Nazgul-bane",
	unided_name = "blackened leather armour",
	level_range = {25, 40},
	rarity = 270,
	cost = 200,
	require = { stat = { str=22 }, },
	material_level = 4,
	wielder = {
		combat_def = 6,
		combat_armor = 7,
		fatigue = 7,
		stun_immune = 0.7,
		knockback_immune = 0.7,
		inc_stats = { [Stats.STAT_WIL] = 5, [Stats.STAT_CON] = 4, },
		resists={[DamageType.BLIGHT] = 35},
	},
}

newEntity{
	unique = true,
	type = "misc", subtype="egg",
	unided_name = "dark egg",
	name = "Mummified Egg-sac of Ungoliant",
	level_range = {20, 35},
	rarity = 190,
	display = "*", color=colors.DARK_GREY, image = "object/bloodstone.png",
	encumber = 2,
	desc = [[By what strange fate this survived, you cannot imagine. Dry and dusty to the touch, it still seems to retain some of its foul mother's unending hunger.]],

	carrier = {
		lite = -2,
	},
	max_power = 100, power_regen = 1,
	use_power = { name = "summon spiders", power = 80, use = function(self, who)
		local NPC = require "mod.class.NPC"
		local list = NPC:loadList("/data/general/npcs/spider.lua")

		for i = 1, 2 do
			-- Find space
			local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			if not x then break end

			local e
			repeat e = rng.tableRemove(list)
			until not e.unique and e.rarity

			local spider = game.zone:finishEntity(game.level, "actor", e)
			spider.faction = who.faction
			spider.ai = "summoned"
			spider.ai_real = "dumb_talented_simple"
			spider.summoner = who
			spider.summon_time = 10

			game.zone:addEntity(game.level, spider, "actor", x, y)
			game.level.map:particleEmitter(x, y, 1, "slime")

			game:playSoundNear(who, "talents/slime")
		end
	end },
}

newEntity{ base = "BASE_HELM",
	unique = true,
	name = "Star of Earendil",
	unided_name = "shining helm",
	desc = [[A headband with a glowing gem set in it, made in likeness of the silmaril that Earendil wore, and imbued with some of its light.]],
	level_range = {20, 28},
	rarity = 240,
	cost = 700,
	material_level = 4,
	wielder = {
		lite = 1,
		combat_armor = 6,
		fatigue = 4,
		blind_immune = 0.3,
		inc_stats = { [Stats.STAT_WIL] = 3, [Stats.STAT_MAG] = 4, },
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_SUN_FLARE, level = 3, power = 30 },
}

newEntity{ base = "BASE_KNIFE",
	unique = true,
	name = "Sting, Bilbo's Small Sword",
	unided_name = "shining dagger",
	desc = [["I will give you a name, and I shall call you Sting."
The perfect size for Bilbo, and stamped forever by the courage he found in Mirkwood, this sturdy little blade grants the wearer combat prowess and survivalabilities they did not know they had.]],
	level_range = {40, 50},
	rarity = 300,
	require = { stat = { dex=44 }, },
	cost = 550,
	material_level = 5,
	combat = {
		dam = 45,
		apr = 11,
		physcrit = 18,
		dammod = {dex=0.55,str=0.35},
	},
	wielder = {
		lite = 1,
		inc_damage={
			[DamageType.PHYSICAL] = 10,
			[DamageType.LIGHT] = 8,
		},
		pin_immune = 0.5,
		inc_stats = { [Stats.STAT_DEX] = 5, [Stats.STAT_CUN] = 4, },
		esp = {["humanoid/orc"]=1},
	},
}

newEntity{ base = "BASE_RING",
	unique = true,
	name = "Ring of the War Master", color = colors.DARK_GREY,
	unided_name = "blade-edged ring",
	desc = [[Elrond was told of the way to fashion a fourth ring by Celebrimbor, one he did not make out of fear it would also fall under the influence of the Ruling Ring.
After Frodo destroyed it, Elrond passed the knowledge to Aragorn the King of Men to use against any remaining forces which once followed Sauron.]],
	level_range = {15, 30},
	rarity = 200,
	cost = 500,
	material_level = 5,

	wielder = {
		inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_DEX] = 3, [Stats.STAT_CON] = 3, },
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.1,
			["technique/2hweapon-offense"] = 0.1,
			["technique/archery-bow"] = 0.1,
			["technique/archery-sling"] = 0.1,
			["technique/archery-training"] = 0.1,
			["technique/archery-utility"] = 0.1,
			["technique/combat-techniques-active"] = 0.1,
			["technique/combat-techniques-passive"] = 0.1,
			["technique/combat-training"] = 0.1,
			["technique/dualweapon-attack"] = 0.1,
			["technique/dualweapon-training"] = 0.1,
			["technique/shield-defense"] = 0.1,
			["technique/shield-offense"] = 0.1,
			["technique/warcries"] = 0.1,
			["technique/superiority"] = 0.1,
		},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	unique = true,
	name = "Mithril Hammer of Khaza'dûm", color = colors.LIGHT_RED,
	unided_name = "flame scorched mithril hammer",
	desc = [[The legendary hammer of the dwarven master smiths of Khaza'dûm. For ages it was used to forge powerful weapons with searing heat until it became of high power by intself.]],
	level_range = {38, 50},
	rarity = 250,
	require = { stat = { str=48 }, },
	cost = 650,
	material_level = 5,
	combat = {
		dam = 82,
		apr = 7,
		physcrit = 4,
		dammod = {str=1.2},
		talent_on_hit = { [Talents.T_FLAMESHOCK] = {level=3, chance=10} },
	},
	wielder = {
		inc_damage={
			[DamageType.PHYSICAL] = 15,
		},
		melee_project={[DamageType.FIRE] = 30},
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	unique = true,
	name = "Spider-Silk Robe of Torech Ungo", color = colors.DARK_GREEN,
	unided_name = "spider-silk robe",
	desc = [[After the fall of Mordor, teams of orcs looking for plunder found the thread of Shelob's own thick webs. They sewed the incredibly strong webbing together into a robe that was given to the head of a Pride before it was lost in a war.]],
	level_range = {20, 30},
	rarity = 190,
	cost = 250,
	material_level = 3,
	wielder = {
		combat_def = 10,
		combat_armor = 10,
		inc_stats = { [Stats.STAT_CON] = 4, [Stats.STAT_WIL] = -2, },
		combat_spellresist = 10,
		combat_physresist = 10,
		resists={[DamageType.NATURE] = 30},
		on_melee_hit={[DamageType.POISON] = 20},
	},
}

newEntity{ base = "BASE_HELM",
	unique = true,
	name = "Dragon-helm of Dor-lómin",
	unided_name = "dragon-helm",
	desc = [[A visored steel helm, embossed and embellished with gold, that bears as its crest the head of Glaurung the Dragon.]],
	require = { talent = { Talents.T_MASSIVE_ARMOUR_TRAINING }, stat = { str=35 }, },
	level_range = {37, 45},
	rarity = 280,
	cost = 400,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_CON] = 5, [Stats.STAT_LCK] = -4, },
		combat_def = 5,
		combat_armor = 9,
		fatigue = 10,
	},
	max_power = 45, power_regen = 1,
	use_talent = { id = Talents.T_WARSHOUT, level = 2, power = 80 },
}

--[=[
newEntity{
	unique = true,
	type = "jewelry", subtype="anhk",
	unided_name = "glowing anhk",
	name = "Anchoring Anhk",
	desc = [[As you lift the anhk you feel stable. The world around you feels stable.]],
	level_range = {15, 50},
	rarity = 400,
	display = "*", color=colors.YELLOW, image = "object/fireopal.png",
	encumber = 2,

	carrier = {

	},
}
]=]
