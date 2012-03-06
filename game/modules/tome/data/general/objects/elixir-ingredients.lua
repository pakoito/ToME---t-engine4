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


newEntity{ define_as = "TROLL_INTESTINE",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/troll_intestine.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "troll guts",
	name = "length of troll intestine",
	display = "&", color=colors.VIOLET,
	desc = [[A length of troll intestines. Fortunately, the troll appears to have eaten nothing in some time.]],
	alch = "Kindly empty it before returning.",
}

newEntity{ define_as = "SKELETON_MAGE_SKULL",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/skeleton_mage_skull.png",
	unided_name = "battered skull",
	name = "skeleton mage skull",
	level_range = {50, 50},
	display = "*", color=colors.WHITE,
	encumber = 0,
	desc = [[The skull of a skeleton mage. The eyes have stopped glowing... for now.]],
	alch = "If the eyes are still glowing, please bash it around a bit until they fade. I'll not have another one of those coming alive and wreaking havoc in my lab.",
}

newEntity{ define_as = "RITCH_STINGER",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/ritch_stinger.png",
	unided_name = "giant stinger",
	name = "ritch stinger",
	level_range = {50, 50},
	display = "/", color=colors.GREEN,
	encumber = 0,
	desc = [[A ritch stinger, still glistening with venom.]],
	alch = "Keep as much venom in it as possible.",
}

newEntity{ define_as = "ORC_HEART",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/orc_heart.png",
	unided_name = "heart",
	name = "orc heart",
	level_range = {50, 50},
	display = "*", color=colors.RED,
	encumber = 0,
	desc = [[The heart of an orc. Perhaps surprisingly, it isn't green.]],
	alch = "If you can fetch me a still-beating orc heart, that would be even better. But you don't look like a master necromancer to me.",
}

newEntity{ define_as = "NAGA_TONGUE",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/naga_tongue.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "naga tongue",
	name = "naga tongue",
	display = "-", color=colors.RED,
	desc = [[A severed naga tongue. It reeks of brine.]],
	alch = "Best results occur with tongues never tainted by profanity, so if you happen to know any saintly nagas...",
}

newEntity{ define_as = "GREATER_DEMON_BILE",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/phial_demon_blood.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "demon bile",
	name = "vial of greater demon bile",
	display = "~", color=colors.GREEN,
	desc = [[A vial of greater demon bile. It hurts your sinuses even with the vial's stopper firmly in place.]],
	alch = "Don't drink it, even if it tells you to.",
}

newEntity{ define_as = "BONE_GOLEM_DUST",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/pouch_bone_giant_dust.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "bone giant dust",
	name = "pouch of bone giant dust",
	display = "~", color=colors.WHITE,
	desc = [[Once the magics animating the bone giant fled, its remains crumbled to dust. It might be your imagination, but it looks like the dust occasionally stirs on its own.]],
	alch = "Never, ever to be confused with garlic powder. Trust me.",
}

newEntity{ define_as = "FROST_ANT_STINGER",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/ice_ant_stinger.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "stinger",
	name = "ice ant stinger",
	display = "-", color=colors.WHITE,
	desc = [[Wickedly sharp and still freezing cold.]],
	alch = "If you've the means to eliminate the little venom problem, these make miraculous instant drink-chilling straws.",
}

newEntity{ define_as = "MINOTAUR_NOSE",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/minotaur_nose.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "minotaur nose",
	name = "minotaur nose",
	display = "*", color=colors.GREY,
	desc = [[The severed front half of a minotaur snout, ring and all.]],
	alch = "You'll need to find one with a ring, preferably an expensive one.",
}

newEntity{ define_as = "ELDER_VAMPIRE_BLOOD",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/vial_elder_vampire_blood.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "black blood",
	name = "vial of elder vampire blood",
	display = "~", color=colors.GREY,
	desc = [[Thick, clotted, and foul. The vial is cold to the touch.]],
	alch = "Once you've gotten it, cross some moving water on your way back.",
}

newEntity{ define_as = "MULTIHUED_WYRM_SCALE",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/dragon_scale_multihued.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "shimmering scale",
	name = "multi-hued wyrm scale",
	display = "~", color=colors.VIOLET,
	desc = [[Beautiful and nearly impregnable. Separating it from the dragon must have been hard work.]],
	alch = "If you think collecting one of these is hard, try liquefying one.",
}

newEntity{ define_as = "SPIDER_SPINNERET",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/spider_spinnarets.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "spinneret",
	name = "giant spider spinneret",
	display = "*", color=colors.GREEN,
	desc = [[An ugly, ripped-out chunk of giant spider. Bits of silk protrude from an orifice.]],
	alch = "The spiders in your barn won't do. You'll know a giant spider when you see one, though they're rare in Maj'Eyal.",
}

newEntity{ define_as = "HONEY_TREE_ROOT",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/honey_tree_root.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "dirty root",
	name = "honey tree root",
	display = "~", color=colors.TAN,
	desc = [[The severed end of one of a honey tree's roots. It wriggles around occasionally, seemingly unwilling to admit that it's dead... and a *plant*.]],
	alch = "Keep a firm grip on it. These things will dig themselves right back into the ground if you drop them.",
}

newEntity{ define_as = "BLOATED_HORROR_HEART",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/bloated_horror_heart.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "heart",
	name = "bloated horror heart",
	display = "*", color=colors.GREY,
	desc = [[Diseased-looking and reeking. It seems to be decaying as you watch.]],
	alch = "Don't worry if it dissolves. Just don't get any on you.",
}

newEntity{ define_as = "ELECTRIC_EEL_TAIL",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/electric_eel_tail.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "eel tail",
	name = "electric eel tail",
	display = "~", color=colors.BLUE,
	desc = [[Slimy, wriggling, and crackling with electricity.]],
	alch = "I know, I know. Where does the eel stop and the tail start? It doesn't much matter. The last ten inches or so should do nicely.",
}

newEntity{ define_as = "SQUID_INK",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/vial_squid_ink.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "black liquid",
	name = "vial of squid ink",
	display = "~", color=colors.VIOLET,
	desc = [[Thick, black and opaque.]],
	alch = "However annoying this will be for you to gather, I promise that the reek it produces in my lab will prove even more annoying.",
}

newEntity{ define_as = "BEAR_PAW",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/bear_paw.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "large, clawed paw",
	name = "bear paw",
	display = "*", color=colors.TAN,
	desc = [[Large and hairy with flesh-rending claws. It smells slightly of fish.]],
	alch = "You'd think I could get one of these from a local hunter, but they've had no luck. Don't get eaten.",
}

newEntity{ define_as = "ICE_WYRM_TOOTH",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/frost_wyrm_tooth.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "tooth",
	name = "ice wyrm tooth",
	display = "/", color=colors.WHITE,
	desc = [[This tooth has been blunted with age, but still looks more than capable of doing its job.]],
	alch = "Ice Wyrms lose teeth fairly often, so you might get lucky and not have to do battle with one. But dress warm just in case.",
}

newEntity{ define_as = "RED_CRYSTAL_SHARD",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/red_crystal_shard.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "red crystal shard",
	name = "red crystal shard",
	display = "/", color=colors.RED,
	desc = [[Tiny flames still dance etherally inside this transparent crystal, though its heat seems to have faded... you hope.]],
	alch = "I hear these can be found in a cave near Elvala. I also hear that they can cause you to spontaneously combust, so no need to explain if you come back hideously scarred.",
}

newEntity{ define_as = "FIRE_WYRM_SALIVA",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/vial_fire_wyrm_saliva.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "wyrm saliva",
	name = "vial of fire wyrm saliva",
	display = "~", color=colors.RED,
	desc = [[Clear and slightly thicker than water. It froths when shaken.]],
	alch = "Keep this stuff well away from your campfire unless you want me to have to find a new, more alive adventurer.",
}

newEntity{ define_as = "GHOUL_FLESH",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/ghoul_flesh.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "chunk of rotten flesh",
	name = "chunk of ghoul flesh",
	display = "*", color=colors.TAN,
	desc = [[Rotten and reeking. It still twitches occasionally.]],
	alch = "Unfortunately for you, the chunks that regularly fall off ghouls won't do. I need one freshly carved off.",
}

newEntity{ define_as = "MUMMY_BONE",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/mummified_bone.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "dry, flesh-encrusted bone",
	name = "mummified bone",
	display = "-", color=colors.WHITE,
	desc = [[Bits of dry flesh still cling to this ancient bone.]],
	alch = "That is, a bone from a corpse that's undergone mummification. Actually, any bit of the body would do, but the bones are the only parts you're certain to find when you kick a mummy apart. I recommend finding one that doesn't apply curses.",
}

newEntity{ define_as = "SANDWORM_TOOTH",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/sandworm_tooth.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "small, pointed tooth",
	name = "sandworm tooth",
	display = "/", color=colors.GREY,
	desc = [[Tiny, dark grey, and wickedly sharp. It looks more like rock than bone.]],
	alch = "Yes, sandworms have teeth. They're just very small and well back from where you're ever likely to see them and live.",
}

newEntity{ define_as = "BLACK_MAMBA_HEAD",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/black_mamba_head.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "snake head",
	name = "black mamba head",
	display = "*", color=colors.GREY,
	desc = [[Unlike the rest of the black mamba, the severed head isn't moving.]],
	alch = "If you get bitten, I can save your life if you still manage to bring back the head... and if it happens within about a minute from my door. Good luck.",
}

newEntity{ define_as = "SNOW_GIANT_KIDNEY",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/snow_giant_kidney.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "kidney",
	name = "snow giant kidney",
	display = "*", color=colors.VIOLET,
	desc = [[As unpleasant-looking as any exposed organ.]],
	alch = "I suggest not killing the snow giant by impaling it through the kidneys. You'll just have to find another.",
}

newEntity{ define_as = "STORM_WYRM_CLAW",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/storm_wyrm_claw.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "claw",
	name = "storm wyrm claw",
	display = "/", color=colors.BLUE,
	desc = [[Bluish and wickedly sharp. It makes your arm hair stand on end.]],
	alch = "I recommend severing one of dewclaws. They're smaller and easier to remove, but they've never been blunted by use, so be careful you don't poke yourself. Oh yes, and don't get eaten.",
}

newEntity{ define_as = "GREEN_WORM",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/green_worm.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "dead green worm",
	name = "green worm",
	display = "~", color=colors.GREEN,
	desc = [[A dead green worm, painstakingly separated from its tangle of companions.]],
	alch = "Try to get any knots out before returning. Wear gloves.",
}

newEntity{ define_as = "WIGHT_ECTOPLASM",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/vial_wight_ectoplasm.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "viscous slime",
	name = "vial of wight ectoplasm",
	display = "*", color=colors.GREEN,
	desc = [[Cloudy and thick. Only by bottling it can you prevent it from evaporating within minutes.]],
	alch = "If you ingest any of this, never mind coming back here. Please.",
}

newEntity{ define_as = "XORN_FRAGMENT",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/xorn_fragment.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "chunk of stone",
	name = "xorn fragment",
	display = "*", color=colors.TAN,
	desc = [[Looks much like any other rock, though this one was recently sentient and trying to murder you.]],
	alch = "Avoid fragments that contained the xorn's eyes. You've no idea how unpleasant it is being watched by your ingredients.",
}

newEntity{ define_as = "WARG_CLAW",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/warg_claw.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "claw",
	name = "warg claw",
	display = "/", color=colors.TAN,
	desc = [[Unpleasantly large and sharp for a canine's claw.]],
	alch = "My usual ingredient gatherers draw the line at hunting wargs. Feel free to mock them on your way back.",
}

newEntity{ define_as = "FAEROS_ASH",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/pharao_ash.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "ash",
	name = "pouch of faeros ash",
	display = "*", color=colors.GREY,
	desc = [[Unremarkable grey ash.]],
	alch = "They're creatures of pure flame, and likely of extraplanar origin, but the ash of objects consumed by their fire has remarkable properties.",
}

newEntity{ define_as = "WRETCHLING_EYE",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/wretchling_eyeball.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "eyeball",
	name = "wretchling eyeball",
	display = "*", color=colors.WHITE,
	desc = [[Small and bloodshot. Its dead gaze still burns your skin.]],
	alch = "Evil little things, wretchlings. Feel free to kill as many as you can, though I just need the one intact eyeball.",
}

newEntity{ define_as = "FAERLHING_FANG",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/faerlhing_fang.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "fang",
	name = "faerlhing fang",
	display = "/", color=colors.GREEN,
	desc = [[It still drips venom and crackles with magical energy.]],
	alch = "I've lost a number of adventurers to this one, but I'm sure you'll be fine.",
}

newEntity{ define_as = "VAMPIRE_LORD_FANG",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/vampire_lord_fang.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "fang",
	name = "vampire lord fang",
	display = "/", color=colors.WHITE,
	desc = [[Brilliantly white, but surrounded by blackest magic.]],
	alch = "You should definitely consider not pricking yourself with it.",
}

newEntity{ define_as = "HUMMERHORN_WING",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/hummerhorn_wing.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "translucent insect wing",
	name = "hummerhorn wing",
	display = "~", color=colors.VIOLET,
	desc = [[Translucent and delicate-looking, but surprisingly durable.]],
	alch = "If you've not encountered hummerhorns before, they're like wasps, only gigantic and lethal.",
}

newEntity{ define_as = "LUMINOUS_HORROR_DUST",
	quest=true, identified=true, no_unique_lore=true,
	type = "misc", subtype="ingredient", image = "object/pouch_luminous_horror_dust.png",
	level_range = {50, 50},
	encumber = 0,
	unided_name = "glowing dust",
	name = "pouch of luminous horror dust",
	display = "*", color=colors.YELLOW,
	desc = [[Weightless and glowing; not your usual dust.]],
	alch = "Not to be confused with radiant horrors. If you encounter the latter, then I suppose there are always more adventurers.",
}
