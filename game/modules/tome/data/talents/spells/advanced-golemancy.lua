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
	name = "Mana Tap",
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
	name = "Life Tap", short_name = "GOLEMANCY_LIFE_TAP",
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
	name = "Gem Golem",
	type = {"spell/advanced-golemancy",3},
	require = spells_req3,
	points = 5,
	mana = 10,
	cooldown = 20,
	no_npc_use = true,
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
	name = "Runic Golem",
	type = {"spell/advanced-golemancy",4},
	require = spells_req_high4,
	mode = "passive",
	points = 5,
	no_npc_use = true,
	on_learn = function(self, t)
		self.alchemy_golem.life_regen = self.alchemy_golem.life_regen + 1
		self.alchemy_golem.mana_regen = self.alchemy_golem.mana_regen + 1
		self.alchemy_golem.stamina_regen = self.alchemy_golem.stamina_regen + 1
		local lev = self:getTalentLevelRaw(t)
		if lev == 1 or lev == 3 or lev == 5 then
			self.alchemy_golem.max_inscriptions = self.alchemy_golem.max_inscriptions + 1
			self.alchemy_golem.inscriptions_slots_added = self.alchemy_golem.inscriptions_slots_added + 1
		end
	end,
	on_unlearn = function(self, t)
		self.alchemy_golem.life_regen = self.alchemy_golem.life_regen - 1
		self.alchemy_golem.mana_regen = self.alchemy_golem.mana_regen - 1
		self.alchemy_golem.stamina_regen = self.alchemy_golem.stamina_regen - 1
		local lev = self:getTalentLevelRaw(t)
		if lev == 0 or lev == 2 or lev == 4 then
			self.alchemy_golem.max_inscriptions = self.alchemy_golem.max_inscriptions - 1
			self.alchemy_golem.inscriptions_slots_added = self.alchemy_golem.inscriptions_slots_added - 1
		end
	end,
	info = function(self, t)
		return ([[Increases your golem's life, mana and stamina regeneration rates by %0.2f.
		At level 1, 3 and 5 the golem also gains a new rune slot.]]):
		format(self:getTalentLevelRaw(t))
	end,
}
