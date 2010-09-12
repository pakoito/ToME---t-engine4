-- ToME - Tales of Middle-Earth
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

module(..., package.seeall, class.make)

function _M:init(x, y, w, h, bgcolor)
	self.display_x = x
	self.display_y = y
	self.w, self.h = w, h
	self.bgcolor = bgcolor
	self.font = core.display.newFont("/data/font/VeraMono.ttf", 14)
	self:resize(x, y, w, h)
end

--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = x, y
	self.w, self.h = w, h
	self.font_h = self.font:lineSkip()
	self.font_w = self.font:size(" ")
	self.bars_x = self.font_w * 9
	self.bars_w = self.w - self.bars_x - 5
	self.surface = core.display.newSurface(w, h)
	self.texture, self.texture_w, self.texture_h = self.surface:glTexture()
end

-- Displays the stats
function _M:display()
	local player = game.player
	if not player or not player.changed then return self.surface end

	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])

	local cur_exp, max_exp = player.exp, player:getExpChart(player.level+1)

	local h = 0
	self.surface:drawColorStringBlended(self.font, "Level: #00ff00#"..player.level, 0, h, 255, 255, 255) h = h + self.font_h
	self.surface:drawColorStringBlended(self.font, ("Exp:  #00ff00#%2d%%"):format(100 * cur_exp / max_exp), 0, h, 255, 255, 255) h = h + self.font_h
	self.surface:drawColorStringBlended(self.font, ("Gold: #00ff00#%0.2f"):format(player.money or 0), 0, h, 255, 255, 255) h = h + self.font_h

	h = h + self.font_h

	if game.level and game.level.turn_counter then
		self.surface:drawColorStringBlended(self.font, ("Turns remaining: %d"):format(game.level.turn_counter / 10), 0, h, 255, 0, 0) h = h + self.font_h
		h = h + self.font_h
	end

	if player:getAir() < player.max_air then
		self.surface:drawColorStringBlended(self.font, ("Air level: %d/%d"):format(player:getAir(), player.max_air), 0, h, 255, 0, 0) h = h + self.font_h
		h = h + self.font_h
	end

	self.surface:erase(colors.VERY_DARK_RED.r, colors.VERY_DARK_RED.g, colors.VERY_DARK_RED.b, 255, self.bars_x, h, self.bars_w, self.font_h)
	self.surface:erase(colors.DARK_RED.r, colors.DARK_RED.g, colors.DARK_RED.b, 255, self.bars_x, h, self.bars_w * player.life / player.max_life, self.font_h)
	self.surface:drawColorStringBlended(self.font, ("#c00000#Life:    #ffffff#%d/%d"):format(player.life, player.max_life), 0, h, 255, 255, 255) h = h + self.font_h

	if player.alchemy_golem and not player.alchemy_golem.dead then
		self.surface:erase(colors.VERY_DARK_RED.r, colors.VERY_DARK_RED.g, colors.VERY_DARK_RED.b, 255, self.bars_x, h, self.bars_w, self.font_h)
		self.surface:erase(colors.DARK_RED.r, colors.DARK_RED.g, colors.DARK_RED.b, 255, self.bars_x, h, self.bars_w * player.alchemy_golem.life / player.alchemy_golem.max_life, self.font_h)
		self.surface:drawColorStringBlended(self.font, ("#c00000#Golem:   #ffffff#%d/%d"):format(player.alchemy_golem.life, player.alchemy_golem.max_life), 0, h, 255, 255, 255) h = h + self.font_h
	end

	if player:knowTalent(player.T_STAMINA_POOL) then
		self.surface:erase(0xff / 6, 0xcc / 6, 0x80 / 6, 255, self.bars_x, h, self.bars_w, self.font_h)
		self.surface:erase(0xff / 3, 0xcc / 3, 0x80 / 3, 255, self.bars_x, h, self.bars_w * player:getStamina() / player.max_stamina, self.font_h)
		self.surface:drawColorStringBlended(self.font, ("#ffcc80#Stamina: #ffffff#%d/%d"):format(player:getStamina(), player.max_stamina), 0, h, 255, 255, 255) h = h + self.font_h
	end
	if player:knowTalent(player.T_MANA_POOL) then
		self.surface:erase(0x7f / 5, 0xff / 5, 0xd4 / 5, 255, self.bars_x, h, self.bars_w, self.font_h)
		self.surface:erase(0x7f / 2, 0xff / 2, 0xd4 / 2, 255, self.bars_x, h, self.bars_w * player:getMana() / player.max_mana, self.font_h)
		self.surface:drawColorStringBlended(self.font, ("#7fffd4#Mana:    #ffffff#%d/%d"):format(player:getMana(), player.max_mana), 0, h, 255, 255, 255) h = h + self.font_h
	end
	if player:knowTalent(player.T_EQUILIBRIUM_POOL) then
		self.surface:erase(0x00 / 5, 0xff / 5, 0x74 / 5, 255, self.bars_x, h, self.bars_w, self.font_h)
		self.surface:erase(0x00 / 2, 0xff / 2, 0x74 / 2, 255, self.bars_x, h, self.bars_w * math.min(1, math.log(1 + player:getEquilibrium() / 100)), self.font_h)
		self.surface:drawColorStringBlended(self.font, ("#00ff74#Equi:    #ffffff#%d"):format(player:getEquilibrium()), 0, h, 255, 255, 255) h = h + self.font_h
	end
	if player:knowTalent(player.T_POSITIVE_POOL) then
		self.surface:erase(colors.GOLD.r / 5, colors.GOLD.g / 5, colors.GOLD.b / 5, 255, self.bars_x, h, self.bars_w, self.font_h)
		self.surface:erase(colors.GOLD.r / 2, colors.GOLD.g / 2, colors.GOLD.b / 2, 255, self.bars_x, h, self.bars_w * player:getPositive() / player.max_positive, self.font_h)
		self.surface:drawColorStringBlended(self.font, ("#7fffd4#Positive:#ffffff#%d/%d"):format(player:getPositive(), player.max_positive), 0, h, 255, 255, 255) h = h + self.font_h
	end
	if player:knowTalent(player.T_NEGATIVE_POOL) then
		self.surface:erase(colors.GREY.r / 5, colors.GREY.g / 5, colors.GREY.b / 5, 255, self.bars_x, h, self.bars_w, self.font_h)
		self.surface:erase(colors.GREY.r / 2, colors.GREY.g / 2, colors.GREY.b / 2, 255, self.bars_x, h, self.bars_w * player:getNegative() / player.max_negative, self.font_h)
		self.surface:drawColorStringBlended(self.font, ("#7fffd4#Negative:#ffffff#%d/%d"):format(player:getNegative(), player.max_negative), 0, h, 255, 255, 255) h = h + self.font_h
	end
	if player:knowTalent(player.T_VIM_POOL) then
		self.surface:erase(0x90 / 6, 0x40 / 6, 0x10 / 6, 255, self.bars_x, h, self.bars_w, self.font_h)
		self.surface:erase(0x90 / 3, 0x40 / 3, 0x10 / 3, 255, self.bars_x, h, self.bars_w * player:getVim() / player.max_vim, self.font_h)
		self.surface:drawColorStringBlended(self.font, ("#904010#Vim:     #ffffff#%d/%d"):format(player:getVim(), player.max_vim), 0, h, 255, 255, 255) h = h + self.font_h
	end
	if player:knowTalent(player.T_HATE_POOL) then
		self.surface:erase(colors.GREY.r / 5, colors.GREY.g / 5, colors.GREY.b / 5, 255, self.bars_x, h, self.bars_w, self.font_h)
		self.surface:erase(colors.GREY.r / 2, colors.GREY.g / 2, colors.GREY.b / 2, 255, self.bars_x, h, self.bars_w * player:getHate() / 10, self.font_h)
		self.surface:drawColorStringBlended(self.font, ("#F53CBE#Hate:    #ffffff#%.1f/%d"):format(player:getHate(), 10), 0, h, 255, 255, 255) h = h + self.font_h
	end

	if savefile_pipe.saving then h = h + self.font_h self.surface:drawColorStringBlended(self.font, "#YELLOW#Saving...", 0, h, 255, 255, 255) h = h + self.font_h end

	h = h + self.font_h
	for tid, act in pairs(player.sustain_talents) do
		if act then self.surface:drawColorStringBlended(self.font, ("#LIGHT_GREEN#%s"):format(player:getTalentFromId(tid).name), 0, h, 255, 255, 255) h = h + self.font_h end
	end
	for eff_id, p in pairs(player.tmp) do
		local e = player.tempeffect_def[eff_id]
		if e.status == "detrimental" then
			self.surface:drawColorStringBlended(self.font, ("#LIGHT_RED#%s"):format(e.desc), 0, h, 255, 255, 255) h = h + self.font_h
		else
			self.surface:drawColorStringBlended(self.font, ("#LIGHT_GREEN#%s"):format(e.desc), 0, h, 255, 255, 255) h = h + self.font_h
		end
	end

	self.surface:updateTexture(self.texture)
	return self.surface
end

function _M:toScreen()
	self:display()
	self.texture:toScreenFull(self.display_x, self.display_y, self.w, self.h, self.texture_w, self.texture_h)
end
