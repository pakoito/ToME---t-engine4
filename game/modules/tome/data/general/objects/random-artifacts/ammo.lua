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
-- Ammo Properties
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="damage", points = 1, rarity = 10, level_range = {1, 50},
	combat = { dam = resolvers.randartmax(2, 20), },
}
newEntity{ theme={physical=true}, name="apr", points = 1, rarity = 10, level_range = {1, 50},
	combat = { apr = resolvers.randartmax(1, 15), },
}
newEntity{ theme={physical=true}, name="crit", points = 1, rarity = 10, level_range = {1, 50},
	combat = { physcrit = resolvers.randartmax(1, 15), },
}
newEntity{ theme={physical=true}, name="ammo reload", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { ammo_reload_speed = resolvers.randartmax(1, 4), },
}
newEntity{ theme={physical=true}, name="travel speed", points = 1, rarity = 10, level_range = {1, 50},
	combat = { travel_speed = resolvers.randartmax(1, 2), },
}
----------------------------------------------------------------
-- Melee damage projection
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical ranged", points = 1, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.PHYSICAL] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={mind=true, mental=true}, name="mind ranged", points = 1, rarity = 24, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.MIND] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={acid=true}, name="acid ranged", points = 1, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.ACID] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={lightning=true}, name="lightning ranged", points = 1, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.LIGHTNING] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={fire=true}, name="fire ranged", points = 1, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.FIRE] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={cold=true}, name="cold ranged", points = 1, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.COLD] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={light=true}, name="light ranged", points = 1, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.LIGHT] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={dark=true}, name="dark ranged", points = 1, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.DARKNESS] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={blight=true, spell=true}, name="blight ranged", points = 1, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.BLIGHT] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={nature=true}, name="nature ranged", points = 1, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.NATURE] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={arcane=true, spell=true}, name="arcane ranged", points = 2, rarity = 24, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.ARCANE] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={temporal=true}, name="temporal ranged", points = 2, rarity = 24, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.TEMPORAL] = resolvers.randartmax(4, 40), }, },
}
----------------------------------------------------------------
-- ranged damage Projection (rare)
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical gravity ranged", points = 2, rarity = 20, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.GRAVITY] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={acid=true}, name="acid blind ranged", points = 2, rarity = 20, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.ACID_BLIND] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={lightning=true}, name="lightning daze ranged", points = 2, rarity = 20, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.LIGHTNING_DAZE] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={cold=true}, name="ice ranged", points = 2, rarity = 20, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.ICE] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={antimagic=true}, name="manaburn ranged", points = 2, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.MANABURN] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={nature=true, antimagic=true}, name="slime ranged", points = 2, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.SLIME] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={nature=true}, name="insidious poison ranged", points = 2, rarity = 20, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.INSIDIOUS_POISON] = resolvers.randartmax(10, 50), }, },  -- this gets divided by 7 for damage
}
----------------------------------------------------------------
-- Melee damage burst
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.PHYSICAL] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={mind=true, mental=true}, name="mind burst", points = 2, rarity = 30, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.MIND] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={acid=true}, name="acid burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.ACID] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={lightning=true}, name="lightning burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.LIGHTNING] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={fire=true}, name="fire burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.FIRE] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={cold=true}, name="cold burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.COLD] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={light=true}, name="light burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.LIGHT] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={dark=true}, name="dark burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.DARKNESS] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={blight=true}, name="blight burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.BLIGHT] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={nature=true}, name="nature burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.NATURE] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={arcane=true}, name="arcane burst", points = 4, rarity = 30, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.ARCANE] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={temporal=true}, name="temporal burst", points = 4, rarity = 30, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.TEMPORAL] = resolvers.randartmax(4, 40), }, },
}
----------------------------------------------------------------
-- Melee damage burst(crit)
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.PHYSICAL] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={mind=true, mental=true}, name="mind burst (crit)", points = 3, rarity = 36, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.MIND] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={acid=true}, name="acid burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.ACID] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={lightning=true}, name="lightning burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.LIGHTNING] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={fire=true}, name="fire burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.FIRE] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={cold=true}, name="cold burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.COLD] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={light=true}, name="light burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.LIGHT] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={dark=true}, name="dark burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.DARKNESS] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={blight=true}, name="blight burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.BLIGHT] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={nature=true}, name="nature burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.NATURE] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={arcane=true}, name="arcane burst (crit)", points = 6, rarity = 36, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.ARCANE] = resolvers.randartmax(4, 40), }, },
}
newEntity{ theme={temporal=true}, name="temporal burst (crit)", points = 6, rarity = 36, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.TEMPORAL] = resolvers.randartmax(4, 40), }, },
}
----------------------------------------------------------------
-- Melee damage conversion
----------------------------------------------------------------
newEntity{ theme={mind=true, mental=true}, name="mind conversion", points = 1, rarity = 36, level_range = {1, 50},
	combat = { convert_damage = {[DamageType.MIND] = resolvers.randartmax(10, 50), }, },
}
newEntity{ theme={acid=true}, name="acid conversion", points = 1, rarity = 28, level_range = {1, 50},
	combat = { convert_damage = {[DamageType.ACID] = resolvers.randartmax(10, 50), }, },
}
newEntity{ theme={lightning=true}, name="lightning conversion", points = 1, rarity = 28, level_range = {1, 50},
	combat = { convert_damage = {[DamageType.LIGHTNING] = resolvers.randartmax(10, 50), }, },
}
newEntity{ theme={fire=true}, name="fire conversion", points = 1, rarity = 28, level_range = {1, 50},
	combat = { convert_damage = {[DamageType.FIRE] = resolvers.randartmax(10, 50), }, },
}
newEntity{ theme={cold=true}, name="cold conversion", points = 1, rarity = 28, level_range = {1, 50},
	combat = { convert_damage = {[DamageType.COLD] = resolvers.randartmax(10, 50), }, },
}
newEntity{ theme={light=true}, name="light conversion", points = 1, rarity = 28, level_range = {1, 50},
	combat = { convert_damage = {[DamageType.LIGHT] = resolvers.randartmax(10, 50), }, },
}
newEntity{ theme={dark=true}, name="dark conversion", points = 1, rarity = 28, level_range = {1, 50},
	combat = { convert_damage = {[DamageType.DARKNESS] = resolvers.randartmax(10, 50), }, },
}
newEntity{ theme={blight=true}, name="blight conversion", points = 1, rarity = 28, level_range = {1, 50},
	combat = { convert_damage = {[DamageType.BLIGHT] = resolvers.randartmax(10, 50), }, },
}
newEntity{ theme={nature=true}, name="nature conversion", points = 1, rarity = 28, level_range = {1, 50},
	combat = { convert_damage = {[DamageType.NATURE] = resolvers.randartmax(10, 50), }, },
}
newEntity{ theme={arcane=true}, name="arcane conversion", points = 2, rarity = 36, level_range = {1, 50},
	combat = { convert_damage = {[DamageType.ARCANE] = resolvers.randartmax(10, 50), }, },
}
newEntity{ theme={temporal=true}, name="temporal conversion", points = 2, rarity = 36, level_range = {1, 50},
	combat = { convert_damage = {[DamageType.TEMPORAL] = resolvers.randartmax(10, 50), }, },
}
----------------------------------------------------------------
-- Slaying
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="slay humanoid", points = 1, rarity = 22, level_range = {1, 50},
	combat = { inc_damage_type = {humanoid=resolvers.randartmax(5, 25),},},
}
newEntity{ theme={physical=true}, name="slay undead", points = 1, rarity = 22, level_range = {1, 50},
	combat = { inc_damage_type = {undead=resolvers.randartmax(5, 25),},},
}
newEntity{ theme={physical=true}, name="slay demon", points = 1, rarity = 22, level_range = {1, 50},
	combat = { inc_damage_type = {demon=resolvers.randartmax(5, 25),},},
}
newEntity{ theme={physical=true}, name="slay dragon", points = 1, rarity = 22, level_range = {1, 50},
	combat = { inc_damage_type = {dragon=resolvers.randartmax(5, 25),},},
}
newEntity{ theme={physical=true}, name="slay animal", points = 1, rarity = 22, level_range = {1, 50},
	combat = { inc_damage_type = {animal=resolvers.randartmax(5, 25),},},
}
newEntity{ theme={physical=true}, name="slay giant", points = 1, rarity = 22, level_range = {1, 50},
	combat = { inc_damage_type = {giant=resolvers.randartmax(5, 25),},},
}
newEntity{ theme={physical=true}, name="slay elemental", points = 1, rarity = 22, level_range = {1, 50},
	combat = { inc_damage_type = {elemental=resolvers.randartmax(5, 25),},},
}
newEntity{ theme={physical=true}, name="slay horror", points = 1, rarity = 22, level_range = {1, 50},
	combat = { inc_damage_type = {horror=resolvers.randartmax(5, 25),},},
}
newEntity{ theme={physical=true}, name="slay vermin", points = 1, rarity = 22, level_range = {1, 50},
	combat = { inc_damage_type = {vermin=resolvers.randartmax(5, 25),},},
}
newEntity{ theme={physical=true}, name="slay insect", points = 1, rarity = 22, level_range = {1, 50},
	combat = { inc_damage_type = {insect=resolvers.randartmax(5, 25),},},
}
newEntity{ theme={physical=true}, name="slay spiderkin", points = 1, rarity = 22, level_range = {1, 50},
	combat = { inc_damage_type = {spiderkin=resolvers.randartmax(5, 25),},},
}