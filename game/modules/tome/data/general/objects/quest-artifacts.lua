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

local Stats = require "engine.interface.ActorStats"

-- The staff of absorption, the reason the game exists!
newEntity{ define_as = "STAFF_ABSORPTION",
	power_source = {unknown=true},
	unique = true, quest=true,
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="staff",
	unided_name = "dark runed staff",
	name = "Staff of Absorption",
	flavor_name = "magestaff",
	level_range = {30, 30},
	display = "\\", color=colors.VIOLET, image = "object/artifact/staff_absorption.png",
	encumber = 7,
	desc = [[Carved with runes of power, this staff seems to have been made long ago. Yet it bears no signs of tarnishment.
Light around it seems to dim and you can feel its tremendous power simply by touching it.]],

	require = { stat = { mag=60 }, },
	combat = {
		dam = 30,
		apr = 4,
		dammod = {mag=1},
		damtype = DamageType.ARCANE,
		talented = "staff",
	},
	wielder = {
		combat_atk = 20,
		combat_spellpower = 20,
		combat_spellcrit = 10,
	},

	max_power = 1000, power_regen = 1,
	use_power = { name = "absorb energies", power = 1000,
		use = function(self, who)
			game.logPlayer(who, "This power seems too much to wield, you fear it might absorb YOU.")
			return {used=true}
		end
	},

	on_pickup = function(self, who)
		if who == game.player then
			who:grantQuest("staff-absorption")
		end
	end,
	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}

-- The orb of many ways, allows usage of Farportals
newEntity{ define_as = "ORB_MANY_WAYS",
	power_source = {unknown=true},
	unique = true, quest=true,
	type = "orb", subtype="orb",
	unided_name = "swirling orb",
	name = "Orb of Many Ways",
	level_range = {30, 30},
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_many_ways.png",
	encumber = 1,
	desc = [[The orb projects images of distant places, some that seem to be not of this world, switching rapidly.
If used near a portal it could probably activate it.]],

	max_power = 30, power_regen = 1,
	use_power = { name = "activate a portal", power = 10,
		use = function(self, who)
			self:identify(true)
			local g = game.level.map(who.x, who.y, game.level.map.TERRAIN)
			if g and g.orb_portal then
				world:gainAchievement("SLIDERS", who:resolveSource())
				who:useOrbPortal(g.orb_portal)
			else
				game.logPlayer(who, "There is no portal to activate here.")
			end
			return {id=true, used=true}
		end
	},

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}

-- The orb of many ways, allows usage of Farportals
newEntity{ define_as = "ORB_MANY_WAYS_DEMON",
	power_source = {unknown=true},
	unique = "Orb of Many Ways Demon", quest=true, no_unique_lore=true,
	type = "orb", subtype="orb",
	unided_name = "swirling orb", identified=true,
	name = "Orb of Many Ways",
	level_range = {30, 30},
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_many_ways.png",
	encumber = 1,
	desc = [[The orb projects images of distant places, some that seem to be not of this world, switching rapidly.
If used near a portal it could probably activate it.]],

	max_power = 30, power_regen = 1,
	use_power = { name = "activate a portal", power = 10,
		use = function(self, who)
			local g = game.level.map(who.x, who.y, game.level.map.TERRAIN)
			if g and g.orb_portal then
				world:gainAchievement("SLIDERS", who:resolveSource())
				who:useOrbPortal{
					change_level = 1,
					change_zone = "demon-plane",
					message = "#VIOLET#The world twists sickeningly around you and you find yourself someplace unexpected! It felt nothing like your previous uses of the Orb of Many Ways. Tannen must have switched the Orb out for a fake!",
					on_use = function(self, who)
						who:setQuestStatus("east-portal", engine.Quest.COMPLETED, "tricked-demon")
						local orb = who:findInAllInventoriesBy("define_as", "ORB_MANY_WAYS_DEMON")
						if orb then orb.name = "Demonic Orb of Many Ways" end
						require("engine.ui.Dialog"):simplePopup("Demonic Orb of Many Ways", "It felt nothing like your previous uses of the Orb of Many Ways. Tannen must have switched the Orb out for a fake!")
					end,
				}
			else
				game.logPlayer(who, "There is no portal to activate here.")
			end
			return {id=true, used=true}
		end
	},

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}

-------------------- The four orbs of command

-- Rak'shor Pride
newEntity{ define_as = "ORB_UNDEATH",
	power_source = {unknown=true},
	unique = true, quest=true,
	type = "orb", subtype="orb",
	unided_name = "orb of command",
	name = "Orb of Undeath (Orb of Command)",
	level_range = {50, 50},
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_undeath.png",
	encumber = 1,
	desc = [[Dark visions fill your mind as you lift the orb. It is cold to the touch.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who) who:useCommandOrb(self) return {id=true, used=true} end
	},

	carrier = {
		inc_stats = { [Stats.STAT_DEX] = 6, },
	},
}

-- Gorbat Pride
newEntity{ define_as = "ORB_DRAGON",
	power_source = {unknown=true},
	unique = true, quest=true,
	type = "orb", subtype="orb",
	unided_name = "orb of command",
	name = "Dragon Orb (Orb of Command)",
	level_range = {50, 50},
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_dragon.png",
	encumber = 1,
	desc = [[This orb is warm to the touch.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who) who:useCommandOrb(self) return {id=true, used=true} end
	},

	carrier = {
		inc_stats = { [Stats.STAT_CUN] = 6, },
	},
}

-- Vor Pride
newEntity{ define_as = "ORB_ELEMENTS",
	power_source = {unknown=true},
	unique = true, quest=true,
	type = "orb", subtype="orb",
	unided_name = "orb of command",
	name = "Elemental Orb (Orb of Command)",
	level_range = {50, 50},
	display = "*", color=colors.VIOLET, image = "object/artifact/elemental_orb.png",
	encumber = 1,
	desc = [[Flames swirl on the icy surface of this orb.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who) who:useCommandOrb(self) return {id=true, used=true} end
	},

	carrier = {
		inc_stats = { [Stats.STAT_MAG] = 6, },
	},
}

-- Grushnak Pride
newEntity{ define_as = "ORB_DESTRUCTION",
	power_source = {unknown=true},
	unique = true, quest=true,
	type = "orb", subtype="orb",
	unided_name = "orb of command",
	name = "Orb of Destruction (Orb of Command)",
	level_range = {50, 50},
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_destruction.png",
	encumber = 1,
	desc = [[Visions of death and destruction fill your mind as you lift this orb.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who) who:useCommandOrb(self) return {id=true, used=true} end
	},

	carrier = {
		inc_stats = { [Stats.STAT_STR] = 6, },
	},
}

-- Scrying
newEntity{ define_as = "ORB_SCRYING",
	power_source = {unknown=true},
	unique = true, quest=true, no_unique_lore=true,
	type = "orb", subtype="orb",
	unided_name = "orb of scrying",
	name = "Orb of Scrying",
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_scrying.png",
	encumber = 1,
	save_hotkey = true,
	desc = [[This orb was given to you by Elisa the Halfling scryer. It will automatically identify normal and rare items for you and can be activated to contact Elisa for rarer items.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who)
			local Chat = require("engine.Chat")
			local chat = Chat.new("elisa-orb-scrying", {name="Elisa the Scryer"}, who, {version="elisa"})
			chat:invoke()
			return {id=true, used=true}
		end
	},

	carrier = {
		auto_id = 2,
	},
}

newEntity{ base = "BASE_ROD",
	power_source = {unknown=true, arcane=false},
	define_as = "ROD_OF_RECALL",
	unided_name = "unstable rod", identified=true, force_lore_artifact=true,
	name = "Rod of Recall", color=colors.LIGHT_BLUE, unique=true, image = "object/artifact/rod_of_recall.png",
	desc = [[This rod is made entirely of voratun, infused with raw magical energies that can bend space itself.
You have heard of such items before. They are very useful to adventurers, allowing faster travel.]],
	cost = 0, quest=true,

	max_power = 400, power_regen = 1,
	use_power = { name = "recall the user to the worldmap", power = 202,
		use = function(self, who)
			if who:hasEffect(who.EFF_RECALL) then
				who:removeEffect(who.EFF_RECALL)
				game.logPlayer(who, "The rod emits a strange noise, glows briefly and returns to normal.")
				return {id=true, used=true}
			end
			if not who:attr("never_move") then
				if who:canBe("worldport") then
					who:setEffect(who.EFF_RECALL, 40, { where = self.shertul_fortress and "shertul-fortress" or nil })
					game.logPlayer(who, "Space around you starts to dissolve...")
					return {id=true, used=true}
				elseif game.zone.force_farportal_recall then
					require("engine.ui.Dialog"):yesnoLongPopup("Force a recall", "The Fortress Shadow warned you that trying to force a recall without finding the portal back could break the exploratory farportal forever.", 500, function(ret)
						if not ret then
							who:setEffect(who.EFF_RECALL, 40, { where = self.shertul_fortress and "shertul-fortress" or nil, allow_override=true })
							game.logPlayer(who, "Space around you starts to dissolve...")
							if rng.percent(90) and who:hasQuest("shertul-fortress") then
								who:hasQuest("shertul-fortress"):break_farportal()
							end
						end
					end, "Cancel", "Recall")
				end
			end
			game.logPlayer(who, "The rod emits a strange noise, glows briefly and returns to normal.")
			return {id=true, used=true}
		end
	},

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}

newEntity{ base = "BASE_ROD",
	power_source = {unknown=true, arcane=false},
	type = "chest", subtype = "sher'tul",
	define_as = "TRANSMO_CHEST",
	add_name = false,
	identified=true, force_lore_artifact=true,
	name = "Transmogrification Chest", display = '~', color=colors.GOLD, unique=true, image = "object/chest4.png",
	desc = [[This chest is an extension of Yiilkgur, any items dropped inside is transported to the Fortress, processed by the core and destroyed to extract energy.
The byproduct of this effect is the creation of gold, which is useless to the Fortress, so it is sent back to you.

When you possess the chest all items you walk upon will automatically be put inside and transmogrified when you leave the level.
Simply go to your inventory to move them out of the chest if you wish to keep them.
Items in the chest will not encumber you.]],
	cost = 0, quest=true,

	carrier = {
		has_transmo = 1,
	},

	max_power = 1000, power_regen = 1,
	use_power = { name = "transmogrify all the items in your chest at once(also done automatically when you change level)", power = 0,
		use = function(self, who)
			local inven = who:getInven("INVEN")
			local nb = 0
			for i = #inven, 1, -1 do
				local o = inven[i]
				if o.__transmo then nb = nb + 1 end
			end
			if nb <= 0 then
				local floor = game.level.map:getObjectTotal(who.x, who.y)
				if floor == 0 then
					require("engine.ui.Dialog"):simplePopup("Transmogrification Chest", "You do not have any items to transmogrify in your chest or on the floor.")
				else
					require("engine.ui.Dialog"):yesnoPopup("Transmogrification Chest", "Transmogrify all "..floor.." item(s) on the floor?", function(ret)
						if not ret then return end
						for i = floor, 1, -1 do
							local o = game.level.map:getObject(who.x, who.y, i)
							if who:transmoFilter(o) then
								game.level.map:removeObject(who.x, who.y, i)
								who:transmoInven(nil, nil, o)
							end
						end
					end)
				end
				return {id=true, used=true}
			end

			require("engine.ui.Dialog"):yesnoPopup("Transmogrification Chest", "Transmogrify all "..nb.." item(s) in your chest?", function(ret)
				if not ret then return end
				for i = #inven, 1, -1 do
					local o = inven[i]
					if o.__transmo then
						who:transmoInven(inven, i, o)
					end
				end
			end)
			return {id=true, used=true}
		end
	},

	on_pickup = function(self, who)
		require("engine.ui.Dialog"):simpleLongPopup("Transmogrification Chest", [[This chest is an extension of Yiilkgur, any items dropped inside is transported to the Fortress, processed by the core and destroyed to extract energy.
The byproduct of this effect is the creation of gold, which is useless to the Fortress, so it is sent back to you.

When you possess the chest all items you walk upon will automatically be put inside and transmogrified when you leave the level.
To take an item out, simply go to your inventory to move them out of the chest.
Items in the chest will not encumber you.]], 500)
	end,
	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}
