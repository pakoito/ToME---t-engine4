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
	name = "Kinetic Strike",
	type = {"psionic/augmented-striking", 1},
	require = psi_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	psi = 10,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	getDam = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	action = function(self, t)
		local weapon = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1]
		if type(weapon) == "boolean" then weapon = nil end
		if not weapon or self:attr("disarmed")then
			game.logPlayer(self, "You cannot do that without a weapon in your hands.")
			return nil
		end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local dam = self:mindCrit(t.getDam(self, t))

		local hit = self:attackTarget(target, DamageType.PHYSICAL, self:combatTalentWeaponDamage(t, 0.5, 2.0))
		if hit then
			DamageType:get(DamageType.TK_PUSHPIN).projector(self, x, y, DamageType.TK_PUSHPIN, {push=4, dam=dam, dur=4})
		end
		
		if self:hasEffect(self.EFF_TRANSCENDENT_TELEKINESIS) then
			local dir = util.getDir(x, y, self.x, self.y)
			if dir == 5 then return nil end
			local lx, ly = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
			local rx, ry = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
			local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

			local hit
			if lt then
				hit = self:attackTarget(lt, DamageType.PHYSICAL, self:combatTalentWeaponDamage(t, 0.5, 2.0))
				if hit then DamageType:get(DamageType.TK_PUSHPIN).projector(self, lx, ly, DamageType.TK_PUSHPIN, {push=4, dam=dam, dur=4}) end
			end

			if rt then
				hit = self:attackTarget(rt, DamageType.PHYSICAL, self:combatTalentWeaponDamage(t, 0.5, 2.0))
				if hit then DamageType:get(DamageType.TK_PUSHPIN).projector(self, rx, ry, DamageType.TK_PUSHPIN, {push=4, dam=dam, dur=4}) end
			end
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Focus kinetic energy and strike an enemy for %d%% weapon damage as physical.
		They will then be thrown back by the force of the hit, taking an extra %0.1f Physical damage if they hit a wall, where they will be pinned for 4 turns.
		The knockback damage will scale with your Mindpower.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.5, 2.0), damDesc(self, DamageType.PHYSICAL, t.getDam(self, t)))
	end,
}


newTalent{
	name = "Thermal Strike",
	type = {"psionic/augmented-striking", 1},
	require = psi_wil_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	psi = 10,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { COLD = 2 } },
	getDam = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	action = function(self, t)
		local weapon = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1]
		if type(weapon) == "boolean" then weapon = nil end
		if not weapon or self:attr("disarmed")then
			game.logPlayer(self, "You cannot do that without a weapon in your hands.")
			return nil
		end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local dam = self:mindCrit(t.getDam(self, t))

		local hit = self:attackTarget(target, DamageType.COLD, self:combatTalentWeaponDamage(t, 0.5, 2.0))
		if hit then
			if self:hasEffect(self.EFF_TRANSCENDENT_PYROKINESIS) then
				local tg = {type="ball", range=1, radius=1, friendlyfire=false}
				self:project(tg, x, y, DamageType.COLD, dam)
				self:project(tg, x, y, DamageType.FREEZE, {dur=4, hp=dam})
				game.level.map:particleEmitter(x, y, tg.radius, "iceflash", {radius=1})
			else
				DamageType:get(DamageType.COLD).projector(self, x, y, DamageType.COLD, dam)
				DamageType:get(DamageType.FREEZE).projector(self, x, y, DamageType.FREEZE, {dur=4, hp=dam})
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Focus thermal energy and strike an enemy for %d%% weapon damage as cold.
		A burst of cold will then engulf them, doing an extra %0.1f Cold damage and also freeze them for 4 turns.
		The cold burst damage will scale with your Mindpower.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.5, 2.0), damDesc(self, DamageType.COLD, t.getDam(self, t)))
	end,
}

newTalent{
	name = "Charged Strike",
	type = {"psionic/augmented-striking", 1},
	require = psi_wil_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	psi = 10,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { LIGHTNING = 2 } },
	getDam = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	action = function(self, t)
		local weapon = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1]
		if type(weapon) == "boolean" then weapon = nil end
		if not weapon or self:attr("disarmed")then
			game.logPlayer(self, "You cannot do that without a weapon in your hands.")
			return nil
		end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local dam = self:mindCrit(t.getDam(self, t))

		local hit = self:attackTarget(target, DamageType.LIGHTNING, self:combatTalentWeaponDamage(t, 0.5, 2.0))
		if hit then
			if self:hasEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS) then
				tg = {type="bolt", range=self:getTalentRange(t), talent=t}
				local fx, fy = x, y
				if not fx or not fy then return nil end

				local nb = 4
				local affected = {}
				local first = nil

				self:project(tg, fx, fy, function(dx, dy)
					print("[Chain lightning] targetting", fx, fy, "from", self.x, self.y)
					local actor = game.level.map(dx, dy, Map.ACTOR)
					if actor and not affected[actor] then
						affected[actor] = true
						first = actor

						print("[Chain lightning] looking for more targets", nb, " at ", dx, dy, "radius ", 3, "from", actor.name)
						self:project({type="ball", selffire=false, x=dx, y=dy, radius=3, range=0}, dx, dy, function(bx, by)
							local actor = game.level.map(bx, by, Map.ACTOR)
							if actor and not affected[actor] and self:reactionToward(actor) < 0 then
								print("[Chain lightning] found possible actor", actor.name, bx, by, "distance", core.fov.distance(dx, dy, bx, by))
								affected[actor] = true
							end
						end)
						return true
					end
				end)

				if not first then return end
				local targets = { first }
				affected[first] = nil
				local possible_targets = table.listify(affected)
				print("[Chain lightning] Found targets:", #possible_targets)
				for i = 2, nb do
					if #possible_targets == 0 then break end
					local act = rng.tableRemove(possible_targets)
					targets[#targets+1] = act[1]
				end

				local sx, sy = self.x, self.y
				for i, actor in ipairs(targets) do
					local tgr = {type="beam", range=self:getTalentRange(t), selffire=false, talent=t, x=sx, y=sy}
					print("[Chain lightning] jumping from", sx, sy, "to", actor.x, actor.y)
					self:project(tgr, actor.x, actor.y, DamageType.LIGHTNING, dam)
					self:project(tgr, actor.x, actor.y, DamageType.BLINDCUSTOMMIND, {apply_power=self:combatMindpower(), turns=4})
					if core.shader.active() then game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning_beam", {tx=actor.x-sx, ty=actor.y-sy}, {type="lightning"})
					else game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning_beam", {tx=actor.x-sx, ty=actor.y-sy})
					end

					sx, sy = actor.x, actor.y
				end
			else
				DamageType:get(DamageType.LIGHTNING).projector(self, x, y, DamageType.LIGHTNING, dam)
				DamageType:get(DamageType.BLINDCUSTOMMIND).projector(self, x, y, DamageType.BLINDCUSTOMMIND, {apply_power=self:combatMindpower(), turns=4})
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Focus charged energy and strike an enemy for %d%% weapon damage as lightning.
		Energy will then discharge from your weapon, doing an extra %0.1f Lightning damage and blinding them for 4 turns.
		The discharge damage will scale with your Mindpower.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.5, 2.0), damDesc(self, DamageType.LIGHTNING, t.getDam(self, t)))
	end,
}

newTalent{
	name = "Psi Tap",
	type = {"psionic/augmented-striking", 4},
	mode = "passive",
	points = 5,
	require = psi_wil_req4,
	getPsiRecover = function(self, t) return self:combatTalentScale(t, 1, 3) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "psi_regen_on_hit", t.getPsiRecover(self, t))
	end,
	info = function(self, t)
		return ([[Siphon excess energy from each weapon hit you land, gaining %0.1f psi per hit.]]):format(t.getPsiRecover(self, t))
	end,
}

