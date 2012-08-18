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

newTalent{
	name = "Slumber",
	type = {"psionic/slumber", 1},
	points = 5,
	require = psi_wil_req1,
	cooldown = 8,
	psi = 10,
	tactical = { DISABLE = {sleep = 2} },
	direct_hit = true,
	requires_target = true,
	range = function(self, t) return 5 + math.min(5, self:getTalentLevelRaw(t)) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)/2) end,
	getInsomniaPower = function(self, t)
		local t = self:getTalentFromId(self.T_SANDMAN)
		local reduction = t.getInsomniaPower(self, t)
		return 20 - reduction
	end,
	getSleepPower = function(self, t)
		local power = self:combatTalentMindDamage(t, 10, 100)
		if self:knowTalent(self.T_SANDMAN) then
			local t = self:getTalentFromId(self.T_SANDMAN)
			power = power * t.getSleepPowerBonus(self, t)
		end
		return math.ceil(power)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		--Restless?
		local is_waking =0
		if self:knowTalent(self.T_RESTLESS_NIGHT) then
			local t = self:getTalentFromId(self.T_RESTLESS_NIGHT)
			is_waking = t.getDamage(self, t)
		end

		local power = self:mindCrit(t.getSleepPower(self, t))
		if target:canBe("sleep") then
			target:setEffect(target.EFF_SLUMBER, t.getDuration(self, t), {src=self, power=power, waking=is_waking, insomnia=t.getInsomniaPower(self, t), no_ct_effect=true, apply_power=self:combatMindpower()})
			game.level.map:particleEmitter(target.x, target.y, 1, "generic_charge", {rm=180, rM=200, gm=100, gM=120, bm=30, bM=50, am=70, aM=180})
		else
			game.logSeen(self, "%s resists the sleep!", target.name:capitalize())
		end
		game:playSoundNear(self, "talents/dispel")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getSleepPower(self, t)
		local insomnia = t.getInsomniaPower(self, t)
		return([[Puts the target into a deep sleep for %d turns, rendering it unable to act.  Every %d points of damage the target suffers will reduce the effect duration by one turn.
		When Slumber ends the target will suffer from Insomnia for a number of turns equal to the amount of time it was asleep (up to five turns max), granting it %d%% sleep immunity for each turn of the Insomnia effect.
		The damage threshold will scale with your mindpower.]]):format(duration, power, insomnia)
	end,
}

newTalent{
	name = "Restless Night",
	type = {"psionic/slumber", 2},
	points = 5,
	require = psi_wil_req2,
	mode = "passive",
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 200) end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return([[Targets you have slept now take %0.2f mind damage upon waking.
		The damage will scale with your mindpower.]]):format(damDesc(self, DamageType.MIND, (damage)))
	end,
}

newTalent{
	name = "Sandman",
	type = {"psionic/slumber", 3},
	points = 5,
	require = psi_wil_req3,
	mode = "passive",
	getSleepPowerBonus = function(self, t) return 1 + math.min(2, self:getTalentLevel(t)/5) end,
	getInsomniaPower = function(self, t) return math.min(10, self:getTalentLevel(t) * 1.2) end,
	info = function(self, t)
		local power_bonus = t.getSleepPowerBonus(self, t) - 1
		local insomnia = t.getInsomniaPower(self, t)
		return([[Increases the amount of damage you can deal to sleeping targets before reducing the effect duration by %d%% and reduces the sleep immunity of your Insomnia effects by %d%%.
		These effects will be directly reflected in the appropriate talent descriptions.
		The damage threshold bonus will scale with your mindpower.]]):format(power_bonus * 100, insomnia)
	end,
}

newTalent{
	name = "Dreamscape",
	type = {"psionic/slumber", 4},
	points = 5,
	require = psi_wil_req4,
	cooldown = 24,
	psi = 40,
	random_boss_rarity = 10,
	tactical = { DISABLE = function(self, t, target) if target and target.game_ender and target:attr("sleep") then return 4 else return 0 end end},
	direct_hit = true,
	requires_target = true,
	range = function(self, t) return 5 + math.min(5, self:getTalentLevelRaw(t)) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return 10 + math.ceil(self:getTalentLevel(t) * 4) end,
	getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	on_pre_use = function(self, t, silent) if self:attr("is_psychic_projection") then if not silent then game.logPlayer(self, "You feel it unwise to travel to the dreamscape in such a fragile form.") end return false end return true end,
	action = function(self, t)
		if game.zone.is_dream_scape then
			game.logPlayer(self, "This talent can not be used from within the Dreamscape.")
			return
		end
		if game.zone.no_planechange then
			game.logPlayer(self, "This talent can not be used here.")
			return
		end
		if not self:canBe("planechange") then
			game.logPlayer(self, "The effect fizzles...")
			return
		end

		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		if not tx or not ty or not target then return nil end
		target = game.level.map(tx, ty, Map.ACTOR)
		if not tx or not ty or not target then return nil end
		if not (target.player and target.game_ender) and not (self.player and self.game_ender) then return nil end
		if target == self then return end
		if target:attr("negative_status_effect_immune") or target:attr("status_effect_immune") then return nil end
		if not (target and target:attr("sleep")) then
			game.logPlayer(self, "Your target must be sleeping in order to enter it's dreamscape.")
			return nil
		end
		if self:reactionToward(target) >= 0 then
			game.logPlayer(self, "You can't cast this on friendly targets.")
			return nil
		end

		game:onTickEnd(function()
			if self:attr("dead") then return end
			local oldzone = game.zone
			local oldlevel = game.level

			-- Clean up thought-forms
			cancelThoughtForms(self)

			-- Remove them before making the new elvel, this way party memebrs are not removed from the old
			if oldlevel:hasEntity(self) then oldlevel:removeEntity(self) end
			if oldlevel:hasEntity(target) then oldlevel:removeEntity(target) end

			oldlevel.no_remove_entities = true
			local zone = mod.class.Zone.new("dreamscape-talent")
			local level = zone:getLevel(game, 1, 0)
			oldlevel.no_remove_entities = nil

			level:addEntity(self)
			level:addEntity(target)

			level.source_zone = oldzone
			level.source_level = oldlevel
			game.zone = zone
			game.level = level
			game.zone_name_s = nil

			local x1, y1 = util.findFreeGrid(4, 6, 20, true, {[Map.ACTOR]=true})
			if x1 then
				self:move(x1, y1, true)
				game.level.map:particleEmitter(x1, y1, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
			end
			local x2, y2 = util.findFreeGrid(8, 6, 20, true, {[Map.ACTOR]=true})
			if x2 then
				target:move(x2, y2, true)
			end

			target:setTarget(self)
			target.dream_plane_trapper = self
			target.dream_plane_on_die = target.on_die
			target.on_die = function(self, ...)
				self.dream_plane_trapper:removeEffect(self.EFF_DREAMSCAPE)
				local args = {...}
				game:onTickEnd(function()
					if self.dream_plane_on_die then self:dream_plane_on_die(unpack(args)) end
					self.on_die, self.dream_plane_on_die = self.dream_plane_on_die, nil
				end)
			end

			self.dream_plane_on_die = self.on_die
			self.on_die = function(self, ...)
				self:removeEffect(self.EFF_DREAMSCAPE)
				local args = {...}
				game:onTickEnd(function()
					if self.dream_plane_on_die then self:dream_plane_on_die(unpack(args)) end
					self.on_die, self.dream_plane_on_die = self.dream_plane_on_die, nil
				--	if not game.party:hasMember(self) then world:gainAchievement("FEARSCAPE", game:getPlayer(true)) end
				end)
			end

			game.logPlayer(game.player, "#LIGHT_BLUE#You are taken to the Dreamscape!")
		end)

		local power = self:mindCrit(t.getPower(self, t))
		self:setEffect(self.EFF_DREAMSCAPE, t.getDuration(self, t), {target=target, power=power, projections_killed=0, x=self.x, y=self.y, tx=target.x, ty=target.y})
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		return([[Enter a sleeping target's dreams for %d turns.  While in the dreamscape you'll encounter the target's invulnerable sleeping form as well as dream projections that it will spawn every four turns to defend it's mind.  When the dreamscape ends the target's life will be reduced by 10%% and it will to be brainlocked for one turn for each projection destroyed.
		Lucid dreamers will spawn projections every two turns instead of every four and their projections will deal more damage (generally projections have a 50%% penalty to all damage).
		In the dreamscape your damage will be improved by %d%%.
		The damage bonus will improve with your mindpower.]]):format(duration, power)
	end,
}
