-- TE4 - T-Engine 4
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

require "engine.class"
local lpeg = require "lpeg"

module(..., package.seeall, class.make)

local number = lpeg.R"09" ^ 0
local rule_pattern = "$" * lpeg.C(number) * lpeg.C(lpeg.S"smePpvc?")

--- Creates a random name generator with a set of rules
-- The lang_def parameter is a table that must look like this:<br/>
-- {<br/>
-- 	phonemesVocals = "a, e, i, o, u, y",<br/>
-- 	phonemesConsonants = "b, c, ch, ck, cz, d, dh, f, g, gh, h, j, k, kh, l, m, n, p, ph, q, r, rh, s, sh, t, th, ts, tz, v, w, x, z, zh",<br/>
-- 	syllablesStart = "Aer, Al, Am, An, Ar, Arm, Arth, B, Bal, Bar, Be, Bel, Ber, Bok, Bor, Bran, Breg, Bren, Brod, Cam, Chal, Cham, Ch, Cuth, Dag, Daim, Dair, Del, Dr, Dur, Duv, Ear, Elen, Er, Erel, Erem, Fal, Ful, Gal, G, Get, Gil, Gor, Grin, Gun, H, Hal, Han, Har, Hath, Hett, Hur, Iss, Khel, K, Kor, Lel, Lor, M, Mal, Man, Mard, N, Ol, Radh, Rag, Relg, Rh, Run, Sam, Tarr, T, Tor, Tul, Tur, Ul, Ulf, Unr, Ur, Urth, Yar, Z, Zan, Zer",<br/>
-- 	syllablesMiddle = "de, do, dra, du, duna, ga, go, hara, kaltho, la, latha, le, ma, nari, ra, re, rego, ro, rodda, romi, rui, sa, to, ya, zila",<br/>
-- 	syllablesEnd = "bar, bers, blek, chak, chik, dan, dar, das, dig, dil, din, dir, dor, dur, fang, fast, gar, gas, gen, gorn, grim, gund, had, hek, hell, hir, hor, kan, kath, khad, kor, lach, lar, ldil, ldir, leg, len, lin, mas, mnir, ndil, ndur, neg, nik, ntir, rab, rach, rain, rak, ran, rand, rath, rek, rig, rim, rin, rion, sin, sta, stir, sus, tar, thad, thel, tir, von, vor, yon, zor",<br/>
-- 	rules = "$s$v$35m$10m$e",<br/>
-- }<br/>
-- The rules field defines how names are generated. Any special character found inside (starting with a $, with an optional number and a character) will be
-- replaced by a random word from one of the lists.<br/>
-- $P = syllablesPre<br/>
-- $s = syllablesStart<br/>
-- $m = syllablesMiddle<br/>
-- $e = syllablesEnd<br/>
-- $p = syllablesPost<br/>
-- $v = phonemesVocals<br/>
-- $c = phonemesConsonants<br/>
-- If a number is give it is a percent chance for this part to exist
function _M:init(lang_def)
	local def = {}
	if lang_def.phonemesVocals then def.v = lang_def.phonemesVocals:split(", ") end
	if lang_def.phonemesConsonants then def.c = lang_def.phonemesConsonants:split(", ") end
	if lang_def.syllablesPre then def.P = lang_def.syllablesPre:split(", ") end
	if lang_def.syllablesStart then def.s = lang_def.syllablesStart:split(", ") end
	if lang_def.syllablesMiddle then def.m = lang_def.syllablesMiddle:split(", ") end
	if lang_def.syllablesEnd then def.e = lang_def.syllablesEnd:split(", ") end
	if lang_def.syllablesPost then def.p = lang_def.syllablesPost:split(", ") end
	if type(lang_def.rules) == "string" then def.rules = {{100, lang_def.rules}} else def = lang_def.rules end
	self.lang_def = def
end

--- Generates a name
-- @param if not nil this is a generation rule to use instead of a random one
function _M:generate(rule)
	while not rule do
		rule = rng.table(self.lang_def.rules)
		if rng.percent(rule[1]) then rule = rule[2] end
	end

	-- Generate the name, using lpeg pattern matching. Lpeg is nice. Love lpeg.
	local name = rule:lpegSub(rule_pattern, function(chance, type)
		if not chance or chance == "" or rng.percent(chance) then
			return rng.table(self.lang_def[type])
		else
			return ""
		end
	end)

	-- Check for double spaces
	name = name:lpegSub("  ", " ")

	-- Prunes repetitions
	-- Those do tail calls in case of bad names
	for i = 1, #name do
		if name:sub(i, i+1) == name:sub(i+2, i+3) then return self:generate() end
		if name:sub(i, i+2) == name:sub(i+3, i+4) then return self:generate() end
	end

	return name
end
