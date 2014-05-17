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

-- Empty Hand adds extra scaling to gauntlet and glove attacks based on character level.

newTalent{
	name = "Empty Hand",
	type = {"technique/unarmed-other", 1},
	innate = true,
	hide = true,
	mode = "passive",
	points = 1,
	no_unlearn_last = true,
	on_learn = function(self, t)
		local fct = function()
			self.before_empty_hands_combat = self.combat
			self.combat = table.clone(self.combat, true)
			self.combat.physspeed = math.min(0.6, self.combat.physspeed or 1000)
			if not self.combat.sound then self.combat.sound = {"actions/punch%d", 1, 4} end
			if not self.combat.sound_miss then self.combat.sound_miss = "actions/melee_miss" end
		end
		if type(self.combat.dam) == "table" then
			game:onTickEnd(fct)
		else
			fct()
		end
	end,
	on_unlearn = function(self, t)
		self.combat = self.before_empty_hands_combat
	end,
	getDamage = function(self, t) return self.level * 0.5 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Grants %d Physical Power when fightning unarmed (or with gloves or gauntlets).
		This talent's effects will scale with your level.]]):
		format(damage)
	end,
}

-- This is by far the most powerful weapon tree in the game, loosely because you lose 2 weapon slots to make use of it and weapon stats are huge
-- Regardless, it gives much less damage than most weapon trees and is slightly more frontloaded
newTalent{
	name = "Unarmed Mastery",
	type = {"technique/unarmed-training", 1},
	points = 5,
	require = { stat = { cun=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 4 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[Increases Physical Power by %d, and increases all unarmed damage by %d%% (including grapples and kicks).
		Note that brawlers naturally gain 0.5 Physical Power per character level while unarmed (current brawler physical power bonus: %0.1f) and attack 40%% faster while unarmed.]]):
		format(damage, 100*inc, self.level * 0.5)
	end,
}

newTalent{
	name = "Unified Body",
	type = {"technique/unarmed-training", 2},
	require = techs_cun_req2,
	mode = "passive",
	points = 5,
	tactical = { BUFF = 2 },
	getStr = function(self, t) return math.ceil(self:combatTalentScale(t, 1.5, 7.5, 0.75) + self:combatTalentStatDamage(t, "cun", 2, 10)) end,
	getCon = function(self, t) return math.ceil(self:combatTalentScale(t, 1.5, 7.5, 0.75) + self:combatTalentStatDamage(t, "dex", 5, 25)) end,

	passives = function(self, t, tmptable)
			self:talentTemporaryValue(tmptable, "inc_stats", {[self.STAT_CON] = t.getCon(self, t)})
			self:talentTemporaryValue(tmptable, "inc_stats", {[self.STAT_STR] = t.getStr(self, t)})	
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if self.turn_procs.unified_body then return end
		if stat == self.STAT_DEX or stat == self.STAT_CUN then
			self.turn_procs.unified_body = true
			self:updateTalentPassives(t)
		end
	end,
	info = function(self, t)
		return ([[Your mastery of unarmed combat unifies your body.  Increases your Strength by %d based on Cunning and your Constitution by %d based on Dexterity.]]):format(t.getStr(self, t), t.getCon(self, t))
	end
}

newTalent{
	name = "Heightened Reflexes",
	type = {"technique/unarmed-training", 3},
	require = techs_cun_req3,
	mode = "passive",
	points = 5,
	getPower = function(self, t) return self:combatTalentScale(t, 0.1, 2, 0.75) end,
	do_reflexes = function(self, t)
		self:setEffect(self.EFF_REFLEXIVE_DODGING, 1, {power=t.getPower(self, t)})
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[When you're targeted by a projectile, your global speed is increased by %d%% for 1 turn.  Taking any action other then movement will break the effect.]]):
		format(power * 100)
	end,
}

-- It's a bit wierd that this works against mind attacks
newTalent{
	name = "Reflex Defense",
	type = {"technique/unarmed-training", 4},
	require = techs_cun_req4, -- bit icky since this is clearly dex, but whatever, cun turns defense special *handwave*
	points = 5,
	mode = "passive",
	getDamageReduction = function(self, t) 
		return self:combatTalentLimit(t, 1, 0.15, 0.50) * self:combatLimit(self:combatDefense(), 1, 0.15, 10, 0.5, 50) -- Limit < 100%, 25% for TL 5.0 and 50 defense
	end,
	getDamagePct = function(self, t)
		return self:combatTalentLimit(t, 0.1, 0.3, 0.15) -- Limit trigger > 10% life
	end,
	callbackOnHit = function(self, t, cb)
		if ( cb.value > (t.getDamagePct(self, t) * self.max_life) ) then
			local damageReduction = cb.value * t.getDamageReduction(self, t)
			cb.value = cb.value - damageReduction
			game.logPlayer(self, "#GREEN#You twist your body in complex ways mitigating the blow by #ORCHID#" .. math.ceil(damageReduction) .. "#LAST#.")
		end
		return cb.value
	end, 
	info = function(self, t)
		return ([[Your understanding of physiology allows you to apply your reflexes in new ways.  Whenever you would receive damage (from any source) greater than %d%% of your maximum life you reduce that damage by %0.1f%% (based on your Defense).]]):
		format(t.getDamagePct(self, t)*100, t.getDamageReduction(self, t)*100 )
	end,
}

