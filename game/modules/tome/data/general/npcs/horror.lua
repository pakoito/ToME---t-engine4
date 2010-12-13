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

-- last updated:  10:46 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_HORROR",
	type = "horror", subtype = "eldritch",
	display = "h", color=colors.WHITE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=3, },

	stats = { str=22, dex=20, wil=15, con=15 },
	energy = { mod=1 },
	combat_armor = 0, combat_def = 0,
	combat = { dam=5, atk=15, apr=7, dammod={str=0.6} },
	infravision = 20,
	max_life = resolvers.rngavg(10,20),
	rank = 2,
	size_category = 3,

	no_breath = 1,
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "worm that walks", color=colors.SANDY_BROWN,
	desc = [[A maggot-filled robe with a vaguely humanoid shape.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 5,
	max_life = 120,
	life_rating = 16,
	rank = 3,

	see_invisible = 100,
	instakill_immune = 1,
	stun_immune = 1,
	blind_immune = 1,

	resists = { [DamageType.PHYSICAL] = 50, [DamageType.FIRE] = -50},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.equip{
		{type="weapon", subtype="sword", autoreq=true},
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="robe", autoreq=true}
	},

	resolvers.talents{
		[Talents.T_BONE_GRAB]=4,
		[Talents.T_DRAIN]=5,
		[Talents.T_CORRUPTED_STRENGTH]=3,
		[Talents.T_VIRULENT_DISEASE]=3,
		[Talents.T_CURSE_OF_DEATH]=5,
		[Talents.T_REND]=4,
		[Talents.T_BLOODLUST]=3,
		[Talents.T_RUIN]=2,

		[Talents.T_WEAPON_COMBAT]=5,
		[Talents.T_WEAPONS_MASTERY]=3,
	},
	resolvers.sustains_at_birth(),

	summon = {
		{type="vermin", subtype="worms", name="carrion worm mass", number=2, hasxp=false},
	},
	make_escort = {
		{type="vermin", subtype="worms", name="carrion worm mass", number=2},
	},
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "bloated horror", color=colors.WHITE,
	desc ="A bulbous humanoid form floats here. Its bald, child-like head is disproportionately large compared to its body, and its skin is pock-marked in nasty red sores.",
	level_range = {27, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	size_category = 4,
	autolevel = "caster",
	combat_armor = 1, combat_def = 0,
	combat = {dam=resolvers.mbonus(25, 15), apr=0, atk=resolvers.mbonus(30, 15), dammod={mag=0.6}},

	never_move = 1,

	resists = {all = 35, [DamageType.LIGHT] = -30},

	resolvers.talents{
		[Talents.T_FEATHER_WIND]=5,
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_MIND_DISRUPTION]=4,
		[Talents.T_MIND_SEAR]=4,
		[Talents.T_TELEKINETIC_BLAST]=4,
	},

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "nightmare horror", color=colors.DARK_GREY,
	desc ="A shifting form of darkest night that seems to reflect your deepest fears.",
	level_range = {30, nil}, exp_worth = 1,
	negative_regen = 10,
	rarity = 7,
	rank = 3,
	life_rating = 7,
	autolevel = "warriormage",
	stats = { str=15, dex=20, mag=20, wil=20, con=15 },
	combat_armor = 1, combat_def = 10,
	combat = { dam=20, atk=20, apr=50, dammod={str=0.6}, damtype=DamageType.DARKNESS},

	ai = "dumb_talented_simple", ai_state = { ai_target="target_player_radius", sense_radius=40, talent_in=2, },

	can_pass = {pass_wall=70},
	resists = {all = 35, [DamageType.LIGHT] = -50, [DamageType.DARKNESS] = 100},

	blind_immune = 1,
	see_invisible = 80,
	no_breath = 1,

	resolvers.talents{
		[Talents.T_STALK]=5,
		[Talents.T_GLOOM]=3,
		[Talents.T_WEAKNESS]=3,
		[Talents.T_TORMENT]=3,
		[Talents.T_DOMINATE]=3,
		[Talents.T_BLINDSIDE]=3,
		[Talents.T_LIFE_LEECH]=5,
		[Talents.T_SHADOW_BLAST]=4,
		[Talents.T_HYMN_OF_SHADOWS]=3,
	},

	resolvers.sustains_at_birth(),
}


------------------------------------------------------------------------
-- Headless horror and its eyes
------------------------------------------------------------------------
newEntity{ base = "BASE_NPC_HORROR",
	name = "headless horror", color=colors.TAN,
	desc ="A headless gangly humanoid with a large distended stomach.",
	level_range = {30, nil}, exp_worth = 1,
	rarity = 3,
	rank = 3,
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	combat = { dam=20, atk=20, apr=10, dammod={str=1} },
	combat = {damtype=DamageType.PHYSICAL},
	no_auto_resists = true,

	-- Should get resists based on eyes generated, 30% all per eye and 100% to the eyes element.  Should lose said resists when the eyes die.

	-- Should be blind but see through the eye escorts
	--blind= 1,

	resolvers.talents{
		[Talents.T_MANA_CLASH]=5,
		[Talents.T_GRAB]=5,
	},

	-- Add eyes
	on_added_to_level = function(self)
		local eyes = {}
		for i = 1, 3 do
			local x, y = util.findFreeGrid(self.x, self.y, 15, true, {[engine.Map.ACTOR]=true})
			if x and y then
				local m = game.zone:makeEntity(game.level, "actor", {properties={"is_eldritch_eye"}, special_rarity="_eldritch_eye_rarity"}, nil, true)
				if m then
					m.summoner = self
					game.zone:addEntity(game.level, m, "actor", x, y)
					eyes[m] = true

					-- Grant resist
					local damtype = next(m.resists)
					self.resists[damtype] = 100
					self.resists.all = (self.resists.all or 0) + 30
				end
			end
		end
		self.eyes = eyes
	end,

	-- Needs an on death affect that kills off any remaining eyes.
	on_die = function(self, src)
		local nb = 0
		for eye, _ in pairs(self.eyes) do
			if not eye.dead then eye:die(src) nb = nb + 1 end
		end
		if nb > 0 then
			game.logSeen(self, "#AQUAMARINE#As %s falls all its eyes fall to the ground!", self.name)
		end
	end,
}

newEntity{ base = "BASE_NPC_HORROR", define_as = "BASE_NPC_ELDRICTH_EYE",
	name = "eldritch eye", color=colors.SLATE, is_eldritch_eye=true,
	desc ="A small bloadshot eye floats here.",
	level_range = {30, nil}, exp_worth = 1,
	life_rating = 7,
	rank = 2,
	size_category = 1,
	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },
	combat_armor = 1, combat_def = 0,
	levitation = 1,
	no_auto_resists = true,
	talent_cd_reduction = {all=100},

	on_die = function(self, src)
		if not self.summoner then return end
		game.logSeen(self, "#AQUAMARINE#As %s falls %s seems to weaken!", self.name, self.summoner.name)
		local damtype = next(self.resists)
		self.summoner.resists.all = (self.summoner.resists.all or 0) - 30
		self.summoner[damtype] = nil

		-- Blind the main horror if no more eyes
		local nb = 0
		for eye, _ in pairs(self.summoner.eyes) do
			if not eye.dead then nb = nb + 1 end
		end
		if nb == 0 then
			local sx, sy = game.level.map:getTileToScreen(self.summoner.x, self.summoner.y)
			game.flyers:add(sx, sy, 20, (rng.range(0,2)-1) * 0.5, -3, "+Blind", {255,100,80})
			self.summoner.blind = 1
			game.logSeen(self.summoner, "%s is blinded by the loss of all its eyes.", self.summoner.name:capitalize())
		end
	end,
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--fire
	_eldritch_eye_rarity = 1,
	vim_regen = 100,
	resists = {[DamageType.FIRE] = 80},
	resolvers.talents{
		[Talents.T_BURNING_HEX]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--cold
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.COLD] = 80},
	resolvers.talents{
		[Talents.T_ICE_SHARDS]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--earth
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.PHYSICAL] = 80},
	resolvers.talents{
		[Talents.T_STRIKE]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--arcane
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.ARCANE] = 80},
	resolvers.talents{
		[Talents.T_MANATHRUST]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--acid
	_eldritch_eye_rarity = 1,
	equilibrium_regen = -100,
	resists = {[DamageType.ACID] = 80},
	resolvers.talents{
		[Talents.T_HYDRA]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--dark
	_eldritch_eye_rarity = 1,
	vim_regen = 100,
	resists = {[DamageType.DARKNESS] = 80},
	resolvers.talents{
		[Talents.T_CURSE_OF_DEATH]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--light
	_eldritch_eye_rarity = 1,
	resists = {[DamageType.LIGHT] = 80},
	resolvers.talents{
		[Talents.T_SEARING_LIGHT]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--lightning
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.LIGHTNING] = 80},
	resolvers.talents{
		[Talents.T_LIGHTNING]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--blight
	_eldritch_eye_rarity = 1,
	vim_regen = 100,
	resists = {[DamageType.BLIGHT] = 80},
	resolvers.talents{
		[Talents.T_VIRULENT_DISEASE]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--nature
	_eldritch_eye_rarity = 1,
	equilibrium_regen = -100,
	resists = {[DamageType.NATURE] = 80},
	resolvers.talents{
		[Talents.T_SPIT_POISON]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--mind
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.MIND] = 80},
	resolvers.talents{
		[Talents.T_MIND_DISRUPTION]=3,
	},
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "luminous horror", color=colors.YELLOW,
	desc ="A lanky humanoid shape composed of yellow light.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 2,
	autolevel = "caster",
	combat_armor = 1, combat_def = 10,
	combat = { dam=5, atk=15, apr=20, dammod={wil=0.6}, damtype=DamageType.LIGHT},
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },

	resists = {all = 35, [DamageType.DARKNESS] = -50, [DamageType.LIGHT] = 100, [DamageType.FIRE] = 100},

	blind_immune = 1,
	see_invisible = 10,

	resolvers.talents{
		[Talents.T_CHANT_OF_FORTITUDE]=3,
		[Talents.T_SEARING_LIGHT]=3,
		[Talents.T_FIREBEAM]=3,
		[Talents.T_PROVIDENCE]=3,
		[Talents.T_HEALING_LIGHT]=3,
		[Talents.T_BARRIER]=3,
	},

	resolvers.sustains_at_birth(),

	make_escort = {
		{type="horror", subtype="eldritch", name="luminous horror", number=2, no_subescort=true},
	},
}

newEntity{ base = "BASE_NPC_HORROR", define_as="TEST",
	name = "radiant horror", color=colors.GOLD,
	desc ="A lanky four-armed humanoid shape composed of bright golden light.  It's so bright it's hard to look at and you can feel heat radiating outward from it.",
	level_range = {35, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	autolevel = "caster",
	max_life = resolvers.rngavg(220,250),
	combat_armor = 1, combat_def = 10,
	combat = { dam=20, atk=30, apr=40, dammod={wil=1}, damtype=DamageType.LIGHT},
	ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=1, },

	resists = {all = 40, [DamageType.DARKNESS] = -50, [DamageType.LIGHT] = 100, [DamageType.FIRE] = 100},

	blind_immune = 1,
	see_invisible = 20,

	resolvers.talents{
		[Talents.T_CHANT_OF_FORTITUDE]=10,
		[Talents.T_CIRCLE_OF_BLAZING_LIGHT]=10,
		[Talents.T_SEARING_LIGHT]=10,
		[Talents.T_FIREBEAM]=10,
		[Talents.T_SUNBURST]=10,
		[Talents.T_SUN_FLARE]=10,
		[Talents.T_PROVIDENCE]=10,
		[Talents.T_HEALING_LIGHT]=10,
		[Talents.T_BARRIER]=10,
	},

	resolvers.sustains_at_birth(),

	make_escort = {
		{type="horror", subtype="eldritch", name="luminous horror", number=1, no_subescort=true},
	},
}
------------------------------------------------------------------------
-- Uniques
------------------------------------------------------------------------

newEntity{ base="BASE_NPC_HORROR",
	name = "Grgglck the Devouring Darkness", unique = true,
	color = colors.DARK_GREY,
	rarity = 50,
	desc = [[A horror from the deepest pits of the earth. It looks like a huge pile of tentacles all trying to reach for you.
You can discern a huge round mouth covered in razor-sharp teeth.]],
	level_range = {20, nil}, exp_worth = 2,
	max_life = 300, life_rating = 25, fixed_rating = true,
	equilibrium_regen = -20,
	negative_regen = 20,
	rank = 3.5,
	no_breath = 1,
	size_category = 4,
	movement_speed = 1.2,

	stun_immune = 1,
	knockback_immune = 1,

	combat = { dam=resolvers.mbonus(100, 15), atk=500, apr=0, dammod={str=1.2} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		  resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	resists = { all=500 },

	resolvers.talents{
		[Talents.T_STARFALL]=4,
		[Talents.T_MOONLIGHT_RAY]=4,
		[Talents.T_PACIFICATION_HEX]=4,
		[Talents.T_BURNING_HEX]=4,
		[Talents.T_INVOKE_TENTACLE]=1,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },
}

newEntity{ base="BASE_NPC_HORROR", define_as = "GRGGLCK_TENTACLE",
	name = "Grgglck's Tentacle",
	color = colors.GREY,
	desc = [[This is one of Grgglck's tentacles. It looks more vulnerable than the main body.]],
	level_range = {20, nil}, exp_worth = 0,
	max_life = 100, life_rating = 3, fixed_rating = true,
	equilibrium_regen = -20,
	rank = 3,
	no_breath = 1,
	size_category = 2,

	stun_immune = 1,
	knockback_immune = 1,
	teleport_immune = 1,

	resists = { all=50, [DamageType.DARKNESS] = 100 },

	combat = { dam=resolvers.mbonus(25, 15), atk=500, apr=500, dammod={str=1} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },

	on_act = function(self)
		if self.summoner.dead then
			self:die()
			game.logSeen(self, "#AQUAMARINE#With Grgglck's death its tentacle also falls lifeless on the ground!")
		end
	end,

	on_die = function(self, who)
		if self.summoner and not self.summoner.dead then
			game.logSeen(self, "#AQUAMARINE#As %s falls you notice that %s seems to shudder in pain!", self.name, self.summoner.name)
			self.summoner:takeHit(self.max_life, who)
		end
	end,
}
