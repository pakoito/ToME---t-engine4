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

local imbue_ring = function(npc, player)
	player:showInventory("Imbue which ring?", player:getInven("INVEN"), function(o) return o.type == "jewelry" and o.subtype == "ring" and not o.egoed and not o.unique end, function(ring, ring_item)
		player:showInventory("Use which gem?", player:getInven("INVEN"), function(gem) return gem.type == "gem" and (gem.material_level or 99) <= ring.material_level end, function(gem, gem_item)
			local price = 10 + gem.material_level * 5 + ring.material_level * 7
			if price > player.money then require("engine.ui.Dialog"):simplePopup("Not enough money", "This costs "..price.." gold, you need more gold.") return end

			require("engine.ui.Dialog"):yesnoPopup("Imbue cost", "This will cost you "..price.." gold, do you accept?", function(ret) if ret then
				player:incMoney(-price)
				player:removeObject(player:getInven("INVEN"), gem_item)
				ring.wielder = ring.wielder or {}
				table.mergeAdd(ring.wielder, gem.imbue_powers, true)
				ring.name = gem.name .. " ring"
				ring.been_imbued = true
				ring.egoed = true
				game.logPlayer(player, "%s creates: %s", npc.name:capitalize(), ring:getName{do_colour=true, no_count=true})
			end end)
		end)
	end)
end

local artifact_imbue_ring = function(npc, player)
	player:showInventory("Imbue which ring?", player:getInven("INVEN"), function(o) return o.type == "jewelry" and o.subtype == "ring" and not o.egoed and not o.unique end, function(ring, ring_item)
		player:showInventory("Use which first gem?", player:getInven("INVEN"), function(gem1) return gem1.type == "gem" and (gem1.material_level or 99) <= ring.material_level end, function(gem1, gem1_item)
			player:showInventory("Use which second gem?", player:getInven("INVEN"), function(gem2) return gem2.type == "gem" and (gem2.material_level or 99) <= ring.material_level and gem1.name ~= gem2.name end, function(gem2, gem2_item)
				local price = 390
				if price > player.money then require("engine.ui.Dialog"):simplePopup("Not enough money", "Limmir needs more gold for the magical plating.") return end

				require("engine.ui.Dialog"):yesnoPopup("Imbue cost", "You need to use "..price.." gold for the plating, do you accept?", function(ret) if ret then
					player:incMoney(-price)
					local gem3 = game.zone:makeEntity(game.level, "object", {type="gem"}, nil, true)
					print("Imbue third gem", gem3.name)

					if gem1_item > gem2_item then
						player:removeObject(player:getInven("INVEN"), gem1_item)
						player:removeObject(player:getInven("INVEN"), gem2_item)
					else
						player:removeObject(player:getInven("INVEN"), gem2_item)
						player:removeObject(player:getInven("INVEN"), gem1_item)
					end
					ring.wielder = ring.wielder or {}
					table.mergeAdd(ring.wielder, gem1.imbue_powers, true)
					table.mergeAdd(ring.wielder, gem2.imbue_powers, true)
					table.mergeAdd(ring.wielder, gem3.imbue_powers, true)
					ring.name = "Limmir's Ring of the Moon"
					ring.been_imbued = true
					ring.unique = util.uuid()
					game.logPlayer(player, "%s creates: %s", npc.name:capitalize(), ring:getName{do_colour=true, no_count=true})
				end end)
			end)
		end)
	end)
end

newChat{ id="welcome",
	text = [[Welcome @playername@ to my shop.]],
	answers = {
		{"Let me see your wares.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end, cond=function(npc, player) return npc.store and true or false end},
		{"I am looking for special jewelry.", jump="jewelry"},
		{"So you can make better rings in this place?", jump="artifact_jewelry", cond=function(npc, player) return npc.can_craft and player:hasQuest("master-jeweler") and player:isQuestStatus("master-jeweler", engine.Quest.COMPLETED, "limmir-survived") end},
		{"I have found this tome; it looked important.", jump="quest", cond=function(npc, player) return npc.can_quest and player:hasQuest("master-jeweler") and player:hasQuest("master-jeweler"):has_tome(player) end},
		{"Sorry I have to go!"},
	}
}

newChat{ id="jewelry",
	text = [[Then you are at the right place, for I am an expert jeweler.
If you bring me a gem and a non-magical ring I can imbue the gem inside the ring for you.
There is a small fee dependent on the level of the ring, and you need a quality ring to use a quality gem.]],
	answers = {
		{"I need your services.", action=imbue_ring},
		{"Not now thanks."},
	}
}

newChat{ id="artifact_jewelry",
	text = [[Yes! Thank to you this place is now free from the corruption. I will stay on this island to study the magical aura, and as promised I can make you better rings.
Bring me a non-magical ring and two gems and I will turn them into a powerful ring.
I will not make you pay a fee for it since you helped me so much, but I am afraid the ritual requires a gold plating. This should be equal to about 390 gold pieces.]],
	answers = {
		{"I need your services.", action=artifact_imbue_ring},
		{"Not now thanks."},
	}
}

newChat{ id="quest",
	text = [[#LIGHT_GREEN#*He quickly looks at the tome and looks amazed.*#WHITE# This is an amazing find! Truly amazing!
With this knowledge I could create much more potent rings. However, this requires a special place of power to craft such items.
There are rumours about a site of power in the southern mountains. Old legends tell about a place where a part of the moon melted when it got too close to the sun and fell from the sky.
A lake formed in the crater of the crash. The water of this lake, soaked in intense moonlight for eons, should be sufficient to forge powerful artifacts!
Go to the lake and then summon me with this scroll. I will retire to study the tome, awaiting your summon.]],
	answers = {
		{"I will see if I can find it.", action=function(npc, player)
			game.level:removeEntity(npc)
			player:hasQuest("master-jeweler"):remove_tome(player)
			player:hasQuest("master-jeweler"):start_search(player)
		end},
	}
}

return "welcome"
