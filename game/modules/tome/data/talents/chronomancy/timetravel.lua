-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

local Object = require "engine.Object"

newTalent{
	name = "Echoes From The Past",
	type = {"chronomancy/timetravel", 1},
	require = chrono_req_1,
	points = 5,
	paradox = 5,
	cooldown = 6,
	tactical = { ATTACKAREA = 2 },
	range = 1,
	requires_target = true,
	getDamage = function(self, t) return (self:combatTalentSpellDamage(t, 10, 120)*getParadoxModifier(self, pm)) end,
	getPercent = function(self, t) return (30 + (self:combatTalentSpellDamage(t, 10, 30)*getParadoxModifier(self, pm))) / 100 end,
	getRadius = function (self, t) return 4 + math.floor(self:getTalentLevelRaw (t)/2) end,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=t.getRadius(self, t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		self:project(tg, x, y, DamageType.TEMPORAL_ECHO, self:spellCrit(t.getPercent(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "temporal_breath", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t) * 100
		local radius = t.getRadius(self, t)
		local damage = t.getDamage(self, t)
		return ([[Creates a temporal echo in a %d radius cone.  Affected targets will take %0.2f temporal damage and %d%% of the difference between their current life and max life as additional temporal damage.
		The percentage and damage scales with your Paradox and the Magic stat.]]):
		format(radius, damage, percent)
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
	getDuration = function(self, t) return 2 + math.floor(self:getTalentLevelRaw(t)/4) end,
	getStun = function(self, t) return 6 - self:getTalentLevelRaw(t) end,
	action = function(self, t)
		self:setEffect(self.EFF_BORROWED_TIME, t.getDuration(self, t), {power=t.getStun(self,t)})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local stun = t.getStun(self, t)
		return ([[You borrow some energy from the future, greatly increasing your global speed for %d turns.  At the end of this time though you'll be stunned for %d turns as you pay back the time you borrowed.
		]]):format(duration, stun)
	end,
}

-- Time Skip and other Overlay talents like jumpgate are causing issues on remove.  They'll eat other overlays.

newTalent{
	name = "Time Skip",
	type = {"chronomancy/timetravel",3},
	require = chrono_req3,
	points = 5,
	cooldown = 10,
	paradox = 10,
	tactical = { ATTACK = 1, DISABLE = 2 },
	range = 6,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 250) * getParadoxModifier(self, pm) end,
	getDuration = function(self, t) return 4 + math.floor(self:getTalentLevel(t) / 3 * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		-- Find the target and check hit
		local tg = {type="hit", self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		tx, ty = checkBackfire(self, tx, ty)
		if tx then
			target = game.level.map(tx, ty, engine.Map.ACTOR)
		end
		if target and not target.player then
			local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
			if not hit then
				game.logSeen(target, "The spell fizzles!")
				return true
			end
		else
			return
		end

		-- Keep the Actor from leveling on return
		target.forceLevelup = false
		-- Create an object to time the effect and store the creature
		-- First, clone the terrain that we are replacing
		local terrain = game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN)
		local temporal_instability = mod.class.Object.new{
			old_feat = game.level.map(target.x, target.y, engine.Map.TERRAIN),
			name = "temporal instability", type="temporal", subtype="anomaly",
			display = '&', color=colors.LIGHT_BLUE,
			temporary = t.getDuration(self, t),
			canAct = false,
			target = target,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map(self.target.x, self.target.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					local mx, my = util.findFreeGrid(self.target.x, self.target.y, 20, true, {[engine.Map.ACTOR]=true})
					game.zone:addEntity(game.level, self.target, "actor", mx, my)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
		-- Mixin the old terrain
		table.update(temporal_instability, terrain)
		-- Now update the display overlay
		local overlay = engine.Entity.new{
		--	image = "terrain/wormhole.png",
			display = '&', color=colors.LIGHT_BLUE, image="object/temporal_instability.png",
			display_on_seen = true,
			display_on_remember = true,
		}
		if not temporal_instability.add_displays then
			temporal_instability.add_displays = {overlay}
		else
			table.append(temporal_instability.add_displays, overlay)
		end

		self:project(tg, tx, ty, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(tx, ty, 1, "temporal_thrust")
		game:playSoundNear(self, "talents/arcane")
		-- Remove the target and place the temporal placeholder
		if not target.dead then
			if target ~= self then
				target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
			end
			game.logSeen(target, "%s has moved forward in time!", target.name:capitalize())
			game.level:removeEntity(target)
			game.level:addEntity(temporal_instability)
			game.level.map(target.x, target.y, engine.Map.TERRAIN, temporal_instability)
		else
			game.logSeen(target, "%s has been killed by the temporal energy!", target.name:capitalize())
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Inflicts %0.2f temporal damage.  If your target survives it will be sent %d turns into the future.
		The duration will scale with your Paradox.  The damage will scale with Paradox and the Magic stat.]]):format(damDesc(self, DamageType.TEMPORAL, damage), duration)
	end,
}

newTalent{
	name = "Revision",
	type = {"chronomancy/timetravel", 4},
	require = chrono_req4,
	points = 5,
	paradox = 100,
	cooldown = 100,
	no_npc_use = true,
	getPercent = function(self, t) return 20 - (self:getTalentLevelRaw(t) * 2) end,
	on_learn = function(self, t)
		self:attr("game_cloning", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("game_cloning", -1)
	end,
	action = function(self, t)
	
		-- Prevent Revision After Death
		if game._chronoworlds == nil then
			game.logPlayer(game.player, "#LIGHT_RED#Your spell fizzles.")
			return
		end		
	
		game:onTickEnd(function()
			if not game:chronoRestore("on_level", true) then
				game.logSeen(self, "#LIGHT_RED#The spell fizzles.")
				return
			end
			game.logPlayer(game.player, "#LIGHT_BLUE#You unfold the space time continuum to a previous state!")
						
			-- Manualy start the cooldown of the "old player"
			game.player:startTalentCooldown(t)
			game.player:incParadox(t.paradox * (1 + (game.player.paradox / 300)))
			game.player.max_life = game.player.max_life * (1 - t.getPercent(self, t) / 100)
		end)
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t)
		return ([[Casting this spell sends you back to the moment you entered the current dungeon level.  Traveling through time carries with it inherent penalties and doing so will permanently reduce your hit points by %d%%.
		Additional talent points will lower the hit point cost.]])
		:format(percent)
	end,
}
