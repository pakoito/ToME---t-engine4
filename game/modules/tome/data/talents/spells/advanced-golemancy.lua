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
	require = spells_req1,
	points = 5,
	on_learn = function(self, t)
		self.alchemy_golem:learnTalent(self.T_WEAPON_COMBAT, true)
		self.alchemy_golem:learnTalent(self.T_WEAPONS_MASTERY, true)
	end,
	on_unlearn = function(self, t)
		self.alchemy_golem:unlearnTalent(self.T_WEAPON_COMBAT, true)
		self.alchemy_golem:unlearnTalent(self.T_WEAPONS_MASTERY, true)
	end,
	info = function(self, t)
		return ([[Improves your golem proficiency with two handed weapons.]])
	end,
}

newTalent{
	name = "Golem Resilience",
	type = {"spell/advanced-golemancy", 2},
	mode = "passive",
	require = spells_req2,
	points = 5,
	on_learn = function(self, t)
		self.alchemy_golem:learnTalent(self.T_HEALTH, true)
		self.alchemy_golem:learnTalent(self.T_HEAVY_ARMOUR_TRAINING, true)
		self.alchemy_golem:learnTalent(self.T_MASSIVE_ARMOUR_TRAINING, true)
	end,
	on_unlearn = function(self, t)
		self.alchemy_golem:unlearnTalent(self.T_HEALTH, true)
		self.alchemy_golem:unlearnTalent(self.T_HEAVY_ARMOUR_TRAINING, true)
		self.alchemy_golem:unlearnTalent(self.T_MASSIVE_ARMOUR_TRAINING, true)
	end,
	info = function(self, t)
		return ([[Improves your golem armour training and health.]])
	end,
}

newTalent{
	name = "Golem: Pound",
	type = {"spell/advanced-golemancy", 3},
	require = spells_req3,
	points = 5,
	cooldown = 15,
	range = 10,
	mana = 5,
	requires_target = true,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "Your golem is currently inactive.")
			return
		end

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
			local target = game.level.map(xx, yy, Map.ACTOR)
			if target and golem:attackTarget(target, nil, golem:combatTalentWeaponDamage(t, 0.4, 1.1), true) then
				if target:checkHit(golem:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 10 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
					target:setEffect(target.EFF_DAZED, 2 + self:getTalentLevel(t), {})
				else
					game.logSeen(target, "%s resists the dazing blow!", target.name:capitalize())
				end
			end
		end)

		return true
	end,
	info = function(self, t)
		return ([[Your golem rushes to the target, pounding the area, dazing all for %d turns and doing %d%% damage.]]):
		format(2 + self:getTalentLevel(t), 100 * self:combatTalentWeaponDamage(t, 0.4, 1.1))
	end,
}

newTalent{
	name = "Mount Golem",
	type = {"spell/advanced-golemancy",4},
	require = spells_req4,
	points = 5,
	mana = 40,
	cooldown = 60,
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
		self:setEffect(self.EFF_GOLEM_MOUNT, 5 + math.ceil(self:getTalentLevel(t) * 4), {mount=mount})

		return true
	end,
	info = function(self, t)
		return ([[Mount inside your golem, directly controlling it and splitting the damage between it and yourself for %d turns.]]):
		format(5 + math.ceil(self:getTalentLevel(t) * 4))
	end,
}
