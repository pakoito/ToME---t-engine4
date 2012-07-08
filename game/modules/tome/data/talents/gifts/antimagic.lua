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
	name = "Resolve",
	type = {"wild-gift/antimagic", 1},
	require = gifts_req1,
	mode = "passive",
	points = 5,
	getRegen = function(self, t) return 1 + (self:combatTalentMindDamage(t, 1, 10) /10) end,
	getResist = function(self, t) return self:combatTalentMindDamage(t, 10, 40) end,
	on_absorb = function(self, t, damtype)
		if not DamageType:get(damtype).antimagic_resolve then return end

		if not self:isTalentActive(self.T_ANTIMAGIC_SHIELD) then
			self:incEquilibrium(-t.getRegen(self, t))
			self:incStamina(t.getRegen(self, t))
		end
		self:setEffect(self.EFF_RESOLVE, 7, {damtype=damtype, res=self:mindCrit(t.getResist(self, t))})
		game.logSeen(self, "%s is invigorated by the attack!", self.name:capitalize())
	end,
	info = function(self, t)
		local resist = t.getResist(self, t)
		local regen = t.getRegen(self, t)
		return ([[You stand in the way of magical damage. That which does not kill you makes you stronger.
		Each time you are hit by a magical damage you get a %d%% resistance to this elemental for 7 turns.
		If antimagic shield is not active you also absorb part of the impact and use it to fuel your own powers, decreasing your equilibrium and increasing your stamina by %0.2f.
		The effects will increase with your Mindpower.]]):
		format(	resist, regen )
	end,
}

newTalent{
	name = "Aura of Silence",
	type = {"wild-gift/antimagic", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 20,
	cooldown = 10,
	tactical = { DISABLE = { silence = 4 } },
	radius = function(self, t) return 4 + self:getTalentLevel(t) * 1.5 end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.SILENCE, {dur=3 + math.floor(self:getTalentLevel(t) / 2), power_check=self:combatMindpower()})
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		return ([[Let out a burst of sound that silences for %d turns all those affected in a radius of %d, including the user.
		The silence chance will increase with your Mindpower.]]):
		format(3 + math.floor(self:getTalentLevel(t) / 2), rad)
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
		Damage shield can absorb will increase with your Mindpower.]]):
		format(self:combatTalentMindDamage(t, 20, 80))
	end,
}

newTalent{
	name = "Mana Clash",
	type = {"wild-gift/antimagic", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 10,
	cooldown = 8,
	range = 10,
	tactical = { ATTACK = { ARCANE = 3 } },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			local base = self:mindCrit(self:combatTalentMindDamage(t, 20, 460))
			DamageType:get(DamageType.MANABURN).projector(self, px, py, DamageType.MANABURN, base)
		end, nil, {type="slime"})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local base = self:combatTalentMindDamage(t, 20, 460)
		local mana = base
		local vim = base / 2
		local positive = base / 4
		local negative = base / 4

		return ([[Drain %d mana, %d vim, %d positive and negative energies from your target, triggering a chain reaction that explodes in a burst of arcane damage.
		The damage done is equal to 100%% of the mana drained, 200%% of the vim drained, or 400%% of the positive or negative energy drained, whichever is higher.
		The effect will increase with your Mindpower.]]):
		format(mana, vim, positive, negative)
	end,
}
