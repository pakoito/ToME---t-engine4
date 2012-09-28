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
	name = "Slime Spit",
	type = {"wild-gift/slime", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	equilibrium = 4,
	cooldown = 5,
	tactical = { ATTACK = { NATURE = 2} },
	range = 10,
	proj_speed = 8,
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.BOUNCE_SLIME, {nb=math.ceil(self:getTalentLevel(t)), dam=self:mindCrit(self:combatTalentMindDamage(t, 30, 290))}, {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Spit slime at your target doing %0.2f nature damage and slowing it down by 30%% for 3 turns.
		The bolt can bounce to a nearby foe %d times.
		The damage will increase with Mindpower]]):format(damDesc(self, DamageType.NATURE, self:combatTalentMindDamage(t, 30, 290)), math.ceil(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Poisonous Spores",
	type = {"wild-gift/slime", 2},
	require = gifts_req2,
	random_ego = "attack",
	points = 5,
	message = "@Source@ releases poisonous spores at @target@.",
	equilibrium = 2,
	cooldown = 10,
	range = 10,
	tactical = { ATTACK = { NATURE = 3 } },
	radius = function(self, t) if self:getTalentLevel(t) < 3 then return 1 else return 2 end end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:combatTalentMindDamage(t, 40, 900)

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and self:reactionToward(target) < 0 and target:canBe("poison") then
				local poison = rng.table{target.EFF_SPYDRIC_POISON, target.EFF_INSIDIOUS_POISON, target.EFF_CRIPPLING_POISON, target.EFF_NUMBING_POISON}
				target:setEffect(poison, 10, {src=self, power=dam/10, reduce=10+self:getTalentLevel(t)*2, fail=math.ceil(5+self:getTalentLevel(t)), heal_factor=20+self:getTalentLevel(t)*4})
			end
		end, 0, {type="slime"})

		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Releases poisonous spores at an area of radius %d, infecting the foes inside with a random poison doing %0.2f nature damage over 10 turns.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.NATURE, self:combatTalentMindDamage(t, 40, 900)))
	end,
}

newTalent{
	name = "Acidic Skin",
	type = {"wild-gift/slime", 3},
	require = gifts_req3,
	points = 5,
	mode = "sustained",
	message = "The skin of @Source@ starts dripping acid.",
	sustain_equilibrium = 30,
	cooldown = 30,
	range = 1,
	requires_target = false,
	tactical = { DEFEND = 1 },
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		local power = 10 + 5 * self:getTalentLevel(t)
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.ACID_DISARM]={dam=power, chance=5 + self:getTalentLevel(t) * 2}}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		return ([[Your skin drips with acid, damaging all that hit you for %0.2f acid damage and giving %d%% chances to disarm them for 3 turns.]]):format(damDesc(self, DamageType.ACID, self:combatTalentMindDamage(t, 10, 50)), 5 + self:getTalentLevel(t) * 2)
	end,
}

newTalent{
	name = "Slime Roots",
	type = {"wild-gift/slime", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "utility",
	equilibrium = 5,
	cooldown = 20,
	tactical = { CLOSEIN = 2 },
	requires_target = true,
	range = function(self, t)
		return 5 + self:getTalentLevel(t)
	end,
	radius = function(self, t)
		return util.bound(4 - self:getTalentLevel(t) / 2, 1, 4)
	end,
	getNbTalents = function(self, t)
		if self:getTalentLevel(t) < 3 then return 1
		elseif self:getTalentLevel(t) < 5 then return 2
		else return 3
		end
	end,
	is_teleport = true,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
		local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=range, radius=radius, requires_knowledge=false}
		local x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code does not restrict the self coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, 1, "slime")
		self:teleportRandom(x, y, self:getTalentRadius(t))
		game.level.map:particleEmitter(self.x, self.y, 1, "slime")

		local nb = t.getNbTalents(self, t)

		local list = {}
		for tid, cd in pairs(self.talents_cd) do list[#list+1] = tid end
		while #list > 0 and nb > 0 do
			self.talents_cd[rng.tableRemove(list)] = nil
			nb = nb - 1
		end
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
		local talents = t.getNbTalents(self, t)
		return ([[You extend slimy roots into the ground, follow them, and re-appear somewhere else in a range of %d with error margin of %d.
		Doing so changes your internal structure slightly, taking %d random talent(s) off cooldown.]]):format(range, radius, talents)
	end,
}

