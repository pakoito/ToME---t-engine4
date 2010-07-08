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

local function makeGolem()
	return require("mod.class.NPC").new{
		type = "construct", subtype = "golem",
		display = 'g', color=colors.WHITE,
		level_range = {1, 50},

		combat = { dam=10, atk=10, apr=0, dammod={str=1} },

		body = { INVEN = 50, MAINHAND=1, OFFHAND=1, BODY=1,},
		infravision = 20,
		rank = 3,
		size_category = 4,

		autolevel = "warrior",
		ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=4, ai_move="move_astar" },
		energy = { mod=1 },
		stats = { str=14, dex=12, mag=10, con=12 },

		no_auto_resists = true,
		open_door = true,
		blind_immune = 1,
		fear_immune = 1,
		see_invisible = 2,
		no_breath = 1,
	}
end

newTalent{
	name = "Refit Golem",
	type = {"spell/golemancy", 1},
	require = spells_req1,
	points = 1,
	action = function(self, t)
		if not self.alchemy_golem then
			self.alchemy_golem = game.zone:finishEntity(game.level, "actor", makeGolem())
			if not self.alchemy_golem then return end
			self.alchemy_golem.faction = self.faction
			self.alchemy_golem.summoner = self
			self.alchemy_golem.summoner_gain_exp = true
		end

		if game.level:hasEntity(self.alchemy_golem) then
		else
			-- Find space
			local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to summon!")
				return
			end
			game.zone:addEntity(game.level, self.alchemy_golem, "actor", x, y)
		end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Carve %d to %d alchemist gems out of natural gems.
		Alchemists gems are used for lots of other spells.]]):format(40, 80)
	end,
}

newTalent{
	name = "Golem: Taunt",
	type = {"spell/golemancy", 1},
	require = spells_req1,
	points = 5,
	range = function(self, t)
		return math.ceil(5 + self:getDex(12))
	end,
	computeDamage = function(self, t, ammo)
		local inc_dam = 0
		local damtype = DamageType.FIRE
		local particle = "ball_fire"
		if self:isTalentActive(self.T_ACID_INFUSION) then inc_dam = self:getTalentLevel(self.T_ACID_INFUSION) * 0.05; damtype = DamageType.ACID; particle = "ball_acid"
		elseif self:isTalentActive(self.T_LIGHTNING_INFUSION) then inc_dam = self:getTalentLevel(self.T_LIGHTNING_INFUSION) * 0.05; damtype = DamageType.LIGHTNING; particle = "ball_lightning"
		elseif self:isTalentActive(self.T_FROST_INFUSION) then inc_dam = self:getTalentLevel(self.T_FROST_INFUSION) * 0.05; damtype = DamageType.ICE; particle = "ball_ice"
		else inc_dam = self:getTalentLevel(self.T_FIRE_INFUSION) * 0.05
		end
		local dam = self:combatTalentSpellDamage(t, 15, 150, (ammo.alchemist_power + self:combatSpellpower()) / 2)
		dam = dam * (1 + inc_dam)
		return dam, damtype, particle
	end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo then
			game.logPlayer(self, "You need to ready alchemist gems in your quiver.")
			return
		end

		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT), talent=t}
		if tg.radius == 0 then tg.type = "hit" end
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		ammo = self:removeObject(self:getInven("QUIVER"), 1)
		if not ammo then return end

		local dam, damtype, particle = t.computeDamage(self, t, ammo)
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 0.2

		local grids = self:project(tg, x, y, function(tx, ty)
			-- Protect yourself
			local d = dam
			if tx == self.x and ty == self.y then d = dam * (1 - prot) end
			DamageType:get(damtype).projector(self, tx, ty, damtype, self:spellCrit(d))
		end)

		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, particle, {radius=tg.radius, grids=grids, tx=x, ty=y})

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		local dam, damtype = 1, DamageType.FIRE
		if ammo then dam, damtype = t.computeDamage(self, t, ammo) end
		return ([[Imbue an alchemist gem with an explosive charge of mana and throw it.
		The gem will explode for %0.2f %s damage.
		The damage will improve with better gems and Magic stat and the range with your dexterity.]]):format(dam, DamageType:get(damtype).name)
	end,
}

newTalent{
	name = "Golem: Knockback",
	type = {"spell/golemancy", 2},
	require = spells_req2,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[Your alchemist bombs now affect a radius of %d around them.]]):format(self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Golem: Crush",
	type = {"spell/golemancy", 3},
	require = spells_req3,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 3
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 3
		self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 3
		self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 3
	end,
	on_unlearn = function(self, t)
		self.resists[DamageType.FIRE] = self.resists[DamageType.FIRE] - 3
		self.resists[DamageType.COLD] = self.resists[DamageType.COLD] - 3
		self.resists[DamageType.LIGHTNING] = self.resists[DamageType.LIGHTNING] - 3
		self.resists[DamageType.ACID] = self.resists[DamageType.ACID] - 3
	end,
	info = function(self, t)
		return ([[Improves your resistance against your own bombs elemental damage by %d%% and against external one byt %d%%.]]):
		format(self:getTalentLevelRaw(t) * 20, self:getTalentLevelRaw(t) * 3)
	end,
}

newTalent{
	name = "Invoke Golem",
	type = {"spell/golemancy",4},
	require = spells_req4,
	points = 5,
	action = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Carve %d to %d alchemist gems out of muliple natural gems, combining their powers.
		Alchemists gems are used for lots of other spells.]]):format(40, 80)
	end,
}
