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
	name = "Golem Power2",
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
	name = "Golem Resilience2",
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
	name = "Invoke Golem2",
	type = {"spell/advanced-golemancy",3},
	require = spells_req3,
	points = 5,
	mana = 10,
	cooldown = 20,
	no_npc_use = true,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 15, 50) end,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "Your golem is currently inactive.")
			return
		end

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to invoke!")
			return
		end

		golem:setEffect(golem.EFF_MIGHTY_BLOWS, 5, {power=t.getPower(self, t)})
		if golem == mover then
			golem:move(x, y, true)
		end
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		power=t.getPower(self, t)
		return ([[You invoke your golem to your side, granting it a temporary melee power increase of %d for 5 turns.]]):
		format(power)
	end,
}

newTalent{
	name = "Mount Golem2",
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
