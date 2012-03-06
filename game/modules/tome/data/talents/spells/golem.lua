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

------------------------------------------------------------------
-- Melee
------------------------------------------------------------------

newTalent{
	name = "Knockback", short_name = "GOLEM_KNOCKBACK",
	type = {"golem/fighting", 1},
	require = techs_req1,
	points = 5,
	cooldown = 10,
	range = 5,
	stamina = 5,
	requires_target = true,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), min_range=2}
	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.6) end,
	tactical = { DEFEND = { knockback = 2 }, DISABLE = { knockback = 1 } },
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "Your golem can not do that currently.") return end

		local tg = self:getTalentTarget(t)
		local olds = game.target.source_actor
		game.target.source_actor = self
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = olds
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		if self.ai_target then self.ai_target.target = target end

		if core.fov.distance(self.x, self.y, x, y) > 1 then
			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then
				game.logPlayer(self, "You are too close to build up momentum!")
				return
			end
			local tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
			while lx and ly do
				if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
				tx, ty = lx, ly
				lx, ly, is_corner_blocked = l:step()
			end

			self:move(tx, ty, true)
		end

		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) > 1 then return true end
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		-- Try to knockback !
		if hit then
			if target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
				target:knockback(self.x, self.y, 3)
				target:crossTierEffect(target.EFF_OFFBALANCE, self:combatPhysicalpower())
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Your golem rushes to the target, knocking it back and doing %d%% damage.
		Knockback chance will increase with talent level.]]):format(100 * damage)
	end,
}

newTalent{
	name = "Taunt", short_name = "GOLEM_TAUNT",
	type = {"golem/fighting", 2},
	require = techs_req2,
	points = 5,
	cooldown = function(self, t)
		return 20 - self:getTalentLevelRaw(t) * 2
	end,
	range = 10,
	radius = function(self, t)
		return self:getTalentLevelRaw(t) / 2
	end,
	stamina = 5,
	requires_target = true,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), friendlyfire=false}
	end,
	tactical = { PROTECT = 3 },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local olds = game.target.source_actor
		game.target.source_actor = self
		local x, y = self:getTarget(tg)
		game.target.source_actor = olds
		if not x or not y then return nil end

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			if self:reactionToward(target) < 0 then
				if self.ai_target then self.ai_target.target = target end
				target:setTarget(self)
				game.logSeen(self, "%s provokes %s to attack it.", self.name:capitalize(), target.name)
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Orders your golem to taunt targets in a radius of %d, forcing it to attack the golem.]]):format(self:getTalentLevelRaw(t) / 2 + 1)
	end,
}

newTalent{
	name = "Crush", short_name = "GOLEM_CRUSH",
	type = {"golem/fighting", 3},
	require = techs_req3,
	points = 5,
	cooldown = 10,
	range = 5,
	stamina = 5,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.6) end,
	getPinDuration = function(self, t) return 2 + self:getTalentLevel(t) end,
	tactical = { ATTACK = { PHYSICAL = 0.5 }, DISABLE = { pin = 2 } },
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "Your golem can not do that currently.") return end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local olds = game.target.source_actor
		game.target.source_actor = self
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = olds
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		if self.ai_target then self.ai_target.target = target end

		if core.fov.distance(self.x, self.y, x, y) > 1 then
			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then
				game.logPlayer(self, "You are too close to build up momentum!")
				return
			end
			local tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
			while lx and ly do
				if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
				tx, ty = lx, ly
				lx, ly, is_corner_blocked = l:step()
			end

			self:move(tx, ty, true)
		end

		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) > 1 then return true end
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		-- Try to pin
		if hit then
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, t.getPinDuration(self, t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s resists the crushing!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getPinDuration(self, t)
		return ([[Your golem rushes to the target, crushing it to the ground for %d turns and doing %d%% damage.
		Pinning chance will increase with talent level.]]):
		format(duration, 100 * damage)
	end,
}

newTalent{
	name = "Pound", short_name = "GOLEM_POUND",
	type = {"golem/fighting", 4},
	require = techs_req4,
	points = 5,
	cooldown = 15,
	range = 5,
	radius = 2,
	stamina = 5,
	requires_target = true,
	target = function(self, t)
		return {type="ballbolt", radius=self:getTalentRadius(t), friendlyfire=false, range=self:getTalentRange(t)}
	end,
	getGolemDamage = function(self, t)
		return self:combatTalentWeaponDamage(t, 0.4, 1.1)
	end,
	getDazeDuration = function(self, t) return 2 + self:getTalentLevel(t) end,
	tactical = { ATTACKAREA = { PHYSICAL = 0.5 }, DISABLE = { daze = 3 } },
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "Your golem can not do that currently.") return end

		local tg = self:getTalentTarget(t)
		local olds = game.target.source_actor
		game.target.source_actor = self
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = olds
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		if core.fov.distance(self.x, self.y, x, y) > 1 then
			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then
				game.logPlayer(self, "You are too close to build up momentum!")
				return
			end
			local tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
			while lx and ly do
				if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
				tx, ty = lx, ly
				lx, ly, is_corner_blocked = l:step()
			end

			self:move(tx, ty, true)
		end

		if self.ai_target then self.ai_target.target = target end

		-- Attack & daze
		tg.type = "ball"
		self:project(tg, self.x, self.y, function(xx, yy)
			if xx == self.x and yy == self.y then return end
			local target = game.level.map(xx, yy, Map.ACTOR)
			if target and self:attackTarget(target, nil, t.getGolemDamage(self, t), true) then
				if target:canBe("stun") then
					target:setEffect(target.EFF_DAZED, t.getDazeDuration(self, t), {apply_power=self:combatPhysicalpower()})
				else
					game.logSeen(target, "%s resists the dazing blow!", target.name:capitalize())
				end
			end
		end)

		return true
	end,
	info = function(self, t)
		local duration = t.getDazeDuration(self, t)
		local damage = t.getGolemDamage(self, t)
		return ([[Your golem rushes to the target, pounding the area of radius 2, dazing all foes for %d turns and doing %d%% damage.
		Daze chance increases with talent level.]]):
		format(duration, 100 * damage)
	end,
}


------------------------------------------------------------------
-- Arcane
------------------------------------------------------------------

newTalent{
	name = "Eye Beam", short_name = "GOLEM_BEAM",
	type = {"golem/arcane", 1},
	require = spells_req1,
	points = 5,
	cooldown = 3,
	range = 7,
	mana = 10,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 320) end,
	tactical = { ATTACK = { FIRE = 1, COLD = 1, LIGHTNING = 1 } },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if self.x == x and self.y == y then return nil end

		-- We will always project the beam as far as possible
		local l = self:lineFOV(x, y)
		l:set_corner_block()
		local lx, ly, is_corner_blocked = l:step(true)
		local target_x, target_y = lx, ly
		-- Check for terrain and friendly actors
		while lx and ly and not is_corner_blocked and core.fov.distance(self.x, self.y, lx, ly) <= tg.range do
			local actor = game.level.map(lx, ly, engine.Map.ACTOR)
			if actor and (self:reactionToward(actor) >= 0) then
				break
			elseif game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then
				target_x, target_y = lx, ly
				break
			end
			target_x, target_y = lx, ly
			lx, ly = l:step(true)
		end
		x, y = target_x, target_y

		local typ = rng.range(1, 3)

		if typ == 1 then
			self:project(tg, x, y, DamageType.FIRE, self:spellCrit(t.getDamage(self, t)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
		elseif typ == 2 then
			self:project(tg, x, y, DamageType.LIGHTNING, self:spellCrit(t.getDamage(self, t)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
		else
			self:project(tg, x, y, DamageType.COLD, self:spellCrit(t.getDamage(self, t)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "icebeam", {tx=x-self.x, ty=y-self.y})
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Fire a beam from your eyes doing %0.2f fire damage, %0.2f cold damage or %0.2f lightning damage.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.FIRE, damage), damDesc(self, DamageType.COLD, damage), damDesc(self, DamageType.LIGHTNING, damage))
	end,
}

newTalent{
	name = "Reflective Skin", short_name = "GOLEM_REFLECTIVE_SKIN",
	type = {"golem/arcane", 2},
	require = spells_req2,
	points = 5,
	mode = "sustained",
	cooldown = 70,
	range = 10,
	sustain_mana = 30,
	requires_target = true,
	tactical = { DEFEND = 1, SURROUNDED = 3, BUFF = 1 },
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			tmpid = self:addTemporaryValue("reflect_damage", 20 + self:combatTalentSpellDamage(t, 12, 40))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("reflect_damage", p.tmpid)
		return true
	end,
	info = function(self, t)
		return ([[Your golem's skin shimmers with eldritch energies.
		Any damage it takes is partly reflected (%d%%) to the attacker.
		The golem still takes full damage.
		Damage returned will increase with your Spellpower.]]):
		format(20 + self:combatTalentSpellDamage(t, 12, 40))
	end,
}

newTalent{
	name = "Arcane Pull", short_name = "GOLEM_ARCANE_PULL",
	type = {"golem/arcane", 3},
	require = spells_req3,
	points = 5,
	cooldown = 15,
	range = 0,
	radius = function(self, t)
		return 3 + self:getTalentLevel(t) / 2
	end,
	mana = 20,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	tactical = { ATTACKAREA = { ARCANE = 2 }, CLOSEIN = 1 },
	getDamage = function(self, t)
		return self:combatTalentSpellDamage(t, 12, 120)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tgts = {}
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				tgts[#tgts+1] = {actor=target, sqdist=core.fov.distance(self.x, self.y, px, py)}
			end
		end)
		table.sort(tgts, "sqdist")
		for i, target in ipairs(tgts) do
			target.actor:pull(self.x, self.y, tg.radius)
			game.logSeen(target.actor, "%s is pulled by %s!", target.actor.name:capitalize(), self.name)
			DamageType:get(DamageType.ARCANE).projector(self, target.actor.x, target.actor.y, DamageType.ARCANE, t.getDamage(self, t))
		end
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		local dam = t.getDamage(self, t)
		return ([[Your golem pulls all foes within %d toward itself, also dealing %0.2f arcane damage.]]):
		format(rad, dam)
	end,
}

newTalent{
	name = "Molten Skin", short_name = "GOLEM_MOLTEN_SKIN",
	type = {"golem/arcane", 4},
	require = spells_req4,
	points = 5,
	mana = 60,
	cooldown = 15,
	range = 0,
	radius = 3,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	tactical = { ATTACKAREA = { FIRE = 2 } },
	action = function(self, t)
		local duration = 5 + self:getTalentLevel(t)
		local dam = self:combatTalentSpellDamage(t, 12, 120)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.GOLEM_FIREBURN, dam,
			self:getTalentRadius(t),
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=200, color_bg=60, color_bb=30},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			false
		)
		self:setEffect(self.EFF_MOLTEN_SKIN, duration, {power=30 + self:combatTalentSpellDamage(t, 12, 60)})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[Turns the golems skin into molten rock. The heat generated sets ablaze all inside a radius of 3 for doing %0.2f fire damage in 3 turns for %d turns.
		Burning is cumulative, the longer they stay in they higher the fire damage they take.
		In addition the golem gains %d%% fire resistance.
		Molten Skin damage will not affect the golem's master.
		The damage and resistance will increase with your Spellpower.]]):format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 12, 120)), 5 + self:getTalentLevel(t), 30 + self:combatTalentSpellDamage(t, 12, 60))
	end,
}

newTalent{
	name = "Self-destruction", short_name = "GOLEM_DESTRUCT",
	type = {"golem/golem", 1},
	points = 1,
	range = 0,
	radius = 4,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	tactical = { ATTACKAREA = { FIRE = 3 } },
	no_npc_use = true,
	on_pre_use = function(self, t)
		return self.summoner and self.summoner.dead
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.FIRE, 50 + 10 * self.level)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_fire", {radius=tg.radius})
		game:playSoundNear(self, "talents/fireflash")
		self:die(self)
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		return ([[The golem self-destructs, destroying itself and generating a blast of fire in a radius of %d, doing %0.2f fire damage.
		This spell is only usable when the golem's master is dead.]]):format(rad, damDesc(self, DamageType.FIRE, 50 + 10 * self.level))
	end,
}

