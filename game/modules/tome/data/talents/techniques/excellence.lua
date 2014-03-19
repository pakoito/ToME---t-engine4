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
	name = "Shoot Down",
	type = {"technique/archery-excellence", 1},
	no_energy = true,
	points = 5,
	cooldown = 4,
	stamina = 20,
	range = archery_range,
	require = techs_dex_req_high1,
	onAIGetTarget = function(self, t)
		local tgts = {}
		self:project({type="ball", radius=self:getTalentRange(t)}, self.x, self.y, function(px, py)
			local tgt = game.level.map(px, py, Map.PROJECTILE)
			if tgt and (not tgt.src or self:reactionToward(tgt.src) < 0) then tgts[#tgts+1] = {x=px, y=py, tgt=tgt, dist=core.fov.distance(self.x, self.y, px, py)} end
		end)
		table.sort(tgts, function(a, b) return a.dist < b.dist end)
		if #tgts > 0 then return tgts[1].x, tgts[1].y, tgts[1].tgt end
	end,
	on_pre_use_ai = function(self, t, silent) return t.onAIGetTarget(self, t) and true or false end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	requires_target = true,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), scan_on=engine.Map.PROJECTILE, no_first_target_filter=true}
	end,
	tactical = {SPECIAL=10},
	action = function(self, t)
		for i = 1, t.getNb(self, t) do
			local targets = self:archeryAcquireTargets(self:getTalentTarget(t), {one_shot=true, no_energy=true})
			if (not targets or #targets == 0) then if i == 1 then return else break end end

			local x, y = targets[1].x, targets[1].y
			local proj = game.level.map(x, y, Map.PROJECTILE)
			if proj then
				proj:terminate(x, y)
				game.level:removeEntity(proj, true)
				proj.dead = true
				self:logCombat(proj, "#Source# shoots down '#Target#'.")
			end
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Your reflexes are lightning-fast, if you spot a projectile (arrow, shot, spell, ...) you can instantly shoot at it without taking a turn to take it down.
		You can shoot down up to %d projectiles.]]):
		format(t.getNb(self, t))
	end,
}

newTalent{
	name = "Bull Shot",
	type = {"technique/archery-excellence", 2},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 18,
	require = techs_dex_req_high2,
	range = archery_range,
	tactical = { ATTACK = { weapon = 1 } },
	requires_target = true,
	on_pre_use = function(self, t, silent)
		if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end
		if self:attr("never_move") then return false end
		return true
	end,
	getDist = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 4, 8)) end,
	archery_onhit = function(self, t, target, x, y)
		if not target or not target:canBe("knockback") then return end
		target:knockback(self.x, self.y, t.getDist(self, t))
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local linestep = self:lineFOV(x, y, block_actor)
		
		local tx, ty, lx, ly, is_corner_blocked 
		repeat  -- make sure each tile is passable
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = linestep:step()
		until is_corner_blocked or not lx or not ly or game.level.map:checkAllEntities(lx, ly, "block_move", self)
		if not tx or core.fov.distance(self.x, self.y, tx, ty) < 1 then
			game.logPlayer(self, "You are too close to build up momentum!")
			return
		end
		if not tx or not ty or core.fov.distance(x, y, tx, ty) > 1 then return nil end

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end
		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) == 1 then
			local targets = self:archeryAcquireTargets(nil, {one_shot=true, x=x, y=y})
			if targets then
				self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1.5, 2.8)})
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[You rush toward your foe, readying your shot. If you reach the enemy, you release the shot, imbuing it with great power.
		The shot does %d%% weapon damage and knocks back your target by %d.]]):
		format(self:combatTalentWeaponDamage(t, 1.5, 2.8) * 100, t.getDist(self, t))
	end,
}

newTalent{
	name = "Intuitive Shots",
	type = {"technique/archery-excellence", 3},
	mode = "sustained",
	points = 5,
	cooldown = 10,
	sustain_stamina = 30,
	no_reload_break = true,
	no_energy = true,
	require = techs_dex_req_high3,
	tactical = { BUFF = 2 },
	getDist = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 1, 3)) end, -- Limit <=10
	getChance = function(self, t) return math.floor(self:combatTalentLimit(t, 100, 20, 50)) end,
	archery_onhit = function(self, t, target, x, y)
		if not target or not target:canBe("knockback") then return end
		target:knockback(self.x, self.y, t.getDist(self, t))
	end,
	-- called by _M:attackTarget in mod.class.interface.Combat.lua
	proc = function(self, t, target)
		local weapon, ammo = self:hasArcheryWeapon()
		if not weapon then return end
		if self.turn_procs.intuitive_shots and self.turn_procs.intuitive_shots ~= target then return end
		if self.turn_procs.intuitive_shots == target then return true end
		local targets = self:archeryAcquireTargets(nil, {one_shot=true, x=target.x, y=target.y}) --Ammo check done here
		if not targets then return end 
		self.turn_procs.intuitive_shots = target
		local xatk, ret = 1e6, true
		--Precheck hit chance so a miss doesn't stop the melee attack
		if not self:checkHit(self:combatAttackRanged(weapon, ammo), target:combatDefenseRanged()) or target:checkEvasion(self) then 
			xatk, ret = -1e6, false
		end
		game.logSeen(self, "%s %s the attack!", self.name:capitalize(), ret and "intercepts" or "fails to intercept")
		self:archeryShoot(targets, t, nil, {atk = xatk, mult=self:combatTalentWeaponDamage(t, 0.4, 0.9)})
		return ret
	end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Activating this talent enhances your reflexes to incredible levels.  Each time you are attacked in melee, you have a %d%% chance get a defensive shot off in time to intercept the attack, fully disrupting it (including extra blows from certain talents), dealing %d%% archery damage, and knocking the attacker back %d tiles.
		Activating this talent will not interrupt reloading.]])
		:format(t.getChance(self, t), self:combatTalentWeaponDamage(t, 0.4, 0.9) * 100, t.getDist(self, t))
	end,
}

newTalent{
	name = "Strangling Shot",
	type = {"technique/archery-excellence", 4},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	stamina = 20,
	require = techs_dex_req_high4,
	range = archery_range,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = { silence = 3 } },
	requires_target = true,
	target = function(self, t)
		local weapon, ammo = self:hasArcheryWeapon()
		return {type="bolt", range=self:getTalentRange(t), display=self:archeryDefaultProjectileVisual(weapon, ammo)}
	end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "You require a bow or sling for this talent.") end return false end return true end,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("silence") then
			target:setEffect(target.EFF_SILENCED, t.getDur(self, t), {apply_power=self:combatAttack()})
		else
			game.logSeen(target, "%s resists the strangling shot!", target.name:capitalize())
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local targets = self:archeryAcquireTargets(tg, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, tg, {mult=self:combatTalentWeaponDamage(t, 0.9, 1.7)})
		return true
	end,
	info = function(self, t)
		return ([[You fire a shot at your target's throat, mouth, or equivalent body part, doing %d%% damage and silencing it for %d turns.
		The silence chance increases with your Accuracy.]])
		:format(self:combatTalentWeaponDamage(t, 0.9, 1.7) * 100, t.getDur(self,t))
	end,
}
