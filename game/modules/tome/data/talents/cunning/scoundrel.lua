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

local Map = require "engine.Map"

newTalent{
	name = "Lacerating Strikes",
	type = {"cunning/scoundrel", 1},
	mode = "passive",
	points = 5,
	require = cuns_req1,
	mode = "passive",
	do_cut = function(self, t, target, dam)
		if target:canBe("cut") and rng.percent(10+(self:getTalentLevel(t)*10)) then
			dam = dam * self:combatTalentWeaponDamage(t, 0.15, 0.35)
			target:setEffect(target.EFF_CUT, 10, {src=self, power=(dam / 10)})
		end
	end,
	info = function(self, t)
		return ([[Rend your foe with every attack you do. All attacks now have a %d%% chance of inflicting an additional %d%% of your attack's damage in Bleeding damage, divided over ten turns.]]):
		format(10+(self:getTalentLevel(t)*10),100 * self:combatTalentWeaponDamage(t, 0.15, 0.35))
	end,
}

newTalent{
	name = "Scoundrel's Strategies", short_name = "SCOUNDREL",
	type = {"cunning/scoundrel", 2},
	require = cuns_req2,
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)/2) end,
	getMovePenalty = function(self, t) return (5 + self:combatTalentStatDamage(t, "cun", 10, 30)) / 100 end,
	getAttackPenalty = function(self, t) return 5 + self:combatTalentStatDamage(t, "cun", 5, 20) end,
	getWillPenalty = function(self, t) return 5 + self:combatTalentStatDamage(t, "cun", 5, 20) end,
	getCunPenalty = function(self, t) return 5 + self:combatTalentStatDamage(t, "cun", 5, 20) end,
	do_scoundrel = function(self, t, target)
		if not rng.percent(5+(self:getTalentLevel(t)*3)) then return end
		if rng.percent(50) then
			if target:hasEffect(target.EFF_DISABLE) then return end
			target:setEffect(target.EFF_DISABLE, t.getDuration(self, t), {speed=t.getMovePenalty(self, t), atk=t.getAttackPenalty(self, t), apply_power=self:combatAttack()})
		else
			if target:hasEffect(target.EFF_ANGUISH) then return end
			target:setEffect(target.EFF_ANGUISH, t.getDuration(self, t), {will=t.getWillPenalty(self, t), cun=t.getCunPenalty(self, t), apply_power=self:combatAttack()})
		end
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local move = t.getMovePenalty(self, t)
		local attack = t.getAttackPenalty(self, t)
		local will = t.getWillPenalty(self, t)
		local cun = t.getCunPenalty(self, t)
		return ([[Learn to take advantage of your enemy's pain.
		If your enemy is bleeding and attempts to attack you, their critical hit rate is reduced by %d%%, as their wounds make them more predictable.
		If you attack a bleeding enemy, there is a %d%% chance that, for %d turns, they are disabled as you take advantage of openings (reducing their movement speed by %d%% and accuracy by %d) or anguished as you strike their painful wounds (reducing their willpower by %d and their cunning by %d).
		The statistical reductions will increase with the Cunning stat.
		]]):format(5+(self:getTalentLevel(t)*5),5+(self:getTalentLevel(t)*3),duration,move * 100,attack,will,cun)
	end,
}

newTalent{
	name = "Nimble Movements",
	type = {"cunning/scoundrel",3},
	message = "@Source@ dashes quickly!",
	no_break_stealth = true,
	require = cuns_req3,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return math.floor(35 - self:getTalentLevel(t) * 3.5) end,
	tactical = { CLOSEIN = 3 },
	requires_target = true,
	range = function(self, t) return math.floor(6 + self:getTalentLevel(t) * 0.6) end,
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "You can not do that currently.") return end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local l = self:lineFOV(x, y, block_actor)
		local lx, ly, is_corner_blocked = l:step()
		if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then
			game.logPlayer(self, "You cannot dash through that!")
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

		return true
	end,
	info = function(self, t)
		return ([[Quickly and quietly dash your way to the target square, if it is not blocked by enemies or obstacles. This talent will not break Stealth.]])
	end,
}


newTalent{
	name = "Misdirection",
	type = {"cunning/scoundrel", 4},
	mode = "passive",
	points = 5,
	require = cuns_req4,
	mode = "passive",
	on_learn = function(self, t)
		self.projectile_evasion = (self.projectile_evasion or 0) + 3
		self.projectile_evasion_spread = (self.projectile_evasion_spread or 0) + 1
	end,
	on_unlearn = function(self, t)
		self.projectile_evasion = (self.projectile_evasion or 0) - 3
		self.projectile_evasion_spread = (self.projectile_evasion_spread or 0) - 1
	end,
	info = function(self, t)
		return ([[Your abilities sowing confusion and chaos have reached their peak. Now even your most simple moves confuse your enemies, rendering their offense less effective.
		Your defense increases by %d%% and all projectiles fired at you have their speed reduced by %d
		Your bonus percent to defense will increase with Cunning.]]):
		format(self:getTalentLevel(self.T_MISDIRECTION) * (0.02 * (1 + self:getCun() / 85) *100),self:getTalentLevelRaw(t) * 3 ,self:getTalentLevelRaw(t) * 1, self:getTalentLevelRaw(t) * 3)
	end,
}
