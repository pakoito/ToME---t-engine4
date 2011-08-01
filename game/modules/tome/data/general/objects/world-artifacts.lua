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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

--- Load additional artifacts
for def, e in pairs(game.state:getWorldArtifacts()) do
	importEntity(e)
	print("Importing "..e.name.." into world artifacts")
end

-- This file describes artifacts not bound to a special location, they can be found anywhere
newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Staff of Destruction",
	unided_name = "darkness infused staff",
	level_range = {20, 25},
	color=colors.VIOLET,
	rarity = 170,
	desc = [[This unique-looking staff is carved with runes of destruction.]],
	cost = 200,
	material_level = 3,

	require = { stat = { mag=24 }, },
	combat = {
		dam = 15,
		apr = 4,
		dammod = {mag=1.5},
		damtype = DamageType.ARCANE,
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

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Penitence",
	unided_name = "glowing staff",
	level_range = {10, 18},
	color=colors.VIOLET,
	rarity = 200,
	desc = [[A powerful staff sent in secret to Angolwen by the Shaloren, to aid their fighting of the plagues following the Spellblaze.]],
	cost = 200,
	material_level = 2,

	require = { stat = { mag=24 }, },
	combat = {
		dam = 10,
		apr = 4,
		dammod = {mag=1.2},
		damtype = DamageType.ARCANE,
	},
	wielder = {
		combat_spellpower = 15,
		combat_spellcrit = 10,
		resists = {
			[DamageType.BLIGHT] = 30,
		},
	},
	max_power = 60, power_regen = 1,
	use_power = { name = "cure diseases", power = 10,
		use = function(self, who)
			local target = who
			local effs = {}
			local known = false

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "disease" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			for i = 1, 3 + math.floor(who:getMag() / 10) do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
					known = true
				end
			end
			game.logSeen(who, "%s is cured of diseases!", who.name:capitalize())
			return true
		end
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Lost Staff of Archmage Tarelion",
	unided_name = "shining staff",
	level_range = {37, 50},
	color=colors.VIOLET,
	rarity = 250,
	desc = [[Archmage Tarelion traveled the world in his youth. But the world is not a nice place and it seems he had to run fast.]],
	cost = 400,
	material_level = 5,

	require = { stat = { mag=48 }, },
	combat = {
		dam = 38,
		apr = 4,
		dammod = {mag=1.5},
		damtype = DamageType.ARCANE,
	},
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 7, [Stats.STAT_MAG] = 8 },
		max_mana = 40,
		combat_spellpower = 40,
		combat_spellcrit = 25,
		inc_damage = { [DamageType.ARCANE] = 24, [DamageType.FIRE] = 24, [DamageType.COLD] = 24, [DamageType.LIGHTNING] = 24,  },
		silence_immune = 0.4,
		mana_on_crit = 12,
		talent_cd_reduction={
			[Talents.T_ICE_STORM] = 2,
			[Talents.T_FIREFLASH] = 2,
			[Talents.T_CHAIN_LIGHTNING] = 2,
		},
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Bolbum's Big Knocker",
	unided_name = "thick staff",
	level_range = {20, 35},
	color=colors.UMBER,
	rarity = 220,
	desc = [[A thick staff with a heavy knob on the end.  It was said to be used by the grand alchemist Bolbum in the Age of Allure.  Much renowned is the fear of his students for their master, and the high rate of cranial injuries amongst them.  Bolbum died with seven daggers in his back and his much-cursed staff went missing after.]],
	cost = 300,
	material_level = 4,

	require = { stat = { mag=38 }, },
	combat = {
		dam = 64,
		apr = 10,
		atk = 7,
		dammod = {mag=1.4},
		damtype = DamageType.PHYSICAL,
	},
	wielder = {
		combat_spellpower = 12,
		combat_spellcrit = 18,
		inc_damage={
			[DamageType.PHYSICAL] = resolvers.mbonus(20, 8),
		},
		talents_types_mastery = {
			["spell/staff-combat"] = 0.2,
		}
	},
}

newEntity{ base = "BASE_RING",
	power_source = {nature=true},
	unique = true,
	name = "Vargh Redemption", color = colors.LIGHT_BLUE,
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
					e.radius = e.radius + 0.4
					return true
				end,
				false
			)
			game.logSeen(who, "%s brandishes the %s, calling forth the might of the oceans!", who.name:capitalize(), self:getName())
			return true
		end
	},
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CON] = 6 },
		max_mana = 20,
		max_stamina = 20,
		max_psi = 20,
		max_air = 50,
		resists = {
			[DamageType.COLD] = 25,
			[DamageType.NATURE] = 10,
		},
	},
}

newEntity{ base = "BASE_RING",
	power_source = {nature=true},
	unique = true,
	name = "Ring of the Dead", color = colors.DARK_GREY,
	unided_name = "dull black ring",
	desc = [[This ring is imbued with powers from beyond the grave. It is said that those who wear it may find a new path when all other roads turn dim.]],
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
	power_source = {arcane=true},
	unique = true,
	name = "Elemental Fury", color = colors.PURPLE,
	unided_name = "multi-hued ring",
	desc = [[This ring shines with many colors.]],
	level_range = {15, 30},
	rarity = 200,
	cost = 200,
	material_level = 3,

	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 3,[Stats.STAT_CUN] = 3, },
		inc_damage = {
			[DamageType.ARCANE]    = 12,
			[DamageType.FIRE]      = 12,
			[DamageType.COLD]      = 12,
			[DamageType.ACID]      = 12,
			[DamageType.LIGHTNING] = 12,
		},
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "Spellblaze Echos", color = colors.DARK_GREY,
	unided_name = "deep black amulet",
	desc = [[This ancient charm still retains a distant echo of the destruction wrought by the Spellblaze]],
	level_range = {30, 39},
	rarity = 290,
	cost = 500,
	material_level = 4,

	wielder = {
		combat_armor = 6,
		combat_def = 6,
	},
	max_power = 300, power_regen = 1,
	use_power = { name = "unleash a destructive wail", power = 300,
		use = function(self, who)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.PHYSICAL, 100 + who:getMag() * 2)
			game.logSeen(who, "%s uses the %s!", who.name:capitalize(), self:getName())
			return true
		end
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {technique=true},
	unique = true,
	name = "Feathersteel Amulet", color = colors.WHITE,
	unided_name = "light amulet",
	desc = [[The weight of the world seems a little lighter with this amulet around your neck.]],
	level_range = {5, 15},
	rarity = 200,
	cost = 90,
	material_level = 2,

	wielder = {
		max_encumber = 20,
		fatigue = -20,
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {technique=true},
	unique = true,
	name = "Daneth's Neckguard", color = colors.STEEL_BLUE,
	unided_name = "a thick steel gorget",
	desc = [[A thick steel gorget designed to protect its wearer from fatal attacks to the neck.  This particular gorget was worn by the Halfling General Daneth Tendermourn during the pyre wars, and judging by the marks along its surface may have saved the General's life on more than one occasion.]],
	level_range = {20, 30},
	rarity = 300,
	cost = 300,
	encumber = 2,
	material_level = 2,
	wielder = {
		combat_armor = 10,
		fatigue = 2,
		inc_stats = {
			[Stats.STAT_STR] = 6,
			[Stats.STAT_CON] = 6,
		},
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_JUGGERNAUT, level = 2, power = 30 },
}

newEntity{ base = "BASE_AMULET",
	power_source = {technique=true},
	unique = true,
	name = "Garkul's Teeth", color = colors.YELLOW,
	unided_name = "a necklace made of teeth",
	desc = [[Hundreds of humanoid teeth have been strung together on multiple strands of thin leather, creating this tribal necklace.  One would have to assume that these are not the teeth of Garkul the Devourer but rather the teeth of Garkul's many meals.]],
	level_range = {40, 50},
	rarity = 300,
	cost = 1000,
	material_level = 4,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = 6,
			[Stats.STAT_CON] = 6,
		},
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.1,
			["technique/2hweapon-offense"] = 0.1,
			["technique/warcries"] = 0.1,
			["technique/bloodthirst"] = 0.1,
		},
		stun_immune = 0.3,
	},
	max_power = 48, power_regen = 1,
	use_talent = { id = Talents.T_SHATTERING_SHOUT, level = 4, power = 24 },
}

newEntity{ base = "BASE_LITE",
	power_source = {nature=true},
	unique = true,
	name = "Summertide Phial", image="object/artifact/summertide_phial.png",
	unided_name = "glowing phial",
	level_range = {1, 10},
	color=colors.YELLOW,
	encumber = 1,
	rarity = 100,
	desc = [[A small crystal phial that captured Sunlight during the Summertide.]],
	cost = 200,

	max_power = 15, power_regen = 1,
	use_power = { name = "call light", power = 10,
		use = function(self, who)
			who:project({type="ball", range=0, radius=20}, who.x, who.y, engine.DamageType.LITE, 100)
			game.logSeen(who, "%s brandishes the %s and banishes all shadows!", who.name:capitalize(), self:getName())
			return true
		end
	},
	wielder = {
		lite = 4,
	},
}

newEntity{ base = "BASE_LITE",
	power_source = {arcane=true},
	unique = true,
	name = "Burning Star",
	unided_name = "burning jewel",
	level_range = {20, 30},
	color=colors.YELLOW,
	encumber = 1,
	rarity = 250,
	desc = [[The first Halfling mages during the Age of Allure discovered how to capture the Sunlight and infuse gems with it.
This star is the culmination of their craft. Light radiates from its ever-shifting yellow surface.]],
	cost = 400,

	max_power = 150, power_regen = 1,
	use_power = { name = "map surroundings", power = 100,
		use = function(self, who)
			who:magicMap(20)
			game.logSeen(who, "%s brandishes the %s which radiates in all directions!", who.name:capitalize(), self:getName())
			return true
		end
	},
	wielder = {
		lite = 5,
	},
}

newEntity{ base = "BASE_LITE",
	power_source = {arcane=true},
	unique = true,
	name = "Dúathedlen Heart",
	unided_name = "a dark, fleshy mass",
	level_range = {30, 40},
	color = colors.RED,
	encumber = 1,
	rarity = 300,
	desc = [[This dark red heart still beats despite being seperated from its owner.  It also snuffs out any light source that comes near it.]],
	cost = 100,

	wielder = {
		lite = -1000,
		infravision = 7,
		resists_cap = { [DamageType.LIGHT] = 10 },
		resists = { [DamageType.LIGHT] = 30 },
	},

	max_power = 15, power_regen = 1,
	use_talent = { id = Talents.T_BLOOD_GRASP, level = 3, power = 10 },
}

newEntity{
	power_source = {nature=true},
	unique = true,
	type = "potion", subtype="potion",
	name = "Blood of Life",
	unided_name = "bloody phial",
	level_range = {1, 50},
	display = '!', color=colors.VIOLET, image="object/potion-0x3.png",
	encumber = 0.4,
	rarity = 350,
	desc = [[The Blood of Life! It can let a living being resurrect in case of an untimely demise. But only once!]],
	cost = 1000,

	use_simple = { name = "quaff the Blood of Life to grant an extra life", use = function(self, who)
		game.logSeen(who, "%s quaffs the %s!", who.name:capitalize(), self:getName())
		if not who:attr("undead") then
			who.blood_life = true
			game.logPlayer(who, "#LIGHT_RED#You feel the Blood of Life rushing through your veins.")
		else
			game.logPlayer(who, "The Blood of Life seems to have no effect on you.")
		end
		return true, "destroy", true
	end},
}

newEntity{ base = "BASE_LONGBOW",
	power_source = {nature=true},
	name = "Thaloren-Tree Longbow", unided_name = "glowing elven-wood longbow", unique=true,
	desc = [[In the aftermath of the Spellblaze, the Thaloren had to defend their forests against foes and fires alike. Many of the trees died despite the efforts of the Elves to save them. Their wood was fashioned into a bow to be wielded against the darkness.]],
	level_range = {40, 50},
	rarity = 200,
	require = { stat = { dex=36 }, },
	cost = 800,
	material_level = 5,
	combat = {
		range = 10,
		physspeed = 0.7,
		apr = 12,
	},
	basic_ammo = {
		dam = 57,
		apr = 18,
		physcrit = 3,
		dammod = {dex=0.7, str=0.5},
	},
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = 12, },
		lite = 1,
		inc_stats = { [Stats.STAT_DEX] = 5, [Stats.STAT_WIL] = 4,  },
		ranged_project={[DamageType.LIGHT] = 30},
	},
}

newEntity{ base = "BASE_LONGBOW",
	power_source = {arcane=true, nature=true},
	name = "Corpsebow", unided_name = "rotting longbow", unique=true,
	desc = [[A lost artifact of the Age of Dusk, the Corpsebow is filled with a lingering essence of that era's terrible plagues. Those struck by arrows fired from its rotten string find themselves afflicted by echoes of ancient sickness.]],
	level_range = {10, 20},
	rarity = 200,
	require = { stat = { dex=16 }, },
	cost = 50,
	material_level = 2,
	combat = {
		range = 7,
		physspeed = 0.8,
	},
	basic_ammo = {
		dam = 20,
		apr = 7,
		physcrit = 1.5,
		dammod = {dex=0.7, str=0.5},
	},
	wielder = {
		disease_immune = 0.5,
		ranged_project = {[DamageType.CORRUPTED_BLOOD] = 15},
	},
}

newEntity{ base = "BASE_SLING",
	power_source = {technique=true},
	unique = true,
	name = "Eldoral Last Resort",
	unided_name = "well-made sling",
	desc = [[A sling with an inscription on its handle: 'May the wielder be granted cunning in his fight against the darkness'.]],
	level_range = {15, 25},
	rarity = 200,
	require = { stat = { dex=26 }, },
	cost = 350,
	material_level = 3,
	combat = {
		range = 10,
		physspeed = 0.7,
	},
	basic_ammo = {
		dam = 36,
		apr = 3,
		physcrit = 5,
		dammod = {dex=0.7, cun=0.5},
	},
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = 4, [Stats.STAT_CUN] = 3,  },
		inc_damage={ [DamageType.PHYSICAL] = 15 },
		talent_cd_reduction={[Talents.T_STEADY_SHOT]=1, [Talents.T_EYE_SHOT]=2},
	},
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Spellblade",
	unided_name = "glowing long sword",
	level_range = {40, 45},
	color=colors.AQUAMARINE,
	rarity = 250,
	desc = [[Mages sometimes have funny ideas. Archmage Varil once learned how to handle a sword and found he preferred wielding it instead of his staff.]],
	on_id_lore = "spellblade",
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
	},
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {nature=true, technique=true},
	unique = true,
	name = "Genocide",
	unided_name = "pitch black blade",
	level_range = {25, 35},
	color=colors.GRAY,
	rarity = 300,
	desc = [[Farian was King Toknor's captain, and fought by his side in the great Battle of Last Hope.  However, when he returned after the battle to find his hometown burnt in an orcish pyre, a madness overtook him.  The desire for vengeance made him quit the army and strike out on his own, lightly armoured and carrying nought but his sword.  Most thought him dead until the reports came back of a fell figure tearing through the orcish encampments, slaughtering all before him and mercilessly butchering the corpses after.  It is said his blade drank the blood of 100 orcs each day until finally all of Maj'Eyal was cleared of their presence.  When the final orc was slain and no more were to be found, Farian at the last turned the blade on himself and stuck it through his chest.  Those nearby said his body shook with convulsions as he did so, though they could not tell whether he was laughing or crying.]],
	cost = 400,
	require = { stat = { str=40, wil=20 }, },
	material_level = 5,
	combat = {
		dam = 42,
		apr = 4,
		physcrit = 18,
		dammod = {str=1.2},
	},
	wielder = {
		stamina_regen = 1,
		life_regen = 0.5,
		inc_stats = { [Stats.STAT_STR] = 7, [Stats.STAT_DEX] = 7 },
		esp = {["humanoid/orc"]=1},
	},
}

newEntity{ base = "BASE_KNIFE",
	power_source = {technique=true},
	unique = true,
	name = "Unerring Scalpel",
	unided_name = "long sharp scalpel",
	desc = [[This scalpel was used by the dread sorcerer Kor'Pul when he began learning the necromantic arts in the Age of Dusk.  Many were the bodies, living and dead, that became unwilling victims of his terrible experiments.]],
	level_range = {1, 12},
	rarity = 200,
	require = { stat = { cun=16 }, },
	cost = 80,
	material_level = 3,
	combat = {
		dam = 15,
		apr = 10,
		atk = 40,
		physcrit = 0,
		dammod = {dex=0.55, str=0.45},
	},
}

newEntity{ base = "BASE_LEATHER_BOOT",
	power_source = {technique=true},
	unique = true,
	name = "Eden's Guile",
	unided_name = "pair of yellow boots",
	desc = [[The boots of a Rogue outcast, who knew that the best way to deal with a problem was to run from it.]],
	on_id_lore = "eden-guile",
	color = colors.YELLOW,
	level_range = {1, 20},
	rarity = 200,
	cost = 100,
	material_level = 3,
	wielder = {
		combat_armor = 1,
		combat_def = 2,
		fatigue = 2,
		talents_types_mastery = { ["cunning/survival"] = 0.2 },
		inc_stats = { [Stats.STAT_CUN] = 3, },
	},

	max_power = 50, power_regen = 1,
	use_power = { name = "boost speed", power = 50,
		use = function(self, who)
			who:setEffect(who.EFF_SPEED, 8, {power=0.20 + who:getCun() / 80})
			return true
		end
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true, technique=true},
	unique = true,
	name = "Fire Dragon Shield",
	unided_name = "dragon shield",
	desc = [[This large shield was made using scales of many fire drakes from the lost land of Tar'Eyal.]],
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
		combat_armor = 9,
		combat_def = 16,
		combat_def_ranged = 15,
		fatigue = 20,
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {technique=true},
	unique = true,
	name = "Titanic",
	unided_name = "huge shield",
	desc = [[This shield made of the darkest stralite is huge, heavy and very solid.]],
	color = colors.GREY,
	level_range = {20, 30},
	rarity = 270,
	require = { stat = { str=37 }, },
	cost = 300,
	material_level = 4,
	special_combat = {
		dam = 48,
		physcrit = 4.5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 18,
		combat_def = 20,
		combat_def_ranged = 10,
		fatigue = 30,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Rogue Plight",
	unided_name = "blackened leather armour",
	desc = [[No rogue blades shall incapacitate the wearer of this armour.]],
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
	power_source = {nature=true},
	unique = true,
	type = "misc", subtype="egg",
	unided_name = "dark egg",
	name = "Mummified Egg-sac of Ungolë",
	level_range = {20, 35},
	rarity = 190,
	display = "*", color=colors.DARK_GREY, image = "object/bloodstone.png",
	encumber = 2,
	not_in_stores = true,
	desc = [[Dry and dusty to the touch, it still seems to retain some of shadow of life.]],

	carrier = {
		lite = -2,
	},
	max_power = 100, power_regen = 1,
	use_power = { name = "summon spiders", power = 80, use = function(self, who)
		if not who:canBe("summon") then game.logPlayer(who, "You cannot summon; you are suppressed!") return end

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

			-- Add to the party
			if self.player then
				spider.remove_from_party_on_death = true
				game.party:addMember(spider, {
					control="no",
					type="summon",
					title="Summon",
					orders = {target=true, leash=true, anchor=true, talents=true},
				})
			end

			game.zone:addEntity(game.level, spider, "actor", x, y)
			game.level.map:particleEmitter(x, y, 1, "slime")

			game:playSoundNear(who, "talents/slime")
			return true
		end
	end },
}

newEntity{ base = "BASE_HELM",
	power_source = {technique=true},
	unique = true,
	name = "Helm of the Dwarven Emperors",
	unided_name = "shining helm",
	desc = [[A Dwarven helm embedded with a single diamond that can banish all underground shadows.]],
	level_range = {20, 28},
	rarity = 240,
	cost = 700,
	material_level = 3,
	wielder = {
		lite = 1,
		combat_armor = 6,
		fatigue = 4,
		blind_immune = 0.3,
		confusion_immune = 0.3,
		inc_stats = { [Stats.STAT_WIL] = 3, [Stats.STAT_MAG] = 4, },
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_SUN_FLARE, level = 3, power = 30 },
}

newEntity{ base = "BASE_KNIFE",
	power_source = {technique=true},
	unique = true,
	name = "Orc Feller",
	unided_name = "shining dagger",
	desc = [[During the invasion of Eldoral the Halfling Rogue Herah is said to have slain over one hundred orcs while defending a group of refugees.]],
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

newEntity{ base = "BASE_KNIFE",
	power_source = {technique=true},
	unique = true,
	name = "Silent Blade",
	unided_name = "shining dagger",
	desc = [[A thin, dark dagger that seems to meld seamlessly into the shadows.]],
	level_range = {23, 28},
	rarity = 200,
	require = { stat = { cun=25 }, },
	cost = 250,
	material_level = 3,
	combat = {
		dam = 25,
		apr = 10,
		atk = 15,
		physcrit = 8,
		dammod = {dex=0.55,str=0.35},
		no_stealth_break = true,
		melee_project={[DamageType.RANDOM_SILENCE] = 10},
	},
}

newEntity{ base = "BASE_KNIFE", define_as = "ART_PAIR_MOON",
	power_source = {arcane=true},
	unique = true,
	name = "Moon",
	unided_name = "crescent blade",
	desc = [[A viciously curved blade that a folk story says is made from a material that originates from the moon.  Devouring the light abound, it fades.]],
	level_range = {20, 30},
	rarity = 200,
	require = { stat = { dex=24, cun=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 30,
		apr = 30,
		physcrit = 10,
		dammod = {dex=0.45,str=0.45},
		melee_project={[DamageType.DARKNESS] = 20},
	},
	wielder = {
		lite = -1,
		inc_damage={
			[DamageType.DARKNESS] = 10,
		},
	},
	set_list = { {"define_as","ART_PAIR_STAR"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","lite"}, 1)
		self:specialSetAdd({"combat","melee_project"}, {[engine.DamageType.RANDOM_CONFUSION]=3})
		self:specialSetAdd({"wielder","inc_damage"}, {[engine.DamageType.DARKNESS]=10})
		game.logSeen(who, "#ANTIQUE_WHITE#The two blades glow brightly as they are brought close together.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#ANTIQUE_WHITE#The light from the two blades fades as they are separated.")
	end,
}

newEntity{ base = "BASE_KNIFE", define_as = "ART_PAIR_STAR",
	power_source = {arcane=true},
	unique = true,
	name = "Star",
	unided_name = "jagged blade",
	desc = [[Legend tells of a blade, shining bright as a star. Forged from a material fallen from the skies, it glows.]],
	level_range = {20, 30},
	rarity = 200,
	require = { stat = { dex=24, cun=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 25,
		apr = 20,
		physcrit = 20,
		dammod = {dex=0.45,str=0.45},
		melee_project={[DamageType.LIGHT] = 20},
	},
	wielder = {
		lite = 1,
		inc_damage={
			[DamageType.LIGHT] = 10,
		},
	},
	set_list = { {"define_as","ART_PAIR_MOON"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","lite"}, 1)
		self:specialSetAdd({"combat","melee_project"}, {[engine.DamageType.RANDOM_BLIND]=3})
		self:specialSetAdd({"wielder","inc_damage"}, {[engine.DamageType.LIGHT]=10})
	end,

}

newEntity{ base = "BASE_RING",
	power_source = {technique=true},
	unique = true,
	name = "Ring of the War Master", color = colors.DARK_GREY,
	unided_name = "blade-edged ring",
	desc = [[A blade-edged ring that radiates power. As you put it on, strange thoughts of pain and destruction come to your mind.]],
	level_range = {15, 30},
	rarity = 200,
	cost = 500,
	material_level = 5,

	wielder = {
		inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_DEX] = 3, [Stats.STAT_CON] = 3, },
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.3,
			["technique/2hweapon-offense"] = 0.3,
			["technique/archery-bow"] = 0.3,
			["technique/archery-sling"] = 0.3,
			["technique/archery-training"] = 0.3,
			["technique/archery-utility"] = 0.3,
			["technique/combat-techniques-active"] = 0.3,
			["technique/combat-techniques-passive"] = 0.3,
			["technique/combat-training"] = 0.3,
			["technique/dualweapon-attack"] = 0.3,
			["technique/dualweapon-training"] = 0.3,
			["technique/shield-defense"] = 0.3,
			["technique/shield-offense"] = 0.3,
			["technique/warcries"] = 0.3,
			["technique/superiority"] = 0.3,
		},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {technique=true, arcane=true},
	unique = true,
	name = "Voratun Hammer of the Deep Bellow", color = colors.LIGHT_RED,
	unided_name = "flame scorched voratun hammer",
	desc = [[The legendary hammer of the Dwarven master smiths. For ages it was used to forge powerful weapons with searing heat until it became highly powerful by itself.]],
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
		melee_project={[DamageType.FIRE] = 30},
	},
	wielder = {
		inc_damage={
			[DamageType.PHYSICAL] = 15,
		},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {technique=true},
	unique = true,
	name = "Unstoppable Mauler", color = colors.UMBER,
	unided_name = "heavy maul",
	desc = [[A huge greatmaul of incredible weight. Wielding it, you feel utterly unstoppable.]],
	level_range = {23, 30},
	rarity = 270,
	require = { stat = { str=40 }, },
	cost = 250,
	material_level = 3,
	combat = {
		dam = 48,
		apr = 15,
		atk = 20,
		physcrit = 3,
		dammod = {str=1.2},
		talent_on_hit = { [Talents.T_SUNDER_ARMOUR] = {level=3, chance=15} },
	},
	wielder = {
		pin_immune = 1,
		knockback_immune = 1,
	},
}

newEntity{ base = "BASE_MACE",
	power_source = {technique=true},
	unique = true,
	name = "Crooked Club", color = colors.GREEN,
	unided_name = "weird club",
	desc = [[An oddly twisted club with a hefty weight on the end.]],
	level_range = {3, 12},
	rarity = 192,
	require = { stat = { str=20 }, },
	cost = 250,
	material_level = 2,
	combat = {
		dam = 25,
		apr = 4,
		atk = 12,
		physcrit = 10,
		dammod = {str=1},
		melee_project={[DamageType.RANDOM_CONFUSION] = 14},
	},
}

newEntity{ base = "BASE_MACE",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Nature's Vengeance", color = colors.BROWN,
	unided_name = "thick wooden mace",
	desc = [[This thick-set mace was used by the Spellhunter Vorlan, who crafted it from the wood of an ancient oak that was uprooted during the Spellblaze.  Many were the wizards and witches felled by this weapon, brought to justice for the crimes they committed against nature.]],
	level_range = {20, 34},
	rarity = 340,
	require = { stat = { str=42 } },
	cost = 350,
	material_level = 4,
	combat = {
		dam = 40,
		apr = 4,
		atk = 6,
		physcrit = 9,
		dammod = {str=1},
		melee_project={[DamageType.RANDOM_SILENCE] = 10, [DamageType.NATURE] = 18},
	},

	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_RUSH, level = 3, power = 15 },
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {nature=true, arcane=true},
	unique = true,
	name = "Spider-Silk Robe of Spydrë", color = colors.DARK_GREEN,
	unided_name = "spider-silk robe",
	desc = [[This set of robes is made wholly of spider silk. It looks outlandish and some sages think it came from another world, probably through a farportal.]],
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
	power_source = {technique=true},
	unique = true,
	name = "Dragon-helm of Kroltar",
	unided_name = "dragon-helm",
	desc = [[A visored steel helm, embossed and embellished with gold, that bears as its crest the head of Kroltar, the greatest of the fire drakes.]],
	require = { talent = { {Talents.T_ARMOUR_TRAINING,4} }, stat = { str=35 }, },
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
	use_talent = { id = Talents.T_WARSHOUT, level = 2, power = 45 },
}

newEntity{ base = "BASE_HELM",
	power_source = {technique=true},
	unique = true,
	name = "Crown of Command",
	unided_name = "unblemished silver crown",
	desc = [[This crown was worn by the Halfling king Roupar, who ruled over the Nargol lands in the Age of Dusk.  Those were dark times, and the king enforced order and discipline under the harshest of terms.  Any who deviated were punished, any who disagreed were repressed, and many disappeared without a trace into his numerous prisons.  All must be loyal to the crown or suffer dearly.  When he died without heir the crown was lost and his kingdom fell into chaos.]],
	require = { stat = { cun=25 } },
	level_range = {20, 35},
	rarity = 280,
	cost = 300,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 3, [Stats.STAT_WIL] = 10, },
		combat_def = 3,
		combat_armor = 6,
		fatigue = 4,
		resists = { [DamageType.PHYSICAL] = 8},
		talents_types_mastery = { ["technique/superiority"] = 0.2, ["technique/field-control"] = 0.2 },
	},
}

newEntity{ base = "BASE_GLOVES",
	power_source = {technique=true},
	unique = true,
	name = "Gloves of the Firm Hand",
	unided_name = "heavy gloves",
	desc = [[These gloves make you feel rock steady! These magical gloves feel really soft to the touch from the inside. On the outside, magical stones create a rough surface that is constantly shifting. When you brace yourself, a magical ray of earth energy seems to automatically bind them to the ground, granting you increased stability.]],
	level_range = {17, 27},
	rarity = 210,
	cost = 150,
	material_level = 3,
	wielder = {
		talent_cd_reduction={[Talents.T_CLINCH]=2},
		inc_stats = { [Stats.STAT_CON] = 4 },
		combat_armor = 1,
		disarm_immune=0.3,
		knockback_immune=0.3,
		stun_immune=0.3,
		combat = {
			dam = 18,
			apr = 1,
			physcrit = 7,
			physspeed = -0.4,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
		},
	},
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {arcane=true, technique=true},
	unique = true,
	name = "Dakhtun's Gauntlets", color = colors.STEEL_BLUE,
	unided_name = "expertly-crafted dwarven-steel gauntlets",
	desc = [[Fashioned by Grand Smith Dakhtun in the Age of Allure, these dwarven-steel gauntlets have been etched with golden arcane runes and are said to grant the wearer unparalleled physical and magical might.]],
	level_range = {40, 50},
	rarity = 300,
	cost = 2000,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 6, [Stats.STAT_MAG] = 6 },
		inc_damage = { [DamageType.PHYSICAL] = 10 },
		combat_physcrit = 10,
		combat_spellcrit = 10,
		combat_critical_power = 50,
		combat_armor = 6,
		combat = {
			dam = 35,
			apr = 10,
			physcrit = 10,
			physspeed = -0.2,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			melee_project={[DamageType.ARCANE] = 20},
			damrange = 0.3,
		},
	},
}

newEntity{ base = "BASE_GLOVES",
	power_source = {nature=true},
	unique = true,
	name = "Snow Giant Wraps", color = colors.SANDY_BROWN,
	unided_name = "fur-lined leather wraps",
	desc = [[Two large pieces of leather designed to be wrapped about the hands and the forearms.  This particular pair of wraps has been enchanted, imparting the wearer with great strength.]],
	level_range = {15, 25},
	rarity = 200,
	cost = 500,
	material_level = 1,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 4, },
		resists = { [DamageType.COLD]= 10, [DamageType.LIGHTNING] = 10, },
		knockback_immune = 0.5,
		combat_armor = 2,
		max_life = 60,
		combat = {
			dam = 16,
			apr = 1,
			physcrit = 4,
			physspeed = -0.4,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			melee_project={ [DamageType.COLD] = 10, [DamageType.LIGHTNING] = 10, },
		},
	},
	max_power = 6, power_regen = 1,
	use_talent = { id = Talents.T_THROW_BOULDER, level = 2, power = 6 },
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {arcane=true},
	unique = true,
	name = "Storm Bringer's Gauntlets", color = colors.LIGHT_STEEL_BLUE,
	unided_name = "fine-mesh gauntlets",
	desc = [[This pair of fine mesh voratun gauntlets is covered with glyphs of power that spark with azure energy.  The metal is supple and light so as not to interfere with spell-casting.  When and where these gauntlets were forged is a mystery but odds are the crafter knew a thing or two about magic.]],
	level_range = {25, 35},
	rarity = 250,
	cost = 1000,
	material_level = 5,
	require = nil,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 4, },
		resists = { [DamageType.LIGHTNING] = 15, },
		inc_damage = { [DamageType.LIGHTNING] = 10 },
		resists_cap = { [DamageType.LIGHTNING] = 5 },
		combat_spellcrit = 5,
		combat_critical_power = 20,
		combat_armor = 3,
		combat = {
			dam = 22,
			apr = 10,
			physcrit = 4,
			physspeed = -0.2,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			melee_project={ [DamageType.LIGHTNING] = 20, },
			talent_on_hit = { [Talents.T_LIGHTNING] = {level=3, chance=10} },
			damrange = 0.3,
		},
	},
	max_power = 16, power_regen = 1,
	use_talent = { id = Talents.T_CHAIN_LIGHTNING, level = 3, power = 16 },
}

newEntity{ base = "BASE_CLOAK",
	power_source = {nature=true},
	unique = true,
	name = "Serpentine Cloak",
	unided_name = "tattered cloak",
	desc = [[Cunning and malice seem to emanate from this cloak.]],
	level_range = {20, 29},
	rarity = 240,
	cost = 200,
	material_level = 3,
	wielder = {
		combat_def = 10,
		inc_stats = { [Stats.STAT_CUN] = 6, [Stats.STAT_CON] = 5, },
		resists_pen = { [DamageType.NATURE] = 15 },
		talents_types_mastery = { ["cunning/stealth"] = 0.1, },
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_PHASE_DOOR, level = 2, power = 30 },
}

newEntity{ base = "BASE_CLOAK",
	power_source = {arcane=true},
	unique = true,
	name = "Wind's Whisper",
	unided_name = "flowing light cloak",
	desc = [[When the enchanter Razeen was cornered by Spellhunters near the Daikara mountain pass she wrapped her cloak about her and fled down a narrow ravine.  The hunters fired volley after volley of arrows at her, but by miracle or magic they all missed.  Razeen was able to escape and flee to the hidden city in the west.]],
	level_range = {15, 25},
	rarity = 400,
	cost = 250,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = 3, },
		combat_def = 4,
		combat_ranged_def = 12,
		silence_immune = 0.3,
	},
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_EVASION, level = 2, power = 50 },
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Vestments of the Conclave", color = colors.DARK_GREY,
	unided_name = "tattered robe",
	desc = [[An ancient set of robes that has survived from the Age of Allure. Primal magic forces inhabit it.
It was made by Humans for Humans; only they can harness the true power of the robes.]],
	level_range = {12, 22},
	rarity = 220,
	cost = 150,
	material_level = 3,
	wielder = {
		inc_damage = {[DamageType.ARCANE]=10},
		inc_stats = { [Stats.STAT_MAG] = 6 },
		combat_spellcrit = 15,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Human" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_MAG] = 3, [Stats.STAT_CUN] = 9, })
			self:specialWearAdd({"wielder","inc_damage"}, {[DamageType.ARCANE]=7})
			self:specialWearAdd({"wielder","combat_spellcrit"}, 2)
			game.logPlayer(who, "#LIGHT_BLUE#You feel as surge of power as you wear the vestments of the old Human Conclave!")
		end
	end,
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Firewalker", color = colors.RED,
	unided_name = "blazing robe",
	desc = [[This fiery robe was worn by the mad pyromancer Halchot, who terrorised many towns in the late Age of Dusk, burning and looting villages as they tried to recover from the Spellblaze.  Eventually he was tracked down by the Ziguranth, who cut out his tongue, chopped off his head, and rent his body to shreds.  The head was encased in a block of ice and paraded through the streets of nearby towns amidst the cheers of the locals.  Only this robe remains of the flames of Halchot.]],
	level_range = {20, 30},
	rarity = 300,
	cost = 280,
	material_level = 4,
	wielder = {
		inc_damage = {[DamageType.FIRE]=20},
		combat_def = 8,
		combat_armor = 2,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_CUN] = 6, },
		resists = {[DamageType.FIRE] = 20, [DamageType.COLD] = -10},
		resists_pen = { [DamageType.FIRE] = 20 },
		on_melee_hit = {[DamageType.FIRE] = 18},
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Robe of the Archmage", color = colors.RED,
	unided_name = "glittering robe",
	desc = [[A plain elven-silk robe. It would be unremarkable if not for the sheer power it radiates.]],
	level_range = {30, 40},
	rarity = 290,
	cost = 550,
	material_level = 5,
	wielder = {
		lite = 1,
		inc_damage = {all=12},
		blind_immune = 0.4,
		combat_def = 10,
		combat_armor = 10,
		inc_stats = { [Stats.STAT_MAG] = 4, [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 4, },
		combat_spellpower = 15,
		combat_spellresist = 18,
		combat_mentalresist = 15,
		resists={[DamageType.FIRE] = 10, [DamageType.COLD] = 10},
		on_melee_hit={[DamageType.ARCANE] = 15},
		mana_regen = 1,
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Temporal Augmentation Robe - Designed In-Style", color = colors.BLACK,
	unided_name = "stylish robe with a scarf",
	desc = [[Designed by a slightly quirky Paradox Mage, this robe always appears to be stylish in any time the user finds him, her, or itself in. Crafted to aid Paradox Mages through their adventures, this robe is of great help to those that understand what a wibbly-wobbly, timey-wimey mess time actually is. Curiously, as a result of a particularly prolonged battle involving its fourth wearer, the robe appends a very long, multi-coloured scarf to its present wearers.]],
	level_range = {30, 40},
	rarity = 310,
	cost = 540,
	material_level = 5,
	wielder = {
		inc_damage = {[DamageType.TEMPORAL]=20},
		combat_def = 9,
		combat_armor = 3,
		inc_stats = { [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 3, },
		resists={[DamageType.TEMPORAL] = 20},
		resists_pen = { [DamageType.TEMPORAL] = 20 },
		on_melee_hit={[DamageType.TEMPORAL] = 10},
	},
	max_power = 100, power_regen = 1,
	use_talent = { id = Talents.T_DAMAGE_SMEARING, level = 3, power = 100 },
}

newEntity{ base = "BASE_GEM",
	power_source = {arcane=true},
	unique = true,
	unided_name = "scintillating white crystal",
	name = "Telos's Staff Crystal", subtype = "multi-hued",
	color = colors.WHITE, image="object/diamond.png",
	level_range = {35, 45},
	desc = [[A closer look at this pure white crystal reveals that it is really a plethora of colors swirling and scintillating.]],
	rarity = 240,
	cost = 200,
	material_level = 5,
	carrier = {
		confusion_immune = 0.8,
		fear_immune = 0.7,
		resists={[DamageType.MIND] = 35,},
	},
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 5, [Stats.STAT_CON] = 5, },
		lite = 2,
	},
	imbue_powers = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 5, [Stats.STAT_CON] = 5, },
		lite = 2,
	},

	max_power = 1, power_regen = 1,
	use_power = { name = "combine with a staff", power = 1, use = function(self, who, gem_inven, gem_item)
		who:showInventory("Fuse with which staff?", who:getInven("INVEN"), function(o) return o.type == "weapon" and o.subtype == "staff" and not o.egoed and not o.unique end, function(o, item)
			local voice = game.zone:makeEntityByName(game.level, "object", "VOICE_TELOS")
			if voice then
				local oldname = o:getName{do_color=true}

				-- Remove the gem
				who:removeObject(gem_inven, gem_item)
				who:sortInven(gem_inven)

				-- Change the staff
				voice.combat = o.combat
				voice.combat.dam = voice.combat.dam * 1.4
				voice.combat.damtype = engine.DamageType.ARCANE
				voice:identify(true)
				o:replaceWith(voice)
				who:sortInven()

				who.changed = true
				game.logPlayer(who, "You fix the crystal on the %s and create the %s.", oldname, o:getName{do_color=true})
			else
				game.logPlayer(who, "The fusing fails!")
			end
		end)
		return true
	end },
}

-- The staff that goes with the crystal above, it will not be generated randomly it is created by the crystal
newEntity{ base = "BASE_STAFF", define_as = "VOICE_TELOS",
	power_source = {arcane=true},
	unique = true,
	name = "Voice of Telos",
	unided_name = "scintillating white staff",
	color = colors.VIOLET,
	rarity = false,
	desc = [[A closer look at this pure white staff reveals that it is really a plethora of colors swirling and scintillating.]],
	cost = 500,
	material_level = 5,

	require = { stat = { mag=45 }, },
	-- This is replaced by the creation process
	combat = { dam = 1, },
	wielder = {
		combat_spellpower = 30,
		combat_spellcrit = 15,
		max_mana = 100,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 4 },
		lite = 1,

		inc_damage = { all=14 },
	},
}

newEntity{ base = "BASE_WAND",
	power_source = {arcane=true},
	unided_name = "glowing rod",
	name = "Gwai's Burninator", color=colors.LIGHT_RED, unique=true,
	desc = [[Gwai, a Pyromanceress that lived during the Spellhunt, was cornered by group of mage hunters. She fought to her last breath and is said to have killed at least ten people with this wand before she fell.]],
	cost = 50,
	rarity = 220,
	level_range = {15, 30},
	elec_proof = true,
	add_name = false,

	material_level = 5,

	max_power = 75, power_regen = 1,
	use_power = { name = "shoot a cone of fire", power = 20,
		use = function(self, who)
			local tg = {type="cone", range=0, radius=5}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, engine.DamageType.FIRE, 80 + who:getMag() * 1.2, {type="flame"})
			return true
		end
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {technique=true},
	unique = true,
	unided_name = "crude iron battle axe",
	name = "Crude Iron Battle Axe of Kroll", color = colors.GREY,
	desc = [[Made in times before the Dwarves learned beautiful craftsmanship, the rough appearance of this axe belies its great power. Only Dwarves may harness its true strength, however.]],
	require = { stat = { str=50 }, },
	level_range = {39, 46},
	rarity = 300,
	material_level = 4,
	combat = {
		dam = 68,
		apr = 7,
		physcrit = 10,
		dammod = {str=1.3},
	},
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 2, [Stats.STAT_DEX] = 2, },
		combat_def = 6, combat_armor = 6,
		inc_damage = { [DamageType.PHYSICAL]=10 },
		stun_immune = 0.5,
		knockback_immune = 0.5,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Dwarf" then
			local Stats = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_CON] = 7, [Stats.STAT_DEX] = 7, })
			self:specialWearAdd({"wielder","stun_immune"}, 0.5)
			self:specialWearAdd({"wielder","knockback_immune"}, 0.5)
			game.logPlayer(who, "#LIGHT_BLUE#You feel as surge of power as you wield the axe of your ancestors!")
		end
	end,
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {technique=true},
	unique = true,
	unided_name = "viciously sharp battle axe",
	name = "Drake's Bane",
	color = colors.RED,
	desc = [[The killing of Kroltar, mightiest of wyrms, took seven months and the lives of 20,000 dwarven warriors.  Finally the beast was worn down and mastersmith Gruxim, standing atop the bodies of his fallen comrades, was able slit its throat with this axe crafted purely for the purpose of penetrating the wyrm's hide.]],
	require = { stat = { str=45 }, },
	rarity = 300,
	cost = 400,
	level_range = {20, 35},
	material_level = 4,
	combat = {
		dam = 52,
		apr = 21,
		physcrit = 2,
		dammod = {str=1.2},
		inc_damage_type = {dragon=25},
	},
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 6, },
		stun_immune = 0.2,
		knockback_immune = 0.4,
		combat_physresist = 9,
	},
}

newEntity{ base = "BASE_WARAXE",
	power_source = {technique=true, nature=true},
	unique = true,
	name = "Blood-Letter",
	unided_name = "Glacial Hatchet",
	desc = [[A hand axe carved out of the most frozen parts of the northern wasteland.]],
	level_range = {25, 35},
	rarity = 235,
	require = { stat = { str=40, dex=24 }, },
	cost = 330,
	material_level = 4,
	combat = {
		dam = 33,
		apr = 4.5,
		physcrit = 7,
		dammod = {str=1},
		melee_project={[DamageType.COLD] = 25},
	},
	wielder = {
		combat_atk = 15,
	},
}

newEntity{ base = "BASE_WHIP",
	power_source = {nature=true},
	unided_name = "metal whip",
	name = "Scorpion's Tail", color=colors.GREEN, unique = true, image = "object/artifact/whip_scorpions_tail.png",
	desc = [[A long whip of linked metal joints finished with a viciously sharp barb leaking venomous poison.]],
	require = { stat = { dex=28 }, },
	cost = 150,
	material_level = 3,
	combat = {
		dam = 28,
		apr = 8,
		atk = 10,
		physcrit = 5,
		dammod = {dex=1},
		melee_project={[DamageType.POISON] = 22},
	},
	wielder = {
		see_invisible = 9,
	},
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {technique=true},
	unique = true,
	name = "Mighty Girdle",
	unided_name = "massive, stained girdle",
	desc = [[This girdle is enchanted with mighty wards against expanding girth. Whatever the source of its wondrous strength, it will prove of great aid in the transport of awkward burdens.]],
	color = colors.LIGHT_RED,
	level_range = {1, 25},
	rarity = 170,
	cost = 350,
	material_level = 5,
	wielder = {
		knockback_immune = 0.4,
		max_encumber = 70,
		combat_armor = 4,
	},
}


newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {nature=true, arcane=true},
	unique = true,
	name = "Rope Belt of the Thaloren",
	unided_name = "short length of rope",
	desc = [[The simplest of belts, worn for centuries by Nessilla Tantaelen as she tended to her people and forests. Some of her wisdom and power have settled permanently into its fibers.]],
	color = colors.LIGHT_RED,
	level_range = {20, 30},
	rarity = 200,
	cost = 450,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 7, [Stats.STAT_WIL] = 8, },
		combat_mindpower = 12,
		talents_types_mastery = { ["wild-gift/harmony"] = 0.2 },
	},
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {nature=true},
	unique = true,
	name = "Girdle of Preservation",
	unided_name = "shimmering, flawless belt",
	desc = [[A pristine belt of purest white leather with a runed voratun buckle. The ravages of neither time nor the elements have touched it.]],
	color = colors.WHITE,
	level_range = {45, 50},
	rarity = 400,
	cost = 750,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 5, [Stats.STAT_WIL] = 5,  },
		resists = {
			[DamageType.ACID] = 15,
			[DamageType.LIGHTNING] = 15,
			[DamageType.FIRE] = 15,
			[DamageType.COLD] = 15,
			[DamageType.LIGHT] = 15,
			[DamageType.DARKNESS] = 15,
			[DamageType.BLIGHT] = 15,
			[DamageType.NATURE] = 15,
			[DamageType.PHYSICAL] = 10,
			[DamageType.ARCANE] = 10,
		},
		confusion_immune = 0.2,
		combat_physresist = 15,
		combat_mentalresist = 15,
		combat_spellresist = 15,
	},
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {nature=true},
	unique = true,
	name = "Girdle of the Calm Waters",
	unided_name = "golden belt",
	desc = [[A belt rumoured to have been worn by the Conclave healers.]],
	color = colors.GOLD,
	level_range = {5, 14},
	rarity = 120,
	cost = 75,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 3,  },
		resists = {
			[DamageType.COLD] = 20,
			[DamageType.BLIGHT] = 20,
			[DamageType.NATURE] = 20,
		},
		healing_factor = 0.3,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Behemoth Hide",
	unided_name = "tough weathered hide",
	desc = [[A rough hide made from a massive beast.  Seeing as it's so weathered but still usable, maybe it's a bit special...]],
	color = colors.BROWN,
	level_range = {18, 23},
	rarity = 230,
	require = { stat = { str=22 }, },
	cost = 250,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 2, [Stats.STAT_CON] = 2 },

		combat_armor = 6,
		combat_def = 4,
		combat_def_ranged = 8,

		max_encumber = 20,
		life_regen = 0.7,
		stamina_regen = 0.7,
		fatigue = 10,
		max_stamina = 43,
		max_life = 45,
		knockback_immune = 0.1,
		size_category = 1,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Skin of Many",
	unided_name = "stitched skin armour",
	desc = [[The stitched-together skin of many creatures. Some eyes and mouths still decorate the robe, and some still live, screaming in tortured agony.]],
	color = colors.BROWN,
	level_range = {12, 22},
	rarity = 200,
	require = { stat = { str=16 }, },
	cost = 200,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 4 },
		combat_armor = 6,
		combat_def = 12,
		fatigue = 7,
		max_life = 40,
		infravision = 6,
		talents_types_mastery = { ["cunning/stealth"] = -0.2, },
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Nature's Blessing",
	unided_name = "supple leather armour entwined with willow bark",
	desc = [[Worn by Protector Ardon, who first formed the Ziguranth during the mage wars between the Humans and the Halflings.  This armour is infused with the powers of nature, and protected against the disruptive forces of magic.]],
	color = colors.BROWN,
	level_range = {15, 30},
	rarity = 350,
	require = { stat = { str=20 }, {wil=20} },
	cost = 350,
	material_level = 4,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 3, [Stats.STAT_CON] = 4 },

		combat_armor = 6,
		combat_def = 8,
		combat_def_ranged = 4,

		life_regen = 1,
		fatigue = 8,
		stun_immune = 0.25,
		healing_factor = 0.2,
		combat_spellresist = 18,

		resists = {
			[DamageType.NATURE] = 20,
			[DamageType.ARCANE] = 25,
		},

		talents_types_mastery = { ["wild-gift/antimagic"] = 0.2},
	},
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Iron Mail of Bloodletting",
	unided_name = "gore-encrusted suit of iron mail",
	desc = [[Blood drips continuously from this fell suit of iron, and dark magics churn almost visibly around it. Bloody ruin comes to those who stand against its wearer.]],
	color = colors.RED,
	level_range = {15, 25},
	rarity = 190,
	require = { stat = { str=14 }, },
	cost = 200,
	material_level = 1,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 2, [Stats.STAT_STR] = 2 },
		resists = {
			[DamageType.ACID] = 10,
			[DamageType.DARKNESS] = 10,
			[DamageType.FIRE] = 10,
			[DamageType.BLIGHT] = 10,
		},
		talents_types_mastery = { ["technique/bloodthirst"] = 0.1 },
		life_regen = 0.5,
		combat_def = 2,
		combat_armor = 4,
		fatigue = 12,
	},
}


newEntity{ base = "BASE_HEAVY_ARMOR",
	power_source = {technique=true, nature=true},
	unique = true,
	name = "Scale Mail of Kroltar",
	unided_name = "perfectly-wrought suit of dragon scales",
	desc = [[A heavy shirt of scale mail constructed from the remains of Kroltar, whose armour was like tenfold shields.]],
	color = colors.LIGHT_RED,
	metallic = false,
	level_range = {38, 45},
	rarity = 300,
	require = { stat = { str=38 }, },
	cost = 500,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 4, [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 3 },
		resists = {
			[DamageType.ACID] = 20,
			[DamageType.LIGHTNING] = 20,
			[DamageType.FIRE] = 20,
			[DamageType.BLIGHT] = 20,
			[DamageType.NATURE] = 20,
		},
		max_life=120,
		combat_def = 10,
		combat_armor = 14,
		fatigue = 16,
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_INFERNO, level = 3, power = 50 },
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Plate Armor of the King",
	unided_name = "suit of gleaming voratun plate",
	desc = [[Beautifully detailed with images of King Toknor's defence of Last Hope. Despair fills the hearts of even the blackest villains at the sight of it.]],
	color = colors.WHITE,
	level_range = {45, 50},
	rarity = 390,
	require = { stat = { str=48 }, },
	cost = 800,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 9, },
		resists = {
			[DamageType.ACID] = 25,
			[DamageType.ARCANE] = 10,
			[DamageType.FIRE] = 25,
			[DamageType.BLIGHT] = 25,
			[DamageType.DARKNESS] = 25,
		},
		max_stamina = 60,
		combat_def = 15,
		combat_armor = 20,
		stun_immune = 0.5,
		knockback_immune = 0.5,
		lite = 1,
		fatigue = 26,
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Cuirass of the Thronesmen",
	unided_name = "heavy dwarven-steel armour",
	desc = [[This heavy dwarven-steel armour was created in the deepest forges of the Iron Throne. While it grants incomparable protection, it demands that you rely only on your own strength.]],
	color = colors.WHITE,
	level_range = {35, 40},
	rarity = 320,
	require = { stat = { str=44 }, },
	cost = 500,
	material_level = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 6, },
		resists = {
			[DamageType.FIRE] = 25,
		},
		combat_def = 20,
		combat_armor = 29,
		stun_immune = 0.5,
		knockback_immune = 0.5,
		healing_factor = -0.4,
		fatigue = 15,
	},
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {technique=true},
	unique = true,
	name = "Golden Three-Edged Sword 'The Truth' ",
	unided_name = "three-edged sword",
	desc = [[The wise ones say that truth is a three-edged sword. And sometimes, the truth hurts.]],
	level_range = {25, 32},
	require = { stat = { str=26, wil=26, cun=26 }, },
	color = colors.GOLD,
	encumber = 12,
	cost = 350,
	rarity = 240,
	material_level = 4,
	combat = {
		dam = 40,
		apr = 1,
		physcrit = 7,
		dammod = {str=1.2},
		special_on_hit = {desc="9% chance to stun or confuse the target", fct=function(combat, who, target)
			if not rng.percent(9) then return end
			local eff = rng.table{"stun", "confusion"}
			if not target:canBe(eff) then return end
			if not target:checkHit(who:combatAttack(combat), target:combatPhysicalResist(), 15) then return end
			if eff == "stun" then target:setEffect(target.EFF_STUNNED, 3, {})
			elseif eff == "confusion" then target:setEffect(target.EFF_CONFUSED, 3, {power=75})
			end
		end},
		melee_project={[DamageType.LIGHT] = 40, [DamageType.DARKNESS] = 40},
	},
}

newEntity{ base = "BASE_WARAXE",
	power_source = {technique=true},
	unique = true,
	rarity = false, unided_name = "razor sharp war axe",
	name = "Razorblade, the Cursed Waraxe", color = colors.LIGHT_BLUE,
	desc = [[This mighty axe can cleave through armour like the sharpest swords, yet hit with all the impact of a heavy club.
It is said the wielder will slowly grow mad. This, however, has never been proven - no known possessor of this item has lived to tell the tale.]],
	require = { stat = { str=42 }, },
	material_level = 5,
	combat = {
		dam = 58,
		apr = 16,
		physcrit = 7,
		dammod = {str=1},
		damrange = 1.4,
		damtype = DamageType.PHYSICALBLEED,
	},
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 4, [Stats.STAT_DEX] = 4, },
		see_invisible = 5,
		inc_damage = { [DamageType.PHYSICAL]=10 },
	},
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {arcane=true},
	unique = true,
	name = "Stone Gauntlets of Harkor'Zun",
	unided_name = "dark stone gauntlets",
	desc = [[Fashioned in ancient times by cultists of Harkor'Zun, these heavy granite gauntlets were designed to protect the wearer from the wrath of their dark master.]],
	level_range = {26, 31},
	rarity = 210,
	encumber = 7,
	metallic = false,
	cost = 150,
	material_level = 3,
	wielder = {
		talent_cd_reduction={
			[Talents.T_CLINCH]=2,
		},
		fatigue = 10,
		combat_armor = 7,
		inc_damage = { [DamageType.PHYSICAL]=5, [DamageType.ACID]=10, },
		resists = {[DamageType.ACID] = 20, [DamageType.PHYSICAL] = 10, },
		resists_cap = {[DamageType.ACID] = 10, [DamageType.PHYSICAL] = 5, },
		resists_pen = {[DamageType.ACID] = 15, [DamageType.PHYSICAL] = 15, },
		combat = {
			dam = 26,
			apr = 15,
			physcrit = 5,
			dammod = {dex=0.3, str=-0.4, cun=0.3 },
			melee_project={[DamageType.ACID] = 10},
			damrange = 0.3,
		},
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "Zemekkys' Broken Hourglass", color = colors.WHITE,
	unided_name = "a broken hourglass",
	desc = [[This small broken hourglass hangs from a thin gold chain.  The glass is cracked and the sand has long since escaped.]],
	level_range = {30, 40},
	rarity = 300,
	cost = 200,
	material_level = 4,
	metallic = false,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, },
		inc_damage = { [DamageType.TEMPORAL]= 10 },
		resists = { [DamageType.TEMPORAL] = 20 },
		resists_cap = { [DamageType.TEMPORAL] = 5 },
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_WORMHOLE, level = 2, power = 60 },
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "Unflinching Eye", color = colors.WHITE,
	unided_name = "a bloodshot eye",
	desc = [[Someone has strung a thick black cord through this large bloodshot eyeball, allowing it to be worn around the neck, should you so choose.]],
	level_range = {30, 40},
	rarity = 300,
	cost = 300,
	material_level = 4,
	metallic = false,
	wielder = {
		infravision = 4,
		resists = { [DamageType.LIGHT] = -25 },
		resists_cap = { [DamageType.LIGHT] = -25 },
		blind_immune = 1,
		confusion_immune = 1,
		esp = { horror = 1 },
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_ARCANE_EYE, level = 2, power = 60 },
}

newEntity{ base = "BASE_CLOAK",
	power_source = {nature=true},
	unique = true,
	name = "Ureslak's Molted Scales",
	unided_name = "scaley multi-hued cloak",
	desc = [[This cloak is fashioned from the scales of some large reptilian creature.  It appears to reflect every color of the rainbow.]],
	level_range = {40, 50},
	rarity = 400,
	cost = 300,
	material_level = 3,
	wielder = {
		resists_cap = {
			[DamageType.FIRE] = 5,
			[DamageType.COLD] = 5,
			[DamageType.LIGHTNING] = 5,
			[DamageType.NATURE] = 5,
			[DamageType.DARKNESS] = 5,
			[DamageType.ARCANE] = -30,
		},
		resists = {
			[DamageType.FIRE] = 20,
			[DamageType.COLD] = 20,
			[DamageType.LIGHTNING] = 20,
			[DamageType.NATURE] = 20,
			[DamageType.DARKNESS] = 20,
			[DamageType.ARCANE] = -30,
		},
	},
}

--[=[
newEntity{
	unique = true,
	type = "jewelry", subtype="ankh",
	unided_name = "glowing ankh",
	name = "Anchoring Ankh",
	desc = [[As you lift the ankh you feel stable. The world around you feels stable.]],
	level_range = {15, 50},
	rarity = 400,
	display = "*", color=colors.YELLOW, image = "object/fireopal.png",
	encumber = 2,

	carrier = {

	},
}
]=]
