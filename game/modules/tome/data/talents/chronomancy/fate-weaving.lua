-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

-- EDGE TODO: Icons, Particles, Timed Effect Particles

newTalent{
	name = "Spin Fate",
	type = {"chronomancy/fate-weaving", 1},
	require = chrono_req1,
	mode = "passive",
	points = 5,
	getSaveBonus = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 8, 0.75)) end,
	doSpinFate = function(self, t)
		local save_bonus = t.getSaveBonus(self, t)
		local resists = self:knowTalent(self.T_FATEWEAVER) and self:callTalent(self.T_FATEWEAVER, "getResist") or 0
		
		self:setEffect(self.EFF_SPIN_FATE, 3, {save_bonus=save_bonus, resists=resists, spin=1, max_spin=3})
		
		return true
	end,
	info = function(self, t)
		local save = t.getSaveBonus(self, t)
		return ([[Each time you take damage from someone else you gain one spin, increasing your defense and saves by %d for three turns.
		This effect may occur once per turn and stacks up to three spin (for a maximum bonus of %d).]]):
		format(save, save * 3)
	end,
}

newTalent{
	name = "Webs of Fate",
	type = {"chronomancy/fate-weaving", 2},
	require = chrono_req2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 12,
	tactical = { BUFF = 2, CLOSEIN = 2, ESCAPE = 2 },
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 20, 100, getParadoxSpellpower(self))/100 end,
	getDuration = function(self, t) return 5 end,
	action = function(self, t)
		local effs = {}
			
		-- Find all pins
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.subtype.pin then
				effs[#effs+1] = {"effect", eff_id}
			end
		end
		
		-- And remove them
		while #effs > 0 do
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				self:removeEffect(eff[2])
			end
		end
		
		-- Set our power based on current spin
		local move = t.getPower(self, t)
		local pin = t.getPower(self, t)/2
		local eff = self:hasEffect(self.EFF_SPIN_FATE)
		if eff then 
			move = move * (1 + eff.spin/3)
			pin = pin * (1 + eff.spin/3)
		end
		pin = math.min(1, pin) -- Limit 100%
		
		self:setEffect(self.EFF_WEBS_OF_FATE, t.getDuration(self, t), {move=move, pin=pin})
		
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t) * 100
		local duration = t.getDuration(self, t)
		return ([[Activate to remove pins.  You also gain %d%% movement speed and %d%% pin immunity for %d turns.
		If you have Spin Fate active these bonuses will be increased by 33%% per spin (up to a maximum of %d%% and %d%% respectively).
		This spell will automatically cast when you're hit by most anomalies.  This will not consume a turn or put the spell on cooldown.
		While Webs of Fate is active you may gain one additional spin per turn.
		These bonuses will scale with your Spellpower.]]):format(power, math.min(100, power/2), duration, power * 2, math.min(100, power/2 * 2))
	end,
}

newTalent{
	name = "Fateweaver",
	type = {"chronomancy/fate-weaving", 3},
	require = chrono_req3,
	mode = "passive",
	points = 5,
	getResist = function(self, t) return self:combatTalentScale(t, 2, 8, 0.75)/2 end,
	info = function(self, t)
		local resist = t.getResist(self, t)
		return ([[You now gain %0.1f%% resist all when you gain spin with Spin Fate (up to a maximum of %0.1f%% resist all at three spin).]]):
		format(resist, resist*3)
	end,
}

newTalent{
	name = "Seal Fate",
	type = {"chronomancy/fate-weaving", 4},
	require = chrono_req4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 24,
	tactical = { BUFF = 2 },
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 25, getParadoxSpellpower(self)) end,
	getDuration = function(self, t) return 5 end,
	action = function(self, t)
		-- Set our power based on current spin
		local crits = t.getPower(self, t)
		local eff = self:hasEffect(self.EFF_SPIN_FATE)
		if eff then 
			crits = crits * (1 + eff.spin/3)
		end
			
		self:setEffect(self.EFF_SEAL_FATE, t.getDuration(self, t), {crit=crits})
		
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[Activate to increase critical hit chance and critical damage by %d%% for five turns.
		If you have Spin Fate active these bonuses will be increased by 33%% per spin (up to a maximum of %d%%).
		This spell will automatically cast when you're hit by most anomalies.  This will not consume a turn or put the spell on cooldown.
		While Seal Fate is active you may gain one additional spin per turn.
		These bonuses will scale with your Spellpower.]]):format(power, power * 2)
	end,
}