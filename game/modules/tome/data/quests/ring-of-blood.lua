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

name = "Till the Blood Runs Clear"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have found a slavers' compound and entered it."
	if self:isCompleted("won-fight") then
		desc[#desc+1] = ""
		desc[#desc+1] = "You decided to join the slavers and take part in their game. You won the ring of blood!"
	end
	if self:isCompleted("killall") then
		desc[#desc+1] = ""
		desc[#desc+1] = "You decided you cannot let slavers continue their dirty work and destroyed them!"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		if self:isCompleted("won-fight") then
			game:setAllowedBuild("warrior_brawler", true)
		elseif self:isCompleted("killall") then
			world:gainAchievement("RING_BLOOD_KILL", who)
		end
	end
end

find_master = function(self)
	for uid, e in pairs(game.level.entities) do
		if e.define_as and e.define_as == "RING_MASTER" then return e end
	end
	return nil
end

start_game = function(self)
	if not self:find_master() then
		game.log("The orb seems to fizzle without the Blood Master.")
		return
	end

	local p = game.party:findMember{main=true}

	local slave = game.zone:makeEntityByName(game.level, "actor", "PLAYER_SLAVE")
	local spot = game.level:pickSpot{type="arena", subtype="player"}
	game.zone:addEntity(game.level, slave, "actor", spot.x, spot.y)

	game.party:addMember(slave, {
		control="full", type="slave", title=p.name.."'s slave",
		orders = {target=true, leash=true, anchor=true, talents=true, behavior=true},
	})
	game.party:setPlayer(slave)
	game.player:hotkeyAutoTalents()
	game.party.members[p].control = "no"
	p.slaver_old_ai = p.ai
	p.ai = "none"

	slave.on_die = function(self)
		game.player:hasQuest("ring-of-blood"):stop_game(false)
		game.log("#CRIMSON#The crowd yells: 'LOSER!'")
	end

	game.log("#LIGHT_GREEN#As you touch the orb your will fills the slave's body. You take full control of his actions!")
	self.inside_ring = 0
	self.inside_kills = 0
end

on_turn = function(self)
	if not self.inside_ring then return end

	if self.inside_ring > 0 and not rng.percent(5) then return end
	if self.inside_ring > 3 then return end
	if self.inside_kills >= 10 then
		if self.inside_ring <= 0 then
			self:stop_game(true)
		end
		return
	end

	local oldlev = game.zone.base_level
	game.zone.base_level = 10
	local filter = {type=rng.table{"animal", "humanoid"}, max_ood=3, special_rarity="slaver_rarity"}
	local foe = game.zone:makeEntity(game.level, "actor", filter, nil, true)
	local spot = game.level:pickSpot{type="arena", subtype="npc"}
	local x, y = util.findFreeGrid(spot.x, spot.y, 20, true, {[engine.Map.ACTOR]=true})
	if not x or not foe then return end
	game.zone:addEntity(game.level, foe, "actor", x, y)
	game.log("#CRIMSON#A new foe appears in the ring of blood!")
	game.zone.base_level = oldlev

	foe.is_ring_foe = true
	foe.faction = "neutral"
	foe.arena_old_on_die = foe.on_die
	foe.no_drops = true
	foe.on_die = function(self, ...)
		local q = game.player:hasQuest("ring-of-blood")
		q.inside_kills = q.inside_kills + 1
		q.inside_ring = q.inside_ring - 1
		if self.arena_old_on_die then self:arena_old_on_die(...) end
	end
	foe:checkAngered(game.player, true, -200)

	self.inside_ring = self.inside_ring + 1
end

stop_game = function(self, win)
	local p = game.party:findMember{main=true}
	local slave = game.player
	p.ai = p.slaver_old_ai
	game.party.members[p].control = "full"
	game.party:setPlayer(p)
	game.party:removeMember(slave)
	slave:disappear()

	self.inside_ring = nil
	local todel = {}
	for uid, e in pairs(game.level.entities) do if e.is_ring_foe then todel[#todel+1] = e end end
	for _, e in ipairs(todel) do e:disappear() end

	if win then
		p:setQuestStatus(self.id, engine.Quest.COMPLETED, "won-fight")
		game.log("#CRIMSON#The crowd yells: 'BLOOOODDD!'")
		local chat = require("engine.Chat").new("ring-of-blood-win", self:find_master(), p)
		chat:invoke()
	end
end

reward = function(self, who)
	local o = game.zone:makeEntityByName(game.level, "object", "RING_OF_BLOOD")
	if not o then return end
	o:identify(true)
	game.zone:addEntity(game.level, o, "object")
	who:addObject(who:getInven("INVEN"), o)
	who:setQuestStatus(self.id, engine.Quest.COMPLETED)
	game.logPlayer(who, "#LIGHT_BLUE#The Blood Master hands you the %s.", o:getName{do_color=true})
end
