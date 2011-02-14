-- ToME - Tales of Maj'Eyal
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
	desc = [[Destroyed the Master in its lair of the Dreadfell.]],
}
newAchievement{
	name = "A dangerous secret",
	desc = [[Found the mysterious staff and told Last Hope about it.]],
}
newAchievement{
	name = "The secret city",
	desc = [[Discovered the truth about mages.]],
}
newAchievement{
	name = "Burnt to the ground", id="APPRENTICE_STAFF",
	desc = [[Gave the staff of absorption to the apprentice mage and watched the fireworks.]],
}
newAchievement{
	name = "Against all odds", id = "KILL_UKRUK",
	desc = [[Killed Ukruk in the ambush.]],
}
newAchievement{
	name = "Sliders",
	desc = [[Activated a portal using the Orb of Many Ways.]],
}
newAchievement{
	name = "Destroyer's bane", id = "DESTROYER_BANE",
	desc = [[Killed Golbug the Destroyer.]],
}
newAchievement{
	name = "Brave new world", id = "STRANGE_NEW_WORLD",
	desc = [[Went to the Far East and took part in the war.]],
}
newAchievement{
	name = "Race through fire", id = "CHARRED_SCAR_SUCCESS",
	desc = [[Raced through the fires of the Charred Scar to stop the Sorcerers.]],
}
newAchievement{
	name = "Orcrist", id = "ORC_PRIDE",
	desc = [[Killed the leaders of the Orc Pride.]],
}

--------------- Wins
newAchievement{
	name = "Evil denied", id = "WIN_FULL",
	desc = [[Won ToME by preventing the Void portal to open.]],
}
newAchievement{
	name = "The High Lady's destiny", id = "WIN_AERYN",
	desc = [[Won ToME by closing the Void portal using Aeryn as a sacrifice.]],
}
newAchievement{
	name = "Selfless", id = "WIN_SACRIFICE",
	desc = [[Won ToME by closing the Void portal using yourself as a sacrifice.]],
}
newAchievement{
	name = "Tactical master", id = "SORCERER_NO_PORTAL",
	desc = [[Fought the two Sorcerers without closing any invocation portals.]],
}
newAchievement{
	name = "Portal destroyer", id = "SORCERER_ONE_PORTAL",
	desc = [[Fought the two Sorcerers and closed one invocation portal.]],
}
newAchievement{
	name = "Portal reaver", id = "SORCERER_TWO_PORTAL",
	desc = [[Fought the two Sorcerers and closed two invocation portals.]],
}
newAchievement{
	name = "Portal ender", id = "SORCERER_THREE_PORTAL",
	desc = [[Fought the two Sorcerers and closed three invocation portals.]],
}
newAchievement{
	name = "Portal master", id = "SORCERER_FOUR_PORTAL",
	desc = [[Fought the two Sorcerers and closed four invocation portals.]],
}

-------------- Other quests
newAchievement{
	name = "Rescuer of the lost", id = "LOST_MERCHANT_RESCUE",
	desc = [[Rescued the merchant from the assassin lord.]],
}
newAchievement{
	name = "Destroyer of the creation", id = "SLASUL_DEAD",
	desc = [[Killed Slasul.]],
}
newAchievement{
	name = "Flooder", id = "UKLLMSWWIK_DEAD",
	desc = [[Defeated Ukllmswwik while doing his own quest.]],
}
newAchievement{
	name = "Gem of the Moon", id = "MASTER_JEWELER",
	desc = [[Completed the Master Jeweler quest with Limmir.]],
}
newAchievement{
	name = "Curse Lifter", id = "CURSE_ERASER",
	desc = [[Killed Ben Cruthdar the Cursed.]],
}
newAchievement{
	name = "Eye of the storm", id = "EYE_OF_THE_STORM",
	desc = [[Freed Derth from the onslaught of the mad Tempest, Urkis.]],
}
newAchievement{
	name = "Antimagic!", id = "ANTIMAGIC",
	desc = [[Completed antimagic training in the Ziguranth camp.]],
}
newAchievement{
	name = "Anti-Antimagic!", id = "ANTI_ANTIMAGIC",
	desc = [[Destroyed the Ziguranth camp with your Rhaloren allies.]],
}
newAchievement{
	name = "There and back again", id = "WEST_PORTAL",
	desc = [[Opened a portal to Maj'Eyal from the Far East.]],
}
newAchievement{
	name = "Back and there again", id = "EAST_PORTAL",
	desc = [[Opened a portal to the Far East from Maj'Eyal.]],
}
newAchievement{
	name = "Arachnophobia", id = "SPYDRIC_INFESTATION",
	desc = [[Destroyed the spydric menace.]],
}
newAchievement{
	name = "Clone War", id = "SHADOW_CLONE",
	desc = [[Destroyed your own Shade.]],
}
newAchievement{
	name = "Home sweet home", id = "SHERTUL_FORTRESS",
	desc = [[Dispatched the Weirdling Beast and taken possession of Yiilkgur, the Sher'Tul Fortress for your own usage.]],
}
newAchievement{
	name = "Squadmate", id = "NORGAN_SAVED",
	desc = [[Escaped from Reknor alive with your squadmate Norgan.]],
}
