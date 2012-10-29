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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A naga steps through the portal, she seems to be a high ranked one.*#WHITE#
NO! You fool, the portal is breaking down!]],
	answers = {
		{"And thus my task is done, serpent!", jump="fool"},
	}
}

newChat{ id="fool",
	text = [[You do not understand: it will explode!]],
	answers = {
		{"...", action = function(npc, player)
			game:onTickEnd(function()
				game.level:removeEntity(npc)
				game:changeLevel(2, (rng.table{"trollmire","ruins-kor-pul","scintillating-caves","rhaloren-camp","norgos-lair","heart-gloom"}), {direct_switch=true})

				local a = require("engine.Astar").new(game.level.map, player)

				local sx, sy = util.findFreeGrid(player.x, player.y, 20, true, {[engine.Map.ACTOR]=true})
				while not sx do
					sx, sy = rng.range(0, game.level.map.w - 1), rng.range(0, game.level.map.h - 1)
					if game.level.map(sx, sy, engine.Map.ACTOR) or not a:calc(player.x, player.y, sx, sy) then sx, sy = nil, nil end
				end

				game.zone:addEntity(game.level, npc, "actor", sx, sy)
				game.level.map:particleEmitter(player.x, player.y, 1, "teleport_water")
				game.level.map:particleEmitter(sx, sy, 1, "teleport_water")

				game:onLevelLoad("wilderness-1", function(zone, level, data)
					local list = {}
					for i = 0, level.map.w - 1 do for j = 0, level.map.h - 1 do
						local idx = i + j * level.map.w
						if level.map.map[idx][engine.Map.TERRAIN] and level.map.map[idx][engine.Map.TERRAIN].change_zone == data.from then
							list[#list+1] = {i, j}
						end
					end end
					if #list > 0 then
						game.player.wild_x, game.player.wild_y = unpack(rng.table(list))
					end
				end, {from=game.zone.short_name})

				local chat = require("engine.Chat").new("zoisla", npc, player)
				chat:invoke("kill")
			end)
		end},
	}
}

newChat{ id="kill",
	text = [[The portal randomly teleported us before exploding.
You fool! You have doomed us, we could be #{bold}#anywhere!#{normal}#
DIE !]],
	answers = {
		{"...", action=function(npc, player) world:gainAchievement("SUNWALL_LOST", player) end},
	}
}

return "welcome"
