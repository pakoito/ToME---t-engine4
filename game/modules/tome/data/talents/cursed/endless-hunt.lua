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

newTalent{
	name = "Stalk",
	type = {"cursed/endless-hunt", 1},
	mode = "sustained",
	require = cursed_wil_req1,
	points = 5,
	cooldown = 0,
	no_energy = true,
	tactical = { BUFF = 5 },
	activate = function(self, t)
		return {
			hit = false, -- was any target hit this turn
			hit_target = nil, -- which single target was hit this turn
			hit_turns = 0, -- how many turns has the target been hit
		}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	getDuration = function(self, t)
		return 40
	end,
	getHitHateChange = function(self, t, bonus)Patbonus = math.min(bonus, 3)
		return 0.5 * bonus
	end,
	getAttackChange = function(self, t, bonus)
		return math.floor(self:combatTalentStatDamage(t, "wil", 10, 30) * math.sqrt(bonus))
	end,
	getStalkedDamageMultiplier = function(self, t, bonus)
		return 1 + self:combatTalentIntervalDamage(t, "str", 0.1, 0.35, 0.4) * bonus / 3
	end,
	doStalk = function(self, t, target)
		if self:hasEffect(self.EFF_STALKER) or target:hasEffect(self.EFF_STALKED) then
			-- doesn't support multiple stalkers, stalkees
			game.logPlayer(self, "#F53CBE#You are having trouble focusing on your prey!")
			return false
		end

		local duration = t.getDuration(self, t)
		self:setEffect(self.EFF_STALKER, duration, { target=target, bonus = 1 })
		target:setEffect(self.EFF_STALKED, duration, { source=self })

		game.level.map:particleEmitter(target.x, target.y, 1, "stalked_start")

		return true
	end,
	on_targetDied = function(self, t, target)
		self:removeEffect(self.EFF_STALKER)
		target:removeEffect(self.EFF_STALKED)

		-- prevent stalk targeting this turn
		local stalk = self:isTalentActive(self.T_STALK)
		if stalk then
			stalk.hit = false
			stalk.hit_target = nil
			stalk.hit_turns = 0
		end
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[When you focus your attacks on a single foe and melee strike them for two consecutive turns your hated of them overcomes you and you begin to stalk them with single-minded purpose. The effect will last for %d turns or until your prey is dead. Stalking gives you bonuses against your foe that grow each turn you hit them and diminish each turn you don't.
		bonus level 1: +%d attack, +%d%% melee damage, +%0.2f hate/turn prey was hit
		bonus level 2: +%d attack, +%d%% melee damage, +%0.2f hate/turn prey was hit
		bonus level 3: +%d attack, +%d%% melee damage, +%0.2f hate/turn prey was hit
		Attack and damage increase with the Willpower stat.]]):format(duration,
		t.getAttackChange(self, t, 1), t.getStalkedDamageMultiplier(self, t, 1) * 100 - 100, t.getHitHateChange(self, t, 1),
		t.getAttackChange(self, t, 2), t.getStalkedDamageMultiplier(self, t, 2) * 100 - 100, t.getHitHateChange(self, t, 2),
		t.getAttackChange(self, t, 3), t.getStalkedDamageMultiplier(self, t, 3) * 100 - 100, t.getHitHateChange(self, t, 3))
	end,
}

newTalent{
	name = "Beckon",
	type = {"cursed/endless-hunt", 2},
	require = cursed_wil_req2,
	points = 5,
	cooldown = 10,
	hate = 2,
	tactical = { DISABLE = 2 },
	range = 10,
	getDuration = function(self, t)
		return math.min(20, math.floor(5 + self:getTalentLevel(t) * 2))
	end,
	getChance = function(self, t)
		return math.min(75, math.floor(25 + (math.sqrt(self:getTalentLevel(t)) - 1) * 20))
	end,
	getSpellpowerChange = function(self, t)
		return -self:combatTalentStatDamage(t, "wil", 8, 33)
	end,
	getMindpowerChange = function(self, t)
		return -self:combatTalentStatDamage(t, "wil", 8, 33)
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)

		local tg = {type="hit", pass_terrain=true, range=range}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > range then return nil end

		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		local spellpowerChange = t.getSpellpowerChange(self, t)
		local mindpowerChange = t.getMindpowerChange(self, t)
		target:setEffect(target.EFF_BECKONED, duration, { source=self, range=range, chance=chance, spellpowerChange=spellpowerChange, mindpowerChange=mindpowerChange })

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		local spellpowerChange = t.getSpellpowerChange(self, t)
		local mindpowerChange = t.getMindpowerChange(self, t)
		return ([[The connection between predator and prey allows you to speak to the mind of your target and beckon them closer. For %d turns they will try to come to you, even pushing others aside to do so. They will move towards you instead of acting %d%% of the time but can save verses Mindpower to slow the effect. If they take significant damage, the beckoning may be overcome altogether. The effect makes concentration difficult for your target, reducing spellpower and mindpower by %d until they reach you.
		Spellpower and Mindpower reduction increases with the Willpower stat.]]):format(duration, chance, -spellpowerChange)
	end,
}

newTalent{
	name = "Harass Prey",
	type = {"cursed/endless-hunt", 3},
	require = cursed_wil_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	hate = 5,
	tactical = { ATTACK = { PHYSICAL = 3 } },
	getCooldownDuration = function(self, t)
		return 3 + math.floor(self:getTalentLevel(t) * 0.75)
	end,
	getDamageMultiplier = function(self, t, hate)
		return getHateMultiplier(self, 0.35, 0.67, false, hate)
	end,
	getTargetDamageChange = function(self, t)
		return -self:combatTalentStatDamage(t, "wil", 0.7, 0.9)
	end,
	getDuration = function(self, t)
		return 2
	end,
	on_pre_use = function(self, t)
		local eff = self:hasEffect(self.EFF_STALKER)
		return eff and not eff.target.dead and core.fov.distance(self.x, self.y, eff.target.x, eff.target.y) <= 1
	end,
	action = function(self, t)
		local damageMultipler = t.getDamageMultiplier(self, t)
		local cooldownDuration = t.getCooldownDuration(self, t)
		local targetDamageChange = t.getTargetDamageChange(self, t)
		local duration = t.getDuration(self, t)
		local effStalker = self:hasEffect(self.EFF_STALKER)
		local target = effStalker.target
		if not target or target.dead then return nil end

		target:setEffect(target.EFF_HARASSED, duration, { source=self, damageChange=targetDamageChange })

		for i = 1, 2 do
			if not target.dead and self:attackTarget(target, nil, damageMultipler, true) then
				-- remove effects
				local tids = {}
				for tid, lev in pairs(target.talents) do
					local t = target:getTalentFromId(tid)
					if not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
				end

				local t = rng.tableRemove(tids)
				if t then
					target.talents_cd[t.id] = rng.range(3, 5)
					game.logSeen(target, "#F53CBE#%s's %s is disrupted!", target.name:capitalize(), t.name)
				end
			end
		end

		return true
	end,
	info = function(self, t)
		local damageMultipler = t.getDamageMultiplier(self, t)
		local cooldownDuration = t.getCooldownDuration(self, t)
		local targetDamageChange = t.getTargetDamageChange(self, t)
		local duration = t.getDuration(self, t)
		return ([[Harass your stalked victim with two quick attacks for %d%% (at 0 Hate) to %d%% (at 100+ Hate) damage each. Each attack that scores a hit disrupts one talent, rune or infusion for %d turns. Your opponent will be unnerved by the attacks, reducing the damage they deal by %d%% for %d turns.
		Damage reduction increases with the Willpower stat.]]):format(t.getDamageMultiplier(self, t, 0) * 100, t.getDamageMultiplier(self, t, 100) * 100, cooldownDuration, -targetDamageChange * 100, duration)
	end,
}

newTalent{
	name = "Surge",
	type = {"cursed/endless-hunt", 4},
	mode = "sustained",
	require = cursed_wil_req4,
	points = 5,
	cooldown = 10,
	no_energy = true,
	getMovementSpeedChange = function(self, t)
		return self:combatTalentStatDamage(t, "wil", 0.1, 1.1)
	end,
	getDefenseChange = function(self, t, hasDualweapon)
		if hasDualweapon or self:hasDualWeapon() then return self:combatTalentStatDamage(t, "wil", 4, 40) end
		return 0
	end,
	preUseTalent = function(self, t)
		-- prevent AI's from activating more than 1 talent
		if self ~= game.player and (self:isTalentActive(self.T_CLEAVE) or self:isTalentActive(self.T_REPEL)) then return false end
		return true
	end,
	activate = function(self, t)
		-- deactivate other talents and place on cooldown
		if self:isTalentActive(self.T_CLEAVE) then
			self:useTalent(self.T_CLEAVE)
		elseif self:knowTalent(self.T_CLEAVE) then
			local tCleave = self:getTalentFromId(self.T_CLEAVE)
			self.talents_cd[self.T_CLEAVE] = tCleave.cooldown
		end

		if self:isTalentActive(self.T_REPEL) then
			self:useTalent(self.T_REPEL)
		elseif self:knowTalent(self.T_REPEL) then
			local tRepel = self:getTalentFromId(self.T_REPEL)
			self.talents_cd[self.T_REPEL] = tRepel.cooldown
		end

		local movementSpeedChange = t.getMovementSpeedChange(self, t)
		return {
			moveId = self:addTemporaryValue("movement_speed", movementSpeedChange),
			luckId = self:addTemporaryValue("inc_stats", { [Stats.STAT_LCK] = -3 })
		}
	end,
	deactivate = function(self, t, p)
		if p.moveId then self:removeTemporaryValue("movement_speed", p.moveId) end
		if p.luckId then self:removeTemporaryValue("inc_stats", p.luckId) end

		return true
	end,
	info = function(self, t)
		local movementSpeedChange = t.getMovementSpeedChange(self, t)
		local defenseChange = t.getDefenseChange(self, t, true)
		return ([[Let hate fuel your movements. While active you gain %d%% movement speed. The recklessness of your movement brings you bad luck (luck -3). Cleave, repel and surge cannot be activate simultaneously and activating one will place the others in cooldown. The speed of your movements combined with the balance and utility of two weapons gives you %d extra defense while dual-wielding.
		Movement speed and dual-wielding defense increase with with the Willpower stat.]]):format(movementSpeedChange * 100, defenseChange)
	end,
}
