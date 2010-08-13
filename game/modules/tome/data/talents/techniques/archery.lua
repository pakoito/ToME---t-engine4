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

-- Default archery attack
newTalent{
	name = "Shoot",
	type = {"technique/archery-base", 1},
	no_energy = true,
	hide = true,
	points = 1,
	range = 20,
	message = "@Source@ shoots!",
	action = function(self, t)
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t)
		return true
	end,
	info = function(self, t)
		return ([[Shoot your bow or sling!]])
	end,
}

newTalent{
	name = "Steady Shot",
	type = {"technique/archery-training", 1},
	no_energy = true,
	points = 5,
	random_ego = "attack",
	cooldown = 3,
	stamina = 8,
	require = techs_dex_req1,
	range = 20,
	action = function(self, t)
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1.1, 2.2)})
		return true
	end,
	info = function(self, t)
		return ([[A steady shot, doing %d%% damage.]]):format(self:combatTalentWeaponDamage(t, 1.1, 2.2) * 100)
	end,
}

newTalent{
	name = "Aim",
	type = {"technique/archery-training", 2},
	mode = "sustained",
	points = 5,
	require = techs_dex_req2,
	cooldown = 30,
	sustain_stamina = 50,
	activate = function(self, t)
		local weapon = self:hasArcheryWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Aim without a bow or sling!")
			return nil
		end

		return {
			move = self:addTemporaryValue("never_move", 1),
			speed = self:addTemporaryValue("combat_physspeed", self:combatSpeed(weapon.combat) - 1 / (1 + self:getTalentLevel(t) * 0.1)),
			crit = self:addTemporaryValue("combat_physcrit", 7 + self:getTalentLevel(t) * self:getDex(10)),
			atk = self:addTemporaryValue("combat_dam", 4 + self:getTalentLevel(t) * self:getDex(10)),
			dam = self:addTemporaryValue("combat_atk", 4 + self:getTalentLevel(t) * self:getDex(10)),
			apr = self:addTemporaryValue("combat_apr", 3 + self:getTalentLevel(t) * self:getDex(10)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("never_move", p.move)
		self:removeTemporaryValue("combat_physspeed", p.speed)
		self:removeTemporaryValue("combat_physcrit", p.crit)
		self:removeTemporaryValue("combat_apr", p.apr)
		self:removeTemporaryValue("combat_atk", p.atk)
		self:removeTemporaryValue("combat_dam", p.dam)
		return true
	end,
	info = function(self, t)
		return ([[You enter a calm, focused stance, increasing your damage(+%d), attack(+%d), armor peneration(+%d), and critical chance(+%d%%) but reducing your firing speed by %d%% and making you unable to move.]]):
		format(4 + self:getTalentLevel(t) * self:getDex(10), 4 + self:getTalentLevel(t) * self:getDex(10),
		3 + self:getTalentLevel(t) * self:getDex(10), 7 + self:getTalentLevel(t) * self:getDex(10),
		self:getTalentLevelRaw(t) * 10)
	end,
}

newTalent{
	name = "Rapid Shot",
	type = {"technique/archery-training", 3},
	mode = "sustained",
	points = 5,
	require = techs_dex_req3,
	cooldown = 30,
	sustain_stamina = 50,
	activate = function(self, t)
		local weapon = self:hasArcheryWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Aim without a bow or sling!")
			return nil
		end

		return {
			speed = self:addTemporaryValue("combat_physspeed", -self:combatSpeed(weapon.combat) + 1 / (1 + self:getTalentLevel(t) * 0.09)),
			atk = self:addTemporaryValue("combat_dam", -8 - self:getTalentLevelRaw(t) * 2.4),
			dam = self:addTemporaryValue("combat_atk", -8 - self:getTalentLevelRaw(t) * 2.4),
			crit = self:addTemporaryValue("combat_physcrit", -8 - self:getTalentLevelRaw(t) * 2.4),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physspeed", p.speed)
		self:removeTemporaryValue("combat_physcrit", p.crit)
		self:removeTemporaryValue("combat_dam", p.dam)
		self:removeTemporaryValue("combat_atk", p.atk)
		return true
	end,
	info = function(self, t)
		return ([[You switch to a fluid and fast battle stance, increasing your firing speed by %d%% at the cost of your accuracy(%d), damage(%d), and critical chance(%d).]]):
		format(self:getTalentLevelRaw(t) * 9, -8 - self:getTalentLevelRaw(t) * 2.4, -8 - self:getTalentLevelRaw(t) * 2.4, -8 - self:getTalentLevelRaw(t) * 2.4)
	end,
}

newTalent{
	name = "Critical Shot",
	type = {"technique/archery-training", 4},
	no_energy = true,
	points = 5,
	random_ego = "attack",
	cooldown = 14,
	stamina = 35,
	require = techs_dex_req4,
	range = 20,
	action = function(self, t)
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1.2, 2), crit_chance=1000})
		return true
	end,
	info = function(self, t)
		return ([[You concentrate on your aim to produce a guaranted critical hit (with a base damage of %d%%).]]):format(self:combatTalentWeaponDamage(t, 1.2, 2) * 100)
	end,
}

-------------------------------- Utility -----------------------------------

newTalent{
	name = "Ammo Creation",
	type = {"technique/archery-utility", 1},
	no_energy = true,
	points = 5,
	cooldown = 200,
	stamina = 30,
	require = techs_dex_req1,
	action = function(self, t)
		if not self:getInven("MAINHAND") then return nil end
		local weapon = self:getInven("MAINHAND")[1]
		if not weapon or not weapon.archery then
			game.logPlayer("You must wield your archery weapon to forage.")
			return nil
		end

		local st = "arrow"
		if weapon.archery == "sling" then st = "shot" end
		local ego = math.ceil(5 + (self:getTalentLevel(t) * 5))

		local o = game.zone:makeEntity(game.level, "object", {type="ammo", subtype=st, ego_chance=ego}, nil, true)
		if o and rng.percent(10 + self:getTalentLevel(t) * 10) then
			o:identify(true)
			o:forAllStack(function(so) so.cost = 0 end)
			self:addObject(self.INVEN_INVEN, o)
			game.zone:addEntity(game.level, o, "object")
			game.logPlayer(self, "You create some ammo: %s", o:getName())
		else
			game.logPlayer(self, "You found nothing!")
		end
		return true
	end,
	info = function(self, t)
		return ([[Forage in your immediate environment to try to make ammo for your current weapon.
		There is an additional %d%% chance to get exceptional ammo.]]):format(math.ceil(5 + (self:getTalentLevel(t) * 5)))
	end,
}

newTalent{
	name = "Crippling Shot",
	type = {"technique/archery-utility", 2},
	no_energy = true,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 15,
	require = techs_dex_req2,
	range = 20,
	archery_onhit = function(self, t, target, x, y)
		if target:checkHit(self:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 10) then
			target:setEffect(target.EFF_SLOW, 7, {power=util.bound((self:combatAttack() * 0.15 * self:getTalentLevel(t)) / 100, 0.1, 0.4)})
		else
			game.logSeen(target, "%s resists!", target.name:capitalize())
		end
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.5)})
		return true
	end,
	info = function(self, t)
		return ([[You fire a crippling shot, doing %d%% damage and reducing your target's speed by %0.2f for 7 turns.]]):format(self:combatTalentWeaponDamage(t, 1, 1.5) * 100, util.bound((5 + 5 * self:getTalentLevel(t)) / 100, 0.1, 0.4))
	end,
}

newTalent{
	name = "Pinning Shot",
	type = {"technique/archery-utility", 3},
	no_energy = true,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 15,
	require = techs_dex_req3,
	range = 20,
	archery_onhit = function(self, t, target, x, y)
		if target:checkHit(self:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 10) and target:canBe("pin") then
			target:setEffect(target.EFF_PINNED, 2 + self:getTalentLevelRaw(t), {})
		else
			game.logSeen(target, "%s resists!", target.name:capitalize())
		end
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.4)})
		return true
	end,
	info = function(self, t)
		return ([[You fire a pinning shot, doing %d%% damage and pinning your target to the ground for %d turns.]]):format(self:combatTalentWeaponDamage(t, 1, 1.4) * 100, 2 + self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Scatter Shot",
	type = {"technique/archery-utility", 4},
	no_energy = true,
	points = 5,
	random_ego = "attack",
	cooldown = 14,
	stamina = 15,
	require = techs_dex_req4,
	range = 20,
	archery_onhit = function(self, t, target, x, y)
		if target:checkHit(self:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 10) then
			target:setEffect(target.EFF_STUNNED, 2 + self:getTalentLevelRaw(t), {})
		else
			game.logSeen(target, "%s resists!", target.name:capitalize())
		end
	end,
	action = function(self, t)
		local tg = {type="ball", radius=1 + self:getTalentLevel(t) / 3}
		local targets = self:archeryAcquireTargets(tg, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, tg, {mult=self:combatTalentWeaponDamage(t, 0.5, 1.5)})
		return true
	end,
	info = function(self, t)
		return ([[You fire multiple shots at the area, doing %d%% damage and stunning your targets for %d turns.]]):format(self:combatTalentWeaponDamage(t, 0.5, 1.5) * 100, 2 + self:getTalentLevelRaw(t))
	end,
}
