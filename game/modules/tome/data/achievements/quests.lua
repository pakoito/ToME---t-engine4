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

--------------- Tutorial objectives
newAchievement{
	name = "Baby steps", id = "TUTORIAL_DONE",
	desc = [[Completed ToME4 tutorial mode.]],
	tutorial = true,
	no_difficulty_duplicate = true,
	on_gain = function(_, src, personal)
		game:setAllowedBuild("tutorial_done")
	end,
}

--------------- Main objectives
newAchievement{
	name = "Vampire crusher",
	image = "npc/the_master.png",
	show = "name",
	desc = [[Destroyed the Master in its lair of the Dreadfell.]],
}
newAchievement{
	name = "A dangerous secret",
	show = "name",
	desc = [[Found the mysterious staff and told Last Hope about it.]],
}
newAchievement{
	name = "The secret city",
	show = "none",
	desc = [[Discovered the truth about mages.]],
}
newAchievement{
	name = "Burnt to the ground", id="APPRENTICE_STAFF",
	show = "none",
	desc = [[Gave the staff of absorption to the apprentice mage and watched the fireworks.]],
}
newAchievement{
	name = "Against all odds", id = "KILL_UKRUK",
	show = "name",
	desc = [[Killed Ukruk in the ambush.]],
}
newAchievement{
	name = "Sliders",
	image = "object/artifact/orb_many_ways.png",
	show = "name",
	desc = [[Activated a portal using the Orb of Many Ways.]],
	on_gain = function()
		game:onTickEnd(function() game.player:learnLore("first-farportal") end)
	end
}
newAchievement{
	name = "Destroyer's bane", id = "DESTROYER_BANE",
	show = "name",
	desc = [[Killed Golbug the Destroyer.]],
}
newAchievement{
	name = "Brave new world", id = "STRANGE_NEW_WORLD",
	show = "name",
	desc = [[Went to the Far East and took part in the war.]],
}
newAchievement{
	name = "Race through fire", id = "CHARRED_SCAR_SUCCESS",
	show = "name",
	desc = [[Raced through the fires of the Charred Scar to stop the Sorcerers.]],
}
newAchievement{
	name = "Orcrist", id = "ORC_PRIDE",
	show = "name",
	desc = [[Killed the leaders of the Orc Pride.]],
}

--------------- Wins
newAchievement{
	name = "Evil denied", id = "WIN_FULL",
	show = "name",
	desc = [[Won ToME by preventing the Void portal to open.]],
}
newAchievement{
	name = "The High Lady's destiny", id = "WIN_AERYN",
	show = "name",
	desc = [[Won ToME by closing the Void portal using Aeryn as a sacrifice.]],
}
newAchievement{
	name = "Selfless", id = "WIN_SACRIFICE",
	show = "name",
	desc = [[Won ToME by closing the Void portal using yourself as a sacrifice.]],
}
newAchievement{
	name = "Triumph of the Way", id = "YEEK_SACRIFICE",
	show = "name",
	desc = [[Won ToME by sacrificing yourself to forcefully spread the Way to every other sentient being on Eyal.]],
}
newAchievement{
	name = "Tactical master", id = "SORCERER_NO_PORTAL",
	show = "name",
	desc = [[Fought the two Sorcerers without closing any invocation portals.]],
}
newAchievement{
	name = "Portal destroyer", id = "SORCERER_ONE_PORTAL",
	show = "name",
	desc = [[Fought the two Sorcerers and closed one invocation portal.]],
}
newAchievement{
	name = "Portal reaver", id = "SORCERER_TWO_PORTAL",
	show = "name",
	desc = [[Fought the two Sorcerers and closed two invocation portals.]],
}
newAchievement{
	name = "Portal ender", id = "SORCERER_THREE_PORTAL",
	show = "name",
	desc = [[Fought the two Sorcerers and closed three invocation portals.]],
}
newAchievement{
	name = "Portal master", id = "SORCERER_FOUR_PORTAL",
	show = "name",
	desc = [[Fought the two Sorcerers and closed four invocation portals.]],
}

-------------- Other quests
newAchievement{
	name = "Rescuer of the lost", id = "LOST_MERCHANT_RESCUE",
	show = "name",
	desc = [[Rescued the merchant from the assassin lord.]],
}
newAchievement{
	name = "Poisonous", id = "LOST_MERCHANT_EVIL",
	show = "name",
	desc = [[Sided with the assassin lord.]],
}
newAchievement{
	name = "Destroyer of the creation", id = "SLASUL_DEAD",
	show = "name",
	desc = [[Killed Slasul.]],
}
newAchievement{
	name = "Flooder", id = "UKLLMSWWIK_DEAD",
	show = "name",
	desc = [[Defeated Ukllmswwik while doing his own quest.]],
}
newAchievement{
	name = "Gem of the Moon", id = "MASTER_JEWELER",
	show = "name",
	desc = [[Completed the Master Jeweler quest with Limmir.]],
}
newAchievement{
	name = "Curse Lifter", id = "CURSE_ERASER",
	show = "name",
	desc = [[Killed Ben Cruthdar the Cursed.]],
}
newAchievement{
	name = "Eye of the storm", id = "EYE_OF_THE_STORM",
	show = "name",
	desc = [[Freed Derth from the onslaught of the mad Tempest, Urkis.]],
}
newAchievement{
	name = "Antimagic!", id = "ANTIMAGIC",
	show = "name",
	desc = [[Completed antimagic training in the Ziguranth camp.]],
}
newAchievement{
	name = "Anti-Antimagic!", id = "ANTI_ANTIMAGIC",
	show = "name",
	desc = [[Destroyed the Ziguranth camp with your Rhaloren allies.]],
}
newAchievement{
	name = "There and back again", id = "WEST_PORTAL",
	show = "name",
	desc = [[Opened a portal to Maj'Eyal from the Far East.]],
}
newAchievement{
	name = "Back and there again", id = "EAST_PORTAL",
	show = "name",
	desc = [[Opened a portal to the Far East from Maj'Eyal.]],
}
newAchievement{
	name = "Arachnophobia", id = "SPYDRIC_INFESTATION",
	show = "name",
	desc = [[Destroyed the spydric menace.]],
}
newAchievement{
	name = "Clone War", id = "SHADOW_CLONE",
	show = "name",
	desc = [[Destroyed your own Shade.]],
}
newAchievement{
	name = "Home sweet home", id = "SHERTUL_FORTRESS",
	show = "name",
	desc = [[Dispatched the Weirdling Beast and taken possession of Yiilkgur, the Sher'Tul Fortress for your own usage.]],
}
newAchievement{
	name = "Squadmate", id = "NORGAN_SAVED",
	show = "name",
	desc = [[Escaped from Reknor alive with your squadmate Norgan.]],
}
newAchievement{
	name = "Genocide", id = "GREATMOTHER_DEAD",
	show = "name",
	desc = [[Killed the Orc Greatmother in the breeding pits, thus dealing a terrible blow to the orc race.]],
}
newAchievement{
	name = "Savior of the damsels in distress", id = "MELINDA_SAVED",
	show = "name",
	desc = [[Saved Melinda from her terrible fate in the Crypt of Kryl-Feijan.]],
}
newAchievement{
	name = "Impossible Death", id = "PARADOX_NOW",
	show = "name",
	desc = [[Being killed by your future self.]],
	on_gain = function(_, src, personal)
		if world:hasAchievement("PARADOX_FUTURE") then world:gainAchievement("PARADOX_FULL", src) end
	end,
}
newAchievement{
	name = "Self-killer", id = "PARADOX_FUTURE",
	show = "name",
	desc = [[Killed your future self.]],
	on_gain = function(_, src, personal)
		if world:hasAchievement("PARADOX_NOW") then world:gainAchievement("PARADOX_FULL", src) end
	end,
}
newAchievement{
	name = "Paradoxology", id = "PARADOX_FULL",
	show = "name",
	desc = [[Both killed your future self and got killed by your future self.]],
}
newAchievement{
	name = "Explorer", id = "EXPLORER",
	show = "name",
	desc = [[Use the Sher'Tul fortress exploratory farportal at least 7 times with the same character.]],
}
newAchievement{
	name = "Orbituary", id = "ABASHED_EXPANSE",
	show = "name",
	desc = [[Stabilized the Abashed Expanse to maintain it in orbit.]],
}
newAchievement{
	name = "Matrix style!", id = "ABASHED_EXPANSE_NO_BLAST",
	show = "full",
	desc = [[Finished the whole Abashed Expanse zone without being hit by a single void blast or manaworm. Dodging's fun!]],
	can_gain = function(self, who, zone)
		if not who:isQuestStatus("start-archmage", engine.Quest.DONE) then return false end
		if zone.void_blast_hits and zone.void_blast_hits == 0 then return true end
	end,
}
newAchievement{
	name = "The Right thing to do", id = "RING_BLOOD_KILL",
	show = "name",
	desc = [[You did the righteous thing in the ring of blood and disposed of the Blood Master.]],
}
newAchievement{
	name = "Thralless", id = "RING_BLOOD_FREED",
	show = "full",
	mode = "player",
	desc = [[Free at least 30 enthralled slaves in the slavers compound.]],
	can_gain = function(self)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 30 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 30"} end,
}
newAchievement{
	name = "Lost in translation", id = "SUNWALL_LOST",
	show = "name",
	desc = [[Destroy the naga portal in the slazish fens and be caught in the aftereffect.]],
}
newAchievement{
	name = "Dreaming my dreams", id = "ALL_DREAMS",
	show = "full",
	desc = [[Experience and complete all the dreams in the Dogroth Caldera.]],
	mode = "world",
	can_gain = function(self, who, kind)
		self[kind] = true
		if self.mice and self.lost then return true end
	end,
	track = function(self)
		return tstring{tostring(
			(self.mice and 1 or 0) +
			(self.lost and 1 or 0)
		)," / 2"}
	end,
	on_gain = function(_, src, personal)
		game:setAllowedBuild("psionic")
		game:setAllowedBuild("psionic_solipsist", true)
	end,
}
