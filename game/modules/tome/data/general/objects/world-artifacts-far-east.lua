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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- This one starts a quest it has a level and rarity so it can drop randomly, but there are places where it is more likely to appear
newEntity{ base = "BASE_SCROLL", define_as = "JEWELER_TOME", subtype="tome", no_unique_lore=true,
	unique = true, quest=true,
	unided_name = "ancient tome",
	name = "Ancient Tome titled 'Gems and their uses'", image = "object/artifact/ancient_tome_gems_and_their_uses.png",
	level_range = {30, 40}, rarity = 120,
	color = colors.VIOLET,
	fire_proof = true,
	not_in_stores = true,

	on_pickup = function(self, who)
		if who == game.player then
			self:identify(true)
			who:grantQuest("master-jeweler")
		end
	end,
}

-- Not a random drop, used by the quest started above
newEntity{ base = "BASE_SCROLL", define_as = "JEWELER_SUMMON", subtype="tome", no_unique_lore=true,
	power_source = {unknown=true},
	unique = true, quest=true, identified=true,
	name = "Scroll of Summoning (Limmir the Jeweler)",
	color = colors.VIOLET,
	fire_proof = true,

	max_power = 1, power_regen = 1,
	use_power = { name = "summon Limmir the jeweler at the center of the lake of the moon", power = 1,
		use = function(self, who) who:hasQuest("master-jeweler"):summon_limmir(who) return {id=true, used=true} end
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "Pendent of the Sun and Moons", color = colors.LIGHT_SLATE, image = "object/artifact/amulet_pendant_of_sun_and_the_moon.png",
	unided_name = "a gray and gold pendent",
	desc = [[This small pendent depicts a hematite moon eclipsing a golden sun and according to legend was worn by one of the Sunwall's founders.]],
	level_range = {35, 45},
	rarity = 300,
	cost = 200,
	material_level = 4,
	wielder = {
		combat_spellpower = 8,
		combat_spellcrit = 5,
		inc_damage = { [DamageType.LIGHT]= 8,[DamageType.DARKNESS]= 8 },
		resists = { [DamageType.LIGHT]= 10, [DamageType.DARKNESS]= 10 },
		resists_cap = { [DamageType.LIGHT]= 5, [DamageType.DARKNESS]= 5 },
		resists_pen = { [DamageType.LIGHT]= 15, [DamageType.DARKNESS]= 15 },
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_CIRCLE_OF_SANCTITY, level = 3, power = 30 },
}

newEntity{ base = "BASE_SHIELD",
	power_source = {arcane=true},
	unique = true,
	unided_name = "shimmering gold shield",
	name = "Unsetting Sun", image = "object/artifact/shield_unsetting_sun.png",
	desc = [[When Elmio Panason, captain of the Vanguard, first sought shelter for his shipwrecked crew, he reflected the last rays of the setting sun off his shield.  Where the beam hit they rested and built the settlement that would become the Sunwall.  In the dark days that followed the shield became a symbol of hope for a better future.]],
	color = colors.YELLOW,
	rarity = 300,
	level_range = {35, 45},
	require = { stat = { str=40 }, },
	cost = 400,
	material_level = 5,
	special_combat = {
		dam = 50,
		block = 280,
		physcrit = 4.5,
		dammod = {str=1},
		damtype = DamageType.LIGHT,
	},
	wielder = {
		lite = 2,
		combat_armor = 9,
		combat_def = 16,
		combat_def_ranged = 17,
		fatigue = 14,
		combat_spellresist = 19,
		resists = {[DamageType.BLIGHT] = 30, [DamageType.DARKNESS] = 30},
		learn_talent = { [Talents.T_BLOCK] = 5, },
	},
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	power_source = {arcane=true},
	unique = true,
	name = "Scorched Boots", image = "object/artifact/scorched_boots.png",
	unided_name = "pair of blackened boots",
	desc = [[The master blood mage Ru'Khan was the first orc to experiment with the power of the Sher'Tul farportals in the Age of Pyre.  However, that first experiment was not particularly successful, and after the explosion of energy all that could be found of Ru'Khan was a pair of scorched boots.]],
	color = colors.DARK_GRAY,
	level_range = {30, 40},
	rarity = 250,
	cost = 200,
	material_level = 5,
	wielder = {
		combat_armor = 4,
		combat_def = 4,
		fatigue = 8,
		combat_spellpower = 13,
		inc_damage = { [DamageType.BLIGHT] = 15 },
	},
}

newEntity{ base = "BASE_GEM",
	power_source = {arcane=true},
	unique = true,
	unided_name = "unearthly black stone",
	name = "Goedalath Rock", subtype = "black", image = "object/artifact/goedalath_rock.png",
	color = colors.PURPLE,
	level_range = {42, 50},
	desc = [[A small rock that seems from beyond this world, vibrating with a fierce energy.  It feels warped and terrible and evil... and yet oh so powerful.]],
	rarity = 300,
	cost = 300,
	material_level = 5,
	carrier = {
		on_melee_hit = {[DamageType.HEAL] = 34},
		life_regen = -2,
		lite = -2,
		combat_mentalresist = -18,
		healing_factor = -0.5,
	},
	imbue_powers = {
		combat_dam = 12,
		combat_spellpower = 16,
		see_invisible = 14,
		infravision = 3,
		inc_damage = {all = 9},
		inc_damage_type = {demon = 20},
		esp = {["demon/major"]=1, ["demon/minor"]=1},
		on_melee_hit = {[DamageType.DARKNESS] = 34},
		healing_factor = 0.5,
	},
}

newEntity{ base = "BASE_CLOAK",
	power_source = {arcane=true}, define_as = "THREADS_FATE",
	unique = true,
	name = "Threads of Fate", image = "object/artifact/cloak_threads_of_fate.png",
	unided_name = "a shimmering white cloak",
	desc = [[Untouched by the ravages of time, this fine spun white cloak appears to be crafted of an otherworldly material that shifts and shimmers in the light.]],
	level_range = {45, 50},
	color = colors.WHITE,
	rarity = 500,
	cost = 300,
	material_level = 5,

	wielder = {
		combat_def = 10,
		combat_spellpower = 8,
		confusion_immune = 0.4,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_WIL] = 6, [Stats.STAT_LCK] = 10, },

		inc_damage = { [DamageType.TEMPORAL]= 10 },
		resists_cap = { [DamageType.TEMPORAL] = 10, },
		resists = { [DamageType.TEMPORAL] = 20, },
		combat_physresist = 20,
		combat_mentalresist = 20,
		combat_spellresist = 20,

		talents_types_mastery = {
			["chronomancy/timeline-threading"] = 0.1,
			["chronomancy/chronomancy"] = 0.1,
			["spell/divination"] = 0.1,
		},
	},

	max_power = 1000, power_regen = 1,
	use_talent = { id = Talents.T_SEE_THE_THREADS, level = 1, power = 1000 },
}

newEntity{ base = "BASE_LONGSWORD", define_as = "BLOODEDGE",
	power_source = {arcane=true},
	unique = true,
	name = "Blood-Edge", image = "object/artifact/sword_blood_edge.png",
	unided_name = "red crystalline sword",
	level_range = {35, 42},
	color=colors.RED,
	rarity = 270,
	desc = [[This deep red sword weeps blood continuously. It was born in the labs of the orcish corrupter Hurik, who sought to make a crystal that would house his soul after death. But his plans were disrupted by a band of sun paladins, and though most died purging his keep of dread minions, their leader Raasul fought through to Hurik's lab, sword in hand. There the two did battle, blade against blood magic, till both fell to the floor with weeping wounds. The orc with his last strength crawled towards his fashioned phylactery, hoping to save himself, but Raasul saw his plans and struck the crystal with his light-bathed sword. It shattered, and in the sudden impulse of energies the steel, crystal and blood were fused into one.
Now the broken fragments of Raasul's soul are trapped in this terrible artifact, his mind warped beyond all sanity by decades of imprisonment. Only the taste of blood calls him forth, his soul stealing the lifeblood of others to take on physical form again, that he may thrash and wail against the living.]],
	cost = 1000,
	require = { stat = { mag=20, str=32,}, },
	material_level = 5,
	wielder = {
		esp = {["undead/blood"]=1,},
		combat_spellpower = 12,
		combat_spellcrit = 4,
		inc_damage={
			[DamageType.PHYSICAL] = 12,
			[DamageType.BLIGHT] = 12,
		},
		max_vim = 20,
	},

	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_BLEEDING_EDGE, level = 4, power = 30 },
	combat = {
		dam = 38,
		apr = 4,
		physcrit = 5,
		dammod = {str=0.5, mag=0.5},
		convert_damage = {[DamageType.BLIGHT] = 50},

		special_on_hit = {desc="15% chance to animate a bleeding foe's blood", fct=function(combat, who, target)
			if not rng.percent(15) then return end
			local cut = false

			-- Go through all timed effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.cut then
					cut = true
				end
			end

			if not (cut) then return end

			local tg = {type="hit", range=1}
			who:project(tg, target.x, target.y, engine.DamageType.DRAIN_VIM, 80)

			local x, y = util.findFreeGrid(target.x, target.y, 5, true, {[engine.Map.ACTOR]=true})
			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "undead", subtype = "blood",
				display = "L",
				name = "animated blood", color=colors.RED,
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_lich_blood_lich.png", display_h=1, display_y=0}}},
				desc = "A haze of blood, vibrant and pulsing through the air, possessed by a warped and cracked soul. Every now and then a scream or wail of agony garbles through it, telling of the mindless suffering undergone by its possessor.",
				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, },
				rank = 3,
				life_rating = 10, exp_worth = 0,
				max_vim=200,
				max_life = resolvers.rngavg(50,90),
				infravision = 20,
				autolevel = "dexmage",
				ai = "summoned", ai_real = "tactical", ai_state = { talent_in=2, ally_compassion=10},
				stats = { str=15, dex=18, mag=18, wil=15, con=10, cun=18 },
				level_range = {1, nil}, exp_worth = 0,
				silent_levelup = true,
				combat_armor = 0, combat_def = 24,
				combat = { dam=resolvers.rngavg(10,13), atk=15, apr=15, dammod={mag=0.5, dex=0.5}, damtype=engine.DamageType.BLIGHT, },

				resists = { [engine.DamageType.BLIGHT] = 100, [engine.DamageType.NATURE] = -100, },

				negative_status_effect_immune = 1,

				on_melee_hit = {[engine.DamageType.DRAINLIFE]=resolvers.mbonus(10, 30)},
				melee_project = {[engine.DamageType.DRAINLIFE]=resolvers.mbonus(10, 30)},

				resolvers.talents{
					[who.T_WEAPON_COMBAT]={base=1, every=7, max=10},
					[who.T_EVASION]={base=3, every=8, max=7},

					[who.T_BLOOD_SPRAY]={base=1, every=6, max = 10},
					[who.T_BLOOD_GRASP]={base=1, every=5, max = 9},
					[who.T_BLOOD_BOIL]={base=1, every=7, max = 7},
					[who.T_BLOOD_FURY]={base=1, every=8, max = 6},
				},
				resolvers.sustains_at_birth(),
				faction = who.faction,
				summoner = who, summoner_gain_exp=true,
				summon_time = 7,
			}

			m:resolve()
			game.zone:addEntity(game.level, m, "actor", x, y)
			m.remove_from_party_on_death = true,
			game.party:addMember(m, {
				control=false,
				type="summon",
				title="Summon",
				orders = {target=true, leash=true, anchor=true, talents=true},
			})

			game.logSeen(who, "#GOLD#As the blade touches %s's spilt blood, the blood rises, animated!", target.name:capitalize())
			if who:knowTalent(who.T_VIM_POOL) then
				game.logSeen(who, "#GOLD#%s draws power from the spilt blood!", who.name:capitalize())
			end

		end},
	},
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Dawn's Blade",
	unided_name = "shining longsword",
	level_range = {35, 42},
	color=colors.YELLOW, image = "object/artifact/dawn_blade.png",
	rarity = 260,
	desc = [[Said to have been forged in the earliest days of the Sunwall, this longsword shines with the light of daybreak, capable of banishing all shadows.]],
	cost = 1000,
	require = { stat = { mag=18, str=35,}, },
	material_level = 5,
	wielder = {
		combat_spellpower = 10,
		combat_spellcrit = 4,
		inc_damage={
			[DamageType.LIGHT] = 18,
		},
		resists_pen={
			[DamageType.LIGHT] = 20,
		},
		talents_types_mastery = {
			["celestial/sun"] = 0.2,
		},
		talent_cd_reduction= {
			[Talents.T_HEALING_LIGHT] = 2,
			[Talents.T_BARRIER] = 2,
			[Talents.T_SUN_FLARE] = 2,
		},
		lite=2,
	},
	max_power = 40, power_regen = 1,
	use_power = { name = "invoke dawn", power = 40,
		use = function(self, who)
			local radius = 4
			local dam = (75 + who:getMag()*2)
			local blast = {type="ball", range=0, radius=5, selffire=false}
			who:project(blast, who.x, who.y, engine.DamageType.LIGHT, dam)
			game.level.map:particleEmitter(who.x, who.y, blast.radius, "sunburst", {radius=blast.radius})
			who:project({type="ball", range=0, radius=10}, who.x, who.y, engine.DamageType.LITE, 100)
			game:playSoundNear(self, "talents/fireflash")
			game.logSeen(who, "%s raises %s and sends out a burst of light!", who.name:capitalize(), self:getName())
			return {id=true, used=true}
		end
	},
	combat = {
		dam = 42,
		apr = 4,
		physcrit = 5,
		dammod = {str=0.75, mag=0.25},
		convert_damage = {[DamageType.LIGHT] = 30},
		inc_damage_type={
			undead=25,
			demon=25,
		},
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "Zemekkys' Broken Hourglass", color = colors.WHITE,
	unided_name = "a broken hourglass", image="object/artifact/amulet_zemekkys_broken_hourglass.png",
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
		spell_cooldown_reduction = 0.1,
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_WORMHOLE, level = 2, power = 60 },
}

newEntity{ base = "BASE_KNIFE", define_as = "MANDIBLE_UNGOLMOR",
	power_source = {nature=true},
	unique = true,
	name = "Mandible of Ungolmor", image = "object/artifact/dagger_life_drinker.png",
	unided_name = "curved, serrated black dagger",
	desc = [[This obsidian-crafted, curved blade is studded with the deadly fangs of the Ungolmor. It seems to drain light from the world around it.]],
	level_range = {40, 50},
	rarity = 270,
	require = { stat = { cun=38 }, },
	cost = 650,
	material_level = 5,
	combat = {
		dam = 40,
		apr = 12,
		physcrit = 22,
		dammod = {cun=0.30, str=0.35, dex=0.35},
		convert_damage ={[DamageType.DARKNESS] = 30},
		special_on_crit = {desc="inflicts pinning spydric poison upon the target", fct=function(combat, who, target)
			if target:canBe("poison") then
				local tg = {type="hit", range=1}
				local x, y = who:getTarget(tg)
				who:project(tg, target.x, target.y, engine.DamageType.SPYDRIC_POISON, {src=who, dam=30, dur=3})
			end
		end},
	},
	wielder = {
		inc_damage={[DamageType.NATURE] = 30, [DamageType.DARKNESS] = 20,},
		inc_stats = {[Stats.STAT_CUN] = 8, [Stats.STAT_DEX] = 4,},
		combat_armor = 5,
		combat_armor_hardiness = 5,
		lite = -2,
	},
	max_power = 40, power_regen = 1,
	use_talent = { id = Talents.T_CREEPING_DARKNESS, level = 3, power = 25 },
}

newEntity{ base = "BASE_KNIFE", define_as = "KINETIC_SPIKE",
	power_source = {psionic=true},
	unique = true,
	name = "Kinetic Spike", image = "object/artifact/dagger_life_drinker.png",
	unided_name = "bladeless hilt",
	desc = [[A simple, rudely crafted stone hilt, this object manifests a blade of wavering, nearly invisible force, like a heat haze, as you grasp it. Despite its simple appearance, it is capable of shearing through solid granite, in the hands of those with the necessary mental fortitude to use it properly.]],
	level_range = {42, 50},
	rarity = 310,
	require = { stat = { wil=42 }, },
	cost = 450,
	material_level = 5,
	combat = {
		dam = 38,
		apr = 40, -- Hard to imagine much being harder to stop with armor.
		physcrit = 10,
		dammod = {wil=0.30, str=0.30, dex=0.40},
	},
	wielder = {
		combat_atk = 8,
		combat_dam = 15,
		resists_pen = {[DamageType.PHYSICAL] = 30},
	},
	max_power = 10, power_regen = 1,
	use_power = { name = "fires a bolt of kinetic force, doing 150%% weapon damage", power = 10,
		use = function(self, who)
			local tg = {type="bolt", range=8}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			local _ _, x, y = who:canProject(tg, x, y)
			local target = game.level.map(x, y, engine.Map.ACTOR)
			if target then
				who:attackTarget(target, engine.DamageType.PHYSICAL, 1.5, true)
			game.logSeen(who, "The %s fires a bolt of kinetic force!", self:getName())
			else
				return
			end
			return {id=true, used=true}
		end
	},
}
