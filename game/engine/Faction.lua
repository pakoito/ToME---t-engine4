require "engine.class"

--- Defines factions
module(..., package.seeall, class.make)

_M.factions = {}

--- Adds a new faction
-- Static method
function _M:add(t)
	assert(t.name, "no faction name")
	t.short_name = t.short_name or t.name:lower():gsub(" ", "-")
	t.reaction = t.reaction or {}
	self.factions[t.short_name] = t
end


--- Returns the status of faction f1 toward f2
-- @param f1 the source faction
-- @param f2 the target faction
-- @return a numerical value representing the reaction, 0 is neutral, <0 is aggressive, >0 is friendly
function _M:factionReaction(f1, f2)
	-- Faction always like itself
	if f1 == f2 then return 100 end
	if not self.factions[f1] then return 0 end
	return self.factions[f1].reaction[f2] or 0
end

-- Add a few default factions
_M:add{ name="Players", reaction={enemies=-100} }
_M:add{ name="Enemies", reaction={players=-100} }
