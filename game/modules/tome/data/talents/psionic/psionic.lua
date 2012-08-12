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

-- Talent trees
newTalentType{ allow_random=true, type="psionic/absorption", name = "absorption", description = "Absorb damage and gain energy." }
newTalentType{ allow_random=true, type="psionic/projection", name = "projection", description = "Project energy to damage foes." }
newTalentType{ allow_random=true, type="psionic/psi-fighting", name = "psi-fighting", description = "Wield melee weapons with mentally-manipulated forces." }
newTalentType{ allow_random=true, type="psionic/focus", name = "focus", description = "Use gems to focus your energies." }
newTalentType{ allow_random=true, type="psionic/augmented-mobility", name = "augmented mobility", min_lev = 10, description = "Use energy to move yourself and others." }
newTalentType{ allow_random=true, type="psionic/voracity", generic = true, name = "voracity", description = "Pull energy from your surroundings." }
newTalentType{ allow_random=true, type="psionic/finer-energy-manipulations", min_lev = 10, generic = true, name = "finer energy manipulations", description = "Subtle applications of the psionic arts." }
newTalentType{ allow_random=true, type="psionic/mental-discipline", generic = true, name = "mental discipline", description = "Increase mental capacity, endurance, and flexibility." }
newTalentType{ type="psionic/other", name = "other", description = "Various psionic talents." }

-- Advanced Talent Trees
newTalentType{ allow_random=true, type="psionic/grip", name = "grip", min_lev = 10, description = "Augment your telekinetic grip." }
newTalentType{ allow_random=true, type="psionic/psi-archery", name = "psi-archery", min_lev = 10, description = "Use your telekinetic powers to wield bows with deadly effectiveness." }
newTalentType{ allow_random=true, type="psionic/greater-psi-fighting", name = "greater psi-fighting", description = "Elevate psi-fighting prowess to epic levels." }
newTalentType{ allow_random=true, type="psionic/brainstorm", name = "brainstorm", description = "Focus your telekinetic powers in ways undreamed of by most mindslayers." }

-- Solipsist Talent Trees
newTalentType{ allow_random=true, type="psionic/discharge", name = "discharge", description = "Project feedback on the world around you." }
newTalentType{ allow_random=true, type="psionic/distortion", name = "distortion", description = "Distort reality with your mental energy." }
newTalentType{ allow_random=true, type="psionic/dream-forge", name = "Dream Forge", description = "Master the dream forge to create powerful armor and effects." }
newTalentType{ allow_random=true, type="psionic/dream-smith", name = "Dream Smith", description = "Call the dream-forge hammer to smite your foes." }
newTalentType{ allow_random=true, type="psionic/nightmare", name = "nightmare", description = "Manifest your enemies nightmares." }
newTalentType{ allow_random=true, type="psionic/psychic-assault", name = "Psychic Assault", description = "Directly attack your opponents minds." }
newTalentType{ allow_random=true, type="psionic/slumber", name = "slumber", description = "Force enemies into a deep sleep." }
newTalentType{ allow_random=true, type="psionic/solipsism", name = "solipsism", description = "Nothing exists outside the minds ability to perceive it." }
newTalentType{ allow_random=true, type="psionic/thought-forms", name = "Thought-Forms", description = "Manifest your thoughts as psionic summons." }

-- Generic Solipsist Trees
newTalentType{ allow_random=true, type="psionic/dreaming", generic = true, name = "dreaming", description = "Manipulate the sleep cycles of yourself and your enemies." }
newTalentType{ allow_random=true, type="psionic/mentalism", generic = true, name = "mentalism", description = "Various mind based effects." }
newTalentType{ allow_random=true, type="psionic/feedback", generic = true, name = "feedback", description = "Store feedback as you get damaged and use it to protect and heal your body." }
newTalentType{ allow_random=true, type="psionic/trance", generic = true, name = "trance", description = "Put your mind into a deep trance." }

newTalentType{ allow_random=true, type="psionic/possession", name = "possession", description = "You have learnt to shed away your body, allowing you to possess any other." }


-- Level 0 wil tree requirements:
psi_absorb = {
	stat = { wil=function(level) return 12 + (level-1) * 8 end },
	level = function(level) return 0 + 5*(level-1)  end,
}
psi_wil_req1 = {
	stat = { wil=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
psi_wil_req2 = {
	stat = { wil=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
psi_wil_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
psi_wil_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}

--Level 10 wil tree requirements:
psi_wil_high1 = {
	stat = { wil=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
psi_wil_high2 = {
	stat = { wil=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
psi_wil_high3 = {
	stat = { wil=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
psi_wil_high4 = {
	stat = { wil=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}

--Level 20 wil tree requirements:
psi_wil_20_1 = {
	stat = { wil=function(level) return 32 + (level-1) * 2 end },
	level = function(level) return 20 + (level-1)  end,
}
psi_wil_20_2 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 24 + (level-1)  end,
}
psi_wil_20_3 = {
	stat = { wil=function(level) return 42 + (level-1) * 2 end },
	level = function(level) return 28 + (level-1)  end,
}
psi_wil_20_4 = {
	stat = { wil=function(level) return 48 + (level-1) * 2 end },
	level = function(level) return 32 + (level-1)  end,
}

-- Level 0 cun tree requirements:
psi_cun_req1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
psi_cun_req2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
psi_cun_req3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
psi_cun_req4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}


-- Level 10 cun tree requirements:
psi_cun_high1 = {
	stat = { cun=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
psi_cun_high2 = {
	stat = { cun=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
psi_cun_high3 = {
	stat = { cun=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
psi_cun_high4 = {
	stat = { cun=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}


-- Useful definitions for psionic talents
function getGemLevel(self)
	local gem_level = 0
	if self:getInven("PSIONIC_FOCUS") then
		local tk_item = self:getInven("PSIONIC_FOCUS")[1]
		if tk_item and ((tk_item.type == "gem") or (tk_item.subtype == "mindstar")) then
			gem_level = tk_item.material_level or 5
		end
	end
	if self:knowTalent(self.T_GREATER_TELEKINETIC_GRASP) and gem_level > 0 then
		if self:getTalentLevelRaw(self.T_GREATER_TELEKINETIC_GRASP) >= 5 then
			gem_level = gem_level + 1
		end
	end
	return gem_level
end

-- Thought Forms really only differ in the equipment they carry, the talents they have, and stat weights
-- So these function will handle everything else
function cancelThoughtForms(self)
	local forms = {self.T_TF_DEFENDER, self.T_TF_WARRIOR, self.T_TF_BOWMAN}
	for i, t in ipairs(forms) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
	end
end

function setupThoughtForm(self, m, x, y)
	-- Set up some basic stuff
	m.display = "p"
	m.color=colors.YELLOW
	m.blood_color = colors.YELLOW
	m.type = "thought-form"
	m.subtype = "thought-form"
	m.summoner_gain_exp=true
	m.faction = self.faction
	m.no_inventory_access = true
	m.rank = 2
	m.size_category = 3
	m.infravision = 10
	m.lite = 1
	m.no_breath = 1
	m.move_others = true

	-- Less tedium
	m.life_regen = 1
	m.stamina_regen = 1

	-- Make sure we don't gain anything from leveling
	m.autolevel = "none"
	m.unused_stats = 0
	m.unused_talents = 0
	m.unused_generics = 0
	m.unused_talents_types = 0
	m.exp_worth = 0
	m.no_points_on_levelup = true
	m.silent_levelup = true
	m.level_range = {self.level, self.level}

	-- Try to use stored AI talents to preserve tweaking over multiple summons
	m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
	m.save_hotkeys = true

	-- Inheret some attributes
	if self:getTalentLevel(self.T_TF_UNITY) >=5 then
		m.inc_damage.all = (m.inc_damage.all) or 0 + (self.inc_damage.all or 0) + (self.inc_damage[engine.DamageType.MIND] or 0)
	end
	if self:getTalentLevel(self.T_TF_UNITY) >=3 then
		local save_bonus = self:combatMentalResist(fake)
		m:attr("combat_physresist", save_bonus)
		m:attr("combat_mentalresist", save_bonus)
		m:attr("combat_spellresist", save_bonus)
	end

	if game.party:hasMember(self) then
		m.remove_from_party_on_death = true
		game.party:addMember(m, {
			control="no",
			type="thought-form",
			title="thought-form",
			orders = {target=true, leash=true, anchor=true, talents=true},
		})
	end
	m:resolve() m:resolve(nil, true)
	m:forceLevelup(self.level)
	game.zone:addEntity(game.level, m, "actor", x, y)
	game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=225, rM=255, gm=225, gM=255, bm=225, bM=255, am=35, aM=90})

	-- Summons never flee
	m.ai_tactic = m.ai_tactic or {}
	m.ai_tactic.escape = 0
	if self.name == "thought-forged bowman" then
		m.ai_tactic.safe_range = 2
	end
end

load("/data/talents/psionic/absorption.lua")
load("/data/talents/psionic/finer-energy-manipulations.lua")
load("/data/talents/psionic/mental-discipline.lua")
load("/data/talents/psionic/projection.lua")
load("/data/talents/psionic/psi-fighting.lua")
load("/data/talents/psionic/voracity.lua")
load("/data/talents/psionic/augmented-mobility.lua")
load("/data/talents/psionic/focus.lua")
load("/data/talents/psionic/other.lua")

load("/data/talents/psionic/psi-archery.lua")
load("/data/talents/psionic/grip.lua")

-- Solipsist
load("/data/talents/psionic/discharge.lua")
load("/data/talents/psionic/distortion.lua")
load("/data/talents/psionic/dream-forge.lua")
load("/data/talents/psionic/dream-smith.lua")
load("/data/talents/psionic/dreaming.lua")
load("/data/talents/psionic/mentalism.lua")
load("/data/talents/psionic/feedback.lua")
load("/data/talents/psionic/nightmare.lua")
load("/data/talents/psionic/psychic-assault.lua")
load("/data/talents/psionic/slumber.lua")
load("/data/talents/psionic/solipsism.lua")
load("/data/talents/psionic/thought-forms.lua")
--load("/data/talents/psionic/trance.lua")


load("/data/talents/psionic/possession.lua")

