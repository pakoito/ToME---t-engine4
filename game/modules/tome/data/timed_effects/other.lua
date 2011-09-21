-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "INFUSION_COOLDOWN",
	desc = "Infusion Saturation",
	long_desc = function(self, eff) return ("The more you use infusions, the longer they will take to recharge (+%d cooldowns)."):format(eff.power) end,
	type = "other",
	subtype = "infusion",
	status = "detrimental",
	no_stop_enter_worlmap = true,
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
}

newEffect{
	name = "RUNE_COOLDOWN",
	desc = "Runic Saturation",
	long_desc = function(self, eff) return ("The more you use runes, the longer they will take to recharge (+%d cooldowns)."):format(eff.power) end,
	type = "other",
	subtype = "rune",
	status = "detrimental",
	no_stop_enter_worlmap = true,
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
}

newEffect{
	name = "TAINT_COOLDOWN",
	desc = "Tainted",
	long_desc = function(self, eff) return ("The more you use taints, the longer they will take to recharge (+%d cooldowns)."):format(eff.power) end,
	type = "other",
	subtype = "taint",
	status = "detrimental",
	no_stop_enter_worlmap = true,
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
}

newEffect{
	name = "TIME_PRISON",
	desc = "Time Prison",
	long_desc = function(self, eff) return "The target is removed from the normal time stream, unable to act but unable to take any damage." end,
	type = "other",
	subtype = "time",
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is removed from time!", "+Out of Time" end,
	on_lose = function(self, err) return "#Target# is returned to normal time.", "-Out of Time" end,
	activate = function(self, eff)
		eff.iid = self:addTemporaryValue("invulnerable", 1)
		eff.sid = self:addTemporaryValue("time_prison", 1)
		eff.particle = self:addParticles(Particles.new("time_prison", 1))
		self.energy.value = 0
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.iid)
		self:removeTemporaryValue("time_prison", eff.sid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "TIME_SHIELD",
	desc = "Time Shield",
	long_desc = function(self, eff) return ("The target is surrounded by a time distortion, absorbing %d/%d damage and sending it forward in time."):format(self.time_shield_absorb, eff.power) end,
	type = "other", 
	subtype = "time",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "The very fabric of time alters around #target#.", "+Time Shield" end,
	on_lose = function(self, err) return "The fabric of time around #target# stabilizes to normal.", "-Time Shield" end,
	on_aegis = function(self, eff, aegis)
		self.time_shield_absorb = self.time_shield_absorb + eff.power * aegis / 100
	end,
	activate = function(self, eff)
		if self:attr("shield_factor") then eff.power = eff.power * (100 + self:attr("shield_factor")) / 100 end
		if self:attr("shield_dur") then eff.dur = eff.dur + self:attr("shield_dur") end
		eff.tmpid = self:addTemporaryValue("time_shield", eff.power)
		--- Warning there can be only one time shield active at once for an actor
		self.time_shield_absorb = eff.power
		self.time_shield_absorb_max = eff.power
		eff.particle = self:addParticles(Particles.new("time_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		-- Time shield ends, setup a dot if needed
		if eff.power - self.time_shield_absorb > 0 then
			print("Time shield dot", eff.power - self.time_shield_absorb, (eff.power - self.time_shield_absorb) / 5)
			self:setEffect(self.EFF_TIME_DOT, 5, {power=(eff.power - self.time_shield_absorb) / 5})
		end

		self:removeTemporaryValue("time_shield", eff.tmpid)
		self.time_shield_absorb = nil
		self.time_shield_absorb_max = 0
	end,
}

newEffect{
	name = "TIME_DOT",
	desc = "Time Shield Backfire",
	long_desc = function(self, eff) return ("The time distortion protecting the target has ended. All damage forwarded in time is now applied, doing %d arcane damage per turn."):format(eff.power) end,
	type = "other", 
	subtype = "time",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "The powerful time-altering energies come crashing down on #target#.", "+Time Shield Backfire" end,
	on_lose = function(self, err) return "The fabric of time around #target# returns to normal.", "-Time Shield Backfire" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.ARCANE).projector(self, self.x, self.y, DamageType.ARCANE, eff.power)
	end,
}

newEffect{
	name = "GOLEM_OFS",
	desc = "Golem out of sight",
	long_desc = function(self, eff) return "The golem is out of sight of the alchemist; direct control will be lost!" end,
	type = "other",
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#LIGHT_RED##Target# is out of sight of its master; direct control will break!.", "+Out of sight" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		if game.player ~= self then return true end

		if eff.dur <= 1 then
			game:onTickEnd(function()
				game.logPlayer(self, "#LIGHT_RED#You lost sight of your golem for too long; direct control is broken!")
				game.player:runStop("golem out of sight")
				game.player:restStop("golem out of sight")
				game.party:setPlayer(self.summoner)
			end)
		end
	end,
}

newEffect{
	name = "CONTINUUM_DESTABILIZATION",
	desc = "Continuum Destabilization",
	long_desc = function(self, eff) return ("The target has been affected by space or time manipulations and is becoming more resistant to them (+%d)."):format(eff.power) end,
	type = "other",
	subtype = "spacetime",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# looks a little pale around the edges.", "+Destabilized" end,
	on_lose = function(self, err) return "#Target# is firmly planted in reality.", "-Destabilized" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the continuum_destabilization
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		-- Need to remove and re-add the continuum_destabilization
		self:removeTemporaryValue("continuum_destabilization", old_eff.effid)
		old_eff.effid = self:addTemporaryValue("continuum_destabilization", old_eff.power)
		return old_eff
	end,
	activate = function(self, eff)
		eff.effid = self:addTemporaryValue("continuum_destabilization", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("continuum_destabilization", eff.effid)
	end,
}

newEffect{
	name = "SUMMON_DESTABILIZATION",
	desc = "Summoning Destabilization",
	long_desc = function(self, eff) return ("The more the target summons creatures the longer it will take to summon more (+%d turns)."):format(eff.power) end,
	type = "other", -- Type "other" so that nothing can dispel it
	status = "detrimental",
	parameters = { power=10 },
	on_merge = function(self, old_eff, new_eff)
		-- Merge the destabilizations
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		-- Need to remove and re-add the talents CD
		self:removeTemporaryValue("talent_cd_reduction", old_eff.effid)
		old_eff.effid = self:addTemporaryValue("talent_cd_reduction", { [self.T_SUMMON] = -old_eff.power })
		return old_eff
	end,
	activate = function(self, eff)
		eff.effid = self:addTemporaryValue("talent_cd_reduction", { [self.T_SUMMON] = -eff.power })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talent_cd_reduction", eff.effid)
	end,
}

newEffect{
	name = "DAMAGE_SMEARING",
	desc = "Damage Smearing",
	long_desc = function(self, eff) return ("Passes damage received in the present off onto the future self."):format(eff.power) end,
	type = "other",
	subtype = "time",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "The fabric of time alters around #target#.", "+Damage Smearing" end,
	on_lose = function(self, err) return "The fabric of time around #target# stabilizes.", "-Damage Smearing" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("time_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "SMEARED",
	desc = "Smeared",
	long_desc = function(self, eff) return ("Damage received in the past is returned as %0.2f temporal damage per turn."):format(eff.power) end,
	type = "other",
	subtype = "time",
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is taking damage received in the past!", "+Smeared" end,
	on_lose = function(self, err) return "#Target# stops taking damage received in the past.", "-Smeared" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, eff.power)
	end,
}

-- Borrowed Time and the Borrowed Time stun effect
newEffect{
	name = "BORROWED_TIME",
	desc = "Borrowed Time",
	long_desc = function(self, eff) return ("The target's global speed has been increased by %d%%."):format(100) end,
	type = "other",
	subtype = "time",
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:setEffect(self.EFF_TEMPORAL_STUN, eff.power, {})
	end,
}

newEffect{
	name = "TEMPORAL_STUN",
	desc = "Temporal Stun",
	long_desc = function(self, eff) return "The target is paralyzed, preventing any actions." end,
	type = "other",
	--subtype = "time", --no subtype so it can't be removed
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is paralyzed!", "+Paralyzed" end,
	on_lose = function(self, err) return "#Target# is not paralyzed anymore.", "-Paralyzed" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("time_stun", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("time_stun", eff.tmpid)
	end,
}

newEffect{
	name = "PRECOGNITION",
	desc = "Precognition",
	long_desc = function(self, eff) return "You walk into the future; when the effect ends, if you are not dead, you are brought back to the past." end,
	type = "other",
	--subtype = "time", --no subtype so it can't be removed
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		game:onTickEnd(function()
			game:chronoClone("precognition")
		end)
	end,
	deactivate = function(self, eff)
		game:onTickEnd(function()
			if not game:chronoRestore("precognition", true) then
				game.logSeen(self, "#LIGHT_RED#The spell fizzles.")
				return
			end
			game.logPlayer(game.player, "#LIGHT_BLUE#You unfold the spacetime continuum to a previous state!")
			game.player.tmp[self.EFF_PRECOGNITION] = nil
			if game._chronoworlds then game._chronoworlds = nil end
		end)
	end,
}

newEffect{
	name = "SEE_THREADS",
	desc = "See the Threads",
	long_desc = function(self, eff) return ("You walk three different timelines, choosing the one you prefer at the end (current timeline: %d)."):format(eff.thread) end,
	type = "other",
	--subtype = "time", --no subtype so it can't be removed
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.thread = 1
		eff.max_dur = eff.dur
		game:onTickEnd(function()
			game:chronoClone("see_threads_base")
		end)
	end,
	deactivate = function(self, eff)
		game:onTickEnd(function()

			if game._chronoworlds == nil then
				game.logSeen(self, "#LIGHT_RED#The see the threads spell fizzles and cancels, leaving you in this timeline.")
				return
			end

			if eff.thread < 3 then
				local worlds = game._chronoworlds

				-- Clone but not the subworlds
				game._chronoworlds = nil
				local clone = game:chronoClone()

				-- Restore the base world and resave it
				game._chronoworlds = worlds
				game:chronoRestore("see_threads_base", true)

				-- Setup next thread
				local eff = game.player:hasEffect(game.player.EFF_SEE_THREADS)
				eff.thread = eff.thread + 1
				game.logPlayer(game.player, "#LIGHT_BLUE#You unfold the space time continuum to the start of the time threads!")

				game._chronoworlds = worlds
				game:chronoClone("see_threads_base")

				-- Add the previous thread
				game._chronoworlds["see_threads_"..(eff.thread-1)] = clone
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "rewrite_universe")
				return
			else
				game._chronoworlds.see_threads_base = nil
				local chat = Chat.new("chronomancy-see-threads", {name="See the Threads"}, self, {turns=eff.max_dur})
				chat:invoke()
			end
		end)
	end,
}

newEffect{
	name = "IMMINENT_PARADOX_CLONE",
	desc = "Imminent Paradox Clone",
	long_desc = function(self, eff) return "When the effect expires you'll be pulled into the past." end,
	type = "other",
	--subtype = "time", --no subtype so it can't be removed
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
			game:onTickEnd(function()
			game:chronoClone("paradox_past")
		end)
	end,
	deactivate = function(self, eff)
		local t = self:getTalentFromId(self.T_PARADOX_CLONE)
		local base = t.getDuration(self, t) - 2
		game:onTickEnd(function()

			if game._chronoworlds == nil then
				game.logSeen(self, "#LIGHT_RED#You've altered your destiny and will not be pulled into the past.")
				return
			end

			local worlds = game._chronoworlds
			-- save the players health so we can reload it
			local oldplayer = game.player

			-- Clone but not the subworlds
			game._chronoworlds = nil
			local clone = game:chronoClone()
			game._chronoworlds = worlds

			-- Move back in time, but keep the paradox_future world stored
			game:chronoRestore("paradox_past", true)
			game._chronoworlds["paradox_future"] = clone
			game.logPlayer(self, "#LIGHT_BLUE#You've been pulled into the past!")
			-- pass health and resources into the new timeline
			game.player.life = oldplayer.life
			for i, r in ipairs(game.player.resources_def) do
				game.player[r.short_name] = oldplayer[r.short_name]
			end

			-- Hack to remove the IMMINENT_PARADOX_CLONE effect in the past
			-- Note that we have to use game.player now since self refers to self from the future!
			game.player.tmp[self.EFF_IMMINENT_PARADOX_CLONE] = nil

			-- Setup the return effect
			game.player:setEffect(self.EFF_PARADOX_CLONE, base, {})
		end)
	end,
}

newEffect{
	name = "PARADOX_CLONE",
	desc = "Paradox Clone",
	long_desc = function(self, eff) return "You've been pulled into the past." end,
	type = "other",
	--subtype = "time", --no subtype so it can't be removed
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		-- save the players rescources so we can reload it
		local oldplayer = game.player
		game:onTickEnd(function()
			game:chronoRestore("paradox_future")
			-- Reload the player's health and resources
			game.logPlayer(game.player, "#LIGHT_BLUE#You've been returned to the present!")
			game.player.life = oldplayer.life
			for i, r in ipairs(game.player.resources_def) do
				game.player[r.short_name] = oldplayer[r.short_name]
			end
		end)
	end,
}

newEffect{
	name = "MILITANT_MIND",
	desc = "Militant Mind",
	long_desc = function(self, eff) return ("Increases physical power, spellpower and mindpower by %d."):format(eff.power) end,
	type = "other",
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.damid = self:addTemporaryValue("combat_dam", eff.power)
		eff.spellid = self:addTemporaryValue("combat_spellpower", eff.power)
		eff.mindid = self:addTemporaryValue("combat_mindpower", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.damid)
		self:removeTemporaryValue("combat_spellpower", eff.spellid)
		self:removeTemporaryValue("combat_mindpower", eff.mindid)
	end,
}

newEffect{
	name = "SEVER_LIFELINE",
	desc = "Sever Lifeline",
	long_desc = function(self, eff) return ("The target lifeline is being cut. When the effect ends %0.2f temporal damage will hit the target."):format(eff.power) end,
	type = "other",
	subtype = "time", 
	status = "detrimental",
	parameters = {power=10000},
	on_gain = function(self, err) return "#Target# lifeline is being severed!", "+Sever Lifeline" end,
	deactivate = function(self, eff)
		if not eff.src or eff.src.dead then return end
		if not eff.src:hasLOS(self.x, self.y) then return end
		if eff.dur >= 1 then return end
		DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, eff.power)
	end,
}

newEffect{
	name = "SPACTIME_STABILITY",
	desc = "Spacetime Stability",
	long_desc = function(self, eff) return "Chronomancy spells cast by the target will not fail, backfire, or cause an anomaly." end,
	type = "other",
	subtype = "time",
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "Spacetime has stabilized around #Target#.", "+Spactime Stability" end,
	on_lose = function(self, err) return "The fabric of spacetime around #Target# has returned to normal.", "-Spacetime Stability" end,
	activate = function(self, eff)
		self:attr("no_paradox_fail", 1)
	end,
	deactivate = function(self, eff)
		self:attr("no_paradox_fail", -1)
	end,
}

newEffect{
	name = "FADE_FROM_TIME",
	desc = "Fade From Time",
	long_desc = function(self, eff) return ("The target is partially removed from the timeline, reducing all damage dealt by %d%%, all damage recieved by %d%%, and the duration of all detrimental effects by %d%%."):
	format(eff.dur + 1, eff.cur_power or eff.power, eff.cur_power or eff.power) end,
	type = "other",
	subtype = "time",
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# has partially removed itself from the timeline.", "+Fade From Time" end,
	on_lose = function(self, err) return "#Target# has returned fully to the timeline.", "-Fade From Time" end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("inc_damage", old_eff.dmgid)
		self:removeTemporaryValue("resists", old_eff.rstid)
		old_eff.cur_power = (new_eff.power)
		old_eff.dmgid = self:addTemporaryValue("inc_damage", {all = - old_eff.dur})
		old_eff.rstid = self:addTemporaryValue("resists", {all = old_eff.cur_power})

		old_eff.dur = old_eff.dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		local current = eff.power * eff.dur/10
		self:setEffect(self.EFF_FADE_FROM_TIME, 1, {power = current})
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.rstid = self:addTemporaryValue("resists", { all = eff.power})
		eff.dmgid = self:addTemporaryValue("inc_damage", {all = -10})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.rstid)
		self:removeTemporaryValue("inc_damage", eff.dmgid)
	end,
}

newEffect{
	name = "SHADOW_VEIL",
	desc = "Shadow Veil",
	long_desc = function(self, eff) return ("You veil yourself in shadows and let them control you. While in the veil you become immune to status effects, gain %d%% all damage reduction and each turn you blink to a nearby foe, hitting it for %d%% darkness weapon damage. While this goes on you can not be stopped unless you are killed and can not control you character."):format(eff.res, eff.dam * 100) end,
	type = "other",
	status = "beneficial",
	parameters = { res=10, dam=1.5 },
	on_gain = function(self, err) return "#Target# is covered in a veil of shadows!", "+Assail" end,
	on_lose = function(self, err) return "#Target# is no longer covered by shadows.", "-Assail" end,
	activate = function(self, eff)
		eff.sefid = self:addTemporaryValue("negative_status_effect_immune", 1)
		eff.resid = self:addTemporaryValue("resists", {all=eff.res})
	end,
	on_timeout = function(self, eff)
		-- Choose a target in FOV
		local acts = {}
		local act
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			if act and self:reactionToward(act) < 0 and not act.dead then
				local sx, sy = util.findFreeGrid(act.x, act.y, 1, true, {[engine.Map.ACTOR]=true})
				if sx then acts[#acts+1] = {act, sx, sy} end
			end
		end
		if #acts == 0 then return end

		act = rng.table(acts)
		self:move(act[2], act[3], true)
		game.level.map:particleEmitter(act[2], act[3], 1, "dark")
		self:attackTarget(act[1], DamageType.DARKNESS, eff.dam) -- Attack *and* use energy
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("negative_status_effect_immune", eff.sefid)
		self:removeTemporaryValue("resists", eff.resid)
	end,
}

newEffect{
	name = "ZERO_GRAVITY",
	desc = "Zero Gravity",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("There is no gravity here, you float in the air. Movement three times as slow, any melee or archery blows have a chance to knockback. Maximum encumberance is greatly increased.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = "spacetime",
	status = "detrimental",
	cancel_on_level_change = true,
	parameters = {},
	on_merge = function(self, old_eff, new_eff)
		return old_eff
	end,
	activate = function(self, eff)
		eff.encumb = self:addTemporaryValue("max_encumber", self:getMaxEncumbrance() * 20),
		self:checkEncumbrance()
		game.logPlayer(self, "#LIGHT_BLUE#You enter a zero gravity zone, beware!")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_encumber", eff.encumb)
		self:checkEncumbrance()
	end,
}