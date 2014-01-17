-- ToME - Tales of Middle-Earth
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

local Emote = require "engine.Emote"

newTalent{
	name = "Shadow Senses",
	type = {"cursed/one-with-shadows", 1},
	require = cursed_cun_req_high1,
	mode = "passive",
	points = 5,
	no_npc_use = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, 1)) end,
	info = function(self, t)
		return ([[Your awareness extends to your shadows.
		You always know exactly where your shadows are and can perceive any foe within %d tiles of their vision.]])
		:format(self:getTalentRange(t))
	end,
}

newTalent{
	name = "Shadow Empathy",
	type = {"cursed/one-with-shadows", 2},
	require = cursed_cun_req_high2,
	points = 5,
	hate = 10,
	cooldown = 25,
	getRandomShadow = function(self, t)
		local shadows = {}
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.is_doomed_shadow and not act.dead then
					shadows[#shadows+1] = act
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.is_doomed_shadow and not act.dead then
					shadows[#shadows+1] = act
				end
			end
		end
		return #shadows > 0 and rng.table(shadows)
	end,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 3, 10)) end,
	getPower = function(self, t) return 5 + self:combatTalentMindDamage(t, 0, 300) / 8 end,
	action = function(self, t)
		self:setEffect(self.EFF_SHADOW_EMPATHY, t.getDur(self, t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDur(self, t)
		return ([[You are linked to your shadows for %d turns, diverting %d%% of all damage you take to a random shadow.
		Effect increases with Mindpower.]]):
		format(duration, power)
	end,
}

newTalent{
	name = "Shadow Transposition",
	type = {"cursed/one-with-shadows", 3},
	require = cursed_cun_req_high3,
	points = 5,
	hate = 6,
	cooldown = 10,
	no_npc_use = true,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 15, 1)) end,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3, 1)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRadius(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, target.x, target.y) > self:getTalentRadius(t) then return nil end
		if target.summoner ~= self or not target.is_doomed_shadow then return end

		-- Displace
		local tx, ty, sx, sy = target.x, target.y, self.x, self.y
		target.x = nil target.y = nil
		self.x = nil self.y = nil
		target:move(sx, sy, true)
		self:move(tx, ty, true)

		self:removeEffectsFilter(function(t) return (t.type == "physical" or t.type == "magical") and t.status == "detrimental" end, t.getNb(self, t))

		return true
	end,
	info = function(self, t)
		return ([[Observers find it difficult to tell you and your shadows apart.
		You can target a shadow in radius %d and instantly trade places with it.
		%d random negative physical or magical effects are transferred from you to the chosen shadow in the process.]])
		:format(self:getTalentRadius(t), t.getNb(self, t))
	end,
}

newTalent{
	name = "Shadow Decoy",
	type = {"cursed/one-with-shadows", 4},
	require = cursed_cun_req_high4,
	mode = "sustained",
	cooldown = 10,
	points = 5,
	cooldown = 50,
	sustain_hate = 40,
	getPower = function(self, t) return 10 + self:combatTalentMindDamage(t, 0, 300) end,
	onDie = function(self, t, value, src)
		local shadow = self:callTalent(self.T_SHADOW_EMPATHY, "getRandomShadow")
		if not shadow then return false end

		game:delayedLogDamage(src, self, 0, ("#GOLD#(%d decoy)#LAST#"):format(value), false)
		game:delayedLogDamage(src, shadow, value, ("#GOLD#%d decoy#LAST#"):format(value), false)
		shadow:takeHit(value, src)
		self:setEffect(self.EFF_SHADOW_DECOY, 4, {power=t.getPower(self, t)})
		self:forceUseTalent(t.id, {ignore_energy=true})

		if self.player then self:setEmote(Emote.new("Fools, you never killed me; that was only my shadow!", 45)) end
		return true
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Your shadows guard you with their lifes.
		When you would receive a fatal blow, you instantly transpose with a random shadow that takes the blow instead, putting this talent on cooldown.
		For the next 4 turns you only die if you reach -%d life. However, when below 0 you cannot see how much life you have left.
		Effect increases with Mindpower.]]):
		format(t.getPower(self, t))
	end,
}
