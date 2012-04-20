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
	name = "Pacification Hex",
	type = {"corruption/hexes", 1},
	require = corrs_req1,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 10,
	radius = 2,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_PACIFICATION_HEX, 20, {power=self:combatSpellpower(), chance=self:combatTalentSpellDamage(t, 30, 50), apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Hexes your target, dazing it and everything in a 2 radius ball of it for 3 turns and giving %d%% chance to daze affected targets again each turn for 20 turns.
		The chance will increase with Magic stat.]]):format(self:combatTalentSpellDamage(t, 30, 50))
	end,
}

newTalent{
	name = "Burning Hex",
	type = {"corruption/hexes", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 10,
	radius = 2,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_BURNING_HEX, 20, {src=self, dam=self:spellCrit(self:combatTalentSpellDamage(t, 4, 90)), power=1+(self:getTalentLevel(t) / 10), apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Hexes your target and everything within a radius 2 ball of your target for 20 turns. Each time your affected targets use a resource (stamina, mana, vim, ...) they take %0.2f fire damage.
		In addition the affected talent will have its cooldown increased by 1 turn + %d%%.
		The damage will increase with Magic stat.]]):format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 4, 90)), ((self:getTalentLevel(t) / 10))*100)
	end,
}

newTalent{
	name = "Empathic Hex",
	type = {"corruption/hexes", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 10,
	radius = 2,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_EMPATHIC_HEX, 20, {power=self:combatTalentSpellDamage(t, 4, 20), apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Hexes your target and everything within a radius 2 ball of your target. Each time they do damage they take %d%% of the same damage for 20 turns.
		The damage will increase with Magic stat.]]):format(self:combatTalentSpellDamage(t, 4, 20))
	end,
}

newTalent{
	name = "Domination Hex",
	type = {"corruption/hexes", 4},
	require = corrs_req4,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 10,
	no_npc_use = true,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			if target:canBe("instakill") then
				target:setEffect(target.EFF_DOMINATION_HEX, 2 + self:getTalentLevel(t), {src=self, apply_power=self:combatSpellpower()})
			end
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Hexes your target, forcing it to be your thrall for %d turns.
		If you damage the target it will be free from the hex.]]):format(2 + self:getTalentLevel(t))
	end,
}
