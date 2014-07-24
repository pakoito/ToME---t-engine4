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

local Map = require "engine.Map"

newTalent{
	name = "Lacerating Strikes",
	type = {"cunning/scoundrel", 1},
	points = 5,
	require = cuns_req1,
	mode = "sustained",
	cutChance = function(self,t) return self:combatTalentLimit(t, 100, 20, 60) end, --Limit < 100%
	do_cut = function(self, t, target, dam)
		if target:canBe("cut") and rng.percent(t.cutChance(self, t)) then
			dam = dam * self:combatTalentWeaponDamage(t, 0.15, 0.35)
			target:setEffect(target.EFF_CUT, 10, {src=self, power=(dam / 10)})
		end
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Rend your foe with every attack you do. All attacks now have a %d%% chance of inflicting an additional %d%% of your attack's damage in Bleeding damage, divided over ten turns.]]):
		format(t.cutChance(self, t), 100 * self:combatTalentWeaponDamage(t, 0.15, 0.35))
	end,
}

newTalent{
	name = "Scoundrel's Strategies", short_name = "SCOUNDREL",
	type = {"cunning/scoundrel", 2},
	require = cuns_req2,
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 3.3, 5.3)) end,
	-- _M:physicalCrit function in mod\class\interface\Combat.lua handles crit penalty
	getCritPenalty = function(self,t) return self:combatTalentScale(t, 10, 30) end,
	disableChance = function(self,t) return self:combatTalentLimit(t, 100, 8, 20) end, -- Limit <100%
	getMovePenalty = function(self, t) return self:combatLimit(self:combatTalentStatDamage(t, "cun", 10, 30), 1, 0.05, 0, 0.274, 22.4) end, -- Limit <100%
	getAttackPenalty = function(self, t) return 5 + self:combatTalentStatDamage(t, "cun", 5, 20) end,
	getWillPenalty = function(self, t) return 5 + self:combatTalentStatDamage(t, "cun", 5, 20) end,
	getCunPenalty = function(self, t) return 5 + self:combatTalentStatDamage(t, "cun", 5, 20) end,
	do_scoundrel = function(self, t, target)
		if not rng.percent(t.disableChance(self, t)) then return end
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
		If you attack a bleeding enemy, there is a %d%% chance that, for %d turns, they are disabled as you take advantage of openings (reducing their movement speed by %d%% and Accuracy by %d) or anguished as you strike their painful wounds (reducing their Willpower by %d and their Cunning by %d).
		The statistical reductions will increase with your Cunning.
		]]):format(t.getCritPenalty(self,t), t.disableChance(self, t), duration, move * 100, attack, will, cun)
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
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 31.9, 17)) end, -- Limit >= 5
	tactical = { CLOSEIN = 3 },
	requires_target = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 6.8, 8.6)) end,
	speed = "movement",
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
	-- Defense bonus implemented in _M:combatDefenseBase function in mod\class\interface\Combat.lua
	getDefense = function(self,t) return self:combatScale(self:getTalentLevel(t) * 2 * (1 + self:getCun()/85), 0, 0, 21.8, 21.8) end,
	getDeflect = function(self, t) return self:combatTalentLimit(t, 100, 3, 15) end, --limit < 100%
	getDeflectRange = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "projectile_evasion", t.getDeflect(self, t))
		self:talentTemporaryValue(p, "projectile_evasion_spread", t.getDeflectRange(self, t))
	end,
	info = function(self, t)
		return ([[Your abilities in sowing confusion and chaos have reached their peak. Now, even your most simple moves confuse your enemies, rendering their offense less effective.
		Your Defense increases by %d%%, and enemies have a %d%% chance of targetting a random square within %d squares of you.
		The bonus to Defense will increase with Cunning.]]):
		format(t.getDefense(self, t) ,t.getDeflect(self, t) ,t.getDeflectRange(self,t))
	end,
}
