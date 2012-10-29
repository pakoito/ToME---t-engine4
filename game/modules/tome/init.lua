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

name = "T.o.M.E"
long_name = "Tales of Maj'Eyal: Age of Ascendancy"
short_name = "tome"
author = { "DarkGod", "darkgod@te4.org" }
homepage = "http://te4.org/"
version = {0,9,43}
engine = {0,9,43,"te4"}
description = [[
Welcome to Maj'Eyal.

This is the Age of Ascendancy. After over ten thousand years of strife, pain and chaos the known world is at last at relative peace.
The last effects of the #FF0000#Spellblaze#WHITE# have been tamed. The land slowly heals itself and the civilisations rebuild themselves after the Age of Pyre.

It has been one hundred and twenty-two years since the Allied Kingdoms were established under the rule of #14fffc#Toknor#ffffff# and his wife #14fffc#Mirvenia#ffffff#.
Together they ruled the kingdoms with fairness and brought prosperity to both Halflings and Humans.
The King died of old age fourteen years ago, and his son #14fffc#Tolak#ffffff# is now King.

The Elven kingdoms are quiet. The Shaloren Elves in their home of Elvala are trying to make the world forget about their role in the Spellblaze and are living happy lives under the leadership of #14fffc#Aranion Gayaeil#ffffff#.
The Thaloren Elves keep to their ancient tradition of living in the woods, ruled as always by #14fffc#Nessilla Tantaelen#ffffff# the wise.

The Dwarves of the Iron Throne have maintained a careful trade relationship with the Allied Kingdoms for nearly one hundred years, yet not much is known about them, not even their leader's name.

While the people of Maj'Eyal know that the mages helped put an end to the terrors of the Spellblaze, they also did not forget that it was magic that started those events. As such, mages are still shunned from society, if not outright hunted down.
Still, this is a golden age. Civilisations are healing the wounds of thousands of years of conflict, and the Humans and the Halflings have made a lasting peace.

You are an adventurer, set out to discover wonders, explore old places, and venture into the unknown for wealth and glory.
]]
starter = "mod.load"

-- List of additional team files required
teams = {
	{ "#name#-#version#-music.team", "optional", {"/data/music/"} },
	{ "#name#-#version#-gfx-shockbolt.team", "optional", {"/data/gfx/shockbolt/"} },
}

loading_wait_ticks = 260
profile_stats_fields = {"artifacts", "characters", "deaths", "uniques", "scores", "lore", "escorts"}
allow_userchat = true -- We can talk to the online community
no_get_name = true -- Name setting for new characters is done by the module itself
background_name = {"tome","tome2","tome3"}

load_tips = {
	{image="/data/gfx/shockbolt/npc/humanoid_human_linaniil_supreme_archmage.png", img_y_off=-50, text=[[Though magic is still shunned in Maj'Eyal, rumours abound of secret havens of mages.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_orc_orc_elite_berserker.png", text=[[The Rush talent lets you close in on an enemy quickly and daze them, disabling them whilst you hack down their friends.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_rogue.png", text=[[Stunning an opponent slows down their movement and reduces their damage output, giving you the opportunity to tactically reposition or finish them off at less risk.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_bandit.png", text=[[Movement is key on the battlefield. A stationary fighter will become a dead fighter. One must always seek the position of greatest tactical advantage and continue to re-evaluate throughout the battle.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_orc_orc_blood_mage.png", text=[[In the Age of Pyre the orcs learned the secrets of magic, and with their newfound powers nearly overcame the whole of Maj'Eyal.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_orc_orc_berserker.png", text=[[The orcs once terrorised the whole continent. In the Age of Ascendancy they were rendered extinct, but rumours abound of hidden groups biding their time to return.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_fire_wyrmic.png", text=[[Intense willpower lets wyrmics take on the natural powers of dragons.]]},
	{image="/data/gfx/loadtiles/alchemist_golem.png", text=[[Alchemist can transmute gems to create fiery explosions, and are known to travel with a sturdy golem for extra protection.]]},
	{image="/data/gfx/shockbolt/npc/construct_golem_athamathon_the_giant_golem.png", text=[[In the Age of Pyre the giant golem Atamathon was built with the sole purpose of stopping the orcish leader Garkul the Devourer. The golem was single-handedly destroyed by the orc, who then slaughtered an army of thousands before the demonic fighter was finally slain.]]},
	{image="/data/gfx/loadtiles/farportal.png", text=[[None know what the Sher'Tul looked like, or what caused them all to disappear thousands of years ago. Their rare ruins are a source of mystery and terror.]]},
	{image="/data/gfx/shockbolt/npc/horror_eldritch_luminous_horror.png", text=[[In deep places dark things dwell beyond description or understanding. None know the source of these hideous horrors.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_celia.png", img_y_off=-20, text=[[Who knows what dark thoughts drive ones to necromancy? Its art is as old as magic itself, and its creations have plagued all the races since the earliest memories.]]},
	{image="/data/gfx/shockbolt/npc/undead_mummy_greater_mummy_lord.png", text=[[Some say that in their early days the Shaloren kings experimented with necromancy to preserve their flesh after death, but with little success. The Shaloren vehemently deny this.]]},
	{image="/data/gfx/loadtiles/toknor_mirvenia.png", img_y_off=-10, text=[[120 years ago Toknor and Mirvenia united the human and halfling kingdoms and wiped out the orcish race, thus establishing the Age of Ascendancy.]]},
	{image="/data/gfx/loadtiles/lava.png", text=[["The Spellblaze tore Eyal apart and nearly brought about the end of all civilisation. Two thousand years on its shadow still hangs over many lands, and the prideful mages have never been forgiven their place in bringing it about.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_ben_cruthdar__the_cursed.png", text=[[Some are cursed with mental powers beyond their full control, turning them to a dark life powered by hatred.]]},
	{image="/data/gfx/shockbolt/npc/the_master.png", text=[[Dreadfell has always been shunned for its haunted crypts, but of late rumours tell of a darker and more terrible power in residence.]]},
	{image="/data/gfx/shockbolt/terrain/shertul_control_orb_blue.png", text=[[Some Sher'Tul artifacts can still be found in hidden places, but it is said they are not to be trifled with.]]},
	{image="/data/gfx/shockbolt/npc/dragon_fire_fire_drake.png", text=[[Drakes and wyrms are the strongest natural creatures in the world, capable of powers far beyond most other beings.]]},
	{image="/data/gfx/shockbolt/npc/vermin_sandworm_sandworm_burrower.png", text=[[Giant worms tear open huge passageways through the deserts in the west. It is said great riches lie buried beneath the sand, still decorating the corpses of those who went there seeking great riches.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_arcane_blade.png", text=[[Arcane Blades employ a fusion of melee and magical combat. Their training is harsh but the most dedicated rise to great powers.]]},
	{image="/data/gfx/shockbolt/object/rune_green.png", text=[[Wild infusions call upon the powers of nature to protect the flesh and rid oneself of inflictions.]]},
	{image="/data/gfx/shockbolt/object/rune_red.png", text=[[Shield runes act instantly, letting one protect oneself quickly whilst also preparing to flee or launch a counter attack.]]},
	{image="/data/gfx/shockbolt/object/plate_voratun.png", text=[[Greater training in the use of armour lets it be used more effectively, blocking more damage and reducing the chance of an enemy hitting a critical spot.]]},
	{image="/data/gfx/talents/thick_skin.png", text=[[The Thick Skin talent reducing all incoming damage, letting you survive for longer before needing to heal.]]},
	{image="/data/gfx/shockbolt/object/rune_green", text=[[Regeneration infusions act over several turns, letting you anticipate damage that will be taken and prepare for it.]]},
	{image="/data/gfx/shockbolt/object/wand_elm.png", text=[[In the most dire circumstances teleportation can be the best escape, but is not without risk.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_halfling_protector_myssil.png", text=[[The Ziguranth are an ancient order vehemently opposed to magic. Some have become so attuned to nature they can resist arcane forces with their will alone.]]},
	{image="/data/gfx/shockbolt/npc/giant_ice_snow_giant.png", img_y_off=-20, text=[[Records say that giants once lived civilised lives, with mastery of many crafts and sciences. Now though they have adopted nomadic cultures, turning hostile against those that encroach on their lands.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_dwarf_ziguranth_warrior.png", text=[[Zigur was founded by escapees of Conclave experiments during the Allure wars between humans and halflings.]]},
	{image="/data/gfx/shockbolt/terrain/statue3.png", text=[[The Thaloren and Shaloren elves have never had good relations, and have been outright hostile since the Spellblaze devastated many Thaloren lands.]]},
	{image="/data/gfx/shockbolt/terrain/statue3.png", text=[[The third elven race, the Naloren, were rendered extinct after a huge cataclysm swept the eastern side of Maj'Eyal into the sea.]]},
	{image="/data/gfx/shockbolt/npc/giant_troll_prox_the_mighty.png", img_y_off=-20, text=[[Trolls were once seen as little more than beasts or pests, but the orcs trained them up for use in war and they became much more intelligent and fearsome.]]},
	{image="/data/gfx/shockbolt/object/artifact/proxs_lucky_halfling_foot.png", text=[[Some say that the foot of a halfling is lucky to own. Halflings do not take well to those who enquire too forcefully.]]},
	{image="/data/gfx/shockbolt/npc/patrol_allied_kingdoms_allied_kingdoms_halfling_patrol.png", text=[[The Nargol empire was once the largest force in Maj'Eyal, but a combination of the Spellblaze and orcish attacks have dwindled it into insignificance.]]},
	{image="/data/gfx/shockbolt/npc/undead_giant_heavy_bone_giant.png", text=[[Some of the most powerful undead do not fall easily, and only through extreme persistence can they be put to rest.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_yeek_yeek_mindslayer.png", img_y_off=-20, text=[[History says little of the ancient race of yeeks that lived in halfling territory, but vanished before the time of the Spellblaze.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_dwarf_dwarven_earthwarden.png", text=[[Dwarves are naturally inquisitive people, but do not enjoy such inquisition turned on them. Most live secretive lives in their closed off city, the Iron Throne.]]},
	{image="/data/gfx/shockbolt/object/diamond.png", text=[[Alchemists can bind gems to armour to grant them magical effects, to protect the wearer or improve their powers. Some commercial alchemists can imbue gems into jewellery.]]},
	{image="/data/gfx/shockbolt/terrain/ruin_tower_closed01.png", text=[[The Spellblaze was followed by the Age of Dusk, when disease was rife and civilisation collapsed. Necromancers and fell sorcerers took advantage of the chaos to spread their vile deeds.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_linaniil_supreme_archmage.png", img_y_off=-50, text=[[After the Spellblaze came the Spellhunt, when the normal people rose against the arrogance of the mages and hunted them down like wolves. Some survived and went into hiding, but many innocents were killed.]]},
	{image="/data/gfx/shockbolt/npc/demon_major_duathedlen.png", text=[[Demons are thought to come from another world, brought to Eyal by magical forces. Some are highly intelligent and follow their own ambitions. To what end, none know.]]},
	{image="/data/gfx/shockbolt/object/elixir_of_mysticism.png", text=[[The art of potion making fell into decline after the Spellhunt, and only a rare few now master the gift.]]},
	{image="/data/gfx/shockbolt/object/artifact/jewelry_ring_of_the_dead.png", text=[[It's said that some rare powers can save your soul from the edge of death.]]},
	{image="/data/gfx/shockbolt/terrain/woman_naked_altar.png", text=[[Rumours tell of a shadowy cult kidnapping women and performing strange rites. Their intention is unknown, and they have so far evaded capture.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_slave_combatant.png", text=[[Though slavery is illegal there is still a black market for it, and in some areas men are even used for blood sports.]]},
	{image="/data/gfx/shockbolt/terrain/worldmap.png", text=[[Maj'Eyal is the biggest continent in the world of Eyal. Though records suggest other continents and islands may exist it has not been possible to cross the wide and stormy oceans since the Spellblaze and the Cataclysm.]]},
	{image="/data/gfx/shockbolt/terrain/worldmap.png", text=[[The effects of the Spellblaze were not all instant, and many centuries later the Cataclysm tore the continent apart once more, devastating coastal areas the destroying all of the Naloren lands.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_elf_elven_archer.png", text=[[Archers are fast and deadly, and with pinning shots can render their foe helpless as swiftly dispatch them.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_reaver.png", text=[[Reavers are powerful fighters with corrupted blood, and the strength to wield a one-handed weapon in each arm.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_shalore_elven_corruptor.png", text=[[Corrupters fed off the essence of others, and can use their own corrupted blood to launch deadly magical attacks.]]},
	{image="/data/gfx/shockbolt/trap/beartrap01.png", text=[[Clever rogues can lay traps to damage or debilitate their foes without having to go near them.]]},
	{image="/data/gfx/talents/stealth.png", text=[[Rogues can move silently and stealthily, letting them approach foes unaware or avoid them entirely.]]},
	{image="/data/gfx/shockbolt/object/rune_green.png", text=[[A movement infusion can let you quickly approach a ranged opponent, or quickly escape a melee one.]]},
	{image="/data/gfx/shockbolt/object/rune_red.png", text=[[Invisibility lets you escape notice, giving you the freedom to move or recover your resources, but reduces your damage and your healing ability.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_assassin_lord.png", text=[[Poison is the domain of assassins and master rogues, and its cunning use can cripple or kill enemies over a long fight.]]},
	{image="/data/gfx/loadtiles/summoner.png", text=[[Summoners can call upon a variety of natural creatures to protect and support them, reducing the risk to their own flesh considerably.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_linaniil_supreme_archmage.png", img_y_off=-50, text=[[The highest sorcerers are known as archmages, and the masters amongst them are said to have the power to change the world. They are feared immensely.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_orc_orc_elite_fighter.png", text=[[Bulwarks are defensive fighters that can take hits more readily than other warriors whilst preparing for the most effective counter attacks.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_slave_combatant.png", text=[[Brawler are trained in the use of their fists and mastery of their bodies. They can be as dangerous in combat as any swordsman.]]},
	{image="/data/gfx/shockbolt/npc/humanoid_human_urkis__the_high_tempest.png", img_y_off=-50, text=[[Lightning is a chaotic element that is hard to control. It is said that those most attuned to it are eventually driven insane.]]},
}

-- Define the fields that are sync'ed online, and how they are sync'ed
profile_defs = {
	allow_build = { {name="index:string:30"}, receive=function(data, save) save[data.name] = true end, export=function(env) for k, _ in pairs(env) do add{name=k} end end },
	lore = { {name="index:string:30"}, receive=function(data, save) save.lore = save.lore or {} save.lore[data.name] = true end, export=function(env) for k, v in pairs(env.lore or {}) do add{name=k} end end },
	escorts = { {fate="index:enum(lost,betrayed,zigur,saved)"}, {nb="number"}, receive=function(data, save) inc_set(save, data.fate, data, "nb") end, export=function(env) for k, v in pairs(env) do add{fate=k, nb=v} end end },
	artifacts = { {cid="index:string:50"}, {name="index:string:40"}, {nb="number"}, receive=function(data, save) save.artifacts = save.artifacts or {} save.artifacts[data.cid] = save.artifacts[data.cid] or {} inc_set(save.artifacts[data.cid], data.name, data, "nb") end, export=function(env) for cid, d in pairs(env.artifacts or {}) do for name, v in pairs(d) do add{cid=cid, name=name, nb=v} end end end },
	characters = { {cid="index:string:50"}, {nb="number"}, receive=function(data, save) save.characters = save.characters or {} inc_set(save.characters, data.cid, data, "nb") end, export=function(env) for k, v in pairs(env.characters or {}) do add{cid=k, nb=v} end end },
	uniques = { {cid="index:string:50"}, {victim="index:string:50"}, {nb="number"}, receive=function(data, save) save.uniques = save.uniques or {} save.uniques[data.cid] = save.uniques[data.cid] or {} inc_set(save.uniques[data.cid], data.victim, data, "nb") end, export=function(env) for cid, d in pairs(env.uniques or {}) do for name, v in pairs(d) do add{cid=cid, victim=name, nb=v} end end end },
	deaths = { {cid="index:string:50"}, {source="index:string:50"}, {nb="number"}, receive=function(data, save) save.sources = save.sources or {} save.sources[data.cid] = save.sources[data.cid] or {} inc_set(save.sources[data.cid], data.source, data, "nb") end, export=function(env) for cid, d in pairs(env.sources or {}) do for name, v in pairs(d) do add{cid=cid, source=name, nb=v} end end end },
	achievements = { {id="index:string:40"}, {gained_on="timestamp"}, {who="string:50"}, {turn="number"}, receive=function(data, save) save[data.id] = {who=data.who, when=data.gained_on, turn=data.turn} end, export=function(env) for id, v in pairs(env) do add{id=id, who=v.who, gained_on=v.when, turn=v.turn} end end },
	donations = { no_sync=true, {last_ask="timestamp"}, receive=function(data, save) save.last_ask = data.last_ask end, export=function(env) add{last_ask=env.last_ask} end },
	scores = {
		nosync=true,
		receive=function(data,save)
			save.sc = save.sc or {}
			save.sc[data.world] = save.sc[data.world] or {}
			save.sc[data.world].alive = save.sc[data.world].alive or {}
			save.sc[data.world].dead = save.sc[data.world].dead or {}
			if data.type == "alive" then
				save.sc[data.world].alive = save.sc[data.world].alive or {}
				save.sc[data.world].alive[data.name] = data
			else
				-- clear any 'alive' entry with this name
				save.sc[data.world].alive[data.name] = nil
				save.sc[data.world].dead = save.sc[data.world].dead or {}
				save.sc[data.world].dead[#save.sc[data.world].dead+1] = data
			end
		end
	},
}

-- Formatter for scores
score_formatters = {
	["Maj'Eyal"] = {
		alive="#LIGHT_GREEN#{score} : #BLUE#{name}#LAST# the #LIGHT_RED#level {level} {subrace} {subclass}#LAST# is still alive and well on #GREEN#{where}#LAST##WHITE#",
		dead="{score} : #BLUE#{name}#LAST# the #LIGHT_RED#level {level} {subrace} {subclass}#LAST# died on #GREEN#{where}#LAST#, killed by a #RED#{killedby}#LAST#"
	},
	["Infinite"] = {
		alive="#LIGHT_GREEN#{score} : #BLUE#{name}#LAST# the #LIGHT_RED#level {level} {subrace} {subclass}#LAST# is still alive and well on level #GREEN#{dlvl}#LAST##WHITE#",
		dead="{score} : #BLUE#{name}#LAST# the #LIGHT_RED#level {level} {subrace} {subclass}#LAST# died on level #GREEN#{dlvl}#LAST#, killed by a #RED#{killedby}#LAST#"
	},
	["Arena"] = {
		alive="#LIGHT_GREEN#{score} : #BLUE#{name}#LAST# the #LIGHT_RED#level {level} {subrace} {subclass}#LAST# is still alive and well on wave #GREEN#{dlvl}#LAST##WHITE#",
		dead="{score} : #BLUE#{name}#LAST# the #LIGHT_RED#level {level} {subrace} {subclass}#LAST# died on wave #GREEN#{dlvl}#LAST#, killed by a #RED#{killedby}#LAST#"
	}
}

