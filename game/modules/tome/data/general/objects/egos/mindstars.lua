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
local Talents = require "engine.interface.ActorTalents"

------------------------------------------------
-- Mindstar Sets -------------------------------
------------------------------------------------
-- Wild Cards: Capable of completing other sets
newEntity{
	power_source = {nature=true},
	name = "harmonious ", prefix=true, instant_resolve=true,
	keywords = {harmonious=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		equilibrium_regen_on_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
		talents_types_mastery = {
			["wild-gift/harmony"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
	},
	max_power = 20, power_regen = 1,
	use_power = { name = "completes a nature powered mindstar set", power = 1,	
		use = function(self, who, ms_inven)
			who:showEquipInven("Harmonize with which mindstar?", function(o) return o.subtype == "mindstar" and o.set_list and o ~= self  and o.power_source and o.power_source.nature end, function(o) 
				-- define the mindstar so it matches the set list of the target mindstar
				self.define_as = o.set_list[1][2]
				-- then set the mindstar's set list as the definition of the target mindstar
				self.set_list = { {"define_as", o.define_as} }
				-- and copies the target mindstar's on set complete
				self.on_set_complete = o.on_set_complete
				-- remove the mindstar and rewear it to trigger set bonuses
				local obj = who:takeoffObject(ms_inven, 1)
				who:wearObject(obj, true)
				return true
			end)
			return {id=true, used=true}
		end
	},
}

 newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_PSIONIC", -- Can complete any psionic MS set
	name = "resonating ", prefix=true, instant_resolve=true,
	keywords = {resonating=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		damage_resonance = resolvers.mbonus_material(20, 5),
		psi_regen_on_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
	},
	max_power = 20, power_regen = 1,
	use_power = { name = "completes a nature powered mindstar set", power = 1,	
		use = function(self, who, ms_inven)
			who:showEquipInven("Resonate with which mindstar?", function(o) return o.subtype == "mindstar" and o.set_list and o ~= self  and o.power_source and o.power_source.psionic end, function(o) 
				-- define the mindstar so it matches the set list of the target mindstar
				self.define_as = o.set_list[1][2]
				-- then set the mindstar's set list as the definition of the target mindstar
				self.set_list = { {"define_as", o.define_as} }
				-- and copies the target mindstar's on set complete
				self.on_set_complete = o.on_set_complete
				-- remove the mindstar and rewear it to trigger set bonuses
				local obj = who:takeoffObject(ms_inven, 1)
				who:wearObject(obj, true)
				return true
			end)
			return {id=true, used=true}
		end
	},
}

-- Caller's Set: For summoners!
 newEntity{
	power_source = {nature=true},  define_as = "MS_EGO_SET_CALLERS",
	name = "caller's ", prefix=true, instant_resolve=true,
	keywords = {callers=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		inc_damage = { 
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
	},
	set_list = { {"define_as", "MS_EGO_SET_SUMMONERS"} },
	on_set_complete = function(self, who)
		game.logPlayer(who, "#GREEN#Your mindstars resonate with Nature's purity.")
		self:specialSetAdd({"wielder","nature_summon_regen"}, self.material_level)
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#The link between the mindstars is broken.")
	end
}

 newEntity{
	power_source = {nature=true}, define_as = "MS_EGO_SET_SUMMONERS",
	name = "summoner's ", prefix=true, instant_resolve=true,
	keywords = {summoners=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 2),
		combat_mindcrit = resolvers.mbonus_material(5, 1),
	},
	set_list = { {"define_as", "MS_EGO_SET_CALLERS"} },
	on_set_complete = function(self, who)
		game.logPlayer(who, "#GREEN#Your mindstars resonate with Nature's purity.")
		self:specialSetAdd({"wielder","nature_summon_max"}, 1)
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#The link between the mindstars is broken.")
	end
}

-- Mentalist Set: For a yet to be written psi class and/or Mindslayers
 newEntity{
	power_source = {psionic=true},  define_as = "MS_EGO_SET_DREAMERS",
	name = "dreamer's ", prefix=true, instant_resolve=true,
	keywords = {dreamers=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(8, 2),
		max_psi = resolvers.mbonus_material(50, 10),
		resists = { [DamageType.MIND] = resolvers.mbonus_material(20, 5), }
	},
	set_list = { {"define_as", "MS_EGO_SET_EPIPHANOUS"} },
	on_set_complete = function(self, who)
		game.logPlayer(who, "#YELLOW#Your mindstars resonate with psionic energy.")
		self:specialSetAdd({"wielder","psi_regen"}, self.material_level / 10)
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#The link between the mindstars is broken.")
	end
}

 newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_EPIPHANOUS",
	name = "epiphanous ", prefix=true, instant_resolve=true,
	keywords = {epiphanous=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(5, 1),
		combat_mindcrit = resolvers.mbonus_material(5, 1),
		inc_damage = { [DamageType.MIND] = resolvers.mbonus_material(20, 5), },
	},
	set_list = { {"define_as", "MS_EGO_SET_DREAMERS"} },
	on_set_complete = function(self, who)
		game.logPlayer(who, "#YELLOW#Your mindstars resonate with psionic energy.")
		self:specialSetAdd({"wielder","psi_on_crit"}, self.material_level)
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#The link between the mindstars is broken.")
	end
}

-- Mitotic Set: Single Mindstar that splits in two
 newEntity{
	power_source = {nature=true},
	name = "mitotic ", prefix=true, instant_resolve=true,
	keywords = {mitotic=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 10,  -- cost is very low to discourage players from splitting them to make extra gold..  because that would be tedious and unfun
	combat = {
		physcrit = resolvers.mbonus_material(10, 2),
		melee_project = { [DamageType.ACID_BLIND]= resolvers.mbonus_material(15, 5), [DamageType.SLIME]= resolvers.mbonus_material(15, 5),},
	},
	max_power = 1, power_regen = 1,
	use_power = { name = "divide the mindstar in two", power = 1,
		use = function(self, who)
			-- Check for free slot first
			if who:getFreeHands() == 0 then
				game.logPlayer(who, "You must have a free hand to divide %s", self.name)
			return 
			end

			if who:getInven("PSIONIC_FOCUS")[1] == self then
				game.logPlayer(who, "You cannot split %s while using it as a psionic focus.", self.name)
				return
			end
			
			local weapon = who:getInven("MAINHAND") or who:getInven("OFFHAND")
			local o = who:takeoffObject(weapon, 1)
			
			-- Remove some properties before cloning
			o.cost = self.cost / 2 -- more don't split for extra gold discouragement
			o.max_power = nil
			o.power_regen = nil
			o.use_power = nil
			local o2 = o:clone()
			
			-- Build the item set
			o.is_mitotic_acid = true
			o2.is_mitotic_slime = true
			o.set_list = { {"is_mitotic_slime", true} }
			o2.set_list = { {"is_mitotic_acid", true} }

			o.on_set_complete = function(self, who)
				self:specialWearAdd({"combat","burst_on_crit"}, { [engine.DamageType.ACID_BLIND] = 10 * o.material_level } )
				game.logPlayer(who, "#GREEN#The mindstars pulse with life.")
			end
			o.on_set_broken = function(self, who)
				game.logPlayer(who, "#SLATE#The link between the mindstars is broken.")
			end
			
			o2.on_set_complete = function(self, who)
				self:specialWearAdd({"combat","burst_on_crit"}, { [engine.DamageType.SLIME] = 10 * o.material_level } )
			end
			
			who:wearObject(o, true)
			who:wearObject(o2, true, true)
			
			-- Because we're removing the use_power we're not returning that it was used; instead we'll have the actor use energy manually
			who:useEnergy()
		end
	},
}

-- Wrathful Set: Geared towards Afflicted
newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_HATEFUL",
	name = "hateful ", prefix=true, instant_resolve=true,
	keywords = {hateful=true},
	level_range = {30, 50},
	greater_ego =1,
	rarity = 35,
	cost = 35,
	wielder = {
		inc_damage={
			[DamageType.MIND] = resolvers.mbonus_material(20, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(20, 5),
		},
		inc_damage_type = {humanoid=resolvers.mbonus_material(20, 5)},
	},
	set_list = { {"define_as", "MS_EGO_SET_WRATHFUL"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","combat_mindpower"}, 2 * self.material_level)
		game.logPlayer(who, "#GREY#You feel a swell of hatred from your mindstars.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#The mindstar resonance has faded.")
	end,
}

 newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_WRATHFUL",
	name = "wrathful ", prefix=true, instant_resolve=true,
	keywords = {wrath=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		psi_on_crit = resolvers.mbonus_material(5, 1),
		hate_on_crit = resolvers.mbonus_material(5, 1),
		combat_mindcrit = resolvers.mbonus_material(10, 2),
	},
	set_list = { {"define_as", "MS_EGO_SET_HATEFUL"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","max_hate"}, 2 * self.material_level)
		game.logPlayer(who, "#GREY#You feel a swell of hatred from your mindstars.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#The mindstar resonance has faded.")
	end,
}
-------------------------------------------------------
--Nature and Antimagic---------------------------------
-------------------------------------------------------
 newEntity{
	power_source = {nature=true},
	name = "blooming ", prefix=true, instant_resolve=true,
	keywords = {blooming=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		heal_on_nature_summon = resolvers.mbonus_material(25, 5),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

-------------------------------------------------------
--Psionic----------------------------------------------
-------------------------------------------------------

newEntity{
	power_source = {psionic=true},
	name = "gifted ", prefix=true, instant_resolve=true,
	keywords = {gifted=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 2),
	},
}

newEntity{
	power_source = {psionic=true},
	name = "horrifying ", prefix=true, instant_resolve=true,
	keywords = {horrifying=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		inc_damage={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
	},
}

 newEntity{
	power_source = {psionic=true},
	name = "hungering ", prefix=true, instant_resolve=true,
	keywords = {hungering=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		talents_types_mastery = {
			["psionic/voracity"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
			["cursed/dark-sustenance"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
		hate_on_kill = resolvers.mbonus_material(4, 1),
	},
}

 newEntity{
	power_source = {psionic=true},
	name = "wrathful ", prefix=true, instant_resolve=true,
	keywords = {wrath=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 8,
	wielder = {
		hate_on_crit = resolvers.mbonus_material(5, 1),
		combat_mindcrit = resolvers.mbonus_material(5, 1),
	},
}

--[[ Not done
newEntity{
	power_source = {psionic=true},
	name = " of clarity", suffix=true, instant_resolve=true,
	keywords = {power=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of nightmares", suffix=true, instant_resolve=true,
	keywords = {night=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {psionic=true},
 	name = " of power", suffix=true, instant_resolve=true,
 	keywords = {power=true},
 	level_range = {1, 50},
	wielder = {
 		combat_mindpower = resolvers.mbonus_material(16, 3),
 	},
 }

newEntity{
	power_source = {psionic=true},
	name = " of shrouds", suffix=true, instant_resolve=true,
	keywords = {shrouds=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {psionic=true},
	name = "spire dragon's ", prefix=true, instant_resolve=true,
	keywords = {spire=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of convergence", suffix=true, instant_resolve=true,
	keywords = {conv=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(16, 3),
	},
}]]