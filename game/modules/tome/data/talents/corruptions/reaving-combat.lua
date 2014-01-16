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

newTalent{
	name = "Corrupted Strength",
	type = {"corruption/reaving-combat", 1},
	mode = "passive",
	points = 5,
	vim = 8,
	require = str_corrs_req1,
	-- called by _M:getOffHandMult function in mod\class\interface\Combat.lua
	getoffmult = function(self,t) return self:combatTalentLimit(t, 1, 0.53, 0.69) end, -- limit <100%
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			self:attr("allow_any_dual_weapons", 1)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:attr("allow_any_dual_weapons", -1)
		end
	end,
	info = function(self, t)
		return ([[Allows you to dual wield any type of one handed weapons, and increases the damage of the off-hand weapon to %d%%.
		Also, casting a spell (which uses a turn) will give a free melee attack at a random target in melee range for %d%% blight damage.]]):
		format(100*t.getoffmult(self,t), 100 * self:combatTalentWeaponDamage(t, 0.5, 1.1))
	end,
}

newTalent{
	name = "Bloodlust",
	type = {"corruption/reaving-combat", 2},
	mode = "passive",
	require = str_corrs_req2,
	points = 5,
	-- _M:combatSpellpower references effect in mod\class\interface\Combat.lua
	-- Effect is refreshed in function _M:onTakeHit(value, src) in mod\class\Actor.lua
	-- getParams called in definition of EFF_BLOODLUST in data\timed_effects\magical.lua
	getParams = function(self, t) -- returns maxSP per turn, max duration
		return self:combatTalentScale(t, 1, 5, 0.75), math.floor(self:combatTalentScale(t, 2, 6))
	end,
	info = function(self, t)
		local SPbonus, maxDur = t.getParams(self, t)
		return ([[Each time you deal damage to one of your foes, you enter a bloodlust-infused frenzy, increasing your Spellpower by 1 (maximum %d Spellpower per turn, %d Spellpower overall), and extending any current frenzy for an additional turn.
		The frenzy lasts up to %d turns, and the bonus decreases by %0.1f%% of its current value each turn you don't deal damage.]]):
		format(SPbonus, SPbonus*6, maxDur, 100/maxDur)
	end,
}

newTalent{
	name = "Carrier",
	type = {"corruption/reaving-combat", 3},
	mode = "passive",
	require = str_corrs_req3,
	points = 5,
	getDiseaseImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.20, 0.75) end, -- Limit < 100%
	-- called by _M:attackTargetWith in mod.class.interface.Combat.lua
	getDiseaseSpread = function(self, t) return self:combatTalentLimit(t, 100, 5, 20) end, --Limit < 100%
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "disease_immune", t.getDiseaseImmune(self, t))
	end,
	info = function(self, t)
		return ([[You gain a %d%% resistance to diseases, and each of your melee attacks have a %d%% chance to spread any diseases on your target.
		(As the Epidemic talent with the melee attack treated like blight damage.)]]):
		format(t.getDiseaseImmune(self, t)*100, t.getDiseaseSpread(self, t))
	end,
}

newTalent{
	name = "Acid Blood",
	type = {"corruption/reaving-combat", 4},
	mode = "passive",
	require = str_corrs_req4,
	points = 5,
	do_splash = function(self, t, target)
		local dam = self:spellCrit(self:combatTalentSpellDamage(t, 5, 30))
		local atk = self:combatTalentSpellDamage(t, 15, 35)
		local armor = self:combatTalentSpellDamage(t, 15, 40)
		if self:getTalentLevel(t) >= 3 then
			target:setEffect(target.EFF_ACID_SPLASH, 5, {src=self, dam=dam, atk=atk, armor=armor})
		else
			target:setEffect(target.EFF_ACID_SPLASH, 5, {src=self, dam=dam, atk=atk})
		end
	end,
	info = function(self, t)
		return ([[Your blood turns into an acidic mixture. When you get hit, the attacker is splashed with acid.
		This deals %0.2f acid damage each turn for 5 turns, and reduces the attacker's Accuracy by %d.
		At level 3, it will also reduce Armour by %d for 5 turns.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.ACID, self:combatTalentSpellDamage(t, 5, 30)), self:combatTalentSpellDamage(t, 15, 35), self:combatTalentSpellDamage(t, 15, 40))
	end,
}
