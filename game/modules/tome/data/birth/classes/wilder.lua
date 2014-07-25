-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	name = "Wilder",
	locked = function() return profile.mod.allow_build.wilder_wyrmic or profile.mod.allow_build.wilder_summoner or profile.mod.allow_build.wilder_stone_warden end,
	locked_desc = "Natural abilities can go beyond mere skill. Experience the true powers of nature to learn of its amazing gifts.",
	desc = {
		"Wilders are one with nature, in one manner or another. There are as many different Wilders as there are aspects of nature.",
		"They can take on the aspects of creatures, summon creatures to them, feel the druidic call, ...",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Summoner = "allow",
			Wyrmic = "allow",
			Oozemancer = "allow",
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Summoner",
	locked = function() return profile.mod.allow_build.wilder_summoner end,
	locked_desc = "Not all might comes from within. Hear the invocations of nature, hear its calling power. See that from without we can find our true strengths.",
	desc = {
		"Summoners never fight alone. They are always ready to summon one of their many minions to fight at their side.",
		"Summons can range from a combat hound to a fire drake.",
		"Their most important stats are: Willpower and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +1 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +5 Willpower, +3 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	power_source = {nature=true},
	getStatDesc = function(stat, actor)
		if stat == actor.STAT_CUN then
			return "Max summons: "..math.floor(actor:getCun()/10)
		end
	end,
	stats = { wil=5, cun=3, dex=1, },
	birth_example_particles = {
		function(actor)
			if actor:addShaderAura("master_summoner", "awesomeaura", {time_factor=6200, alpha=0.7, flame_scale=0.8}, "particles_images/naturewings.png") then
			elseif core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {radius=1.1}, {type="flames", zoom=2, npow=4, time_factor=4000, color1={0.2,0.7,0,1}, color2={0,1,0.3,1}, hide_center=0, xy={self.x, self.y}}))
			else actor:addParticles(Particles.new("master_summoner", 1))
			end
		end,
	},
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/harmony"]={false, 0.1},
		["wild-gift/summon-melee"]={true, 0.3},
		["wild-gift/summon-distance"]={true, 0.3},
		["wild-gift/summon-utility"]={true, 0.3},
		["wild-gift/summon-augmentation"]={false, 0.3},
		["wild-gift/summon-advanced"]={false, 0.3},
		["wild-gift/mindstar-mastery"]={false, 0.1},
		["cunning/survival"]={true, 0},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={false, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_WAR_HOUND] = 1,
		[ActorTalents.T_RITCH_FLAMESPITTER] = 1,
		[ActorTalents.T_MEDITATION] = 1,
		[ActorTalents.T_HEIGHTENED_SENSES] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Wyrmic",
	locked = function() return profile.mod.allow_build.wilder_wyrmic end,
	locked_desc = "Sleek, majestic, powerful... In the path of dragons we walk, and their breath is our breath. See their beating hearts with your eyes and taste their majesty between your teeth.",
	desc = {
		"Wyrmics are fighters who have learnt how to mimic some of the aspects of the dragons.",
		"They have access to talents normally belonging to the various kind of drakes.",
		"Their most important stats are: Strength and Willpower",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +5 Strength, +0 Dexterity, +1 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +3 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	birth_example_particles = {
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, life=18, fade=-0.006, deploy_speed=14})) end end,
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="lightningwings", life=18, fade=-0.006, deploy_speed=14})) end end,
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="poisonwings", life=18, fade=-0.006, deploy_speed=14})) end end,
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="acidwings", life=18, fade=-0.006, deploy_speed=14})) end end,
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="sandwings", life=18, fade=-0.006, deploy_speed=14})) end end,
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="icewings", life=18, fade=-0.006, deploy_speed=14})) end end,
	},
	power_source = {nature=true, technique=true},
	stats = { str=5, wil=3, con=1, },
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/harmony"]={false, 0.1},
		["wild-gift/sand-drake"]={true, 0.3},
		["wild-gift/fire-drake"]={true, 0.3},
		["wild-gift/cold-drake"]={true, 0.3},
		["wild-gift/storm-drake"]={true, 0.3},
		["wild-gift/venom-drake"]={true, 0.3},
		["wild-gift/higher-draconic"]={false, 0.3},
		["wild-gift/fungus"]={true, 0.1},
		["cunning/survival"]={false, 0},
		["technique/shield-offense"]={true, 0.1},
		["technique/2hweapon-assault"]={true, 0.1},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={true, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_ICE_CLAW] = 1,
		[ActorTalents.T_MEDITATION] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		drake_touched = 2,
		max_life = 110,
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
		},
	},
	copy_add = {
		life_rating = 2,
	},
}


newBirthDescriptor{
	type = "subclass",
	name = "Oozemancer",
	locked = function() return profile.mod.allow_build.wilder_oozemancer end,
	locked_desc = "Magic must fail, magic must lose, nothing arcane can face the ooze...",
	desc = {
		"Oozemancers separate themselves from normal civilisation so that they be more in harmony with Nature. Arcane force are reviled by them, and their natural attunement to the wilds lets them do battle with abusive magic-users on an equal footing.",
		"They can spawn oozes to protect and attack from a distance while also being adept at harnessing the power of mindstars and psiblades.",
		"Their most important stats are: Willpower and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +5 Willpower, +4 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# -3",
	},
	power_source = {nature=true, antimagic=true},
	random_rarity = 3,
	getStatDesc = function(stat, actor)
		if stat == actor.STAT_CUN then
			return "Max summons: "..math.floor(actor:getCun()/10)
		end
	end,
	birth_example_particles = {
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {additive=true, radius=1.1}, {type="flames", zoom=5, npow=2, time_factor=9000, color1={0.5,0.7,0,1}, color2={0.3,1,0.3,1}, hide_center=0, xy={0,0}}))
			else actor:addParticles(Particles.new("master_summoner", 1))
			end
		end,
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {additive=true, radius=1.1}, {type="flames", zoom=0.5, npow=4, time_factor=2000, color1={0.5,0.7,0,1}, color2={0.3,1,0.3,1}, hide_center=0, xy={0,0}}))
			else actor:addParticles(Particles.new("master_summoner", 1))
			end
		end,
	},
	stats = { wil=5, cun=4, },
	talents_types = {
		["cunning/survival"]={true, 0.1},
		["wild-gift/call"]={true, 0.3},
		["wild-gift/antimagic"]={true, 0.3},
		["wild-gift/mindstar-mastery"]={true, 0.3},
		["wild-gift/mucus"]={true, 0.3},
		["wild-gift/ooze"]={true, 0.3},
		["wild-gift/fungus"]={false, 0.3},
		["wild-gift/oozing-blades"]={false, 0.3},
		["wild-gift/corrosive-blades"]={false, 0.3},
		["wild-gift/moss"]={true, 0.3},
		["wild-gift/eyals-fury"]={false, 0.3},
		["wild-gift/slime"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_PSIBLADES] = 1,
		[ActorTalents.T_MITOSIS] = 1,
		[ActorTalents.T_MUCUS] = 1,
		[ActorTalents.T_SLIME_SPIT] = 1,
	},
	copy = {
		forbid_arcane = 2,
		max_life = 90,
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = -3,
	},
}
