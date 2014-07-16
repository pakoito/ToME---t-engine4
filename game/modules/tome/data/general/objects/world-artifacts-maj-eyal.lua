-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Penitence",
	flavor_name = "starstaff",
	unided_name = "glowing staff", image = "object/artifact/staff_penitence.png",
	level_range = {10, 18},
	color=colors.VIOLET,
	rarity = 200,
	desc = [[A powerful staff sent in secret to Angolwen by the Shaloren, to aid their fighting of the plagues following the Spellblaze.]],
	cost = 200,
	material_level = 2,

	require = { stat = { mag=24 }, },
	combat = {
		--sentient = "penitent", -- commented out for now...  how many sentient staves do we need?
		dam = 15,
		apr = 4,
		dammod = {mag=1.2},
		damtype = DamageType.NATURE, -- Note this is odd for a staff; it's intentional and it's also why the damage type can't be changed.  Blight on this staff would be sad :(
	},
	wielder = {
		combat_spellpower = 15,
		combat_spellcrit = 10,
		resists = {
			[DamageType.BLIGHT] = 30,
		},
		damage_affinity={
			[DamageType.NATURE] = 20,
		},
	},
	max_power = 60, power_regen = 1,
	use_power = { name = "cure diseases and poisons", power = 10,
		use = function(self, who)
			local target = who
			local effs = {}
			local known = false

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.disease or e.subtype.poison then
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
			game.logSeen(who, "%s is cured of diseases and poisons!", who.name:capitalize())
			return {id=true, used=true}
		end
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subrace == "Shalore" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","resists"}, { [engine.DamageType.BLIGHT] = 10})
			self:specialWearAdd({"wielder","disease_immune"}, 0.5)
			game.logPlayer(who, "#DARK_GREEN#You feel the cleansing power of Penitence attune to you.")
		end
	end,
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Lost Staff of Archmage Tarelion", image = "object/artifact/staff_lost_staff_archmage_tarelion.png",
	unided_name = "shining staff",
	flavor_name = "magestaff",
	level_range = {37, 50},
	color=colors.VIOLET,
	rarity = 250,
	desc = [[Archmage Tarelion travelled the world in his youth. But the world is not a nice place and it seems he had to run fast.]],
	cost = 400,
	material_level = 5,

	require = { stat = { mag=48 }, },
	modes = {"fire", "cold", "lightning", "arcane"},
	combat = {
		is_greater = true,
		dam = 30,
		apr = 4,
		dammod = {mag=1.5},
		damtype = DamageType.ARCANE,
	},
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 7, [Stats.STAT_MAG] = 8 },
		max_mana = 40,
		combat_spellpower = 40,
		combat_spellcrit = 25,
		inc_damage = { [DamageType.ARCANE] = 30, [DamageType.FIRE] = 30, [DamageType.COLD] = 30, [DamageType.LIGHTNING] = 30,  },
		silence_immune = 0.4,
		mana_on_crit = 12,
		talent_cd_reduction={
			[Talents.T_ICE_STORM] = 2,
			[Talents.T_FIREFLASH] = 2,
			[Talents.T_CHAIN_LIGHTNING] = 2,
			[Talents.T_ARCANE_VORTEX] = 2,
		},
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1,},
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "Spellblaze Echoes", color = colors.DARK_GREY, image = "object/artifact/amulet_spellblaze_echoes.png",
	unided_name = "deep black amulet",
	desc = [[This ancient charm still retains a distant echo of the destruction wrought by the Spellblaze]],
	level_range = {30, 39},
	rarity = 290,
	cost = 500,
	material_level = 4,

	wielder = {
		combat_armor = 6,
		combat_def = 6,
		combat_spellpower = 8,
		combat_spellcrit = 6,
		spellsurge_on_crit = 15,
	},
	max_power = 60, power_regen = 1,
	use_power = { name = "unleash a destructive wail", power = 60,
		use = function(self, who)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.PHYSICAL, 250 + who:getMag() * 3)
			game.logSeen(who, "%s uses the %s!", who.name:capitalize(), self:getName())
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {technique=true},
	unique = true,
	name = "Daneth's Neckguard", color = colors.STEEL_BLUE, image = "object/artifact/daneths_neckguard.png",
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
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Halfling" then
			local Talents = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder", "talents_types_mastery"}, { ["technique/battle-tactics"] = 0.2 })
			self:specialWearAdd({"wielder","combat_armor"}, 5)
			self:specialWearAdd({"wielder","combat_crit_reduction"}, 10)
			game.logPlayer(who, "#LIGHT_BLUE#You feel invincible!")
		end
	end,
}

newEntity{ base = "BASE_LONGBOW",
	power_source = {nature=true},
	name = "Thaloren-Tree Longbow", unided_name = "glowing elven-wood longbow", unique=true, image = "object/artifact/thaloren_tree_longbow.png",
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
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = 30, },
		lite = 1,
		inc_stats = { [Stats.STAT_DEX] = 10, [Stats.STAT_WIL] = 10,  },
		ranged_project={[DamageType.LIGHT] = 30},
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subrace == "Thalore" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","resists"}, { [engine.DamageType.DARKNESS] = 20, [DamageType.NATURE] = 20,} )
			self:specialWearAdd({"wielder","combat_def"}, 12)
			game.logPlayer(who, "#DARK_GREEN#You understand this bow-and its connection to nature-in a way few can.")
		end
	end,
}

-- Broken for its tier, Archery has very rarely had broken for its tier, its fine
newEntity{ base = "BASE_LONGBOW",
	power_source = {arcane=true, nature=true},
	name = "Corpsebow", unided_name = "rotting longbow", unique=true, image = "object/artifact/bow_corpsebow.png",
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
	wielder = {
		disease_immune = 0.5,
		ranged_project = {
			[DamageType.ITEM_BLIGHT_DISEASE] = 40,
			[DamageType.BLIGHT] = 20
		}, -- ITEM_BLIGHT_DISEASE doesn't do damage, so this is big
		inc_damage={ [DamageType.BLIGHT] = 40, }, -- Hacky method of scaling the damage on the active because the diseases do no DPS
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_CYST_BURST, level = 5, power = 10 },
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Undead" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"combat","ranged_project"}, {[DamageType.DRAINLIFE]=20})
			game.logPlayer(who, "#DARK_BLUE#You feel a kindred spirit in this bow...")
		end
	end,
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Spellblade", image = "object/artifact/weapon_spellblade.png",
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

-- 2H advantage:  Ridiculous item vs. Orc
newEntity{ base = "BASE_GREATSWORD",
	power_source = {nature=true, technique=true},
	unique = true,
	name = "Genocide",
	unided_name = "pitch black blade", image = "object/artifact/weapon_sword_genocide.png",
	level_range = {25, 35},
	color=colors.GRAY,
	rarity = 300,
	desc = [[Farian was King Toknor's captain, and fought by his side in the great Battle of Last Hope.  However, when he returned after the battle to find his hometown burnt in an orcish pyre, a madness overtook him.  The desire for vengeance made him quit the army and strike out on his own, lightly armoured and carrying nought but his sword.  Most thought him dead until the reports came back of a fell figure tearing through the orcish encampments, slaughtering all before him and mercilessly butchering the corpses after.  It is said his blade drank the blood of 100 orcs each day until finally all of Maj'Eyal was cleared of their presence.  When the final orc was slain and no more were to be found, Farian at the last turned the blade on himself and stuck it through his chest.  Those nearby said his body shook with convulsions as he did so, though they could not tell whether he was laughing or crying.]],
	cost = 400,
	require = { stat = { str=40, wil=20 }, },
	material_level = 3,
	combat = {
		dam = 42,
		apr = 4,
		physcrit = 18,
		dammod = {str=1.2},
		inc_damage_type = {["humanoid/orc"]=25},
	},
	wielder = {
		resists_actor_type = {["humanoid/orc"]=15},
		stamina_regen = 1,
		life_regen = 0.5,
		inc_stats = { [Stats.STAT_STR] = 7, [Stats.STAT_DEX] = 7, [Stats.STAT_CON] = 7 },
		esp = {["humanoid/orc"]=1},
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Bolbum's Big Knocker", image = "object/artifact/staff_bolbums_big_knocker.png",
	unided_name = "thick staff",
	level_range = {20, 35},
	color=colors.UMBER,
	rarity = 220,
	desc = [[A thick staff with a heavy knob on the end.  It was said to be used by the grand alchemist Bolbum in the Age of Allure.  Much renowned is the fear of his students for their master, and the high rate of cranial injuries amongst them.  Bolbum died with seven daggers in his back and his much-cursed staff went missing after.]],
	cost = 300,
	material_level = 3,

	require = { stat = { mag=38 }, },
	combat = {
		dam = 64,
		apr = 10,
		dammod = {mag=1.4},
		damtype = DamageType.PHYSICAL,
		melee_project={[DamageType.RANDOM_CONFUSION] = 10},
	},
	wielder = {
		combat_atk = 7,
		combat_spellpower = 12,
		combat_spellcrit = 18,
		inc_damage={
			[DamageType.PHYSICAL] = 20,
		},
		talents_types_mastery = {
			["spell/staff-combat"] = 0.2,
		}
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_CHANNEL_STAFF, level = 2, power = 9 },
}

newEntity{ base = "BASE_LITE",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Guidance", image = "object/artifact/guidance.png",
	unided_name = "a softly glowing crystal",
	level_range = {38, 50},
	color = colors.YELLOW,
	encumber = 1,
	rarity = 300,
	desc = [[Said to have once belonged to Inquisitor Marcus Dunn during the Spellhunt this fist sized quartz crystal glows constantly with a soft white light and was rumoured to be a great aid in meditation, helping focus the mind, body, and soul of the owner as well as protecting them from the foulest of magics.
It seems somebody well versed in antimagic could use it to its fullest potential.]],
	cost = 100,
	material_level = 5,

	wielder = {
		lite = 4,
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 6,},
		combat_physresist = 6,
		combat_mentalresist = 6,
		combat_spellresist = 6,
		talents_types_mastery = { ["wild-gift/call"] = 0.2, ["wild-gift/antimagic"] = 0.1, },
		resists_cap = { [DamageType.BLIGHT] = 10, },
		resists = { [DamageType.BLIGHT] = 20, },
	},
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 6, })
			self:specialWearAdd({"wielder","combat_physresist"}, 6)
			self:specialWearAdd({"wielder","combat_spellresist"}, 6)
			self:specialWearAdd({"wielder","combat_mentalresist"}, 6)
			game.logPlayer(who, "#LIGHT_BLUE#You feel a great hero guiding you!")
		end
	end,
}

newEntity{ base = "BASE_SLING",
	power_source = {technique=true},
	unique = true,
	name = "Eldoral Last Resort", image = "object/artifact/sling_eldoral_last_resort.png",
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
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = 4, [Stats.STAT_CUN] = 3,  },
		inc_damage={ [DamageType.PHYSICAL] = 15 },
		talent_cd_reduction={[Talents.T_STEADY_SHOT]=1, [Talents.T_EYE_SHOT]=2},
	},
}

newEntity{ base = "BASE_KNIFE",
	power_source = {technique=true},
	unique = true,
	name = "Orc Feller", image = "object/artifact/dagger_orc_feller.png",
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
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Halfling" then
			local Stats = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder","inc_stats"}, {  [Stats.STAT_CUN] = 6, [Stats.STAT_LCK] = 25, })
			game.logPlayer(who, "#LIGHT_BLUE#Herah's guile and luck is with you, her successor!")
		end
	end,
}

newEntity{ base = "BASE_MACE",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Nature's Vengeance", color = colors.BROWN, image = "object/artifact/mace_natures_vengeance.png",
	unided_name = "thick wooden mace",
	desc = [[This thick-set mace was used by the Spellhunter Vorlan, who crafted it from the wood of an ancient oak that was uprooted during the Spellblaze.  Many were the wizards and witches felled by this weapon, brought to justice for the crimes they committed against nature.]],
	level_range = {20, 34},
	rarity = 340,
	require = { stat = { str=42 } },
	cost = 350,
	metallic = false,
	material_level = 3,
	combat = {
		dam = 40,
		apr = 4,
		physcrit = 9,
		dammod = {str=1},
		melee_project={[DamageType.RANDOM_SILENCE] = 10, [DamageType.NATURE] = 18},
	},
	wielder = {combat_atk=6},

	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_RUSH, level = 3, power = 15 },
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","resists"}, { all = 4 })

			game.logPlayer(who, "#LIGHT_BLUE#You feel nature defending you.")
		end
	end,
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {psionic=true, technique=true},
	define_as = "GAUNTLETS_SCORPION",
	unique = true,
	name = "Fists of the Desert Scorpion", color = colors.STEEL_BLUE, image = "object/artifact/scorpion_gauntlets.png",
	unided_name = "viciously spiked gauntlets",
	desc = [[These wickedly spiked gauntlets belonged to an orc captain in the Age of Pyre who conquered the western sands, using them as a base to lay raids on Elvala to the south.  Known as The Scorpion, he seemed unconquerable in battle, able to pull enemies towards him with vicious mental force and lay down lethal blows on them.  Often a flurry of these yellow and black gauntlets would be the last thing great Shaloren mages would see before having the life crushed from them.

Finally The Scorpion was defeated by the alchemist Nessylia, who went to face the fiendish orc alone.  The captain pulled the elf towards him with a brutish cackle, but before he could batter the life from her flesh she tore off her robes, revealing eighty incendiary bombs strapped to her flesh.  With a spark from her fingers she triggered an explosion that could be seen for miles around.  To this day Nessylia is still remembered in song for the sacrifice of her immortal life to protect her people.]],
	level_range = {20, 40},
	rarity = 300,
	cost = 1000,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_WIL] = 3, [Stats.STAT_CUN] = 3, },
		inc_damage = { [DamageType.PHYSICAL] = 8 },
		combat_mindpower=3,
		combat_armor = 4,
		combat_def = 8,
		disarm_immune = 0.4,
		talents_types_mastery = { ["technique/grappling"] = 0.2},
		combat = {
			dam = 24,
			apr = 10,
			physcrit = 10,
			physspeed = 0.15,
			dammod = {dex=0.4, str=-0.6, cun=0.4,},
			damrange = 0.3,
			talent_on_hit = { T_BITE_POISON = {level=3, chance=20}, T_PERFECT_CONTROL = {level=1, chance=5}, T_QUICK_AS_THOUGHT = {level=3, chance=5}, T_IMPLODE = {level=1, chance=5} },
		},
	},
	max_power = 24, power_regen = 1,
	use_talent = { id = Talents.T_MINDHOOK, level = 4, power = 16 },
}

newEntity{ base = "BASE_CLOAK",
	power_source = {arcane=true},
	unique = true,
	name = "Wind's Whisper", image="object/artifact/cloak_winds_whisper.png",
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
		slow_projectiles = 20,
		projectile_evasion = 25,
	},
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_EVASION, level = 2, power = 50 },
}

newEntity{ base = "BASE_ROD",
	power_source = {arcane=true},
	unided_name = "glowing rod",
	name = "Gwai's Burninator", color=colors.LIGHT_RED, unique=true, image = "object/artifact/wand_gwais_burninator.png",
	desc = [[Gwai, a Pyromanceress that lived during the Spellhunt, was cornered by group of mage hunters. She fought to her last breath and is said to have killed at least ten people with this wand before she fell.]],
	cost = 600,
	rarity = 220,
	level_range = {25, 35},
	elec_proof = true,
	add_name = false,

	material_level = 3,

	max_power = 75, power_regen = 1,
	use_power = { name = "shoot a cone of fire", power = 50,
		use = function(self, who)
			local tg = {type="cone", range=0, radius=5}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, engine.DamageType.FIRE, 300 + who:getMag() * 2, {type="flame"})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {technique=true},
	unique = true,
	unided_name = "viciously sharp battle axe",
	name = "Drake's Bane", image = "object/artifact/axe_drakes_bane.png",
	color = colors.RED,
	desc = [[The killing of Kroltar, mightiest of wyrms, took seven months and the lives of 20,000 dwarven warriors.  Finally the beast was worn down and mastersmith Gruxim, standing atop the bodies of his fallen comrades, was able slit its throat with this axe crafted purely for the purpose of penetrating the wyrm's hide.]],
	require = { stat = { str=45 }, },
	rarity = 300,
	cost = 400,
	level_range = {20, 35},
	material_level = 3,
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
	name = "Blood-Letter", image = "object/artifact/weapon_axe_blood_letter.png",
	unided_name = "glacial hatchet",
	desc = [[A hand axe carved out of the most frozen parts of the northern wasteland.]],
	level_range = {25, 35},
	rarity = 235,
	require = { stat = { str=40, dex=24 }, },
	cost = 330,
	metallic = false,
	material_level = 3,
	wielder = {
		combat_armor = 20,
		resists_pen = {
			[DamageType.COLD] = 20,
		},
		iceblock_pierce=25,
	},
	combat = {
		dam = 33,
		apr = 4.5,
		physcrit = 7,
		dammod = {str=1},
		convert_damage = {
			[DamageType.ICE] = 50,
		},
		talent_on_hit = { [Talents.T_ICE_BREATH] = {level=2, chance=15} },
	},
}

newEntity{ base = "BASE_GEM", define_as = "GEM_TELOS",
	power_source = {arcane=true},
	unique = true,
	unided_name = "scintillating white crystal",
	name = "Telos's Staff Crystal", subtype = "multi-hued", image = "object/artifact/telos_staff_crystal.png",
	color = colors.WHITE,
	level_range = {35, 45},
	desc = [[A closer look at this pure white crystal reveals that it is really a plethora of colors swirling and scintillating.]],
	rarity = 240,
	identified = false,
	cost = 200,
	material_level = 5,
	carrier = {
		lite = 2,
	},
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 5, [Stats.STAT_CON] = 5, },
		lite = 2,
		confusion_immune = 0.3,
		fear_immune = 0.3,
		resists={[DamageType.MIND] = 30,},
	},
	imbue_powers = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 5, [Stats.STAT_CON] = 5, },
		lite = 2,
		confusion_immune = 0.3,
		fear_immune = 0.3,
		resists={[DamageType.MIND] = 30,},
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
				voice.modes = o.modes
				voice.flavor_name = o.flavor_name
				voice.combat = o.combat
				voice.combat.dam = math.floor(voice.combat.dam * 1.4)
				voice.combat.sentient = "telos"
				voice.wielder.inc_damage[voice.combat.damtype] = voice.combat.dam
				voice:identify(true)
				o:replaceWith(voice)
				who:sortInven()

				who.changed = true
				game.logPlayer(who, "You fix the crystal on the %s and create the %s.", oldname, o:getName{do_color=true})
			else
				game.logPlayer(who, "The fusing fails!")
			end
		end)
		return {id=true, used=true}
	end },
}

-- The staff that goes with the crystal above, it will not be generated randomly it is created by the crystal
newEntity{ base = "BASE_STAFF", define_as = "VOICE_TELOS",
	power_source = {arcane=true},
	unique = true,
	name = "Voice of Telos",
	unided_name = "scintillating white staff", image="object/artifact/staff_voice_of_telos.png",
	color = colors.VIOLET,
	rarity = false,
	desc = [[A closer look at this pure white staff reveals that it is really a plethora of colors swirling and scintillating.]],
	cost = 500,
	material_level = 5,

	require = { stat = { mag=45 }, },
	-- This is replaced by the creation process
	combat = { dam = 1, damtype = DamageType.ARCANE, },
	wielder = {
		combat_spellpower = 30,
		combat_spellcrit = 15,
		max_mana = 100,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 4 },
		lite = 1,
		inc_damage = {},
		damage_affinity = { [DamageType.ARCANE] = 5, [DamageType.BLIGHT] = 5, [DamageType.COLD] = 5, [DamageType.DARKNESS] = 5, [DamageType.ACID] = 5, [DamageType.LIGHT] = 5, [DamageType.LIGHTNING] = 5, [DamageType.FIRE] = 5, },
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1},
	},
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {nature=true},
	unique = true,
	name = "Rope Belt of the Thaloren", image = "object/artifact/rope_belt_of_the_thaloren.png",
	unided_name = "short length of rope",
	desc = [[The simplest of belts, worn for centuries by Nessilla Tantaelen as she tended to her people and forests. Some of her wisdom and power have settled permanently into its fibers.]],
	color = colors.LIGHT_RED,
	level_range = {20, 30},
	rarity = 200,
	cost = 450,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 7, [Stats.STAT_WIL] = 8, },
		combat_mindpower = 12,
		talents_types_mastery = { ["wild-gift/harmony"] = 0.2 },
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subrace == "Thalore" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","resists"}, { [engine.DamageType.MIND] = 20,} )
			self:specialWearAdd({"wielder","combat_mentalresist"}, 15)
			game.logPlayer(who, "#DARK_GREEN#Nessilla's belt seems to come alive as you put it on.")
		end
	end,
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {arcane=true},
	unique = true,
	name = "Neira's Memory", image = "object/artifact/neira_memory.png",
	unided_name = "crackling belt",
	desc = [[Ages ago this belt was worn by Linaniil herself in her youth, using its power she shielded herself from the Spellblaze rain of fire, but naught could she do for her sister Neira.]],
	color = colors.GOLD,
	level_range = {20, 30},
	rarity = 200,
	cost = 450,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 2, [Stats.STAT_WIL] = 5, },
		confusion_immune = 0.3,
		stun_immune = 0.3,
		mana_on_crit = 3,
	},
	max_power = 20, power_regen = 1,
	use_power = { name = "generate a personal shield", power = 20,
		use = function(self, who)
			who:setEffect(who.EFF_DAMAGE_SHIELD, 10, {power=100 + who:getMag(250)})
			game:playSoundNear(who, "talents/arcane")
			game.logSeen(who, "%s invokes the memory of Neira!", who.name:capitalize())
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Nature's Blessing", image = "object/artifact/armor_natures_blessing.png",
	unided_name = "supple leather armour entwined with willow bark",
	desc = [[Worn by Protector Ardon, who first formed the Ziguranth during the mage wars between the Humans and the Halflings.  This armour is infused with the powers of nature, and protected against the disruptive forces of magic.]],
	color = colors.BROWN,
	level_range = {15, 30},
	rarity = 350,
	require = { stat = { str=20 }, {wil=20} },
	cost = 350,
	material_level = 2,
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
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder","combat_spellresist"}, 20)
			game.logPlayer(who, "#DARK_GREEN#You feel especially blessed.")
		end
	end,
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Plate Armor of the King", image = "object/artifact/plate_armor_of_the_king.png",
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
		combat_armor = 30,
		stun_immune = 0.3,
		knockback_immune = 0.3,
		combat_mentalresist = 25,
		combat_spellresist = 25,
		combat_physresist = 15,
		lite = 1,
		fatigue = 26,
	},
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Witch-Bane", color = colors.LIGHT_STEEL_BLUE, image = "object/artifact/sword_witch_bane.png",
	unided_name = "an ivory handled voratun longsword",
	desc = [[A thin voratun blade with an ivory handle wrapped in purple cloth.  The weapon is nearly as legendary as its former owner, Marcus Dunn, and was thought to have been destroyed after Marcus was slain near the end of the Spellhunt.
It seems somebody well versed in antimagic could use it to its fullest potential.]],
	level_range = {38, 50},
	rarity = 250,
	require = { stat = { str=48 }, },
	cost = 650,
	material_level = 5,
	combat = {
		dam = 42,
		apr = 4,
		physcrit = 20,
		dammod = {str=1},
		melee_project = { [DamageType.ITEM_ANTIMAGIC_MANABURN] = 50 },
	},
	wielder = {
		talent_cd_reduction={
			[Talents.T_AURA_OF_SILENCE] = 2,
			[Talents.T_MANA_CLASH] = 2,
		},
		resists = {
			all = 15,
			[DamageType.PHYSICAL] = - 15,
			[DamageType.BLIGHT] = 15,
		},
	},
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"
			local Talents = require "engine.interface.ActorTalents"

			self:specialWearAdd({"combat", "talent_on_hit"}, { [Talents.T_MANA_CLASH] = {level=1, chance=25}  })
			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 6, })
			game.logPlayer(who, "#LIGHT_BLUE#You feel a great hero watching over you!")
		end
	end,
}

-- Channelers set
-- Note that this staff can not be channeled.  All of it's flavor is arcane, lets leave it arcane
newEntity{ base = "BASE_STAFF", define_as = "SET_STAFF_CHANNELERS",
	power_source = {arcane=true},
	unique = true,
	name = "Staff of Arcane Supremacy",
	unided_name = "silver-runed staff",
	flavor_name = "magestaff",
	level_range = {20, 40},
	color=colors.BLUE, image = "object/artifact/staff_of_arcane_supremacy.png",
	rarity = 300,
	desc = [[A long slender staff, made of ancient dragon-bone, with runes emblazoned all over its surface in bright silver.
It hums faintly, as if great power is locked within, yet alone it seems incomplete.]],
	cost = 200,
	material_level = 3,
	require = { stat = { mag=24 }, },
	combat = {
		dam = 20,
		apr = 4,
		dammod = {mag=1.5},
		damtype = DamageType.ARCANE,
	},
	wielder = {
		combat_spellpower = 20,
		inc_damage={
			[DamageType.ARCANE] = 20,
		},
		talent_cd_reduction = {
			[Talents.T_MANATHRUST] = 1,
		},
		talents_types_mastery = {
			["spell/arcane"]=0.2,
		},
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_ARCANE_SUPREMACY, level = 3, power = 20 },
	set_list = { {"define_as", "SET_HAT_CHANNELERS"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","max_mana"}, 100)
		game.logSeen(who, "#STEEL_BLUE#You feel a swell of arcane energy.")
	end,
}

newEntity{ base = "BASE_WIZARD_HAT", define_as = "SET_HAT_CHANNELERS",
	power_source = {arcane=true},
	unique = true,
	name = "Hat of Arcane Understanding",
	unided_name = "silver-runed hat",
	desc = [[A traditional pointed wizard's hat, made of fine purple elven-silk and decorated with bright silver runes. You sense it has been passed from ancient times, and has been born on the heads of great mages.
Touching the cloth you feel a sense of knowledge and power from bygone ages, yet it is partly sealed away, waiting for a trigger to release it.]],
	color = colors.BLUE, image = "object/artifact/wizard_hat_of_arcane_understanding.png",
	level_range = {20, 40},
	rarity = 300,
	cost = 100,
	material_level = 3,
	wielder = {
		combat_def = 2,
		mana_regen = 2,
		resists = {
			[DamageType.ARCANE] = 20,
		},
		talent_cd_reduction = {
			[Talents.T_DISRUPTION_SHIELD] = 10,
		},
		talents_types_mastery = {
			["spell/meta"]=0.2,
		},
	},
	max_power = 40, power_regen = 1,
	set_list = { {"define_as", "SET_STAFF_CHANNELERS"} },
	on_set_complete = function(self, who)
		local Talents = require "engine.interface.ActorTalents"
		self.use_talent = { id = Talents.T_METAFLOW, level = 3, power = 40 }
		game.party:learnLore("channelers-set")
	end,
	on_set_broken = function(self, who)
		self.use_talent = nil
		game.logPlayer(who, "#STEEL_BLUE#The arcane energies surrounding you dissipate.")
	end,
}

newEntity{ base = "BASE_AMULET", --Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Mirror Shards",
	unided_name = "mirror lined chain", image = "object/artifact/mirror_shards.png",
	desc = [[Said to have been created by a powerful mage after his home was destroyed by a mob following the Spellblaze. Though he fled, his possessions were crushed, burned, and smashed. When he returned to the ruins, he made this amulet from the remains of his shattered mirror.]],
	color = colors.LIGHT_RED,
	level_range = {18, 30},
	rarity = 220,
	cost = 350,
	material_level = 3,
	wielder = {
		inc_damage={
			[DamageType.LIGHT] = 12,
		},
		resists={
			[DamageType.LIGHT] = 25,
		},
		lite=1,
		on_melee_hit = {[DamageType.ITEM_LIGHT_BLIND]=30},
	},
	max_power = 24, power_regen = 1,
	use_power = { name = "create a reflective shield (50% reflection rate)", power = 24,
		use = function(self, who)
			who:setEffect(who.EFF_DAMAGE_SHIELD, 5, {power=150 + who:getMag(100)*2, reflect=50})
			game:playSoundNear(who, "talents/arcane")
			game.logSeen(who, "%s forges a reflective barrier!", who.name:capitalize())
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_CLOAK",
	power_source = {nature=true},
	unique = true,
	name = "Destala's Scales", image = "object/artifact/destalas_scales.png",
	unided_name = "green dragon-scale cloak",
	desc = [[This cloak is made from the scales of an infamous Venom Drake that terrorized the country side towards the end of the Age of Dusk. It was slain by a party led by Kestin Highfin, who had this cloak fashioned personally.]],
	level_range = {20, 30},
	rarity = 240,
	cost = 200,
	material_level = 3,
	wielder = {
		combat_def = 10,
		inc_stats = { [Stats.STAT_CUN] = 6,},
		inc_damage = { [DamageType.ACID] = 15 },
		resists_pen = { [DamageType.ACID] = 10 },
		talents_types_mastery = { ["wild-gift/venom-drake"] = 0.2, },
		combat_mindpower=6,
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_DISSOLVE, level = 2, power = 20 },
	talent_on_wild_gift = { {chance=10, talent=Talents.T_ACIDIC_SPRAY, level=2} },
}

newEntity{ base = "BASE_KNIFE", -- Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Spellblaze Shard", image = "object/artifact/spellblaze_shard.png",
	unided_name = "crystalline dagger",
	desc = [[This jagged crystal glows with an unnatural light. A strap of cloth is wrapped around one end, as a handle.]],
	level_range = {12, 25},
	rarity = 200,
	require = { stat = { dex=17 }, },
	cost = 250,
	metallic = false,
	material_level = 2,
	combat = {
		dam = 20,
		apr = 10,
		physcrit = 12,
		dammod = {dex=0.45,str=0.45,},
		melee_project={[DamageType.FIREBURN] = 10, [DamageType.BLIGHT] = 10,},
		lifesteal = 6,
		burst_on_crit = {
			[DamageType.CORRUPTED_BLOOD] = 20,
			[DamageType.FIRE] = 20,
		},
	},
	wielder = {
		inc_stats = {[Stats.STAT_MAG] = 5,},
		resists = {[DamageType.BLIGHT] = 10, [DamageType.FIRE] = 10},
	},
}

newEntity{ base = "BASE_KNIFE", --Razakai's idea, slightly modified
	power_source = {psionic=true},
	unique = true,
	name = "Mercy", image = "object/artifact/mercy.png",
	unided_name = "wickedly sharp dagger",
	desc = [[This dagger was used by a nameless healer during the Age of Dusk. The plagues that ravaged his town were beyond the ability of mortal man to treat, so he took to using his dagger to as an act of mercy when faced with hopeless patients. Despite his good intentions, it is now cursed with dark power, letting it kill in a single stroke against those already weakened.]],
	level_range = {30, 40},
	rarity = 250,
	require = { stat = { dex=42 }, },
	cost = 500,
	material_level = 4,
	combat = {
		dam = 35,
		apr = 9,
		physcrit = 15,
		dammod = {str=0.45, dex=0.55},
		special_on_hit = {desc="deals physical damage equal to 3% of the target's missing health", fct=function(combat, who, target)
			local tg = {type="ball", range=10, radius=0, selffire=false}
			who:project(tg, target.x, target.y, engine.DamageType.PHYSICAL, (target.max_life - target.life)*0.03)
		end},
	},
	wielder = {
		inc_stats = {[Stats.STAT_STR] = 6, [Stats.STAT_DEX] = 6,},
		combat_critical_power = 20,
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR", -- Thanks SageAcrin!
	power_source = {technique = true, nature = true},
	unique = true,
	name = "Thalore-Wood Cuirass", image = "object/artifact/thalore_wood_cuirass.png",
	unided_name = "thick wooden plate armour",
	desc = [[Expertly hewn from the bark of trees, this wooden armor provides excellent protection at a low weight.]],
	color = colors.WHITE,
	level_range = {8, 22},
	rarity = 220,
	require = { stat = { str=24 }, },
	cost = 300,
	material_level = 2,
	moddable_tile = "special/wooden_cuirass",
	moddable_tile_big = true,

	encumber = 12,
	metallic=false,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 3, [Stats.STAT_DEX] = 3, [Stats.STAT_CON] = 3,},
		combat_armor = 12,
		combat_def = 4,
		fatigue = 14,
		resists = {
			[DamageType.DARKNESS] = 18,
			[DamageType.COLD] = 18,
			[DamageType.NATURE] = 18,
		},
		healing_factor = 0.25,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subrace == "Thalore" then
			local Stats = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder","fatigue"}, -14)
			game.logPlayer(who, "#DARK_GREEN#The armor molds comfortably to one of its caretakers.")
		end
	end,
}