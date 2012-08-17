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

-- Archmage spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/arcane", name = "arcane", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/aether", name = "aether", description = "Tap on the core arcane forces of the aether, unleashing devastating effects on your foes." }

-- Elemental spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/fire", name = "fire", description = "Harness the power of fire to burn your foes to ashes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/wildfire", name = "wildfire", min_lev = 10, description = "Harness the power of wildfire to burn your foes to ashes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/earth", name = "earth", description = "Harness the power of the earth to protect and destroy." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/stone", name = "stone", min_lev = 10, description = "Harness the power of the stone to protect and destroy." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/water", name = "water", description = "Harness the power of water to drown your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/ice", name = "ice", min_lev = 10, description = "Harness the power of ice to freeze and shatter your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/air", name = "air", description = "Harness the power of the air to fry your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/storm", name = "storm", min_lev = 10, description = "Harness the power of the storm to incinerate your foes." }

-- Various other magic schools
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/meta", name = "meta", description = "Meta spells alter the working of magic itself." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/temporal", name = "temporal", description = "The school of time manipulation." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/phantasm", name = "phantasm", description = "Control the power of tricks and illusions." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/enhancement", name = "enhancement", description = "Magical enhancement of your body." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/conveyance", name = "conveyance", generic = true, description = "Conveyance is the school of travel. It allows you to travel faster and to track others." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/divination", name = "divination", generic = true, description = "Divination allows the caster to sense its surroundings, find hidden things." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/aegis", name = "aegis", generic = true, description = "Command the arcane forces into healing and protection." }

-- Alchemist spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/explosives", name = "explosive admixtures", description = "Manipulate gems to turn them into explosive magical bombs." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/infusion", name = "infusion", description = "Infusion your gem bombs with the powers of the elements." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/golemancy-base", name = "golemancy", hide = true, description = "Learn to craft and upgrade your golem." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/golemancy", name = "golemancy", description = "Learn to craft and upgrade your golem." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/advanced-golemancy", name = "advanced-golemancy", min_lev = 10, description = "Advanced golem operations." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/fire-alchemy", name = "fire alchemy", description = "Alchemical control over fire." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/stone-alchemy-base", name = "stone alchemy", hide = true, description = "Manipulate gems, imbue their powers into other objects." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/stone-alchemy", name = "stone alchemy", generic = true, description = "Alchemical control over stone and gems." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/staff-combat", name = "staff combat", generic = true, description = "Harness the power of magical staves." }
newTalentType{ type="golem/fighting", name = "fighting", description = "Golem melee capacity." }
newTalentType{ type="golem/arcane", no_silence=true, is_spell=true, name = "arcane", description = "Golem arcane capacity." }
newTalentType{ type="golem/golem", name = "golem", description = "Golem basic capacity." }

-- Necromancer spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/necrotic-minions", name = "necrotic minions", description = "Create and empower dumb undead minions." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/advanced-necrotic-minions", name = "advanced necrotic minions", min_lev = 10, description = "Create and empower powerful undead minions." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/nightfall", name = "nightfall", description = "Manipulate darkness itself to slaughter your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/shades", name = "shades", min_lev = 10, description = "Invoke and control shades." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/necrosis", name = "necrosis", description = "Gain control over death, eventually turning into a lich." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/grave", name = "grave", description = "Use the rotting cold doom of the tomb to fell your foes." }

-- Generic requires for spells based on talent level
spells_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
spells_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
spells_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
spells_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
spells_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
spells_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
spells_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
spells_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
spells_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
spells_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

-------------------------------------------
-- Necromancer minions
function necroGetNbSummon(self)
	local nb = 0
	if not game.party or not game.party:hasMember(self) then return 0 end
	-- Count party members
	for act, def in pairs(game.party.members) do
		if act.summoner and act.summoner == self and act.necrotic_minion then nb = nb + 1 end
	end
	return nb
end

function necroSetupSummon(self, m, x, y, level, no_control, no_decay)
	m.faction = self.faction
	m.summoner = self
	m.summoner_gain_exp = true
	m.necrotic_minion = true
	m.exp_worth = 0
	m.life_regen = 0
	m.unused_stats = 0
	m.unused_talents = 0
	m.unused_generics = 0
	m.unused_talents_types = 0
	m.silent_levelup = true
	m.no_points_on_levelup = true
	m.ai_state = m.ai_state or {}
	m.ai_state.tactic_leash = 100
	-- Try to use stored AI talents to preserve tweaking over multiple summons
	m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
	m.inc_damage = table.clone(self.inc_damage, true)
	m.no_breath = 1

	if self:knowTalent(self.T_DARK_EMPATHY) then
		local t = self:getTalentFromId(self.T_DARK_EMPATHY)
		local perc = t.getPerc(self, t)
		for k, e in pairs(self.resists) do
			m.resists[k] = (m.resists[k] or 0) + e * perc / 100
		end
		m.combat_physresist = m.combat_physresist + self:combatPhysicalResist() * perc / 100
		m.combat_spellresist = m.combat_spellresist + self:combatSpellResist() * perc / 100
		m.combat_mentalresist = m.combat_mentalresist + self:combatMentalResist() * perc / 100

		m.poison_immune = (m.poison_immune or 0) + (self:attr("poison_immune") or 0) * perc / 100
		m.disease_immune = (m.disease_immune or 0) + (self:attr("disease_immune") or 0) * perc / 100
		m.cut_immune = (m.cut_immune or 0) + (self:attr("cut_immune") or 0) * perc / 100
		m.confusion_immune = (m.confusion_immune or 0) + (self:attr("confusion_immune") or 0) * perc / 100
		m.blind_immune = (m.blind_immune or 0) + (self:attr("blind_immune") or 0) * perc / 100
		m.silence_immune = (m.silence_immune or 0) + (self:attr("silence_immune") or 0) * perc / 100
		m.disarm_immune = (m.disarm_immune or 0) + (self:attr("disarm_immune") or 0) * perc / 100
		m.pin_immune = (m.pin_immune or 0) + (self:attr("pin_immune") or 0) * perc / 100
		m.stun_immune = (m.stun_immune or 0) + (self:attr("stun_immune") or 0) * perc / 100
		m.fear_immune = (m.fear_immune or 0) + (self:attr("fear_immune") or 0) * perc / 100
		m.knockback_immune = (m.knockback_immune or 0) + (self:attr("knockback_immune") or 0) * perc / 100
		m.stone_immune = (m.stone_immune or 0) + (self:attr("stone_immune") or 0) * perc / 100
		m.teleport_immune = (m.teleport_immune or 0) + (self:attr("teleport_immune") or 0) * perc / 100
	end

	if game.party:hasMember(self) then
		local can_control = not no_control

		m.remove_from_party_on_death = true
		game.party:addMember(m, {
			control=can_control and "full" or "no",
			type="minion",
			title="Necrotic Minion",
			orders = {target=true},
		})
	end
	m:resolve() m:resolve(nil, true)
	m.max_level = self.level + (level or 0)
	m:forceLevelup(math.max(1, self.level + (level or 0)))
	game.zone:addEntity(game.level, m, "actor", x, y)
	game.level.map:particleEmitter(x, y, 1, "summon")

	-- Summons decay
	if not no_decay then
		m.on_act = function(self)
			local src = self.summoner
			local p = src:isTalentActive(src.T_NECROTIC_AURA)
			if p and self.x and self.y and not src.dead and src.x and src.y and core.fov.distance(self.x, self.y, src.x, src.y) <= self.summoner.necrotic_aura_radius then return end

			self.life = self.life - self.max_life * (p and p.necrotic_aura_decay or 10) / 100
			self.changed = true
			if self.life <= 0 then
				game.logSeen(self, "#{bold}#%s decays into a pile of ash!#{normal}#", self.name:capitalize())
				local t = src:getTalentFromId(src.T_NECROTIC_AURA)
				t.die_speach(self, t)
				self:die(self)
			end
		end
	end

	m.on_die = function(self, killer)
		local src = self.summoner
		local w = src:isTalentActive(src.T_WILL_O__THE_WISP)
		local p = src:isTalentActive(src.T_NECROTIC_AURA)
		if not w or not p or not self.x or not self.y or not src.x or not src.y or core.fov.distance(self.x, self.y, src.x, src.y) > self.summoner.necrotic_aura_radius then return end
		if not rng.percent(w.chance) then return end

		local t = src:getTalentFromId(src.T_WILL_O__THE_WISP)
		t.summon(src, t, w.dam, self, killer)
	end

	-- Summons never flee
	m.ai_tactic = m.ai_tactic or {}
	m.ai_tactic.escape = 0
end
-------------------------------------------


load("/data/talents/spells/arcane.lua")
load("/data/talents/spells/aether.lua")
load("/data/talents/spells/fire.lua")
load("/data/talents/spells/wildfire.lua")
load("/data/talents/spells/earth.lua")
load("/data/talents/spells/stone.lua")
load("/data/talents/spells/water.lua")
load("/data/talents/spells/ice.lua")
load("/data/talents/spells/air.lua")
load("/data/talents/spells/storm.lua")
load("/data/talents/spells/conveyance.lua")
load("/data/talents/spells/aegis.lua")
load("/data/talents/spells/meta.lua")
load("/data/talents/spells/divination.lua")
load("/data/talents/spells/temporal.lua")
load("/data/talents/spells/phantasm.lua")
load("/data/talents/spells/enhancement.lua")

load("/data/talents/spells/explosives.lua")
load("/data/talents/spells/infusion.lua")
load("/data/talents/spells/golemancy.lua")
load("/data/talents/spells/advanced-golemancy.lua")
load("/data/talents/spells/staff-combat.lua")
load("/data/talents/spells/fire-alchemy.lua")
load("/data/talents/spells/stone-alchemy.lua")
load("/data/talents/spells/golem.lua")

load("/data/talents/spells/necrotic-minions.lua")
load("/data/talents/spells/advanced-necrotic-minions.lua")
load("/data/talents/spells/nightfall.lua")
load("/data/talents/spells/shades.lua")
load("/data/talents/spells/necrosis.lua")
load("/data/talents/spells/grave.lua")
