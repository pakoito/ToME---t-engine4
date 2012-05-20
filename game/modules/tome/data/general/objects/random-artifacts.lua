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

----------------------------------------------------------------
-- Spellcasting
----------------------------------------------------------------
newEntity{ theme={spell=true, sorcerous=true}, name="spellpower", points = 1, rarity = 8, level_range = {1, 50},
	wielder = { combat_spellpower = resolvers.randartmax(1, 28), },
}
newEntity{ theme={spell=true, sorcerous=true}, name="spellcrit", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_spellcrit = resolvers.randartmax(1, 15), },
}
newEntity{ theme={spell=true, sorcerous=true}, name="spell crit magnitude", points = 1, rarity = 15, level_range = {1, 50},
	wielder = { combat_critical_power = resolvers.randartmax(1, 12), },
}

----------------------------------------------------------------
-- Mindpower
----------------------------------------------------------------
newEntity{ theme={mind=true, mindcraft=true}, name="mindpower", points = 1, rarity = 8, level_range = {1, 50},
	wielder = { combat_mindpower = resolvers.randartmax(1, 28), },
}
newEntity{ theme={mind=true, mindcraft=true}, name="mindcrit", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_mindcrit = resolvers.randartmax(1, 15), },
}
newEntity{ theme={mind=true, mindcraft=true}, name="mind crit magnitude", points = 1, rarity = 15, level_range = {1, 50},
	wielder = { combat_critical_power = resolvers.randartmax(1, 12), },
}

----------------------------------------------------------------
-- Physical damage
----------------------------------------------------------------
newEntity{ theme={physical=true, brawny=true}, name="phys dam", points = 1, rarity = 8, level_range = {1, 50},
	wielder = { combat_dam = resolvers.randartmax(1, 20), },
}
newEntity{ theme={physical=true, nimble=true}, name="phys apr", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_apr = resolvers.randartmax(1, 15), },
}
newEntity{ theme={physical=true, brawny=true, nimble=true}, name="phys crit", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_physcrit = resolvers.randartmax(1, 15), },
}
newEntity{ theme={physical=true, nimble=true}, name="phys atk", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_atk = resolvers.randartmax(1, 15), },
}
newEntity{ theme={physical=true, brawny=true}, name="phys crit magnitude", points = 1, rarity = 15, level_range = {1, 50},
	wielder = { combat_critical_power = resolvers.randartmax(1, 12),   },
}

----------------------------------------------------------------
-- Melee damage projection
----------------------------------------------------------------
newEntity{ theme={attack=true, venom=true}, name="acid melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { melee_project = {[DamageType.ACID] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={attack=true, lightning=true}, name="lightning melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { melee_project = {[DamageType.LIGHTNING] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={attack=true, fire=true}, name="fire melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { melee_project = {[DamageType.FIRE] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={attack=true, cold=true}, name="cold melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { melee_project = {[DamageType.COLD] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={attack=true, light=true}, name="light melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { melee_project = {[DamageType.LIGHT] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={attack=true, dark=true}, name="dark melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { melee_project = {[DamageType.DARKNESS] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={attack=true, venom=true}, name="blight melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { melee_project = {[DamageType.BLIGHT] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={attack=true, nature=true}, name="nature melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { melee_project = {[DamageType.NATURE] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={attack=true, arcane=true}, name="arcane melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { melee_project = {[DamageType.ARCANE] = resolvers.randartmax(1, 20), }, },
}
newEntity{ theme={attack=true, venom=true}, name="poison melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { melee_project = {[DamageType.POISON] = resolvers.randartmax(1, 20), }, },
}


----------------------------------------------------------------
-- Defence
----------------------------------------------------------------
newEntity{ theme={def=true}, name="def", points = 2, rarity = 8, level_range = {1, 50},
	wielder = { combat_def = resolvers.randartmax(1, 15), },
}
newEntity{ theme={def=true}, name="rdef", points = 1.5, rarity = 12, level_range = {1, 50},
	wielder = { combat_def_ranged = resolvers.randartmax(1, 15), },
}
newEntity{ theme={def=true}, name="armor", points = 2, rarity = 8, level_range = {1, 50},
	wielder = { combat_armor = resolvers.randartmax(1, 15), },
}

----------------------------------------------------------------
-- Stats
----------------------------------------------------------------
newEntity{ theme={misc=true, brawny=true}, name="stat str", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_STR] = resolvers.randartmax(1, 10), }, },
}
newEntity{ theme={misc=true, nimble=true}, name="stat dex", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_DEX] = resolvers.randartmax(1, 10), }, },
}
newEntity{ theme={misc=true, sorcerous=true}, name="stat mag", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_MAG] = resolvers.randartmax(1, 10), }, },
}
newEntity{ theme={misc=true, sorcerous=true, psionic=true}, name="stat wil", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_WIL] = resolvers.randartmax(1, 10), }, },
}
newEntity{ theme={misc=true, nimble=true, psionic=true}, name="stat cun", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_CUN] = resolvers.randartmax(1, 10), }, },
}
newEntity{ theme={misc=true, brawny=true}, name="stat con", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_CON] = resolvers.randartmax(1, 10), }, },
}

----------------------------------------------------------------
-- Damage %
----------------------------------------------------------------
newEntity{ theme={attack=true, brawny=true}, name="inc damage physical", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.PHYSICAL] = resolvers.randartmax(2, 30), }, },
}
newEntity{ theme={attack=true, fire=true}, name="inc damage fire", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.FIRE] = resolvers.randartmax(2, 30),  }, },
}
newEntity{ theme={attack=true, cold=true}, name="inc damage cold", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.COLD] = resolvers.randartmax(2, 30),  }, },
}
newEntity{ theme={attack=true, venom=true}, name="inc damage acid", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.ACID] = resolvers.randartmax(2, 30),  }, },
}
newEntity{ theme={attack=true, lightning=true}, name="inc damage lightning", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.LIGHTNING] = resolvers.randartmax(2, 30),  }, },
}
newEntity{ theme={attack=true, arcane=true, sorcerous=true}, name="inc damage arcane", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.ARCANE] = resolvers.randartmax(2, 30),  }, },
}
newEntity{ theme={attack=true, nature=true}, name="inc damage nature", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.NATURE] = resolvers.randartmax(2, 30),  }, },
}
newEntity{ theme={attack=true, venom=true}, name="inc damage blight", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.BLIGHT] = resolvers.randartmax(2, 30),  }, },
}
newEntity{ theme={attack=true, light=true}, name="inc damage light", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.LIGHT] = resolvers.randartmax(2, 30),  }, },
}
newEntity{ theme={attack=true, dark=true}, name="inc damage darkness", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.DARKNESS] = resolvers.randartmax(2, 30),  }, },
}
newEntity{ theme={attack=true, psionic=true}, name="inc damage mind", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.MIND] = resolvers.randartmax(2, 30),  }, },
}

----------------------------------------------------------------
-- Immunes
----------------------------------------------------------------
newEntity{ theme={def=true, unyielding=true}, name="immune stun", points = 1, rarity = 7, level_range = {1, 50},
	wielder = { stun_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={def=true, brawny=true, unyielding=true}, name="immune knockback", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { knockback_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={def=true, sorcerous=true}, name="immune blind", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { blind_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={def=true, psionic=true}, name="immune confusion", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { confusion_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={def=true, brawny=true}, name="immune pin", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { pin_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={def=true, venom=true, nature=true}, name="immune poison", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { poison_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={def=true, venom=true, nature=true}, name="immune disease", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { disease_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={def=true, sorcerous=true}, name="immune silence", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { silence_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={def=true, nimble=true, unyielding=true}, name="immune disarm", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { disarm_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={def=true, nimble=true}, name="immune cut", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { cut_immune = resolvers.randartmax(0.05, 0.5), },
}

----------------------------------------------------------------
-- Resists %
----------------------------------------------------------------
newEntity{ theme={def=true, brawny=true}, name="resist physical", points = 2, rarity = 15, level_range = {1, 50},
	wielder = { resists = { [DamageType.PHYSICAL] = resolvers.randartmax(1, 15), }, },
}
newEntity{ theme={def=true, fire=true}, name="resist fire", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.FIRE] = resolvers.randartmax(3, 30), }, },
}
newEntity{ theme={def=true, cold=true}, name="resist cold", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.COLD] = resolvers.randartmax(3, 30), }, },
}
newEntity{ theme={def=true, venom=true}, name="resist acid", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.ACID] = resolvers.randartmax(3, 30), }, },
}
newEntity{ theme={def=true, lightning=true}, name="resist lightning", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.LIGHTNING] = resolvers.randartmax(3, 30), }, },
}
newEntity{ theme={def=true, arcane=true, sorcerous=true}, name="resist arcane", points = 5, rarity = 15, level_range = {1, 50},
	wielder = { resists = { [DamageType.ARCANE] = resolvers.randartmax(5, 5), }, },
}
newEntity{ theme={def=true, nature=true}, name="resist nature", points = 2, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.NATURE] = resolvers.randartmax(3, 20), }, },
}
newEntity{ theme={def=true, venom=true}, name="resist blight", points = 2, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.BLIGHT] = resolvers.randartmax(3, 20), }, },
}
newEntity{ theme={def=true, light=true}, name="resist light", points = 2, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.LIGHT] = resolvers.randartmax(3, 20), }, },
}
newEntity{ theme={def=true, dark=true}, name="resist darkness", points = 2, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.DARKNESS] = resolvers.randartmax(3, 20), }, },
}
newEntity{ theme={def=true, psionic=true}, name="resist mind", points = 2, rarity = 15, level_range = {1, 50},
	wielder = { resists = { [DamageType.MIND] = resolvers.randartmax(3, 15), }, },
}

----------------------------------------------------------------
-- Saves
----------------------------------------------------------------
newEntity{ theme={def=true, brawny=true, nimble=true}, name="save physical", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { combat_physresist = resolvers.randartmax(3, 18), },
}
newEntity{ theme={def=true, sorcerous=true}, name="save spell", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { combat_spellresist = resolvers.randartmax(3, 18), },
}
newEntity{ theme={def=true, psionic=true}, name="save mental", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { combat_mentalresist = resolvers.randartmax(3, 18), },
}

----------------------------------------------------------------
-- Regen
----------------------------------------------------------------

newEntity{ theme={def=true, sorcerous=true}, name="mana regeneration", points = 1, rarity = 15, level_range = {1, 50},
	wielder = { mana_regen = resolvers.randartmax(.04, .6), },
}
newEntity{ theme={def=true, brawny=true, nimble=true, tireless=true}, name="stamina regeneration", points = 1, rarity = 15, level_range = {1, 50},
	wielder = { stamina_regen = resolvers.randartmax(.2, 3), },
}
newEntity{ theme={def=true, tireless=true}, name="life regeneration", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { life_regen = resolvers.randartmax(.2, 3), },
}


----------------------------------------------------------------
-- Life, resource pool increase
----------------------------------------------------------------

newEntity{ theme={def=true, sorcerous=true}, name="increased mana", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { max_mana = resolvers.randartmax(10, 150), },
}
newEntity{ theme={def=true, brawny=true, nimble=true, tireless=true}, name="increased stamina", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { max_stamina = resolvers.randartmax(5, 75), },
}
newEntity{ theme={def=true, brawny=true, tireless=true}, name="increased life", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { max_life = resolvers.randartmax(10, 150), },
}

----------------------------------------------------------------
-- Other
----------------------------------------------------------------

newEntity{ theme={def=true}, name="see invisible", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { see_invisible = resolvers.randartmax(3, 24), },
}
newEntity{ theme={tireless=true}, name="decreased fatigue", points = 1, rarity = 15, level_range = {1, 50},
	wielder = { fatigue = -2 },
}
newEntity{ theme={brawny=true, tireless=true}, name="greater max encumbrance", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { max_encumber = resolvers.randartmax(10, 100), },
}
newEntity{ theme={def=true, tireless=true}, name="improve heal", points = 1, rarity = 15, level_range = {1, 50},
	wielder = { healing_factor = resolvers.randartmax(0.05, .5), },
}
newEntity{ theme={light=true}, name="lite radius", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { lite = resolvers.randartmax(1, 3), },
}
newEntity{ theme={nature=true}, name="water breathing", points = 10, rarity = 15, level_range = {1, 50},
	wielder = { can_breath = {water=1}, },
}
newEntity{ theme={psionic=true}, name="telepathy", points = 60, rarity = 65, level_range = {1, 50},
	wielder = { esp_all = 1 },
}
newEntity{ theme={psionic=true}, name="orc telepathy", points = 15, rarity = 25, level_range = {1, 50},
	wielder = { esp = {["humanoid/orc"]=1}, },
}
newEntity{ theme={psionic=true}, name="dragon telepathy", points = 8, rarity = 20, level_range = {1, 50},
	wielder = { esp = {dragon=1}, },
}
newEntity{ theme={psionic=true}, name="demon telepathy", points = 8, rarity = 20, level_range = {1, 50},
	wielder = { esp = {["demon/minor"]=1, ["demon/major"]=1}, },
}
newEntity{ theme={unyielding=true}, name="no teleport", points = 1, rarity = 17, level_range = {1, 50},
	copy = { no_teleport = 1, },
}
