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

name = "The Way We Weren't"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have met what seems to be a future version of yourself.\n"
	if self:isCompleted("combat") then desc[#desc+1] = "You tried to kill yourself to prevent you from doing something, or going somewhere... you were not very clear.\n" end
	if self:isCompleted("now-died") then desc[#desc+1] = "You were killed by your future self, and thus this event never occured.\n" end
	if self:isCompleted("future-died") then desc[#desc+1] = "You killed your future self. In the future, you might wish to avoid time-traveling back to this moment...\n" end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("future-died") or self:isCompleted("now-died") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
		end
	end
end

generate = function(self, player, x, y)
	local a = mod.class.NPC.new{}
	a:replaceWith(player:resolveSource():cloneFull())
	mod.class.NPC.castAs(a)
	engine.interface.ActorAI.init(a, a)
	a.no_drops = true
	a.energy.value = 0
	a.player = nil
	a.rank = 4
	a.name = a.name.." the Paradox Mage"
	a.color_r = 250 a.color_g = 50 a.color_b = 250
	a:removeAllMOs()
	a.ai = "tactical"
	a.ai_state = {talent_in=1}
	a.faction = "enemies"
	a.max_life = a.max_life * 2
	a.puuid = nil
	a.life = a.max_life

	-- Remove all talents
	local tids = {}
	for tid, _ in pairs(a.talents) do
		local t = a:getTalentFromId(tid)
		tids[#tids+1] = t
	end
	for i, t in ipairs(tids) do
		if t.mode == "sustained" and a:isTalentActive(t.id) then a:forceUseTalent(t.id, {ignore_energy=true}) end
		a.talents[t.id] = nil
	end

	-- Add talents
	a:learnTalent(a.T_TURN_BACK_THE_CLOCK, true, 3)
	a:learnTalent(a.T_BODY_REVERSION, true, 3)
	a:learnTalent(a.T_TEMPORAL_FUGUE, true, 4)
	a:learnTalent(a.T_STATIC_HISTORY, true, 4)
	a:learnTalent(a.T_RETHREAD, true, 3)
	a:learnTalent(a.T_GATHER_THE_THREADS, true, 3)
	a:learnTalent(a.T_FADE_FROM_TIME, true, 3)
	a:learnTalent(a.T_ASHES_TO_ASHES, true, 4)
	a:learnTalent(a.T_QUANTUM_SPIKE, true, 3)
	a:learnTalent(a.T_SEVER_LIFELINE, true, 5)

	a.talent_cd_reduction = a.talent_cd_reduction or {}
	a.talent_cd_reduction[a.T_STATIC_HISTORY] = 15
	a.talents_cd[a.T_SEVER_LIFELINE] = 20

	a:forceLevelup(a.level + 7)

	a:incIncStat("wil", 200)
	a.self_resurrect = nil -- In case this is a skeleton player
	a.on_die = function(self)
		local o = game.zone:makeEntityByName(game.level, "object", "RUNE_RIFT")
		o:identify(true)
		game.zone:addEntity(game.level, o, "object", self.x, self.y)

		game.player:setQuestStatus("paradoxology", engine.Quest.COMPLETED, "future-died")
		world:gainAchievement("PARADOX_FUTURE", p)
		game.logSeen(self, "#LIGHT_BLUE#Killing your own future self does feel weird, but you know that you can avoid this future. Just do not time travel.")
	end
	a.on_takehit = function(self, val)
		if not self.half_life_check and (self.life - val < self.max_life / 2) then
			self:doEmote("Meet the guardian!")
			game:onTickEnd(function()
				game:changeLevel(1, "paradox-plane")
			end)
			self.half_life_check = true
			self:heal(self.max_life)
			return 0
		end
		return val
	end
	a.on_kill = function(self, who)
		local p = game.party:findMember{main=true}
		if who == p then
			p:setQuestStatus("paradoxology", engine.Quest.COMPLETED, "now-died")
			game.logSeen(self, "#LIGHT_BLUE#Your future self kills you! The timestreams are broken by the paradox!")
			game.logSeen(self, "#LIGHT_BLUE#All those events never happened. Except they did, somewhen.")
			game:setAllowedBuild("chronomancer_paradox_mage", true)
			world:gainAchievement("PARADOX_NOW", p)

			local rift = game.zone:makeEntityByName(game.level, "terrain", "RIFT")
			rift.change_level_check = function() game.log("This rift in time has been created by the paradox. You dare not enter it; it could make things worse. Another Warden will have to fix your mess.") return true end
			game.zone:addEntity(game.level, rift, "terrain", self.x, self.y)

			self.on_die = nil
			self:die()
			who.changed = true
			who.life = math.max(who.life, who.max_life * 0.3)
			return true
		end
	end

	game.zone:addEntity(game.level, a, "actor", x, y)

	local chat = require("engine.Chat").new("paradoxology", a, player)
	chat:invoke()
end
