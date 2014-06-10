-- Skirmisher, a class for Tales of Maj'Eyal 1.1.5
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


newTalent {
	short_name = "SKIRMISHER_BUCKLER_EXPERTISE",
	name = "Buckler Expertise",
	type = {"technique/buckler-training", 1},
	require = techs_dex_req1,
	points = 5,
	no_unlearn_last = true,
	mode = "passive",
	chance = function(self, t) --Limit < 50%, 5% at TL =1, Cun = 10, 25% at TL=5, Cun=100
		return self:combatLimit(self:getTalentLevel(t)*10+self:getCun()*0.5, 50, 5, 15, 25, 100)
	end,
	-- called by _M:combatArmorHardiness
	getHardiness = function(self, t)
		return 0 --self:getTalentLevel(t) * 4;
	end,
	-- called by Combat.attackTargetWith
	shouldEvade = function(self, t)
		return rng.percent(t.chance(self, t)) and self:hasShield() and not self:hasHeavyArmor()
	end,
	onEvade = function(self, t, target)
		if self:isTalentActive(self.T_SKIRMISHER_COUNTER_SHOT) and target then
			local t2 = self:getTalentFromId(self.T_SKIRMISHER_COUNTER_SHOT)
			t2.doCounter(self, t2, target)
		end
	end,
	on_learn = function(self, t)
		self:attr("show_shield_combat", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("show_shield_combat", 1)
	end,
	info = function(self, t)
		local block = t.chance(self, t)
		local armor = t.getHardiness(self, t)
		return ([[Allows shields to be equipped, using Cunning instead of strength as a requirement.
			When you are attacked in melee, you have a %d%% chance to deflect the attack with your shield, completely evading it.
			The chance to deflect increases with your Cunning.]])
			:format(block, armor)
	end,
}

newTalent {
	short_name = "SKIRMISHER_BASH_AND_SMASH",
	name = "Bash and Smash",
	type = {"technique/buckler-training", 2},
	require = techs_dex_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	stamina = 15,
	requires_target = true,
	tactical = { ATTACK = 2, ESCAPE = { knockback = 1 }, DISABLE = { knockback = 1 } },
	on_pre_use = function(self, t, silent)
		if not self:hasShield() or not self:hasArcheryWeapon() then
			if not silent then game.logPlayer(self, "You require a ranged weapon and a shield to use this talent.") end
			return false
		end
		return true
	end,

	getDist = function(self, t)
		if self:getTalentLevelRaw(t) >= 3 then
			return 3
		else
			return 2
		end
	end,
	getShieldMult = function(self, t)
		return self:combatTalentWeaponDamage(t, 1, 2)
	end,
	getSlingMult = function(self, t)
		return self:combatTalentWeaponDamage(t, 1.5, 3)
	end,
	action = function(self, t)
		local shield = self:hasShield()
		local sling = self:hasArcheryWeapon()
		if not shield or not sling then
			game.logPlayer(self, "You require a ranged weapon and a shield to use this talent.")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local autocrit = false
		if self:knowTalent(self.T_SKIRMISHER_BUCKLER_MASTERY) then
			local t2 = self:getTalentFromId(self.T_SKIRMISHER_BUCKLER_MASTERY)
			if self:getTalentLevelRaw(t2) >= 5 then
				autocrit = true
			end
		end

		if autocrit then
			self.combat_physcrit = self.combat_physcrit + 1000
		end

		-- Modify shield combat to use dex.
		local combat = table.clone(shield.special_combat, true)
		if combat.dammod.str and combat.dammod.str > 0 then
			combat.dammod.dex = (combat.dammod.dex or 0) + combat.dammod.str
			combat.dammod.str = nil
		end

		-- First attack with shield
		local speed, hit = self:attackTargetWith(target, combat, nil, t.getShieldMult(self, t))
		-- At talent levels >= 5, attack twice
		if self:getTalentLevel(t) >= 5 then
			local speed, hit = self:attackTargetWith(target, combat, nil, t.getShieldMult(self, t))
		end

		if autocrit then
			self.combat_physcrit = self.combat_physcrit - 1000
		end

		-- Knockback
		if hit then
			if target:canBe("knockback") then
				local dist = t.getDist(self, t)
				target:knockback(self.x, self.y, dist)
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end

		-- Ranged attack
		local targets = self:archeryAcquireTargets(nil, {one_shot=true, x=target.x, y=target.y, no_energy = true})
		if targets then
			--game.logSeen(self, "%s follows up with a shot from %s!", self.name:capitalize(), sling:getName())
			self:archeryShoot(targets, t, nil, {mult=t.getSlingMult(self, t)})
		end

		return true
	end,
	info = function(self, t)
		local shieldMult = t.getShieldMult(self, t) * 100
		local tiles = t.getDist(self, t)
		local slingMult = t.getSlingMult(self, t) * 100
		return ([[Bash an enemy in melee range with your shield (twice for talent level 5 or more), doing %d%% damage and knocking them back %d squares. You may then follow with a deadly short-range sling attack, dealing %d%% damage. The shield bash will use Dexterity instead of Strength for the shield's bonus damage.]])
		:format(shieldMult, tiles, slingMult)
	end,
}

newTalent {
	short_name = "SKIRMISHER_BUCKLER_MASTERY",
	name = "Buckler Mastery",
	type = {"technique/buckler-training", 3},
	require = techs_dex_req3,
	points = 5,
	mode = "passive",
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 7.5, 37.5) end, --limit < 100%
	getRange = function(self, t) return math.ceil(self:combatTalentScale(t, 0.5, 3, "log")) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "projectile_evasion", t.getChance(self, t))
		self:talentTemporaryValue(p, "projectile_evasion_spread", t.getRange(self, t))
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local range = t.getRange(self, t)
		local crit = ""
		local t2 = self:getTalentFromId(self.T_SKIRMISHER_BASH_AND_SMASH)
		if t2 then
			if self:getTalentLevelRaw(t2) >= 5 then
				crit = " At talent level 5, your Bash and Smash shield hits are guaranteed criticals."
			else
				crit = " At talent level 5, your Bash and Smash shield hit is a guaranteed critical."
			end
		end
		return ([[When you are hit by a projectile, physical or otherwise, you have a %d%% chance to deflect it up to %d squares away.%s]])
			:format(chance, range, crit)
	end,
}

-- Stamina cost removed, this triggers too much and tends to randomly spike your stamina to nothing
-- It might be ok if there weren't other passives with random stamina drain too, but..
newTalent {
	short_name = "SKIRMISHER_COUNTER_SHOT",
	name = "Counter Shot",
	type = {"technique/buckler-training", 4},
	mode = "sustained",
	points = 5,
	cooldown = 10,
	sustain_stamina = 0,
	no_energy = true,
	require = techs_dex_req4,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t, silent)
		if not self:hasShield() or not self:hasArcheryWeapon() then
			if not silent then game.logPlayer(self, "You require a ranged weapon and a shield to use this talent.") end
			return false
		end
		return true
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	getMult = function(self, t)
		return self:combatTalentScale(t, .2, 0.6)
	end,
	getBlocks = function(self, t)
		return math.min(7, math.floor(self:combatTalentScale(t, 1, 4)))
	end,
	-- called from the relevant buckler talents
	doCounter = function(self, t, target)
		local sling = self:hasArcheryWeapon()
		--local stamina = t.getStaminaPerShot(self, t)
		if not sling or (self.turn_procs.counter_shot and self.turn_procs.counter_shot > t.getBlocks(self, t) ) or not target.x or not target.y then --or self.stamina < stamina then
			return false
		end
		self.turn_procs.counter_shot = 1 + (self.turn_procs.counter_shot or 0)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true, x=target.x, y=target.y, no_energy = true})
		if targets then
			self:logCombat(who, "#ORCHID##Source# follows up with a countershot.#LAST#")
			--self:incStamina(-stamina)


			self:archeryShoot(targets, t, nil, {mult=t.getMult(self, t)})
		end
	end,

	info = function(self, t)
		local mult = t.getMult(self, t) * 100
		local blocks = t.getBlocks(self, t)
		--local stamina = t.getStaminaPerShot(self, t)
		return ([[Any time you block an attack with Buckler Expertise or Buckler Mastery you instantly counterattack with your sling for %d%% damage  This can only occur up to %d time(s) per turn.
			]])
			:format(mult, blocks)
	end,
}
