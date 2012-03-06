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
	name = "Lethality",
	type = {"cunning/lethality", 1},
	mode = "passive",
	points = 5,
	require = cuns_req1,
	on_learn = function(self, t)
		self.combat_critical_power = (self.combat_critical_power or 0) + 5
	end,
	on_unlearn = function(self, t)
		self.combat_critical_power = (self.combat_critical_power or 0) - 5
	end,
	getCriticalChance = function(self, t) return 1 + self:getTalentLevel(t) * 1.3 end,
	info = function(self, t)
		local critchance = t.getCriticalChance(self, t)
		return ([[You have learned to find and hit the weak spots. Your strikes have a %0.2f%% greater chance to be critical hits and your critical hits do %d%% more damage.
		Also, when using knives, you now use your cunning score instead of your strength for bonus damage.]]):
		format(critchance, self:getTalentLevelRaw(t) * 5)
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
	getArmorPierce = function(self, t) return self:combatTalentStatDamage(t, "cun", 5, 60) end,
	getDuration = function(self, t) return 5 + math.ceil(self:getTalentLevel(t)) end,
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
		return ([[You hit your target doing %d%% damage. If your attack hits, you gain %d armour penetration for %d turns.
		The APR will increase with Cunning.]]):
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
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t) * 1.5) end,
	getDamage = function(self, t) return self:getWil(40, true) + self:getCun(40, true) end,
	action = function(self, t)
		self:setEffect(self.EFF_WILLFUL_COMBAT, t.getDuration(self, t), {power=t.getDamage(self, t)})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		return ([[For %d turns you put all your will into your blows, adding %d damage to each strike.
		Damage will improve with your Cunning and Willpower stats.]]):
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
	getTalentCount = function(self, t) return math.ceil(self:getTalentLevel(t) + 2) end,
	getMaxLevel = function(self, t) return self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local nb = math.ceil(self:getTalentLevel(t) + 2)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[2] <= t.getMaxLevel(self, t) and (tt.type[1]:find("^cunning/") or tt.type[1]:find("^technique/")) then
				tids[#tids+1] = tid
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
		return ([[Your quick wits allow you to reset the cooldown of %d of your combat talents(cunning or technique) of level %d or less.]]):
		format(talentcount, maxlevel)
	end,
}

