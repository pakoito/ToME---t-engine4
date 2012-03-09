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
	name = "Eldritch Blow",
	type = {"spell/arcane-shield", 1},
	require = spells_req1,
	points = 5,
	equilibrium = 3,
	mana = 10,
	cooldown = 6,
	range = 1,
	tactical = { ATTACK = { ARCANE = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	on_pre_use = function(self, t, silent) local shield = self:hasShield() if not shield then if not silent then game.logPlayer(self, "You cannot use Eldricth Blow without a shield!") end return false end return true end,
	action = function(self, t)
		local shield = self:hasShield()

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- First attack with both weapon & shield (since we have the Stoneshield talent)
		local hit = self:attackTarget(target, DamageType.ARCANE, self:combatTalentWeaponDamage(t, 0.6, (100 + self:combatTalentSpellDamage(t, 50, 300)) / 100), true)

		-- Try to stun !
		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2 + math.floor(self:getTalentLevel(t) / 2), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s resists the stun!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Channel eldritch forces in your attack, hitting the target with your weapon and shield doing %d%% arcane damage.
		If the any of the attacks hit, the target is stunned for %d turns.
		The stun is considered a magical attack and thus is resisted with spell save, not physical save.]])
		:format(100 * self:combatTalentWeaponDamage(t, 0.6, (100 + self:combatTalentSpellDamage(t, 50, 300)) / 100), 2 + math.floor(self:getTalentLevel(t) / 2))
	end,
}

newTalent{
	name = "Eldritch Infusion",
	type = {"spell/arcane-shield", 2},
	require = spells_req2,
	points = 5,
	mode = "sustained",
	sustain_equilibrium = 15,
	sustain_mana = 15,
	cooldown = 30,
	tactical = { ATTACK = 3, BUFF = 2 },
	activate = function(self, t)
		local power = 5 * self:getTalentLevel(t) + (self:getWil() + self:getMag()) / 5
		return {
			onhit = self:addTemporaryValue("melee_project", {[DamageType.ARCANE]=power}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("melee_project", p.onhit)
		return true
	end,
	info = function(self, t)
		return ([[Imbues your weapon with arcane power, dealing %0.2f arcane damage with each attacks.
		The damage will increase with Willpower and Magic stats.]]):format(damDesc(self, DamageType.ARCANE, 5 * self:getTalentLevel(t) + (self:getWil() + self:getMag()) / 5))
	end,
}

newTalent{
	name = "Eldritch Fury",
	type = {"spell/arcane-shield", 3},
	require = spells_req3,
	points = 5,
	equilibrium = 20,
	mana = 30,
	cooldown = 12,
	requires_target = true,
	tactical = { ATTACK = { NATURE = 3 }, DISABLE = { stun = 1 } },
	range = 1,
	on_pre_use = function(self, t, silent) local shield = self:hasShield() if not shield then if not silent then game.logPlayer(self, "You cannot use Eldricth Fury without a shield!") end return false end return true end,
	action = function(self, t)
		local shield = self:hasShield()

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- First attack with both weapon & shield (since we have the Stoneshield talent)
		local hit1 = self:attackTarget(target, DamageType.NATURE, self:combatTalentWeaponDamage(t, 0.6, 1.6), true)
		local hit2 = self:attackTarget(target, DamageType.NATURE, self:combatTalentWeaponDamage(t, 0.6, 1.6), true)
		local hit3 = self:attackTarget(target, DamageType.NATURE, self:combatTalentWeaponDamage(t, 0.6, 1.6), true)

		-- Try to stun !
		if hit1 or hit2 or hit3 then
			if target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, 3 + math.floor(self:getTalentLevel(t)), {apply_power=self:combatPhysicalpower(), apply_save="combatSpellResist"})
			else
				game.logSeen(target, "%s resists the dazing blows!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Channel eldritch forces to speed up your attacks, hitting the target three times with your weapon and shield doing %d%% nature damage.
		If any of the attacks hit, the target is dazed for %d turns.
		The daze is considered a magical attack and thus is resisted with spell save, not physical save.]])
		:format(100 * self:combatTalentWeaponDamage(t, 0.6, 1.6), 3 + math.floor(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Eldritch Slam",
	type = {"spell/arcane-shield", 4},
	require = spells_req4,
	points = 5,
	equilibrium = 10,
	mana = 30,
	cooldown = 20,
	tactical = { ATTACKAREA = { PHYSICAL = 3 } },
	requires_target = true,
	range = 1,
	radius = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	on_pre_use = function(self, t, silent) local shield = self:hasShield() if not shield then if not silent then game.logPlayer(self, "You cannot use Eldritch Slam without a shield!") end return false end return true end,
	action = function(self, t)
		local shield = self:hasShield()

		local tg = {type="ball", radius=self:getTalentRadius(t)}
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or target == self then return end
			self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 1.3, 2.6))
		end)

		return true
	end,
	info = function(self, t)
		return ([[Slam your shield on the ground, doing %d%% damage in a radius of %d.]])
		:format(100 * self:combatTalentWeaponDamage(t, 1.3, 2.6), self:getTalentRadius(t))
	end,
}

