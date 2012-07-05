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

newTalent{
	name = "Swallow",
	type = {"wild-gift/sand-drake", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 4,
	cooldown = 10,
	range = 1,
	message = "@Source@ tries to swallow @target@!",
	tactical = { ATTACK = { NATURE = 0.5 }, EQUILIBRIUM = 0.5},
	requires_target = true,
	no_npc_use = true,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local hit = self:attackTarget(target, DamageType.NATURE, self:combatTalentWeaponDamage(t, 1, 1.5), true)
		if not hit then return true end

		if (target.life * 100 / target.max_life > 10 + 3 * self:getTalentLevel(t)) and not target.dead then
			return true
		end

		if (target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 15) or target.dead) and (target:canBe("instakill") or target.life * 100 / target.max_life <= 5) then
			if not target.dead then target:die(self) end
			world:gainAchievement("EAT_BOSSES", self, target)
			self:incEquilibrium(-target.level - 5)
			self:attr("allow_on_heal", 1)
			self:heal(target.level * 2 + 5)
			self:attr("allow_on_heal", -1)
		else
			game.logSeen(target, "%s resists!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[Attack the target for %d%% nature weapon damage.
		If the attack brings your target below %d%% life (or kills it) you can try to swallow it, killing it automatically and regaining life and equilibrium depending on its level.
		Each point in sand drake talents also increases your physical resistance by 0.5%%.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1, 1.5), 10 + 3 * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Quake",
	type = {"wild-gift/sand-drake", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	message = "@Source@ shakes the ground!",
	equilibrium = 4,
	cooldown = 30,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 } },
	range = 10,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	radius = function(self, t)
		return 2 + self:getTalentLevel(t) / 2
	end,
	no_npc_use = true,
	getDamage = function(self, t)
		return self:combatDamage() * 0.8
	end,
	action = function(self, t)
		local tg = {type="ball", range=0, selffire=false, radius=self:getTalentRadius(t), talent=t, no_restrict=true}
		self:project(tg, self.x, self.y, DamageType.PHYSKNOCKBACK, {dam=self:mindCrit(t.getDamage(self, t)), dist=4})
		self:doQuake(tg, self.x, self.y)
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local dam = t.getDamage(self, t)
		return ([[You slam your foot onto the ground, shaking the area around you in a radius of %d.
		Creatures caught by the quake will be damaged for %d and knocked back up to 4 titles away.
		The terrain will also be moved around within the quake's radius.
		The damage will increase with the Strength stat.
		Each point in sand drake talents also increases your physical resistance by 0.5%%.]]):format(radius, dam)
	end,
}

newTalent{
	name = "Burrow",
	type = {"wild-gift/sand-drake", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 50,
	cooldown = 30,
	range = 10,
	tactical = { CLOSEIN = 0.5, ESCAPE = 0.5 },
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	action = function(self, t)
		self:setEffect(self.EFF_BURROW, 5 + self:getTalentLevel(t) * 3, {})
		return true
	end,
	info = function(self, t)
		return ([[Allows you to burrow into walls for %d turns.
		Each point in sand drake talents also increases your physical resistance by 0.5%%.]]):format(5 + self:getTalentLevel(t) * 3)
	end,
}

newTalent{
	name = "Sand Breath",
	type = {"wild-gift/sand-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ breathes sand!",
	tactical = { ATTACKAREA = {PHYSICAL = 2}, DISABLE = { blind = 2 } },
	range = 0,
	radius = function(self, t) return 4 + self:getTalentLevelRaw(t) end,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t)
		return self:combatTalentStatDamage(t, "str", 30, 400)
	end,
	getDuration = function(self, t)
		return 2+self:getTalentLevelRaw(t)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SAND, {dur=t.getDuration(self, t), dam=self:mindCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_earth", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[You breathe sand in a frontal cone of radius %d. Any target caught in the area will take %0.2f physical damage and be blinded for %d turns.
		The damage will increase with the Strength stat.
		Each point in sand drake talents also increases your physical resistance by 0.5%%.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, damage), duration)
	end,
}

