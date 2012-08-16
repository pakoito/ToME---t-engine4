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
	name = "Psychometry",
	type = {"psionic/mentalism", 1},
	points = 5, 
	require = psi_wil_req1,
	mode = "passive",
	getPsychometryCap = function(self, t) return self:getTalentLevelRaw(t)/2 end,
	updatePsychometryCount = function(self, t)
		-- Update psychometry power
		local psychometry_count = 0
		for inven_id, inven in pairs(self.inven) do
			if inven.worn then
				for item, o in ipairs(inven) do
					if o and item and o.power_source and (o.power_source.psionic or o.power_source.nature or o.power_source.antimagic) then
						psychometry_count = psychometry_count + math.min((o.material_level or 1) / 2, t.getPsychometryCap(self, t))
					end
				end
			end
		end
		self:attr("psychometry_power", psychometry_count, true)
	end,
	on_learn = function(self, t)
		t.updatePsychometryCount(self, t)
	end,	
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self.psychometry_power = nil
		else
			t.updatePsychometryCount(self, t)
		end
	end,
	info = function(self, t)
		local max = t.getPsychometryCap(self, t)
		return ([[Resonate with psionic, nature, and anti-magic powered objects, increasing your physical and mind power by %0.2f or half the objects material level (whichever is lower).
		This effect stacks and applies for each qualifying object worn.]]):format(max)
	end,
}

newTalent{
	name = "Mental Shielding",
	type = {"psionic/mentalism", 2},
	points = 5,
	require = psi_wil_req2,
	psi = 15,
	cooldown = function(self, t) return math.max(10, 20 - self:getTalentLevelRaw(t) * 2) end,
	tactical = { BUFF = 1, CURE = function(self, t, target)
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type == "mental" then
				nb = nb + 1
			end
		end
		return nb
	end,},
	no_energy = true,
	getRemoveCount = function(self, t) return math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		local effs = {}
		local count = t.getRemoveCount(self, t)

		-- Go through all mental effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.type == "mental" and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				self:removeEffect(eff[2])
				count = count - 1
			end
		end
		
		if count >= 1 then
			self:setEffect(self.EFF_CLEAR_MIND, 6, {power=count})
		end
		
		game.logSeen(self, "%s's mind is clear!", self.name:capitalize())
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local count = t.getRemoveCount(self, t)
		return ([[Clears your mind of current mental effects and block additional ones over 6 turns.  At most %d mental effects will be affected.
		This talent takes not time to use.]]):format(count)
	end,
}

newTalent{
	name = "Projection",
	type = {"psionic/mentalism", 3},
	points = 5, 
	require = psi_wil_req3,
	psi = 20,
	cooldown = function(self, t) return 20 - self:getTalentLevelRaw(t) * 2 end,
	no_npc_use = true, -- this can be changed if the AI is improved.  I don't trust it to be smart enough to leverage this effect.
	getPower = function(self, t) return math.ceil(self:combatTalentMindDamage(t, 5, 40)) end,
	getDuration = function(self, t) return 4 + math.ceil(self:getTalentLevel(t)*2) end,
	action = function(self, t)
		if self:attr("is_psychic_projection") then return true end
		local x, y = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to invoke your spirit!")
			return
		end
		
		local m = self:clone{
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=nil},
			ai = "summoned", ai_real = "tactical",
			subtype = "ghost", is_psychic_projection = 1,
			name = "Projection of "..self.name,
			desc = [[A ghostly figure.]],
		}
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil
		m._rst_full = true

		m.energy.value = 0
		m.player = nil
		m.max_life = m.max_life
		m.life = util.bound(m.life, 0, m.max_life)
		m.forceLevelup = function() end
		m.die = nil
		m.on_die = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.puuid = nil
		m.on_takehit = nil
		m.can_talk = nil
		m.clone_on_hit = nil
		m.exp_worth = 0
		m.no_inventory_access = true
		m.can_change_level = false
		m.remove_from_party_on_death = true
		for i = 1, 10 do
			m:unlearnTalent(m.T_AMBUSCADE)	-- no recurssive projections
			m:unlearnTalent(m.T_PROJECTION)		
		end
				
		m.can_pass = {pass_wall=70}
		m.no_breath = 1
		m.invisible = (m.invisible or 0) + t.getPower(self, t)/2
		m.see_invisible = (m.see_invisible or 0) + t.getPower(self, t)
		m.see_stealth = (m.see_stealth or 0) + t.getPower(self, t)
		m.lite = 0
		m.infravision = (m.infravision or 0) + 10
		m.avoid_pressure_traps = 1
		
		
		-- Connection to the summoner functions
		local summon_time = t.getDuration(self, t)
		--summoner takes hit
		m.on_takehit = function(self, value, src) self.summoner:takeHit(value, src) return value end
		--pass actors targeting us back to the summoner to prevent super cheese
		m.on_die = function(self)
			local tg = {type="ball", radius=10}
			self:project(tg, self.x, self.y, function(tx, ty)
				local target = game.level.map(tx, ty, Map.ACTOR)
				if target and target.ai_target.actor == self then
					target.ai_target.actor = self.summoner
				end
			end)
		end				
		
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(m.x, m.y, 1, "generic_teleport", {rm=0, rM=0, gm=100, gM=180, bm=180, bM=255, am=35, aM=90})
		game:playSoundNear(self, "talents/teleport")
	
		if game.party:hasMember(self) then
			game.party:addMember(m, {
				control="full",
				type = m.type, subtype="ghost",
				title="Projection of "..self.name,
				temporary_level=1,
				orders = {target=true},
				on_control = function(self)
					self.summoner.projection_ai = self.summoner.ai
					self.summoner.ai = "none"
				end,
				on_uncontrol = function(self)
					game:onTickEnd(function() 
						self.summoner.ai = self.summoner.projection_ai
						self.energy.value = 0
						self.summon_time = 0
						game.party:removeMember(self)
						game.level.map:particleEmitter(self.summoner.x, self.summoner.y, 1, "generic_teleport", {rm=0, rM=0, gm=100, gM=180, bm=180, bM=255, am=35, aM=90})
					end)
				end,
			})
		end
		game:onTickEnd(function() 
			game.party:setPlayer(m)
			self:resetCanSeeCache()
		end)
		
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[Activate to project your mind from your body for %d turns.  In this state you're invisible(+%d power), can see invisible and stealthed creatures (+%d detection power), can move through walls, and do not need air to survive.
		All damage you suffer is shared with your physical body and while in this form you may only deal damage to 'ghosts' or through an active mind link (mind damage only in the second case.)
		To return to your body, simply release control of the projection.]]):format(duration, power/2, power)
	end,
}

newTalent{
	name = "Mind Link",
	type = {"psionic/mentalism", 4},
	points = 5, 
	require = psi_wil_req4,
	sustain_psi = 50,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = function(self, t) return 52 - self:getTalentLevelRaw(t) * 8 end,
	tactical = { BUFF = 2, ATTACK = {MIND = 2}},
	range = function(self, t) return 5 + math.min(5, self:getTalentLevelRaw(t)) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getBonusDamage = function(self, t) return self:combatTalentMindDamage(t, 5, 30) end,
	activate = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target or target == self then return end
		
		target:setEffect(target.EFF_MIND_LINK_TARGET, 10, {power=t.getBonusDamage(self, t), src=self, range=self:getTalentRange(t)*2})
		
		game.level.map:particleEmitter(self.x, self.y, 1, "generic_discharge", {rm=0, rM=0, gm=100, gM=180, bm=180, bM=255, am=35, aM=90})
		game.level.map:particleEmitter(target.x, target.y, 1, "generic_discharge", {rm=0, rM=0, gm=100, gM=180, bm=180, bM=255, am=35, aM=90})
		game:playSoundNear(self, "talents/echo")
		
		local ret = {
			target = target,
			esp = self:addTemporaryValue("esp", {[target.type] = 1}),
		}
		
		-- Update for ESP
		game:onTickEnd(function() 
			self:resetCanSeeCache()
		end)
		
		return ret
	end,
	deactivate = function(self, t, p)
		-- Break 'both' mind links if we're projecting
		if self:attr("is_psychic_projection") and self.summoner:isTalentActive(self.summoner.T_MIND_LINK) then
			self.summoner:forceUseTalent(self.summoner.T_MIND_LINK, {ignore_energy=true})
		end
		self:removeTemporaryValue("esp", p.esp)

		return true
	end,
	info = function(self, t)
		local damage = t.getBonusDamage(self, t)
		local range = self:getTalentRange(t) * 2
		return ([[Link minds with the target.  While your minds are linked you'll inflict %d%% more mind damage to the target and gain telepathy to it's creature type.
		Only one mindlink can be maintained at a time and the effect will break if the target dies or goes beyond range (%d)).
		The mind damage bonus will scale with your mindpower.]]):format(damage, range)
	end,
}