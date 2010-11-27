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
	desc[#desc+1] = "You met a warrior who invited you join the group called the Ziguranth, dedicated to opposing magic."
	if who:hasQuest("antimagic"):ten_levels_ok(who) then
		desc[#desc+1] = "#SLATE#* You must report back to the warrior in Zigur.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must not use spells, runes, or magical devices.#WHITE#"
		desc[#desc+1] = ("#SLATE#* You have gained %d of 10 levels.#WHITE#"):format(who.level - self.start_level)
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	self.start_level = who.level
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		world:gainAchievement("ANTIMAGIC", game.player)
		game.player:learnTalentType("wild-gift/antimagic", true)
	end
end

ten_levels_ok = function(self, who)
	if not self:isEnded() then
		if who.level >= self.start_level + 10 then return true end
	end
end

-- Start the event, summon the first challenger
start_event = function(self)
	local spot = game.level:pickSpot{type="quest", subtype="arena"}
	game.player:move(spot.x, spot.y, true)

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
		local spot = game.level:pickSpot{type="quest", subtype="outside-arena"}
		game.player:move(spot.x, spot.y, true)

		if not self:isEnded() then
			local Chat = require "engine.Chat"
			local chat = Chat.new("antimagic-end", {name="Grim-looking fighter"}, game.player)
			chat:invoke()
		end
	end
end

add_foe = function(self, next_wave, first, foe_idx)
	local spot = game.level:pickSpot{type="portal", subtype="portal"}
	while not spot do spot = game.level:pickSpot{type="portal", subtype="portal"} end

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
			if foe_idx == 4 then m.inc_damage.all = -30 end
			m:setTarget(game.player)
			game.zone:addEntity(game.level, m, "actor", x, y)
			if first then game.logSeen(m, "#VIOLET#A foe is summoned to the arena!")
			else game.logSeen(m, "#VIOLET#Another foe is summoned to the arena!") end
		end
	end
end
