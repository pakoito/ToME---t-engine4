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

-- EDGE TODO: Icons, Particles, Timed Effect Particles, Mine Tiles

local Trap = require "mod.class.Trap"

newTalent{
	name = "Warp Mines",
	type = {"chronomancy/spacetime-folding", 1},
	points = 5,
	mode = "passive",
	require = chrono_req1,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 100, getParadoxSpellpower(self)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end, -- Duration of glyph
	trapPower = function(self,t) return math.max(1,self:combatScale(self:getTalentLevel(t) * self:getMag(15, true), 0, 0, 75, 75)) end, -- Used to determine detection and disarm power, about 75 at level 50
	on_learn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 1 then
			self:learnTalent(self.T_WARP_MINE_TOWARD, true, nil, {no_unlearn=true})
			self:learnTalent(self.T_WARP_MINE_AWAY, true, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 0 then
			self:unlearnTalent(self.T_WARP_MINE_TOWARD)
			self:unlearnTalent(self.T_WARP_MINE_AWAY)
		end
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)/2
		local detect = t.trapPower(self,t)*0.8
		local disarm = t.trapPower(self,t)
		local duration = t.getDuration(self, t)
		return ([[Learn to lay Warp Mines in a radius of 1.
		Warp Mines teleport targets that trigger them either toward you or away from you depending on the type of mine used and inflict %0.2f temporal and %0.2f physical damage.
		The mines are hidden traps (%d detection and %d disarm power based on your Magic) and last for %d turns.
		The damage caused by your Warp Mines will improve with your Spellpower.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage), damDesc(self, DamageType.PHYSICAL, damage), detect, disarm, duration) --I5
	end,
}

newTalent{
	name = "Warp Mine Toward",
	type = {"chronomancy/other", 1},
	points = 1,
	cooldown = 10,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	tactical = { ATTACKAREA = { TEMPORAL = 2 }, CLOSEIN = 2  },
	requires_target = true,
	range = 10,
	no_unlearn_last = true,
	target = function(self, t) return {type="ball", nowarning=true, range=self:getTalentRange(t), radius=1, nolock=true, talent=t} end,	
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local __, tx, ty = self:canProject(tg, tx, ty)
		
		-- Lay the mines in a ball
		self:project(tg, tx, ty, function(px, py)
			local target_trap = game.level.map(px, py, Map.TRAP)
			if target_trap then return end
			if game.level.map:checkEntity(px, py, Map.TERRAIN, "block_move") then return end
			
			-- Our Mines
			local dam = self:spellCrit(self:callTalent(self.T_WARP_MINES, "getDamage"))
			local duration = self:callTalent(self.T_WARP_MINES, "getDuration")
			local detect = self:callTalent(self.T_WARP_MINES, "trapPower") * 0.8
			local disarm = self:callTalent(self.T_WARP_MINES, "trapPower")
			local power = getParadoxSpellpower(self)
			local trap = Trap.new{
				name = "warp mine",
				type = "temporal", id_by_type=true, unided_name = "trap",
				display = '^', color=colors.BLUE, image = "trap/trap_teleport_01.png",
				dam = dam, power = power,
				canTrigger = function(self, x, y, who)
					if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
					return false
				end,
				triggered = function(self, x, y, who)
					self:project({type="hit",x=x,y=y}, x, y, engine.DamageType.MATTER, self.dam)
					-- Teleport Toward
					local hit = self.summoner:checkHit(self.power, who:combatSpellResist() + (who:attr("continuum_destabilization") or 0)) and who:canBe("teleport")
					if not hit then	
						game.logSeen(who, "%s resists the teleport!", who.name:capitalize())
					else
						game.level.map:particleEmitter(who.x, who.y, 1, "temporal_teleport")
						-- since we're using a precise teleport we'll look for a free grid first
						local tx, ty = util.findFreeGrid(self.summoner.x, self.summoner.y, 5, true, {[Map.ACTOR]=true})
						if tx and ty then
							game.level.map:particleEmitter(who.x, who.y, 1, "temporal_teleport")
							if not who:teleportRandom(self.summoner.x, self.summoner.y, 1, 0) then
								game.logSeen(self, "The warp fizzles!")
							else
								who:setEffect(who.EFF_CONTINUUM_DESTABILIZATION, 100, {power=power*0.3})
								game.level.map:particleEmitter(who.x, who.y, 1, "temporal_teleport")
							end
						end
					end
			
					return true, true
				end,
				temporary = duration,
				x = px, y = py,
				disarm_power = math.floor(disarm),
				detect_power = math.floor(detect),
				canAct = false,
				energy = {value=0},
				act = function(self)
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
						game.level:removeEntity(self)
					end
				end,
				summoner = self,
				summoner_gain_exp = true,
			}
			
			-- Add mines
			game.level:addEntity(trap)
			trap:identify(true)
			trap:setKnown(self, true)
			game.zone:addEntity(game.level, trap, "trap", px, py)
		end)

		game:playSoundNear(self, "talents/heal")
		self:startTalentCooldown(self.T_WARP_MINE_AWAY)
		
		return true
	end,
	info = function(self, t)
		local damage = self:callTalent(self.T_WARP_MINES, "getDamage")/2
		local duration = self:callTalent(self.T_WARP_MINES, "getDuration")
		local detect = self:callTalent(self.T_WARP_MINES, "trapPower") * 0.8
		local disarm = self:callTalent(self.T_WARP_MINES, "trapPower")
		return ([[Lay Warp Mines in a radius of 1 that teleport enemies to you and inflict %0.2f temporal and %0.2f physical damage.
		The mines are hidden traps (%d detection and %d disarm power based on your Magic) and last for %d turns.
		The damage caused by your Warp Mines will improve with your Spellpower.
		Using this talent will trigger the cooldown on Warp Mine Away.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage), damDesc(self, DamageType.PHYSICAL, damage), detect, disarm, duration) 
	end,
}

newTalent{
	name = "Warp Mine Away",
	type = {"chronomancy/other", 1},
	points = 1,
	cooldown = 10,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	tactical = { ATTACKAREA = { TEMPORAL = 2 }, ESCAPE = 2  },
	requires_target = true,
	range = 10,
	no_unlearn_last = true,
	target = function(self, t) return {type="ball", nowarning=true, range=self:getTalentRange(t), radius=1, nolock=true, talent=t} end,	
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		
		-- Lay the mines in a ball
		self:project(tg, tx, ty, function(px, py)
			local target_trap = game.level.map(px, py, Map.TRAP)
			if target_trap then return end
			if game.level.map:checkEntity(px, py, Map.TERRAIN, "block_move") then return end
			
			-- Our Mines
			local dam = self:spellCrit(self:callTalent(self.T_WARP_MINES, "getDamage"))
			local duration = self:callTalent(self.T_WARP_MINES, "getDuration")
			local detect = self:callTalent(self.T_WARP_MINES, "trapPower") * 0.8
			local disarm = self:callTalent(self.T_WARP_MINES, "trapPower")
			local power = getParadoxSpellpower(self)
			local trap = Trap.new{
				name = "warp mine",
				type = "temporal", id_by_type=true, unided_name = "trap",
				display = '^', color=colors.BLUE, image = "trap/trap_teleport_01.png",
				dam = dam, power = power,
				canTrigger = function(self, x, y, who)
					if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
					return false
				end,
				triggered = function(self, x, y, who)
					self:project({type="hit",x=x,y=y}, x, y, engine.DamageType.MATTER, self.dam)
					-- Teleport Away
					local hit = self.summoner:checkHit(self.power, who:combatSpellResist() + (who:attr("continuum_destabilization") or 0)) and who:canBe("teleport")
					if not hit then	
						game.logSeen(who, "%s resists the teleport!", who.name:capitalize())
					else
						game.level.map:particleEmitter(who.x, who.y, 1, "temporal_teleport")
						if not who:teleportRandom(self.summoner.x, self.summoner.y, 10, 5) then
							game.logSeen(self, "The warp fizzles!")
						else
							who:setEffect(who.EFF_CONTINUUM_DESTABILIZATION, 100, {power=power*0.3})
							game.level.map:particleEmitter(who.x, who.y, 1, "temporal_teleport")
						end
					end
			
					return true, true
				end,
				temporary = duration,
				x = px, y = py,
				disarm_power = math.floor(disarm),
				detect_power = math.floor(detect),
				canAct = false,
				energy = {value=0},
				act = function(self)
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
						game.level:removeEntity(self)
					end
				end,
				summoner = self,
				summoner_gain_exp = true,
			}
			
			-- Add mines
			game.level:addEntity(trap)
			trap:identify(true)
			trap:setKnown(self, true)
			game.zone:addEntity(game.level, trap, "trap", px, py)
		end)

		game:playSoundNear(self, "talents/heal")
		self:startTalentCooldown(self.T_WARP_MINE_TOWARD)
		
		return true
	end,
	info = function(self, t)
		local damage = self:callTalent(self.T_WARP_MINES, "getDamage")/2
		local duration = self:callTalent(self.T_WARP_MINES, "getDuration")
		local detect = self:callTalent(self.T_WARP_MINES, "trapPower") * 0.8
		local disarm = self:callTalent(self.T_WARP_MINES, "trapPower")
		return ([[Lay Warp Mines in a radius of 1 that teleport enemies away from you and inflict %0.2f temporal and %0.2f physical damage.
		The mines are hidden traps (%d detection and %d disarm power based on your Magic) and last for %d turns.
		The damage caused by your Warp Mines will improve with your Spellpower.
		Using this talent will trigger the cooldown on Warp Mine Away.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage), damDesc(self, DamageType.PHYSICAL, damage), detect, disarm, duration) 
	end,
}

newTalent{
	name = "Banish",
	type = {"chronomancy/spacetime-folding", 2},
	require = chrono_req2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 10,
	tactical = { ESCAPE = 2 },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 5.5)) end,
	getTeleport = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(t), 8, 16)) end,
	target = function(self, t)
		return {type="ball", range=0, radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	direct_hit = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local hit = false

		--checks for spacetime mastery hit bonus
		local power = getParadoxSpellpower(self)
		if self:knowTalent(self.T_SPACETIME_MASTERY) then
			power = getParadoxSpellpower(self) * (1 + self:callTalent(self.T_SPACETIME_MASTERY, "getPower"))
		end

		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or target == self then return end
			game.level.map:particleEmitter(target.x, target.y, 1, "temporal_teleport")
			if self:checkHit(power, target:combatSpellResist() + (target:attr("continuum_destabilization") or 0)) and target:canBe("teleport") then
				if not target:teleportRandom(target.x, target.y, self:getTalentRadius(t) * 4, self:getTalentRadius(t) * 2) then
					game.logSeen(target, "The spell fizzles on %s!", target.name:capitalize())
				else
					target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=power*0.3})
					game.level.map:particleEmitter(target.x, target.y, 1, "temporal_teleport")
					hit = true
				end
			else
				game.logSeen(target, "%s resists the banishment!", target.name:capitalize())
			end
		end)
		
		if not hit then
			game:onTickEnd(function()
				if not self:attr("no_talents_cooldown") then
					self.talents_cd[self.T_BANISH] = self.talents_cd[self.T_BANISH] /2
				end
			end)
		end

		game:playSoundNear(self, "talents/teleport")

		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local range = t.getTeleport(self, t)
		return ([[Randomly teleports all targets within a radius of %d around you.  Targets will be teleported between %d and %d tiles from their current location.
		If no targets are teleported the cooldown will be halved.
		The chance of teleportion will scale with your Spellpower.]]):format(radius, range / 2, range)
	end,
}

newTalent{
	name = "Temporal Wake",
	type = {"chronomancy/spacetime-folding", 3},
	require = chrono_req3,
	points = 5,
	random_ego = "attack",
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 10,
	tactical = { ATTACK = {TEMPORAL = 1}, CLOSEIN = 2, DISABLE = { stun = 2 } },
	direct_hit = true,
	requires_target = true,
	is_teleport = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230, getParadoxSpellpower(self)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10, 0.5, 0, 1)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			game.logSeen(self, "You do not have line of sight.")
			return nil
		end
		local _ _, x, y = self:canProject(tg, x, y)
		local ox, oy = self.x, self.y
		
		-- since we're using a precise teleport we'll look for a free grid first
		local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		if tx and ty then
			if not self:teleportRandom(tx, ty, 0) then
				game.logSeen(self, "The teleport fizzles!")
			else
				local dam = self:spellCrit(t.getDamage(self, t))
				local x, y = ox, oy
				self:project(tg, x, y, function(px, py)
					DamageType:get(DamageType.MATTER).projector(self, px, py, DamageType.MATTER, dam)
					local target = game.level.map(px, py, Map.ACTOR)
					if target then
						if target:canBe("stun") then
							target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=getParadoxSpellpower(self)})
						else
							game.logSeen(target, "%s resists the stun!", target.name:capitalize())
						end
					end
				end)
				game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "temporal_lightning", {tx=x-self.x, ty=y-self.y})
				game:playSoundNear(self, "talents/lightning")
			end
		end
		
		return true
	end,
	info = function(self, t)
		local stun = t.getDuration(self, t)
		local damage = t.getDamage(self, t)/2
		return ([[Violently fold the space between yourself and another point within range.
		You move to the target location, and leave a temporal wake behind that stuns for %d turns and inflicts %0.2f temporal and %0.2f physical damage to everything in the path.
		The damage will scale with your Spellpower.]]):
		format(stun, damDesc(self, DamageType.TEMPORAL, damage), damDesc(self, DamageType.PHYSICAL, damage))
	end,
}

newTalent{
	name = "Dimensional Anchor",
	type = {"chronomancy/spacetime-folding", 4},
	require = chrono_req4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 24,
	tactical = { DISABLE = 2 },
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230, getParadoxSpellpower(self)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	requires_target = true,
	direct_hit = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		local damage = self:spellCrit(t.getDamage(self, t))
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_DIMENSIONAL_ANCHOR, t.getDuration(self, t), {damage=damage, src=self, apply_power=getParadoxSpellpower(self)})
		end)

		game.level.map:particleEmitter(x, y, tg.radius, "ball_teleport", {radius=tg.radius})
		game:playSoundNear(self, "talents/teleport")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)/2
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[Anchors enemies in a radius of %d.  Anchored targets will be prevented from teleporting for %d turns and take %0.2f temporal and %0.2f physical damage on teleport attempts.
		The damage will scale with your Spellpower.]]):format(radius, duration, damDesc(self, DamageType.TEMPORAL, damage), damDesc(self, DamageType.PHYSICAL, damage))
	end,
}