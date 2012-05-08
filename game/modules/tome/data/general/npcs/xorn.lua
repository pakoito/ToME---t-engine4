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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_XORN",
	type = "elemental", subtype = "xorn",
	display = "X", color=colors.UMBER,

	blood_color = colors.UMBER,
	combat = { dam=resolvers.levelup(resolvers.mbonus(46, 15), 1, 0.8), atk=15, apr=15, dammod={str=0.8} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {type="money"} },
	resolvers.drops{chance=60, nb=1, {type="money"} },
	resolvers.drops{chance=40, nb=1, {type="money"} },

	can_pass = {pass_wall=20},

	infravision = 10,
	life_rating = 12,
	max_stamina = 90,
	rank = 2,
	size_category = 4,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_target="target_player_radius", sense_radius=6, talent_in=3, },
	dont_pass_target = true,
	stats = { str=20, dex=8, mag=6, con=16 },

	resists = { [DamageType.PHYSICAL] = 20, [DamageType.FIRE] = 50, },

	no_breath = 1,
	confusion_immune = 1,
	poison_immune = 1,
	stone_immune = 1,
	ingredient_on_death = "XORN_FRAGMENT",
	not_power_source = {arcane=true},
}

newEntity{ base = "BASE_NPC_XORN",
	name = "umber hulk", color=colors.LIGHT_UMBER,
	desc = [[This bizarre creature has glaring eyes and large mandibles capable of slicing through rock.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 12, combat_def = 0,
	move_project = {[DamageType.DIG]=1},
	resolvers.talents{ [Talents.T_MIND_DISRUPTION]={base=2, every=5, max=6}, },
}

newEntity{ base = "BASE_NPC_XORN",
	name = "xorn", color=colors.UMBER,
	desc = [[A huge creature of the element Earth. Able to merge with its element, it has four huge arms protruding from its enormous torso.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(130,140),
	combat_armor = 15, combat_def = 10,
	combat = { damtype=DamageType.ACID },
	resolvers.talents{ [Talents.T_CONSTRICT]={base=4, every=7, max=8}, },
}

newEntity{ base = "BASE_NPC_XORN",
	name = "xaren", color=colors.SLATE,
	desc = [[It is a tougher relative of the Xorn. Its hide glitters with metal ores.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(130,140),
	combat_armor = 15, combat_def = 10,
	combat = { damtype=DamageType.ACID },
	resolvers.talents{ [Talents.T_CONSTRICT]={base=4, every=7, max=8}, [Talents.T_RUSH]=2, },
}

newEntity{ base = "BASE_NPC_XORN",
	name = "The Fragmented Essence of Harkor'Zun", color=colors.VIOLET, unique=true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/elemental_xorn_fragmented_harkor_zun.png", display_h=2, display_y=-1}}},
	desc = [[Fragmented essence...  maybe it'd be best if it stayed fragmented.]],
	level_range = {17, nil}, exp_worth = 0,
	rank = 3.5,
	size_category = 4,
	rarity = 50,
	max_life = 230, life_rating = 12,
	combat_armor = 15, combat_def = 10,
	combat = { damtype=DamageType.ACID },

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	stun_immune = 1,
	can_pass = {pass_wall=0}, -- We restore it after generation, to make sure it does not birth in walls

	-- Come in 5!
	on_added_to_level = function(self)
		self.add_max_life = self.max_life * 0.2
		local all = {self}
		for i = 1, 4 do
			local x, y = util.findFreeGrid(self.x, self.y, 15, true, {[engine.Map.ACTOR]=true})
			if x and y then
				local m = self:clone()
				m.on_added_to_level = nil
				m.x, m.y = nil, nil
				game.zone:addEntity(game.level, m, "actor", x, y)
				all[#all+1] = m
			end
		end
		for _, m in ipairs(all) do
			m.all_fragments = all
			m.can_pass = {pass_wall=20} -- Restore passwall
		end
	end,
	on_die = function(self, who)
		local nb_alive = 0
		-- Buff others
		for _, m in ipairs(self.all_fragments) do
			if not m.dead then
				nb_alive = nb_alive + 1
				game.logSeen(self, "#AQUAMARINE#%s absorbs the energy of the destroyed fragment!", self.name)
				m.max_life = m.max_life + m.add_max_life
				m:heal(m.add_max_life)
				m.inc_damage.all = (m.inc_damage.all or 0) + 20
			end
		end
		-- Only one left?
		if nb_alive == 1 then
			local x, y
			for _, m in ipairs(self.all_fragments) do
				if not m.dead then x, y = m.x, m.y; m:die(who) end
			end
			local m = game.zone:makeEntityByName(game.level, "actor", "FULL_HARKOR_ZUN")
			if m then
				game.zone:addEntity(game.level, m, "actor", x, y)
				game.level.map:particleEmitter(x, y, 1, "teleport")
				game.logSeen(self, "#AQUAMARINE#%s is infused with all the energies of the fragments. The real Harkor'Zun is reconstituted!", m.name)
			end
		end
	end,

	resolvers.talents{ [Talents.T_CONSTRICT]=4, [Talents.T_RUSH]=2, },
}

-- Does not appear randomly, it is summoned by killing the fragments
newEntity{ base = "BASE_NPC_XORN", define_as = "FULL_HARKOR_ZUN",
	name = "Harkor'Zun", color=colors.VIOLET, unique=true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/elemental_xorn_harkor_zun.png", display_h=2, display_y=-1}}},
	desc = [[A gigantic demon composed of elemental Earth, resembling a twisted Xaren but much, much larger.  It doesn't seem pleased with your presence.]],
	level_range = {23, nil}, exp_worth = 2,
	rank = 3.5,
	size_category = 5,
	autolevel = "warriormage",
	stats = { str=20, dex=8, mag=25, con=16 },
	max_life = 460, life_rating=24,
	mana_regen = 100,
	combat_armor = 20, combat_def = 10,
	combat = { dam=resolvers.mbonus(46, 30), atk=35, apr=18, dammod={str=1}, damtype=DamageType.ACID },

	resists = { [DamageType.PHYSICAL] = 50, [DamageType.ACID] = 50, },
	no_auto_resists = true,

	silence_immune = 1,
	stun_immune = 1,
	demon = 1,
	resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	resolvers.talents{
		[Talents.T_CONSTRICT]={base=4, every=7, max=8},
		[Talents.T_RUSH]=4,
		[Talents.T_STONE_SKIN]={base=4, every=7, max=8},
		[Talents.T_STRIKE]={base=4, every=7, max=8},
		[Talents.T_EARTHQUAKE]={base=5, every=7, max=9},
		[Talents.T_EARTHEN_MISSILES]={base=4, every=7, max=8},
		[Talents.T_CRYSTALLINE_FOCUS]={base=4, every=7, max=8},
		[Talents.T_VOLCANO]={base=2, every=7, max=4},
	},

	resolvers.inscriptions(1, {"shielding rune"}),
	resolvers.sustains_at_birth(),

	on_die = function(self)
		if profile.mod.allow_build.mage then
			game:setAllowedBuild("mage_geomancer", true)
			world:gainAchievement("GEOMANCER", game.player)
			local p = game.party:findMember{main=true}
			if p.descriptor.subclass == "Archmage" or p.descriptor.subclass == "Arcane Blade" then
				if p:knowTalentType("spell/stone") == nil then
					p:learnTalentType("spell/stone", false)
					p:setTalentTypeMastery("spell/stone", p.descriptor.subclass == "Archmage" and 1.3 or 1.1)
				end
			end
		end
	end,
}
