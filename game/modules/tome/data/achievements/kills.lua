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

newAchievement{
	name = "That was close",
	show = "full",
	desc = [[Kill your target while having only 1 life left.]],
}
newAchievement{
	name = "Size matters",
	show = "full",
	desc = [[Do over 600 damage in one attack]],
}
newAchievement{
	name = "Exterminator",
	show = "full",
	desc = [[Killed 1000 creatures]],
	mode = "player",
	can_gain = function(self, who)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 1000 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 1000"} end,
}
newAchievement{
	name = "Pest Control",
	image = "npc/vermin_worms_green_worm_mass.png",
	show = "full",
	desc = [[Killed 1000 reproducing vermin]],
	mode = "player",
	can_gain = function(self, who, target)
		if target:knowTalent(target.T_MULTIPLY) then
			self.nb = (self.nb or 0) + 1
			if self.nb >= 1000 then return true end
		end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 1000"} end,
}
newAchievement{
	name = "Reaver",
	show = "full",
	desc = [[Killed 1000 humanoids]],
	mode = "world",
	can_gain = function(self, who, target)
		if target.type == "humanoid" then
			self.nb = (self.nb or 0) + 1
			if self.nb >= 1000 then return true end
		end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 1000"} end,
	on_gain = function(_, src, personal)
		game:setAllowedBuild("corrupter")
		game:setAllowedBuild("corrupter_reaver", true)
	end,
}

newAchievement{
	name = "Backstabbing Traitor", id = "ESCORT_KILL",
	image = "object/knife_stralite.png",
	show = "full",
	desc = [[Killed 6 escorted adventurers while you were supposed to save them]],
	mode = "player",
	can_gain = function(self, who, target)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 6 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 6"} end,
}

newAchievement{
	name = "Earth Master", id = "GEOMANCER",
	show = "name",
	desc = [[Killed Harkor'Zun and unlocked Stone magic]],
	mode = "player",
}

newAchievement{
	name = "Kill Bill!", id = "KILL_BILL",
	image = "object/artifact/bill_treestump.png",
	show = "full",
	desc = [[Killed Bill in the Trollmire with a level one character]],
	mode = "player",
}

newAchievement{
	name = "Atamathoned!", id = "ATAMATHON",
	image = "npc/atamathon.png",
	show = "name",
	desc = [[Killed the giant golem Atamathon after foolishly reactivating it.]],
	mode = "player",
}

newAchievement{
	name = "Huge Appetite", id = "EAT_BOSSES",
	show = "full",
	desc = [[Ate 20 bosses.]],
	mode = "player",
	can_gain = function(self, who)
		if who.rank < 3.5 then return false end
		self.nb = (self.nb or 0) + 1
		if self.nb >= 20 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 20"} end,
}

newAchievement{
	name = "Are you out of your mind?!", id = "UBER_WYRMS_OPEN",
	image = "npc/dragon_multihued_multi_hued_drake.png",
	show = "name",
	desc = [[Caught the attention of overpowered greater multi-hued wyrms in Vor Armoury. Perhaps fleeing is in order.]],
	mode = "player",
}

newAchievement{
	name = "I cleared the room of death and all I got was this lousy achievement!", id = "UBER_WYRMS",
	image = "npc/dragon_multihued_multi_hued_drake.png",
	show = "name",
	desc = [[Killed the seven overpowered wyrms in the "Room of Death" in Vor Armoury.]],
	mode = "player",
	can_gain = function(self, who)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 7 then return true end
	end,
}
