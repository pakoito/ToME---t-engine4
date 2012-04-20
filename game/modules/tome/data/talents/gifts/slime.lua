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
	name = "Poisonous Spores",
	type = {"wild-gift/slime", 1},
	require = gifts_req1,
	random_ego = "attack",
	points = 5,
	message = "@Source@ releases poisonous spores at @target@.",
	equilibrium = 2,
	cooldown = 10,
	range = 1,
	tactical = { ATTACK = { NATURE = 1, poison = 1 } },
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.POISON, 1.5 + self:getTalentLevel(t) / 4, true)
		self.combat_apr = self.combat_apr - 1000
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Releases poisonous spores at the target bypassing his armor and doing %d%% weapon damage.]]):format(damDesc(self, DamageType.POISON, 100 * (1.5 + self:getTalentLevel(t) / 4)))
	end,
}

newTalent{
	name = "Acidic Skin",
	type = {"wild-gift/slime", 2},
	require = gifts_req2,
	points = 5,
	mode = "sustained",
	message = "The skin of @Source@ starts dripping acid.",
	sustain_equilibrium = 25,
	cooldown = 10,
	range = 1,
	tactical = { DEFEND = 1 },
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		local power = 10 + 5 * self:getTalentLevel(t)
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.ACID]=power}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		return ([[Your skin drips with acid, damaging all that hit you for %0.2f acid damage.]]):format(damDesc(self, DamageType.ACID, 10 + 5 * self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Slime Spit",
	type = {"wild-gift/slime", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "attack",
	equilibrium = 4,
	cooldown = 30,
	tactical = { ATTACK = { NATURE = 2} },
	range = 10,
	direct_hit = true,
	proj_speed = 8,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), display={particle="bolt_arcane"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.SLIME, self:mindCrit(self:combatTalentStatDamage(t, "dex", 30, 290)), {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Spit slime at your target doing %0.2f nature damage and slowing it down by 30%% for 3 turns.
		The damage will increase with the Dexterity stat]]):format(damDesc(self, DamageType.NATURE, self:combatTalentStatDamage(t, "dex", 30, 290)))
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
	getDuration = function(self, t)
		return math.floor(util.bound(7 - self:getTalentLevel(t) / 2, 2, 7))
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

		local duration = t.getDuration(self, t)

		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t.mode == "activated" and not t.innate and (not self.talents_cd[t.id] or self.talents_cd[t.id] == 0) then
				self.talents_cd[t.id] = duration
			end
		end
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[You extend slimy roots into the ground, follow them, and re-appear somewhere else in a range of %d with error margin of %d.
		The process is quite a strain on your body and all your talents will be put on cooldown for %d turns.]]):format(range, radius, duration)
	end,
}

