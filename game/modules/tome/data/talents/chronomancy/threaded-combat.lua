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

-- EDGE TODO: Talents, Icons, Particles, Timed Effect Particles

newTalent{
	name = "Frayed Threads",
	type = {"chronomancy/threaded-combat", 1},
	require = chrono_req_high1,
	mode = "passive",
	points = 5,
	getPercent = function(self, t) return math.min(100, self:combatTalentSpellDamage(t, 20, 80, getParadoxSpellpower(self)))/100 end,
	getRadius = function(self, t) return self:getTalentLevel(t) > 4 and 2 or 1 end,
	info = function(self, t)
		local percent = t.getPercent(self, t) * 100
		local radius = t.getRadius(self, t)
		return ([[Your Weapon Folding and Impact spells now deal %d%% of their damage in a radius of %d.
		The damage percent will scale with your Spellpower.]])
		:format(percent, radius)
	end
}

newTalent{
	name = "Thread the Needle",
	type = {"chronomancy/threaded-combat", 2},
	require = chrono_req_high2,
	points = 5,
	cooldown = 8,
	paradox = function (self, t) return getParadoxCost(self, t, 15) end,
	tactical = { ATTACKAREA = { weapon = 3 } , DISABLE = 3 },
	requires_target = true,
	range = archery_range,
	no_energy = "fake",
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 1.9) end,
	getCooldown = function(self, t) return self:getTalentLevel(t) >= 5 and 2 or 1 end,
	on_pre_use = function(self, t, silent) if self:attr("disarmed") then if not silent then game.logPlayer(self, "You require a weapon to use this talent.") end return false end return true end,
	target = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t)}
		if not self:hasArcheryWeapon("bow") then
			tg = {type="ball", radius=1, range=self:getTalentRange(t)}
		end
		return tg
	end,
	archery_onhit = function(self, t, target, x, y)
		-- Refresh blade talents
		for tid, cd in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[1]:find("^chronomancy/blade") then
				self.talents_cd[tid] = cd - t.getCooldown(self, t)
			end
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local damage = t.getDamage(self, t)
		local mainhand, offhand = self:hasDualWeapon()
				
		if self:hasArcheryWeapon("bow") then
			-- Ranged attack
			local targets = self:archeryAcquireTargets(tg, {one_shot=true})
			if not targets then return end
			self:archeryShoot(targets, t, tg, {mult=dam})
		elseif mainhand then
			-- Melee attack
			self:project(tg, self.x, self.y, function(px, py, tg, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and target ~= self then
					local hit = self:attackTarget(target, nil, dam)
					-- Refresh bow talents
					if hit then
						for tid, cd in pairs(self.talents_cd) do
							local tt = self:getTalentFromId(tid)
							if tt.type[1]:find("^chronomancy/bow") then
								self.talents_cd[tid] = cd - t.getCooldown(self, t)
							end
						end
					end
				end
			end)
			self:addParticles(Particles.new("meleestorm2", 1, {}))
		else
			game.logPlayer(self, "You cannot use Thread the Needle without an appropriate weapon!")
			return nil
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local cooldown = t.getCooldown(self, t)
		return ([[Attack with your bow or dual-weapons for %d%% damage.
		If you use your bow you'll shoot a beam and each target hit will reduce the cooldown of one Blade Threading spell currently on cooldown by %d.
		If you use your dual-weapons you'll attack all targets within a radius of one around you and each target hit will reduce the cooldown of one Bow Threading spell currently on cooldown by %d.
		At talent level five cooldowns are reduced by two.]])
		:format(damage, cooldown, cooldown)
	end
}

newTalent{
	name = "Blended Threads",
	type = {"chronomancy/threaded-combat", 3},
	require = chrono_req_high3,
	mode = "passive",
	points = 5,
	getPercent = function(self, t) return math.min(50, 10 + self:combatTalentSpellDamage(t, 0, 30, getParadoxSpellpower(self)))/100 end,
	info = function(self, t)
		local percent = t.getPercent(self, t) * 100
		return ([[Your Bow Threading and Blade Threading spells now deal %d%% more weapon damage if you did not have the appropriate weapon equipped when you initated the attack.
		The damage percent will scale with your Spellpower.]])
		:format(percent)
	end
}

newTalent{
	name = "Twin Threads",
	type = {"chronomancy/threaded-combat", 4},
	require = chrono_req_high4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 15, 45, 25)) end, -- Limit >15
	tactical = { ATTACK = {weapon = 4} },
	range = 10,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 12)) end,
	getDamagePenalty = function(self, t) return 60 - math.min(self:combatTalentSpellDamage(t, 0, 20, getParadoxSpellpower(self)), 30) end,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t)}
	end,
	direct_hit = true,
	remove_on_clone = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			game.logSeen(self, "You do not have line of sight.")
			return nil
		end
		local __, x, y = self:canProject(tg, x, y)

		-- First find a position
		local blade_warden = false
		local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		-- Create our melee clone
		if tx and ty then
			game.level.map:particleEmitter(tx, ty, 1, "temporal_teleport")
			
			-- clone our caster
			local m = makeParadoxClone(self, self, t.getDuration(self, t))
			
			-- remove some talents; note most of this is handled by makeParadoxClone, but we want to be more extensive
			local tids = {}
			for tid, _ in pairs(m.talents) do
				local t = m:getTalentFromId(tid)
				if t.remove_on_clone then tids[#tids+1] = t end
				local tt = self:getTalentFromId(tid)
				if not tt.type[1]:find("^chronomancy/blade") and not tt.type[1]:find("^chronomancy/threaded") and not tt.type[1]:find("^chronomancy/guardian") then
					tids[#tids+1] = t 
				end
			end
			for i, t in ipairs(tids) do
				if t.mode == "sustained" and m:isTalentActive(t.id) then m:forceUseTalent(t.id, {ignore_energy=true, silent=true}) end
				m.talents[t.id] = nil
			end
			game.zone:addEntity(game.level, m, "actor", tx, ty)
			m.ai_target.actor = target or nil
			m.ai_state = { talent_in=2, ally_compassion=10 }	
			m.generic_damage_penalty = t.getDamagePenalty(self, t)
			
			if game.party:hasMember(self) then
				game.party:addMember(m, {
					control="no",
					type="minion",
					title="Blade Guardian",
					orders = {target=true},
				})
			end
			
			-- Swap to our blade if needed
			doWardenWeaponSwap(m, t, 0, "blade")
			blade_warden = true
		else
			game.logPlayer(self, "Not enough space to summon blade warden!")
		end
		
		-- First find a position
		local bow_warden = false
		local poss = {}
		local range = 6
		for i = x - range, x + range do
			for j = y - range, y + range do
				if game.level.map:isBound(i, j) and
					core.fov.distance(x, y, i, j) <= range and -- make sure they're within arrow range
					core.fov.distance(i, j, self.x, self.y) <= range/2 and -- try to place them close to the caster so enemies dodge less
					self:canMove(i, j) and self:hasLOS(x, y) then
					poss[#poss+1] = {i,j}
				end
			end
		end
		-- Create our archer clone
		if #poss > 0 then
			local pos = poss[rng.range(1, #poss)]
			tx, ty = pos[1], pos[2]
			game.level.map:particleEmitter(tx, ty, 1, "temporal_teleport")
			
			-- clone our caster
			local m = makeParadoxClone(self, self, t.getDuration(self, t))
			
			-- remove some talents; note most of this is handled by makeParadoxClone, but we want to be more extensive
			local tids = {}
			for tid, _ in pairs(m.talents) do
				local t = m:getTalentFromId(tid)
				if t.remove_on_clone then tids[#tids+1] = t end
				local tt = self:getTalentFromId(tid)
				if not tt.type[1]:find("^chronomancy/bow") and not tt.type[1]:find("^chronomancy/threaded") and not tt.type[1]:find("^chronomancy/guardian") then
					tids[#tids+1] = t 
				end
			end
			for i, t in ipairs(tids) do
				if t.mode == "sustained" and m:isTalentActive(t.id) then m:forceUseTalent(t.id, {ignore_energy=true, silent=true}) end
				m.talents[t.id] = nil
			end
			
			game.zone:addEntity(game.level, m, "actor", tx, ty)
			m.ai_target.actor = target or nil
			m.ai_state = { talent_in=2, ally_compassion=10 }
			m.generic_damage_penalty = t.getDamagePenalty(self, t)
			m.remove_from_party_on_death = true
			m:attr("archery_pass_friendly", 1)
			
			if game.party:hasMember(self) then
				game.party:addMember(m, {
					control="no",
					type="minion",
					title="Bow Guardian",
					orders = {target=true},
				})
			end
				
			-- Swap to our bow if needed
			doWardenWeaponSwap(m, t, 0, "bow")
			bow_warden = true
		else
			game.logPlayer(self, "Not enough space to summon bow warden!")
		end

		game:playSoundNear(self, "talents/teleport")
		
		if not blade_warden and not bow_warden then  -- If neither summons then don't punish the player
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage_penalty = t.getDamagePenalty(self, t)
		return ([[Summons a blade warden and a bow warden from an alternate timeline for %d turns.  The wardens are out of phase with this reality and deal %d%% less damage but the bow warden's arrows will pass through friendly targets.
		Each warden knows all Threaded Combat, Temporal Guardian, and Blade Threading or Bow Threading spells you know.
		The damage reduction penalty will be lessened by your Spellpower.]]):format(duration, damage_penalty)
	end,
}
