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

newBirthDescriptor{
	type = "class",
	name = "Adventurer",
	locked = function() return profile.mod.allow_build.adventurer and true or "hide"  end,
	desc = {
		"Adventurer can learn to do a bit of everything, getting training in whatever they happen to find.",
		"#{bold}##GOLD#This is a bonus class for winning the game, it is by no means balanced.#WHITE##{normal}#",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Adventurer = "allow",
		},
	},
	copy = {
		max_life = 100,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Adventurer",
	locked = function() return profile.mod.allow_build.adventurer and true or "hide"  end,
	desc = {
		"Adventurer can learn to do a bit of everything, getting training in whatever they happen to find.",
		"#{bold}##GOLD#This is a bonus class for winning the game, it is by no means balanced.#WHITE##{normal}#",
		"Their most important stats depends on what they wish to do.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +2 Strength, +2 Dexterity, +2 Constitution",
		"#LIGHT_BLUE# * +2 Magic, +2 Willpower, +2 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	not_on_random_boss = true,
	stats = { str=2, con=2, dex=2, mag=2, wil=2, cun=2 },
	talents_types = function(birth)
		local tts = {}
		for _, class in ipairs(birth.all_classes) do
			for _, sclass in ipairs(class.nodes) do if sclass.id ~= "Adventurer" and not sclass.not_on_random_boss then
				if birth.birth_descriptor_def.subclass[sclass.id].talents_types then
					local tt = birth.birth_descriptor_def.subclass[sclass.id].talents_types
					if type(tt) == "function" then tt = tt(birth) end

					for t, _ in pairs(tt) do
						tts[t] = {false, 0}
					end
				end

				if birth.birth_descriptor_def.subclass[sclass.id].unlockable_talents_types then
					local tt = birth.birth_descriptor_def.subclass[sclass.id].unlockable_talents_types
					if type(tt) == "function" then tt = tt(birth) end

					for t, v in pairs(tt) do
						if profile.mod.allow_build[v[3]] then
							tts[t] = {false, 0}
						end
					end
				end
			end end
		end
		return tts
	end,
	copy_add = {
		unused_generics = 2,
		unused_talent_points = 3,
		unused_talents_types = 7,
	},
	copy = {
		resolvers.inventory{ id=true,
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="longsword", name="iron longsword", ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
	},
}
