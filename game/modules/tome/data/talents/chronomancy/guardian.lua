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
	name = "Strength of Purpose",
	type = {"chronomancy/guardian", 1},
	points = 5,
	require = { stat = { mag=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[Increases Physical Power by %d, and increases weapon damage by %d%% when using swords, axes, maces, knives, or bows.
		You now also use your Magic in place of Strength when equipping weapons, calculating weapon damage, and physical power.
		These bonuses override rather than stack with weapon mastery, knife mastery, and bow mastery.]]):
		format(damage, 100*inc)
	end,
}

newTalent{
	name = "Invigorate",
	type = {"chronomancy/guardian", 2},
	require = chrono_req2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 24,
	fixed_cooldown = true,
	tactical = { HEAL = 1 },
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(self:getTalentLevel(t), 14, 4, 8)) end, -- Limit < 14
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 50, getParadoxSpellpower(self)) end,
	getNumber = function(self, t) return math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		self:setEffect(self.EFF_INVIGORATE, t.getDuration(self,t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[For the next %d turns, you recover %0.1f life per turn and most other talents on cooldown will refresh twice as fast as usual.
		The amount healed will increase with your Spellpower.]]):format(duration, power)
	end,
}

newTalent{
	name = "Double Edge",
	type = {"chronomancy/guardian", 4},
	require = chrono_req4,
	points = 5,
	mode = "passive",
	getSplit = function(self, t) return math.min(100, self:combatTalentSpellDamage(t, 20, 50, getParadoxSpellpower(self)))/100 end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	remove_on_clone = true,
	callbackOnHit = function(self, t, cb, src)
		local split = cb.value * t.getSplit(self, t)
		if not self:knowTalent(self.T_DOUBLE_EDGE) then return cb.value end  -- Clone protection
		
		-- Do our split
		if self.max_life and self.life - cb.value < self.max_life * 0.5 then
			-- Look for space first
			local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if tx and ty then
				game.level.map:particleEmitter(tx, ty, 1, "temporal_teleport")
				
				-- clone our caster
				local m = makeParadoxClone(self, self, t.getDuration(self, t))
				
				-- remove some talents; note most of this is handled by makeParadoxClone already but we don't want to keep splitting
				local tids = {}
				for tid, _ in pairs(m.talents) do
					local t = m:getTalentFromId(tid)
					if t.remove_on_clone then tids[#tids+1] = t end
				end
				for i, t in ipairs(tids) do
					if t.mode == "sustained" and m:isTalentActive(t.id) then m:forceUseTalent(t.id, {ignore_energy=true, silent=true}) end
					m.talents[t.id] = nil
				end
				
				-- add our clone
				game.zone:addEntity(game.level, m, "actor", tx, ty)
				m.ai_state = { talent_in=2, ally_compassion=10 }
				m.remove_from_party_on_death = true				
				
				-- split the damage
				game:delayedLogDamage(src, m, split, ("#PINK#%d displaced#LAST#"):format(split), false)
				cb.value = cb.value - split
				
				m:takeHit(split, src)
				m:setTarget(src or nil)
								
				if game.party:hasMember(self) then
					game.party:addMember(m, {
						control="no",
						type="minion",
						title="Temporal Clone",
						orders = {target=true},
					})
				end
			else
				game.logPlayer(self, "Not enough space to summon warden!")
			end
		end
		
		return cb.value
	end,
	info = function(self, t)
		local split = t.getSplit(self, t) * 100
		local duration = t.getDuration(self, t)
		return ([[When an attack would reduce you below 50%% of your maximum life another you from an alternate timeline appears and takes %d%% of the damage.
		Your double will remain for %d turns and knows most talents you do.
		The amount of damage split scales with your Spellpower.]]):format(split, duration)
	end,
}

newTalent{
	name = "Breach",
	type = {"chronomancy/guardian", 4},
	require = chrono_req4,
	points = 5,
	cooldown = 8,
	paradox = function (self, t) return getParadoxCost(self, t, 15) end,
	tactical = { ATTACK = {weapon = 2}, DISABLE = 3 },
	requires_target = true,
	range = archery_range,
	no_energy = "fake",
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	on_pre_use = function(self, t, silent) if self:attr("disarmed") then if not silent then game.logPlayer(self, "You require a weapon to use this talent.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		target:setEffect(target.EFF_BREACH, t.getDuration(self, t), {})
	end,
	action = function(self, t)
		local mainhand, offhand = self:hasDualWeapon()
		
		if self:hasArcheryWeapon("bow") then
			-- Ranged attack
			local targets = self:archeryAcquireTargets(nil, {one_shot=true})
			if not targets then return end
			self:archeryShoot(targets, t, nil, {mult=t.getDamage(self, t)})
		elseif mainhand then
			-- Melee attack
			local tg = {type="hit", range=self:getTalentRange(t), talent=t}
			local x, y, target = self:getTarget(tg)
			if not x or not y or not target then return nil end
			if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
			local hitted = self:attackTarget(target, nil, t.getDamage(self, t))

			if hitted then
				target:setEffect(target.EFF_BREACH, t.getDuration(self, t), {apply_power=getParadoxSpellpower(self)})
			end
		else
			game.logPlayer(self, "You cannot use Breach without an appropriate weapon!")
			return nil
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Attack the target with either your bow or melee weapons for %d%% damage.
		If the attack hits you'll breach the target's immunities, reducing armor hardiness, stun, pin, blindness, and confusion immunity by 50%% for %d turns.
		Breach chance scales with your Spellpower.]])
		:format(damage, duration)
	end
}