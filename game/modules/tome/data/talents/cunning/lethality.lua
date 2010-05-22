-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
	info = function(self, t)
		return ([[You have learned to find and hit the weak spots. Your strikes have a %0.2f%% greater chance to be critical hits.
		Also, when using knives, you now use your cunning score instead of your strength for bonus damage.]]):format(1 + self:getTalentLevel(t) * 1.3)
	end,
}

newTalent{
	name = "Deadly Strikes",
	type = {"cunning/lethality", 2},
	points = 5,
	cooldown = 12,
	stamina = 15,
	require = cuns_req2,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, 0.8 + self:getTalentLevel(t) / 10, true)

		if hitted then
			local dur = 5 + math.ceil(self:getTalentLevel(t))
			local power = 4 + (self:getTalentLevel(t) * self:getCun()) / 20
			self:setEffect(self.EFF_DEADLY_STRIKES, dur, {power=power})
		end

		return true
	end,
	info = function(self, t)
		return ([[You hit your target doing %d%% damage. If your attack hits, you gain %d armour penetration for %d turns.
		The APR will increase with Cunning.]]):
		format(100 * (0.8 + self:getTalentLevel(t) / 10), 4 + (self:getTalentLevel(t) * self:getCun()) / 20, 5 + math.ceil(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Willful Combat",
	type = {"cunning/lethality", 3},
	points = 5,
	cooldown = 60,
	stamina = 25,
	require = cuns_req3,
	action = function(self, t)
		local dur = 3 + math.ceil(self:getTalentLevel(t) * 1.5)
		local power = self:getWil(70)
		self:setEffect(self.EFF_WILLFUL_COMBAT, dur, {power=power})
		return true
	end,
	info = function(self, t)
		return ([[For %d turns you put all your will into your blows, adding %d (based on Willpower) damage to each strike.]]):
		format(3 + math.ceil(self:getTalentLevel(t) * 1.5), self:getWil(70))
	end,
}

newTalent{
	name = "Snap",
	type = {"cunning/lethality",4},
	require = cuns_req4,
	points = 5,
	stamina = 50,
	cooldown = 50,
	action = function(self, t)
		local nb = math.ceil(self:getTalentLevel(t) + 2)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[2] <= self:getTalentLevelRaw(t) and (tt.type[1]:find("^cunning/")  or tt.type[1]:find("^technique/")) then
				tids[#tids+1] = tid
			end
		end
		for i = 1, nb do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		self.changed = true
		return true
	end,
	info = function(self, t)
		return ([[Your quick wits allow you to reset the cooldown of %d of your combat talents of level %d or less.]]):
		format(math.ceil(self:getTalentLevel(t) + 2), self:getTalentLevelRaw(t))
	end,
}
