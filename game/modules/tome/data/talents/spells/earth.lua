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

local Object = require "engine.Object"

newTalent{
	name = "Stone Skin",
	type = {"spell/earth", 1},
	mode = "sustained",
	require = spells_req1,
	points = 5,
	sustain_mana = 30,
	cooldown = 10,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		game:playSoundNear(self, "talents/earth")
		local power = self:combatTalentSpellDamage(t, 10, 20)
		return {
			armor = self:addTemporaryValue("combat_armor", power),
			particle = self:addParticles(Particles.new("stone_skin", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("combat_armor", p.armor)
		return true
	end,
	info = function(self, t)
		return ([[The caster's skin grows as hard as stone, granting %d bonus to armor.
		The bonus to armor will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 10, 20))
	end,
}

newTalent{
	name = "Dig",
	type = {"spell/earth",2},
	require = spells_req2,
	points = 5,
	random_ego = "utility",
	mana = 40,
	range = 20,
	reflectable = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t, display={particle="bolt_earth", trail="earthtrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		for i = 1, self:getTalentLevelRaw(t) do
			self:project(tg, x, y, DamageType.DIG, 1)
		end
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Digs up to %d grids into walls, trees or other impassable terrain]]):format(self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Strike",
	type = {"spell/earth",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 18,
	cooldown = 6,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	reflectable = true,
	proj_speed = 6,
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_earth", trail="earthtrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.SPELLKNOCKBACK, self:spellCrit(self:combatTalentSpellDamage(t, 8, 170)))
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a fist of stone doing %0.2f physical damage and knocking the target back.
		The damage will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 8, 170))
	end,
}

newTalent{
	name = "Stone Wall",
	type = {"spell/earth",4},
	require = spells_req4,
	points = 5,
	cooldown = 50,
	mana = 70,
	range = 20,
	reflectable = true,
	requires_target = function(self, t) return self:getTalentLevel(t) >= 4 end,
	action = function(self, t)
		local x, y = self.x, self.y
		if self:getTalentLevel(t) >= 4 then
			local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
			x, y = self:getTarget(tg)
			if not x or not y then return nil end
		end

		for i = -1, 1 do for j = -1, 1 do if game.level.map:isBound(x + i, y + j) then
			if not game.level.map:checkAllEntities(x + i, y + j, "block_move") then
				-- Ok some explanation, we make a new *OBJECT* because objects can have energy and act
				-- it stores the current terrain in "old_feat" and restores it when it expires
				-- We CAN set an object as a terrain because they are all entities

				local e = Object.new{
					old_feat = game.level.map(x + i, y + j, Map.TERRAIN),
					name = "summoned wall", image = "terrain/granite_wall1.png",
					display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
					always_remember = true,
					can_pass = {pass_wall=1},
					block_move = true,
					block_sight = true,
					temporary = 2 + self:combatTalentSpellDamage(t, 5, 12),
					x = x + i, y = y + j,
					canAct = false,
					act = function(self)
						self:useEnergy()
						self.temporary = self.temporary - 1
						if self.temporary <= 0 then
							game.level.map(self.x, self.y, Map.TERRAIN, self.old_feat)
							game.level:removeEntity(self)
							game.level.map:redisplay()
						end
					end,
					dig = function(src, x, y, old)
						game.level:removeEntity(old)
						game.level.map:redisplay()
						return nil, old.old_feat
					end,
					summoner_gain_exp = true,
					summoner = self,
				}
				game.level:addEntity(e)
				game.level.map(x + i, y + j, Map.TERRAIN, e)
			end
		end end end

		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Entomb yourself in a wall of stone for %d turns.
		At level 4 it becomes targettable.]]):format(2 + self:combatSpellpower(0.03) * self:getTalentLevel(t))
	end,
}
