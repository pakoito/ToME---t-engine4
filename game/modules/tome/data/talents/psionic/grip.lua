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
	name = "Bind",
	type = {"psionic/grip", 1},
	require = psi_cun_high1,
	points = 5,
	random_ego = "attack",
	cooldown = 25,
	psi = 10,
	tactical = { DISABLE = 2 },
	range = function(self, t)
		local r = 5
		local mult = 1 + 0.01*self:callTalent(self.T_REACH, "rangebonus")
		return math.floor(r*mult)
	end,
	getDuration = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 3, 10))
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t} end,
	action = function(self, t)
		local gem_level = getGemLevel(self)
		local dur = t.getDuration(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(self.EFF_PSIONIC_BIND, dur, {power=1, apply_power=self:combatMindpower()})
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		return ([[Bind the target in crushing bands of telekinetic force, immobilizing it for %d turns. 
		The duration will improve with your Mindpower.]]):
		format(dur)
	end,
}

newTalent{
	name = "Redirect",
	type = {"psionic/grip", 2},
	require = psi_cun_high2,
	points = 5,
	psi = 40,
	cooldown = 30,
	tactical = { },
	no_npc_use = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5, "log")) end, 
	radius = 10,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), selffire=false, talent=t}
	end,
	action = function(self, t)
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
		return ([[Use your mind to grab all projectiles within radius 10 of you and hurl them toward any location within range %d of you.]]):
		format(self:getTalentRange(t))
	end,
}

newTalent{
	name = "Implode",
	type = {"psionic/grip", 3},
	require = psi_cun_high3,
	points = 5,
	random_ego = "attack",
	cooldown = 45,
	psi = 35,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	no_npc_use = true,
	range = function(self, t)
		local r = 3
		local mult = 1 + 0.01*self:callTalent(self.T_REACH, "rangebonus")
		return math.floor(r*mult)
	end,
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
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		local dam = t.getDamage(self, t)
		return ([[Crush the target mercilessly with constant, bone-shattering pressure, slowing it by 50%% for %d turns and dealing %d damage each turn.
		The duration and damage will improve with your Mindpower.]]):
		format(dur, damDesc(self, DamageType.PHYSICAL, dam))
	end,
}

newTalent{
	name = "Telekinetic Throw",
	type = {"psionic/grip", 4},
	require = psi_cun_high4,
	points = 5,
	random_ego = "attack",
	cooldown = 30,
	psi = 40,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	range = function(self, t)
		local r = 4
		local mult = 1 + 0.01*self:callTalent(self.T_REACH, "rangebonus")
		return math.floor(r*mult)
	end,
	getDamage = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 10, 400))
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
		local range = t.range(self, t)
		local dam = t.getDamage(self, t)
		return ([[Use your telekinetic power to enhance your strength, allowing you to pick up your target and throw it anywhere in radius %d. 
		Upon landing, your target takes %0.2f physical damage and is stunned for 4 turns, and all other creatures within radius 2 of the landing point take %0.2f physical damage and are knocked back. 
		The damage will improve with your Mindpower.]]):
		format(range, damDesc(self, DamageType.PHYSICAL, dam), damDesc(self, DamageType.PHYSICAL, dam/2) )
	end,
}

newTalent{
	name = "Greater Telekinetic Grasp",
	type = {"psionic/grip", 4},
	require = psi_cun_high4,
	hide = true,
	points = 5,
	mode = "passive",
	getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.15, 0.50) end, -- Limit < 100%
	stat_sub = function(self, t) -- called by _M:combatDamage in mod\class\interface\Combat.lua
		return self:combatTalentScale(t, 0.64, 0.80)
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "disarm_immune", t.getImmune(self, t))
	end,
	info = function(self, t)
		local boost = 100 * t.stat_sub(self, t)
		return ([[Use finely controlled forces to augment both your flesh-and-blood grip, and your telekinetic grip. This does the following:
		Increases disarm immunity by %d%%.
		Allows %d%% of Willpower and Cunning (instead of the usual 60%%) to be substituted for Strength and Dexterity for the purposes of determining damage done by telekinetically-wielded weapons.
		At talent level 5, telekinetically wielded gems and mindstars will be treated as one material level higher than they actually are.
		]]):
		format(t.getImmune(self, t)*100, boost)
	end,
}
