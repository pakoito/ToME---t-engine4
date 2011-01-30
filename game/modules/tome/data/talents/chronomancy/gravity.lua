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
	name = "Repulsion Field",
	type = {"chronomancy/gravity",1},
	require = chrono_req1,
	points = 5,
	paradox = 4,
	cooldown = 20,
	tactical = { DEFEND = 1, ESCAPE = 1, DISABLE = 1 },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 4, 50)*getParadoxModifier(self, pm) end,
	getDuration = function (self, t) return 4 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		self:setEffect(self.EFF_REPULSION_FIELD, t.getDuration(self, t), {power=t.getDamage(self, t)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Surround yourself with a repulsion field for %d turns, inflicting %0.2f physical damage to attackers and potentially knocking them back.
		The damage will scale with your Paradox and Magic stat.]]):format(duration, damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Gravity Spike",
	type = {"chronomancy/gravity", 2},
	require = chrono_req2,
	points = 5,
	paradox = 10,
	cooldown = 10,
	tactical = { ATTACK = 2, DISABLE = 2 },
	range = 6,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 170)*getParadoxModifier(self, pm) end,
	getRadius = function (self, t) return 2 + math.floor(self:getTalentLevel(t) / 3) end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
			if tx and ty and target:canBe("knockback") then
				target:move(tx, ty, true)
				game.logSeen(target, "%s is drawn in by the gravity spike!", target.name:capitalize())
			end
		end)
		self:project (tg, x, y, DamageType.PHYSICAL, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(x, y, tg.radius, "gravity_spike", {radius=tg.radius, grids=grids, tx=x, ty=y})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = t.getRadius(self, t)
		return ([[Creates a gravity spike in a radius of %d moving all targets towards the spells center and inflicting %0.2f physical damage.
		The damage will scale with your Paradox and Magic Stat.]]):format(radius, damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Repulsion Blast",
	type = {"chronomancy/gravity",3},
	require = chrono_req3,
	points = 5,
	paradox = 12,
	cooldown = 15,
	tactical = { ATTACKAREA = 2, ESCAPE = 2 },
	range = 1,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 170)*getParadoxModifier(self, pm) end,
	getRadius = function (self, t) return 2 + self:getTalentLevelRaw (t) end,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=t.getRadius(self, t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.REPULSION, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "gravity_breath", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = t.getRadius (self, t)
		return ([[Sends out a wave of repulsion in a %d radius cone, dealing %0.2f physical damage and knocking back creatures caught in the area.
		The damage will scale with your Paradox and Magic stat.]]):
		format(radius, damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}


newTalent{
	name = "Gravity Well",
	type = {"chronomancy/gravity", 4},
	require = chrono_req4,
	points = 5,
	paradox = 20,
	cooldown = 30,
	tactical = { ATTACK = 2, DISABLE = 2 },
	range = 6,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 50)*getParadoxModifier(self, pm) end,
	getDuration = function (self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		local duration = t.getDuration(self,t)
		local radius = 2
		local dam = t.getDamage(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		local _ _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.GRAVITY, dam,
			radius,
			5, nil,
			{type="quake"},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Increases local gravity, doing %0.2f physical damage with a chance to pin in a radius of 3 each turn for %d turns.
		The damage will scale with your Paradox and Magic stat]]):format(damDesc(self, DamageType.PHYSICAL, damage), duration)
	end,
}