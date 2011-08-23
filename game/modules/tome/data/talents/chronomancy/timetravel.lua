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

newTalent{
	name = "Time Skip",
	type = {"chronomancy/timetravel",1},
	require = chrono_req1,
	points = 5,
	cooldown = 6,
	paradox = 5,
	tactical = { ATTACK = 1, DISABLE = 2 },
	range = 6,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 250) * getParadoxModifier(self, pm) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t) / 2 * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		-- Find the target and check hit
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		tx, ty = checkBackfire(self, tx, ty)
		if tx then
			target = game.level.map(tx, ty, engine.Map.ACTOR)
		end
		
		-- checks for spacetime mastery hit bonus
		local power = self:combatSpellpower()
		if self:knowTalent(self.T_SPACETIME_MASTERY) then
			power = self:combatSpellpower() * 1 + (self:getTalentLevel(self.T_SPACETIME_MASTERY)/10)
		end
		
		if target then
			local hit = self:checkHit(power, target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
			if not hit then
				game.logSeen(target, "%s resists!", target.name:capitalize())
				return true
			end
		else
			return
		end
		
		-- deal the damage first so time prison doesn't prevent it
		self:project(tg, tx, ty, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(tx, ty, 1, "temporal_thrust")
		game:playSoundNear(self, "talents/arcane")
		
		-- make sure the target survives the initial hit and then time prison
		if not target.dead then
			if target ~= self then
				target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
			end
			target:setEffect(target.EFF_TIME_PRISON, t.getDuration(self, t), {})
		else
			game.logSeen(target, "%s has been killed by the temporal energy!", target.name:capitalize())
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Inflicts %0.2f temporal damage.  If your target survives it will be removed from time for %d turns.
		The duration will scale with your Paradox.  The damage will scale with your Paradox and Spellpower.]]):format(damDesc(self, DamageType.TEMPORAL, damage), duration)
	end,
}

newTalent{
	name = "Borrowed Time",
	type = {"chronomancy/timetravel", 2},
	require = chrono_req2,
	points = 5,
	paradox = 15,
	cooldown = 20,
	no_energy = true,
	tactical = { ESCAPE = 2, CLOSEIN = 2, BUFF = 2 },
	getDuration = function(self, t) return 1 + math.floor(self:getTalentLevelRaw(t)/4) end,
	getStun = function(self, t) return 6 - self:getTalentLevelRaw(t) end,
	action = function(self, t)
		self:setEffect(self.EFF_BORROWED_TIME, t.getDuration(self, t), {power=t.getStun(self,t)})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local stun = t.getStun(self, t)
		return ([[You borrow some energy from the future, greatly increasing your global speed for %d turns.  At the end of this time though you'll be paralyzed (no chance of resisting) for %d turns as you pay back the time you borrowed.
		]]):format(duration + 1, stun)
	end,
}

newTalent{
	name = "Echoes From The Past",
	type = {"chronomancy/timetravel", 3},
	require = chrono_req3,
	points = 5,
	paradox = 10,
	cooldown = 6,
	tactical = { ATTACKAREA = 2 },
	range = 0,
	radius = function(self, t)
		return 1 + self:getTalentLevelRaw(t)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return (self:combatTalentSpellDamage(t, 18, 160)*getParadoxModifier(self, pm)) end,
	getPercent = function(self, t) return (10 + (self:combatTalentSpellDamage(t, 1, 10))) / 100 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		self:project(tg, self.x, self.y, DamageType.TEMPORAL_ECHO, t.getPercent(self, t))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_temporal", {radius=tg.radius})
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t) * 100
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[Creates a temporal echo in a nova around you in a radius of %d.  Affected targets will take %0.2f temporal damage and %d%% of the difference between their current life and max life as additional temporal damage.
		The percentage and damage scales with your Paradox and Spellpower.]]):
		format(radius, damage, percent)
	end,
}

newTalent{
	name = "Door to the Past",
	type = {"chronomancy/timetravel", 4},
	require = chrono_req4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_paradox = 150,
	cooldown = 50,
	no_npc_use = true,
	getAnomalyCount = function(self, t) return math.ceil(self:getTalentLevel(t)) end,
	on_learn = function(self, t)
		if not self:knowTalent(self.T_REVISION) then
			self:learnTalent(self.T_REVISION)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:unlearnTalent(self.T_REVISION)
		end
	end,
	do_anomalyCount = function(self, t)
		if self.dttp_anomaly_count == 0 then
			-- check for anomaly
			if not game.zone.no_anomalies and not self:attr("no_paradox_fail") and self:paradoxAnomalyChance() then
				-- Random anomaly
				local ts = {}
				for id, t in pairs(self.talents_def) do
					if t.type[1] == "chronomancy/anomalies" then ts[#ts+1] = id end
				end
				if not silent then game.logPlayer(self, "Your Door to the Past has caused an anomaly!") end
				self:forceUseTalent(rng.table(ts), {ignore_energy=true})
			end
			-- reset count
			self.dttp_anomaly_count = t.getAnomalyCount(self, t)
		else
			self.dttp_anomaly_count = self.dttp_anomaly_count - 1
		end
	end,
	activate = function(self, t)
		if checkTimeline(self) == true then
			return
		end

		-- set the counter
		self.dttp_anomaly_count = t.getAnomalyCount(self, t)

		game:playSoundNear(self, "talents/arcane")
		return {
			game:onTickEnd(function()
				game:chronoClone("revision")
			end),
			particle = self:addParticles(Particles.new("temporal_aura", 1)),
		}
	end,
	deactivate = function(self, t, p)
		if game._chronoworlds then game._chronoworlds = nil end
		self.dttp_anomaly_count = nil
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local count = t.getAnomalyCount(self, t)
		return ([[This powerful spell allows you to mark a point in time that you can later return to by casting Revision (which you'll automatically learn upon learning this spell).  Maintaining such a doorway causes constant strain on the spacetime continuum and can possibly trigger an anomaly (using your current anomaly chance) once every %d turns.
		Additional talent points will increase the time between anomaly checks.]]):
		format(count)
	end,
}

newTalent{
	name = "Revision",
	type = {"chronomancy/other", 1},
	type_no_req = true,
	points = 1,
	message = "@Source@ revises history.",
	cooldown = 100,
	paradox = 100,
	no_npc_use = true,
	on_pre_use = function(self, t, silent) if not self:isTalentActive(self.T_DOOR_TO_THE_PAST) then if not silent then game.logPlayer(self, "Door to the Past must be active to use this talent.") end return false end return true end,
	action = function(self, t)

		-- Prevent Revision After Death
		if game._chronoworlds == nil then
			game.logPlayer(game.player, "#LIGHT_RED#Your spell fizzles.")
			return
		end

		game:onTickEnd(function()
			if not game:chronoRestore("revision", true) then
				game.logSeen(self, "#LIGHT_RED#The spell fizzles.")
				return
			end
			game.logPlayer(game.player, "#LIGHT_BLUE#You unfold the spacetime continuum to a previous state!")

			-- Manualy start the cooldown of the "old player"
			game.player:startTalentCooldown(t)
			game.player:incParadox(t.paradox * (1 + (game.player.paradox / 300)))
			game.player:forceUseTalent(game.player.T_DOOR_TO_THE_PAST, {ignore_energy=true})
			-- remove anomaly count
			if self.dttp_anomaly_count then self.dttp_anomaly_count = nil end
			if game._chronoworlds then game._chronoworlds = nil end
		end)

		return true
	end,
	info = function(self, t)
		return ([[Casting Revision will return you to the point in time you created a temporal marker using Door to the Past.]])
		:format()
	end,
}
