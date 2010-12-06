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

local Trap = require "mod.class.Trap"

newTalent{
	name = "Glyph of Paralysis",
	type = {"divine/glyphs", 1},
	require = divi_req_high1,
	random_ego = "attack",
	points = 5,
	cooldown = 20,
	positive = -10,
	requires_target = true,
	range = function(self, t) return math.floor (self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = 3 + self:getTalentLevelRaw(t)
		local trap = Trap.new{
			name = "glyph of paralysis",
			type = "elemental", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD,
			dam = dam,
			canTrigger = function(self, x, y, who)
				if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
				return false
			end,
			triggered = function(self, x, y, who)
				who:setEffect(who.EFF_DAZED, self.dam, {})
				return true
			end,
			temporary = 5 + self:getTalentLevel(t),
			x = tx, y = ty,
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map:remove(self.x, self.y, engine.Map.TRAP)
					game.level:removeEntity(self)
				end
			end,
			summoner = self,
			summoner_gain_exp = true,
		}
		game.level:addEntity(trap)
		trap:identify(true)
		trap:setKnown(self, true)
		game.zone:addEntity(game.level, trap, "trap", tx, ty)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[You bind light in a glyph on the floor. All targets passing by will be dazed for %d turns.
		The glyph lasts for %d turns.]]):format(3 + self:getTalentLevelRaw(t), 5 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Glyph of Repulsion",
	type = {"divine/glyphs", 2},
	require = spells_req2,
	random_ego = "attack",
	points = 5,
	positive = -10,
	cooldown = 20,
	requires_target = true,
	range = function(self, t) return math.floor (self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = 15 + self:combatSpellpower(0.12) * self:getTalentLevel(t)
		local sp = self:combatSpellpower()
		local trap = Trap.new{
			name = "glyph of repulsion",
			type = "elemental", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD,
			dam = dam,
			canTrigger = function(self, x, y, who)
				if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
				return false
			end,
			triggered = function(self, x, y, who)
				local ox, oy = self.x, self.y
				local dir = util.getDir(who.x, who.y, who.old_x, who.old_y)
				self.x, self.y = util.coordAddDir(self.x, self.y, dir)
				self:project({type="hit",x=x,y=y}, x, y, engine.DamageType.SPELLKNOCKBACK, self.dam)
				self.x, self.y = ox, oy
				return true
			end,
			temporary = 5 + self:getTalentLevel(t),
			x = tx, y = ty,
			canAct = false,
			energy = {value=0},
			combatSpellpower = function(self) return self.sp end, sp = sp,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map:remove(self.x, self.y, engine.Map.TRAP)
					game.level:removeEntity(self)
				end
			end,
			summoner = self,
			summoner_gain_exp = true,
		}
		game.level:addEntity(trap)
		trap:identify(true)
		trap:setKnown(self, true)
		game.zone:addEntity(game.level, trap, "trap", tx, ty)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[You bind light in a glyph on the floor. All targets passing by will be hit by a blast of light doing %0.2f damage and knocked back.
		The glyph lasts for %d turns.
		The damage will increase with the Magic stat]]):format(15 + self:combatSpellpower(0.12) * self:getTalentLevel(t), 5 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Glyph of Explosion",
	type = {"divine/glyphs", 3},
	require = divi_req_high3,
	random_ego = "attack",
	points = 5,
	cooldown = 20,
	positive = -10,
	requires_target = true,
	range = function(self, t) return math.floor (self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = 15 + self:combatSpellpower(0.12) * self:getTalentLevel(t)
		local trap = Trap.new{
			name = "glyph of explosion",
			type = "elemental", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD,
			dam = dam,
			canTrigger = function(self, x, y, who)
				if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
				return false
			end,
			triggered = function(self, x, y, who)
				self:project({type="ball", x=x,y=y, radius=1}, x, y, engine.DamageType.LIGHT, self.dam, {type="light"})
				game.level.map:particleEmitter(x, y, 1, "sunburst", {radius=1, tx=x, ty=y})
				return true
			end,
			temporary = 5 + self:getTalentLevel(t),
			x = tx, y = ty,
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map:remove(self.x, self.y, engine.Map.TRAP)
					game.level:removeEntity(self)
				end
			end,
			summoner = self,
			summoner_gain_exp = true,
		}
		game.level:addEntity(trap)
		trap:identify(true)
		trap:setKnown(self, true)
		game.zone:addEntity(game.level, trap, "trap", tx, ty)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[You bind light in a glyph on the floor. All targets passing by will trigger a radius 1 blast of light doing %0.2f damage.
		The glyph lasts for %d turns.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.LIGHT, 15 + self:combatSpellpower(0.12) * self:getTalentLevel(t)), 5 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Glyph of Fatigue",
	type = {"divine/glyphs", 4},
	require = divi_req_high4,
	random_ego = "attack",
	points = 5,
	cooldown = 20,
	positive = -10,
	requires_target = true,
	range = function(self, t) return math.floor (self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = -1 + 1 / (1 + (self:getTalentLevel(t) * 0.07 + 0.2))
		local trap = Trap.new{
			name = "glyph of fatigue",
			type = "elemental", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD,
			dam = dam,
			canTrigger = function(self, x, y, who)
				if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
				return false
			end,
			triggered = function(self, x, y, who)
				who:setEffect(who.EFF_SLOW, 5, {power=-self.dam})
				return true
			end,
			temporary = 5 + self:getTalentLevel(t),
			x = tx, y = ty,
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map:remove(self.x, self.y, engine.Map.TRAP)
					game.level:removeEntity(self)
				end
			end,
			summoner = self,
			summoner_gain_exp = true,
		}
		game.level:addEntity(trap)
		trap:identify(true)
		trap:setKnown(self, true)
		game.zone:addEntity(game.level, trap, "trap", tx, ty)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[You bind light in a glyph on the floor. All targets passing by will be slowed by %d%%.
		The glyph lasts for %d turns.]]):format(self:getTalentLevel(t) * 7 + 20, 5 + self:getTalentLevel(t))
	end,
}
