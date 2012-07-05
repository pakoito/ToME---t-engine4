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
	name = "Stone Vines",
	type = {"wild-gift/earthen-vines", 1},
	require = gifts_req1,
	points = 5,
	mode = "sustained",
	sustain_equilibrium = 15,
	cooldown = 30,
	tactical = { ATTACK = { PHYSICAL = 2 }, BUFF = 2, DISABLE = { pin = 2 } },
	radius = function(self, t) return 4 + math.ceil(self:getTalentLevel(t) / 2) end,
	getValues = function(self, t) return 4 + self:getTalentLevelRaw(t), self:combatTalentStatDamage(t, "wil", 3, 50) end,
	do_vines = function(self, t)
		local p = self:isTalentActive(t.id)
		local rad = self:getTalentRadius(t)

		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, rad, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 and not a:hasEffect(a.EFF_STONE_VINE) then
				tgts[#tgts+1] = a
			end
		end end
		if #tgts <= 0 then return end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local a, id = rng.table(tgts)
		local hit, chance = a:checkHit(self:combatTalentStatDamage(t, "wil", 5, 110), a:combatPhysicalResist(), 0, 95, 5)
		if a:canBe("pin") and hit then
			local turns, dam = t.getValues(self, t)
			a:setEffect(a.EFF_STONE_VINE, turns, {dam=dam, src=self, free=rad*2, free_chance=100-chance})
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(a.x-self.x), math.abs(a.y-self.y)), "stonevine", {tx=a.x-self.x, ty=a.y-self.y})
			game:playSoundNear(self, "talents/stone")
		end
	end,
	activate = function(self, t)
		return {
			movid = self:addTemporaryValue("movement_speed", -0.5),
			particle = self:addParticles(Particles.new("stonevine_static", 1, {})),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("movement_speed", p.movid)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		local turns, dam = t.getValues(self, t)
		return ([[Living stone vines extend from your feet, each turn the vines will randomly target a creature in a radius of %d.
		Affected creatures are pinned to the ground and take %0.2f physical damage for %d turns.
		Targets will be free from the vines if they are at least %d grids away from you.
		While earthen vines are active your movement speed is reduced by 50%%.
		Each turn a creature entangled by the vines will have a chance to break free.
		The damage will increase with Willpower stats.]]):
		format(rad, damDesc(self, DamageType.PHYSICAL, dam), turns, rad*2)
	end,
}

newTalent{
	name = "Eldritch Vines",
	type = {"wild-gift/earthen-vines", 2},
	require = gifts_req2,
	points = 5,
	mode = "passive",
	info = function(self, t)
		return ([[Each time a vine deal damage to a creature it will restore %0.2f equilibrium and %0.2f mana.]])
		:format(self:getTalentLevel(t) / 4, self:getTalentLevel(t) / 3)
	end,
}

newTalent{
	name = "Rockwalk",
	type = {"wild-gift/earthen-vines", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 15,
	cooldown = 10,
	requires_target = true,
	range = 20,
	tactical = { HEAL = 2, CLOSEIN = 2 },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if not target:hasEffect(target.EFF_STONE_VINE) then return nil end

		self:attr("allow_on_heal", 1)
		self:heal(100 + self:combatTalentStatDamage(t, "wil", 40, 630))
		self:attr("allow_on_heal", -1)
		local tx, ty = util.findFreeGrid(x, y, 2, true, {[Map.ACTOR]=true})
		if tx and ty then
			local ox, oy = self.x, self.y
			self:move(tx, ty, true)
			if config.settings.tome.smooth_move > 0 then
				self:resetMoveAnim()
				self:setMoveAnim(ox, oy, 8, 5)
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Merge with a stone vine, travelling alongside it to reappear near an entangled creature.
		Merging with the stone is beneficial for you, healing %0.2f life.
		Healing will increase with Willpower.]])
		:format(100 + self:combatTalentStatDamage(t, "wil", 40, 630))
	end,
}

newTalent{
	name = "Rockswallow",
	type = {"wild-gift/earthen-vines", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 15,
	cooldown = 10,
	requires_target = true,
	range = 20,
	tactical = { ATTACK = { PHYSICAL = 2 }, CLOSEIN = 2 },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if not target:hasEffect(target.EFF_STONE_VINE) then return nil end

		DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, 80 + self:combatTalentStatDamage(t, "wil", 40, 330))

		if target.dead then return end

		local tx, ty = util.findFreeGrid(self.x, self.y, 2, true, {[Map.ACTOR]=true})
		if tx and ty then
			local ox, oy = target.x, target.y
			target:move(tx, ty, true)
			if config.settings.tome.smooth_move > 0 then
				target:resetMoveAnim()
				target:setMoveAnim(ox, oy, 8, 5)
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Merge your target with a stone vine, forcing it to travel alongside it to reappear near you.
		Merging with the stone is detrimental for the target, dealing %0.2f physical damage.
		Damage will increase with Willpower.]])
		:format(80 + self:combatTalentStatDamage(t, "wil", 40, 330))
	end,
}
