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

require "engine.class"
require "engine.Entity"
local Particles = require "engine.Particles"
local Map = require "engine.Map"
local NameGenerator = require("engine.NameGenerator")

module(..., package.seeall, class.inherit(engine.Entity))

function _M:init(t, no_default)
	engine.Entity.init(self, t, no_default)

	self.allow_backup_guardians = {}
	self.world_artifacts_pool = {}
end

--- Allow dropping the rod of recall
function _M:allowRodRecall(v)
	if v == nil then return self.allow_drop_recall end
	self.allow_drop_recall = v
end

--- Discovered the far east
function _M:goneEast()
	self.gone_east = true
end

--- Setup a backup guardian for the given zone
function _M:activateBackupGuardian(guardian, on_level, zonelevel, rumor, action)
	if self.gone_east then return end
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

--- Activate a backup guardian & settings, if available
function _M:zoneCheckBackupGuardian()
	if not self.gone_east then print("Not gone east, no backup guardian") return end

	-- Adjust level of the zone
	if self.allow_backup_guardians[game.zone.short_name] then
		local data = self.allow_backup_guardians[game.zone.short_name]
		game.zone.base_level = data.new_level
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
	base = base or game.zone:makeEntity(game.level, "object", {ego_filter={keep_egos=true, ego_chance=-1000}, special=function(e)
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
