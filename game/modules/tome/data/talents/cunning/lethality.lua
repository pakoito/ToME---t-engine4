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
	name = "Lethality",
	type = {"cunning/lethality", 1},
	mode = "passive",
	points = 5,
	require = cuns_req1,
	critpower = function(self, t) return self:combatTalentScale(t, 7.5, 25, 0.75) end,
	-- called by _M:combatCrit in mod.class.interface.Combat.lua
	getCriticalChance = function(self, t) return self:combatTalentScale(t, 2.3, 7.5, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_critical_power", t.critpower(self, t))
	end,
	info = function(self, t)
		local critchance = t.getCriticalChance(self, t)
		local power = t.critpower(self, t)
		return ([[You have learned to find and hit weak spots. All your strikes have a %0.2f%% greater chance to be critical hits, and your critical hits do %0.1f%% more damage.
		Also, when using knives, you now use your Cunning instead of your Strength for bonus damage.]]):
		format(critchance, power)
	end,
}

newTalent{
	name = "Deadly Strikes",
	type = {"cunning/lethality", 2},
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 15,
	require = cuns_req2,
	tactical = { ATTACK = {weapon = 2} },
	no_energy = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.4) end,
	getArmorPierce = function(self, t) return self:combatTalentStatDamage(t, "cun", 5, 45) end,  -- Adjust to scale like armor progression elsewhere
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 12, 6, 10)) end, --Limit to <12
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hitted then
			self:setEffect(self.EFF_DEADLY_STRIKES, t.getDuration(self, t), {power=t.getArmorPierce(self, t)})
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local apr = t.getArmorPierce(self, t)
		local duration = t.getDuration(self, t)
		return ([[You hit your target, doing %d%% damage. If your attack hits, you gain %d armour penetration for %d turns.
		The APR will increase with your Cunning.]]):
		format(100 * damage, apr, duration)
	end,
}

newTalent{
	name = "Willful Combat",
	type = {"cunning/lethality", 3},
	points = 5,
	random_ego = "attack",
	cooldown = 60,
	stamina = 25,
	tactical = { BUFF = 3 },
	require = cuns_req3,
	no_energy = true,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 60, 5, 11.1)) end, -- Limit <60
	getDamage = function(self, t) return self:combatStatScale("wil", 4, 40, 0.75) + self:combatStatScale("cun", 4, 40, 0.75) end,
	action = function(self, t)
		self:setEffect(self.EFF_WILLFUL_COMBAT, t.getDuration(self, t), {power=t.getDamage(self, t)})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		return ([[For %d turns, you put all your will into your blows, adding %d physical power to each strike.
		The effect will improve with your Cunning and Willpower stats.]]):
		format(duration, damage)
	end,
}

newTalent{
	name = "Snap",
	type = {"cunning/lethality",4},
	require = cuns_req4,
	points = 5,
	stamina = 50,
	cooldown = 50,
	tactical = { BUFF = 1 },
	fixed_cooldown = true,
	getTalentCount = function(self, t) return math.floor(self:combatTalentScale(t, 2, 7, "log")) end,
	getMaxLevel = function(self, t) return self:getTalentLevel(t) end,
	speed = "combat",
	action = function(self, t)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if not tt.fixed_cooldown then
				if tt.type[2] <= t.getMaxLevel(self, t) and (tt.type[1]:find("^cunning/") or tt.type[1]:find("^technique/")) then
					tids[#tids+1] = tid
				end
			end
		end
		for i = 1, t.getTalentCount(self, t) do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		self.changed = true
		return true
	end,
	info = function(self, t)
		local talentcount = t.getTalentCount(self, t)
		local maxlevel = t.getMaxLevel(self, t)
		return ([[Your quick wits allow you to reset the cooldown of up to %d of your combat talents (cunning or technique) of tier %d or less.]]):
		format(talentcount, maxlevel)
	end,
}
