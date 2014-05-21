-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	name = "Transcendent Telekinesis",
	type = {"psionic/kinetic-mastery", 1},
	require = psi_wil_high1,
	points = 5,
	psi = 20,
	cooldown = 30,
	tactical = { BUFF = 3 },
	getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 20) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10)) end,
	action = function(self, t)
		self:setEffect(self.EFF_TRANSCENDENT_TELEKINESIS, t.getDuration(self, t), {power=t.getPower(self, t)})
		self:removeEffect(self.EFF_TRANSCENDENT_PYROKINESIS)
		self:removeEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS)
		self.talents_cd[self.T_KINETIC_LEECH] = 0
		self.talents_cd[self.T_KINETIC_AURA] = 0
		self.talents_cd[self.T_KINETIC_SHIELD] = 0
		self.talents_cd[self.T_MINDLASH] = 0
		return true
	end,
	info = function(self, t)
		return ([[For %d turns your telekinesis transcends your normal limits, increasing your physical damage and resistance penetration by %d%%.
		Kinetic Shield, Kinetic Leech, Kinetic Aura and Mindlash will have their cooldowns reset.
		Kinetic Aura will increase to radius 2, or apply its damage bonus to all your weapons, whichever is applicable.
		Kinetic Shield will have 100%% damage absorption efficiency and double max.
		kinetic Leech will put enemies to sleep.
		Damage bonus and penetration scale with your mindpower.
		Only one Transcendent talent may be in effect at a time.]]):format(t.getDuration(self, t), t.getPower(self, t))
	end,
}


newTalent{
	name = "Telekinetic Throw",
	type = {"psionic/kinetic-mastery", 2},
	require = psi_wil_high2,
	points = 5,
	random_ego = "attack",
	cooldown = 30,
	psi = 40,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	range = 4,
	getDamage = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 10, 300))
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=2, selffire=false, talent=t} end,
	action = function(self, t)
		local tg = {type="hit", range=1}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, self.x, self.y, DamageType.SPELLKNOCKBACK, dam/2)
		
		local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		if tx and ty then
			local ox, oy = target.x, target.y
			target:move(tx, ty, true)
			if config.settings.tome.smooth_move > 0 then
				target:resetMoveAnim()
				target:setMoveAnim(ox, oy, 8, 5)
			end
		end
		
		self:project({type="hit", range=10}, target.x, target.y, DamageType.PHYSICAL, dam)
		if target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, 4, {apply_power=self:combatMindpower()})
		else
			game.logSeen(target, "%s resists the stun!", target.name:capitalize())
		end
		
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(self, t)
		local dam = t.getDamage(self, t)
		return ([[Use your telekinetic power to enhance your strength, allowing you to pick up your target and throw it anywhere in radius %d. 
		Upon landing, your target takes %0.2f physical damage and is stunned for 4 turns, and all other creatures within radius 2 of the landing point take %0.2f physical damage and are knocked back. 
		The damage will improve with your Mindpower.]]):
		format(range, damDesc(self, DamageType.PHYSICAL, dam), damDesc(self, DamageType.PHYSICAL, dam/2) )
	end,
}

newTalent{
	name = "Deflect Projectiles",
	type = {"psionic/kinetic-mastery", 3},
	require = psi_wil_high3, 
	points = 5,
	mode = "sustained",
	sustain_psi = 25,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5, "log")) end, 
	radius = 10,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), selffire=false, talent=t}
	end,
	getEvasion = function(self, t) return self:combatTalentLimit(t, 100, 17, 45), self:getTalentLevel(t) >= 4 and 2 or 1 end, -- Limit chance <100%
	activate = function(self, t)
		local chance, spread = t.getEvasion(self, t)
		return {
			chance = self:addTemporaryValue("projectile_evasion", chance),
			spread = self:addTemporaryValue("projectile_evasion_spread", spread),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("projectile_evasion", p.chance)
		self:removeTemporaryValue("projectile_evasion_spread", p.spread)
		
		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRadius(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local i = 0
			local p = game.level.map(x, y, Map.PROJECTILE+i)
			while p do
				if p.project and p.project.def.typ.source_actor ~= self then
					p.project.def.typ.line_function = core.fov.line(p.x, p.y, tx, ty)
				end
				
				i = i + 1
				p = game.level.map(x, y, Map.PROJECTILE+i)
			end
		end end

		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "shout", {additive=true, life=10, size=3, distorion_factor=0.0, radius=self:getTalentRadius(t), nb_circles=4, rm=0.8, rM=1, gm=0, gM=0, bm=0.8, bM=1.0, am=0.4, aM=0.6})
		
		return true
	end,
	info = function(self, t)
		local chance, spread = t.getEvasion(self, t)
		return ([[You learn to devote a portion of your attention to mentally swatting, grabbing, or otherwise deflecting incoming projectiles.
		All projectiles targeting you have a %d%% chance to instead target a spot up to %d grids nearby.
		If you choose, you can use your mind to grab all projectiles within radius 10 of you and hurl them toward any location within range %d of you, but this will break your concentration.
		To do this, deactivate this sustained talent.]]):
		format(chance, spread, self:getTalentRange(t))
	end,
}

newTalent{
	name = "Implode",
	type = {"psionic/kinetic-mastery", 4},
	require = psi_wil_high4,
	points = 5,
	random_ego = "attack",
	cooldown = 45,
	psi = 35,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = 2 },
	range = 5,
	getDuration = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 2, 6))
	end,
	getDamage = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 66, 132))
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t} end,
	action = function(self, t)
		local dur = t.getDuration(self, t)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.IMPLOSION, {dur=dur, dam=dam})
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(self.EFF_PSIONIC_BIND, dur, {power=1, apply_power=self:combatMindpower()})
		end
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		local dam = t.getDamage(self, t)
		return ([[Bind the target mercilessly with constant, bone-shattering pressure, pinning and slowing it by 50%% for %d turns and dealing %d damage each turn.
		The duration and damage will improve with your Mindpower.]]):
		format(dur, damDesc(self, DamageType.PHYSICAL, dam))
	end,
}
