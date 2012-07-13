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

-- Edge TODO: Sounds, Particles

local Map = require "engine.Map"

newTalent{
	name = "Psychometry",
	type = {"psionic/mentalism", 1},
	points = 5, 
	require = psi_wil_req1,
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
	type = {"psionic/mentalism", 2},
	points = 5,
	require = psi_wil_req2,
	mode = "sustained",
	sustain_psi = 10,
	cooldown = 24,
	remove_on_zero = true,
	tactical = { BUFF=2, DEFEND=2},
	getPower = function(self, t) return 20 + (self:getTalentLevel(t) * 10) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {
			schism = self:addTemporaryValue("psionic_schism", t.getPower(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("psionic_schism", p.schism)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[Divide your mental faculties, increasing your mindpower for mind damage hit calculations by %d%% and giving you a %d%% chance to roll any mental saves against status effects twice, taking the better of the two results.
		]]):format(power, power)
	end,
}

newTalent{
	name = "Projection",
	type = {"psionic/mentalism", 3},
	points = 5, 
	require = psi_wil_req3,
	psi = 10,
	cooldown = 24,
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
			shader = "shadow_simulacrum",
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
		m.invisible = (m.invisible or 0) + t.getPower(self, t)
		m.see_invisible = (m.see_invisible or 0) + t.getPower(self, t)
		m.see_stealth = (m.see_stealth or 0) + t.getPower(self, t)
		m.lite = 0
		m.infravision = (m.infravision or 0) + 10
		m.avoid_pressure_traps = 1
		
		
		-- Connection to the summoner functions
		local summon_time = t.getDuration(self, t)
		--summoner takes hit
		m.on_takehit = function(self, value, src) self.summoner:takeHit(value, src) return value end
		
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
				end,
				on_uncontrol = function(self)
					self.summoner.ai = self.summoner.projection_ai
					self.summon_time = 0
					game:onTickEnd(function() game.party:removeMember(self) end)
				end,
			})
		end
		game:onTickEnd(function() game.party:setPlayer(m)  self:resetCanSeeCache() end)
		
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[Activate to project your mind from your body for %d turns.  In this state you're invisible(+%d power), can see invisible and stealthed creatures (+%d detection power), can move through walls, and do not need air to survive.
		All damage you suffer is shared with your physical body and while in this form you may only deal damage to 'ghosts' or through an active mind link (mind damage only in the second case.)
		To return to your body, simply release control of the projection.]]):format(duration, power, power)
	end,
}

newTalent{
	name = "Mind Link",
	type = {"psionic/mentalism", 4},
	points = 5, 
	require = psi_wil_req4,
	sustain_psi = 20,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 24,
	tactical = { BUFF = 2, ATTACK = {MIND = 2}},
	range = 10,
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
		local target = game.level.map(x, y, Map.ACTOR)
		if not target or target == self then return end
		
		-- I would just check hit here but I hate bypassing the on_set_temporary_effect function, it kinda cheats the player
		target:setEffect(target.EFF_MIND_LINK_TARGET, 10, {apply_power = self:combatMindpower(), no_ct_effect=true, src=self})
		
		-- So we do it like this...  Did we hit?
		if not target:hasEffect(target.EFF_MIND_LINK_TARGET) then return false end
		
		local ret = {
			bonus_damage = t.getBonusDamage(self, t),
			target = target,
			esp = self:addTemporaryValue("esp", {[target.type] = 1}),
		}
		
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
		return ([[Link minds with the target.  While your minds are linked you'll inflict %d%% more mind damage to the target and gain telepathy to it's creature type.
		Only one mindlink can be maintained at a time and the mind damage bonus will scale with your mindpower.]]):format(damage)
	end,
}
