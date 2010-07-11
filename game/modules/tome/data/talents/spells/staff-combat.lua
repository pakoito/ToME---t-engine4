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
		local weapon = self:hasStaffWeapon()
		if not weapon then
			game.logPlayer(self, "You need a staff to use this spell.")
			return
		end

		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		self.combat_apr = self.combat_apr + 10000
		self.combat_atk = self.combat_atk + 10000
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 0.4, 1.1))
		self.combat_atk = self.combat_atk - 10000
		self.combat_apr = self.combat_apr - 10000
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
		local weapon = self:hasStaffWeapon()
		if not weapon then
			game.logPlayer(self, "You need a staff to use this spell.")
			return
		end

		local power = self:combatTalentSpellDamage(t, 10, 20)
		game:playSoundNear(self, "talents/arcane")
		return {
			dam = self:addTemporaryValue("combat_dam", -power / 2),
			def = self:addTemporaryValue("combat_def", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_dam", p.dam)
		self:removeTemporaryValue("combat_def", p.def)
		return true
	end,
	info = function(self, t)
		return ([[Adopt a defensive posture, reducing your staff attack power by %d and increasing your defense by %d.]]):
		format(self:combatTalentSpellDamage(t, 10, 20) / 2, self:combatTalentSpellDamage(t, 10, 20))
	end,
}

newTalent{
	name = "Blunt Thrust",
	type = {"spell/staff-combat",4},
	require = spells_req4,
	points = 5,
	mana = 30,
	cooldown = 6,
	tactical = {
		ATTACK = 10,
	},
	action = function(self, t)
		local weapon = self:hasStaffWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Stunning Blow without a two-handed weapon!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.5))

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttackStr(weapon.combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, 4 + self:getTalentLevel(t), {})
			else
				game.logSeen(target, "%s resists the dazing blow!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hit a target for %d%% melee damage and daze it for %d turns.]]):format(100 * self:combatTalentWeaponDamage(t, 1, 1.5), 4 + self:getTalentLevel(t))
	end,
}
