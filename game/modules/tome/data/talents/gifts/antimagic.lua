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
	name = "Resolve",
	type = {"wild-gift/antimagic", 1},
	require = gifts_req1,
	mode = "passive",
	points = 5,
	on_absorb = function(self, t, damtype)
		if not DamageType:get(damtype).antimagic_resolve then return end

		local equi = math.ceil(2 + self:getTalentLevel(t) * 1.5)
		local stamina = math.ceil(3 + self:getTalentLevel(t) * 1.6)
		self:incEquilibrium(-equi)
		self:incStamina(stamina)
		self:setEffect(self.EFF_RESOLVE, 7, {damtype=damtype, res=10 + self:getTalentLevel(t) * self:getWil() * 0.06})
		game.logSeen(self, "%s is invigorated by the attack!", self.name:capitalize())
	end,
	info = function(self, t)
		return ([[You stand in the way of magical damage. That which does not kill you makes you stronger.
		Each time you are hit by a magical damage you get a %d%% resistance to this elemental for 7 turns.
		You also absorb part of the impact and use it to fuel your own powers, decreasing your equilibrium by %d and increasing your stamina by %d.]]):
		format(10 + self:getTalentLevel(t) * self:getWil() * 0.06, math.ceil(2 + self:getTalentLevel(t) * 1.5), math.ceil(3 + self:getTalentLevel(t) * 1.6))
	end,
}

newTalent{
	name = "Aura of Silence",
	type = {"wild-gift/antimagic", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 20,
	cooldown = 12,
	range = function(self, t) return 4 + self:getTalentLevel(t) * 2 end,
	action = function(self, t)
		local tg = {type="ball", range=0, radius=self:getTalentRange(t), friendlyfire=true, talent=t}
		self:project(tg, self.x, self.y, DamageType.SILENCE, 3 + math.floor(self:getTalentLevel(t) / 2))
		return true
	end,
	info = function(self, t)
		return ([[Let out a burst of sound that silences for %d turns all those affected, including the user.
		The silence chance will increase with your Willpower stat.]]):
		format(3 + math.floor(self:getTalentLevel(t) / 2))
	end,
}

newTalent{
	name = "Antimagic Shield",
	type = {"wild-gift/antimagic", 3},
	require = gifts_req3,
	mode = "sustained",
	points = 5,
	sustain_equilibrium = 30,
	cooldown = 20,
	range = 20,
	activate = function(self, t)
		game.logPlayer(self, "===================MAKE ME!")

		game:playSoundNear(self, "talents/heal")
		local power = 10 + 5 * self:getTalentLevel(t)
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.ACID]=power}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		return ([[Touch a target (or yourself) to infuse it with Nature, healing it for %d.
		The effect will increase with your Willpower stat.]]):
		format(20 + self:getWil(50) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Mana Clash",
	type = {"wild-gift/antimagic", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 10,
	cooldown = 10,
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			local base = 20 + self:getTalentLevel(t) * self:getWil() / 2.4
			local mana = base * 2
			local vim = base
			local positive = base / 2
			local negative = base / 2

			mana = math.min(target:getMana(), mana)
			vim = math.min(target:getVim(), vim)
			positive = math.min(target:getPositive(), positive)
			negative = math.min(target:getNegative(), negative)

			target:incMana(-mana)
			target:incVim(-vim)
			target:incPositive(-positive)
			target:incNegative(-negative)

			local dam = math.max(mana, vim * 2, positive * 4, negative * 4) * 1.3
			DamageType:get(DamageType.ARCANE).projector(self, px, py, DamageType.ARCANE, dam)
		end, nil, {type="slime"})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local base = 20 + self:getTalentLevel(t) * self:getWil() / 2.4
		local mana = base * 2
		local vim = base
		local positive = base / 2
		local negative = base / 2

		return ([[Drain %d mana, %d vim, %d positive and negative energies from your target, triggering a chain reaction that explodes in a burst of arcane damage.
		The damage done is 130%% of the mana drained, 260%% of the vim drained, 530%% of the positive or negative enrgy drained, whichever is higher.]]):
		format(mana, vim, positive, negative)
	end,
}
