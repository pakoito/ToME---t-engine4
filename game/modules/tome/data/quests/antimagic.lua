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

name = "The Curse of Magic"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You met a warrior who invited you join the group called the Ziguranth he belongs to that is dedicated to combat magic."

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal entrances
	local g = mod.class.Grid.new{
		show_tooltip=true, always_remember = true,
		name="Ziguranth training ground",
		display='*', color=colors.WHITE,
		notice = true, image="terrain/town1.png",
		change_level=1, change_zone="town-antimagic",
	}
	g:resolve() g:resolve(nil, true)
	local level = game.level
	local spot = level:pickSpot{type="zone-pop", subtype="antimagic"}
	game.zone:addEntity(level, g, "terrain", spot.x, spot.y)

	game.logPlayer(game.player, "He points in the direction of the thaloren forest near the Daikara.")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		world:gainAchievement("ANTIMAGIC", game.player)
		game.player:learnTalentType("wild-gift/antimagic", true)
		local stair = game.zone:makeEntityByName(game.level, "terrain", "UP_WILDERNESS")
		game.zone:addEntity(game.level, stair, "terrain", game.player.x, game.player.y)
	end
end

-- Start the event, summon the first challenger
start_event = function(self)
	local Chat = require "engine.Chat"
	local chat = Chat.new("antimagic-start", {name="Grim-looking fighter"}, game.player)
	chat:invoke()

	self.wave = 1
	self:add_foe(true, true, 1)
end

next_combat = function(self)
	self.wave = self.wave + 1
	if self.wave < 4 then
		self:add_foe(true, false, 1)
	elseif self.wave < 6 then
		self:add_foe(true, false, 2)
	elseif self.wave < 8 then
		self:add_foe(true, false, 3)
	elseif self.wave < 9 then
		self:add_foe(true, false, 4)
	else
		local Chat = require "engine.Chat"
		local chat = Chat.new("antimagic-end", {name="Grim-looking fighter"}, game.player)
		chat:invoke()
	end
end

add_foe = function(self, next_wave, first, foe_idx)
	local spot = game.level:pickSpot{type="portal"}
	while not spot do spot = game.level:pickSpot{type="portal"} end

	local foes = {
		[1] = {
			{name="skeleton mage"},
			{name="fire imp"},
			{name="greater gwelgoroth"},
		},
		[2] = {
			{name="vampire"},
			{name="umber hulk"},
			{name="snow giant thunderer"},
		},
		[3] = {
			{name="maulotaur"},
			{name="faeros"},
			{name="dread"},
		},
		[4] = {
			{name="orc corruptor"},
		},
	}

	foe = rng.table(foes[foe_idx])
	local m = game.zone:makeEntity(game.level, "actor", foe, nil, true)

	if m then
		local x = spot.x
		local y = spot.y
		if m:canMove(x, y) then
			if next_wave then
				m.on_die = function(a, who)
					game.player:hasQuest("antimagic"):next_combat()
				end
			end
			-- Tone down the corruptor
			if foe_idx == 4 then m.inc_damage.all = -50 end
			m:setTarget(game.player)
			game.zone:addEntity(game.level, m, "actor", x, y)
			if first then game.logSeen(m, "#VIOLET#A foe is summoned to the arena!")
			else game.logSeen(m, "#VIOLET#An other foe is summoned to the arena!") end
		end
	end
end
