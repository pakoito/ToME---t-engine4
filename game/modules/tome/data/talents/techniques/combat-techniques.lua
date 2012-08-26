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

----------------------------------------------------
-- Active techniques
----------------------------------------------------
newTalent{
	name = "Rush",
	type = {"technique/combat-techniques-active", 1},
	message = "@Source@ rushes out!",
	require = techs_strdex_req1,
	points = 5,
	random_ego = "attack",
	stamina = 22,
	cooldown = function(self, t) return math.floor(40 - self:getTalentLevel(t) * 4) end,
	tactical = { ATTACK = { weapon = 1, stun = 1 }, CLOSEIN = 3 },
	requires_target = true,
	range = function(self, t) return math.floor(5 + self:getTalentLevelRaw(t)) end,
	on_pre_use = function(self, t)
		if self:attr("never_move") then return false end
		return true
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

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

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end

		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) == 1 then
			if self:knowTalent(self.T_STEAMROLLER) then target:setEffect(target.EFF_STEAMROLLER, 2, {src=self}) end

			if self:attackTarget(target, nil, 1.2, true) and target:canBe("stun") then
				-- Daze, no save
				target:setEffect(target.EFF_DAZED, 3, {})
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Rushes toward your target with incredible speed. If the target is reached you get a free attack doing 120% weapon damage.
		If the attack hits the target is dazed for 3 turns.
		You must rush from at least 2 tiles away.]])
	end,
}

newTalent{
	name = "Precise Strikes",
	type = {"technique/combat-techniques-active", 2},
	mode = "sustained",
	points = 5,
	require = techs_strdex_req2,
	cooldown = 30,
	sustain_stamina = 30,
	tactical = { BUFF = 1 },
	activate = function(self, t)
		return {
			speed = self:addTemporaryValue("combat_physspeed", -0.10),
			atk = self:addTemporaryValue("combat_atk", 4 + (self:getTalentLevel(t) * self:getDex()) / 15),
			crit = self:addTemporaryValue("combat_physcrit", 4 + (self:getTalentLevel(t) * self:getDex()) / 25),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physspeed", p.speed)
		self:removeTemporaryValue("combat_physcrit", p.crit)
		self:removeTemporaryValue("combat_atk", p.atk)
		return true
	end,
	info = function(self, t)
		return ([[You focus your strikes, reducing your attack speed by %d%% and increasing your accuracy by %d and critical chance by %d%%.
		The effects will increase with your Dexterity stat.]]):
		format(10, 4 + (self:getTalentLevel(t) * self:getDex()) / 15, 4 + (self:getTalentLevel(t) * self:getDex()) / 25)
	end,
}

newTalent{
	name = "Perfect Strike",
	type = {"technique/combat-techniques-active", 3},
	points = 5,
	random_ego = "attack",
	cooldown = 25,
	stamina = 10,
	require = techs_strdex_req3,
	no_energy = true,
	tactical = { ATTACK = 4 },
	action = function(self, t)
		self:setEffect(self.EFF_ATTACK, 1 + self:getTalentLevel(t), {power=100})
		return true
	end,
	info = function(self, t)
		return ([[You have learned to focus your blows to hit your target, granting +100 accuracy and allowing you to attack creatures you can not see without penalty for the next %d turns.]]):format(1 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Blinding Speed",
	type = {"technique/combat-techniques-active", 4},
	points = 5,
	random_ego = "utility",
	cooldown = 55,
	stamina = 25,
	no_energy = true,
	require = techs_strdex_req4,
	tactical = { BUFF = 2, CLOSEIN = 2, ESCAPE = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_SPEED, 5, {power=self:getTalentLevel(t) * 0.09})
		return true
	end,
	info = function(self, t)
		return ([[Through rigorous training you have learned to focus your actions for a short while, increasing your speed by %d%% for 5 turns.]]):format(self:getTalentLevel(t) * 9)
	end,
}

----------------------------------------------------
-- Passive techniques
----------------------------------------------------
newTalent{
	name = "Quick Recovery",
	type = {"technique/combat-techniques-passive", 1},
	require = techs_strdex_req1,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.stamina_regen = self.stamina_regen + 0.5
	end,
	on_unlearn = function(self, t)
		self.stamina_regen = self.stamina_regen - 0.5
	end,
	info = function(self, t)
		return ([[Your combat focus allows you to regenerate stamina faster (+%0.2f stamina/turn).]]):format(self:getTalentLevelRaw(t) / 2)
	end,
}

newTalent{
	name = "Fast Metabolism",
	type = {"technique/combat-techniques-passive", 2},
	require = techs_strdex_req2,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.life_regen = self.life_regen + 1
	end,
	on_unlearn = function(self, t)
		self.life_regen = self.life_regen - 1
	end,
	info = function(self, t)
		return ([[Your combat focus allows you to regenerate life faster (+%0.2f life/turn).]]):format(self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Spell Shield",
	type = {"technique/combat-techniques-passive", 3},
	require = techs_strdex_req3,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.combat_spellresist = self.combat_spellresist + 8
	end,
	on_unlearn = function(self, t)
		self.combat_spellresist = self.combat_spellresist - 8
	end,
	info = function(self, t)
		return ([[Rigorous training allows you to be more resistant to some spell effects. (+%d spell save).]]):format(self:getTalentLevelRaw(t) * 8)
	end,
}

newTalent{
	name = "Unending Frenzy",
	type = {"technique/combat-techniques-passive", 4},
	require = techs_strdex_req4,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[You revel in the death of your foes, regaining %d stamina with each death.]]):format(self:getTalentLevel(t) * 4)
	end,
}

