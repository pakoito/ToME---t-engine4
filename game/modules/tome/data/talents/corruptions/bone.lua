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
	name = "Bone Spear",
	type = {"corruption/bone", 1},
	require = corrs_req1,
	points = 5,
	vim = 13,
	cooldown = 4,
	range = 10,
	random_ego = "attack",
	tactical = { ATTACK = {PHYSICAL = 2} },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSICAL, self:spellCrit(self:combatTalentSpellDamage(t, 20, 200)), {type="bones"})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a spear of bones doing %0.2f physical damage to all targets in line.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(t, 20, 200)))
	end,
}

newTalent{
	name = "Bone Grab",
	type = {"corruption/bone", 2},
	require = corrs_req2,
	points = 5,
	vim = 28,
	cooldown = 15,
	range = 7,
	tactical = { DISABLE = 1, CLOSEIN = 3 },
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(self:combatTalentSpellDamage(t, 5, 140))

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			target:pull(self.x, self.y, tg.range)

			DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, dam)
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, math.floor(3 + self:getTalentLevel(t)), {apply_power=self:combatSpellpower()})
			else
				game.logSeen(target, "%s resists the bone!", target.name:capitalize())
			end
		end)
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = function(self, t)
		return ([[Grab a target and teleport it to your side, pinning it there with a bone rising from the ground for %d turns.
		The bone will also deal %0.2f physical damage.
		The damage will increase with your Magic stat.]]):
		format(math.floor(3 + self:getTalentLevel(t)), damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(t, 5, 140)))
	end,
}

newTalent{
	name = "Bone Nova",
	type = {"corruption/bone", 3},
	require = corrs_req3,
	points = 5,
	vim = 25,
	cooldown = 12,
	tactical = { ATTACKAREA = {PHYSICAL = 2} },
	random_ego = "attack",
	radius = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.PHYSICAL, self:spellCrit(self:combatTalentSpellDamage(t, 8, 180)), {type="bones"})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Fire bone spears in all directions, hitting all your foes within radius %d for %0.2f physical damage.
		The damage will increase with your Magic stat.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(t, 8, 180)))
	end,
}

newTalent{
	name = "Bone Shield",
	type = {"corruption/bone", 4},
	points = 5,
	mode = "sustained", no_sustain_autoreset = true,
	require = corrs_req4,
	cooldown = 30,
	sustain_vim = 50,
	tactical = { DEFEND = 4 },
	direct_hit = true,
	absorb = function(self, t, p)
		game.logPlayer(self, "Your bone shield absorbs the damage!")
		game:onTickEnd(function() -- Happens on tick end to avoid problems
			local pid = table.remove(p.particles)
			if pid then self:removeParticles(pid) end
			if #p.particles <= 0 then
				if self:isTalentActive(t.id) then self:forceUseTalent(t.id, {ignore_energy=true}) end
			end
		end)
	end,
	activate = function(self, t)
		local nb = math.ceil(self:getTalentLevel(t))

		local ps = {}
		for i = 1, nb do ps[#ps+1] = self:addParticles(Particles.new("bone_shield", 1)) end

		game:playSoundNear(self, "talents/spell_generic2")
		return {
			particles = ps,
		}
	end,
	deactivate = function(self, t, p)
		for i, particle in ipairs(p.particles) do self:removeParticles(particle) end
		return true
	end,
	info = function(self, t)
		return ([[Bone shields start circling around you. They will each fully absorb one attack.
		%d shield(s) will be generated.]]):
		format(math.ceil(self:getTalentLevel(t)))
	end,
}
