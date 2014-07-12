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

-- EDGE TODO: Icons, Particles, Timed Effect Particles

newTalent{
	name = "Precognition",
	type = {"chronomancy/chronomancy",1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 20,
	no_npc_use = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 14)) end,
	range = function(self, t) return 10 + math.min(self:combatTalentSpellDamage(t, 10, 20, getParadoxSpellpower(self))) end,
	action = function(self, t)
		-- Foresight bonuses
		local defense = 0
		local crits = 0
		if self:knowTalent(self.T_FORESIGHT) then
			defense = self:callTalent(self.T_FORESIGHT, "getDefense")
			crits = self:callTalent(self.T_FORESIGHT, "getCritDefense")
		end
		
		self:setEffect(self.EFF_PRECOGNITION, t.getDuration(self, t), {range=self:getTalentRange(t), actor=1, traps=1, defense=defense, crits=crits})
		
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getDuration(self, t)
		return ([[You peer into the future, sensing creatures and traps in a radius of %d for %d turns.
		If you know Foresight you'll gain additional defense and chance to shrug off critical hits (equal to your Foresight bonuses) while Precognition is active.
		The detection radius will scale with your Spellpower.]]):format(range, duration)
	end,
}

newTalent{
	name = "Foresight",
	type = {"chronomancy/chronomancy",2},
	mode = "passive",
	require = chrono_req2,
	points = 5,
	getDefense = function(self, t) return self:combatTalentStatDamage(t, "mag", 10, 50) end,
	getCritDefense = function(self, t) return self:combatTalentStatDamage(t, "mag", 5, 25) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_def", t.getDefense(self, t))
		self:talentTemporaryValue(p, "ignore_direct_crits", t.getCritDefense(self, t))
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_MAG then
			self:updateTalentPassives(t)
		end
	end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		local crits = t.getCritDefense(self, t)
		return ([[Gain %d defense and %d%% chance to shrug off critical hits.
		If you have Precognition or See the Threads active these bonuses will be added to those effects, granting additional defense and chance to shrug off critical hits.
		These bonuses scale with your Magic stat.]]):
		format(defense, crits)
	end,
}

newTalent{
	name = "Contingency",
	type = {"chronomancy/chronomancy", 3},
	require = chrono_req3,
	points = 5,
	sustain_paradox = 36,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 15, 45, 25)) end, -- Limit >15
	tactical = { DEFEND = 2 },
	no_npc_use = true,
	callbackOnHit = function(self, t, cb)
		local p = self:isTalentActive(t.id)
		local life_after = self.life - cb.value
		local cont_trigger = self.max_life * 0.3
		
		-- Cast our contingent spell
		if p and p.rest_count <= 0 and cont_trigger > life_after then
			local cont_t = p.talent
			local cont_id = self:getTalentFromId(cont_t)
			local t_level = math.min(self:getTalentLevel(t), self:getTalentLevel(cont_t))
			
			-- Make sure we still know the talent and that the preuse conditions apply
			if t_level == 0 or not self:preUseTalent(cont_id, true, true) then
				game.logPlayer(self, "#LIGHT_RED#Your Contingency has failed to cast %s!", self:getTalentFromId(cont_t).name)
			else
				self:forceUseTalent(cont_t, {ignore_ressources=true, ignore_cd=true, ignore_energy=true, force_level=t_level})
				game.logPlayer(self, "#STEEL_BLUE#Your Contingency triggered %s!", self:getTalentFromId(cont_t).name)
			end
			
			p.rest_count = self:getTalentCooldown(t)
		end
		
		return cb.value
	end,
	callbackOnActBase = function(self, t)
		local p = self:isTalentActive(t.id)
		if p.rest_count > 0 then p.rest_count = p.rest_count - 1 end
	end,
	iconOverlay = function(self, t, p)
		local val = p.rest_count or 0
		if val <= 0 then return "" end
		local fnt = "buff_font"
		return tostring(math.ceil(val)), fnt
	end,
	activate = function(self, t)
		local d = require("mod.dialogs.talents.ChronomancyContingency").new(self)
		game:registerDialog(d)
		local co = coroutine.running()
		d.unload = function() coroutine.resume(co, d.contingecy_talent) end
		if not coroutine.yield() then return nil end
		local talent = d.contingecy_talent
				
		return {
			talent = talent, rest_count = 0
		}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local cooldown = self:getTalentCooldown(t)
		local talent = self:isTalentActive(t.id) and self:getTalentFromId(self:isTalentActive(t.id).talent).name or "None"
		return ([[Choose an activatable spell that's not targeted.  When you take damage that reduces your life below 30%% the spell will automatically cast.
		This spell will cast even if it is currently on cooldown, will not consume a turn or resources, and uses the talent level of Contingency or its own, whichever is lower.
		This effect can only occur once every %d turns and takes place after the damage is resolved.
		
		Current Contingency Spell: %s]]):
		format(cooldown, talent)
	end,
}

newTalent{
	name = "See the Threads",
	type = {"chronomancy/chronomancy", 4},
	require = chrono_req4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 50,
	no_npc_use = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(t), 10, 25)) end,
	on_pre_use = function(self, t, silent)
		if checkTimeline(self) then
			if not silent then
				game.logPlayer(self, "The timeline is too fractured to do this now.")
			end
			return false
		end
		if game.level and game.level.data and game.level.data.see_the_threads_done then
			if not silent then
				game.logPlayer(self, "You've seen as much as you can here.")
			end
			return false
		end
		return true
	end,
	action = function(self, t)
		-- Foresight Bonuses
		local defense = 0
		local crits = 0
		if self:knowTalent(self.T_FORESIGHT) then
			defense = self:callTalent(self.T_FORESIGHT, "getDefense")
			crits = self:callTalent(self.T_FORESIGHT, "getCritDefense")
		end
		
		if game.level and game.level.data then
			game.level.data.see_the_threads_done = true
		end
		
		self:setEffect(self.EFF_SEE_THREADS, t.getDuration(self, t), {defense=defense, crits=crits})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[You peer into three possible futures, allowing you to explore each for %d turns.  When the effect expires, you'll choose which of the three futures becomes your present.
		If you know Foresight you'll gain additional defense and chance to shrug off critical hits (equal to your Foresight values) while See the Threads is active.
		This spell splits the timeline.  Attempting to use another spell that also splits the timeline while this effect is active will be unsuccessful.
		Note that seeing visions of your own death can still be fatal.
		This spell may only be used once per zone level.]])
		:format(duration)
	end,
}