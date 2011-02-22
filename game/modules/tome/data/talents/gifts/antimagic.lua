-- ToME - Tales of Maj'Eyal
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

		if not self:isTalentActive(self.T_ANTIMAGIC_SHIELD) then
			local equi = 1 + self:combatTalentMindDamage(t, 10, 5)
			local stamina = 1 + self:combatTalentMindDamage(t, 10, 10)
			self:incEquilibrium(-equi)
			self:incStamina(stamina)
		end
		self:setEffect(self.EFF_RESOLVE, 7, {damtype=damtype, res=self:combatTalentMindDamage(t, 10, 40)})
		game.logSeen(self, "%s is invigorated by the attack!", self.name:capitalize())
	end,
	info = function(self, t)
		return ([[You stand in the way of magical damage. That which does not kill you makes you stronger.
		Each time you are hit by a magical damage you get a %d%% resistance to this elemental for 7 turns.
		If antimagic shield is not active you also absorb part of the impact and use it to fuel your own powers, decreasing your equilibrium by %d and increasing your stamina by %d.
		The effects will increase with your Willpower stat.]]):
		format(
			self:combatTalentMindDamage(t, 10, 40),
			1 + self:combatTalentMindDamage(t, 10, 5),
			1 + self:combatTalentMindDamage(t, 10, 10)
		)
	end,
}

newTalent{
	name = "Aura of Silence",
	type = {"wild-gift/antimagic", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 20,
	cooldown = 10,
	tactical = { DISABLE = 4 },
	radius = function(self, t) return 4 + self:getTalentLevel(t) * 1.5 end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=true, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
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
	range = 10,
	tactical = { DEFEND = 2 },
	on_damage = function(self, t, damtype, dam)
		if not DamageType:get(damtype).antimagic_resolve then return dam end

		if dam <= self.antimagic_shield then
			self:incEquilibrium(dam / 30)
			dam = 0
		else
			self:incEquilibrium(self.antimagic_shield / 30)
			dam = dam - self.antimagic_shield
		end

		if not self:equilibriumChance() then
			self:forceUseTalent(self.T_ANTIMAGIC_SHIELD, {ignore_energy=true})
			game.logSeen(self, "#GREEN#The antimagic shield of %s crumbles.", self.name)
		end
		return dam
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		return {
			am = self:addTemporaryValue("antimagic_shield", self:combatTalentMindDamage(t, 20, 80)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("antimagic_shield", p.am)
		return true
	end,
	info = function(self, t)
		return ([[Surround yourself with a shield that will absorb at most %d magical or elemental damage per attack.
		Each time damage is absorbed your equilibrium increases by 1 for every 30 points of damage and a check is made, if it fails the shield will crumble.
		Damage shield can absorb will increase with your Willpower stat.]]):
		format(self:combatTalentMindDamage(t, 20, 80))
	end,
}

newTalent{
	name = "Mana Clash",
	type = {"wild-gift/antimagic", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 10,
	cooldown = 10,
	range = 10,
	tactical = { ATTACK = 3 },
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			local base = self:combatTalentMindDamage(t, 20, 230)
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
		local base = self:combatTalentMindDamage(t, 20, 230)
		local mana = base * 2
		local vim = base
		local positive = base / 2
		local negative = base / 2

		return ([[Drain %d mana, %d vim, %d positive and negative energies from your target, triggering a chain reaction that explodes in a burst of arcane damage.
		The damage done is 130%% of the mana drained, 260%% of the vim drained, 520%% of the positive or negative energy drained, whichever is higher.
		The effect will increase with your Willpower stat.]]):
		format(mana, vim, positive, negative)
	end,
}
