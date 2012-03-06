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

getRelentless = function(self, cd)
	local cd = 1
	if self:knowTalent(self.T_RELENTLESS_STRIKES) then
		local t = self:getTalentFromId(self.T_RELENTLESS_STRIKES)
		cd = 1 - t.getCooldownReduction(self, t)
	end
		return cd
	end,

newTalent{
	name = "Striking Stance",
	type = {"technique/unarmed-other", 1},
	mode = "sustained",
	hide = true,
	points = 1,
	cooldown = 12,
	tactical = { BUFF = 2 },
	type_no_req = true,
	no_npc_use = true, -- They dont need it since it auto switches anyway
	no_unlearn_last = true,
	getAttack = function(self, t) return self:getDex(25, true) end,
	getDamage = function(self, t) return self:getDex(50, true) end,
	activate = function(self, t)
		cancelStances(self)
		local ret = {
			atk = self:addTemporaryValue("combat_atk", t.getAttack(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_atk", p.atk)
		return true
	end,
	info = function(self, t)
		local attack = t.getAttack(self, t)
		local damage = t.getDamage(self, t)
		return ([[Increases your accuracy by %d and the damage multiplier of your striking talents (pugilism and finishing moves) by %d%%.
		The bonuses will scale with the Dexterity stat.]]):
		format(attack, damage)
	end,
}

newTalent{
	name = "Double Strike",  -- no stamina cost attack that will replace the bump attack under certain conditions
	type = {"technique/pugilism", 1},
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return math.ceil(3 * getRelentless(self, cd)) end,
	message = "@Source@ throws two quick punches.",
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.1, 0.8) + getStrikingStyle(self, dam) end,
	-- Learn the appropriate stance
	on_learn = function(self, t)
		if not self:knowTalent(self.T_STRIKING_STANCE) then
			self:learnTalent(self.T_STRIKING_STANCE, true, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:unlearnTalent(self.T_STRIKING_STANCE)
		end
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- force stance change
		if target and not self:isTalentActive(self.T_STRIKING_STANCE) then
			self:forceUseTalent(self.T_STRIKING_STANCE, {ignore_energy=true, ignore_cd = true})
		end

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		local hit1 = false
		local hit2 = false

		hit1 = self:attackTarget(target, nil, t.getDamage(self, t), true)
		hit2 = self:attackTarget(target, nil, t.getDamage(self, t), true)

		-- build combo points
		local combo = false

		if self:getTalentLevel(t) >= 4 then
			combo = true
		end

		if combo then
			if hit1 then
				self:buildCombo()
			end
			if hit2 then
				self:buildCombo()
			end
		elseif hit1 or hit2 then
			self:buildCombo()
		end

		return true

	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Two quick punches that deal %d%% damage each and switches your stance to Striking Stance.  If you already have Striking Stance active and Double Strike isn't on cooldown this talent will automatically replace your normal attacks (and trigger the cooldown).
		If either jab connects you earn one combo point.  At talent level 4 or greater if both jabs connect you'll earn two combo points.]])
		:format(damage)
	end,
}

newTalent{
	name = "Relentless Strikes",
	type = {"technique/pugilism", 2},
	require = techs_dex_req2,
	points = 5,
	random_ego = "utility",
	mode = "passive",
	getStamina = function(self, t) return self:getTalentLevel(t)/4 end,
	getCooldownReduction = function(self, t) return self:getTalentLevel(t)/15 end,
	info = function(self, t)
		local stamina = t.getStamina(self, t)
		local cooldown = t.getCooldownReduction(self, t)
		return ([[Reduces the cooldown on all your pugilism talents by %d%%.  Additionally every time you earn a combo point you will regain %0.2f stamina.
		Note that stamina gains from combo points occur before any talent stamina costs.]])
		:format(cooldown * 100, stamina)
	end,
}

newTalent{
	name = "Spinning Backhand",
	type = {"technique/pugilism", 3},
	require = techs_dex_req3,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return math.ceil(12 * getRelentless(self, cd)) end,
	stamina = 12,
	range = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)/2) end,
	message = "@Source@ lashes out with a spinning backhand.",
	tactical = { ATTACKAREA = { weapon = 2 }, CLOSEIN = 1 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.7) + getStrikingStyle(self, dam) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		-- bonus damage for charging
		local charge = (core.fov.distance(self.x, self.y, x, y) - 1) / 10
		local damage = t.getDamage(self, t) + charge

		-- do the rush
		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local l = self:lineFOV(x, y, block_actor)
		local lx, ly, is_corner_blocked = l:step()
		local tx, ty = self.x, self.y
		while lx and ly do
			if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
		end

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end

		local hit1 = false
		local hit2 = false
		local hit3 = false

		-- do the backhand
		if core.fov.distance(self.x, self.y, x, y) == 1 then
			-- get left and right side
			local dir = util.getDir(x, y, self.x, self.y)
			local lx, ly = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
			local rx, ry = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
			local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

			hit1 = self:attackTarget(target, nil, damage, true)

			--left hit
			if lt then
				hit2 = self:attackTarget(lt, nil, damage, true)
			end
			--right hit
			if rt then
				hit3 = self:attackTarget(rt, nil, damage, true)
			end

		end

		-- remove grappls
		self:breakGrapples()

		-- build combo points
		local combo = false

		if self:getTalentLevel(t) >= 4 then
			combo = true
		end

		if combo then
			if hit1 then
				self:buildCombo()
			end
			if hit2 then
				self:buildCombo()
			end
			if hit3 then
				self:buildCombo()
			end
		elseif hit1 or hit2 or hit3 then
			self:buildCombo()
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Attack your foes in a frontal arc with a spinning backhand doing %d%% damage.  If you're not adjacent to the target you'll step forward as you spin, gaining 10%% bonus damage for each tile you move.
		This attack will remove any grapples you're maintaining and earn one combo point (or one combo point per attack that connects if your talent level is four or greater).]])
		:format(damage)
	end,
}

newTalent{
	name = "Flurry of Fists",
	type = {"technique/pugilism", 4},
	require = techs_dex_req4,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return math.ceil(24 * getRelentless(self, cd)) end,
	stamina = 15,
	message = "@Source@ lashes out with a flurry of fists.",
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1.1) + getStrikingStyle(self, dam) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		local hit1 = false
		local hit2 = false
		local hit3 = false

		hit1 = self:attackTarget(target, nil, t.getDamage(self, t), true)
		hit2 = self:attackTarget(target, nil, t.getDamage(self, t), true)
		hit3 = self:attackTarget(target, nil, t.getDamage(self, t), true)

		--build combo points
		local combo = false

		if self:getTalentLevel(t) >= 4 then
			combo = true
		end

		if combo then
			if hit1 then
				self:buildCombo()
			end
			if hit2 then
				self:buildCombo()
			end
			if hit3 then
				self:buildCombo()
			end
		elseif hit1 or hit2 or hit3 then
			self:buildCombo()
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Lashes out at the target with three quick punches that each deal %d%% damage.
		Earns one combo point.  If your talent level is four or greater earns one combo point per blow that connects.]])
		:format(damage)
	end,
}

