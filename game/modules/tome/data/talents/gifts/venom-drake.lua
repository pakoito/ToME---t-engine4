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
	name = "Acidic Spray",
	type = {"wild-gift/venom-drake", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	message = "@Source@ spits acid!",
	equilibrium = 3,
	cooldown = function(self, t) return math.floor(8 - self:getTalentLevel(t)/3) end,
	tactical = { ATTACK = { ACID = 2 } },
	range = function(self, t) return math.floor(5 + self:getTalentLevel(t)/2) end,
	on_learn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) - 1 end,
	direct_hit = function(self, t) if self:getTalentLevel(t) >= 5 then return true else return false end end,
	requires_target = true,
	target = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		if self:getTalentLevel(t) >= 5 then tg.type = "beam" end
		return tg
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 25, 250) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ACID_DISARM, self:mindCrit(t.getDamage(self, t)), nil)
		local _ _, x, y = self:canProject(tg, x, y)
		if tg.type == "beam" then
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "acidbeam", {tx=x-self.x, ty=y-self.y})
		else
			game.level.map:particleEmitter(x, y, 1, "acid")
		end
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Spray forth a glob of acidic moisture at your enemy.
		The target will take %0.2f mindpower-based acid damage.
		Enemies struck have a 25%% chance to be Disarmed for three turns, as their weapon is rendered useless by an acid coating.
		At Talent Level 5, this becomes a piercing line of acid.
		Each point in acid drake talents also increases your acid resistance by 1%%.]]):format(damDesc(self, DamageType.ACID, damage))
	end,
}

newTalent{
	name = "Corrosive Mist",
	type = {"wild-gift/venom-drake", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	equilibrium = 15,
	cooldown = 25,
	tactical = { ATTACKAREA = { ACID = 2 } },
	range = 0,
	on_learn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) - 1 end,
	radius = function(self, t) return 2 + self:getTalentLevel(t)/2 end,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 70) end,
	getDuration = function(self, t) return 6 + self:combatMindpower(0.04) + (self:getTalentLevel(t)/2) end,
	getCorrodeDur = function(self, t) return 2 + (self:getTalentLevel(t)/3) end,
	getAtk = function(self, t) return self:combatTalentMindDamage(t, 2, 20) end,
	getArmor = function(self, t) return self:combatTalentMindDamage(t, 2, 20) end,
	getDefense = function(self, t) return self:combatTalentMindDamage(t, 2, 20) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	action = function(self, t)
		local damage = self:mindCrit(t.getDamage(self, t))
		local duration = t.getDuration(self, t)
		local cordur = t.getCorrodeDur(self, t)
		local atk = t.getAtk(self, t)
		local armor = t.getArmor(self, t)
		local defense = t.getDefense(self, t)
		local actor = self
		local radius = 2 + self:getTalentLevel(t)/2
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.ACID_CORRODE, {dam=damage, dur=cordur, atk=atk, armor=armor, defense=defense}, 
			radius,
			5, nil,
			{type="acidstorm", only_one=true},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			false
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local cordur = t.getCorrodeDur(self, t)
		local atk = t.getAtk(self, t)
		local radius = 2 + self:getTalentLevel(t)/2
		return ([[Exhale a mist of lingering acid, dealing %0.2f acid damage in a radius of %d each turn for %d turns.
		Enemies in this mist will be corroded for %d turns, lowering their accuracy, their armor and defense by %d.
		The damage and duration will increase with mindpower, and the radius will increase with talent level.
		Each point in acid drake talents also increases your acid resistance by 1%%.]]):format(damDesc(self, DamageType.ACID, damage), radius, duration, cordur, atk)
	end,
}

newTalent{
	name = "Dissolve",
	type = {"wild-gift/venom-drake", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "attack",
	equilibrium = 10,
	cooldown = 12,
	range = 1,
	tactical = { ATTACK = { ACID = 2 } },
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) - 1 end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		self:attackTarget(target, (self:getTalentLevel(t) >= 2) and DamageType.ACID_BLIND or DamageType.ACID, self:combatTalentWeaponDamage(t, 0.1, 0.60), true)
		self:attackTarget(target, (self:getTalentLevel(t) >= 4) and DamageType.ACID_BLIND or DamageType.ACID, self:combatTalentWeaponDamage(t, 0.1, 0.60), true)
		self:attackTarget(target, (self:getTalentLevel(t) >= 6) and DamageType.ACID_BLIND or DamageType.ACID, self:combatTalentWeaponDamage(t, 0.1, 0.60), true)
		self:attackTarget(target, (self:getTalentLevel(t) >= 8) and DamageType.ACID_BLIND or DamageType.ACID, self:combatTalentWeaponDamage(t, 0.1, 0.60), true)
		return true
	end,
	info = function(self, t)
		return ([[You strike the enemy with a rain of fast, acidic blows. You strike four times for pure acid damage. Every blow does %d%% damage.
		Every two talent levels, one of your strikes becomes blinding acid, instead of normal acid, blinding the target 25%% of the time if it hits.
		Each point in acid drake talents also increases your acid resistance by 1%%.]]):format(100 * self:combatTalentWeaponDamage(t, 0.1, 0.6))
	end,
}

newTalent{
	name = "Corrosive Breath",
	type = {"wild-gift/venom-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ breathes acid!",
	tactical = { ATTACKAREA = { ACID = 2 } },
	range = 0,
	radius = function(self, t) return 4 + self:getTalentLevelRaw(t) end,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) - 1 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ACID_DISARM, self:mindCrit(self:combatTalentStatDamage(t, "str", 30, 420)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_acid", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[You breathe acid in a frontal cone of radius %d. Any target caught in the area will take %0.2f acid damage. 
		Enemies caught in the acid have a 25%% chance of their weapons becoming useless for three turns.
		The damage will increase with the Strength stat.
		Each point in acid drake talents also increases your acid resistance by 1%%.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.ACID, self:combatTalentStatDamage(t, "str", 30, 420)))
	end,
}