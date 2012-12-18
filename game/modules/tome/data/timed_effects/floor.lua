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
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

local function floorEffect(t)
	t.name = t.name or t.desc
	t.name = t.name:upper():gsub("[ ']", "_")
	local d = t.long_desc
	if type(t.long_desc) == "string" then t.long_desc = function() return d end end
	t.type = "other"
	t.subtype = { floor=true }
	t.status = "neutral"
	t.parameters = {}
	t.on_gain = function(self, err) return nil, "+"..t.desc end
	t.on_lose = function(self, err) return nil, "-"..t.desc end

	newEffect(t)
end

floorEffect{
	desc = "Icy Floor", image = "talents/ice_storm.png",
	long_desc = "The target is walking on an icy floor. Increasing movement speed by 20%, providing +20% cold damage piercing and -30% stun immunity.",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists_pen", {[DamageType.COLD] = 20})
		self:effectTemporaryValue(eff, "movement_speed", 0.2)
		self:effectTemporaryValue(eff, "stun_immune", -0.3)
	end,
}

floorEffect{
	desc = "Font of Life", image = "talents/grand_arrival.png",
	long_desc = function(self, eff) return ("The target is near a font of life, granting +%0.2f life regeneration, -%0.2f equilibrium regeneration, +%0.2f stamina regeneration and +%0.2f psi regeneration. Undeads are not affected."):format(eff.power, eff.power, eff.power, eff.power) end,
	activate = function(self, eff)
		if self:attr("undead") then eff.power = 0 return end
		eff.power = 3 + game.zone:level_adjust_level(game.level, game.zone, "object") / 2
		self:effectTemporaryValue(eff, "life_regen", eff.power)
		self:effectTemporaryValue(eff, "stamina_regen", eff.power)
		self:effectTemporaryValue(eff, "psi_regen", eff.power)
		self:effectTemporaryValue(eff, "equilibrium_regen", -eff.power)
	end,
}

floorEffect{
	desc = "Spellblaze Scar", image = "talents/blood_boil.png",
	long_desc = "The target is near a spellblaze scar, granting +25% spell critical chance, +10% fire and blight damage but critical spells will drain arcane forces.",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_spellcrit", 25)
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.FIRE]=10,[DamageType.BLIGHT]=10})
		self:effectTemporaryValue(eff, "mana_on_crit", -15)
		self:effectTemporaryValue(eff, "vim_on_crit", -10)
		self:effectTemporaryValue(eff, "paradox_on_crit", 20)
		self:effectTemporaryValue(eff, "positive_on_crit", -10)
		self:effectTemporaryValue(eff, "negative_on_crit", -10)
	end,
}

floorEffect{
	desc = "Blighted Soil", image = "talents/blightzone.png",
	long_desc = "The target is walking on blighted soil, reducing diseases resistance by 60% and giving all attacks a 40% chance to infect the target with a random disease (can only happen once per turn).",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "disease_immune", -0.6)
		self:effectTemporaryValue(eff, "blighted_soil", 40)
	end,
}

floorEffect{
	desc = "Protective Aura", image = "talents/barrier.png",
	long_desc = function(self, eff) return ("The target is near a protective aura, granting +%d armour and +%d physical save."):format(eff.power, eff.power * 3) end,
	activate = function(self, eff)
		eff.power = 3 + game.zone:level_adjust_level(game.level, game.zone, "object") / 5
		self:effectTemporaryValue(eff, "combat_armor", eff.power)
		self:effectTemporaryValue(eff, "combat_physicalresist", eff.power * 3)
	end,
}

floorEffect{
	desc = "Antimagic Bush", image = "talents/fungal_growth.png",
	long_desc = function(self, eff) return ("The target is near an antimagic bush, granting +20%% nature damage, +20%% nature resistance penetration and -%d spellpower."):format(eff.power) end,
	activate = function(self, eff)
		eff.power = 10 + game.zone:level_adjust_level(game.level, game.zone, "object") / 1.5
		self:effectTemporaryValue(eff, "combat_spellpower", -eff.power)
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.NATURE]=20})
		self:effectTemporaryValue(eff, "resists_pen", {[DamageType.NATURE]=20})
	end,
}

floorEffect{
	desc = "Necrotic Air", image = "talents/repression.png",
	long_desc = "The target is in a zone of necrotic air, granting -40% healing mod. Undead creatures also get +15% to all resistances.",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "healing_factor", -0.4)
		if self:attr("undead") then self:effectTemporaryValue(eff, "resists", {all=15}) end
	end,
}

floorEffect{
	desc = "Whistling Vortex", image = "talents/shadow_blast.png",
	long_desc = function(self, eff) return ("The target is in a whistling vortex, granting +%d ranged defense, -%d ranged accuracy and incoming projectiles are 30%% slower."):format(eff.power, eff.power) end,
	activate = function(self, eff)
		eff.power = 10 + game.zone:level_adjust_level(game.level, game.zone, "object") / 2
		self:effectTemporaryValue(eff, "combat_def_ranged", eff.power)
		self:effectTemporaryValue(eff, "combat_atk_ranged", -eff.power)
		self:effectTemporaryValue(eff, "slow_projectiles", 30)
	end,
}

floorEffect{
	desc = "Fell Aura", image = "talents/shadow_mages.png",
	long_desc = "The target is surrounded by a fell aura, granting 40% critical damage bonus but -20% to all resistances.",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_critical_power", 40)
		self:effectTemporaryValue(eff, "resists", {all=-20})
	end,
}

floorEffect{
	desc = "Slimey Pool", image = "talents/acidic_skin.png",
	long_desc = "The target is walking on slime. Decreasing movement speed by 20% and dealing 20 slime damage to any creatures attacking it.",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "on_melee_hit", {[DamageType.SLIME] = 20})
		self:effectTemporaryValue(eff, "movement_speed", -0.2)
	end,
}
