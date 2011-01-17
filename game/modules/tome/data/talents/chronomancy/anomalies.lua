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

-- Ideas, sex change, gold loss/increase, draining/charging charged items.  Stat rearrangement.  Vertigo (reassign hotkeys so up is down left is right)

local Object = require "engine.Object"

newTalent{
	name = "Anomaly Teleport",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 6,
	direct_hit = true,
	type_no_req = true,
	getTargetCount = function(self, t) return math.floor(self:getParadox()/200) end,
	getRange = function(self, t) return (self:getParadox()/10) end,
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 6, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and a:canBe("teleport") then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			game.level.map:particleEmitter(a.x, a.y, 1, "teleport")
			a:teleportRandom(a.x, a.y, t.getRange(self, t), 15)
			game.level.map:particleEmitter(a.x, a.y, 1, "teleport")
		end
		game.logSeen(self, "Reality has shifted.")
		return true
	end,
	info = function(self, t)
		local targets = t.getTargetCount(self, t)
		local range = t.getRange(self, t)
		return ([[Randomly teleports %d targets within range of the caster %d tiles away.]]):format(targets, range)
	end,
}

newTalent{
	name = "Anomaly Rearrange",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 6,
	direct_hit = true,
	type_no_req = true,
	getTargetCount = function(self, t) return math.floor(self:getParadox()/50) end,
	getRange = function(self, t) return (self:getParadox()/100) end,
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 6, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and a:canBe("teleport") then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			game.level.map:particleEmitter(a.x, a.y, 1, "teleport")
			a:teleportRandom(a.x, a.y, t.getRange(self, t), 1)
			game.level.map:particleEmitter(a.x, a.y, 1, "teleport")
		end
		game.logSeen(self,"%s has caused a hiccup in the fabric of spacetime.", self.name)
		game.logSeen(self, "Reality has shifted.")
		return true
	end,
	info = function(self, t)
		local targets = t.getTargetCount(self, t)
		local range = t.getRange(self, t)
		return ([[Randomly teleports %d targets within range of the caster %d tiles away.]]):format(targets, range)
	end,
}

newTalent{
	name = "Anomaly Stop",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 6,
	direct_hit = true,
	type_no_req = true,
	getTargetCount = function(self, t) return 1 end,
	getRadius = function(self, t) return math.floor(self:getParadox()/200) end,
	getStop = function(self, t) return (self:getParadox()/100) end,
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 6, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t), friendlyfire=self:spellFriendlyFire(), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.STOP, t.getStop(self, t))
			game.level.map:particleEmitter(a.x, a.y, tg.radius, "ball_temporal", {radius=tg.radius, tx=a.x, ty=a.y})
			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[Stuns all targets in a ball.]])
	end,
}

newTalent{
	name = "Anomaly Slow",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 6,
	direct_hit = true,
	type_no_req = true,
	getTargetCount = function(self, t) return 1 end,
	getRadius = function(self, t) return math.floor(self:getParadox()/200) end,
	getSlow = function(self, t) return 1 - 1 / (1 + (self:getParadox()/15) / 100) end,
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 6, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t), friendlyfire=self:spellFriendlyFire(), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.SLOW, t.getSlow(self, t))
			game.level.map:particleEmitter(a.x, a.y, tg.radius, "ball_temporal", {radius=tg.radius, tx=a.x, ty=a.y})
			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[Slows all targets in a ball.]])
	end,
}

newTalent{
	name = "Anomaly Haste",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 6,
	direct_hit = true,
	type_no_req = true,
	getTargetCount = function(self, t) return math.floor(self:getParadox()/300) end,
	getPower = function(self, t) return ((self:getParadox()/15) / 100) end,
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 6, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			a:setEffect(self.EFF_SPEED, 8, {power=t.getPower(self, t)})
			game.level.map:particleEmitter(a.x, a.y, 1, "teleport")
			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[Increases global speed in a ball on target.]])
	end,
}

newTalent{
	name = "Anomaly Spacetime Correction",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	action = function(self, t)
		self:incParadox (-(self:getParadox()*0.5))
		game.logSeen(self, "A spacetime correction has occurred.")
		return true
	end,
	info = function(self, t)
		return ([[Massive Paradox Loss.]])
	end,
}

newTalent{
	name = "Anomaly Spacetime Damage",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	action = function(self, t)
		self:incParadox ((self:getParadox()*0.5))
		game.logSeen(self, "%s has done damage to the spacetime continuum!", self.name)
		return true
	end,
	info = function(self, t)
		return ([[Massive Paradox gain.]])
	end,
}

newTalent{
	name = "Anomaly Temporal Storm",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	getDamage = function(self, t) return self:getParadox()/25 end,
	getDuration = function(self, t) return self:getParadox()/50 end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.TEMPORAL, t.getDamage(self, t),
			3,
			5, nil,
			engine.Entity.new{alpha=75, display='', color_br=200, color_bg=200, color_bb=0},
			nil, self:spellFriendlyFire()
		)
		game.logSeen(self, "A temporal storm rages around %s!", self.name)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Creates a temporal storm for %d turns that deals %d temporal damage each turn.]])
		:format(duration, damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

newTalent{
	name = "Anomaly Summon Time Elemental",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 6,
	direct_hit = true,
	type_no_req = true,
	getTargetCount = function(self, t) return math.floor(self:getParadox()/200) end,
	getSummonTime = function(self, t) return math.floor(self:getParadox()/50) end,
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 6, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and a:canBe("teleport") then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			-- Find space
			local x, y = util.findFreeGrid(a.x, a.y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to summon!")
				return
			end

			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "elemental", subtype = "temporal",
				display = "E", color=colors.YELLOW,
				name = "Telugoroth", faction = a.faction,
				desc = [[A temporal elemental, rarely encountered except by those who travel through time itself.  It's blurred form constantly shifts before your eyes.]],
				combat = { dam=resolvers.mbonus(40, 15), atk=15, apr=15, dammod={mag=0.8}, damtype=DamageType.TEMPORAL },
				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
				autolevel = "none",
				energy = { mod=1.5 },
				stats = { str=8, dex=12, mag=12, wil= 12, con=10 },
				ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, },
				level_range = {self.level, self.level},

				resists = { [DamageType.PHYSICAL] = 10, [DamageType.TEMPORAL] = 100, },

				no_breath = 1,
				poison_immune = 1,
				disease_immune = 1,

				max_life = resolvers.rngavg(70,80),
				life_rating = 8,
				infravision = 10,
				rank = 2,
				size_category = 3,

				autolevel = "dexmage",

				combat_armor = 0, combat_def = 20,

				on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },

				resolvers.talents{
					[Talents.T_TURN_BACK_THE_CLOCK]=3,
				},

				summoner = self, summoner_gain_exp=false,
				summon_time = t.getSummonTime(self, t),
			--	ai_target = {actor=target}
			}

			m:resolve() m:resolve(nil, true)
			m:forceLevelup(self.level)
			game.zone:addEntity(game.level, m, "actor", x, y)
			game.level.map:particleEmitter(x, y, 1, "summon")

			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[Summons a time elemental that may or may not be friendly to the caster.]])
	end,
}

newTalent{
	name = "Anomaly Temporal Bubble",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 6,
	type_no_req = true,
	getTargetCount = function(self, t) return math.floor(self:getParadox()/200) end,
	getDuration = function(self, t) return (self:getParadox()/100) end,
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 6, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and a:canBe("teleport") then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.TIME_PRISON, t.getDuration(self, t), {type="manathrust"})
		end
		game.logSeen(self,"%s has paused a thread in time.", self.name)
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local target = t.getTargetCount(self, t)
		return ([[Places %d random targets in time prisons for %d turns.]])
		:format(target, duration)
	end,
}

--[[newTalent{
	name = "Anomaly Terrain Change",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Random Terrain in a ball.)
	end,
}

newTalent{
	name = "Anomaly Dig",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Random Terrain in a ball.)
	end,
}

newTalent{
	name = "Anomaly Stat Reorder",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Target loses stats.)
	end,
}

newTalent{
	name = "Anomaly Heal",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Target is healed to full life.)
	end,
}

newTalent{
	name = "Anomaly Double",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Clones a random non-elite creature.  Clone may or may not be hostile to the caster.)
	end,
}

newTalent{
	name = "Anomaly Swap",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Caster swaps places with a random target.)
	end,
}

newTalent{
	name = "Anomaly Sex Change",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_npc_use = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ()
	end,
}

newTalent{
	name = "Anomaly Money Changer",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_npc_use = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ()
	end,
}

newTalent{
	name = "Anomaly Spacetime Folding",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ()
	end,
}

newTalent{
	name = "Anomaly Charge/Drain",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_npc_use = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ()
	end,
}

newTalent{
	name = "Anomaly Vertigo",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_npc_use = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ()
	end,
}

newTalent{
	name = "Anomaly Evil Twin",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	requires_target = true,
	getSummonTime = function(self, t) return math.floor(self:getParadox()/50) end,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Clones the caster)
	end,
}]]