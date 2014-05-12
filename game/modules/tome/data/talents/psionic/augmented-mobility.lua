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
	name = "Skate",
	type = {"psionic/augmented-mobility", 1},
	require = psi_cun_req1,
	points = 5,
	mode = "sustained",
	cooldown = 0,
	sustain_psi = 10,
	no_energy = true,
	tactical = { BUFF = 2 },
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.2, 1.0, 0.75) end,
	getKBVulnerable = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.8) end,
	activate = function(self, t)
		return {
			speed = self:addTemporaryValue("movement_speed", t.getSpeed(self, t)),
			knockback = self:addTemporaryValue("knockback_immune", -t.getKBVulnerable(self, t))
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("movement_speed", p.speed)
		self:removeTemporaryValue("knockback_immune", p.knockback)
		return true
	end,
	info = function(self, t)
		local inc = t.getSpeed(self, t)
		return ([[You telekinetically float just off the ground.
		This allows you to slide around the battle quickly, increasing your movement speed by %d%%.
		It also makes you more vulnerable to being pushed around (-%d%% knockback resistance).]]):
		format(inc*100, t.getKBVulnerable(self, t)*100)
	end,
}

newTalent{
	name = "Mindhook",
	type = {"psionic/augmented-mobility", 2},
	require = psi_cun_req2,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 16, 8)) end, -- Limit to >5
	psi = 20,
	points = 5,
	tactical = { CLOSEIN = 2 },
	range = function(self, t)
		return self:combatTalentLimit(t, 10, 4, 9) -- Limit < 10
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then
			game.logPlayer(self, "The target is out of range")
			return
		end
		target:pull(self.x, self.y, tg.range)
		target:setEffect(target.EFF_DAZED, 1, {})
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Briefly extend your telekinetic reach to grab an enemy and haul them towards you.
		Works on enemies up to %d squares away. The cooldown decreases, and the range increases, with additional talent points spent.]]):
		format(range)
	end,
}

newTalent{
	name = "Quick as Thought",
	type = {"psionic/augmented-mobility", 3},
	points = 5,
	random_ego = "utility",
	cooldown = 20,
	psi = 30,
	no_energy = true,
	require = psi_cun_req3,
	getDuration = function(self, t) return math.floor(self:combatLimit(self:combatMindpower(0.1), 10, 4, 0, 6, 6)) end, -- Limit < 10
	speed = function(self, t) return self:combatTalentScale(t, 0.6, 2.0, 0.75) end,
	getBoost = function(self, t)
		return self:combatScale(self:getTalentLevel(t)*self:combatStatTalentIntervalDamage(t, "combatMindpower", 1, 9), 15, 0, 49, 34)
	end,
	action = function(self, t)
		self:setEffect(self.EFF_QUICKNESS, t.getDuration(self, t), {power=t.speed(self, t)})
		self:setEffect(self.EFF_CONTROL, t.getDuration(self, t), {power=t.getBoost(self, t)})
		return true
	end,
	info = function(self, t)
		local inc = t.speed(self, t)
		local percentinc = 100 * inc
		local boost = t.getBoost(self, t)
		return ([[Encase your body in a sheath of thought-quick forces, allowing you to control your body's movements directly without the inefficiency of dealing with crude mechanisms like nerves and muscles.
		Increases Accuracy by %d, your critical strike chance by %0.1f%% and your physical speed by %d%% for %d turns.
		The duration improves with your Mindpower.]]):
		format(boost, 0.5*boost, percentinc, t.getDuration(self, t))
	end,
}

-- =game.player:combatTalentLimit(game.player:getTalentFromId(game.player.T_TELEKINETIC_LEAP), 10, 5, 9)
newTalent{
	name = "Telekinetic Leap",
	type = {"psionic/augmented-mobility", 4},
	require = psi_cun_req4,
	cooldown = 15,
	psi = 10,
	points = 5,
	tactical = { CLOSEIN = 2 },
	range = function(self, t)
		return self:combatTalentLimit(t, 10, 4, 9) -- Limit < 10
	end,
	action = function(self, t)
		local tg = {default_target=self, type="ball", nolock=true, pass_terrain=false, nowarning=true, range=self:getTalentRange(t), radius=0, requires_knowledge=false}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end

		local fx, fy = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		if not fx then
			return
		end
		self:move(fx, fy, true)

		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[You perform a precise, telekinetically-enhanced leap, landing up to %d squares away.]]):
		format(range)
	end,
}


