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

newBirthDescriptor{
	type = "class",
	name = "Mage",
	desc = {
		"Mages are the wielders of the arcane powers, able to cast powerful spells of destruction or to heal their wounds with nothing but a thought.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Alchemist = "allow",
			Archmage = function() return profile.mod.allow_build.mage and "allow" or "disallow" end,
--			Pyromancer = function() return profile.mod.allow_build.mage_pyromancer and "allow" or "disallow" end,
--			Cryomancer = function() return profile.mod.allow_build.mage_cryomancer and "allow" or "disallow" end,
--			Tempest = function() return profile.mod.allow_build.mage_tempest and "allow" or "disallow" end,
--			Geomancer = function() return profile.mod.allow_build.mage_geomancer and "allow" or "disallow" end,
--			Maelstrom = function() return profile.mod.allow_build.mage_maelstrom and "allow" or "disallow" end,
		},
	},
	copy = {
		mana_regen = 0.5,
		mana_rating = 7,
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=25, dur=10, mana=620}),
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Archmage",
	desc = {
		"An Archmage devotes his whole life to the study of magic above anything else.",
		"Most Archmagi lack basic skills that others take for granted (like general fighting sense), but they make up for it by their raw magical power.",
		"Archmagi know all schools of magic but the more intricate (Temporal and Meta) from the start. However, they usually refuse to have anything to do with Necromancy.",
		"All Archmagi have been trained in the secret town of Angolwen and possess a unique spell to teleport to it directly.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +3 Willpower, +1 Cunning",
	},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["spell/arcane"]={true, 0.3},
		["spell/fire"]={true, 0.3},
		["spell/earth"]={true, 0.3},
		["spell/water"]={true, 0.3},
		["spell/air"]={true, 0.3},
		["spell/phantasm"]={true, 0.3},
		["spell/temporal"]={false, 0.3},
		["spell/meta"]={false, 0.3},
		["spell/divination"]={true, 0.3},
		["spell/conveyance"]={true, 0.3},
		["spell/nature"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_ARCANE_POWER] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_LIGHTNING] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
		[ActorTalents.T_TELEPORT_ANGOLWEN]=1,
	},
	copy = {
		-- All mages are of angolwen faction
		faction = "angolwen",
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true},
		},
		resolvers.generic(function(self)
			if profile.mod.allow_build.mage_pyromancer then self:learnTalentType("spell/wildfire", false, 1.3) end
			if profile.mod.allow_build.mage_cryomancer then self:learnTalentType("spell/ice", false, 1.3) end
			if profile.mod.allow_build.mage_geomancer then self:learnTalentType("spell/stone", false, 1.3) end
			if profile.mod.allow_build.mage_tempest then self:learnTalentType("spell/storm", false, 1.3) end
		end),
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Alchemist",
	desc = {
		"An Alchemist is a dabbler in magic, while 'true' magic is thought to have been lost during the Spellhunt.",
		"Alchemists have an empirical knowledge of magic, which they can not use directly but through focuses.",
		"A focus is usualy a gem which they can imbue with power to throw at their foes, exploding in fires, acid, ...",
		"Alchemists are also known for their golem craft and are usually accompanied by such a construct which acts as a bodyguard.",
		"Their most important stats are: Magic and Dexterity",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +3 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +1 Willpower, +0 Cunning",
	},
	stats = { mag=5, dex=3, wil=1, },
	talents_types = {
		["spell/explosives"]={true, 0.3},
		["spell/infusion"]={true, 0.3},
		["spell/golemancy"]={true, 0.3},
		["spell/advanced-golemancy"]={false, 0.3},
		["spell/stone-alchemy"]={true, 0.3},
		["spell/fire-alchemy"]={false, 0.3},
		["spell/staff-combat"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
		["technique/combat-training"]={false, 0},
	},
	talents = {
		[ActorTalents.T_CREATE_ALCHEMIST_GEMS] = 1,
		[ActorTalents.T_REFIT_GOLEM] = 1,
		[ActorTalents.T_THROW_BOMB] = 1,
		[ActorTalents.T_FIRE_INFUSION] = 1,
		[ActorTalents.T_CHANNEL_STAFF] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true}
		},
		resolvers.inventory{ id=true,
			{type="gem",},
			{type="gem",},
			{type="gem",},
		},
		resolvers.generic(function(self)
			-- Make and wield some alchemist gems
			local t = self:getTalentFromId(self.T_CREATE_ALCHEMIST_GEMS)
			local gem = t.make_gem(self, t, "GEM_AGATE")
			self:wearObject(gem, true, true)
			self:sortInven()
		end),

		on_birth_done = function(self)
			-- Invoke the golem
			local t = self:getTalentFromId(self.T_REFIT_GOLEM)
			t.action(self, t)
		end,
	},
	copy_add = {
		life_rating = -1,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Pyromancer",
	desc = {
		"A Pyromancer is an Archmage specialized in fire magic.",
		"They can even learn to pierce through fire resistance and immunity.",
		"They gain access to the special Wildfire talents whose main purpose is to make things burn and burn more.",
		"Most Archmagi lack basic skills that others take for granted (like general fighting sense), but they make up for it by their raw magical power.",
		"Archmagi know all schools of magic but the more intricate (Temporal and Meta) from the start. However, they usually refuse to have anything to do with Necromancy.",
		"All Archmagi have been trained in the secret town of Angolwen and possess a unique spell to teleport to it directly.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +3 Willpower, +1 Cunning",
	},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["spell/arcane"]={true, 0.2},
		["spell/fire"]={true, 0.3},
		["spell/wildfire"]={true, 0.4},
		["spell/earth"]={true, 0.2},
		["spell/phantasm"]={true, 0.3},
		["spell/temporal"]={false, 0.3},
		["spell/meta"]={false, 0.3},
		["spell/divination"]={true, 0.3},
		["spell/conveyance"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_ARCANE_POWER] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_BLASTWAVE] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
		[ActorTalents.T_TELEPORT_ANGOLWEN]=1,
	},
	copy = {
		-- All mages are of angolwen faction
		faction = "angolwen",
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Cryomancer",
	desc = {
		"A Cryomancer is an Archmage specialized in ice magic.",
		"They gain access to the special Ice talents whose main purpose is to make things shatter under extreme cold.",
		"They can even learn to pierce through cold resistance and immunity.",
		"Most Archmagi lack basic skills that others take for granted (like general fighting sense), but they make up for it by their raw magical power.",
		"Archmagi know all schools of magic but the more intricate (Temporal and Meta) from the start. However, they usually refuse to have anything to do with Necromancy.",
		"All Archmagi have been trained in the secret town of Angolwen and possess a unique spell to teleport to it directly.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +3 Willpower, +1 Cunning",
	},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["spell/arcane"]={true, 0.2},
		["spell/water"]={true, 0.3},
		["spell/ice"]={true, 0.4},
		["spell/air"]={true, 0.2},
		["spell/phantasm"]={true, 0.3},
		["spell/temporal"]={false, 0.3},
		["spell/meta"]={false, 0.3},
		["spell/divination"]={true, 0.3},
		["spell/conveyance"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_ARCANE_POWER] = 1,
		[ActorTalents.T_ICE_SHARDS] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
		[ActorTalents.T_TELEPORT_ANGOLWEN]=1,
	},
	copy = {
		-- All mages are of angolwen faction
		faction = "angolwen",
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Tempest",
	desc = {
		"A Tempest is an Archmage specialized in lightning magic.",
		"They gain access to the special Storm talents whose main purpose is to electrocute everything in sight.",
		"They can even learn to pierce through lightning resistance and immunity.",
		"Most Archmagi lack basic skills that others take for granted (like general fighting sense), but they make up for it by their raw magical power.",
		"Archmagi know all schools of magic but the more intricate (Temporal and Meta) from the start. However, they usually refuse to have anything to do with Necromancy.",
		"All Archmagi have been trained in the secret town of Angolwen and possess a unique spell to teleport to it directly.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +3 Willpower, +1 Cunning",
	},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["spell/arcane"]={true, 0.2},
		["spell/earth"]={true, 0.2},
		["spell/storm"]={true, 0.4},
		["spell/air"]={true, 0.3},
		["spell/phantasm"]={true, 0.3},
		["spell/temporal"]={false, 0.3},
		["spell/meta"]={false, 0.3},
		["spell/divination"]={true, 0.3},
		["spell/conveyance"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_ARCANE_POWER] = 1,
		[ActorTalents.T_LIGHTNING] = 1,
		[ActorTalents.T_NOVA] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
		[ActorTalents.T_TELEPORT_ANGOLWEN]=1,
	},
	copy = {
		-- All mages are of angolwen faction
		faction = "angolwen",
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Geomancer",
	desc = {
		"A Geomancer is an Archmage specialized in earth magic.",
		"They gain access to the special Stone talents whose main purpose is to crush and destroy.",
		"They can even learn to pierce through physical resistance and immunity.",
		"Most Archmagi lack basic skills that others take for granted (like general fighting sense), but they make up for it by their raw magical power.",
		"Archmagi know all schools of magic but the more intricate (Temporal and Meta) from the start. However, they usually refuse to have anything to do with Necromancy.",
		"All Archmagi have been trained in the secret town of Angolwen and possess a unique spell to teleport to it directly.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +3 Willpower, +1 Cunning",
	},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["spell/arcane"]={true, 0.2},
		["spell/earth"]={true, 0.3},
		["spell/stone"]={true, 0.4},
		["spell/water"]={true, 0.2},
		["spell/phantasm"]={true, 0.3},
		["spell/temporal"]={false, 0.3},
		["spell/meta"]={false, 0.3},
		["spell/divination"]={true, 0.3},
		["spell/conveyance"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_ARCANE_POWER] = 1,
		[ActorTalents.T_STONE_SKIN] = 1,
		[ActorTalents.T_EARTHEN_MISSILES] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
		[ActorTalents.T_TELEPORT_ANGOLWEN]=1,
	},
	copy = {
		-- All mages are of angolwen faction
		faction = "angolwen",
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Maelstrom",
	desc = {
		"A Maelstrom is an Archmage specialized in elemental magic.",
		"They gain access to all special elemental talents but have a restricted selection of other spells.",
		"Most Archmagi lack basic skills that others take for granted (like general fighting sense), but they make up for it by their raw magical power.",
		"All Archmagi have been trained in the secret town of Angolwen and possess a unique spell to teleport to it directly.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +3 Willpower, +1 Cunning",
	},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["spell/fire"]={true, 0.3},
		["spell/wildfire"]={true, 0.3},
		["spell/air"]={true, 0.3},
		["spell/storm"]={true, 0.3},
		["spell/earth"]={true, 0.3},
		["spell/stone"]={true, 0.3},
		["spell/water"]={true, 0.3},
		["spell/ice"]={true, 0.3},
		["spell/conveyance"]={true, 0},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_ICE_SHARDS] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_EARTHEN_MISSILES] = 1,
		[ActorTalents.T_NOVA] = 1,
		[ActorTalents.T_TELEPORT_ANGOLWEN]=1,
	},
	copy = {
		-- All mages are of angolwen faction
		faction = "angolwen",
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true},
		},
	},
	copy_add = {
		life_rating = -1,
	},
}
