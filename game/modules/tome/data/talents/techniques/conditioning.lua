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

newTalent{
	name = "Vitality",
	type = {"technique/conditioning", 1},
	require = techs_con_req1,
	mode = "passive",
	points = 5,
	getWoundReduction = function(self, t) return self:getTalentLevel(t)/10 end,
	getHealMod = function(self, t) return self:combatTalentStatDamage(t, "con", 10, 50) end,
	getLifeRegen = function(self, t) return self:combatTalentStatDamage(t, "con", 2, 20) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)) end,
	do_vitality_recovery = function(self, t)
		self:setEffect(self.EFF_RECOVERY, t.getDuration(self, t), {heal_mod = t.getHealMod(self, t), regen = t.getLifeRegen(self, t)})
	end,
	info = function(self, t)
		local wounds = t.getWoundReduction(self, t) * 100
		local regen = t.getLifeRegen(self, t)
		local healmod = t.getHealMod(self, t)
		local duration = t.getDuration(self, t)
		return ([[You recover faster from poisons, diseases and wounds; reducing the duration of all such affects by %d%%.  Additionally you gain %0.2f life regen and %d%% healing modifier for %d turns when your life drops below 50%%.
		The healing modifier and life regen will scale with your Constitution stat.]]):
		format(wounds, regen, healmod, duration)
	end,
}

newTalent{
	name = "Daunting Presence",
	type = {"technique/conditioning", 2},
	require = techs_con_req2,
	points = 5,
	mode = "sustained",
	sustain_stamina = 20,
	cooldown = 8,
	tactical = { DEFEND = 2, DISABLE = 1, },
	range = 0,
	getRadius = function(self, t) return math.ceil(self:getTalentLevel(t)/2) end,
	getPenalty = function(self, t) return self:combatTalentStatDamage(t, "con", 5, 30) end,
	getMinimumLife = function(self, t)
		return self.max_life * (0.5 - (self:getTalentLevel(t)/20))
	end,
	on_pre_use = function(self, t, silent) if t.getMinimumLife(self, t) > self.life then if not silent then game.logPlayer(self, "You are too injured to use this talent.") end return false end return true end,
	do_daunting_presence = function(self, t)
		local tg = {type="ball", range=0, radius=t.getRadius(self, t), friendlyfire=false, talent=t}
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if target then
				if target:canBe("fear") then
					target:setEffect(target.EFF_INTIMIDATED, 4, {apply_power=self:combatAttackStr(), power=t.getPenalty(self, t), no_ct_effect=true})
					game.level.map:particleEmitter(target.x, target.y, 1, "flame")
				else
					game.logSeen(target, "%s is not intimidated!", target.name:capitalize())
				end
			end
		end)
	end,
	activate = function(self, t)
		local ret = {	}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local penalty = t.getPenalty(self, t)
		local min_life = t.getMinimumLife(self, t)
		return ([[Enemies are intimidated by how composed you remain under fire.  When you take more then 5%% of your maximum life in a single hit all enemies in a radius of %d will be intimidated, reducing their physical power, mind power, and spellpower by %d for 4 turns.
		If your health drops below %d you'll be unable to maintain your daunting presence and the sustain will deactivate.  The power of the intimidation effect will scale with your Constitution stat.]]):
		format(radius, penalty, min_life)
	end,
}

newTalent{
	name = "Unflinching Resolve",
	type = {"technique/conditioning", 3},
	require = techs_con_req3,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return self:combatTalentStatDamage(t, "con", 20, 80) end,
	do_unflinching_resolve = function(self, t)
		local effs = {}
		-- Go through all spell effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" then
				if e.subtype.stun then 
					effs[#effs+1] = {"effect", eff_id}
				elseif e.subtype.blind and self:getTalentLevel(t) >=2 then
					effs[#effs+1] = {"effect", eff_id}
				elseif e.subtype.confusion and self:getTalentLevel(t) >=3 then
					effs[#effs+1] = {"effect", eff_id}
				elseif e.subtype.pin and self:getTalentLevel(t) >=4 then
					effs[#effs+1] = {"effect", eff_id}
				elseif e.subtype.slow and self:getTalentLevel(t) >=5 then
					effs[#effs+1] = {"effect", eff_id}
				end
			end
		end
		
		if #effs > 0 then
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" and rng.percent(t.getChance(self, t)) then
				self:removeEffect(eff[2])
				game.logSeen(self, "%s has recovered!", self.name:capitalize())
			end
		end
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[You've learned to recover quickly from effects that would disable you. Each turn you have a %d%% chance to recover from a single stun effect.
		At talent level 2 you may also recover from blindness, at level 3 confusion, level 4 pins, and level 5 slows. 
		Only one effect may be recovered from each turn and the chance to recover from an effect scales with your Constitution stat.]]):
		format(chance)
	end,
}

newTalent{
	name = "Adrenaline Surge", -- no stamina cost; it's main purpose is to give the player an alternative means of using stamina based talents
	type = {"technique/conditioning", 4},
	require = techs_con_req4,
	points = 5,
	cooldown = 24,
	tactical = { STAMINA = 1, BUFF = 2 },
	getAttackPower = function(self, t) return self:combatTalentStatDamage(t, "con", 5, 25) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)) end,
	no_energy = true,
	action = function(self, t)
		self:setEffect(self.EFF_ADRENALINE_SURGE, t.getDuration(self, t), {power = t.getAttackPower(self, t)})
		return true
	end,
	info = function(self, t)
		local attack_power = t.getAttackPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[You release a surge of adrenaline that increases your physical power by %d for %d turns. While the effect is active you may continue to fight beyond the point of exhaustion.
		Your stamina based sustains will not be disabled if your stamina reaches zero and you may continue to use stamina based talents while at zero stamina at the cost of life.
		The attack power increase will scale with your Constitution stat.
		Using this talent does not take a turn.]]):
		format(attack_power, duration)
	end,
}
