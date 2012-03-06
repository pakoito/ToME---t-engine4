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
	name = "Curse of Defenselessness",
	type = {"corruption/curses", 1},
	require = corrs_req1,
	points = 5,
	cooldown = 20,
	vim = 20,
	range = 10,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_CURSE_DEFENSELESSNESS, 10, {power=self:combatTalentSpellDamage(t, 30, 60), apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Curses your target, decreasing its defense and saves by %d for 10 turns.
		The defense and saves will decrease with Magic stat.]]):format(self:combatTalentSpellDamage(t, 30, 60))
	end,
}

newTalent{
	name = "Curse of Impotence",
	type = {"corruption/curses", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 20,
	vim = 20,
	range = 10,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_CURSE_IMPOTENCE, 10, {power=self:combatTalentSpellDamage(t, 10, 30), apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Curses your target, decreasing all damage done by %d%% for 10 turns.
		The damage will decrease with Magic stat.]]):format(self:combatTalentSpellDamage(t, 10, 30))
	end,
}

newTalent{
	name = "Curse of Death",
	type = {"corruption/curses", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 20,
	vim = 20,
	range = 10,
	tactical = { ATTACK = {DARKNESS = 2}, DISABLE = 1 },
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_CURSE_DEATH, 10, {src=self, dam=self:combatTalentSpellDamage(t, 10, 70), apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Curses your target, stopping any natural healing and dealing %0.2f darkness damage each turn for 10 turns.
		The damage will increase with Magic stat.]]):format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 10, 70)))
	end,
}

newTalent{
	name = "Curse of Vulnerability",
	type = {"corruption/curses", 4},
	require = corrs_req4,
	points = 5,
	cooldown = 20,
	vim = 20,
	range = 10,
	tactical = { DISABLE = 2 },
	requires_target = true,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_CURSE_VULNERABILITY, 7, {power=self:combatTalentSpellDamage(t, 10, 40), apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Curses your target, decreasing all its resistances by %d%% for 7 turns.
		The resistances will decrease with Magic stat.]]):format(self:combatTalentSpellDamage(t, 10, 40))
	end,
}
