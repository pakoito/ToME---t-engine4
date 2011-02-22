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
	name = "Weapon Folding",
	type = {"chronomancy/spacetime-folding", 1},
	mode = "sustained",
	require = temporal_req1,
	sustain_paradox = 75,
	cooldown = 10,
	tactical = { BUFF = 2 },
	points = 5,
	getDamage = function(self, t) return 3 + ((self:combatSpellpower() / 10) * self:getTalentLevel(t)) end,
	getArmorPen = function(self, t) return 2 + ((self:combatSpellpower() / 20) * self:getTalentLevel(t)) end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local ap = t.getArmorPen(self, t)
		return ([[Folds a single dimension of your melee weapons, allowing them to penetrate %d armor and adding %0.2f temporal damage to your strikes.
		The armor penetration and damage will increase with the Magic stat.]]):format(ap, damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

newTalent{
	name = "Displace Damage",
	type = {"chronomancy/spacetime-folding", 2},
	mode = "sustained",
	require = temporal_req2,
	sustain_paradox = 150,
	cooldown = 10,
	tactical = { BUFF = 2 },
	points = 5,
	no_energy = true,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Space bends around you, giving you a %d%% chance to displace half of any damage you recieve onto a random enemy within a range of %d.
		]]):format(5 + self:getTalentLevel(t) * 5, self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Temporal Wake",
	type = {"chronomancy/spacetime-folding", 3},
	require = temporal_req3,
	points = 5,
	random_ego = "attack",
	paradox = 10,
	cooldown = 12,
	tactical = { ATTACK = 1, CLOSEIN = 2 },
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) * getParadoxModifier(self, pm) end,
	range = function(self, t)
		return 5 + (self:getTalentLevelRaw(t))
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if self:hasLOS(x, y) and not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			local dam = self:spellCrit(t.getDamage(self, t))
			self:project(tg, x, y, DamageType.TEMPORAL, dam)
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "temporal_lightning", {tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/lightning")
			local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
			if tx and ty then
				self:move(tx, ty, true)
			end
		else
			game.logSeen(self, "You can't move there.")
			return nil
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local range = self:getTalentRange(t)
		return ([[Violently fold the space between yourself and another point within a range of %d.  You move to the selected point and leave a temporal wake behind, inflicting %0.2f temporal damage to everything in the path.
		The damage will scale with your Paradox and the Magic stat and the range will increase with the talent level.]]):
		format(range, damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

newTalent{
	name = "Kinetic Folding",
	type = {"chronomancy/spacetime-folding", 4},
	require = temporal_req4,
	points = 5,
	paradox = 10,
	cooldown = 12,
	tactical = { ATTACK = 2 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon() then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.9) * getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			self:attackTarget(target, nil, t.getDamage(self, t), true)
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[You momentarily fold the space between yourself and your target, attacking it at range with both weapons for %d%% weapon damage.
		The damage will scale with your Paradox.]]):
		format (damage*100)
	end,
}
