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
-- Spell Themes
----------------------------------------------------------------
----------------------------------------------------------------
-- Spell damage
----------------------------------------------------------------
newEntity{ theme={spell=true}, name="spellpower", points = 1, rarity = 8, level_range = {1, 50},
	wielder = { combat_spellpower = resolvers.randartmax(2, 20), },
}
newEntity{ theme={spell=true}, name="spellcrit", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_spellcrit = resolvers.randartmax(1, 15), },
}
newEntity{ theme={spell=true}, name="spell crit magnitude", points = 3, rarity = 15, level_range = {1, 50},
	wielder = { combat_critical_power = resolvers.randartmax(5, 25), },
}
newEntity{ theme={spell=true}, name="spellsurge", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { spellsurge_on_crit = resolvers.randartmax(2, 10), },
}
----------------------------------------------------------------
-- Resources
----------------------------------------------------------------
newEntity{ theme={spell=true}, name="mana regeneration", points = 1, rarity = 15, level_range = {1, 50},
	wielder = { mana_regen = resolvers.randartmax(.04, .6), },
}
newEntity{ theme={spell=true}, name="increased mana", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { max_mana = resolvers.randartmax(20, 100), },
}
newEntity{ theme={spell=true}, name="mana on crit", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { mana_on_crit = resolvers.randartmax(1, 10), },
}
newEntity{ theme={spell=true}, name="increased vim", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { max_vim = resolvers.randartmax(10, 50), },
}
newEntity{ theme={spell=true}, name="vim on crit", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { vim_on_crit = resolvers.randartmax(1, 5), },
}
----------------------------------------------------------------
-- Misc
----------------------------------------------------------------
newEntity{ theme={spell=true}, name="phasing", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { damage_shield_penetrate = resolvers.randartmax(10, 50), },
}
newEntity{ theme={defense=true, spell=true}, name="void resist", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resist_all_on_teleport = resolvers.randartmax(2, 20), },
}
newEntity{ theme={defense=true, spell=true}, name="void defense", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { defense_on_teleport = resolvers.randartmax(5, 25), },
}
newEntity{ theme={defense=true, spell=true}, name="void effect reduction", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { effect_reduction_on_teleport = resolvers.randartmax(10, 40), },
}

----------------------------------------------------------------
-- Mental Themes
----------------------------------------------------------------
----------------------------------------------------------------
-- Mental Damage
----------------------------------------------------------------
newEntity{ theme={mental=true}, name="mindpower", points = 1, rarity = 8, level_range = {1, 50},
	wielder = { combat_mindpower = resolvers.randartmax(2, 20), },
}
newEntity{ theme={mental=true}, name="mindcrit", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_mindcrit = resolvers.randartmax(1, 15), },
}
newEntity{ theme={mental=true}, name="mind crit magnitude", points = 3, rarity = 15, level_range = {1, 50},
	wielder = { combat_critical_power = resolvers.randartmax(5, 25), },
}
----------------------------------------------------------------
-- Resources
----------------------------------------------------------------
newEntity{ theme={mental=true}, name="equilibrium on hit", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { equilibrium_regen_when_hit = resolvers.randartmax(.04, 2), },
}
newEntity{ theme={mental=true}, name="max hate", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { max_hate = resolvers.randartmax(2, 10), },
}
newEntity{ theme={mental=true}, name="hate per kill", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { hate_per_kill = resolvers.randartmax(1, 5), },
}
newEntity{ theme={mental=true}, name="hate on crit", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { hate_on_crit = resolvers.randartmax(1, 5), },
}
newEntity{ theme={mental=true}, name="max psi", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { max_psi = resolvers.randartmax(10, 50), },
}
newEntity{ theme={mental=true}, name="psi per kill", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { psi_per_kill = resolvers.randartmax(1, 5), },
}
newEntity{ theme={mental=true}, name="psi on hit", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { psi_regen_when_hit = resolvers.randartmax(.04, 2), },
}
newEntity{ theme={mental=true}, name="psi on crit", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { psi_on_crit = resolvers.randartmax(1, 5), },
}
newEntity{ theme={mental=true}, name="psi regen", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { psi_regen = resolvers.randartmax(.1, 1), },
}
----------------------------------------------------------------
-- Misc
----------------------------------------------------------------
newEntity{ theme={mental=true}, name="summon regen", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { nature_summon_regen = resolvers.randartmax(1, 5), },
}
newEntity{ theme={mental=true}, name="summon heal", points = 1, rarity = 16, level_range = {1, 50},
	wielder = { heal_on_nature_summon  = resolvers.randartmax(10, 50), },
}

----------------------------------------------------------------
-- Physical Themes
----------------------------------------------------------------
----------------------------------------------------------------
-- Physical Damage
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="phys dam", points = 1, rarity = 8, level_range = {1, 50},
	wielder = { combat_dam = resolvers.randartmax(2, 20), },
}
newEntity{ theme={physical=true}, name="phys apr", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_apr = resolvers.randartmax(1, 15), },
}
newEntity{ theme={physical=true}, name="phys crit", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_physcrit = resolvers.randartmax(1, 15), },
}
newEntity{ theme={physical=true}, name="phys atk", points = 1, rarity = 10, level_range = {1, 50},
	wielder = { combat_atk = resolvers.randartmax(2, 20), },
}
newEntity{ theme={physical=true}, name="phys crit magnitude", points = 3, rarity = 15, level_range = {1, 50},
	wielder = { combat_critical_power = resolvers.randartmax(5, 25),   },
}
----------------------------------------------------------------
-- Resources
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="stamina regeneration", points = 1, rarity = 15, level_range = {1, 50},
	wielder = { stamina_regen = resolvers.randartmax(.2, 3), },
}
newEntity{ theme={physical=true}, name="increased stamina", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { max_stamina = resolvers.randartmax(5, 75), },
}
newEntity{ theme={physical=true}, name="life regeneration", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { life_regen = resolvers.randartmax(.2, 3), },
}
newEntity{ theme={physical=true}, name="increased life", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { max_life = resolvers.randartmax(10, 150), },
}
newEntity{ theme={physical=true}, name="improve heal", points = 1, rarity = 15, level_range = {1, 50},
	wielder = { healing_factor = resolvers.randartmax(0.05, .5), },
}
----------------------------------------------------------------
-- Misc
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="decreased fatigue", points = 1, rarity = 15, level_range = {1, 50},
	wielder = { fatigue = -2 },
}
newEntity{ theme={physical=true}, name="greater max encumbrance", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { max_encumber = resolvers.randartmax(10, 100), },
}

----------------------------------------------------------------
-- Defense Themes
----------------------------------------------------------------
----------------------------------------------------------------
-- Defense
----------------------------------------------------------------
newEntity{ theme={defense=true}, name="def", points = 2, rarity = 8, level_range = {1, 50},
	wielder = { combat_def = resolvers.randartmax(2, 20), },
}
newEntity{ theme={defense=true}, name="rdef", points = 1.5, rarity = 12, level_range = {1, 50},
	wielder = { combat_def_ranged = resolvers.randartmax(2, 20), },
}
newEntity{ theme={defense=true}, name="armor", points = 2, rarity = 8, level_range = {1, 50},
	wielder = { combat_armor = resolvers.randartmax(2, 20), },
}
----------------------------------------------------------------
-- Saves
----------------------------------------------------------------
newEntity{ theme={defense=true, physical=true}, name="save physical", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { combat_physresist = resolvers.randartmax(3, 18), },
}
newEntity{ theme={defense=true, spell=true, antimagic=true}, name="save spell", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { combat_spellresist = resolvers.randartmax(3, 18), },
}
newEntity{ theme={defense=true, mental=true}, name="save mental", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { combat_mentalresist = resolvers.randartmax(3, 18), },
}
--------------------------------------------------------------
-- Immunities
--------------------------------------------------------------
newEntity{ theme={defense=true}, name="immune stun", points = 1, rarity = 7, level_range = {1, 50},
	wielder = { stun_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={defense=true}, name="immune knockback", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { knockback_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={defense=true}, name="immune blind", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { blind_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={defense=true}, name="immune confusion", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { confusion_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={defense=true}, name="immune pin", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { pin_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={defense=true}, name="immune poison", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { poison_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={defense=true}, name="immune disease", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { disease_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={defense=true}, name="immune silence", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { silence_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={defense=true}, name="immune disarm", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { disarm_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={defense=true}, name="immune cut", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { cut_immune = resolvers.randartmax(0.05, 0.5), },
}
newEntity{ theme={defense=true}, name="immune teleport", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { teleport_immune = resolvers.randartmax(0.05, 0.5), },
}
--------------------------------------------------------------
-- Resist %
--------------------------------------------------------------
newEntity{ theme={defense=true, physical=true}, name="resist physical", points = 2, rarity = 15, level_range = {1, 50},
	wielder = { resists = { [DamageType.PHYSICAL] = resolvers.randartmax(1, 15), }, },
}
newEntity{ theme={defense=true, mind=true}, name="resist mind", points = 2, rarity = 15, level_range = {1, 50},
	wielder = { resists = { [DamageType.MIND] = resolvers.randartmax(3, 15), }, },
}
newEntity{ theme={defense=true, antimagic=true, fire=true}, name="resist fire", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.FIRE] = resolvers.randartmax(3, 30), }, },
}
newEntity{ theme={defense=true, antimagic=true, cold=true}, name="resist cold", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.COLD] = resolvers.randartmax(3, 30), }, },
}
newEntity{ theme={defense=true, antimagic=true, acid=true}, name="resist acid", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.ACID] = resolvers.randartmax(3, 30), }, },
}
newEntity{ theme={defense=true, antimagic=true, lightning=true}, name="resist lightning", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.LIGHTNING] = resolvers.randartmax(3, 30), }, },
}
newEntity{ theme={defense=true, antimagic=true, arcane=true}, name="resist arcane", points = 5, rarity = 15, level_range = {1, 50},
	wielder = { resists = { [DamageType.ARCANE] = resolvers.randartmax(5, 5), }, },
}
newEntity{ theme={defense=true, antimagic=true, nature=true}, name="resist nature", points = 2, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.NATURE] = resolvers.randartmax(3, 20), }, },
}
newEntity{ theme={defense=true, antimagic=true, blight=true}, name="resist blight", points = 2, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.BLIGHT] = resolvers.randartmax(3, 20), }, },
}
newEntity{ theme={defense=true, antimagic=true, light=true}, name="resist light", points = 2, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.LIGHT] = resolvers.randartmax(3, 20), }, },
}
newEntity{ theme={defense=true, antimagic=true, dark=true}, name="resist darkness", points = 2, rarity = 11, level_range = {1, 50},
	wielder = { resists = { [DamageType.DARKNESS] = resolvers.randartmax(3, 20), }, },
}
newEntity{ theme={defense=true, antimagic=true, temporal=true}, name="resist temporal", points = 2, rarity = 15, level_range = {1, 50},
	wielder = { resists = { [DamageType.TEMPORAL] = resolvers.randartmax(3, 15), }, },
}

----------------------------------------------------------------
--- Elemental Themes ---
----------------------------------------------------------------
----------------------------------------------------------------
-- Elemental Projection
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { ranged_project = {[DamageType.PHYSICAL] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={mind=true, mental=true}, name="mind melee", points = 1, rarity = 24, level_range = {1, 50},
	wielder = { ranged_project = {[DamageType.MIND] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={acid=true}, name="acid melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { ranged_project = {[DamageType.ACID] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={lightning=true}, name="lightning melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { ranged_project = {[DamageType.LIGHTNING] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={fire=true}, name="fire melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { ranged_project = {[DamageType.FIRE] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={cold=true}, name="cold melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { ranged_project = {[DamageType.COLD] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={light=true}, name="light melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { ranged_project = {[DamageType.LIGHT] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={dark=true}, name="dark melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { ranged_project = {[DamageType.DARKNESS] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={blight=true, spell=true}, name="blight melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { ranged_project = {[DamageType.BLIGHT] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={nature=true}, name="nature melee", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { ranged_project = {[DamageType.NATURE] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={arcane=true, spell=true}, name="arcane melee", points = 2, rarity = 24, level_range = {1, 50},
	wielder = { ranged_project = {[DamageType.ARCANE] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={temporal=true}, name="temporal melee", points = 2, rarity = 24, level_range = {1, 50},
	wielder = { ranged_project = {[DamageType.TEMPORAL] = resolvers.randartmax(2, 20), }, },
}
----------------------------------------------------------------
-- ranged damage Projection (rare)
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical gravity ranged", points = 2, rarity = 20, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.GRAVITY] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={acid=true}, name="acid blind ranged", points = 2, rarity = 20, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.ACID_BLIND] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={lightning=true}, name="lightning daze ranged", points = 2, rarity = 20, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.LIGHTNING_DAZE] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={cold=true}, name="ice ranged", points = 2, rarity = 20, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.ICE] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={antimagic=true}, name="manaburn ranged", points = 2, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.MANABURN] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={nature=true, antimagic=true}, name="slime ranged", points = 2, rarity = 18, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.SLIME] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={nature=true}, name="insidious poison ranged", points = 2, rarity = 20, level_range = {1, 50},
	combat = { ranged_project = {[DamageType.INSIDIOUS_POISON] = resolvers.randartmax(5, 25), }, },  -- this gets divided by 7 for damage
}
----------------------------------------------------------------
-- damage burst
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.PHYSICAL] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={mind=true, mental=true}, name="mind burst", points = 2, rarity = 30, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.MIND] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={acid=true}, name="acid burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.ACID] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={lightning=true}, name="lightning burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.LIGHTNING] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={fire=true}, name="fire burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.FIRE] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={cold=true}, name="cold burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.COLD] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={light=true}, name="light burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.LIGHT] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={dark=true}, name="dark burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.DARKNESS] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={blight=true}, name="blight burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.BLIGHT] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={nature=true}, name="nature burst", points = 2, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.NATURE] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={arcane=true}, name="arcane burst", points = 4, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.ARCANE] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={temporal=true}, name="temporal burst", points = 4, rarity = 24, level_range = {1, 50},
	combat = { burst_on_hit = {[DamageType.TEMPORAL] = resolvers.randartmax(2, 20), }, },
}
----------------------------------------------------------------
-- damage burst(crit)
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.PHYSICAL] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={mind=true, mental=true}, name="mind burst (crit)", points = 3, rarity = 36, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.MIND] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={acid=true}, name="acid burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.ACID] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={lightning=true}, name="lightning burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.LIGHTNING] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={fire=true}, name="fire burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.FIRE] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={cold=true}, name="cold burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.COLD] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={light=true}, name="light burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.LIGHT] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={dark=true}, name="dark burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.DARKNESS] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={blight=true}, name="blight burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.BLIGHT] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={nature=true}, name="nature burst (crit)", points = 3, rarity = 28, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.NATURE] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={arcane=true}, name="arcane burst (crit)", points = 6, rarity = 36, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.ARCANE] = resolvers.randartmax(2, 20), }, },
}
newEntity{ theme={temporal=true}, name="temporal burst (crit)", points = 6, rarity = 36, level_range = {1, 50},
	combat = { burst_on_crit = {[DamageType.TEMPORAL] = resolvers.randartmax(2, 20), }, },
}
----------------------------------------------------------------
-- damage conversion
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
-- Elemental Retribution
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="physical retribution", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { on_melee_hit = {[DamageType.PHYSICAL] = resolvers.randartmax(4, 20), }, },
}
newEntity{ theme={mind=true, mental=true}, name="mind retribution", points = 1, rarity = 24, level_range = {1, 50},
	wielder = { on_melee_hit = {[DamageType.MIND] = resolvers.randartmax(4, 20), }, },
}
newEntity{ theme={acid=true}, name="acid retribution", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { on_melee_hit = {[DamageType.ACID] = resolvers.randartmax(4, 20), }, },
}
newEntity{ theme={lightning=true}, name="lightning retribution", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { on_melee_hit = {[DamageType.LIGHTNING] = resolvers.randartmax(4, 20), }, },
}
newEntity{ theme={fire=true}, name="fire retribution", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { on_melee_hit = {[DamageType.FIRE] = resolvers.randartmax(4, 20), }, },
}
newEntity{ theme={cold=true}, name="cold retribution", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { on_melee_hit = {[DamageType.COLD] = resolvers.randartmax(4, 20), }, },
}
newEntity{ theme={light=true}, name="light retribution", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { on_melee_hit = {[DamageType.LIGHT] = resolvers.randartmax(4, 20), }, },
}
newEntity{ theme={dark=true}, name="dark retribution", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { on_melee_hit = {[DamageType.DARKNESS] = resolvers.randartmax(4, 20), }, },
}
newEntity{ theme={blight=true, spell=true}, name="blight retribution", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { on_melee_hit = {[DamageType.BLIGHT] = resolvers.randartmax(4, 20), }, },
}
newEntity{ theme={nature=true}, name="nature retribution", points = 1, rarity = 18, level_range = {1, 50},
	wielder = { on_melee_hit = {[DamageType.NATURE] = resolvers.randartmax(4, 20), }, },
}
newEntity{ theme={arcane=true, spell=true}, name="arcane retribution", points = 2, rarity = 24, level_range = {1, 50},
	wielder = { on_melee_hit = {[DamageType.ARCANE] = resolvers.randartmax(4, 20), }, },
}
newEntity{ theme={temporal=true}, name="temporal retribution", points = 2, rarity = 24, level_range = {1, 50},
	wielder = { on_melee_hit = {[DamageType.TEMPORAL] = resolvers.randartmax(4, 20), }, },
}

----------------------------------------------------------------
-- Damage %
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="inc damage physical", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.PHYSICAL] = resolvers.randartmax(3, 30), }, },
}
newEntity{ theme={mind=true, mental=true}, name="inc damage mind", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.MIND] = resolvers.randartmax(3, 30),  }, },
}
newEntity{ theme={fire=true}, name="inc damage fire", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.FIRE] = resolvers.randartmax(3, 30),  }, },
}
newEntity{ theme={cold=true}, name="inc damage cold", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.COLD] = resolvers.randartmax(3, 30),  }, },
}
newEntity{ theme={acid=true}, name="inc damage acid", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.ACID] = resolvers.randartmax(3, 30),  }, },
}
newEntity{ theme={lightning=true}, name="inc damage lightning", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.LIGHTNING] = resolvers.randartmax(3, 30),  }, },
}
newEntity{ theme={arcane=true, spell=true}, name="inc damage arcane", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.ARCANE] = resolvers.randartmax(3, 30),  }, },
}
newEntity{ theme={nature=true}, name="inc damage nature", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.NATURE] = resolvers.randartmax(3, 30),  }, },
}
newEntity{ theme={blight=true, spell=true}, name="inc damage blight", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.BLIGHT] = resolvers.randartmax(3, 30),  }, },
}
newEntity{ theme={light=true}, name="inc damage light", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.LIGHT] = resolvers.randartmax(3, 30),  }, },
}
newEntity{ theme={dark=true}, name="inc damage darkness", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.DARKNESS] = resolvers.randartmax(3, 30),  }, },
}
newEntity{ theme={temporal=true}, name="inc damage temporal", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { inc_damage = { [DamageType.TEMPORAL] = resolvers.randartmax(3, 30),  }, },
}

----------------------------------------------------------------
-- Resist Penetration %
----------------------------------------------------------------
newEntity{ theme={physical=true}, name="resists pen physical", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resists_pen = { [DamageType.PHYSICAL] = resolvers.randartmax(5, 25), }, },
}
newEntity{ theme={mind=true, mental=true}, name="resists pen mind", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resists_pen = { [DamageType.MIND] = resolvers.randartmax(5, 25),  }, },
}
newEntity{ theme={fire=true}, name="resists pen fire", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resists_pen = { [DamageType.FIRE] = resolvers.randartmax(5, 25),  }, },
}
newEntity{ theme={cold=true}, name="resists pen cold", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resists_pen = { [DamageType.COLD] = resolvers.randartmax(5, 25),  }, },
}
newEntity{ theme={acid=true}, name="resists pen acid", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resists_pen = { [DamageType.ACID] = resolvers.randartmax(5, 25),  }, },
}
newEntity{ theme={lightning=true}, name="resists pen lightning", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resists_pen = { [DamageType.LIGHTNING] = resolvers.randartmax(5, 25),  }, },
}
newEntity{ theme={arcane=true, spell=true}, name="resists pen arcane", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resists_pen = { [DamageType.ARCANE] = resolvers.randartmax(5, 25),  }, },
}
newEntity{ theme={nature=true}, name="resists pen nature", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resists_pen = { [DamageType.NATURE] = resolvers.randartmax(5, 25),  }, },
}
newEntity{ theme={blight=true, spell=true}, name="resists pen blight", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resists_pen = { [DamageType.BLIGHT] = resolvers.randartmax(5, 25),  }, },
}
newEntity{ theme={light=true}, name="resists pen light", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resists_pen = { [DamageType.LIGHT] = resolvers.randartmax(5, 25),  }, },
}
newEntity{ theme={dark=true}, name="resists pen darkness", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resists_pen = { [DamageType.DARKNESS] = resolvers.randartmax(5, 25),  }, },
}
newEntity{ theme={temporal=true}, name="resists pen temporal", points = 2, rarity = 16, level_range = {1, 50},
	wielder = { resists_pen = { [DamageType.TEMPORAL] = resolvers.randartmax(5, 25),  }, },
}

----------------------------------------------------------------
--- Misc Themes ---
----------------------------------------------------------------
----------------------------------------------------------------
-- Stats
----------------------------------------------------------------
newEntity{ theme={misc=true, physical=true}, name="stat str", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_STR] = resolvers.randartmax(1, 10), }, },
}
newEntity{ theme={misc=true, physical=true}, name="stat dex", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_DEX] = resolvers.randartmax(1, 10), }, },
}
newEntity{ theme={misc=true, spell=true}, name="stat mag", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_MAG] = resolvers.randartmax(1, 10), }, },
}
newEntity{ theme={misc=true, spell=true, mental=true}, name="stat wil", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_WIL] = resolvers.randartmax(1, 10), }, },
}
newEntity{ theme={misc=true, mental=true}, name="stat cun", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_CUN] = resolvers.randartmax(1, 10), }, },
}
newEntity{ theme={misc=true, physical=true}, name="stat con", points = 2, rarity = 7, level_range = {1, 50},
	wielder = { inc_stats = { [Stats.STAT_CON] = resolvers.randartmax(1, 10), }, },
}
----------------------------------------------------------------
-- Other
----------------------------------------------------------------
newEntity{ theme={misc=true, darkness=true}, name="see invisible", points = 1, rarity = 11, level_range = {1, 50},
	wielder = { see_invisible = resolvers.randartmax(3, 24), },
}
newEntity{ theme={misc=true, darkness=true}, name="infravision radius", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { infravision = resolvers.randartmax(1, 3), },
}
newEntity{ theme={misc=true, light=true}, name="lite radius", points = 1, rarity = 14, level_range = {1, 50},
	wielder = { lite = resolvers.randartmax(1, 3), },
}
newEntity{ theme={misc=true}, name="water breathing", points = 10, rarity = 15, level_range = {1, 50},
	wielder = { can_breath = {water=1}, },
}
newEntity{ theme={misc=true, mental=true}, name="telepathy", points = 60, rarity = 100, level_range = {1, 50},
	wielder = { esp_all = 1 },
}
newEntity{ theme={misc=true, mental=true}, name="orc telepathy", points = 15, rarity = 50, level_range = {1, 50},
	wielder = { esp = {["humanoid/orc"]=1}, },
}
newEntity{ theme={misc=true, mental=true}, name="dragon telepathy", points = 8, rarity = 40, level_range = {1, 50},
	wielder = { esp = {dragon=1}, },
}
newEntity{ theme={misc=true, mental=true}, name="demon telepathy", points = 8, rarity = 40, level_range = {1, 50},
	wielder = { esp = {["demon/minor"]=1, ["demon/major"]=1}, },
}
newEntity{ theme={misc=true}, name="no teleport", points = 1, rarity = 17, level_range = {1, 50},
	copy = { no_teleport = 1, },
}