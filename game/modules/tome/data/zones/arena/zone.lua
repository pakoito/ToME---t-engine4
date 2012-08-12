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

return {
	name = "The Arena",
	level_range = {1, 50},
	level_scheme = "player",
	max_level = 1,
	actor_adjust_level = function(zone, level, e)
		local val = 0
		if level.arena.bonusMultiplier >= 7 then
			val = math.floor(level.arena.bonusMultiplier * 0.3)
		end
	return game.player.level + rng.range(-2 + val, 2 + val)
	end,
	width = 15, height = 15,
	all_remembered = true,
	all_lited = true,
	no_worldport = true,
	ambient_music = "a_lomos_del_dragon_blanco.ogg",

	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/arena",
			zoom = 4,
		},
		actor = { },
		--object = { },
		--trap = { },

	},


	on_turn = function(self)
		if game.turn % 10 ~= 0 or game.level.arena.event == 4 then return end
		game.level.arena.checkPinch()
		require("mod.class.generator.actor.Arena").new(self, game.level.map, game.level, {}):tick()
		if game.level.turn_counter then
			if game.level.turn_counter > 0 then game.level.turn_counter = game.level.turn_counter - 10
			else
				--Clear up items and do gold bonus if applicable.
				--The wave starts at this point.
				game.level.turn_counter = nil
				if game.level.arena.event == 1 then game.log("#GOLD#Miniboss round starts!!")
				elseif game.level.arena.event == 2 then game.log("#VIOLET#Boss round starts!!!")
				elseif game.level.arena.event == 3 then game.log("#LIGHT_RED#Final round starts!!!!")
				end
				game.level.arena.removeStuff()
				if game.player.money > 0 then
					game.level.arena.goldToScore()
				end
				game.level.arena.openGates()
			end
		end
		if game.level.arena.bonus > 0 then game.level.arena.bonus = game.level.arena.bonus - 10  end
		if game.level.arena.bonus < 0 then game.level.arena.bonus = 0 end
		if game.level.arena.delay > 0 then game.level.arena.delay = game.level.arena.delay - 1  end
		--Only raise danger level while you can raise bonus multiplier.
		if game.level.arena.dangerMod < 1.5 and game.level.arena.pinch == false
		and game.level.arena.delay  <= 0 and not game.level.turn_counter then
			game.level.arena.dangerMod = game.level.arena.dangerMod + 0.05
		end
		--Reset kill counter
		if game.level.arena.kills > 0 then
			game.level.arena.checkCombo(game.level.arena.kills)
			game.level.arena.totalKills = game.level.arena.totalKills + game.level.arena.kills
		 end
		game.level.arena.kills = 0
	end,


	post_process = function(level)
		game.player.money = 0
		game.player.no_resurrect = true
		game.player.on_die = function (self, src)
			local rank = math.floor(game.level.arena.rank)
			local drank
			if rank < 0 then drank = "Master of Arena" else drank = game.level.arena.ranks[rank] or "nobody" end
			local lastScore = {
				name = game.player.name.." the "..drank,
				score = game.level.arena.score,
				perk = game.level.arena.perk,
				wave = game.level.arena.currentWave,
				sex = game.player.descriptor.sex,
				race = game.player.descriptor.subrace,
				class = game.player.descriptor.subclass,
			}
			game.level.arena.updateScores(lastScore)
		end

		--Allow players to shoot bows and stuff by default. Move it back to perks if too powerful.
		game.player:learnTalent(game.player.T_SHOOT, true, nil, {no_unlearn=true})
		game.player.changed = true
		level.turn_counter = 60 --5 turns before action starts.
		level.max_turn_counter = 60 --5 turns before action starts.
		level.turn_counter_desc = ""

		--world.arena = nil
		if not world.arena or not world.arena.ver then
			local emptyScore = {name = nil, score = 0, perk = nil, wave = 1, sex = nil, race = nil, class = nil}
			world.arena = {
				master30 = nil,
				master60 = nil,
				lastScore = emptyScore,
				bestWave = 1,
				ver = 1
			}
			world.arena.scores = {[1] = emptyScore}
			local o = game.zone:makeEntityByName(game.level, "object", "ARENA_SCORING")
			if o then game.zone:addEntity(game.level, o, "object", 7, 3) end
		end
		level.arena = {
			ranks = { "nobody", "rat stomper", "aspirant", "fighter", "brave", "dangerous", "promise", "powerful", "rising star", "destroyer", "obliterator", "annihilator", "grandious", "glorious", "victorious", "ultimate", "ultimate", "ultimate", "ultimate", "ultimate", "grand master" },
			rank = 1,
			perk = nil,
			event = 0,
			initEvent = false,
			lockEvent = false,
			display = nil,
			kills = 0,
			totalKills = 0,
			currentWave = 1,
			eventWave = 5,
			finalWave = 61,
			modeString = "60",
			danger = 0,
			dangerTop = 12,
			dangerMod = 0,
			score = 0,
			delay = 0,
			pinch = false,
			pinchValue = 0,
			bonus = 0,
			clearItems = false,
			bonusMultiplier = 1,
			bonusMin = 1,
			entry = {
				--The physical doors
				door = {
					max = 5,
					function () return 0, 1 end,
					function () return 1, 14 end,
					function () return 14, 1 end,
					function () return 13, 14 end,
					function () return 7, 0 end
				},
				--Main gate
				main = {
					max = 4,
					function () return 7, 0 end,
					function () return 7, 1 end,
					function () return 8, 1 end,
					function () return 6, 1 end
				},
				--Corner gates
				corner = {
					max = 12,
					function () return 1, 1 end,
					function () return 2, 1 end,
					function () return 1, 2 end,

					function () return 13, 13 end,
					function () return 12, 13 end,
					function () return 13, 12 end,

					function () return 1, 13 end,
					function () return 2, 13 end,
					function () return 1, 12 end,

					function () return 13, 1 end,
					function () return 12, 1 end,
					function () return 13, 2 end,
				},
				--Crystal gates
				crystal = {
					max = 8,
					function () return 4, 2 end,
					function () return 10, 2 end,
					function () return 10, 12 end,
					function () return 4, 12 end,

					function () return 1, 4 end,
					function () return 12, 4 end,
					function () return 1, 10 end,
					function () return 12, 10 end,
				}
			},
			clear = function()
				game.player:setQuestStatus("arena", engine.Quest.COMPLETED)
				local master = game.player:cloneFull()
				game.level.arena.rank = -1
--				game.player:die(game.player)
				master.version = game.__mod_info.version
				master.no_drops = true
				master.energy.value = 0
				master.player = nil
				master.rank = 5
				master.color_r = 255
				master.color_g = 0
				master.color_b = 255
				master:removeAllMOs()
				master.ai = "tactical"
				master.ai_state = {talent_in=1, ai_move="move_astar"}
				master.faction="enemies"
				master.life = master.max_life
				-- Remove some talents
				local tids = {}
				for tid, _ in pairs(master.talents) do
					local t = master:getTalentFromId(tid)
					if t.no_npc_use then tids[#tids+1] = t end
				end
				game.level.arena.event = 4
				if game.level.arena.finalWave > 60 then
					world:gainAchievement("MASTER_OF_ARENA", game.player)
					world.arena.master60 = master
				else
					world:gainAchievement("ALMOST_MASTER_OF_ARENA", game.player)
					world.arena.master30 = master
				end
			end,
			printRankings = function (val)
				local scores = world.arena.scores
				if not scores or not scores[1] or not scores[1].name then return "#LIGHT_GREEN#...but it's been wiped out recently."
				else
					local text = ""
					local tmp = ""
					local line = function (txt, col) return " "..col..txt.."\n" end
					local stri = "%s (%s %s %s)\n Score %d[%s]) - Wave: %d"
					local i = 1
					while(scores[i] and scores[i].name) do
						p = scores[i]
						tmp = stri:format(p.name:capitalize(), p.sex or "???", p.race or "???", p.class or "???", p.score or 0, p.perk or "???", p.wave or 0)
						text = text..line(tmp, "#LIGHT_BLUE#")
						i = i + 1
					end
					p = world.arena.lastScore
					tmp = "\n#YELLOW#LAST:"..stri:format(p.name:capitalize(), p.sex or "unknown", p.race or "unknown", p.class or "unknown", p.score or 0, p.perk or "", p.wave or 0)
					return text..line(tmp, "#YELLOW#")
				end
			end,
			printRank = function (r, ranks)
				local rank = math.floor(r)
				if rank > #ranks then rank = #ranks end
				return ranks[rank]
			end,
			updateScores = function(l)
				local scores = world.arena.scores or {}
				table.insert(scores, l)
				table.sort(scores, function(a,b) return a.score > b.score end)
				if #scores > 10 then table.remove(scores) end
				world.arena.scores = scores
				if l.wave > world.arena.bestWave then world.arena.bestWave = l.wave end
				world.arena.lastScore = l
			end,
			openGates = function()
				local gates = game.level.arena.entry.door
				local g = game.zone:makeEntityByName(game.level, "terrain", "LOCK_OPEN")
				local x, y = 0, 0
				for i = 1, gates.max do
					x, y = gates[i]()
					game.zone:addEntity(game.level, g, "terrain", x, y)
					game.nicer_tiles:updateAround(game.level, x, y)
				end
				game:playSoundNear(game.player, "talents/earth")
				game.log("#LIGHT_GREEN#The gates open!")
			end,
			closeGates = function()
				local gates = game.level.arena.entry.door
				local g = game.zone:makeEntityByName(game.level, "terrain", "LOCK")
				local x, y = 0, 0
				for i = 1, gates.max do
					x, y = gates[i]()
					game.zone:addEntity(game.level, g, "terrain", x, y)
					game.level.map:particleEmitter(x, y, 0.5, "arena_gate")
					game.nicer_tiles:updateAround(game.level, x, y)
				end
				game:playSoundNear(game.player, "talents/earth")
				game.log("#LIGHT_RED#The gates close!")
			end,
			raiseRank = function (val)
				if game.level.arena.rank >= 21 then return end
				local currentRank = math.floor(game.level.arena.rank)
				game.level.arena.rank = game.level.arena.rank + val
				if game.level.arena.rank >= #game.level.arena.ranks then game.level.arena.rank = #game.level.arena.ranks end
				local newRank = math.floor(game.level.arena.rank)
				if currentRank < newRank then --Player's rank increases!
					local x, y = game.level.map:getTileToScreen(game.player.x, game.player.y)
					if newRank == 10 then world:gainAchievement("XXX_THE_DESTROYER", game.player)
					elseif newRank == 21 then world:gainAchievement("GRAND_MASTER", game.player)
					end
					game.flyers:add(x, y, 90, 0, -0.5, "RANK UP!!", { 2, 57, 185 }, true)
					game.log("#LIGHT_GREEN#The public is pleased by your performance! You now have the rank of #WHITE#"..game.level.arena.ranks[newRank].."!")
				end
			end,
			checkCombo = function (k)
				if k >= 10 then world:gainAchievement("TEN_AT_ONE_BLOW", game.player) end
				if k > 2 then
					local x, y = game.level.map:getTileToScreen(game.player.x, game.player.y)
					local b = (k * 0.035) + 0.04
					game.level.arena.raiseRank(b)
					game.flyers:add(x, y, 90, 0.5, 0, k.." kills!", { 2, 57, 185 }, false)
					game.log("#YELLOW#You killed "..k.." enemies in a single turn! The public is excited!")
				else return
				end
			end,
			addTrap = function ()
				local g = game.zone:makeEntity(game.level, "trap", nil, nil, true)
				local d = game.level.arena.currentWave
				g.dam = 5 + (d * 2) + rng.range(d, d * 1.5)
				game.zone:addEntity(game.level, g, "trap", 7, 7)
				g:setKnown(game.player, true)
				game.level.map:updateMap(7, 7)
				game.level.map:particleEmitter(7, 7, 0.3, "demon_teleport")
				if d > 1 then game.log("#YELLOW#The trap changes...") end
			end,
			goldToScore = function ()
				local x, y = game.level.map:getTileToScreen(game.player.x, game.player.y)
				local goldAward = game.player.money * 100
				local healthAward = game.player.money * 10
				local regStamina = goldAward * 0.5
				game.level.arena.score = game.level.arena.score + goldAward
				game.flyers:add(x, y, 90, 0, -0.6, "GOLD BONUS! +"..goldAward.." SCORE!", { 2, 57, 185 }, false)
				game.log("#ROYAL_BLUE#Gold bonus! Score increased by #WHITE#"..goldAward.."#ROYAL_BLUE#! #LIGHT_GREEN#You also recover some health(#WHITE#+"..healthAward.."#LIGHT_GREEN#!)#LAST#")
				if game.player:knowTalent(game.player.T_STAMINA_POOL) then
					game.player:incStamina(regStamina)
					game.log("#LIGHT_GREEN#Stamina(#WHITE#+"..regStamina.."#LIGHT_GREEN#)")
				end
				game.player.money = 0
				game.player:heal(healthAward)
				game.player.changed = true
			end,
			initWave = function (val) --Clean up and start a new wave.
				if val > 20 then --If the player has more than 20 turns of rest, clean up all items lying around.
					game.level.arena.clearItems = true
					game.log("#YELLOW#Items lying around will disappear in #WHITE#"..val.."#YELLOW# turns!#LAST#")
				end
				game.level.arena.dangerTop = game.level.arena.dangerTop + (2 + math.floor(game.level.arena.currentWave * 0.05))
				game.level.arena.currentWave = game.level.arena.currentWave + 1
				game.level.arena.dangerMod = 0.7 + (game.level.arena.currentWave * 0.005)
				game.level.arena.bonus = 0
				game.level.level = game.level.arena.currentWave
				game.level.arena.bonusMultiplier = game.level.arena.bonusMin
				game.level.arena.pinchValue = 0
				game.level.arena.pinch = false
				if game.level.arena.display then game.level.arena.display = nil end
				if game.level.arena.currentWave % game.level.arena.eventWave == 0 then
					if game.level.arena.currentWave % (game.level.arena.eventWave * 3) == 0 then --Boss round!
						game.log("#VIOLET#Boss round!!!")
						game.level.arena.event = 2
					else --Miniboss round!
						game.log("#GOLD#Miniboss round!")
						game.level.arena.event = 1
					end
				elseif game.level.arena.currentWave == game.level.arena.finalWave then --Final round!
					game.level.arena.event = 3
					game.log("#LIGHT_RED#Final round!!!")
				else --Regular stuff.
					game.level.arena.event = 0
				end
				game.level.arena.initEvent = false
				game.level.arena.lockEvent = false
				game.level.arena.addTrap()
				if game.level.arena.currentWave == 21 then world:gainAchievement("ARENA_BATTLER_20", game.player)
				elseif game.level.arena.currentWave == 51 then world:gainAchievement("ARENA_BATTLER_50", game.player)
				end
			end,
			removeStuff = function ()
				for i = 0, game.level.map.w - 1 do
					for j = 0, game.level.map.h - 1 do
						local nb = game.level.map:getObjectTotal(i, j)
						for z = nb, 1, -1 do game.level.map:removeObject(i, j, z) end
					end
				end
			end,
			doReward = function (val)
				local col = "#ROYAL_BLUE#"
				local hgh = "#WHITE#"
				local dangerBonus = val * 0.5
				local scoreBonus = game.level.arena.bonus * 0.2
				local clearBonus = math.ceil(game.level.arena.currentWave ^ 1.85)
				local rankBonus = math.floor(game.level.arena.rank) * 20
				local expAward = (dangerBonus + scoreBonus + clearBonus + rankBonus) * game.level.arena.bonusMultiplier
				local x, y = game.level.map:getTileToScreen(game.player.x, game.player.y)
				game.player:gainExp(expAward)
				game.level.arena.score = game.level.arena.score + game.level.arena.bonus
				game.flyers:add(x, y, 90, 0, -1, "Round Clear! +"..expAward.." EXP!", { 2, 57, 185 }, true)
				game.log(col.."Wave clear!")
				game.log(col.."Clear bonus: "..hgh..clearBonus..col.."! Score bonus: "..hgh..scoreBonus..col.."! Danger bonus: "..hgh..dangerBonus..col.."! Rank bonus: "..hgh..rankBonus..col.."!")
				game.log(col.."Your experience increases by"..hgh..expAward..col.."!")
				game.player.changed = true
			end,
			clearRound = function () --Relax and give rewards.
				--Do rewarding.
				local val = game.level.arena.pinchValue
				local plvl = game.player.level
				game.level.arena.doReward(val)
				--Set rest time.
				local rest_time = val
				if not plvl == game.player.level then --If bonuses made the player level up, give minimal time.
					if rest_time > 30 then rest_time = 30 end
				else
					if rest_time < 25 then rest_time = 25
					elseif rest_time > 80 then rest_time = 80
					end
				end
				game.level.turn_counter = rest_time * 10
				game.level.max_turn_counter = rest_time * 10
				game.level.arena.initWave(val)
			end,
			checkPinch = function ()
				if game.level.arena.danger > game.level.arena.dangerTop and game.level.arena.pinch == false then --The player is in a pinch!
					if game.level.arena.danger - game.level.arena.dangerTop < 10 then return end --Ignore minimal excess of power.
					game.level.arena.pinch = true
					game.level.arena.pinchValue = game.level.arena.danger - game.level.arena.dangerTop
					game.level.arena.bonus = (game.level.arena.pinchValue * 20) + 200
					game.level.arena.closeGates()
				elseif game.level.arena.danger <= 0 and game.level.arena.pinch == true then --The player cleared the round.
					if game.level.arena.event == 0 then
						game.level.arena.clearRound()
					elseif game.level.arena.lockEvent == false then --Call minibosses or boss next turn.
						game.level.arena.initEvent = true
					else --Round is clear
						game.level.arena.clearRound()
					end
				end
			end,
		}
		local Chat = require "engine.Chat"
		local chat = Chat.new("arena-start", {name="Arena mode"}, game.player, {text = level.arena.printRankings()})
		chat:invoke()
		game.level.arena.addTrap()
	end
}
