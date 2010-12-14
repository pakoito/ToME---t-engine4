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
	name = "Golem Power",
	type = {"spell/advanced-golemancy", 1},
	mode = "passive",
	require = spells_req_high1,
	points = 5,
	on_learn = function(self, t)
		self.alchemy_golem:learnTalent(Talents.T_WEAPON_COMBAT, true)
		self.alchemy_golem:learnTalent(Talents.T_WEAPONS_MASTERY, true)
	end,
	on_unlearn = function(self, t)
		self.alchemy_golem:unlearnTalent(Talents.T_WEAPON_COMBAT, true)
		self.alchemy_golem:unlearnTalent(Talents.T_WEAPONS_MASTERY, true)
	end,
	info = function(self, t)
		local attack = self:getTalentFromId(Talents.T_WEAPON_COMBAT).getAttack(self, t)
		local damage = self:getTalentFromId(Talents.T_WEAPONS_MASTERY).getDamage(self, t)
		return ([[Improves your golem proficiency with weapons. Increasing its attack by %d and damage by %d%%.]]):
		format(attack, 100 * damage)
	end,
}

newTalent{
	name = "Golem Resilience",
	type = {"spell/advanced-golemancy", 2},
	mode = "passive",
	require = spells_req_high2,
	points = 5,
	on_learn = function(self, t)
		self.alchemy_golem:learnTalent(Talents.T_HEALTH, true)
		self.alchemy_golem:learnTalent(Talents.T_HEAVY_ARMOUR_TRAINING, true)
		self.alchemy_golem:learnTalent(Talents.T_MASSIVE_ARMOUR_TRAINING, true)
	end,
	on_unlearn = function(self, t)
		self.alchemy_golem:unlearnTalent(Talents.T_HEALTH, true)
		self.alchemy_golem:unlearnTalent(Talents.T_HEAVY_ARMOUR_TRAINING, true)
		self.alchemy_golem:unlearnTalent(Talents.T_MASSIVE_ARMOUR_TRAINING, true)
	end,
	info = function(self, t)
		local health = self:getTalentFromId(Talents.T_HEALTH).getHealth(self, t)
		local heavyarmor = self:getTalentFromId(Talents.T_HEAVY_ARMOUR_TRAINING).getArmor(self, t)
		local massivearmor = self:getTalentFromId(Talents.T_MASSIVE_ARMOUR_TRAINING).getArmor(self, t)
		return ([[Improves your golem armour training and health. Increases armor by %d when wearing heavy armor or by %d when wearing massive armor also increases health by %d.]]):
		format(heavyarmor, massivearmor, health)
	end,
}

newTalent{
	name = "Golem: Pound",
	type = {"spell/advanced-golemancy", 3},
	require = spells_req_high3,
	points = 5,
	cooldown = 15,
	range = 10,
	mana = 5,
	requires_target = true,
	no_npc_use = true,
	getGolemDamage = function(self, t)
		local damage = 0
		if self.alchemy_golem then
			local golem = getGolem(self)
			if golem then
				return golem:combatTalentWeaponDamage(t, 0.4, 1.1) 
			end
		end
		return damage
	end,
	getDazeDuration = function(self, t) return 2 + self:getTalentLevel(t) end,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "Your golem is currently inactive.")
			return
		end
		if mover:attr("never_move") then game.logPlayer(self, "Your golem can not do that currently.") return end

		local tg = {type="ball", radius=2, friendlyfire=false, range=self:getTalentRange(t)}
		game.target.source_actor = mover
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = self
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(mover.x, mover.y, x, y)) > self:getTalentRange(t) then return nil end

		local l = line.new(mover.x, mover.y, x, y)
		local lx, ly = l()
		local tx, ty = mover.x, mover.y
		lx, ly = l()
		while lx and ly do
			if game.level.map:checkAllEntities(lx, ly, "block_move", mover) then break end
			tx, ty = lx, ly
			lx, ly = l()
		end

		mover:move(tx, ty, true)

		-- Attack & daze
		golem:project({type="ball", radius=2, friendlyfire=false}, tx, ty, function(xx, yy)
			if xx == mover.x and yy == mover.y then return end
			local target = game.level.map(xx, yy, Map.ACTOR)
			if target and golem:attackTarget(target, nil, t.getGolemDamage(self, t), true) then
				if target:checkHit(golem:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 10 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
					target:setEffect(target.EFF_DAZED, t.getDazeDuration(self, t), {})
				else
					game.logSeen(target, "%s resists the dazing blow!", target.name:capitalize())
				end
			end
		end)

		return true
	end,
	info = function(self, t)
		local duration = t.getDazeDuration(self, t)
		local damage = t.getGolemDamage(self, t)
		return ([[Your golem rushes to the target, pounding the area of radius 2, dazing all foes for %d turns and doing %d%% damage.
		Daze chance increases with talent level.]]):
		format(duration, 100 * damage)
	end,
}

newTalent{
	name = "Mount Golem",
	type = {"spell/advanced-golemancy",4},
	require = spells_req_high4,
	points = 5,
	mana = 40,
	cooldown = 60,
	no_npc_use = true,
	getDuration = function(self, t) return 5 + math.ceil(self:getTalentLevel(t) * 4) end,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "Your golem is currently inactive.")
			return
		end
		if math.floor(core.fov.distance(self.x, self.y, golem.x, golem.y)) > 1 then
			game.logPlayer(self, "You are too far away from your golem.")
			return
		end

		-- Create the mount item
		local mount = game.zone:makeEntityByName(game.level, "object", "ALCHEMIST_GOLEM_MOUNT")
		if not mount then return end
		mount.mount.actor = golem
		self:setEffect(self.EFF_GOLEM_MOUNT, t.getDuration(self, t), {mount=mount})

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Mount inside your golem, directly controlling it for %d turns also golem absorb 75%% of the damage taken.]]):
		format(duration)
	end,
}
