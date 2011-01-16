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

require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"

module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, spots)
	engine.Generator.init(self, zone, map, level, spots)
	self.data = level.data.generator.actor
	self.level = level
	self.rate = self.data.rate
	self.max_rate = 5
	self.turn_scale = game.energy_per_tick / game.energy_to_act
end

function _M:tick()
	if game.level.arena.initEvent == true and game.level.arena.lockEvent == false then
		game.level.arena.lockEvent = true
		if game.level.arena.event == 1 then
			local mboss = math.floor(game.level.arena.currentWave / game.level.arena.eventWave)
			self:summonMiniboss(mboss)
			return
		elseif game.level.arena.event == 2 then
			local boss = math.floor(game.level.arena.currentWave / (game.level.arena.eventWave * 3))
			self:generateBoss(boss)
			return
		elseif game.level.arena.event == 3 then
			self:generateMaster()
		end
	end

	if game.level.arena.pinch == true or game.level.turn_counter or game.level.arena.delay > 0 then return
	else --Get entity data.
		local dangerMin = 1 + math.floor(game.level.arena.currentWave * 0.1)
		local dangerMax = dangerMin + (game.level.arena.currentWave ^ game.level.arena.dangerMod)
		local en = rng.range(dangerMin, dangerMax)
		local t = self:calculateWave()
		if t.special then t = t.special(t) end
		for i = 1, t.wave do
			self:generateOne(t)
		end
		if t.entitySub then t.entity = t.entitySub self:generateOne(t) end
		game.level.arena.delay = self:mitigateDelay(t.delay, en)
	end
end

function _M:mitigateDelay(val, l)
	local wave = game.level.arena.currentWave
	if wave > 10 and l + 1 < wave then
		local reduction = math.floor(wave * 0.1)
		if reduction > 3 then reduction = 3 end
	end
	return val
end

function _M:summonMiniboss(val)
	local miniboss = {
		{ name = "SKELERAT", wave = 4, entry = 2, display = "Skeletal rats", score = 100, power = 5 },
		{ name = "GLADIATOR", wave = 2, entry = 1, display = "Gladiators", score = 150, power = 10 },
		{ nil },
		{ name = "GOLDCRYSTAL", wave = 4, entry = 3, display = "Golden crystals", score = 250, power = 15 },
		{ name = "MASTERSLINGER", wave = 3, entry = 2, display = "Master slingers", score = 350, power = 20 },
		{ nil },
		{ name = "MASTERALCHEMIST", wave = 1, entry = 1, display = "Master Alchemist", score = 400, power = 25 },
		{ name = "MULTIHUEWYRMIC", wave = 1, entry = 1, display = "Multi-hued Wyrmic", score = 400, power = 30 },
		{ nil },
		{ name = "REAVER", wave = 2, entry = 2, display = "Reaver", score = 800, power = 40 },
		{ name = "HEADLESSHORROR", wave = 1, entry = 1, display = "Headless horror", score = 1000, power = 50 },
	}
	local e = miniboss[val] or miniboss[1]
	for i = 1, e.wave do
		self:generateMiniboss(e)
	end
	game.level.arena.display = {game.player.name.." the "..game.level.arena.printRank(game.level.arena.rank, game.level.arena.ranks), e.display}
	local verb = ""
	game:playSoundNear(game.player, "talents/teleport")
	if e.wave > 1 then verb = " appear!!" else verb = " appears!!" end
	game.log("#LIGHT_RED#"..e.display..verb)
end

function _M:getEntrance(val)
	if val == 1 then return game.level.arena.entry.main
		elseif val == 3 then return game.level.arena.entry.crystal
		else return game.level.arena.entry.corner
	end
end

function _M:generateMiniboss(e)
	local m = self.zone:makeEntityByName(self.level, "actor", e.name)
	if m then
		local entry = self:getEntrance(e.entry)
		m.arenaPower = e.power
		m.arenaScore = e.score
		if m.on_added then m.on_added_orig = m.on_added end
		m.on_added = function (self)
			if m.on_added_orig then m.on_added_orig(self) end
			game.level.arena.danger = game.level.arena.danger + self.arenaPower
			game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
			game.level.arena.pinchValue = game.level.arena.pinchValue + self.arenaPower
		end
		if m.on_die then m.on_die_orig = m.on_die end
		m.on_die = function (self)
			if m.on_die_orig then m.on_die_orig(self) end
			game.level.arena.danger = game.level.arena.danger - self.arenaPower
			game.level.arena.bonus = game.level.arena.bonus + self.arenaScore
			game.level.map:particleEmitter(self.x, self.y, 1, "ball_fire", {radius = 1})
		end
		self:place(m, entry, true)
	else print("[ARENA] Miniboss error ("..e.display..")")
	end
end

function _M:place(m, entry, elite)
	local place = rng.range(1, entry.max)
	local x, y = entry[place]()
	local tries = 0
	while (not m:canMove(x, y)) and tries < entry.max + 2 do
		x, y = entry[place]()
		place = rng.range(1, entry.max)
		tries = tries + 1
	end
	if elite == true then
		self.zone:addEntity(self.level, m, "actor", x, y)
	elseif tries < entry.max + 2 then
		self.zone:addEntity(self.level, m, "actor", x, y)
	end
end


function _M:generateBoss(val)
	local bosses = {
		{ name = "ARENA_BOSS_RYAL", display = "Ryal the Towering", chat = "arena_boss_ryal",
		score = 1500, power = 35,
		start = function ()
			local Chat = require "engine.Chat"
			local chat = Chat.new("arena", {name="Boss fight!"}, game.player)
			chat:invoke("ryal-entry")
		end,
		finish = function ()
			local Chat = require "engine.Chat"
			local chat = Chat.new("arena", {name="Victory!!"}, game.player)
			chat:invoke("ryal-defeat")
		end
		},
		{ name = "ARENA_BOSS_FRYJIA", display = "Fryjia the Hailstorm", chat= "arena_boss_fryjia",
		score = 2500, power = 55,
		start = function ()
			local Chat = require "engine.Chat"
			local chat = Chat.new("arena", {name="Boss fight!"}, game.player)
			chat:invoke("fryjia-entry")
		end,
		finish = function ()
			local Chat = require "engine.Chat"
			local chat = Chat.new("arena", {name="Victory!!"}, game.player)
			chat:invoke("fryjia-defeat")
		end
		},
		{ name = "ARENA_BOSS_RIALA", display = "Riala the Crimson", chat = "arena_boss_riala",
		score = 3500, power = 85,
		start = function ()
			local Chat = require "engine.Chat"
			local chat = Chat.new("arena", {name="Boss fight!"}, game.player)
			chat:invoke("riala-entry")
		end,
		finish = function ()
			local Chat = require "engine.Chat"
			local chat = Chat.new("arena", {name="Victory!!"}, game.player)
			chat:invoke("riala-defeat")
		end
		},
		{ name = "ARENA_BOSS_VALFREN", display = "Valfren the Rampage", chat = "arena_boss_valfren",
		score = 4500, power = 125,
		start = function ()
			game.level.map:setShown(0.3, 0.3, 0.3, 1)
			game.level.map:setObscure(0.3*0.6, 0.3*0.6, 0.3*0.6, 1)
			local Chat = require "engine.Chat"
			local chat = Chat.new("arena", {name="Boss fight!"}, game.player)
			chat:invoke("valfren-entry")
		end,
		finish = function ()
			game.level.map:setShown(1, 1, 1, 1)
			game.level.map:setObscure(1*0.6, 1*0.6, 1*0.6, 1)
			local Chat = require "engine.Chat"
			local chat = Chat.new("arena", {name="Victory!!"}, game.player)
			chat:invoke("valfren-defeat")
		end
		},
	}
	local e = bosses[val] or bosses[1]
	local m = self.zone:makeEntityByName(self.level, "actor", e.name)
	if m then
		m.arenaPower = e.power
		m.arenaScore = e.score
		m.on_added = function (self)
			game.level.arena.danger = game.level.arena.danger + self.arenaPower
			game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
			game:playSoundNear(game.player, "talents/teleport")
			game.level.arena.pinchValue = game.level.arena.pinchValue + self.arenaPower
		end
		m.on_die = function (self)
			game.level.arena.danger = game.level.arena.danger - self.arenaPower
			game.level.arena.bonus = game.level.arena.bonus + self.arenaScore
			game.level.map:particleEmitter(self.x, self.y, 1, "ball_fire", {radius = 2})
			self.arenaDefeat()
		end
		e.start()
		m.arenaDefeat = e.finish
		self.zone:addEntity(self.level, m, "actor", 7, 1)
		game.level.arena.display = {game.player.name.." the "..game.level.arena.printRank(game.level.arena.rank, game.level.arena.ranks), e.display}
		game.log("#LIGHT_RED#WARNING! "..e.display.." appears!!!")
		else print("[ARENA] - Boss error #1! ("..e.display..")")
	end
end

function _M:generateMaster()
	local defmaster = true
	local master
	if game.level.arena.finalWave < 60 then
		master = world.arena.master30 or nil
	else
		master = world.arena.master60 or nil
	end
	if master then
		if master.version[1] == game.__mod_info.version[1] and	master.version[2] == game.__mod_info.version[2] and master.version[3] == game.__mod_info.version[3] then
			defmaster = false
		else
			defmaster = true
		end
	else defmaster = true
	end

	if defmaster == true then
		local m = self.zone:makeEntityByName(self.level, "actor", "ARENA_BOSS_MASTER_DEFAULT")
		if m then
			m.on_added = function (self)
				local Chat = require "engine.Chat"
				local chat = Chat.new("arena", {name="The final fight!"}, game.player)
				chat:invoke("master-entry")
				game.level.arena.danger = game.level.arena.danger + 1000
				game.level.map:particleEmitter(self.x, self.y, 3, "teleport")
				game:playSoundNear(game.player, "talents/teleport")
				game.level.arena.pinchValue = game.level.arena.pinchValue + 100
			end
			m.on_die = function (self)
				game.level.arena.danger = 0
				game.level.arena.bonus = 100
				game.level.map:particleEmitter(self.x, self.y, 1, "ball_fire", {radius = 5})
				game.level.arena.clear()
				local Chat = require "engine.Chat"
				local chat = Chat.new("arena", {name="Congratulations!"}, game.player)
				chat:invoke("master-defeat")
			end
			self.zone:addEntity(self.level, m, "actor", 7, 1)
			local rank = math.floor(game.level.arena.rank)
			game.level.arena.display = {game.player.name.." the "..game.level.arena.printRank(game.level.arena.rank, game.level.arena.ranks), "Rej the Master of Arena"}
			game.log("#LIGHT_RED#WARNING! Rej Arkatis, the master of the arena, appears!!!")
			else print("[ARENA] - Finale error #1! (Default master error)")
		end
	else
		local m = master
		mod.class.NPC.castAs(m)
		engine.interface.ActorAI.init(m, m)
		m.on_added = function (self)
			local Chat = require "engine.Chat"
			local chat = Chat.new("arena", {name="The final fight!"}, game.player)
			chat:invoke("master-entry")
			game.level.arena.danger = game.level.arena.danger + 1000
			game.level.map:particleEmitter(self.x, self.y, 3, "teleport")
			game:playSoundNear(game.player, "talents/teleport")
			game.level.arena.pinchValue = game.level.arena.pinchValue + 100
		end
		m.on_die = function (self)
			game.level.arena.danger = 0
			game.level.arena.bonus = 100
			game.level.map:particleEmitter(self.x, self.y, 1, "ball_fire", {radius = 3})
			game.level.arena.clear()
			local Chat = require "engine.Chat"
			local chat = Chat.new("arena", {name="Congratulations!"}, game.player)
			chat:invoke("master-defeat")

		end
		self.zone:addEntity(self.level, m, "actor", 7, 1)
		game.level.arena.display = {game.player.name.." the "..game.level.arena.printRank(game.level.arena.rank, game.level.arena.ranks), m.name.." the Master of Arena"}
		game.log("#LIGHT_RED#WARNING! "..m.name..", the master of the arena, appears!!!")
	end
end

function _M:calculateWave()
--TODO:Apply some reduction in delay based on current wave.
	local foe = {
--Relative cannon fodder.
		{ entity = { type = "vermin", subtype = "rodent" }, --Wave 1
			wave = 4, power = 2, delay = 3, bonus = 0.1, score = 5, entry = 2 },
		{ entity = { type = "insect", subtype = "ant" },
			wave = 2, power = 2, delay = 2, bonus = 0.1, score = 15 , entry = 2 },
		{ entity = { type = "animal", subtype = "canine" },
			wave = 2, power = 3, delay = 3, bonus = 0.1 , score = 25, entry = 2 },
		{ entity = { name = "white ooze" },
			wave = 1, power = 3, delay = 3, bonus = 0.1, score = 15, entry = 2,
			special = function (self) if game.level.arena.currentWave > 10 then self.wave = 2 end if game.level.arena.currentWave > 15 then self.entity = { name = "green ooze" } end return self end },
		{ entity = { name = "cutpurse" }, --Wave ~5
			wave = 1, power = 8, delay = 3, bonus = 0.1, score = 40, entry = 1 },
		{ entity = { name = "white crystal" },
			wave = 1, power = 5, delay = 4, bonus = 0.5 , score = 100, entry = 3},
		{ entity = { name = "slinger" },
			wave = 1, power = 7, delay = 4, bonus = 0.2, score = 100, entry = 1,
			special = function (self) if game.level.arena.currentWave > 35 then self.entity = { name = "high slinger" } end return self end },
		{ entity = { name = "brown bear" },
			wave = 1, power = 4, delay = 3, bonus = 0.2, score = 100 , entry = 2},
		{ entity = { type = "animal", subtype = "snake" },
			wave = 2, power = 4, delay = 3, bonus = 0.1, score = 100 , entry = 2},
		{ entity = { type = "humanoid", subtype = "human", name = "rogue" }, --Wave ~10
			wave = 1, power = 6, delay = 3, bonus = 0.2, score = 100 , entry = 1,
			special = function (self) if game.level.arena.currentWave > 30 then self.wave = 2 end return self end },
		{ entity = { type = "animal", subtype = "bear" },
			wave = 2, power = 4, delay = 5, bonus = 0.3, score = 80, entry = 2 },
		{ entity = { type = "vermin", subtype = "ooze" },
			wave = 4, power = 3, delay = 2, bonus = 0.1, score = 15, entry = 2 },
		{ entity = { type = "undead", subtype = "skeleton" },
			wave = 1, power = 8, delay = 4, bonus = 0.2, score = 120, entry = 2,
			special = function (self) if game.level.arena.currentWave > 15 then self.wave = 2 end return self end },
		{ entity = { name = "ghoul" },
			wave = 1, power = 7, delay = 5, bonus = 0.2, score = 150, entry = 1,
			special = function (self) if game.level.arena.currentWave > 20 then self.wave, self.entry = 2, 2 end return self end },
		{ entity = { type = "humanoid", subtype = "human", name = "alchemist" },
			wave = 1, power = 9, delay = 3, bonus = 0.2, score = 150, entry = 1,
			special = function (self) if game.level.arena.currentWave > 25 then self.wave = 2 end return self end },
		{ entity = { type = "immovable", subtype = "crystal" },
			wave = 2, power = 5, delay = 3, bonus = 0.5 , score = 100, entry = 3,
			special = function (self) if game.level.arena.currentWave > 20 then self.wave = 3 end if game.level.arena.currentWave > 45 then self.wave = 4 end return self end },
		{ entity = { type = "giant", subtype = "troll" },
			wave = 1, power = 4, delay = 2, bonus = 0.2 , score = 150, entry = 1 },
		{ entity = { name = "blood mage" },
			wave = 1, power = 10, delay = 2, bonus = 0.5 , score = 200, entry = 1 },
		{ entity = { name = "honey tree" },
			wave = 1, power = 4, delay = 3, bonus = 0.3 , score = 120, entry = 3,
			special = function (self) if game.level.arena.currentWave > 35 then self.wave, self.score  = 2, 150 end return self end },
		{ entity = { name = "skeleton mage" },
			wave = 1, power = 10, delay = 4, bonus = 0.3, score = 150 , entry = 1,
			special = function (self) if game.player.level > 10 then self.wave = 2 end return self end },
		{ entity = { name = "high gladiator" },
			wave = 1, power = 6, delay = 1, bonus = 0.3, score = 200, entry = 1,
			special = function (self) if game.level.arena.currentWave > 30 then self.wave = 2 end return self end },
		{ entity = { name = "wisp" },
			wave = 4, power = 1, delay = 1, bonus = 0.3, score = 50 , entry = 3 },
		{ entity = { name = "minotaur" },
			wave = 1, power = 12, delay = 3, bonus = 0.3, score = 150 , entry = 2 },
		{ entity = { name = "shadowblade" },
			wave = 1, power = 13, delay = 1, bonus = 0.4, score = 200 , entry = 1 },
		{ entity = { name = "orc soldier" },
			wave = 1, power = 10, delay = 4, bonus = 0.3, score = 150 , entry = 1,
			special = function (self) if game.level.arena.currentWave > 25 then self.entity = {type = "humanoid", subtype = "orc"} end return self end },
		{ entity = { name = "bone giant" },
			wave = 1, power = 11, delay = 3, bonus = 0.3, score = 150 , entry = 2,
			special = function (self) if game.player.level > 30 then self.wave, self.power = 2, 8 end return self end },
		{ entity = { name = "ziguranth warrior" },
			wave = 2, power = 8, delay = 2, bonus = 0.3, score = 130 , entry = 1 },
		{ entity = { name = "orc archer" },
			wave = 2, power = 10, delay = 5, bonus = 0.2, score = 100, entry = 2,
			special = function (self) if game.player.level > 25 then self.wave, self.score  = 3, 125 end if game.player.level > 35 then self.wave, self.score  = 4, 150 end return self end },
		{ entity = { name = "hexer" },
			wave = 1, power = 13, delay = 1, bonus = 0.5 , score = 250, entry = 1 },
		{ entity = { name = "wisp" },
			wave = 6, power = 1, delay = 1, bonus = 0.3, score = 50 , entry = 3 },
		{ entity = { name = "orc assassin" },
			wave = 2, power = 10, delay = 4, bonus = 0.2, score = 200, entry = 2 },
		{ entity = { name = "fire wyrmic" }, entitySub = { name = "ice wyrmic"},
			wave = 1, power = 11, delay = 3, bonus = 0.3, score = 250, entry = 1 },
		{ entity = { name = "sand wyrmic" }, entitySub = { name = "storm wyrmic" },
			wave = 1, power = 11, delay = 3, bonus = 0.3, score = 250, entry = 1 },
		{ entity = { name = "martyr" },
			wave = 1, power = 13, delay = 1, bonus = 0.5 , score = 250, entry = 1 },
		{ entity = { type = "vermin", subtype = "sandworm" },
			wave = 1, power = 10, delay = 3, bonus = 0.2, score = 200, entry = 2 },
		{ entity = { name = "ritch larva" },
			wave = 2, power = 4, delay = 3, bonus = 0.1, score = 150, entry = 2 },
		{ entity = { type = "giant", subtype = "ice" },
			wave = 1, power = 8, delay = 2, bonus = 0.5, score = 300, entry = 1 },
		{ entity = { name = "naga myrmidon" },
			wave = 1, power = 9, delay = 2, bonus = 0.3, score = 300, entry = 1,
			special = function (self) if game.level.arena.currentWave > 40 then self.wave = 2 end return self end },
		{ entity = { name = "quasit" },
			wave = 1, power = 9, delay = 2, bonus = 0.2, score = 300, entry = 2 },
		{ entity = { name = "wretchling" },
			wave = 1, power = 10, delay = 3, bonus = 0.3, score = 250, entry = 2,
			special = function (self) if game.player.level > 25 then self.wave = 3 end if game.player.level > 35 then self.wave = 4 end return self end },
		{ entity = { name = "great gladiator" },
			wave = 2, power = 9, delay = 3, bonus = 0.3, score = 300, entry = 1 },
		{ entity = { name = "bloated horror" },
			wave = 2, power = 11, delay = 2, bonus = 0.4, score = 300, entry = 3 },
		{ entity = { name = "umber hulk" },
			wave = 1, power = 10, delay = 3, bonus = 0.3, score = 350, entry = 1 },
		{ entity = { name = "anorithil" },
			wave = 1, power = 10, delay = 2, bonus = 0.5, score = 450, entry = 1 },
		{ entity = { name = "naga tide huntress" },
			wave = 1, power = 10, delay = 2, bonus = 0.3, score = 300, entry = 2 },
		{ entity = { name = "ritch hunter" },
			wave = 4, power = 6, delay = 5, bonus = 0.4, score = 250, entry = 2 },
		{ entity = { type = "undead", subtype = "wight" },
			wave = 1, power = 11, delay = 2, bonus = 0.5, score = 400, entry = 1 },
		{ entity = { name = "sun paladin" },
			wave = 1, power = 12, delay = 2, bonus = 1, score = 450, entry = 1 },
		{ entity = { name = "dread" },
			wave = 1, power = 13, delay = 2, bonus = 1, score = 450, entry = 2 },
		{ entity = { name = "naga psyren" },
			wave = 1, power = 10, delay = 2, bonus = 0.3, score = 400, entry = 2 },
		{ entity = { name = "star crusader" },
			wave = 1, power = 14, delay = 2, bonus = 1, score = 450, entry = 2 },

	}
	local dangerMin = 1 + math.floor(game.level.arena.currentWave * 0.1)
	local dangerMax = dangerMin + (game.level.arena.currentWave ^ game.level.arena.dangerMod)
	if dangerMax > #foe then dangerMax = #foe end
	local val = rng.range(dangerMin, dangerMax)
	return foe[val]
end

function _M:generateOne(e)
	local m = self.zone:makeEntity(self.level, "actor", e.entity, nil, true)
	if m then
		local escort = m.make_escort
		m.make_escort = nil
		local entry = self:getEntrance(e.entry)
		m.arenaPower = e.power * m.level
		m.arenaBonusMult = e.bonus
		m.arenaScore = e.score
		if m.on_added then m.on_added_orig = m.on_added end
		if e.entry == 3 then
			m.on_added = function (self)
				if self.on_added_orig then self.on_added_orig(self) end
				game.level.arena.danger = game.level.arena.danger + self.arenaPower
				game:playSoundNear(game.player, "talents/teleport")
				game.level.map:particleEmitter(self.x, self.y, 0.5, "teleport")
			end
		else
			m.on_added = function (self)
				if m.on_added_orig then m.on_added_orig(self) end
				game.level.arena.danger = game.level.arena.danger + self.arenaPower
			end
		end
		if m.on_die then m.on_die_orig = m.on_die end
		m.on_die = function (self)
			if self.on_die_orig then self.on_die_orig(self) end
			game.level.arena.danger = game.level.arena.danger - self.arenaPower
			if game.level.arena.pinch == false then
				game.log("#LIGHT_GREEN#Your score multiplier increases by #WHITE#"..self.arenaBonusMult.."#LIGHT_GREEN#!")
				game.level.arena.bonusMultiplier = game.level.arena.bonusMultiplier + self.arenaBonusMult
			else
				game.level.arena.bonus = game.level.arena.bonus + self.arenaScore
			end
			game.level.arena.kills = game.level.arena.kills + 1
			if game.level.arena.kills > 5 then
				game.level.arena.bonusMultiplier = game.level.arena.bonusMultiplier + 0.1
				game.log("#LIGHT_GREEN#Your score multiplier increases by #WHITE#0.1#LIGHT_GREEN#!")
			end
			if self.level > game.player.level + 3 then
				game.log("#YELLOW#You defeat an experienced enemy!")
				local raise = (self.level - game.player.level) + 0.03
				if raise > 0.5 then raise = 0.5 end
				game.level.arena.raiseRank(raise)
			end
		end
		self:place(m, entry, false)
	end
end
