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

load("/data/general/objects/objects.lua")
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_LORE",
	define_as = "ARENA_SCORING",
	name = "Arena for dummies", lore="arena-scoring",
	desc = [[A note explaining the arena's scoring rules. Someone must have dropped it.]],
	rarity = false,
	is_magic_device = false,
	encumberance = 0,
}


-- Id stuff
newEntity{ define_as = "ORB_KNOWLEDGE",
	unique = true, quest=true,
	type = "jewelry", subtype="orb",
	unided_name = "orb", no_unique_lore = true,
	name = "Orb of Knowledge", identified = true,
	display = "*", color=colors.VIOLET, image = "object/ruby.png",
	encumber = 1,
	desc = [[This orb was given to you by Elisa the halfling scryer, it will automatically identify normal and rare items for you and can be activated to identify all others.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "use the orb", power = 1,
		use = function(self, who)
			for inven_id, inven in pairs(who.inven) do
				for item, o in ipairs(inven) do
					if not o:isIdentified() then
						o:identify(true)
						game.logPlayer(who, "You have: %s", o:getName{do_colour=true})
					end
				end
			end
		end
	},

	carrier = {
		auto_id = 1,
	},
}

newEntity{
	define_as = "ARENA_BOOTS_DISE",
	slot = "FEET",
	type = "armor", subtype="feet",
	add_name = " (#ARMOR#)",
	display = "]", color=colors.UMBER, image = resolvers.image_material("boots", "leather"),
	encumber = 2,
	desc = [[A pair of boots made of leather. They seem to be of exceptional quality.]],
	name = "a pair of leather boots of disengagement", suffix=true, instant_resolve=true,
	egoed = true,
	greater_ego = true,
	identified = true,
	rarity = false,
	cost = 0,
	material_level = 1,
	wielder = {
		combat_armor = 2,
		fatigue = 1,
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_DISENGAGE, level = 2, power = 10 },
}

newEntity{
	define_as = "ARENA_BOOTS_PHAS",
	slot = "FEET",
	type = "armor", subtype="feet",
	add_name = " (#ARMOR#)",
	display = "]", color=colors.UMBER, image = resolvers.image_material("boots", "leather"),
	encumber = 2,
	desc = [[A pair of boots made of leather. They seem to be of exceptional quality.]],
	name = "a pair of leather boots of phasing", suffix=true, instant_resolve=true,
	egoed = true,
	greater_ego = true,
	identified = true,
	cost = 0,
	rarity = false,
	material_level = 1,
	wielder = {
		combat_armor = 2,
		fatigue = 1,
	},
	max_power = 25, power_regen = 1,
	use_power = { name = "blink to a nearby random location", power = 15, use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 10 + who:getMag(5))
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game:playSoundNear(who, "talents/teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}
}

newEntity{
	define_as = "ARENA_BOOTS_RUSH",
	slot = "FEET",
	type = "armor", subtype="feet",
	add_name = " (#ARMOR#)",
	display = "]", color=colors.UMBER, image = resolvers.image_material("boots", "leather"),
	encumber = 2,
	desc = [[A pair of boots made of leather. They seem to be of exceptional quality.]],
	name = "a pair of leather boots of rushing", suffix=true, instant_resolve=true,
	egoed = true,
	rarity = false,
	greater_ego = true,
	identified = true,
	cost = 0,
	material_level = 1,
	wielder = {
		combat_armor = 2,
		fatigue = 1,
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_RUSH, level = 2, power = 10 },
}

newEntity{
	define_as = "ARENA_DEBUG_CANNON",
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="cannon",
	name = "debug cannon",
	display = "}", color=colors.BLUE,
	encumber = 4,
	egoed = true,
	unique = true,
	greater_ego = true,
	identified = true,
	max_power = 20, power_regen = 1,
	cost = 0,
	material_level = 1,
	rarity = 9999999999999,
	metallic = true,
	twohanded = true,
	combat = { talented = "bow", sound = "actions/arrow", sound_miss = "actions/arrow",},
	archery = "bow",
	combat = {
		range = 16,
		physspeed = 1,
		talented = "mace",
		dam = resolvers.rngavg(22,30),
		apr = 2,
		physcrit = 1,
		dammod = {str=1.2},
		damrange = 1.5,
		sound = "actions/melee",
		sound_miss = "actions/melee_miss",
	},
	basic_ammo = {
		dam = 3000,
		apr = 5000,
		physcrit = 10,
		dammod = {wil = 2},
	},
	wielder = {
		ranged_project={
			[DamageType.LIGHTNING] = 3000,
			[DamageType.LIGHT] = 3000,
		},
		fatigue = 1,
	},
	desc = [[A powerful weapon from another world. It operates on a graviton engine.]],
	use_talent = { id = Talents.T_GRAVITY_SPIKE, level = 6, power = 10 },
}

newEntity{
	define_as = "ARENA_DEBUG_ARMOR",
	slot = "BODY",
	type = "armor", subtype="mechanic",
	add_name = " (#ARMOR#)",
	display = "[", color=colors.SLATE, image = resolvers.image_material("plate", "metal"),
	unique = true,
	name = "Full frame",
	unided_name = "Strange armor",
	desc = [[A powered armor from another world. Worn by fighters facing unstable dimensional fields.]],
	color = colors.BLACK,
	metallic = true,
	rarity = 99999999999,
	cost = 250,
	material_level = 3,
	max_power = 20, power_regen = 1,
	wielder = {
		combat_armor = 120,
		combat_def = 120,
		combat_def_ranged = 120,
		max_encumber = 300,
		life_regen = 1000,
		stamina_regen = 20,
		fatigue = 0,
		max_stamina = 500,
		max_life = 3000,
		knockback_immune = 1,
		stun_immune = 1,
		size_category = 2,
	},
	use_talent = { id = Talents.T_TWILIGHT_SURGE, level = 99, power = 10 },
}


newEntity{
	define_as = "ARENA_BOOTS_LSPEED",
	slot = "FEET",
	type = "armor", subtype="feet",
	add_name = " (#ARMOR#)",
	display = "]", color=colors.UMBER, image = resolvers.image_material("boots", "leather"),
	encumber = 2,
	desc = [[A pair of boots made of leather. They seem to be of exceptional quality.]],
	name = "a pair of leather boots of lightning speed", suffix=true, instant_resolve=true,
	egoed = true,
	greater_ego = true,
	identified = true,
	rarity = false,
	cost = 0,
	material_level = 1,
	wielder = {
		combat_armor = 2,
		fatigue = 1,
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_LIGHTNING_SPEED, level = 2, power = 10 },
}

newEntity{
	define_as = "ARENA_BOW",
	base = "BASE_LONGBOW",
	name = "elm longbow of steady shot",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	rarity = false,
	egoed = true,
	greater_ego = true,
	identified = true,
	cost = 0,
	material_level = 1,
	use_talent = { id = Talents.T_STEADY_SHOT, level = 2, power = 10 },
	max_power = 15, power_regen = 1,
	combat = {
		range = 8,
		physspeed = 0.8,
	},
	basic_ammo = {
		dam = 12,
		apr = 5,
		physcrit = 1,
		dammod = {dex=0.7, str=0.5},
	},
}

newEntity{
	define_as = "ARENA_SLING",
	base = "BASE_SLING",
	name = "rough leather sling of flare",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	rarity = false,
	egoed = true,
	greater_ego = true,
	identified = true,
	cost = 0,
	material_level = 1,
	use_talent = { id = Talents.T_FLARE, level = 2, power = 15 },
	max_power = 15, power_regen = 1,
	combat = {
		range = 8,
		physspeed = 0.8,
	},
	basic_ammo = {
		dam = 12,
		apr = 1,
		physcrit = 4,
		dammod = {dex=0.7, cun=0.5},
	},
}

newEntity{
	base = "BASE_AMULET",
	color=colors.BLACK,
	rarity = 12,
	add_name = "#CHARGES#",
	use_sound = "talents/spell_generic",
	is_magic_device = true,
	unique = true,
	name = "amulet of shadow warding",
	define_as = "WARDING",
	material_level = 4,
	max_power = 25, power_regen = 1,
	use_power = { name = "multiply your shadow to trap enemies inside", power = 1, use = function(self, who)
		local Trap = require "mod.class.Trap"
		local radius = 1 + math.floor(self.material_level * 0.3)
		local grids = who:project({type = "ball", radius = radius}, who.x, who.y, function(px, py)
			if game.level.map:checkAllEntities(px, py, "block_move", who) then return false end
			local t = Trap.new{
				type = "elemental", id_by_type=true, unided_name = "trap",
				name = "lurking shadow", color=colors.BLACK, display = '^',
				dam = self.material_level * (who:getCun(20) + who:getMag(20)),
				check_hit = self.material_level * 15,
				faction = self.faction,
				triggered = function(self, x, y, who)
					if who == self.summoner then return false, false end
					game.logSeen(self.summoner, "The shadow emerges and engulfs "..who.name:capitalize().."!")
					game:playSoundNear(self.summoner, "talents/arcane")
					self:project({type="hit", x=x,y=y}, x, y, engine.DamageType.DARKNESS, self.dam, {type="dark"})
					return true, true
				end,
				summoner = who, timer = rng.range(2, 4) + self.material_level, canAct = false, energy = { value = 0 },
				act = function(self)
					self:useEnergy()
					self.timer = self.timer - 1
					if self.timer <= 0 then
						game.level.map:remove(self.x, self.y, engine.Map.TRAP)
						game.level:removeEntity(self)
					end
				end,
			}
			t.x, t.y = px, py
			t:identify(true)
			t:resolve()
			t:resolve(nil, true)
			t:setKnown(who, true)
			game.level:addEntity(t)
			game.zone:addEntity(game.level, t, "trap", px, py)
		end)
		return true
		end
	}
}

newEntity{
	type = "wand", subtype="wand",
	unided_name = "wand", id_by_type = true,
	display = "-", color=colors.WHITE, image = resolvers.image_material("wand", "wood"),
	encumber = 2,
	rarity = 9,
	add_name = "#CHARGES#",
	use_sound = "talents/spell_generic",
	is_magic_device = true,
	name = "wand of barrage",
	define_as = "BARRAGE",
	color = colors.UMBER,
	level_range = {1, 10},
	cost = 1,
	material_level = 3,
	desc = [[Magical wands are made by powerful Alchemists and Archmagi to store spells. Anybody can use them to release the spells.]],
	max_power = 25, power_regen = 1,
	use_power = { name = "unleash a barrage of elemental shots", power = 15,
		use = function(self, who)
			local tg = {type = "ball", range = 8, radius = 2, talent = {requires_target=false} }
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			local grids = who:project(tg, x, y, function(px, py)
			local tg2 = {type="bolt", range=12, talent = {proj_speed = rng.range(2, 4), requires_target=false}}
			local elem = rng.table{
				{DamageType.ACID, "acid"},
				{DamageType.FIRE, "flame"},
				{DamageType.COLD, "freeze"},
				{DamageType.LIGHTNING, "lightning_explosion"},
				{DamageType.ACID, "acid"},
				{DamageType.NATURE, "slime"},
				{DamageType.BLIGHT, "blood"},
				{DamageType.LIGHT, "light"},
				{DamageType.ARCANE, "manathrust"},
				{DamageType.DARKNESS, "dark"},
			}
			tg2.display={particle="bolt_elemental", trail="generictrail"}
			who:projectile(tg2, px, py, elem[1], math.floor(5 * self.material_level), {type=elem[2]})
			end)
			game:playSoundNear(who, "talents/arcane")
			return true
		end
	}
}
newEntity{
	type = "wand", subtype="wand",
	unided_name = "wand", id_by_type = true,
	display = "-", color=colors.WHITE, image = resolvers.image_material("wand", "wood"),
	encumber = 2,
	rarity = 9,
	add_name = "#CHARGES#",
	use_sound = "talents/spell_generic",
	is_magic_device = true,
	name = "wand of heat eater",
	define_as = "HEATEATER",
	color = colors.UMBER,
	level_range = {1, 10},
	cost = 1,
	material_level = 3,
	desc = [[Magical wands are made by powerful Alchemists and Archmagi to store spells. Anybody can use them to release the spells.]],
	max_power = 25, power_regen = 1,
	use_power = { name = "unleash a barrage of elemental shots", power = 15,
		use = function(self, who)
			local rad = self.material_level
			local damage = 0
			for i = who.x - rad, who.x + rad do for j = who.y - rad, who.y + rad do if game.level.map:isBound(i, j) then
				local actor = game.level.map(i, j, game.level.map.ACTOR)
				if actor and not actor.player and who:reactionToward(actor) < 0 then
					local x, y = who:getTarget(tg)
					local tg = {type="bolt", range=self.material_level, talent = {direct_hit = true}}
					local d = math.floor(5 * self.material_level)
					who:project(tg, i, j, DamageType.COLD, d, {type="freeze"})
					game.log("You steal "..d.." degrees from your enemy!")
					damage = d + damage
				end
			end end end
			game:playSoundNear(who, "talents/freeze")
			tg = nil
			tg = {type = "bolt", range = 10, talent = { requires_target = true }, display = {particle="bolt_fire", trail="firetrail"}}
			x, y = who:getTarget(tg)
			if not x or not y then return nil end
			game.log("You release a "..damage.." degrees hot calorific bolt!")
			who:projectile(tg, x, y, DamageType.FIRE, damage, {type="flame"})
			return true
		end
	}
}


newEntity{ name = "steel gauntlets of the raptor",
	slot = "HANDS",
	define_as = "RAPTOR",
	type = "armor", subtype="hands",
	add_name = " (#ARMOR#)(#CHARGES#)",
	display = "[", color=colors.SLATE,
	--require = { talent = { Talents.T_HEAVY_ARMOUR_TRAINING }, },
	encumber = 4,
	rarity = 12,
	metallic = true,
	use_sound = "talents/spell_generic",
	is_magic_device = true,
	greater_ego = true,
	egoed = true,
	level_range = {20, 40},
	cost = 7,
	material_level = 2,
	wielder = {
		combat_armor = 2,
	},
	desc = [[Heavy gauntlets covering the full arms. They have engravings resembling hawk's wings. They are full with magical energies.]],
	max_power = 35, power_regen = 1,
	use_power = { name = "punch an enemy with supernatural might, then rush towards it with the speed of a hawk", power = 15,
		use = function(self, who)
			if who:hasTwoHandedWeapon() then
				game.log("You can't punch while wielding a two-handed weapon!")
			end
			local tg = {type="hit", range=1}
			local x, y, target = who:getTarget(tg)
			if not x or not y or not target then return nil, true end
			if math.floor(core.fov.distance(who.x, who.y, x, y)) > 1 then return nil, true end
			local knuckles = {
				range = 1, physspeed = 1,
				damrange = 1.4, talented = "mace",
				sound = "talents/lightning", sound_miss = "actions/melee_miss",
				dam = self.material_level * 11, apr = 2 + self.material_level,
				physcrit = 0.5 + (self.material_level * 0.5), dammod = {str=0.3, dex=0.3, mag=0.4}
			}
			local _, hit = who:attackTargetWith(target, knuckles, DamageType.LIGHTNING, 1)
			if hit then
				game:playSoundNear(who, "talents/lightning")
				game.logSeen(target, "%s punches %s with magical energies!", who.name:capitalize(), target.name:capitalize())
				if target:checkHit(who:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5) and target:canBe("knockback") then
					target:knockback(who.x, who.y, 4)
					tg = {type="hit", range = 4}
					local l = line.new(who.x, who.y, target.x, target.y)
					local hitact = function ()
						game:playSoundNear(who, "talents/lightning")
						game.level.map:particleEmitter(target.x, target.y, 0.5, "lightning_explosion")
					end
					local lx, ly = l()
					local tx, ty = who.x, who.y
					lx, ly = l()
					while lx and ly do
						if game.level.map:checkAllEntities(lx, ly, "block_move", who) then break end
						tx, ty = lx, ly
						lx, ly = l()
					end
					local ox, oy = who.x, who.y
					who:move(tx, ty, true)
					if config.settings.tome.smooth_move > 0 then
						who:resetMoveAnim() who:setMoveAnim(ox, oy, 4, 5)
					end
					if math.floor(core.fov.distance(who.x, who.y, target.x, target.y)) == 1 then
						game:playSoundNear(who, "talents/lightning")
						game.logSeen(target, "%s strikes %s at full speed.", who.name:capitalize(), target.name:capitalize())
						_, hit = who:attackTargetWith(target, knuckles, DamageType.LIGHTNING, 1.2)
						if hit then hitact() end
					end
				else
					game.logSeen(target, "%s resists the knockback! %s punches again!", who.name:capitalize(), target.name:capitalize())
					_, hit = who:attackTargetWith(target, knuckles, DamageType.LIGHTNING, 1.2)
					if hit then hitact() end
					return nil, true
				end
			end
			return nil, true
		end
	}
}

newEntity{
	define_as = "ARENA_BOOTS_JUMPING",
	slot = "FEET",
	type = "armor", subtype="feet",
	add_name = " (#ARMOR#)(#CHARGES#)",
	display = "]", color=colors.UMBER, image = resolvers.image_material("boots", "leather"),
	encumber = 2,
	desc = [[A pair of boots made of leather. They seem to be of exceptional quality.]],
	name = "a pair of leather boots of jumping", suffix=true, instant_resolve=true,
	egoed = true,
	greater_ego = true,
	identified = true,
	cost = 0,
	rarity = false,
	material_level = 1,
	wielder = {
		combat_armor = 2,
		fatigue = 1,
	},
	max_power = 25, power_regen = 1,
	use_power = { name = "jump one square away", power = 1, use = function(self, who)
		if who:attr("never_move") then game.logPlayer(who, "#YELLOW#You cannot jump!") return end
		local tg = {default_target=who, type="bolt", nowarning=true, nolock = true, range = 2, {requires_target = false}}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		if math.floor(core.fov.distance(who.x, who.y, x, y)) > 2 then return nil, true end
		local l = line.new(who.x, who.y, x, y)
		local lx, ly = l()
		local tx, ty = self.x, self.y
		lx, ly = l()
		while lx and ly do
			if game.level.map:checkAllEntities(lx, ly, "block_move", who) then break end
			tx, ty = lx, ly
			lx, ly = l()
		end
		local ox, oy = who.x, who.y
		who:move(tx, ty, true)
		game:playSoundNear(who, "actions/melee")
		if config.settings.tome.smooth_move > 0 then
			who:resetMoveAnim()
			who:setMoveAnim(ox, oy, 6, 4)
		end
		return nil, true
	end}
}
