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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

----------------------------------------------------------------
-- Spellcasting
----------------------------------------------------------------
newEntity{ theme={spell=true}, name="spellpower", points = 1, rarity = 8, level_range = {1, 50},
	wielder = { combat_spellpower = 2, },
}
newEntity{ theme={spell=true}, name="spellcrit", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_spellcrit = 1, },
}

----------------------------------------------------------------
-- Physical damage
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="phys dam", points = 1, rarity = 8, level_range = {1, 50},
	wielder = { combat_dam = 1, },
}
newEntity{ theme={physical=true}, name="phys apr", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_apr = 1, },
}
newEntity{ theme={physical=true}, name="phys crit", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_physcrit = 1, },
}

----------------------------------------------------------------
-- Defence
----------------------------------------------------------------
newEntity{ theme={def=true}, name="def", points = 2, rarity = 8, level_range = {1, 50},
	wielder = { combat_def = 1, },
}
newEntity{ theme={def=true}, name="rdef", points = 1.5, rarity = 12, level_range = {1, 50},
	wielder = { combat_def_ranged = 1, },
}
newEntity{ theme={def=true}, name="armor", points = 2, rarity = 8, level_range = {1, 50},
	wielder = { combat_armor = 1, },
}

----------------------------------------------------------------
-- Stats
----------------------------------------------------------------
newEntity{ theme={misc=true}, name="stat str", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_STR] = 1 }, },
}
newEntity{ theme={misc=true}, name="stat dex", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_DEX] = 1 }, },
}
newEntity{ theme={misc=true}, name="stat mag", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_MAG] = 1 }, },
}
newEntity{ theme={misc=true}, name="stat wil", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_WIL] = 1 }, },
}
newEntity{ theme={misc=true}, name="stat cun", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_CUN] = 1 }, },
}
newEntity{ theme={misc=true}, name="stat con", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_CON] = 1 }, },
}

----------------------------------------------------------------
-- Damage %
----------------------------------------------------------------
newEntity{ theme={attack=true}, name="inc damage physical", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.PHYSICAL] = 1 }, },
}
newEntity{ theme={attack=true}, name="inc damage fire", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.FIRE] = 1 }, },
}
newEntity{ theme={attack=true}, name="inc damage cold", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.COLD] = 1 }, },
}
newEntity{ theme={attack=true}, name="inc damage acid", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.ACID] = 1 }, },
}
newEntity{ theme={attack=true}, name="inc damage lightning", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.LIGHTNING] = 1 }, },
}
newEntity{ theme={attack=true}, name="inc damage arcane", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.ARCANE] = 1 }, },
}
newEntity{ theme={attack=true}, name="inc damage nature", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.NATURE] = 1 }, },
}
newEntity{ theme={attack=true}, name="inc damage blight", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.BLIGHT] = 1 }, },
}
newEntity{ theme={attack=true}, name="inc damage light", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.LIGHT] = 1 }, },
}
newEntity{ theme={attack=true}, name="inc damage darkness", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.DARKNESS] = 1 }, },
}
newEntity{ theme={attack=true}, name="inc damage mind", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.MIND] = 1 }, },
}

----------------------------------------------------------------
-- Immunes
----------------------------------------------------------------
newEntity{ theme={def=true}, name="immune stun", points = 2, rarity = 14, level_range = {1, 50},
	wielder = { stun_immune = 0.05 },
}
newEntity{ theme={def=true}, name="immune knockback", points = 2, rarity = 14, level_range = {1, 50},
	wielder = { knockback_immune = 0.05 },
}
newEntity{ theme={def=true}, name="immune blind", points = 2, rarity = 14, level_range = {1, 50},
	wielder = { blind_immune = 0.05 },
}
newEntity{ theme={def=true}, name="immune confusion", points = 2, rarity = 14, level_range = {1, 50},
	wielder = { confusion_immune = 0.05 },
}
newEntity{ theme={def=true}, name="immune pin", points = 2, rarity = 14, level_range = {1, 50},
	wielder = { pin_immune = 0.05 },
}
newEntity{ theme={def=true}, name="immune poison", points = 2, rarity = 14, level_range = {1, 50},
	wielder = { poison_immune = 0.05 },
}
newEntity{ theme={def=true}, name="immune disease", points = 2, rarity = 14, level_range = {1, 50},
	wielder = { disease_immune = 0.05 },
}
newEntity{ theme={def=true}, name="immune silence", points = 2, rarity = 14, level_range = {1, 50},
	wielder = { silence_immune = 0.05 },
}
newEntity{ theme={def=true}, name="immune disarm", points = 2, rarity = 14, level_range = {1, 50},
	wielder = { disarm_immune = 0.05 },
}
newEntity{ theme={def=true}, name="immune cut", points = 2, rarity = 14, level_range = {1, 50},
	wielder = { cut_immune = 0.05 },
}

----------------------------------------------------------------
-- Resists %
----------------------------------------------------------------
newEntity{ theme={def=true}, name="resist physical", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.PHYSICAL] = 1 }, },
}
newEntity{ theme={def=true}, name="resist fire", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.FIRE] = 1 }, },
}
newEntity{ theme={def=true}, name="resist cold", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.COLD] = 1 }, },
}
newEntity{ theme={def=true}, name="resist acid", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.ACID] = 1 }, },
}
newEntity{ theme={def=true}, name="resist lightning", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.LIGHTNING] = 1 }, },
}
newEntity{ theme={def=true}, name="resist arcane", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.ARCANE] = 1 }, },
}
newEntity{ theme={def=true}, name="resist nature", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.NATURE] = 1 }, },
}
newEntity{ theme={def=true}, name="resist blight", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.BLIGHT] = 1 }, },
}
newEntity{ theme={def=true}, name="resist light", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.LIGHT] = 1 }, },
}
newEntity{ theme={def=true}, name="resist darkness", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.DARKNESS] = 1 }, },
}
newEntity{ theme={def=true}, name="resist mind", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.MIND] = 1 }, },
}

----------------------------------------------------------------
-- Saves
----------------------------------------------------------------
newEntity{ theme={def=true}, name="save physical", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { combat_physresist = 1 },
}
newEntity{ theme={def=true}, name="save spell", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { combat_spellresist = 1 },
}
newEntity{ theme={def=true}, name="save mental", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { combat_mentalresist = 1 },
}
