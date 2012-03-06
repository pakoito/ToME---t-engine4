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

local Trap = require "mod.class.Trap"

newTalent{
	name = "Glyph of Paralysis",
	type = {"celestial/glyphs", 1},
	require = divi_req_high1,
	random_ego = "attack",
	points = 5,
	cooldown = 20,
	positive = -10,
	requires_target = true,
	tactical = { DISABLE = 2 },
	range = function(self, t) return math.floor (self:getTalentLevel(t)) end,
	getDazeDuration = function(self, t) return 3 + self:getTalentLevelRaw(t) end,
	getDuration = function(self, t) return 5 + self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = t.getDazeDuration(self, t)
		local trap = Trap.new{
			name = "glyph of paralysis",
			type = "elemental", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD, image = "trap/trap_glyph_paralysis_01_64.png",
			dam = dam,
			canTrigger = function(self, x, y, who)
				if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
				return false
			end,
			triggered = function(self, x, y, who)
				who:setEffect(who.EFF_DAZED, self.dam, {})
				return true
			end,
			temporary = t.getDuration(self, t),
			x = tx, y = ty,
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
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
		local dazeduration = t.getDazeDuration(self, t)
		local duration = t.getDuration(self, t)
		return ([[You bind light in a glyph on the floor. All targets passing by will be dazed for %d turns.
		The glyph lasts for %d turns.]]):format(dazeduration, duration)
	end,
}

newTalent{
	name = "Glyph of Repulsion",
	type = {"celestial/glyphs", 2},
	require = divi_req_high2,
	random_ego = "attack",
	points = 5,
	positive = -10,
	cooldown = 20,
	tactical = { DISABLE = 2 },
	requires_target = true,
	range = function(self, t) return math.floor (self:getTalentLevel(t)) end,
	getDamage = function(self, t) return 15 + self:combatSpellpower(0.12) * self:getTalentLevel(t) end,
	getDuration = function(self, t) return 5 + self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = t.getDamage(self, t)
		local sp = self:combatSpellpower()
		local trap = Trap.new{
			name = "glyph of repulsion",
			type = "elemental", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD, image = "trap/trap_glyph_repulsion_01_64.png",
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
			temporary = t.getDuration(self, t),
			x = tx, y = ty,
			canAct = false,
			energy = {value=0},
			combatSpellpower = function(self) return self.sp end, sp = sp,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
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
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[You bind light in a glyph on the floor. All targets passing by will be hit by a blast of light doing %0.2f damage and knocked back.
		The glyph lasts for %d turns.
		The damage will increase with the Magic stat]]):
		format(damage, duration)
	end,
}

newTalent{
	name = "Glyph of Explosion",
	type = {"celestial/glyphs", 3},
	require = divi_req_high3,
	random_ego = "attack",
	points = 5,
	cooldown = 20,
	positive = -10,
	tactical = { ATTACKAREA = {LIGHT = 2} },
	requires_target = true,
	range = function(self, t) return math.floor (self:getTalentLevel(t)) end,
	getDamage = function(self, t) return 15 + self:combatSpellpower(0.12) * self:getTalentLevel(t) end,
	getDuration = function(self, t) return 5 + self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = t.getDamage(self, t)
		local trap = Trap.new{
			name = "glyph of explosion",
			type = "elemental", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD, image = "trap/trap_glyph_explosion_01_64.png",
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
			temporary = t.getDuration(self, t),
			x = tx, y = ty,
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
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
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[You bind light in a glyph on the floor. All targets passing by will trigger blast of light doing %0.2f damage.
		The glyph lasts for %d turns.
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.LIGHT, damage), duration)
	end,
}

newTalent{
	name = "Glyph of Fatigue",
	type = {"celestial/glyphs", 4},
	require = divi_req_high4,
	random_ego = "attack",
	points = 5,
	cooldown = 20,
	positive = -10,
	tactical = { DISABLE = 2 },
	requires_target = true,
	range = function(self, t) return math.floor (self:getTalentLevel(t)) end,
	getSlow = function(self, t) return math.min(self:getTalentLevel(t) * 0.07 + 0.2, 0.65) end,
	getDuration = function(self, t) return 5 + self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = t.getSlow(self, t)
		local trap = Trap.new{
			name = "glyph of fatigue",
			type = "elemental", id_by_type=true, unided_name = "trap",
			display = '^', color=colors.GOLD, image = "trap/trap_glyph_fatigue_01_64.png",
			dam = dam,
			canTrigger = function(self, x, y, who)
				if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
				return false
			end,
			triggered = function(self, x, y, who)
				who:setEffect(who.EFF_SLOW, 5, {power=self.dam})
				return true
			end,
			temporary = t.getDuration(self, t),
			x = tx, y = ty,
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
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
		local slow = t.getSlow(self, t)
		local duration = t.getDuration(self, t)
		return ([[You bind light in a glyph on the floor. All targets passing by will be slowed by %d%%.
		The glyph lasts for %d turns.]]):format(100 * slow, duration)
	end,
}
