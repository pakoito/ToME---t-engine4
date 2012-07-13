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
	name = "Corrupted Strength",
	type = {"corruption/reaving-combat", 1},
	mode = "passive",
	points = 5,
	require = str_corrs_req1,
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
		return ([[Allows you to dual wield any type of one handed weapons and increases the damage of the off-hand weapon to %d%%.
		Also casting a spell (which uses a turn) will give a free melee attack at a random target in melee range for %d%% blight damage.]]):
		format(100 / (2 - self:getTalentLevel(t) / 9), 100 * self:combatTalentWeaponDamage(t, 0.5, 1.1))
	end,
}

newTalent{
	name = "Bloodlust",
	type = {"corruption/reaving-combat", 2},
	mode = "passive",
	require = str_corrs_req2,
	points = 5,
	info = function(self, t)
		return ([[When you damage one of your foes you enter a bloodlust, increasing your spell power by 1 for each target, up to a maximum of %d per turn.
		The maximum reachable is +%d spell power.
		The bonus decreases by one per turn.]]):
		format(math.floor(self:getTalentLevel(t)), math.floor(6 * self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Carrier",
	type = {"corruption/reaving-combat", 3},
	mode = "passive",
	require = str_corrs_req3,
	points = 5,
	on_learn = function(self, t)
		self:attr("disease_immune", 0.2)
	end,
	on_unlearn = function(self, t)
		self:attr("disease_immune", -0.2)
	end,
	info = function(self, t)
		return ([[You gain a %d%% resistance to diseases and have a %d%% chance on melee attacks to spread any existing diseases on your target.]]):
		format(20 * self:getTalentLevelRaw(t), 4 * self:getTalentLevelRaw(t))
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
		return ([[Your blood turns into an acidic mixture. When you get hit the attacker is splashed with acid.
		This deals %0.2f acid damage each turn for 5 turns and reduces the attacker's accuracy by %d.
		At level 3 it will also reduce armour by %d for 5 turns.
		The damage will increase with your Magic stat.]]):
		format(damDesc(self, DamageType.ACID, self:combatTalentSpellDamage(t, 5, 30)), self:combatTalentSpellDamage(t, 15, 35), self:combatTalentSpellDamage(t, 15, 40))
	end,
}
