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

name = "Lost Knowledge"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You found an ancient tome about gems."
	desc[#desc+1] = "You should bring it to the jeweler in the Gates of Morning."
	if self:isCompleted("search-valley") then
		desc[#desc+1] = "Limmir told you to look for the Valley of the Moon in the southern mountains."
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	game.logPlayer(who, "#VIOLET#This tome seems to be about the power of gems. Maybe you should bring it to the jeweler in the Gates of Morning.")
end

has_tome = function(self, who)
	for inven_id, inven in pairs(who.inven) do
		for item, o in ipairs(inven) do
			if o.type == "scroll" and o.subtype == "tome" and o.define_as == "JEWELER_TOME" then return o, inven_id, item end
		end
	end
end

has_scroll = function(self, who)
	for inven_id, inven in pairs(who.inven) do
		for item, o in ipairs(inven) do
			if o.type == "scroll" and o.subtype == "tome" and o.define_as == "JEWELER_SUMMON" then return o, inven_id, item end
		end
	end
end

remove_tome = function(self, who)
	local o, inven, item = self:has_tome(who)
	who:removeObject(inven, item)
end

start_search = function(self, who)
	-- Reveal entrances
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "CAVERN_MOON")
		local spot = level:pickSpot{type="zone-pop", subtype="valley-moon-caverns"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)
	end)

	who:setQuestStatus(self.id, engine.Quest.COMPLETED, "search-valley")
	game.logPlayer(game.player, "Limmir points to the entrance to a cave on your map. This is supposed to be the way to the valley.")

	local o = game.zone:makeEntityByName(game.level, "object", "JEWELER_SUMMON")
	if o then who:addObject(who:getInven("INVEN"), o) end
end

summon_limmir = function(self, who)
	if not game.level.map.attrs(who.x, who.y, "summon_limmir") then
		game.logPlayer(who, "You must be near the moonstone to summon Limmir.")
		return
	end

	local o, inven, item = self:has_scroll(who)
	if not o then game.logPlayer(who, "You do not have the summoning scroll!") return end
	who:removeObject(inven, item)

	local limmir = game.zone:makeEntityByName(game.level, "actor", "LIMMIR")
	limmir.limmir_target = {x=42, y=11}
	limmir.limmir_target2 = {x=24, y=25}
	game.zone:addEntity(game.level, limmir, "actor", 45, 1)
end

ritual_end = function(self)
	local limmir = nil
	for i, e in pairs(game.level.entities) do
		if e.define_as and e.define_as == "LIMMIR" then limmir = e break end
	end

	if not limmir then
		game.player:setQuestStatus(self.id, engine.Quest.COMPLETED, "limmir-dead")
		game.player:setQuestStatus(self.id, engine.Quest.FAILED)
		return
	end

	game.player:setQuestStatus(self.id, engine.Quest.COMPLETED, "limmir-survived")
	game.player:setQuestStatus(self.id, engine.Quest.DONE)
	world:gainAchievement("MASTER_JEWELER", game.player)

	for i = #game.level.e_array, 1, -1 do
		local e = game.level.e_array[i]
		if not e.unique and e.type == "demon" then e:die() end
	end
	limmir.name = "Limmir the Master Jeweler"
	limmir.can_talk = "jewelry-store"

	-- Update water
	local water = game.zone:makeEntityByName(game.level, "terrain", "DEEP_WATER")
	for x = 0, game.level.map.w - 1 do for y = 0, game.level.map.h - 1 do
		local g = game.level.map(x, y, engine.Map.TERRAIN)
		if g and g.define_as == "POISON_DEEP_WATER" then
			game.level.map(x, y, engine.Map.TERRAIN, water)
		end
	end end
end
