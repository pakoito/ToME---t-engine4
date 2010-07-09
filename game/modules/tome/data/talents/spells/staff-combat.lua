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
	name = "Channel Staff",
	type = {"spell/staff-combat", 1},
	require = spells_req1,
	points = 5,
	mana = 5,
	tactical = {
		ATTACK = 10,
	},
	range = 10,
	reflectable = true,
	action = function(self, t)
		local weapon = self:hasTwoStaffWeapon()
		if not weapon then
			game.logPlayer(self, "You need a staff to use this spell.")
			return
		end

		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:combatDamage(weapon) * self:combatTalentWeaponDamage(t, 0.4, 1.1)
		self:project(tg, x, y, weapon.combat.damtype or DamageType.ARCANE, self:spellCrit(dam), {type="manathrust"})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Channel raw mana through your staff, projecting a bolt your staff damage type doing %d%% staff damage.
		This attack always hits and ignores target armour.]]):
		format(self:combatTalentWeaponDamage(t, 0.4, 1.1) * 100)
	end,
}

newTalent{
	name = "Staff Mastery",
	type = {"spell/staff-combat", 2},
	mode = "passive",
	require = spells_req2,
	points = 5,
	info = function(self, t)
		return ([[Increases damage done with staves by %d%%.]]):format(100 * (math.sqrt(self:getTalentLevel(t) / 10)))
	end,
}

newTalent{
	name = "Defensive Posture",
	type = {"spell/staff-combat", 3},
	require = spells_req3,
	mode = "sustained",
	points = 5,
	sustain_mana = 80,
	cooldown = 30,
	tactical = {
		DEFEND = 20,
	},
	activate = function(self, t)
		local power = self:combatTalentSpellDamage(t, 10, 20)
		game:playSoundNear(self, "talents/arcane")
		return {
			power = self:addTemporaryValue("combat_def", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_def", p.power)
		return true
	end,
	info = function(self, t)
		return ([[Adopt a defensive posture, reducing your staff attack power by %d and increasing your defense by %d.
		The mana restored will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 20, 230))
	end,
}

newTalent{
	name = "Disruption Shield",
	type = {"spell/staff-combat",4},
	require = spells_req4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_mana = 150,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		local power = math.max(0.8, 3 - (self:combatSpellpower(1) * self:getTalentLevel(t)) / 280)
		self.disruption_shield_absorb = 0
		game:playSoundNear(self, "talents/arcane")
		return {
			shield = self:addTemporaryValue("disruption_shield", power),
			particle = self:addParticles(Particles.new("disruption_shield", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("disruption_shield", p.shield)
		self.disruption_shield_absorb = nil
		return true
	end,
	info = function(self, t)
		return ([[Uses mana instead of life to take damage. Uses %0.2f mana per damage point taken.
		If your mana is brought too low by the shield, it will de-activate and the chain reaction will release a deadly arcane explosion of the amount of damage absorbed.
		The damage to mana ratio increases with the Magic stat]]):format(math.max(0.8, 3 - (self:combatSpellpower(1) * self:getTalentLevel(t)) / 280))
	end,
}
