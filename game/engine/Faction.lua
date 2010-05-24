-- TE4 - T-Engine 4
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

--- Defines factions
module(..., package.seeall, class.make)

_M.factions = {}

--- Adds a new faction
-- Static method
function _M:add(t)
	assert(t.name, "no faction name")
	t.short_name = t.short_name or t.name:lower():gsub(" ", "-")
	if self.factions[t.short_name] then print("[FACTION] tried to redefine", t.name) return t.short_name end

	local r = {}
	t.reaction = t.reaction or {}
	for n, v in pairs(t.reaction) do
		n = n:lower():gsub(" ", "-")
		r[n] = v
	end
	t.reaction = r
	self.factions[t.short_name] = t
	return t.short_name
end

--- Sets the initial reaction
-- Static method
function _M:setInitialReaction(f1, f2, reaction, mutual)
	-- Faction always like itself
	if f1 == f2 then return end
	if not self.factions[f1] then return end
	if not self.factions[f2] then return end
	self.factions[f1].reaction[f2] = reaction
	if mutual then
		self.factions[f2].reaction[f1] = reaction
	end
end

--- Returns the faction definition
function _M:get(id)
	return self.factions[id]
end

--- Returns the status of faction f1 toward f2
-- @param f1 the source faction
-- @param f2 the target faction
-- @return a numerical value representing the reaction, 0 is neutral, <0 is aggressive, >0 is friendly
function _M:factionReaction(f1, f2)
	-- Faction always like itself
	if f1 == f2 then return 100 end
	if game.factions and game.factions[f1] and game.factions[f1][f2] then return game.factions[f1][f2] end
	if not self.factions[f1] then return 0 end
	return self.factions[f1].reaction[f2] or 0
end

--- Sets the status of faction f1 toward f2
-- @param f1 the source faction
-- @param f2 the target faction
-- @param reaction a numerical value representing the reaction, 0 is neutral, <0 is aggressive, >0 is friendly
-- @param mutual if true the same status will be set for f2 toward f1
function _M:setFactionReaction(f1, f2, reaction, mutual)
	print("[FACTION]", f1, f2, reaction, mutual)
	-- Faction always like itself
	if f1 == f2 then return end
	if not self.factions[f1] then return end
	if not self.factions[f2] then return end
	game.factions = game.factions or {}
	game.factions[f1] = game.factions[f1] or {}
	game.factions[f1][f2] = reaction
	if mutual then
		game.factions[f2] = game.factions[f2] or {}
		game.factions[f2][f1] = reaction
	end
end

-- Add a few default factions
_M:add{ name="Players", reaction={enemies=-100} }
_M:add{ name="Enemies", reaction={players=-100} }
