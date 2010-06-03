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

-- CSV export
local src = [[
,Enemies,Undead,Reunited Kingdom,Shire,Lonely Mountain,Eryn Lasgalen,Angolwen,Tol Falas,,Water lair|H,Assassin lair|H,,Sunwall|H,Orc Pride,,Sandworm Burrowers
Enemies,,,,,,,,,,,,,,,,
Undead,-1,,,,,,,,,,,,,,,
Reunited Kingdom,-1,,,,,,,,,,,,,,,
Shire,-1,,1,,,,,,,,,,,,,
Lonely Mountain,-1,,0.5,1,,,,,,,,,,,,
Eryn Lasgalen,-1,,0.5,1,0.3,,,,,,,,,,,
Angolwen,-1,,,,,,,,,,,,,,,
Tol Falas,,-1,-1,-1,-1,-1,-1,,,,,,,,,
,,,,,,,,,,,,,,,,
Water lair|H,-1,,,,,,,,,,,,,,,
Assassin lair|H,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,
Sunwall|H,-1,,,,,,0,-1,,,-1,,,,,
Orc Pride,,-1,-1,-1,-1,-1,-1,-1,,,,,-1,,,
,,,,,,,,,,,,,,,,
Sandworm Burrowers,,,,,,,,,,,,,,,,
]]

local facts = {}
local factsid = {}
local lines = src:split("\n")
for i, line in ipairs(lines) do
	local data = line:split(",")
	for j, d in ipairs(data) do

		if i == 1 then
			if d ~= "" then
				local def = d:split("|")
				local on_attack = false
				for z = 2, #def do if def[z] == "H" then on_attack = true end end

				local sn = engine.Faction:add{ name=def[1], reaction={}, hostile_on_attack=on_attack }
				print("[FACTION] added", sn, def[1])
				facts[sn] = {id=j, reactions={}}
				factsid[j] = sn
			end
		else
			local n = tonumber(d)
			if n then
				facts[factsid[j]].reactions[factsid[i]] = n * 100
			end
		end
	end
end

for f1, data in pairs(facts) do
	for f2, v in pairs(data.reactions) do
		print("[FACTION] initial reaction", f1, f2, " => ", v)
		engine.Faction:setInitialReaction(f1, f2, v, true)
	end
end
