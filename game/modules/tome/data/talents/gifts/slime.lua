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
	name = "Slime Spit",
	type = {"wild-gift/slime", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	equilibrium = 4,
	cooldown = 5,
	tactical = { ATTACK = { NATURE = 2}, DISABLE = 1 },
	range = 10,
	proj_speed = 6,
	requires_target = true,
	getTargetCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	bouncePercent = function(self, t) return self:combatTalentLimit(t, 100, 50, 60) end, --Limit < 100%
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), selffire=false, talent=t, display={particle="bolt_slime"}, name = t.name, speed = t.proj_speed}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.BOUNCE_SLIME, {nb=t.getTargetCount(self, t), dam=self:mindCrit(self:combatTalentMindDamage(t, 30, 250)), bounce_factor=t.bouncePercent(self, t)/100}, {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Spit slime at your target doing %0.1f nature damage and slowing it down by 30%% for 3 turns.
		The slime can bounce from foe to foe, hitting up to a total of %d target(s).
		Additional targets must be within 6 tiles of each other and the slime loses %0.1f%% damage per bounce.
		The damage will increase with your Mindpower]]):format(damDesc(self, DamageType.NATURE, self:combatTalentMindDamage(t, 30, 250)), t.getTargetCount(self, t), 100-t.bouncePercent(self, t))
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
	tactical = { ATTACKAREA = { NATURE = 2 }, DISABLE = 1 },
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2.7)) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 30, 390) end,
	critPower = function(self, t) return self:combatTalentMindDamage(t, 10, 40) end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:mindCrit(t.getDamage(self, t), 0, t.critPower(self, t)/100)
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and self:reactionToward(target) < 0 and target:canBe("poison") then
				local poison = rng.table{target.EFF_SPYDRIC_POISON, target.EFF_INSIDIOUS_POISON, target.EFF_CRIPPLING_POISON, target.EFF_NUMBING_POISON}
				target:setEffect(poison, 10, {src=self, power=dam/10, 
				reduce=self:combatTalentLimit(t, 100, 12, 20), 
				fail=math.ceil(self:combatTalentLimit(t, 100, 6, 10)),
				heal_factor=self:combatTalentLimit(t, 100, 24, 40)})
			end
		end, 0, {type="slime"})

		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Releases poisonous spores at an area of radius %d, infecting the foes inside with a random poison doing %0.1f Nature damage over 10 turns.
		This attack can crit and deals %d%% additional critical damage.
		The damage and critical bonus increase with your Mindpower.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.NATURE, t.getDamage(self, t)), t.critPower(self, t))
	end,
}

-- Boring, but disarm was way too far
-- Now that we have melee retaliation damage shown in tooltips its a little safer to raise the damage on this
newTalent{
	name = "Acidic Skin",
	type = {"wild-gift/slime", 3},
	require = gifts_req3,
	points = 5,
	mode = "sustained",
	message = "The skin of @Source@ starts dripping acid.",
	sustain_equilibrium = 3,
	cooldown = 30,
	range = 1,
	requires_target = false,
	tactical = { DEFEND = 1 },
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 7, 15) end, -- Limit < 100%
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		local power = t.getDamage(self, t)
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.ACID_DISARM]={dam=power, chance=t.getChance(self, t)}}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		return ([[Your skin drips with acid, damaging all that hit you for %0.1f Acid damage.
		The damage increases with your Mindpower.]]):format(damDesc(self, DamageType.ACID, t.getDamage(self, t)))
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
	tactical = { CLOSEIN = 2, ESCAPE = 1 },
	requires_target = true,
	range = function(self, t)
		return math.floor(self:combatTalentScale(t,4.5,6.5))
	end,
	radius = function(self, t)
		return util.bound(4 - self:getTalentLevel(t) / 2, 1, 4)
	end,
	getNbTalents = function(self, t)
		if self:getTalentLevel(t) < 4 then return 1
		elseif self:getTalentLevel(t) < 7 then return 2
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
		local _, x, y = self:canProject(tg, x, y)
		if not x then return nil end
		local oldx, oldy = self.x, self.y
		if not self:teleportRandom(x, y, self:getTalentRadius(t)) then return nil end
		game.level.map:particleEmitter(oldx, oldy, 1, "slime")
		game.level.map:particleEmitter(self.x, self.y, 1, "slime")

		local nb = t.getNbTalents(self, t)
		local list = {}
		for tid, cd in pairs(self.talents_cd) do 
			local tt = self:getTalentFromId(tid)
			if tt.mode ~= "passive" and not tt.uber then list[#list+1] = tid end
		end
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

