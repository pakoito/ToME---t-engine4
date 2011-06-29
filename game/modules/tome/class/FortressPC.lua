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
require "mod.class.Player"

module(..., package.seeall, class.inherit(mod.class.Player))

function _M:init(t, no_default)
	mod.class.Player.init(self, t, no_default)

	self.name = "Yiilkgur, the Sher'Tul Fortress"
	self.faction = game:getPlayer(true).faction
	self.no_party_class = true
	self.no_leave_control = true
	self.can_change_level = true
	self.can_change_zone = true
	self.display = ' '
	self.moddable_tile = nil
	self.can_pass = {water=500, wall=500}
	self.image="terrain/shertul_flying_castle.png"
	self.display_h = 2
	self.display_y = -1
	self.z = 18

	self.max_life = 10000
	self.life = 10000
end

function _M:tooltip(x, y, seen_by)
	return tstring{{"color", "GOLD"}, self.name, {"color", "WHITE"}}
end

function _M:die(src, death_note)
	return self:onPartyDeath(src, death_note)
end

--- Attach or remove a display callback
-- Defines particles to display
function _M:defineDisplayCallback()
do return end
	if not self._mo then return end

	local ps = self:getParticlesList()

	local f_self = nil
	local f_danger = nil
	local f_powerful = nil
	local f_friend = nil
	local f_enemy = nil
	local f_neutral = nil

	self._mo:displayCallback(function(x, y, w, h, zoom, on_map)
		-- Tactical info
		if game.level and game.level.map.view_faction then
			local map = game.level.map
			if on_map then
				if not f_self then
					f_self = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_self)
					f_powerful = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_powerful)
					f_danger = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_danger)
					f_friend = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_friend)
					f_enemy = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_enemy)
					f_neutral = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_neutral)
				end

				if self.faction then
					local friend
					if not map.actor_player then friend = Faction:factionReaction(map.view_faction, self.faction)
					else friend = map.actor_player:reactionToward(self) end

					if self == map.actor_player then
						f_self:toScreen(x, y, w, h)
					elseif map:faction_danger_check(self) then
						if friend >= 0 then f_powerful:toScreen(x, y, w, h)
						else f_danger:toScreen(x, y, w, h) end
					elseif friend > 0 then
						f_friend:toScreen(x, y, w, h)
					elseif friend < 0 then
						f_enemy:toScreen(x, y, w, h)
					else
						f_neutral:toScreen(x, y, w, h)
					end
				end
			end
		end

		local e
		for i = 1, #ps do
			e = ps[i]
			e:checkDisplay()
			if e.ps:isAlive() then e.ps:toScreen(x + w / 2, y + h / 2, true, w / (game.level and game.level.map.tile_w or w))
			else self:removeParticles(e)
			end
		end

		return true
	end)
end
