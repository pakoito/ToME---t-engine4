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

require "engine.class"
require "engine.Entity"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Map = require "engine.Map"
local NameGenerator = require "engine.NameGenerator"
local NameGenerator2 = require "engine.NameGenerator2"
local Donation = require "mod.dialogs.Donation"

module(..., package.seeall, class.inherit(engine.Entity))

function _M:init(t, no_default)
	engine.Entity.init(self, t, no_default)

	self.allow_backup_guardians = {}
	self.world_artifacts_pool = {}
	self.seen_special_farportals = {}
	self.unique_death = {}
	self.used_events = {}
	self.boss_killed = 0
	self.stores_restock = 1
	self.east_orc_patrols = 4
	self.birth = {}
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

--- Sets unique as dead
function _M:registerUniqueDeath(u)
	if u.randboss then return end
	self.unique_death[u.name] = true
end

--- Is unique dead?
function _M:isUniqueDead(name)
	return self.unique_death[name]
end

--- Seen a special farportal location
function _M:seenSpecialFarportal(name)
	self.seen_special_farportals[name] = true
end

--- Is farportal already used
function _M:hasSeenSpecialFarportal(name)
	return self.seen_special_farportals[name]
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
		syllablesStart ="Nature, Green, Loam, Earth, Heal, Root, Growth, Grow, Bark, Bloom, Satyr, Rain, Pure, Wild, Wind, Cure, Cleanse, Forest, Breeze, Oak, Willow, Tree, Balance, Flower, Ichor, Offal, Rot, Scab, Squalor, Taint, Undeath, Vile, Weep, Plague, Pox, Pus, Gore, Sepsis, Corruption, Filth, Muck, Fester, Toxin, Venom, Scorpion, Serpent, Viper, Cobra, Sulfur, Mire, Ooze, Wretch, Carrion, Bile, Bog, Sewer, Swamp, Corpse, Scum, Mold, Spider, Phlegm, Mucus, Morbus, Murk, Smear, Cyst",
		syllablesEnd = "arc, bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, brawn, burst, bringer, bearer, bender, blight, brand, break, born, black, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, flash, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, night, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, strike, striker, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, umbra, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, woe, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr,",
		rules = "$s$e",
	},
}

--- Generate randarts for this state
function _M:generateRandart(data)
	-- Setup level
	local lev = data.lev or rng.range(12, 50)
	local oldlev = game.level.level
	local oldclev = resolvers.current_level
	game.level.level = lev
	resolvers.current_level = math.ceil(lev * 1.4)

	-- Get a base object
	local base = data.base or game.zone:makeEntity(game.level, "object", data.base_filter or {ingore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}, special=function(e)
		return (not e.unique and e.randart_able) and (not e.material_level or e.material_level >= 2) and true or false
	end}, nil, true)
	if not base then game.level.level = oldlev resolvers.current_level = oldclev return end
	local o = base:cloneFull()

	local powers_list = engine.Object:loadList(o.randart_able, nil, nil, function(e) if e.rarity then e.rarity = math.ceil(e.rarity / 5) end end)
	o.randart_able = nil

	local allthemes = {
		'physical', 'mental', 'spell', 'defense', 'misc', 'fire',
		'lightning', 'acid', 'mind', 'arcane', 'blight', 'nature',
		'temporal', 'light', 'dark', 'antimagic'
	}
	local themes = {}
	if data.force_themes then
		for i, v in ipairs(data.force_themes) do
			table.removeFromList(allthemes, v)
			themes[v] = true
			if v == 'antimagic' then table.removeFromList(allthemes, 'spell', 'arcane', 'blight', 'temporal') end
			if v == 'spell' or v == 'arcane' or v == 'blight' or v == 'temporal' then table.removeFromList(allthemes, 'antimagic') end
		end
	end
	for i = #themes + 1, (data.nb_themes or 2) do
		if #allthemes == 0 then break end
		local v = rng.tableRemove(allthemes)
		themes[v] = true
		if v == 'antimagic' then table.removeFromList(allthemes, 'spell', 'arcane', 'blight', 'temporal') end
		if v == 'spell' or v == 'arcane' or v == 'blight' or v == 'temporal' then table.removeFromList(allthemes, 'antimagic') end
	end
	local themes_fct = function(e)
		for theme, _ in pairs(e.theme) do if themes[theme] then return true end end
		return false
	end

	-----------------------------------------------------------
	-- Determine power
	-----------------------------------------------------------
	local points = math.ceil(((lev * 0.7 + rng.range(5, 15)) / 2) * (data.power_points_factor or 1))
	local nb_powers = 1 + rng.dice(math.max(1, lev / 17), 2) + (data.nb_powers_add or 0)
	local powers = {}
	print("Powers:", points, nb_powers, lev)

	o.cost = o.cost + points * 7

	-- Select some powers
	local power_themes = {}
	for i = 1, nb_powers do
		local list = game.zone:computeRarities("powers", powers_list, game.level, themes_fct)
		local p = game.zone:pickEntity(list)
		if p then
			for t, _ in pairs(p.theme) do if themes[t] and randart_name_rules[t] then power_themes[t] = (power_themes[t] or 0) + 1 end end
			powers[p.name] = p:clone()
			powers[#powers+1] = powers[p.name]
		end
	end
	print("Selected powers:") table.print(powers)
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
	local namescheme = data.namescheme or ((ngt ~= ngd) and rng.range(1, 4) or rng.range(1, 3))
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

	o.unided_name = rng.table{"glowing","scintillating","rune-covered","unblemished","jewel-encrusted"}.." "..(o.unided_name or o.name)
	o.unique = name
	o.randart = true
	o.no_unique_lore = true
	o.rarity = rng.range(200, 290)

	print("Creating randart "..name.."("..o.unided_name..") with "..(themename or "nil").." with level "..lev)
	print(" * using themes", table.concat(table.keys(themes), ','))

	-----------------------------------------------------------
	-- Add ego properties
	-----------------------------------------------------------
	local nb_egos = data.egos or 3
	if o.egos and nb_egos > 0 then
		local legos = {}
		local been_greater = 0
		table.insert(legos, game.level:getEntitiesList("object/"..o.egos..":prefix"))
		table.insert(legos, game.level:getEntitiesList("object/"..o.egos..":suffix"))
		table.insert(legos, game.level:getEntitiesList("object/"..o.egos..":"))
		for i = 1, nb_egos or 3 do
			local egos = rng.table(legos)
			local list = {}
			local filter = nil
			if rng.percent(lev) and been_greater < 2 then been_greater = been_greater + 1 filter = function(e) return e.greater_ego end end
			for z = 1, #egos do list[#list+1] = egos[z].e end

			local ef = self:egoFilter(game.zone, game.level, "object", "randartego", o, {special=filter, forbid_power_source=data.forbid_power_source, power_source=data.power_source}, list, {})
			filter = ef.special

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

				-- OMFG this is ugly, there is a very rare combinaison that can result in a crash there, so we .. well, ignore it :/
				-- Sorry.
				local ok, err = pcall(table.mergeAddAppendArray, o, ego, true)
				if not ok then
					print("table.mergeAddAppendArray failed at creating a randart, retrying")
					game.level.level = oldlev
					resolvers.current_level = oldclev
					return self:generateRandart(data)
				end
			end
		end
		o.egos = nil o.egos_chance = nil o.force_ego = nil
	end
	-- Re-resolve with the (possibly) new resolvers
	o:resolve()
	o:resolve(nil, true)

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
	while hpoints > 0 and #powers >0 do
		i = util.boundWrap(i + 1, 1, #powers)
		local p = powers[i]
		if p.points <= hpoints then
			print(" * adding power: "..p.name)
			if p.wielder then
				o.wielder = o.wielder or {}
				merger(o.wielder, p.wielder)
			end
			if p.combat then
				o.combat = o.combat or {}
				merger(o.combat, p.combat)
			end
			if p.special_combat then
				o.special_combat = o.special_combat or {}
				merger(o.special_combat, p.special_combat)
			end
			if p.copy then merger(o, p.copy) end
		end
		hpoints = hpoints - p.points
		p.points = p.points * 1.5
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

		local p = bias_powers[i] and bias_powers[i]
		if p and p.points <= hpoints * 2 then
			if p.wielder then
				o.wielder = o.wielder or {}
				merger(o.wielder, p.wielder)
			end
			if p.copy then merger(o, p.copy) end
			print(" * adding bias power: "..p.name)
		end
		hpoints = hpoints - (p and p.points or 1) * 2
		if p then p.points = p.points * 1.5 end
	end

	-- Power source if none
	if not o.power_source then
		local ps = {}
		if themes.physical or themes.defense then ps.technique = true end
		if themes.mental then ps[rng.percent(50) and 'nature' or 'psionic'] = true end
		if themes.spell or themes.arcane or themes.blight or themes.temporal then ps.arcane = true end
		if themes.nature then ps.nature = true end
		if themes.antimagic then ps.antimagic = true end
		if not next(ps) then ps[rng.table{'technique','nature','arcane','psionic','antimagic'}] = true end
		o.power_source = ps
	end

	-- Setup the name
	o.name = name

	if data.post then
		data.post(o)
	end

	if data.add_pool then self:addWorldArtifact(o) end

	game.level.level = oldlev
	resolvers.current_level = oldclev
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

function _M:spawnWorldAmbush(enc, dx, dy)
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
	local g1 = game.level.map(dx, dy, engine.Map.TERRAIN)
	local g2 = game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN)
	local g = g1
	if not g or not g.can_encounter then g = g2 end
	if not g or not g.can_encounter then return false end

	if g.can_encounter == "desert" then gen.floor = "SAND" gen.wall = "PALMTREE" end

	local terrains = mod.class.Grid:loadList{"/data/general/grids/basic.lua", "/data/general/grids/forest.lua", "/data/general/grids/sand.lua"}
	terrains[gen.up].change_level_shift_back = true

	local zone = mod.class.Zone.new("ambush", {
		name = "Ambush!",
		level_range = {game.player.level, game.player.level},
		level_scheme = "player",
		max_level = 1,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = enc.width or 20, height = enc.height or 20,
--		no_worldport = true,
		all_lited = true,
		ambient_music = "last",
		max_material_level = util.bound(math.ceil(game.player.level / 10), 1, 5),
		min_material_level = util.bound(math.ceil(game.player.level / 10), 1, 5) - 1,
		generator =  {
			map = gen,
			actor = { class = "mod.class.generator.actor.Random", nb_npc = enc.nb or {1,1}, filters=enc.filters },
		},

		npc_list = mod.class.NPC:loadList("/data/general/npcs/all.lua", nil, nil, function(e) e.make_escort=nil end),
		grid_list = terrains,
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
	game:changeLevel(1, zone, {temporary_zone_shift=true})
	engine.ui.Dialog:simplePopup("Ambush!", "You have been ambushed!")

	end)
end

function _M:handleWorldEncounter(target)
	local enc = target.on_encounter
	if type(enc) == "function" then return enc() end
	if type(enc) == "table" then
		if enc.type == "ambush" then
			local x, y = target.x, target.y
			target:die()
			self:spawnWorldAmbush(enc, x, y)
		end
	end
end

--------------------------------------------------------------------
-- Ambient sounds stuff
--------------------------------------------------------------------
function _M:makeAmbientSounds(level, t)
	local s = {}
	level.data.ambient_bg_sounds = s

	for chan, data in pairs(t) do
		data.name = chan
		s[#s+1] = data
	end
end

function _M:playAmbientSounds(level, s, nb_keyframes)
	for i = 1, #s do
		local data = s[i]

		if data._sound then if not data._sound:playing() then data._sound = nil end end

		if not data._sound and nb_keyframes > 0 and rng.chance(math.ceil(data.chance / nb_keyframes)) then
			local f = rng.table(data.files)
			data._sound = game:playSound(f)
			local pos = {x=0,y=0,z=0}
			if data.random_pos then
				local a, r = rng.float(0, 2 * math.pi), rng.float(1, data.random_pos.rad or 10)
				pos.x = math.cos(a) * r
				pos.y = math.sin(a) * r
			end
--			print("===playing", data.name, f, data._sound)
			if data._sound then
				if data.volume_mod then data._sound:volume(data._sound:volume() * data.volume_mod) end
				if data.pitch then data._sound:pitch(data.pitch) end
			end
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

function _M:makeWeatherShader(level, shader, params)
	if not config.settings.tome.weather_effects then return end

	local ps = level.data.weather_shader or {}
	ps[#ps+1] = Shader.new(shader, params)
	level.data.weather_shader = ps
end

function _M:displayWeatherShader(level, ps, x, y, nb_keyframes)
	local dx, dy = level.map:getScreenUpperCorner() -- Display at map border, always, so it scrolls with the map

	local sx, sy = level.map._map:getScroll()
	local mapcoords = {(-sx + level.map.mx * level.map.tile_w) / level.map.viewport.width , (-sy + level.map.my * level.map.tile_h) / level.map.viewport.height}

	for j = 1, #ps do
		ps[j]:setUniform("mapCoord", mapcoords)
		ps[j].shad:use(true)
		core.display.drawQuad(x, y, level.map.viewport.width, level.map.viewport.height, 255, 255, 255, 255)
		ps[j].shad:use(false)
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

	-- If this is a reccuring donator, do not bother her/him
	if profile.auth and tonumber(profile.auth.donated) and profile.auth.sub == "yes" then
		print("Donation check: already a reccuring donator")
		return
	end

	-- Dont ask often
	local last = profile.mod.donations and profile.mod.donations.last_ask or 0
	local min_interval = 15 * 24 * 60 * 60 -- 1 month
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
	profile:saveModuleProfile("donations", {last_ask=os.time()})

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
			lore = 2,
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
			lore = 2.5,
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
			lore = 2.5,
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
			lore = 3,
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
			lore = 3,
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
			lore = 0,
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
			lore = 0,
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
			lore = 0,
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
			lore = 0,
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
			lore = 0,
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
			lore = 0,
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
			lore = 0,
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
			lore = 0,
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
			lore = 0,
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
			lore = 0,
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
		lore = 0,
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
		lore = 0,
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
		lore = 0,
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

	if filter.force_tome_drops or (not filter.tome and not filter.defined and not filter.special and not filter.unique and not filter.ego_chance and not filter.ego_filter and not filter.no_tome_drops) then
		filter = table.clone(filter)
		filter.tome = default_drops(zone, level, filter.tome_drops or "normal")
	end

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
		local l = m + (t.lore or 0)
		local total = l + (t.basic or 0)

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
			filter.ego_chance={tries = { {ego_chance=100, properties={"greater_ego"}, power_source=filter.power_source, forbid_power_source=filter.forbid_power_source}, {ego_chance=100, properties={"greater_ego"}, power_source=filter.power_source, forbid_power_source=filter.forbid_power_source} } }

		elseif r < ge then
			print("[TOME ENTITY FILTER] selected Greater + Ego", r, ge)
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "unique"
			filter.ego_chance={tries = { {ego_chance=100, properties={"greater_ego"}, power_source=filter.power_source, forbid_power_source=filter.forbid_power_source}, {ego_chance=100, not_properties={"greater_ego"}, power_source=filter.power_source, forbid_power_source=filter.forbid_power_source} }}

		elseif r < g then
			print("[TOME ENTITY FILTER] selected Greater", r, g)
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "unique"
			filter.ego_chance={tries = { {ego_chance=100, properties={"greater_ego"}, power_source=filter.power_source, forbid_power_source=filter.forbid_power_source} } }

		elseif r < de then
			print("[TOME ENTITY FILTER] selected Double Ego", r, de)
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "unique"
			filter.ego_chance={tries = { {ego_chance=100, not_properties={"greater_ego"}, power_source=filter.power_source, forbid_power_source=filter.forbid_power_source}, {ego_chance=100, not_properties={"greater_ego"}, power_source=filter.power_source, forbid_power_source=filter.forbid_power_source} }}

		elseif r < e then
			print("[TOME ENTITY FILTER] selected Ego", r, e)
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "unique"
			filter.ego_chance={tries = { {ego_chance=100, not_properties={"greater_ego"}, power_source=filter.power_source, forbid_power_source=filter.forbid_power_source} } }

		elseif r < m then
			print("[TOME ENTITY FILTER] selected Money", r, m)
			filter.special = function(e) return e.type == "money" or e.type == "gem" end

		elseif r < l then
			print("[TOME ENTITY FILTER] selected Lore", r, m)
			filter.special = function(e) return e.lore and true or false end

		else
			print("[TOME ENTITY FILTER] selected basic", r, total)
			filter.not_properties = filter.not_properties or {}
			filter.not_properties[#filter.not_properties+1] = "unique"
			filter.ego_chance = -1000
		end
	end

	if filter.random_object then
		print("[TOME ENTITY FILTER] random object requested, removing ego chances")
		filter.ego_chance = -1000
	end

	-- By default we dont apply special filters, but we always provide one so that entityFilter is called
	return filter
end

function _M:entityFilter(zone, e, filter, type)
	if filter.forbid_power_source then
		if e.power_source then
			for k, _ in pairs(filter.forbid_power_source) do
				if e.power_source[k] then return false end
			end
		end
	end

	if filter.power_source and e.power_source then
		local ok = false
		for k, _ in pairs(filter.power_source) do
			if e.power_source[k] then ok = true break end
		end
		if not ok then return false end
	end

	if type == "object" then
		if not filter.ingore_material_restriction then
			local min_mlvl = util.getval(zone.min_material_level)
			local max_mlvl = util.getval(zone.max_material_level)
			if min_mlvl and not e.material_level_min_only then
				if not e.material_level then return true end
				if e.material_level < min_mlvl then return false end
			end

			if max_mlvl then
				if not e.material_level then return true end
				if e.material_level > max_mlvl then return false end
			end
		end
		if e.lore and e.rarity and util.getval(zone.no_random_lore) then return false end
		if filter.random_object and not e.randart_able then return false end
		return true
	else
		return true
	end
end

function _M:entityFilterPost(zone, level, type, e, filter)
	if type == "actor" then
		if filter.random_boss and not e.unique then
			if _G.type(filter.random_boss) == "boolean" then filter.random_boss = {}
			else filter.random_boss = table.clone(filter.random_boss, true) end
			filter.random_boss.level = filter.random_boss.level or zone:level_adjust_level(level, zone, type)
			filter.random_boss.class_filter = filter.random_boss.class_filter or function(c)
				if e.power_source then
					for ps, _ in pairs(e.power_source) do if c.power_source and c.power_source[ps] then return true end end
					return false
				end
				if e.not_power_source then
					for ps, _ in pairs(e.not_power_source) do if c.power_source and c.power_source[ps] then return false end end
					return true
				end
				return true
			end

			e = self:createRandomBoss(e, filter.random_boss)
		elseif filter.random_elite and not e.unique then
			if _G.type(filter.random_elite) == "boolean" then filter.random_elite = {}
			else filter.random_elite = table.clone(filter.random_elite, true) end
			local lev = filter.random_elite.level or zone:level_adjust_level(level, zone, type)
			local base = {
				nb_classes=1,
				rank=3.2, ai = "tactical",
				life_rating = filter.random_elite.life_rating or function(v) return v * 1.3 + 2 end,
				loot_quality = "store",
				loot_quantity = 0,
				drop_equipment = false,
				no_loot_randart = true,
				resources_boost = 1.5,
				talent_cds_factor = (lev <= 10) and 3 or ((lev <= 20) and 2 or nil),
				class_filter = function(c)
					if e.power_source then
						for ps, _ in pairs(e.power_source) do if c.power_source and c.power_source[ps] then return true end end
						return false
					end
					if e.not_power_source then
						for ps, _ in pairs(e.not_power_source) do if c.power_source and c.power_source[ps] then return false end end
						return true
					end
					return true
				end,
				level = lev,
				nb_rares = filter.random_elite.nb_rares or 1,
				check_talents_level = true,
				post = function(b, data)
					if data.level <= 20 then
						b.inc_damage = b.inc_damage or {}
						b.inc_damage.all = (b.inc_damage.all or 0) - 40 * (20 - data.level + 1) / 20
					end

					-- Drop
					for i = 1, data.nb_rares do
						local o = game.zone:makeEntity(game.level,"object", {random_object=true}, nil, true)
						if o then
							b:addObject(b.INVEN_INVEN, o)
							game.zone:addEntity(game.level, o, "object")
						end
					end
				end,
			}
			e = self:createRandomBoss(e, table.merge(base, filter.random_elite, true))
		end
	elseif type == "object" then
		if filter.random_object and not e.unique and e.randart_able then
			local data = _G.type(filter.random_object) == "table" and filter.random_object or {}
			local lev = math.max(4, game.zone:level_adjust_level(game.level, game.zone, "object"))
			e = game.state:generateRandart{
				lev = lev,
				egos = 0,
				power_points_factor = data.power_points_factor or 3,
				nb_powers_add = data.nb_powers_add or 1,
				nb_themes = data.nb_themes or math.max(2, math.floor(lev / 20)),
				force_themes = data.force_themes or nil,
				base = e,
				post = function(o) o.rare = true o.unique = nil o.randart = nil end,
				namescheme = 3
			}
		end
	end

	return e
end

function _M:egoFilter(zone, level, type, etype, e, ego_filter, egos_list, picked_etype)
	if type ~= "object" then return ego_filter end

	if not ego_filter then ego_filter = {}
	else ego_filter = table.clone(ego_filter, true) end

	local arcane_check = false
	local nature_check = false
	local am_check = false
	for i = 1, #egos_list do
		local e = egos_list[i]
		if e.power_source and e.power_source.arcane then arcane_check = true end
		if e.power_source and e.power_source.nature then nature_check = true end
		if e.power_source and e.power_source.antimagic then am_check = true end
	end

	local fcts = {}

	if arcane_check then
		fcts[#fcts+1] = function(ego) return not ego.power_source or not ego.power_source.nature or rng.percent(20) end
		fcts[#fcts+1] = function(ego) return not ego.power_source or not ego.power_source.antimagic end
	end
	if nature_check then
		fcts[#fcts+1] = function(ego) return not ego.power_source or not ego.power_source.arcane or rng.percent(20) end
	end
	if am_check then
		fcts[#fcts+1] = function(ego) return not ego.power_source or not ego.power_source.arcane end
	end

	if #fcts > 0 then
		local old = ego_filter.special
		ego_filter.special = function(ego)
			for i = 1, #fcts do
				if not fcts[i](ego) then return false end
			end
			if old and not old(ego) then return false end
			return true
		end
	end

	return ego_filter
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
	-- Maze
	{ name="maze", rarity=3, gen=function(data)
		return {
		class = "engine.generator.map.Maze",
		floor = data:getFloor(),
		wall = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
		door = data:getDoor(),
	} end, guardian_alert=true },
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
	-- Building
--[[ not yet	{ name="building", rarity=4, gen=function(data)
		return {
		class = "engine.generator.map.Building",
		lite_room_chance = rng.range(0, 100),
		max_block_w = rng.range(14, 20), max_block_h = rng.range(14, 20),
		max_building_w = rng.range(4, 8), max_building_h = rng.range(4, 8),
		floor = data:getFloor(),
		wall = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
		door = data:getDoor(),
	} end },
]]
	-- "Octopus"
	{ name="octopus", rarity=6, gen=function(data)
		return {
		class = "engine.generator.map.Octopus",
		main_radius = {0.3, 0.4},
		arms_radius = {0.1, 0.2},
		arms_range = {0.7, 0.8},
		nb_rooms = {5, 9},
		['.'] = data:getFloor(),
		['#'] = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
		door = data:getDoor(),
	} end },
}

local random_zone_themes = {
	-- Trees
	{ name="trees", rarity=3, gen=function() return {
		load_grids = {"/data/general/grids/forest.lua"},
		getDoor = function(self) return "GRASS" end,
		getFloor = function(self) return function() if rng.chance(20) then return "FLOWER" else return "GRASS" end end end,
		getWall = function(self) return "TREE" end,
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
	{ name="underground", rarity=5, gen=function() return {
		load_grids = {"/data/general/grids/underground.lua"},
		getDoor = function(self) return "UNDERGROUND_FLOOR" end,
		getFloor = function(self) return "UNDERGROUND_FLOOR" end,
		getWall = function(self) return {"UNDERGROUND_TREE","UNDERGROUND_TREE2","UNDERGROUND_TREE3","UNDERGROUND_TREE4","UNDERGROUND_TREE5","UNDERGROUND_TREE6","UNDERGROUND_TREE7","UNDERGROUND_TREE8","UNDERGROUND_TREE9","UNDERGROUND_TREE10","UNDERGROUND_TREE11","UNDERGROUND_TREE12","UNDERGROUND_TREE13","UNDERGROUND_TREE14","UNDERGROUND_TREE15","UNDERGROUND_TREE16","UNDERGROUND_TREE17","UNDERGROUND_TREE18","UNDERGROUND_TREE19","UNDERGROUND_TREE20",} end,
		getUp = function(self) return "UNDERGROUND_LADDER_UP" end,
		getDown = function(self) return "UNDERGROUND_LADDER_DOWN" end,
	} end },
	-- Crystals
	{ name="crystal", rarity=4, gen=function() return {
		load_grids = {"/data/general/grids/underground.lua"},
		getDoor = function(self) return "CRYSTAL_FLOOR" end,
		getFloor = function(self) return "CRYSTAL_FLOOR" end,
		getWall = function(self) return {"CRYSTAL_WALL","CRYSTAL_WALL2","CRYSTAL_WALL3","CRYSTAL_WALL4","CRYSTAL_WALL5","CRYSTAL_WALL6","CRYSTAL_WALL7","CRYSTAL_WALL8","CRYSTAL_WALL9","CRYSTAL_WALL10","CRYSTAL_WALL11","CRYSTAL_WALL12","CRYSTAL_WALL13","CRYSTAL_WALL14","CRYSTAL_WALL15","CRYSTAL_WALL16","CRYSTAL_WALL17","CRYSTAL_WALL18","CRYSTAL_WALL19","CRYSTAL_WALL20",} end,
		getUp = function(self) return "CRYSTAL_LADDER_UP" end,
		getDown = function(self) return "CRYSTAL_LADDER_DOWN" end,
	} end },
	-- Sand
	{ name="sand", rarity=3, gen=function() return {
		load_grids = {"/data/general/grids/sand.lua"},
		getDoor = function(self) return "UNDERGROUND_SAND" end,
		getFloor = function(self) return "UNDERGROUND_SAND" end,
		getWall = function(self) return "SANDWALL" end,
		getUp = function(self) return "SAND_LADDER_UP" end,
		getDown = function(self) return "SAND_LADDER_DOWN" end,
	} end },
	-- Desert
	{ name="desert", rarity=3, gen=function() return {
		load_grids = {"/data/general/grids/sand.lua"},
		getDoor = function(self) return "SAND" end,
		getFloor = function(self) return "SAND" end,
		getWall = function(self) return "PALMTREE" end,
		getUp = function(self) return "SAND_UP"..self.less_dir end,
		getDown = function(self) return "SAND_DOWN"..self.more_dir end,
	} end },
	-- Slime
	{ name="slime", rarity=4, gen=function() return {
		load_grids = {"/data/general/grids/slime.lua"},
		getDoor = function(self) return "SLIME_DOOR" end,
		getFloor = function(self) return "SLIME_FLOOR" end,
		getWall = function(self) return "SLIME_WALL" end,
		getUp = function(self) return "SLIME_UP" end,
		getDown = function(self) return "SLIME_DOWN" end,
	} end },
}

function _M:createRandomZone(zbase)
	zbase = zbase or {}

	------------------------------------------------------------
	-- Select theme
	------------------------------------------------------------
	local themes = {}
	for i, theme in ipairs(random_zone_themes) do for j = 1, 100 / theme.rarity do themes[#themes+1] = theme end end
	local theme = rng.table(themes)
	print("[RANDOM ZONE] Using theme", theme.name)
	local data = theme.gen()

	local grids = {}
	for i, file in ipairs(data.load_grids) do
		mod.class.Grid:loadList(file, nil, grids)
	end

	------------------------------------------------------------
	-- Misc data
	------------------------------------------------------------
	data.depth = zbase.depth or rng.range(2, 4)
	data.min_lev, data.max_lev = zbase.min_lev or game.player.level, zbase.max_lev or game.player.level + 15
	data.w, data.h = zbase.w or rng.range(40, 60), zbase.h or rng.range(40, 60)
	data.max_material_level = util.bound(math.ceil(data.min_lev / 10), 1, 5)
	data.min_material_level = data.max_material_level - 1

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
	local layouts = {}
	for i, layout in ipairs(random_zone_layouts) do for j = 1, 100 / layout.rarity do layouts[#layouts+1] = layout end end
	local layout = rng.table(layouts)
	print("[RANDOM ZONE] Using layout", layout.name)

	------------------------------------------------------------
	-- Select Music
	------------------------------------------------------------
	local musics = {}
	for i, file in ipairs(fs.list("/data/music/")) do
		if file:find("%.ogg$") then musics[#musics+1] = file end
	end

	------------------------------------------------------------
	-- Create a boss
	------------------------------------------------------------
	local npcs = mod.class.NPC:loadList("/data/general/npcs/random_zone.lua")
	local list = {}
	for _, e in ipairs(npcs) do
		if e.rarity and e.level_range and e.level_range[1] <= data.min_lev and (not e.level_range[2] or e.level_range[2] >= data.min_lev) and e.rank > 1 and not e.unique then
			list[#list+1] = e
		end
	end
	local base = rng.table(list)
	local boss, boss_id = self:createRandomBoss(base, {level=data.min_lev + data.depth + rng.range(2, 4)})
	npcs[boss_id] = boss

	------------------------------------------------------------
	-- Entities
	------------------------------------------------------------
	local base_nb = math.sqrt(data.w * data.h)
	local nb_npc = { math.ceil(base_nb * 0.4), math.ceil(base_nb * 0.6) }
	local nb_trap = { math.ceil(base_nb * 0.1), math.ceil(base_nb * 0.2) }
	local nb_object = { math.ceil(base_nb * 0.06), math.ceil(base_nb * 0.12) }
	if rng.percent(20) then nb_trap = {0,0} end
	if rng.percent(10) then nb_object = {0,0} end

	------------------------------------------------------------
	-- Name
	------------------------------------------------------------
	local ngd = NameGenerator.new(randart_name_rules.default2)
	local name = ngd:generate()
	local short_name = name:lower():gsub("[^a-z]", "_")

	------------------------------------------------------------
	-- Final glue
	------------------------------------------------------------
	local zone = mod.class.Zone.new(short_name, {
		name = name,
		level_range = {data.min_lev, data.max_lev},
		level_scheme = "player",
		max_level = data.depth,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = data.w, height = data.h,
		color_shown = data.tint_s,
		color_obscure = data.tint_o,
		ambient_music = rng.table(musics),
		min_material_level = data.min_material_level,
		max_material_level = data.max_material_level,
		no_random_lore = true,
		persistent = "zone_temporary",
		reload_lists = false,
		generator =  {
			map = layout.gen(data),
			actor = { class = "mod.class.generator.actor.Random", nb_npc = nb_npc, guardian = boss_id, abord_no_guardian=true, guardian_alert=layout.guardian_alert },
			trap = { class = "engine.generator.trap.Random", nb_trap = nb_trap, },
			object = { class = "engine.generator.object.Random", nb_object = nb_object, },
		},
		levels = { [1] = { generator = { map = { up = data:getFloor() } } } },
		basic_floor = util.getval(data:getFloor()),
		npc_list = npcs,
		grid_list = grids,
		object_list = mod.class.Object:loadList("/data/general/objects/objects.lua"),
		trap_list = mod.class.Trap:loadList("/data/general/traps/alarm.lua"),
	})
	return zone, boss
end

function _M:createRandomBoss(base, data)
	local b = base:clone()
	data = data or {level=1}

	------------------------------------------------------------
	-- Basic stuff, name, rank, ...
	------------------------------------------------------------
	local ngd, name
	if base.random_name_def then
		ngd = NameGenerator2.new("/data/languages/names/"..base.random_name_def:gsub("#sex#", base.female and "female" or "male")..".txt")
		name = ngd:generate(nil, base.random_name_min_syllables, base.random_name_max_syllables)
	else
		ngd = NameGenerator.new(randart_name_rules.default)
		name = ngd:generate()
	end
	if data.name_scheme then
		b.name = data.name_scheme:gsub("#rng#", name):gsub("#base#", b.name)
	else
		b.name = name.." the "..b.name
	end
	b.unique = b.name
	b.randboss = true
	local boss_id = "RND_BOSS_"..b.name:upper():gsub("[^A-Z]", "_")
	b.define_as = boss_id
	b.color = colors.VIOLET
	b.rank = data.rank or (rng.percent(30) and 4 or 3.5)
	b.level_range[1] = data.level
	b.fixed_rating = true
	if data.life_rating then
		b.life_rating = data.life_rating(b.life_rating)
	else
		b.life_rating = b.life_rating * 1.7 + rng.range(4, 9)
	end
	b.max_life = b.max_life or 150

	if b.can_multiply or b.clone_on_hit then
		b.clone_base = base:clone()
		b.clone_base:resolve()
		b.clone_base:resolve(nil, true)
	end

	-- Force resolving some stuff
	if type(b.max_life) == "table" and b.max_life.__resolver then b.max_life = resolvers.calc[b.max_life.__resolver](b.max_life, b, b, b, "max_life", {}) end

	-- All bosses have alll body parts .. yes snake bosses can use archery and so on ..
	-- This is to prevent them from having unusable talents
	b.inven = {}
	b.body = { INVEN = 1000, QS_MAINHAND = 1, QS_OFFHAND = 1, MAINHAND = 1, OFFHAND = 1, FINGER = 2, NECK = 1, LITE = 1, BODY = 1, HEAD = 1, CLOAK = 1, HANDS = 1, BELT = 1, FEET = 1, TOOL = 1, QUIVER = 1 }
	b:initBody()

	b:resolve()

	-- Start with sustains sustained
	b[#b+1] = resolvers.sustains_at_birth()

	-- Leveling stats
	b.autolevel = "random_boss"
	b.auto_stats = {}

	-- Always smart
	if data.ai then b.ai = data.ai
	else b.ai = (b.rank > 3) and "tactical" or b.ai
	end
	b.ai_state = { talent_in=1, ai_move=data.ai_move or "move_astar" }

	-- Remove default equipment, if any
	local todel = {}
	for k, resolver in pairs(b) do if type(resolver) == "table" and resolver.__resolver and (resolver.__resolver == "equip" or resolver.__resolver == "drops") then todel[#todel+1] = k end end
	for _, k in ipairs(todel) do b[k] = nil end

	-- Boss worthy drops
	b[#b+1] = resolvers.drops{chance=100, nb=data.loot_quantity or 3, {tome_drops=data.loot_quality or "boss"} }
	if not data.no_loot_randart then b[#b+1] = resolvers.drop_randart{} end

	-- On die
	if data.on_die then
		b.rng_boss_on_die = b.on_die
		b.rng_boss_on_die_custom = data.on_die
		b.on_die = function(self, src)
			self:check("rng_boss_on_die_custom", src)
			self:check("rng_boss_on_die", src)
		end
	end

	------------------------------------------------------------
	-- Apply talents from classes
	------------------------------------------------------------

	-- Apply a class
	local Birther = require "engine.Birther"
	b.learn_tids = {}
	local function apply_class(class)
		local mclasses = Birther.birth_descriptor_def.class
		local mclass = nil
		for name, data in pairs(mclasses) do
			if data.descriptor_choices and data.descriptor_choices.subclass and data.descriptor_choices.subclass[class.name] then mclass = data break end
		end
		if not mclass then return end

		print("Adding to random boss class", class.name, mclass.name)
		if config.settings.cheat then b.desc = (b.desc or "").."\nClass: "..class.name end

		-- Add stats
		b.stats = b.stats or {}
		for stat, v in pairs(class.stats or {}) do
			b.stats[stat] = (b.stats[stat] or 10) + v
			for i = 1, v do b.auto_stats[#b.auto_stats+1] = b.stats_def[stat].id end
		end

		-- Add talent categories
		for tt, d in pairs(mclass.talents_types or {}) do b:learnTalentType(tt, true) b:setTalentTypeMastery(tt, (b:getTalentTypeMastery(tt) or 1) + d[2]) end
		for tt, d in pairs(mclass.unlockable_talents_types or {}) do b:learnTalentType(tt, true) b:setTalentTypeMastery(tt, (b:getTalentTypeMastery(tt) or 1) + d[2]) end
		for tt, d in pairs(class.talents_types or {}) do b:learnTalentType(tt, true) b:setTalentTypeMastery(tt, (b:getTalentTypeMastery(tt) or 1) + d[2]) end
		for tt, d in pairs(class.unlockable_talents_types or {}) do b:learnTalentType(tt, true) b:setTalentTypeMastery(tt, (b:getTalentTypeMastery(tt) or 1) + d[2]) end

		-- Add starting equipment
		local apply_resolvers = function(k, resolver)
			if type(resolver) == "table" and resolver.__resolver and resolver.__resolver == "equip" then
				resolver[1].id = nil
				-- Make sure we equip some nifty stuff instead of player's starting iron stuff
				for i, d in ipairs(resolver[1]) do
					d.name = nil
					d.ego_chance = nil
					d.tome_drops = data.loot_quality or "boss"
					d.force_drop = (data.drop_equipment == nil) and true or data.drop_equipment
				end
				b[#b+1] = resolver
			elseif k == "birth_create_alchemist_golem" then
				b.birth_create_alchemist_golem = resolver
			elseif k == "necrotic_aura_base_souls" then
				b.necrotic_aura_base_souls = util.bound(1 + math.ceil(data.level / 10), 1, 10)
			end
		end
		for k, resolver in pairs(mclass.copy or {}) do apply_resolvers(k, resolver) end
		for k, resolver in pairs(class.copy or {}) do apply_resolvers(k, resolver) end

		-- Starting talents are autoleveling
		local tres = nil
		for k, resolver in pairs(b) do if type(resolver) == "table" and resolver.__resolver and resolver.__resolver == "talents" then tres = resolver break end end
		if not tres then tres = resolvers.talents{} b[#b+1] = tres end
		for tid, v in pairs(class.talents or {}) do
			local t = b:getTalentFromId(tid)
			if not t.no_npc_use and (not t.random_boss_rarity or rng.chance(t.random_boss_rarity)) then
				local max = (t.points == 1) and 1 or math.ceil(t.points * 1.2)
				local step = max / 50
				tres[1][tid] = v + math.ceil(step * data.level)
			end
		end

		-- Select additional talents from the class
		local list = {}
		for _, t in pairs(b.talents_def) do
			if b.talents_types[t.type[1]] and not t.no_npc_use then
				local ok = true
				if data.check_talents_level and rawget(t, 'require') then
					local req = t.require
					if type(req) == "function" then req = req(b, t) end
					if req and req.level and util.getval(req.level, 1) > math.ceil(data.level/2) then
						print("Random boss forbade talent because of level", t.name, data.level)
						ok = false
					end
				end

				if ok then list[t.id] = true end
			end
		end
		local nb = 4 + (data.level / 7)
		nb = math.max(rng.range(math.floor(nb * 0.7), math.ceil(nb * 1.3)), 1)
		print("Adding "..nb.." random class talents to boss")

		for i = 1, nb do
			local tid = rng.tableIndex(list, b.learn_tids)
			local t = b:getTalentFromId(tid)
			if t then
				print(" * talent", tid)
				local max = (t.points == 1) and 1 or math.ceil(t.points * 1.2)
				local step = max / 50
				b.learn_tids[tid] = math.ceil(step * data.level)
			end
		end
	end

	-- Select two classes
	local classes = Birther.birth_descriptor_def.subclass
	local list = {}
	local force_classes = data.force_classes and table.clone(data.force_classes)
	for name, cdata in pairs(classes) do
		if force_classes and force_classes[cdata.name] then apply_class(table.clone(cdata, true)) force_classes[cdata.name] = nil
		elseif not cdata.not_on_random_boss and (not data.class_filter or data.class_filter(cdata))then list[#list+1] = cdata
		end
	end
	for i = 1, data.nb_classes or 2 do
		local c = rng.tableRemove(list)
		if not c then break end
		apply_class(table.clone(c, true))
	end

	b.rnd_boss_on_added_to_level = b.on_added_to_level
	b._rndboss_resources_boost = data.resources_boost
	b._rndboss_talent_cds = data.talent_cds_factor
	b.on_added_to_level = function(self, ...)
		self:check("birth_create_alchemist_golem")
		for tid, lev in pairs(self.learn_tids) do
			if self:getTalentLevelRaw(tid) < lev then
				self:learnTalent(tid, true, lev - self:getTalentLevelRaw(tid))
			end
		end
		self:check("rnd_boss_on_added_to_level", ...)
		self.rnd_boss_on_added_to_level = nil
		self.learn_tids = nil
		self.on_added_to_level = nil

		-- Increase talent cds
		if self._rndboss_talent_cds then
			local fact = self._rndboss_talent_cds
			for tid, _ in pairs(self.talents) do
				local t = self:getTalentFromId(tid)
				if t.mode ~= "passive" then
					local bcd = self:getTalentCooldown(t) or 0
					self.talent_cd_reduction[tid] = (self.talent_cd_reduction[tid] or 0) - math.ceil(bcd * (fact - 1))
				end
			end
		end

		-- Cheat a bit with ressources
		self.max_mana = self.max_mana * (self._rndboss_resources_boost or 3) self.mana_regen = self.mana_regen + 1
		self.max_vim = self.max_vim * (self._rndboss_resources_boost or 3) self.vim_regen = self.vim_regen + 1
		self.max_stamina = self.max_stamina * (self._rndboss_resources_boost or 3) self.stamina_regen = self.stamina_regen + 1
		self.max_psi = self.max_psi * (self._rndboss_resources_boost or 3) self.psi_regen = self.psi_regen + 2
		self.equilibrium_regen = self.equilibrium_regen - 2
		self:resetToFull()
	end

	-- Anything else
	if data.post then data.post(b, data) end

	return b, boss_id
end

function _M:debugRandomZone()
	local zone = self:createRandomZone()
	game:changeLevel(zone.max_level, zone)

	game.level.map:liteAll(0, 0, game.level.map.w, game.level.map.h)
	game.level.map:rememberAll(0, 0, game.level.map.w, game.level.map.h)
	for i = 0, game.level.map.w - 1 do
		for j = 0, game.level.map.h - 1 do
			local trap = game.level.map(i, j, game.level.map.TRAP)
			if trap then
				trap:setKnown(game.player, true)
				game.level.map:updateMap(i, j)
			end
		end
	end
end

function _M:locationRevealAround(x, y)
	game.level.map.lites(x, y, true)
	game.level.map.remembers(x, y, true)
	for _, c in pairs(util.adjacentCoords(x, y)) do
		game.level.map.lites(x+c[1], y+c[2], true)
		game.level.map.remembers(x+c[1], y+c[2], true)
	end
end

function _M:doneEvent(id)
	return self.used_events[id]
end

function _M:canEventGrid(level, x, y)
	return game.player:canMove(x, y) and not level.map.attrs(x, y, "no_teleport") and not level.map:checkAllEntities(x, y, "change_level")
end

function _M:canEventGridRadius(level, x, y, radius, min)
	local list = {}
	for i = -radius, radius do for j = -radius, radius do
		if game.state:canEventGrid(level, x+i, y+j) then list[#list+1] = {x=x+i, y=y+j} end
	end end

	if #list < min then return false
	else return list end
end

function _M:findEventGrid(level)
	local x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
	local tries = 0
	while not self:canEventGrid(level, x, y) and tries < 100 do
		x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
		tries = tries + 1
	end
	if tries >= 100 then return false end
	return x, y
end

function _M:findEventGridRadius(level, radius, min)
	local x, y = rng.range(3, level.map.w - 4), rng.range(3, level.map.h - 4)
	local tries = 0
	while not self:canEventGridRadius(level, x, y, radius, min) and tries < 100 do
		x, y = rng.range(3, level.map.w - 4), rng.range(3, level.map.h - 4)
		tries = tries + 1
	end
	if tries >= 100 then return false end
	return self:canEventGridRadius(level, x, y, radius, min)
end

function _M:startEvents()
	if not game.zone.events then print("No zone events loaded") return end

	if not game.zone.assigned_events then
		local levels = {}
		if game.zone.events_by_level then
			levels[game.level.level] = {}
		else
			for i = 1, game.zone.max_level do levels[i] = {} end
		end

		-- Generate the events list for this zone, eventually loading from group files
		local evts, mevts = {}, {}
		for i, e in ipairs(game.zone.events) do
			if e.name then if e.minor then mevts[#mevts+1] = e else evts[#evts+1] = e end
			elseif e.group then
				local f, err = loadfile("/data/general/events/groups/"..e.group..".lua")
				if not f then error(err) end
				setfenv(f, setmetatable({level=game.level, zone=game.zone}, {__index=_G}))
				local list = f()
				for j, ee in ipairs(list) do
					if e.percent_factor and ee.percent then ee.percent_factor = math.floor(ee.percent * e.percent_factor) end
					if ee.name then if ee.minor then mevts[#mevts+1] = ee else evts[#evts+1] = ee end end
				end
			end
		end

		-- Randomize the order they are checked as
		table.shuffle(evts)
		table.print(evts)
		table.shuffle(mevts)
		table.print(mevts)
		for i, e in ipairs(evts) do
			-- If we allow it, try to find a level to host it
			if (e.always or rng.percent(e.percent)) and (not e.unique or not self:doneEvent(e.name)) then
				local lev = nil
				local forbid = e.forbid or {}
				forbid = table.reverse(forbid)
				if game.zone.events_by_level then
					lev = game.level.level
				else
					if game.zone.events.one_per_level then
						local list = {}
						for i = 1, #levels do if #levels[i] == 0 and not forbid[i] then list[#list+1] = i end end
						if #list > 0 then
							lev = rng.table(list)
						end
					else
						if forbid then
							local t = table.genrange(1, game.zone.max_level, true)
							t = table.minus_keys(t, forbid)
							lev = rng.table(table.keys(t))
						else
							lev = rng.range(1, game.zone.max_level)
						end
					end
				end

				if lev then
					lev = levels[lev]
					lev[#lev+1] = e.name
				end
			end
		end
		for i, e in ipairs(mevts) do
			local forbid = e.forbid or {}
			forbid = table.reverse(forbid)

			local start, stop = 1, game.zone.max_level
			if game.zone.events_by_level then start, stop = game.level.level, game.level.level end
			for lev = start, stop do
				if rng.percent(e.percent) and not forbid[lev] then
					local lev = levels[lev]
					lev[#lev+1] = e.name

					if e.max_repeat then
						local nb = 1
						local p = e.percent
						while nb <= e.max_repeat do
							if rng.percent(p) then
								lev[#lev+1] = e.name
							else
								break
							end
							p = p / 2
						end
					end
				end
			end
		end

		game.zone.assigned_events = levels
	end

	return function()
		print("Assigned events list")
		table.print(game.zone.assigned_events)

		for i, e in ipairs(game.zone.assigned_events[game.level.level] or {}) do
			local f, err = loadfile("/data/general/events/"..e..".lua")
			if not f then error(err) end
			setfenv(f, setmetatable({level=game.level, zone=game.zone, event_id=e.name, Map=Map}, {__index=_G}))
			f()
		end
		game.zone.assigned_events[game.level.level] = {}
		if game.zone.events_by_level then game.zone.assigned_events = nil end
	end
end
