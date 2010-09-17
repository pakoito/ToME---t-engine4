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
	name = "Pacification Hex",
	type = {"corruption/hexes", 1},
	require = corrs_req1,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 30,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
				target:setEffect(target.EFF_PACIFICATION_HEX, 20, {chance=self:combatTalentSpellDamage(t, 30, 50)})
			end
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Hexes your target, dazing it for 3 turns and giving %d%% chance to daze it again each turn.
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
	range = 30,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
				target:setEffect(target.EFF_BURNING_HEX, 20, {src=self, dam=self:combatTalentSpellDamage(t, 4, 90)})
			end
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Hexes your target, each time it uses a ressource(stamina, mana, vim, ...) it takes %0.2f fire damage.
		The damage will increase with Magic stat.]]):format(self:combatTalentSpellDamage(t, 4, 90))
	end,
}

newTalent{
	name = "Empathic Hex",
	type = {"corruption/hexes", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 30,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
				target:setEffect(target.EFF_EMPATHIC_HEX, 20, {power=self:combatTalentSpellDamage(t, 4, 20)})
			end
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Hexes your target, each time it does damage it takes %d%% of the same damage.
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
	range = 30,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 25) then
				target:setEffect(target.EFF_DOMINATION_HEX, 2 + self:getTalentLevel(t), {faction=self.faction})
			end
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Hexes your target, forcing it to be your thrall for %d turns.]]):format(2 + self:getTalentLevel(t))
	end,
}
