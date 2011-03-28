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

require "engine.class"
require "engine.Entity"
local Particles = require "engine.Particles"
local Map = require "engine.Map"
local NameGenerator = require("engine.NameGenerator")
local Donation = require "mod.dialogs.Donation"

module(..., package.seeall, class.inherit(engine.Entity))

function _M:init(t, no_default)
	engine.Entity.init(self, t, no_default)

	self.allow_backup_guardians = {}
	self.world_artifacts_pool = {}
	self.boss_killed = 0
	self.stores_restock = 1
	self.east_orc_patrols = 4
end

--- Restock all stores
function _M:storesRestock()
	self.stores_restock = self.stores_restock + 1
	print("[STORES] restocking")
end

--- Number of bosses killed
function _M:bossKilled(rank)
	self.boss_killed = self.boss_killed + 1
end

--- Allow dropping the rod of recall
function _M:allowRodRecall(v)
	if v == nil then return self.allow_drop_recall end
	self.allow_drop_recall = v
end

--- Discovered the far east
function _M:goneEast()
	self.is_advanced = true
end

--- Is the game in an advanced state (gone east ? others ?)
function _M:isAdvanced()
	return self.is_advanced
end

--- Reduce the chance of orc patrols
function _M:eastPatrolsReduce()
	self.east_orc_patrols = self.east_orc_patrols / 2
end

--- Get the chance of orc patrols
function _M:canEastPatrol()
	return self.east_orc_patrols
end

--- Setup a backup guardian for the given zone
function _M:activateBackupGuardian(guardian, on_level, zonelevel, rumor, action)
	if self.is_advanced then return end
	print("Zone guardian dead, setting up backup guardian", guardian, zonelevel)
	self.allow_backup_guardians[game.zone.short_name] =
	{
		name = game.zone.name,
		guardian = guardian,
		on_level = on_level,
		new_level = zonelevel,
		rumor = rumor,
		action = action,
	}
end

--- Get random emote for townpeople based on backup guardians
function _M:getBackupGuardianEmotes(t)
	if not self.is_advanced then return t end
	for zone, data in pairs(self.allow_backup_guardians) do
		print("possible chatter", zone, data.rumor)
		t[#t+1] = data.rumor
	end
	return t
end

--- Activate a backup guardian & settings, if available
function _M:zoneCheckBackupGuardian()
	if not self.is_advanced then print("Not gone east, no backup guardian") return end

	-- Adjust level of the zone
	if self.allow_backup_guardians[game.zone.short_name] then
		local data = self.allow_backup_guardians[game.zone.short_name]
		game.zone.base_level = data.new_level
		if game.difficulty == game.DIFFICULTY_INSANE then
			game.zone.base_level_range = table.clone(game.zone.level_range, true)
			game.zone.specific_base_level.object = -10 -game.zone.base_level
			game.zone.base_level = game.zone.base_level * 2 + 10
		end
		if data.action then data.action(false) end
	end

	-- Spawn the new guardian
	if self.allow_backup_guardians[game.zone.short_name] and self.allow_backup_guardians[game.zone.short_name].on_level == game.level.level then
		local data = self.allow_backup_guardians[game.zone.short_name]

		-- Place the guardian, we do not check for connectivity, vault or whatever, the player is supposed to be strong enough to get there
		local m = game.zone:makeEntityByName(game.level, "actor", data.guardian)
		if m then
			local x, y = rng.range(0, game.level.map.w - 1), rng.range(0, game.level.map.h - 1)
			local tries = 0
			while not m:canMove(x, y) and tries < 100 do
				x, y = rng.range(0, game.level.map.w - 1), rng.range(0, game.level.map.h - 1)
				tries = tries + 1
			end
			if tries < 100 then
				game.zone:addEntity(game.level, m, "actor", x, y)
				print("Backup Guardian allocated: ", data.guardian, m.uid, m.name)
			end
		else
			print("WARNING: Backup Guardian not found: ", data.guardian)
		end

		if data.action then data.action(true) end
		self.allow_backup_guardians[game.zone.short_name] = nil
	end
end

--- A boss refused to drop his artifact! Bastard! Add it to the world pool
function _M:addWorldArtifact(o)
	self.world_artifacts_pool[o.define_as] = o
end

--- Load all added artifacts
-- This is called from the world-artifacts.lua file
function _M:getWorldArtifacts()
	return self.world_artifacts_pool
end

local randart_name_rules = {
	default2 = {
		phonemesVocals = "a, e, i, o, u, y",
		phonemesConsonants = "b, c, ch, ck, cz, d, dh, f, g, gh, h, j, k, kh, l, m, n, p, ph, q, r, rh, s, sh, t, th, ts, tz, v, w, x, z, zh",
		syllablesStart = "Aer, Al, Am, An, Ar, Arm, Arth, B, Bal, Bar, Be, Bel, Ber, Bok, Bor, Bran, Breg, Bren, Brod, Cam, Chal, Cham, Ch, Cuth, Dag, Daim, Dair, Del, Dr, Dur, Duv, Ear, Elen, Er, Erel, Erem, Fal, Ful, Gal, G, Get, Gil, Gor, Grin, Gun, H, Hal, Han, Har, Hath, Hett, Hur, Iss, Khel, K, Kor, Lel, Lor, M, Mal, Man, Mard, N, Ol, Radh, Rag, Relg, Rh, Run, Sam, Tarr, T, Tor, Tul, Tur, Ul, Ulf, Unr, Ur, Urth, Yar, Z, Zan, Zer",
		syllablesMiddle = "de, do, dra, du, duna, ga, go, hara, kaltho, la, latha, le, ma, nari, ra, re, rego, ro, rodda, romi, rui, sa, to, ya, zila",
		syllablesEnd = "bar, bers, blek, chak, chik, dan, dar, das, dig, dil, din, dir, dor, dur, fang, fast, gar, gas, gen, gorn, grim, gund, had, hek, hell, hir, hor, kan, kath, khad, kor, lach, lar, ldil, ldir, leg, len, lin, mas, mnir, ndil, ndur, neg, nik, ntir, rab, rach, rain, rak, ran, rand, rath, rek, rig, rim, rin, rion, sin, sta, stir, sus, tar, thad, thel, tir, von, vor, yon, zor",
		rules = "$s$v$35m$10m$e",
	},
	default = {
		phonemesVocals = "a, e, i, o, u, y",
		syllablesStart = "Ad, Aer, Ar, Bel, Bet, Beth, Ce'N, Cyr, Eilin, El, Em, Emel, G, Gl, Glor, Is, Isl, Iv, Lay, Lis, May, Ner, Pol, Por, Sal, Sil, Vel, Vor, X, Xan, Xer, Yv, Zub",
		syllablesMiddle = "bre, da, dhe, ga, lda, le, lra, mi, ra, ri, ria, re, se, ya",
		syllablesEnd = "ba, beth, da, kira, laith, lle, ma, mina, mira, na, nn, nne, nor, ra, rin, ssra, ta, th, tha, thra, tira, tta, vea, vena, we, wen, wyn",
		rules = "$s$v$35m$10m$e",
	},
	fire = {
		syllablesStart ="Phoenix, Stoke, Fire, Blaze, Burn, Bright, Sear, Heat, Scald, Hell, Hells, Inferno, Lava, Pyre, Furnace, Cinder, Singe, Flame, Scorch, Brand, Kindle, Flash, Smolder, Torch, Ash, Abyss, Char, Kiln, Sun, Magma, Flare",
		syllablesEnd = "arc, bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, breeze, brawn, burst, bringer, bearer, bender, blight, break, born, black, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, night, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rain, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, strike, striker, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, umbra, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, woe, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
	cold = {
		syllablesStart ="Frost, Ice, Freeze, Sleet, Snow, Chill, Shiver, Winter, Blizzard, Glacier, Tundra, Floe, Hail, Frozen, Frigid, Rime, Haze, Rain, Tide, Quench",
		syllablesEnd = "arc, bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, breeze, brawn, burst, bringer, bearer, bender, blight, brand, break, born, black, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, flash, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, night, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rain, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, strike, striker, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, umbra, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, wire, wisp, wish, witch, wolf, woe, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
	venom = {
		syllablesStart ="Ichor, Offal, Rot, Scab, Squalor, Taint, Undeath, Vile, Weep, Plague, Pox, Pus, Gore, Sepsis, Corruption, Filth, Muck, Fester, Toxin, Venom, Scorpion, Serpent, Viper, Cobra, Sulfur, Mire, Ooze, Wretch, Carrion, Bile, Bog, Sewer, Swamp, Corpse, Scum, Mold, Spider, Phlegm, Mucus, Morbus, Murk, Smear, Cyst",
		syllablesEnd = "arc, bane, bait, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, breeze, brawn, burst, bringer, bearer, bender, blight, brand, break, born, black, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, flash, fiend, fist, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, night, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rain, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, strike, striker, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, trail, umbra, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, woe, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
	lightning = {
		syllablesStart ="Tempest, Storm, Lightning, Arc, Shock, Thunder, Charge, Cloud, Air, Nimbus, Gale, Crackle, Shimmer, Flash, Spark, Blast, Blaze, Strike, Sky, Bolt",
		syllablesEnd = "bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bone, bore, brace, braid, braze, breacher, breaker, breeze, brawn, burst, bringer, bearer, bender, blight, brand, break, born, black, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, flash, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, night, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rain, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, umbra, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, woe, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
	light = {
		syllablesStart ="Light, Shine, Day, Sun, Morning, Star, Blaze, Glow, Gleam, Bright, Prism, Dazzle, Glint, Dawn, Noon, Glare, Flash, Radiance, Blind, Glimmer, Splendour, Glitter, Kindle, Lustre",
		syllablesEnd = "arc, bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, breeze, brawn, burst, bringer, bearer, bender, blight, brand, break, born, black, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, nail, nigh, night, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rain, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, streak, sting, stinger, strike, striker, stun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, umbra, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, woe, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
	dark = {
		syllablesStart ="Night, Umbra, Void, Dark, Gloom, Woe, Dour, Shade, Dusk, Murk, Bleak, Dim, Soot, Pitch, Fog, Black, Coal, Ebony, Shadow, Obsidian, Raven, Jet, Demon, Duathel, Unlight, Eclipse, Blind, Deeps",
		syllablesEnd = "arc, bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, breeze, brawn, burst, bringer, bearer, bender, blight, brand, break, born, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, flash, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rain, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, strike, striker, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
	nature = {
		syllablesStart ="Nature, Green, Loam, Earth, Heal, Root, Growth, Grow, Bark, Bloom, Satyr, Rain, Pure, Wild, Wind, Cure, Cleanse, Forest, Breeze, Oak, Willow, Tree, Balance, Flower",
		syllablesEnd = "arc, bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, brawn, burst, bringer, bearer, bender, blight, brand, break, born, black, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, flash, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, night, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, strike, striker, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, umbra, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, woe, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
}

--- Generate randarts for this state
function _M:generateRandart(add, base, lev)
	if not self.randart_powers then self.randart_powers = engine.Object:loadList("/data/general/objects/random-artifacts.lua") end
	local powers_list = self.randart_powers

	-- Setup level
	lev = lev or rng.range(12, 50)
	local oldlev = game.level.level
	game.level.level = lev

	-- Get a base object
	base = base or game.zone:makeEntity(game.level, "object", {ingore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}, special=function(e)
		return (not e.unique and e.randart_able) and (not e.material_level or e.material_level >= 2) and true or false
	end}, nil, true)
	if not base then game.level.level = oldlev return end
	local o = base:cloneFull()

	local allthemes = {'misc','psionic','sorcerous','nature','brawny','lightning','arcane','light','physical','def','tireless','unyielding','dark','nimble','spell','cold','fire','venom','attack'}
	local pthemes = table.listify(o.randart_able)
	local themes = {[rng.table(allthemes)] = true}
	for i = 1, #pthemes do if rng.percent(pthemes[i][2]) then themes[pthemes[i][1]] = true no_theme = false end end
	local themes_fct = function(e)
		for theme, _ in pairs(e.theme) do if themes[theme] then return true end end
		return false
	end

	-----------------------------------------------------------
	-- Determine power
	-----------------------------------------------------------
	local points = math.ceil((lev * 0.7 + rng.range(5, 15)) / 2)
	local nb_powers = 1 + rng.dice(math.max(1, lev / 17), 2)
	local powers = {}

	o.cost = o.cost + points * 7

	-- Select some powers
	local power_themes = {}
	for i = 1, nb_powers do
		local list = game.zone:computeRarities("powers", powers_list, game.level, themes_fct)
		local p = game.zone:pickEntity(list)
		if p then
			for t, _ in pairs(p.theme) do if themes[t] and randart_name_rules[t] then power_themes[t] = (power_themes[t] or 0) + 1 end end
			powers[p.name] = p
			powers[#powers+1] = p
		end
	end
	power_themes = table.listify(power_themes)
	table.sort(power_themes, function(a, b) return a[2] < b[2] end)

	-----------------------------------------------------------
	-- Make up a name
	-----------------------------------------------------------
	local themename = power_themes[#power_themes]
	themename = themename and themename[1] or nil
	local ngd = NameGenerator.new(rng.chance(2) and randart_name_rules.default or randart_name_rules.default2)
	local ngt = (themename and randart_name_rules[themename] and NameGenerator.new(randart_name_rules[themename])) or ngd
	local name
	local namescheme = (ngt ~= ngd) and rng.range(1, 4) or rng.range(1, 3)
	if namescheme == 1 then
		name = o.name.." '"..ngt:generate().."'"
	elseif namescheme == 2 then
		name = ngt:generate().." the "..o.name
	elseif namescheme == 3 then
		name = ngt:generate()
	elseif namescheme == 4 then
		name = ngd:generate().." the "..ngt:generate()
	end
	o.define_as = name:upper():gsub("[^A-Z]", "_")

	o.unided_name = rng.table{"glowing","scintillating","rune-covered","unblemished","jewel-encrusted"}.." "..o.unided_name
	o.unique = name
	o.randart = true
	o.no_unique_lore = true
	o.rarity = rng.range(200, 290)

	print("Creating randart "..name.."("..o.unided_name..") with "..(themename or "nil").." with level "..lev)
	print(" * using themes", table.concat(table.keys(themes), ','))

	-----------------------------------------------------------
	-- Add ego properties
	-----------------------------------------------------------
	if o.egos then
		local legos = {}
		local been_greater = false
		table.insert(legos, game.level:getEntitiesList("object/"..o.egos..":prefix"))
		table.insert(legos, game.level:getEntitiesList("object/"..o.egos..":suffix"))
		table.insert(legos, game.level:getEntitiesList("object/"..o.egos..":"))
		for i = 1, 2 do
			local egos = rng.table(legos)
			local list = {}
			local filter = nil
			if rng.percent(lev) and not been_greater then been_greater = true filter = function(e) return e.greater_ego end end
			for z = 1, #egos do list[#list+1] = egos[z].e end
			local pick_egos = game.zone:computeRarities("object", list, game.level, filter, nil, nil)
			local ego = game.zone:pickEntity(pick_egos)
			if ego then
				print(" ** selected ego", ego.name)
				ego = ego:clone()
				if ego.instant_resolve then ego:resolve(nil, nil, o) end
				ego.instant_resolve = nil
				ego.uid = nil
				ego.name = nil
				ego.unided_name = nil

				table.mergeAddAppendArray(o, ego, true)
			end
		end
		o.egos = nil o.egos_chance = nil o.force_ego = nil
		-- Re-resolve with the (possibly) new resolvers
		o:resolve()
		o:resolve(nil, true)
	end

	-----------------------------------------------------------
	-- Imbue powers in the randart
	-----------------------------------------------------------
	local function merger(dst, src)
		for k, e in pairs(src) do
			if type(e) == "table" then
				if e.__resolver and e.__resolver == "randartmax" then
					dst[k] = (dst[k] or 0) + e.v
					if dst[k] > e.max then
						dst[k] = e.max
					end
				else
					if not dst[k] then dst[k] = {} end
					merger(dst[k], e)
				end
			elseif type(e) == "number" then
				dst[k] = (dst[k] or 0) + e
			else
				error("Type "..type(e).. " for randart property unsupported!")
			end
		end
	end

	-- Distribute points
	local hpoints = math.ceil(points / 2)
	local i = 0
	while hpoints > 0 do
		i = util.boundWrap(i + 1, 1, #powers)

		local p = powers[i]:clone()
		if p.points <= hpoints then
			if p.wielder then
				o.wielder = o.wielder or {}
				merger(o.wielder, p.wielder)
			end
			if p.copy then merger(o, p.copy) end
--			print(" * adding power: "..p.name)
		end
		hpoints = hpoints - p.points
	end
	o:resolve() o:resolve(nil, true)

	-- Bias toward some powers
	local bias_powers = {}
	local nb_bias = rng.range(1, lev / 5)
	for i = 1, nb_bias do bias_powers[#bias_powers+1] = rng.table(powers) end
	local hpoints = math.ceil(points / 2)
	local i = 0
	while hpoints > 0 do
		i = util.boundWrap(i + 1, 1, #bias_powers)

		local p = bias_powers[i]:clone()
		if p.points <= hpoints * 2 then
			if p.wielder then
				o.wielder = o.wielder or {}
				merger(o.wielder, p.wielder)
			end
			if p.copy then merger(o, p.copy) end
--			print(" * adding power: "..p.name)
		end
		hpoints = hpoints - p.points * 2
	end

	-- Setup the name
	o.name = name

	if add then self:addWorldArtifact(o) end

	game.level.level = oldlev
	return o
end



local wda_cache = {}

--- Runs the worldmap directory AI
function _M:worldDirectorAI()
	if not game.level.data.wda or not game.level.data.wda.script then return end
	local script = wda_cache[game.level.data.wda.script]
	if not script then
		local f, err = loadfile("/data/wda/"..game.level.data.wda.script..".lua")
		if not f then error(err) end
		wda_cache[game.level.data.wda.script] = f
		script = f
	end

	game.level.level = game.player.level
	setfenv(script, setmetatable({wda=game.level.data.wda}, {__index=_G}))
	local ok, err = pcall(script)
	if not ok and err then error(err) end
end

function _M:spawnWorldAmbush(enc)
	game:onTickEnd(function()

	local gen = { class = "engine.generator.map.Forest",
		edge_entrances = {4,6},
		sqrt_percent = 50,
		zoom = 10,
		floor = "GRASS",
		wall = "TREE",
		down = "DOWN",
		up = "GRASS_UP_WILDERNESS",
	}
	local g = game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN)
	if not g.can_encounter then return false end

	if g.can_encounter == "desert" then gen.floor = "SAND" gen.wall = "PALMTREE" end

	local zone = engine.Zone.new("ambush", {
		name = "Ambush!",
		level_range = {game.player.level, game.player.level},
		level_scheme = "player",
		max_level = 1,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = enc.width or 20, height = enc.height or 20,
		all_lited = true,
		ambient_music = "last",
		generator =  {
			map = gen,
			actor = { class = "engine.generator.actor.Random", nb_npc = enc.nb or {1,1}, filters=enc.filters },
		},

		npc_list = mod.class.NPC:loadList("/data/general/npcs/all.lua", nil, nil, function(e) e.make_escort=nil end),
		grid_list = mod.class.Grid:loadList{"/data/general/grids/basic.lua", "/data/general/grids/forest.lua", "/data/general/grids/sand.lua"},
		object_list = mod.class.Object:loadList("/data/general/objects/objects.lua"),
		trap_list = {},
		post_process = function(level)
			-- Find a good starting location, on the opposite side of the exit
			local sx, sy = level.map.w-1, rng.range(0, level.map.h-1)
			level.spots[#level.spots+1] = {
				check_connectivity = "entrance",
				x = sx,
				y = sy,
			}
			level.default_down = level.default_up
			level.default_up = {x=sx, y=sy}
		end,
	})
	game.player:runStop()
	game.player.energy.value = game.energy_to_act
	game.paused = true
	game:changeLevel(1, zone)
	engine.ui.Dialog:simplePopup("Ambush!", "You have been ambushed!")

	end)
end

function _M:handleWorldEncounter(target)
	local enc = target.on_encounter
	if type(enc) == "function" then return enc() end
	if type(enc) == "table" then
		if enc.type == "ambush" then target:die() self:spawnWorldAmbush(enc)
		end
	end
end

--------------------------------------------------------------------
-- Weather stuff
--------------------------------------------------------------------
function _M:makeWeather(level, nb, params, typ)
	if not config.settings.tome.weather_effects then return end

	local ps = {}
	params.width = level.map.w*level.map.tile_w
	params.height = level.map.h*level.map.tile_h
	for i = 1, nb do
		local p = table.clone(params, true)
		p.particle_name = p.particle_name:format(nb)
		ps[#ps+1] = Particles.new(typ or "weather_storm", 1, p)
	end
	level.data.weather_particle = ps
end

function _M:displayWeather(level, ps, nb_keyframes)
	local dx, dy = level.map:getScreenUpperCorner() -- Display at map border, always, so it scrolls with the map
	for j = 1, #ps do
		ps[j].ps:toScreen(dx, dy, true, 1)
	end
end

local function doTint(from, to, amount)
	local tint = {r = 0, g = 0, b = 0}
	tint.r = (from.r * (1 - amount) + to.r * amount)
	tint.g = (from.g * (1 - amount) + to.g * amount)
	tint.b = (from.b * (1 - amount) + to.b * amount)
	return tint
end

--- Compute a day/night cycle
-- Works by changing the tint of the map gradualy
function _M:dayNightCycle()
	local map = game.level.map
	local shown = map.color_shown
	local obscure = map.color_obscure

	if not config.settings.tome.daynight then
		-- Restore defaults
		map._map:setShown(unpack(shown))
		map._map:setObscure(unpack(obscure))
		return
	end

	local hour, minute = game.calendar:getTimeOfDay(game.turn)
	hour = hour + (minute / 60)
	local tint = {r = 0.1, g = 0.1, b = 0.1}
	local startTint = {r = 0.1, g = 0.1, b = 0.1}
	local endTint = {r = 0.1, g = 0.1, b = 0.1}
	if hour <= 4 then
		tint = {r = 0.1, g = 0.1, b = 0.1}
	elseif hour > 4 and hour <= 7 then
		startTint = { r = 0.1, g = 0.1, b = 0.1 }
		endTint = { r = 0.3, g = 0.3, b = 0.5 }
		tint = doTint(startTint, endTint, (hour - 4) / 3)
	elseif hour > 7 and hour <= 12 then
		startTint = { r = 0.3, g = 0.3, b = 0.5 }
		endTint = { r = 0.9, g = 0.9, b = 0.9 }
		tint = doTint(startTint, endTint, (hour - 7) / 5)
	elseif hour > 12 and hour <= 18 then
		startTint = { r = 0.9, g = 0.9, b = 0.9 }
		endTint = { r = 0.9, g = 0.9, b = 0.6 }
		tint = doTint(startTint, endTint, (hour - 12) / 6)
	elseif hour > 18 and hour < 24 then
		startTint = { r = 0.9, g = 0.9, b = 0.6 }
		endTint = { r = 0.1, g = 0.1, b = 0.1 }
		tint = doTint(startTint, endTint, (hour - 18) / 6)
	end
	map._map:setShown(shown[1] * (tint.r+0.4), shown[2] * (tint.g+0.4), shown[3] * (tint.b+0.4), shown[4])
	map._map:setObscure(obscure[1] * (tint.r+0.2), obscure[2] * (tint.g+0.2), obscure[3] * (tint.b+0.2), obscure[4])
end

--------------------------------------------------------------------
-- Donations
--------------------------------------------------------------------
function _M:checkDonation(back_insert)
	-- Multiple checks to see if this is a "good" time
	-- This is only called when something nice happens (like an achievement)
	-- We then check multiple conditions to make sure the player is in a good state of mind

	-- Dont ask often
	local last = profile.generic.donations and profile.generic.donations.last_ask or 0
	local min_interval = 30 * 24 * 60 * 60 -- 1 month
	if os.time() < last + min_interval then
		print("Donation check: too soon")
		return
	end

	-- Not as soon as they start playing, wait 15 minutes
	if os.time() - game.real_starttime < 15 * 60 then
		print("Donation check: not started tome long enough")
		return
	end

	-- Total playtime must be over a few hours
	local total = profile.generic.modules_played and profile.generic.modules_played.tome or 0
	if total + (os.time() - game.real_starttime) < 7 * 60 * 60 then
		print("Donation check: total time too low")
		return
	end

	-- Dont ask low level characters, they are probably still pissed to not have progressed further
	if game.player.level < 15 then
		print("Donation check: too low level")
		return
	end

	-- Dont ask people in immediate danger
	if game.player.life / game.player.max_life < 0.7 then
		print("Donation check: too low life")
		return
	end

	-- Dont ask people that already have their hands full
	local nb_foes = 0
	for i = 1, #game.player.fov.actors_dist do
		local act = game.player.fov.actors_dist[i]
		if act and game.player:reactionToward(act) < 0 and not act.dead then
			if act.rank and act.rank > 3 then nb_foes = nb_foes + 1000 end -- Never with bosses in sight
			nb_foes = nb_foes + 1
		end
	end
	if nb_foes > 2 then
		print("Donation check: too many foes")
		return
	end

	-- Request money! Even a god has to eat :)
	profile.generic.donations = profile.generic.donations or {}
	profile.generic.donations.last_ask = os.time()
	profile:saveGenericProfile("donations", profile.generic.donations)
	if back_insert then
		game:registerDialogAt(Donation.new(), 2)
	else
		game:registerDialog(Donation.new())
	end
end

--------------------------------------------------------------
-- Loot filters
--------------------------------------------------------------

local drop_tables = {
	normal = {
		[1] = {
			uniques = 0.5,
			double_greater = 2,
			greater_normal = 4,
			greater = 12,
			double_ego = 20,
			ego = 45,
			basic = 20,
			money = 7,
		},
		[2] = {
			uniques = 0.7,
			double_greater = 6,
			greater_normal = 10,
			greater = 20,
			double_ego = 35,
			ego = 30,
			basic = 15,
			money = 8,
		},
		[3] = {
			uniques = 1,
			double_greater = 10,
			greater_normal = 15,
			greater = 35,
			double_ego = 25,
			ego = 15,
			basic = 10,
			money = 8.5,
		},
		[4] = {
			uniques = 1.1,
			double_greater = 15,
			greater_normal = 35,
			greater = 25,
			double_ego = 20,
			ego = 5,
			basic = 5,
			money = 8,
		},
		[5] = {
			uniques = 1.2,
			double_greater = 35,
			greater_normal = 30,
			greater = 20,
			double_ego = 10,
			ego = 5,
			basic = 5,
			money = 8,
		},
	},
	store = {
		[1] = {
			uniques = 0.5,
			double_greater = 10,
			greater_normal = 15,
			greater = 25,
			double_ego = 45,
			ego = 10,
			basic = 0,
			money = 0,
		},
		[2] = {
			uniques = 0.5,
			double_greater = 20,
			greater_normal = 18,
			greater = 25,
			double_ego = 35,
			ego = 8,
			basic = 0,
			money = 0,
		},
		[3] = {
			uniques = 0.5,
			double_greater = 30,
			greater_normal = 22,
			greater = 25,
			double_ego = 25,
			ego = 6,
			basic = 0,
			money = 0,
		},
		[4] = {
			uniques = 0.5,
			double_greater = 40,
			greater_normal = 30,
			greater = 25,
			double_ego = 20,
			ego = 4,
			basic = 0,
			money = 0,
		},
		[5] = {
			uniques = 0.5,
			double_greater = 50,
			greater_normal = 30,
			greater = 25,
			double_ego = 10,
			ego = 0,
			basic = 0,
			money = 0,
		},
	},
	boss = {
		[1] = {
			uniques = 3,
			double_greater = 10,
			greater_normal = 15,
			greater = 25,
			double_ego = 45,
			ego = 0,
			basic = 0,
			money = 4,
		},
		[2] = {
			uniques = 4,
			double_greater = 20,
			greater_normal = 18,
			greater = 25,
			double_ego = 35,
			ego = 0,
			basic = 0,
			money = 4,
		},
		[3] = {
			uniques = 5,
			double_greater = 30,
			greater_normal = 22,
			greater = 25,
			double_ego = 25,
			ego = 0,
			basic = 0,
			money = 4,
		},
		[4] = {
			uniques = 6,
			double_greater = 40,
			greater_normal = 30,
			greater = 25,
			double_ego = 20,
			ego = 0,
			basic = 0,
			money = 4,
		},
		[5] = {
			uniques = 7,
			double_greater = 50,
			greater_normal = 30,
			greater = 25,
			double_ego = 10,
			ego = 0,
			basic = 0,
			money = 4,
		},
	},
}

local loot_mod = {
	uvault = { -- Uber vault
		uniques = 40,
		double_greater = 8,
		greater_normal = 5,
		greater = 3,
		double_ego = 0,
		ego = 0,
		basic = 0,
		money = 0,
	},
	gvault = { -- Greater vault
		uniques = 10,
		double_greater = 2,
		greater_normal = 2,
		greater = 2,
		double_ego = 1,
		ego = 0,
		basic = 0,
		money = 0,
	},
	vault = { -- Default vault
		uniques = 5,
		double_greater = 2,
		greater_normal = 3,
		greater = 3,
		double_ego = 2,
		ego = 0,
		basic = 0,
		money = 0,
	},
}

local default_drops = function(zone, level, what)
	if zone.default_drops then return zone.default_drops end
	local lev = util.bound(math.ceil(zone:level_adjust_level(level, "object") / 10), 1, 5)
	print("[TOME ENTITY FILTER] making default loot table for", what, lev)
	return table.clone(drop_tables[what][lev])
end

function _M:defaultEntityFilter(zone, level, type)
	if type ~= "object" then return end

	-- By default we dont apply special filters, but we always provide one so that entityFilter is called
	return {
		tome = default_drops(zone, level, "normal"),
	}
end

--- Alter any entity filters to process tome specific loot tables
-- Here be magic! We tweak and convert and turn and create filters! It's magic but it works :)
function _M:entityFilterAlter(zone, level, type, filter)
	if type ~= "object" then return filter end

	if filter.force_tome_drops or (not filter.tome and not filter.defined and not filter.special and not filter.unique and not filter.ego_chance and not filter.ego_filter and not filter.no_tome_drops) then filter.tome = default_drops(zone, level, filter.tome_drops or "normal") end

	if filter.tome then
		local t = (filter.tome == true) and default_drops(zone, level, "normal") or filter.tome
		filter.tome = nil

		if filter.tome_mod then
			t = table.clone(t)
			if _G.type(filter.tome_mod) == "string" then filter.tome_mod = loot_mod[filter.tome_mod] end
			for k, v in pairs(filter.tome_mod) do
				print(" ***** LOOT MOD", k, v)
				t[k] = (t[k] or 0) * v
			end
		end

		-- If we request a specific type/subtype, we dont waht categories that could make that not happen
		if filter.type or filter.subtype or filter.name then t.money = 0 end

		local u = t.uniques or 0
		local dg = u + (t.double_greater or 0)
		local ge = dg + (t.greater_normal or 0)
		local g = ge + (t.greater or 0)
		local de = g + (t.double_ego or 0)
		local e = de + (t.ego or 0)
		local m = e + (t.money or 0)
		local total = m + (t.basic or 0)

		local r = rng.float(0, total)
		if r < u then
			print("[TOME ENTITY FILTER] selected Uniques", r, u)
			filter.unique = true
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "lore"

		elseif r < dg then
			print("[TOME ENTITY FILTER] selected Double Greater", r, dg)
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "unique"
			filter.ego_chance={tries = { {ego_chance=100, properties={"greater_ego"}}, {ego_chance=100, properties={"greater_ego"}} } }

		elseif r < ge then
			print("[TOME ENTITY FILTER] selected Greater + Ego", r, ge)
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "unique"
			filter.ego_chance={tries = { {ego_chance=100, properties={"greater_ego"}}, {ego_chance=100, not_properties={"greater_ego"}} }}

		elseif r < g then
			print("[TOME ENTITY FILTER] selected Greater", r, g)
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "unique"
			filter.ego_chance={tries = { {ego_chance=100, properties={"greater_ego"}} } }

		elseif r < de then
			print("[TOME ENTITY FILTER] selected Double Ego", r, de)
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "unique"
			filter.ego_chance={tries = { {ego_chance=100, not_properties={"greater_ego"}}, {ego_chance=100, not_properties={"greater_ego"}} }}

		elseif r < e then
			print("[TOME ENTITY FILTER] selected Ego", r, e)
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "unique"
			filter.ego_chance={tries = { {ego_chance=100, not_properties={"greater_ego"}} } }

		elseif r < m then
			print("[TOME ENTITY FILTER] selected Money", r, m)
			filter.special = function(e) return e.type == "money" or e.type == "gem" end

		else
			print("[TOME ENTITY FILTER] selected basic", r, total)
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "unique"
			filter.ego_chance = -1000
		end
	end

	-- By default we dont apply special filters, but we always provide one so that entityFilter is called
	return filter
end

function _M:entityFilter(zone, e, filter, type)
	if type == "object" then
		if not filter.ingore_material_restriction then
			local min_mlvl = util.getval(zone.min_material_level)
			local max_mlvl = util.getval(zone.max_material_level)
			if min_mlvl then
				if not e.material_level then return true end
				if e.material_level < min_mlvl then return false end
			end

			if max_mlvl then
				if not e.material_level then return true end
				if e.material_level > max_mlvl then return false end
			end
		end
		return true
	else
		return true
	end
end

--------------------------------------------------------------
-- Random zones
--------------------------------------------------------------

local random_zone_layouts = {
	-- Forest
	{ name="forest", rarity=3, gen=function(data) return {
		class = "engine.generator.map.Forest",
		edge_entrances = {data.less_dir, data.more_dir},
		zoom = rng.range(2,6),
		sqrt_percent = rng.range(20, 50),
		noise = "fbm_perlin",
		floor = data:getFloor(),
		wall = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
	} end },
	-- Cavern
	{ name="cavern", rarity=3, gen=function(data)
		local floors = data.w * data.h * 0.4
		return {
		class = "engine.generator.map.Cavern",
		zoom = rng.range(10, 20),
		min_floor = rng.range(floors / 2, floors),
		floor = data:getFloor(),
		wall = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
	} end },
	-- Rooms
	{ name="rooms", rarity=3, gen=function(data)
		local rooms = {"random_room"}
		if rng.percent(30) then rooms = {"forest_clearing"} end
		return {
		class = "engine.generator.map.Roomer",
		nb_rooms = math.floor(data.w * data.h / 250),
		rooms = rooms,
		lite_room_chance = rng.range(0, 100),
		['.'] = data:getFloor(),
		['#'] = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
		door = data:getDoor(),
	} end },
	-- Sets
	{ name="sets", rarity=3, gen=function(data)
		local set = rng.table{
			{"3x3/base", "3x3/tunnel", "3x3/windy_tunnel"},
			{"5x5/base", "5x5/tunnel", "5x5/windy_tunnel", "5x5/crypt"},
			{"7x7/base", "7x7/tunnel"},
		}
		return {
		class = "engine.generator.map.TileSet",
		tileset = set,
		['.'] = data:getFloor(),
		['#'] = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
		door = data:getDoor(),
		["'"] = data:getDoor(),
	} end },
}

local random_zone_themes = {
	-- Trees
	{ name="trees", rarity=3, gen=function() return {
		load_grids = {"/data/general/grids/forest.lua"},
		getDoor = function(self) return "GRASS" end,
		getFloor = function(self) return function() if rng.chance(20) then return "FLOWER" else return "GRASS" end end end,
		getWall = function(self) return {"TREE","TREE2","TREE3","TREE4","TREE5","TREE6","TREE7","TREE8","TREE9","TREE10","TREE11","TREE12","TREE13","TREE14","TREE15","TREE16","TREE17","TREE18","TREE19","TREE20",} end,
		getUp = function(self) return "GRASS_UP"..self.less_dir end,
		getDown = function(self) return "GRASS_DOWN"..self.more_dir end,
	} end },
	-- Walls
	{ name="walls", rarity=2, gen=function() return {
		load_grids = {"/data/general/grids/basic.lua"},
		getDoor = function(self) return "DOOR" end,
		getFloor = function(self) return "FLOOR" end,
		getWall = function(self) return "WALL" end,
		getUp = function(self) return "UP" end,
		getDown = function(self) return "DOWN" end,
	} end },
	-- Underground
	{ name="underground", rarity=6, gen=function() return {
		load_grids = {"/data/general/grids/underground.lua"},
		getDoor = function(self) return "UNDERGROUND_FLOOR" end,
		getFloor = function(self) return "UNDERGROUND_FLOOR" end,
		getWall = function(self) return {"UNDERGROUND_TREE","UNDERGROUND_TREE2","UNDERGROUND_TREE3","UNDERGROUND_TREE4","UNDERGROUND_TREE5","UNDERGROUND_TREE6","UNDERGROUND_TREE7","UNDERGROUND_TREE8","UNDERGROUND_TREE9","UNDERGROUND_TREE10","UNDERGROUND_TREE11","UNDERGROUND_TREE12","UNDERGROUND_TREE13","UNDERGROUND_TREE14","UNDERGROUND_TREE15","UNDERGROUND_TREE16","UNDERGROUND_TREE17","UNDERGROUND_TREE18","UNDERGROUND_TREE19","UNDERGROUND_TREE20",} end,
		getUp = function(self) return "UNDERGROUND_LADDER_UP" end,
		getDown = function(self) return "UNDERGROUND_LADDER_DOWN" end,
	} end },
	-- Crystals
	{ name="crystal", rarity=6, gen=function() return {
		load_grids = {"/data/general/grids/underground.lua"},
		getDoor = function(self) return "CRYSTAL_FLOOR" end,
		getFloor = function(self) return "CRYSTAL_FLOOR" end,
		getWall = function(self) return {"CRYSTAL_WALL","CRYSTAL_WALL2","CRYSTAL_WALL3","CRYSTAL_WALL4","CRYSTAL_WALL5","CRYSTAL_WALL6","CRYSTAL_WALL7","CRYSTAL_WALL8","CRYSTAL_WALL9","CRYSTAL_WALL10","CRYSTAL_WALL11","CRYSTAL_WALL12","CRYSTAL_WALL13","CRYSTAL_WALL14","CRYSTAL_WALL15","CRYSTAL_WALL16","CRYSTAL_WALL17","CRYSTAL_WALL18","CRYSTAL_WALL19","CRYSTAL_WALL20",} end,
		getUp = function(self) return "CRYSTAL_LADDER_UP" end,
		getDown = function(self) return "CRYSTAL_LADDER_DOWN" end,
	} end },
}

function _M:createRandomZone()
	------------------------------------------------------------
	-- Select theme
	------------------------------------------------------------
	local theme = rng.table(random_zone_themes)
	print("[RANDOM ZONE] Using theme", theme.name)
	local data = theme.gen()

	local grids = {}
	for i, file in ipairs(data.load_grids) do
		mod.class.Grid:loadList(file, nil, grids)
	end

	------------------------------------------------------------
	-- Misc data
	------------------------------------------------------------
	data.depth = rng.range(2, 4)
	data.min_lev, data.max_lev = game.player.level, game.player.level + 15
	data.w, data.h = rng.range(40, 60), rng.range(40, 60)

	data.less_dir = rng.table{2, 4, 6, 8}
	data.more_dir = ({[2]=8, [8]=2, [4]=6, [6]=4})[data.less_dir]

	-- Give a random tint
	data.tint_s = {1, 1, 1, 1}
	if rng.percent(10) then
		local sr, sg, sb
		sr = rng.float(0.3, 1)
		sg = rng.float(0.3, 1)
		sb = rng.float(0.3, 1)
		local max = math.max(sr, sg, sb)
		data.tint_s[1] = sr / max
		data.tint_s[2] = sg / max
		data.tint_s[3] = sb / max
	end
	data.tint_o = {data.tint_s[1] * 0.6, data.tint_s[2] * 0.6, data.tint_s[3] * 0.6, 0.6}

	------------------------------------------------------------
	-- Select layout
	------------------------------------------------------------
	local layout = rng.table(random_zone_layouts)
	print("[RANDOM ZONE] Using layout", layout.name)

	------------------------------------------------------------
	-- Select Music
	------------------------------------------------------------
	local musics = {}
	for i, file in ipairs(fs.list("/data/music/")) do
		if file:find("%.ogg$") then musics[#musics+1] = file end
	end

	local zone = engine.Zone.new("random_zone", {
		name = "Random Zone!!",
		level_range = {data.min_lev, data.max_lev},
		level_scheme = "player",
		max_level = data.depth,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = data.w, height = data.h,
		color_shown = data.tint_s,
		color_obscure = data.tint_o,
		ambient_music = rng.table(musics),
		generator =  {
			map = layout.gen(data),
			actor = { class = "engine.generator.actor.Random",nb_npc = {5, 7}, },
			trap = { class = "engine.generator.trap.Random", nb_trap = {3, 3}, },
		},
		npc_list = mod.class.NPC:loadList("/data/general/npcs/thieve.lua"),
		grid_list = grids,
		object_list = mod.class.Object:loadList("/data/general/objects/objects.lua"),
		trap_list = mod.class.Trap:loadList("/data/general/traps/alarm.lua"),
	})
	return zone
end

function _M:debugRandomZone()
	game:changeLevel(1, self:createRandomZone())
end
