-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	name = "Blood Splash",
	type = {"corruption/vile-life", 1},
	require = corrs_req1,
	points = 5,
	mode = "passive",
	heal = function(self, t) return self:combatTalentScale(t, 10, 50) end,
	callbackOnCrit = function(self, t)
		if self.turn_procs.blood_splash_on_crit then return end
		self.turn_procs.blood_splash_on_crit = true

		self:heal(t.heal(self, t), self)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
		end
	end,
	callbackOnKill = function(self, t)
		if self.turn_procs.blood_splash_on_kill then return end
		self.turn_procs.blood_splash_on_kill = true

		self:heal(t.heal(self, t), self)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
		end
	end,
	info = function(self, t)
		return ([[Inflicting pain and death invogorates you.
		Each time you deal a critical strike you gain %d life (this effect can only happen once per turn).
		Each time you kill a creature you gain %d life (this effect can only happen once per turn).]]):
		format(t.heal(self, t), t.heal(self, t))
	end,
}

newTalent{
	name = "Elemental Discord",
	type = {"corruption/vile-life", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 10,
	radius = 2,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	getCDincrease = function(self, t) return self:combatTalentScale(t, 0.15, 0.5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_BURNING_HEX, 20, {src=self, dam=self:spellCrit(self:combatTalentSpellDamage(t, 4, 90)), power=1 + t.getCDincrease(self, t), apply_power=self:combatSpellpower()})
		end)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, g=100, b=100, a=90, limit_life=8, appear=8, speed=2, img="blight_circle", radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Hexes your target and everything within a radius 2 ball around it for 20 turns. Each time an affected target uses a resource (stamina, mana, vim, ...), it takes %0.2f fire damage.
		In addition, the cooldown of any talent used while so hexed is increased by %d%% + 1 turn.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 4, 90)), t.getCDincrease(self, t)*100)
	end,
}

newTalent{
	name = "Healing Inversion",
	type = {"corruption/vile-life", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 10,
	radius = 2,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	recoil = function(self,t) return self:combatLimit(self:combatTalentSpellDamage(t, 4, 20), 100, 0, 0, 12.1, 12.1) end, -- Limit to <100%
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_EMPATHIC_HEX, 20, {power=t.recoil(self,t), apply_power=self:combatSpellpower()})
		end)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, r=100, b=100, a=90, limit_life=8, appear=8, speed=2, img="blight_circle", radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Hexes your target and everything within a radius 2 ball around it. Each time they do damage, they take %d%% of the same damage for 20 turns.
		The damage will increase with your Spellpower.]]):format(t.recoil(self,t))
	end,
}

newTalent{
	name = "Vile Transplant",
	type = {"corruption/vile-life", 4},
	require = corrs_req4,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 10,
	no_npc_use = true,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			if target:canBe("instakill") then
				target:setEffect(target.EFF_DOMINATION_HEX, t.getDuration(self, t), {src=self, apply_power=self:combatSpellpower(), faction = self.faction})
			end
		end)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, g=100, r=100, a=90, limit_life=8, appear=8, speed=2, img="blight_circle", radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Hexes your target, forcing it to be your thrall for %d turns.
		If you damage the target, it will be freed from the hex.]]):format(t.getDuration(self, t))
	end,
}
