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
local Mouse = require "engine.Mouse"
local TooltipsData = require "mod.class.interface.TooltipsData"

module(..., package.seeall, class.inherit(TooltipsData))

function _M:init(x, y, w, h, bgcolor)
	self.display_x = x
	self.display_y = y
	self.w, self.h = w, h
	self.bgcolor = bgcolor
	self.font = core.display.newFont("/data/font/VeraMono.ttf", 14)
	self.mouse = Mouse.new()
	self:resize(x, y, w, h)
end

--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = x, y
	self.mouse.delegate_offset_x = x
	self.mouse.delegate_offset_y = y
	self.w, self.h = w, h
	self.font_h = self.font:lineSkip()
	self.font_w = self.font:size(" ")
	self.bars_x = self.font_w * 9
	self.bars_w = self.w - self.bars_x - 5
	self.surface = core.display.newSurface(w, h)
	self.texture, self.texture_w, self.texture_h = self.surface:glTexture()

	self.portrait = core.display.loadImage("/data/gfx/ui/party-portrait.png")
	local tex_bg = core.display.loadImage("/data/gfx/ui/player-display.png")
	local tex_up = core.display.loadImage("/data/gfx/ui/player-display-top.png")
	local bw, bh = tex_bg:getSize()
	self.bg_surface = core.display.newSurface(w, h)
	local i = 0
	while i < h do
		self.bg_surface:merge(tex_bg, 0, i)
		i = i + bh
	end
	self.bg_surface:merge(tex_up, 0, 0)
end

function _M:mouseTooltip(text, _, _, _, w, h, x, y, click)
	self.mouse:registerZone(x, y, w, h, function(button, mx, my, xrel, yrel, bx, by, event)
		game.tooltip_x, game.tooltip_y = 1, 1; game.tooltip:displayAtMap(nil, nil, game.w, game.h, text)
		if click and event == "button" and button == "left" then
			click()
		end
	end)
end

-- Displays the stats
function _M:display()
	local player = game.player
	if not player or not player.changed then return self.surface end

	self.mouse:reset()
	local s = self.surface

	if self.bg_surface then
		s:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])
		s:merge(self.bg_surface, 0, 0)
	else
		s:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])
	end

	local cur_exp, max_exp = player.exp, player:getExpChart(player.level+1)

	local h = 6
	local x = 2
	self:mouseTooltip(self.TOOLTIP_LEVEL, s:drawColorStringBlended(self.font, "Level: #00ff00#"..player.level, x, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_LEVEL, s:drawColorStringBlended(self.font, ("Exp:  #00ff00#%2d%%"):format(100 * cur_exp / max_exp), x, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_GOLD, s:drawColorStringBlended(self.font, ("Gold: #00ff00#%0.2f"):format(player.money or 0), x, h, 255, 255, 255)) h = h + self.font_h

	h = h + self.font_h

	if game.level and game.level.turn_counter then
		s:drawColorStringBlended(self.font, ("Turns remaining: %d"):format(game.level.turn_counter / 10), x, h, 255, 0, 0) h = h + self.font_h
		h = h + self.font_h
	end

	if player:getAir() < player.max_air then
		self:mouseTooltip(self.TOOLTIP_AIR, s:drawColorStringBlended(self.font, ("Air level: %d/%d"):format(player:getAir(), player.max_air), x, h, 255, 0, 0)) h = h + self.font_h
		h = h + self.font_h
	end

	if player:attr("encumbered") then
		self:mouseTooltip(self.TOOLTIP_ENCUMBERED, s:drawColorStringBlended(self.font, "Encumbered!", x, h, 255, 0, 0)) h = h + self.font_h
		h = h + self.font_h
	end

	self:mouseTooltip(self.TOOLTIP_STRDEXCON, s:drawColorStringBlended(self.font, ("Str/Dex/Con: #00ff00#%3d/%3d/%3d"):format(player:getStr(), player:getDex(), player:getCon()), x, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_MAGWILCUN, s:drawColorStringBlended(self.font, ("Mag/Wil/Cun: #00ff00#%3d/%3d/%3d"):format(player:getMag(), player:getWil(), player:getCun()), x, h, 255, 255, 255)) h = h + self.font_h
	h = h + self.font_h

	s:erase(colors.VERY_DARK_RED.r, colors.VERY_DARK_RED.g, colors.VERY_DARK_RED.b, 255, self.bars_x, h, self.bars_w, self.font_h)
	s:erase(colors.DARK_RED.r, colors.DARK_RED.g, colors.DARK_RED.b, 255, self.bars_x, h, self.bars_w * player.life / player.max_life, self.font_h)
	self:mouseTooltip(self.TOOLTIP_LIFE, s:drawColorStringBlended(self.font, ("#c00000#Life:    #ffffff#%d/%d"):format(player.life, player.max_life), x, h, 255, 255, 255)) h = h + self.font_h

--	if player.alchemy_golem and not player.alchemy_golem.dead then
--		s:erase(colors.VERY_DARK_RED.r, colors.VERY_DARK_RED.g, colors.VERY_DARK_RED.b, 255, self.bars_x, h, self.bars_w, self.font_h)
--		s:erase(colors.DARK_RED.r, colors.DARK_RED.g, colors.DARK_RED.b, 255, self.bars_x, h, self.bars_w * player.alchemy_golem.life / player.alchemy_golem.max_life, self.font_h)
--		self:mouseTooltip(self.TOOLTIP_LIFE, s:drawColorStringBlended(self.font, ("#c00000#Golem:   #ffffff#%d/%d"):format(player.alchemy_golem.life, player.alchemy_golem.max_life), x, h, 255, 255, 255)) h = h + self.font_h
--	end

	if player:knowTalent(player.T_STAMINA_POOL) then
		s:erase(0xff / 6, 0xcc / 6, 0x80 / 6, 255, self.bars_x, h, self.bars_w, self.font_h)
		s:erase(0xff / 3, 0xcc / 3, 0x80 / 3, 255, self.bars_x, h, self.bars_w * player:getStamina() / player.max_stamina, self.font_h)
		self:mouseTooltip(self.TOOLTIP_STAMINA, s:drawColorStringBlended(self.font, ("#ffcc80#Stamina: #ffffff#%d/%d"):format(player:getStamina(), player.max_stamina), x, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_MANA_POOL) then
		s:erase(0x7f / 5, 0xff / 5, 0xd4 / 5, 255, self.bars_x, h, self.bars_w, self.font_h)
		s:erase(0x7f / 2, 0xff / 2, 0xd4 / 2, 255, self.bars_x, h, self.bars_w * player:getMana() / player.max_mana, self.font_h)
		self:mouseTooltip(self.TOOLTIP_MANA, s:drawColorStringBlended(self.font, ("#7fffd4#Mana:    #ffffff#%d/%d"):format(player:getMana(), player.max_mana), x, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_EQUILIBRIUM_POOL) then
		s:erase(0x00 / 5, 0xff / 5, 0x74 / 5, 255, self.bars_x, h, self.bars_w, self.font_h)
		s:erase(0x00 / 2, 0xff / 2, 0x74 / 2, 255, self.bars_x, h, self.bars_w * math.min(1, math.log(1 + player:getEquilibrium() / 100)), self.font_h)
		self:mouseTooltip(self.TOOLTIP_EQUILIBRIUM, s:drawColorStringBlended(self.font, ("#00ff74#Equi:    #ffffff#%d"):format(player:getEquilibrium()), x, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_POSITIVE_POOL) then
		s:erase(colors.GOLD.r / 5, colors.GOLD.g / 5, colors.GOLD.b / 5, 255, self.bars_x, h, self.bars_w, self.font_h)
		s:erase(colors.GOLD.r / 2, colors.GOLD.g / 2, colors.GOLD.b / 2, 255, self.bars_x, h, self.bars_w * player:getPositive() / player.max_positive, self.font_h)
		self:mouseTooltip(self.TOOLTIP_POSITIVE, s:drawColorStringBlended(self.font, ("#7fffd4#Positive:#ffffff#%d/%d"):format(player:getPositive(), player.max_positive), x, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_NEGATIVE_POOL) then
		s:erase(colors.GREY.r / 5, colors.GREY.g / 5, colors.GREY.b / 5, 255, self.bars_x, h, self.bars_w, self.font_h)
		s:erase(colors.GREY.r / 2, colors.GREY.g / 2, colors.GREY.b / 2, 255, self.bars_x, h, self.bars_w * player:getNegative() / player.max_negative, self.font_h)
		self:mouseTooltip(self.TOOLTIP_NEGATIVE, s:drawColorStringBlended(self.font, ("#7fffd4#Negative:#ffffff#%d/%d"):format(player:getNegative(), player.max_negative), x, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_VIM_POOL) then
		s:erase(0x90 / 6, 0x40 / 6, 0x10 / 6, 255, self.bars_x, h, self.bars_w, self.font_h)
		s:erase(0x90 / 3, 0x40 / 3, 0x10 / 3, 255, self.bars_x, h, self.bars_w * player:getVim() / player.max_vim, self.font_h)
		self:mouseTooltip(self.TOOLTIP_VIM, s:drawColorStringBlended(self.font, ("#904010#Vim:     #ffffff#%d/%d"):format(player:getVim(), player.max_vim), x, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_HATE_POOL) then
		s:erase(colors.GREY.r / 5, colors.GREY.g / 5, colors.GREY.b / 5, 255, self.bars_x, h, self.bars_w, self.font_h)
		s:erase(colors.GREY.r / 2, colors.GREY.g / 2, colors.GREY.b / 2, 255, self.bars_x, h, self.bars_w * player:getHate() / 10, self.font_h)
		self:mouseTooltip(self.TOOLTIP_HATE, s:drawColorStringBlended(self.font, ("#F53CBE#Hate:    #ffffff#%.1f/%d"):format(player:getHate(), 10), x, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_PARADOX_POOL) then
		s:erase(176 / 5, 196 / 5, 222 / 5, 255, self.bars_x, h, self.bars_w, self.font_h)
		s:erase(176 / 2, 196 / 2, 222 / 2, 255, self.bars_x, h, self.bars_w * math.min(1, math.log(1 + player:getParadox() / 100)), self.font_h)
		self:mouseTooltip(self.TOOLTIP_PARADOX, s:drawColorStringBlended(self.font, ("#LIGHT_STEEL_BLUE#Paradox:    #ffffff#%d"):format(player:getParadox()), 0, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_PSI_POOL) then
		s:erase(colors.BLUE.r / 5, colors.BLUE.g / 5, colors.BLUE.b / 5, 255, self.bars_x, h, self.bars_w, self.font_h)
		s:erase(colors.BLUE.r / 2, colors.BLUE.g / 2, colors.BLUE.b / 2, 255, self.bars_x, h, self.bars_w * player:getPsi() / player.max_psi, self.font_h)
		self:mouseTooltip(self.TOOLTIP_PSI, s:drawColorStringBlended(self.font, ("#7fffd4#Psi:     #ffffff#%d/%d"):format(player:getPsi(), player.max_psi), x, h, 255, 255, 255)) h = h + self.font_h
	end

	local quiver = player:getInven("QUIVER")
	local ammo = quiver and quiver[1]
	if ammo then
		self:mouseTooltip(self.TOOLTIP_COMBAT_AMMO, s:drawColorStringBlended(self.font, ("#ANTIQUE_WHITE#Ammo:       #ffffff#%d"):format(ammo:getNumber()), 0, h, 255, 255, 255)) h = h + self.font_h
	end

	-- Other party members
	if #game.party.m_list >= 2 then
		local w = 0
		for i = 1, #game.party.m_list do
			local a = game.party.m_list[i]
			if a ~= player then
				local def = game.party.members[a]
				s:merge(self.portrait, w, h)
				s:erase(colors.VERY_DARK_RED.r, colors.VERY_DARK_RED.g, colors.VERY_DARK_RED.b, 255, w+2, h+2, 32, 32)
				local hl = 32 * math.max(0, a.life) / a.max_life
				s:erase(colors.DARK_RED.r, colors.DARK_RED.g, colors.DARK_RED.b, 255, w+2, h+34-hl, 32, hl)

				local es = game.level.map.tilesSurface:get(a.display, a.color_r, a.color_g, a.color_b, a.color_br, a.color_bg, a.color_bb, a.image, a._noalpha and 255, a.ascii_outline)
				s:merge(es, w+2, h+2)

				self:mouseTooltip("#GOLD##{bold}#"..a.name.."\n#WHITE##{normal}#"..def.title, nil, nil, nil, w+36, h+36, w, h, function()
					if def.control == "full" then
						game.party:setPlayer(a)
					end
				end)
				w = w + 36
				if w + 36 > self.w then w = 0 h = h + 36 end
			end
		end
		h = h + 36
	end

	if savefile_pipe.saving then
		h = h + self.font_h
		s:erase(0x68 / 6, 0x72 / 6, 0x00 / 6, 255, self.bars_x, h, self.bars_w, self.font_h)
		s:erase(0x95 / 3, 0xa2 / 3, 0x80 / 3, 255, self.bars_x, h, self.bars_w * savefile_pipe.current_nb / savefile_pipe.total_nb, self.font_h)
		s:drawColorStringBlended(self.font, ("#YELLOW#Saving...: %d%%"):format(100 * savefile_pipe.current_nb / savefile_pipe.total_nb), x, h, 255, 255, 255)
		h = h + self.font_h
	end

	h = h + self.font_h
	for tid, act in pairs(player.sustain_talents) do
		if act then
			local t = player:getTalentFromId(tid)
			local displayName = t.name
			if t.getDisplayName then displayName = t.getDisplayName(player, t, player:isTalentActive(tid)) end
			local desc = "#GOLD##{bold}#"..displayName.."#{normal}##WHITE#\n"..tostring(player:getTalentFullDescription(t))
			self:mouseTooltip(desc, s:drawColorStringBlended(self.font, ("#LIGHT_GREEN#%s"):format(displayName), x, h, 255, 255, 255)) h = h + self.font_h
		end
	end
	for eff_id, p in pairs(player.tmp) do
		local e = player.tempeffect_def[eff_id]
		local dur = p.dur + 1
		local desc = e.long_desc(player, p)
		if e.status == "detrimental" then
			self:mouseTooltip(desc, s:drawColorStringBlended(self.font, ("#LIGHT_RED#%s(%d)"):format(e.desc,dur), x, h, 255, 255, 255)) h = h + self.font_h
		else
			self:mouseTooltip(desc, s:drawColorStringBlended(self.font, ("#LIGHT_GREEN#%s(%d)"):format(e.desc,dur), x, h, 255, 255, 255)) h = h + self.font_h
		end
	end

	s:updateTexture(self.texture)
	return s
end

function _M:toScreen()
	self:display()
	self.texture:toScreenFull(self.display_x, self.display_y, self.w, self.h, self.texture_w, self.texture_h)
end
