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
	getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 30) end,
	getPenetration = function(self, t) return self:combatLimit(self:combatTalentMindDamage(t, 10, 20), 100, 4.2, 4.2, 13.4, 13.4) end, -- Limit < 100%
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 30, 5, 10)) end, --Limit < 30
	action = function(self, t)
		self:setEffect(self.EFF_TRANSCENDENT_TELEKINESIS, t.getDuration(self, t), {power=t.getPower(self, t), penetration = t.getPenetration(self, t)})
		self:removeEffect(self.EFF_TRANSCENDENT_PYROKINESIS)
		self:removeEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS)
		self:alterTalentCoolingdown(self.T_KINETIC_LEECH, -1000)
		self:alterTalentCoolingdown(self.T_KINETIC_STRIKE, -1000)
		self:alterTalentCoolingdown(self.T_KINETIC_AURA, -1000)
		self:alterTalentCoolingdown(self.T_KINETIC_SHIELD, -1000)
		self:alterTalentCoolingdown(self.T_MINDLASH, -1000)
		return true
	end,
	info = function(self, t)
		return ([[For %d turns your telekinesis transcends your normal limits, increasing your Physical damage by %d%% and you Physical resistance penetration by %d%%.
		In addition:
		The cooldowns of Kinetic Shield, Kinetic Leech, Kinetic Aura and Mindlash are reset.
		Kinetic Aura will either increase in radius to 2, or apply its damage bonus to all of your weapons, whichever is applicable.
		Your Kinetic Shield will have 100%% absorption efficiency and will absorb twice the normal amount of damage.
		Mindlash will also inflict stun.
		Kinetic Leech will put enemies to sleep.
		Kinetic Strike will hit 2 adjacent enemies in a sweeping attack.
		The damage bonus and resistance penetration scale with your Mindpower.
		Only one Transcendent talent may be in effect at a time.]]):format(t.getDuration(self, t), t.getPower(self, t), t.getPenetration(self, t))
	end,
}


newTalent{
	name = "Kinetic Surge", image = "talents/telekinetic_throw.png",
	type = {"psionic/kinetic-mastery", 2},
	require = psi_wil_high2,
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	psi = 20,
	tactical = { CLOSEIN = 2, ATTACK = { PHYSICAL = 2 }, ESCAPE = 2 },
	range = function(self, t) return self:combatTalentLimit(t, 10, 6, 9) end,
	getDamage = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 20, 180))
	end,
	getKBResistPen = function(self, t) return self:combatTalentLimit(t, 100, 25, 45) end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=2, selffire=false, talent=t} end,
	action = function(self, t)
		local tg = {type="hit", range=1, nowarning=true }
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local dam = self:mindCrit(t.getDamage(self, t))
				
		if target ~= self then
			local tg = self:getTalentTarget(t)
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end

			if target:canBe("knockback") or rng.percent(t.getKBResistPen(self, t)) then
				self:project({type="hit", range=tg.range}, target.x, target.y, DamageType.PHYSICAL, dam) --Direct Damage
				
				local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
				if tx and ty then
					local ox, oy = target.x, target.y
					target:move(tx, ty, true)
					if config.settings.tome.smooth_move > 0 then
						target:resetMoveAnim()
						target:setMoveAnim(ox, oy, 8, 5)
					end
				end
				tg.act_exclude = {[target.uid]=true} -- Don't hit primary target with AOE
				self:project(tg, target.x, target.y, DamageType.SPELLKNOCKBACK, dam/2) --AOE damage
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, math.floor(self:getTalentRange(t) / 2), {apply_power=self:combatMindpower()})
				else
					game.logSeen(target, "%s resists the stun!", target.name:capitalize())
				end
			else --If the target resists the knockback, do half damage to it.
				target:logCombat(self, "#YELLOW##Source# resists #Target#'s throw!")
				self:project({type="hit", range=tg.range}, target.x, target.y, DamageType.PHYSICAL, dam/2)
			end
		else
			local tg = {type="beam", range=self:getTalentRange(t), nolock=true, talent=t, display={particle="bolt_earth", trail="earthtrail"}}
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end
			if core.fov.distance(self.x, self.y, x, y) > tg.range then return nil end
			for i = 1, math.floor(self:getTalentRange(t) / 2) do
				self:project(tg, x, y, DamageType.DIG, 1)
			end
			self:project(tg, x, y, DamageType.MINDKNOCKBACK, dam)
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/lightning")
			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, engine.Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			local tx, ty = self.x, self.y
			while lx and ly do
				if is_corner_blocked or block_actor(_, lx, ly) then break end
				tx, ty = lx, ly
				lx, ly, is_corner_blocked = l:step()
			end
			--self:move(tx, ty, true)
			local fx, fy = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
			if fx then
				self:move(fx, fy, true)
			end
			return true
		end
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local dam = damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t))
		return ([[Build telekinetic power and dump it onto an adjacent creature or yourself. 
		This will launch them to where ever you target in a radius of %d. 
		
		Upon landing, launched enemy takes %0.1f Physical damage and is stunned for %d turns.  
		All other creatures within radius 2 of the landing point take %0.1f Physical damage and are knocked away from you.
		This talent ignores %d%% of the knockback resistance of the thrown target, which takes half damage if it resists being thrown.
		
		When used on yourself, you will launch in a straight line, knocking enemies flying and doing %0.1f Physical damage to each.
		You can break through %d walls while doing this.
		The damage improves with your Mindpower and the range increases with both Mindpower and Strength.]]):
		format(range, dam, math.floor(range/2), dam/2, t.getKBResistPen(self, t), dam, math.floor(range/2))
	end,
}


newTalent{
	name = "Deflect Projectiles",
	type = {"psionic/kinetic-mastery", 3},
	require = psi_wil_high3, 
	points = 5,
	mode = "sustained", no_sustain_autoreset = true,
	sustain_psi = 25,
	cooldown = 10,
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
		if self:attr("save_cleanup") then return true end
	
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
		All projectiles targeting you have a %d%% chance to instead target another spot within radius %d.
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
	cooldown = 20,
	psi = 35,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = 2 },
	range = 5,
	getDuration = function (self, t)
		return math.ceil(self:combatTalentMindDamage(t, 2, 6))
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
		return ([[Bind the target mercilessly with constant, bone-shattering pressure, pinning and slowing it by 50%% for %d turns and dealing %0.1f Physical damage each turn.
		The duration and damage will improve with your Mindpower.]]):
		format(dur, damDesc(self, DamageType.PHYSICAL, dam))
	end,
}
