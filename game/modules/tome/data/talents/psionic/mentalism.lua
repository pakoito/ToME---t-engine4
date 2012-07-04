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

-- Edge TODO: Sounds, Particles, Talent Icons; Mind Link

local Map = require "engine.Map"

newTalent{
	name = "Projection",
	type = {"psionic/mentalism", 1},
	points = 5, 
	require = psi_wil_req1,
	mode = "sustained",
	sustain_psi = 10,
	cooldown = 24,
	no_npc_use = true,
	getMaxDistance = function(self, t) return 5 + math.ceil(self:combatTalentMindDamage(t, 10, 20)) end,
	getSensoryPower = function(self, t) return math.ceil(self:combatTalentMindDamage(t, 10, 40)) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)*2) end,
	activate = function(self, t)
		if self:attr("is_psychic_projection") then return true end
		local x, y = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to invoke your spirit!")
			return
		end

		local m = self:clone{
			shader = "shadow_simulacrum",
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getMaxDistance(self, t),
			ai_target = {actor=nil},
			ai = "summoned", ai_real = "tactical",
			subtype = "ghost", is_psychic_projection = 1,
			name = "Projection of "..self.name,
			desc = [[A ghostly figure.]],
		}
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil

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
			m:unlearnTalent(m.T_AMBUSCADE) -- no recurssive projections
		end
				
		m.can_pass = {pass_wall=70}
		m.no_breath = 1
		m.invisible = (m.invisible or 0) + 1
		m.see_invisible = (m.see_invisible or 0) + t.getSensoryPower(self, t)
		m.see_stealth = (m.see_stealth or 0) + t.getSensoryPower(self, t)
		m.lite = 0
		m.infravision = (m.infravision or 0) + 10
		
		
		-- Connection to the summoner functions
		local max_distance = t.getMaxDistance(self, t)
		local summon_time = t.getDuration(self, t)
		m.on_act = function(self)
			-- only check these very other turn to prevent to much spam
			if math.mod(self.summon_time, 2) == 0 and self.summon_time > 0 then
				if core.fov.distance(self.x, self.y, self.summoner.x, self.summoner.y) < max_distance and not self.summoner.dead then
					self.summon_time = summon_time
				elseif not self.summoner.dead then
					game.logPlayer(self, "#LIGHT_RED#The psychic link is growing weak...")
				else
					game.logPlayer(self, "#LIGHT_RED#You're being pulled into the void!")
				end
			end
		end
		--summoner takes hit
		m.on_takehit = function(self, value, src) self.summoner:takeHit(value, src) return value end
		-- summoner deactivates talent when we die
		m.on_die = function(self)
			if not self.summoner.dead then
				game.logPlayer(self, "#LIGHT_RED#A violent force pushes you back into your body!")
				self.summoner:forceUseTalent(self.summoner.T_PROJECTION, {ignore_energy=true})
			end
		end
		
		game.zone:addEntity(game.level, m, "actor", x, y)
	
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
					self:forceUseTalent(self.T_PROJECTION, {ignore_energy=true})
				end,
				on_uncontrol = function(self)
					self.summoner.ai = self.summoner.projection_ai
					self.summon_time = 0
					self.summoner:forceUseTalent(self.summoner.T_PROJECTION, {ignore_energy=true})
					game:onTickEnd(function() game.party:removeMember(self) end)
				end,
			})
		end
		game:onTickEnd(function() game.party:setPlayer(m)  self:resetCanSeeCache() end)
		
		return true
	end,
	deactivate = function(self, t, p)
		game:onTickEnd(function()
			if self:attr("is_psychic_projection") then 
				game.party:setPlayer(self.summoner)
			else
				game.party:setPlayer(self)
			end
		end)
		return true
	end,
	info = function(self, t)
		local max_distance = t.getMaxDistance(self, t)
		local senses = t.getSensoryPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[Activate to project your mind from your body.  In this state you're invisible, can see invisible and stealthed creatures (+%d detection power), can move through walls, and do not need air to survive.
		All damage you suffer is shared with your physical body and you can sustain the projection indifinetly within a radius of %d.  Beyond that distance the connection will begin to weaken and you'll have %d turns before your projection dissipates.
		While active you may only damage 'ghosts' and creatures you've formed a Mind Link with and even then can only use mind damage for such attacks.
		To return to your body, simply release control of the projection.]]):format(senses, max_distance, duration)
	end,
}

newTalent{
	name = "Mind Link",
	type = {"psionic/mentalism", 2},
	points = 5, 
	require = psi_wil_req2,
	cooldown = 15,
	tactical = { DEFEND = 2, ATTACK = {MIND = 2}},
	getShieldPower = function(self, t) return self:combatTalentMindDamage(t, 20, 300) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	action = function(self, t)
		local power = math.min(self.psionic_feedback, t.getShieldPower(self, t))
		self:setEffect(self.EFF_RESONANCE_SHIELD, 10, {power = self:mindCrit(power), dam = t.getDamage(self, t)})
		self.psionic_feedback = self.psionic_feedback - power
		return true
	end,
	info = function(self, t)
		local shield_power = t.getShieldPower(self, t)
		local damage = t.getDamage(self, t)
		return ([[Activate to conver up to %0.2f feedback into a resonance shield that will absorb 50%% of all damage you take and inflict %0.2f mind damage to melee attackers.
		Learning this talent will increase the amount of feedback you can store by 100 (first talent point only).
		The conversion ratio will scale with your mindpower and the effect lasts up to ten turns.]]):format(shield_power, damDesc(self, DamageType.MIND, damage))
	end,
}

newTalent{
	name = "Psychometry",
	type = {"psionic/mentalism", 3},
	points = 5, 
	require = psi_wil_req3,
	mode = "passive",
	getMultiplier = function(self, t) return 0.05 + (self:getTalentLevel(t) / 33) end,
	info = function(self, t)
		local multiplier = t.getMultiplier(self, t)
		return ([[When you wield or wear an item infused by psionic, nature, or arcane-disrupting forces you improve all values under its 'when wielded/worn' field by %d%%.
		Note this doesn't change the item itself, but rather the effects it has on your person (the item description will not reflect the improved values).]]):format(multiplier * 100)
	end,
}

newTalent{
	name = "Schism",
	type = {"psionic/mentalism", 4},
	points = 5,
	require = psi_wil_req4,
	mode = "sustained",
	sustain_psi = 20,
	cooldown = 50,
	remove_on_zero = true,
	tactical = { BUFF=2, DEFEND=2},
	getSpeed = function(self, t) return self:combatTalentMindDamage(t, 5, 30) end,
	getDrain = function(self, t) return math.max(1, 5 - (self:getTalentLevelRaw(t))/2) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {
			speed  = self:addTemporaryValue("combat_mentalspeed", t.getSpeed(self, t)/ 100),
			schism = self:addTemporaryValue("psionic_schism", 1),
			drain = self:addTemporaryValue("psi_regen", - t.getDrain(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_mentalspeed", p.speed)
		self:removeTemporaryValue("psionic_schism", p.schism)
		self:removeTemporaryValue("psi_regen", p.drain)
		return true
	end,
	info = function(self, t)
		local speed = t.getSpeed(self, t)
		local drain = t.getDrain(self, t)
		return ([[Divide your mental faculties, increasing the speed at which you perform psionic talents by %d%%.   While active any mental saves you roll against status effects will be checked twice, taking the better of the two results.
		Maintaining this effect constantly drains your Psi (%0.2f per turn).
		The speed increase will scale with your mindpower.]]):format(speed, drain)
	end,
}
