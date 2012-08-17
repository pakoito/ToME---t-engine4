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

local Particles = require "engine.Particles"

newBirthDescriptor{
	type = "class",
	name = "Mage",
	desc = {
		"Mages are the wielders of arcane powers, able to cast powerful spells of destruction or to heal their wounds with nothing but a thought.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Alchemist = "allow",
			Archmage = "allow-nochange",
			Necromancer = "allow-nochange",
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
	name = "Alchemist",
	desc = {
		"An Alchemist is a manipulator of materials using magic.",
		"They do not use the forbidden arcane arts practised by the mages of old - such perverters of nature have been shunned or actively hunted down since the Spellblaze.",
		"Alchemists can transmute gems to bring forth elemental effects, turning them into balls of fire, torrents of acid, and other effects.  They can also reinforce armour with magical effects using gems, and channel arcane staffs to produce bolts of energy.",
		"Though normally physically weak, most alchemists are accompanied by magical golems which they construct and use as bodyguards.  These golems are enslaved to their master's will, and can grow in power as their master advances through the arts.",
		"Their most important stats are: Magic and Dexterity",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +3 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +1 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# -1",
	},
	power_source = {arcane=true},
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
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		},
		resolvers.inventory{ id=true,
			{type="gem",},
			{type="gem",},
			{type="gem",},
		},
		resolvers.generic(function(self) self:birth_create_alchemist_golem() end),
		birth_create_alchemist_golem = function(self)
			-- Make and wield some alchemist gems
			local t = self:getTalentFromId(self.T_CREATE_ALCHEMIST_GEMS)
			local gem = t.make_gem(self, t, "GEM_AGATE")
			self:wearObject(gem, true, true)
			self:sortInven()

			-- Invoke the golem
			if not self.alchemy_golem then
				local t = self:getTalentFromId(self.T_REFIT_GOLEM)
				t.action(self, t)
			end
		end,
	},
	copy_add = {
		life_rating = -1,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Archmage",
	locked = function() return profile.mod.allow_build.mage end,
	locked_desc = "Hated, harrowed, hunted, hidden... Our ways are forbidden, but our cause is just. In our veiled valley we find solace from the world's wrath, free to study our arts. Only through charity and friendship can you earn our trust.",
	desc = {
		"An Archmage devotes his whole life to the study of magic above anything else.",
		"Most Archmagi lack basic skills that others take for granted (like general fighting sense), but they make up for it by their raw magical power.",
		"Archmagi start with knowledge of many schools of magic. However, they usually refuse to have anything to do with Necromancy.",
		"Most Archmagi have been trained in the secret town of Angolwen and possess a unique spell to teleport to it directly.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +3 Willpower, +1 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# -4",
	},
	power_source = {arcane=true},
	stats = { mag=5, wil=3, cun=1, },
	birth_example_particles = {
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {radius=1.1}, {type="flames", hide_center=0, xy={0, 0}}))
			else actor:addParticles(Particles.new("wildfire", 1))
			end
		end,
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {radius=1.1}, {type="flames", hide_center=0, time_factor=1700, zoom=0.3, npow=1, color1={0.6, 0.3, 0.8, 1}, color2={0.8, 0, 0.8, 1}, xy={0,0}}))
			else actor:addParticles(Particles.new("ultrashield", 1, {rm=180, rM=220, gm=10, gM=50, bm=190, bM=220, am=120, aM=200, radius=0.4, density=100, life=8, instop=20}))
			end
		end,
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=-0.2, radius=1.1}, {type="sparks", hide_center=0, time_factor=40000, color1={0, 0, 1, 1}, color2={0, 1, 1, 1}, zoom=0.5, xy={0, 0}}))
			else actor:addParticles(Particles.new("uttercold", 1))
			end
		end,
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=-0.01, radius=1.1}, {type="stone", hide_center=1, xy={0, 0}}))
			else actor:addParticles(Particles.new("crystalline_focus", 1))
			end
		end,
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {radius=1.1}, {type="sparks", hide_center=0, zoom=3, xy={0, 0}}))
			else actor:addParticles(Particles.new("tempest", 1))
			end
		end,
	},
	talents_types = {
		["spell/arcane"]={true, 0.3},
		["spell/aether"]={false, 0.3},
		["spell/fire"]={true, 0.3},
		["spell/earth"]={true, 0.3},
		["spell/water"]={true, 0.3},
		["spell/air"]={true, 0.3},
		["spell/phantasm"]={true, 0.3},
		["spell/temporal"]={false, 0.3},
		["spell/meta"]={false, 0.3},
		["spell/divination"]={true, 0.3},
		["spell/conveyance"]={true, 0.3},
		["spell/aegis"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
	},
	unlockable_talents_types = {
		["spell/wildfire"]={false, 0.3, "mage_pyromancer"},
		["spell/ice"]={false, 0.3, "mage_cryomancer"},
		["spell/stone"]={false, 0.3, "mage_geomancer"},
		["spell/storm"]={false, 0.3, "mage_tempest"},
	},
	talents = {
		[ActorTalents.T_ARCANE_POWER] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_LIGHTNING] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
	},
	copy = {
		-- Mages start in angolwen
		class_start_check = function(self)
			if self.descriptor.world == "Maj'Eyal" and (self.descriptor.race == "Human" or self.descriptor.race == "Elf" or self.descriptor.race == "Halfling") then
				self.archmage_race_start_quest = self.starting_quest
				self.default_wilderness = {"zone-pop", "angolwen-portal"}
				self.starting_zone = "town-angolwen"
				self.starting_quest = "start-archmage"
				self.starting_intro = "archmage"
				self.faction = "angolwen"
				self:learnTalent(self.T_TELEPORT_ANGOLWEN, true, nil, {no_unlearn=true})
			end
		end,

		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Necromancer",
	locked = function() return profile.mod.allow_build.mage_necromancer end,
	locked_desc = "The road to necromancy is a macabre path indeed. Walk with the dead, and drink deeply of their black knowledge.",
	desc = {
		"While most magic is viewed with suspicion since the Spellblaze, the stigma surrounding the black art of Necromancy has been around since time immemorial.",
		"These dark spellcasters extinguish life, twist death, and raise armies of undead monsters to sate their lust for power and pursue their ultimate goal: Eternal life.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +3 Willpower, +1 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# -3",
	},
	power_source = {arcane=true},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["spell/conveyance"]={true, 0.2},
		["spell/divination"]={true, 0.2},
		["spell/necrotic-minions"]={true, 0.3},
		["spell/advanced-necrotic-minions"]={false, 0.3},
		["spell/shades"]={false, 0.3},
		["spell/necrosis"]={true, 0.3},
		["spell/nightfall"]={true, 0.3},
		["spell/grave"]={true, 0.3},
		["cunning/survival"]={true, -0.1},
	},
	unlockable_talents_types = {
		["spell/ice"]={false, 0.2, "mage_cryomancer"},
	},
	birth_example_particles = {
		"necrotic-aura",
		function(actor)
			actor:addParticles(Particles.new("ultrashield", 1, {rm=0, rM=0, gm=0, gM=0, bm=10, bM=100, am=70, aM=180, radius=0.4, density=60, life=14, instop=20}))
		end,
	},
	talents = {
		[ActorTalents.T_NECROTIC_AURA] = 1,
		[ActorTalents.T_CREATE_MINIONS] = 1,
		[ActorTalents.T_ARCANE_EYE] = 1,
		[ActorTalents.T_INVOKE_DARKNESS] = 1,
		[ActorTalents.T_BLURRED_MORTALITY] = 1,
	},
	copy = {
		necrotic_aura_base_souls = 1,
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
--			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = -3,
		resolvers.generic(function(self)
			self:grantQuest("lichform")
			if game.state.birth.campaign_name ~= "maj-eyal" then self:setQuestStatus("lichform", engine.Quest.DONE) end
		end),
	},
}
