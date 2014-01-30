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

require "engine.class"
local Mouse = require "engine.Mouse"

module(..., package.seeall, class.make)

function _M:init()
	self.font = core.display.newFont("/data/font/FSEX300.ttf", 16)
	self.font_h = self.font:lineSkip()

	self.mouse = Mouse.new()

	local gw, gh = core.display.size()
	self:resize(0, gh - self.font_h, gw, self.font_h)
end

--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = x, y
	self.mouse.delegate_offset_x = x
	self.mouse.delegate_offset_y = y
	self.w, self.h = w, h
	self.font_w = self.font:size(" ")
	self.bars_x = self.font_w * 9
	self.bars_w = self.w - self.bars_x - 5
	self.surface = core.display.newSurface(w, h)
	self.texture, self.texture_w, self.texture_h = self.surface:glTexture()

	self.items = {}
end

function _M:mouseTooltip(text, w, h, x, y, click)
--	self.mouse:registerZone(x, y, w, h, function(button, mx, my, xrel, yrel, bx, by, event)
--		game.tooltip_x, game.tooltip_y = 1, 1; game.tooltip:displayAtMap(nil, nil, game.w, game.h, text)
--		if click and event == "button" and button == "left" then
--			click()
--		end
--	end)
	return w, h
end

function _M:makeTexture(text, x, y, r, g, b, max_w)
	local s = self.surface
	s:drawColorStringBlended(self.font, text, x, y, r, g, b, true, max_w)
	return self.font:size(text)
end

-- Displays the stats
function _M:display()
	local player = game.player
	if not player or not player.changed or not game.level then return end

	self.mouse:reset()
	self.items = {}

	local s = self.surface
	s:erase(0, 0, 0, 0)

	local w = 0

	w = w + self:makeTexture(("%-20s"):format(player.name), w, 0, 255, 255, 255)

	w = w + self:mouseTooltip("#GOLD##{bold}#Lurk Power\n#WHITE##{normal}#Your lurking power. You can gain lurk power by standing still in the shadows.",
		self:makeTexture(("LP: #GREY#%d/%d   "):format(player:getLurk(), player.max_lurk), w, 0, 255, 255, 255))

	w = w + self:mouseTooltip("#GOLD##{bold}#Shadow Power\n#WHITE##{normal}#Your shadow power. You can gain shadow power by eating adventurers.",
		self:makeTexture(("SP: #GREY#%d/%d   "):format(player:getShadow(), player.max_shadow), w, 0, 255, 255, 255))

	w = w + self:mouseTooltip("#GOLD##{bold}#Meals\n#WHITE##{normal}#The total number of adventurers you ate.",
		self:makeTexture(("Meals: %-4d  "):format(player.kills + player.lurkkills), w, 0, 255, 255, 255))

	w = w + self:mouseTooltip("#GOLD##{bold}#Turns\n#WHITE##{normal}#The total number of turns elapsed since starting.",
		self:makeTexture(("Turns: %-6d  "):format(game.turn / 10), w, 0, 255, 255, 255))

	w = w + self:mouseTooltip("#GOLD##{bold}#Dungeon level\n#WHITE##{normal}#The current dungeon level. Reach level 1 to win!",
		self:makeTexture(("Level: %d"):format(game.level.level), w, 0, 255, 255, 255))

	s:updateTexture(self.texture)
end

function _M:toScreen()
	self:display()
	self.texture:toScreenFull(self.display_x, self.display_y, self.w, self.h, self.texture_w, self.texture_h)
end
