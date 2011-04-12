-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

function _M:init(x, y, w, h, bgcolor, font, size)
	self.display_x = x
	self.display_y = y
	self.w, self.h = w, h
	self.bgcolor = bgcolor
	self.font = core.display.newFont(font, size)
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
	self.surface_line = core.display.newSurface(w, self.font_h)
	self.surface_portrait = core.display.newSurface(40, 40)
	self.texture, self.texture_w, self.texture_h = self.surface:glTexture()

	self.top = {core.display.loadImage("/data/gfx/ui/party_end.png")} self.top.tex = {self.top[1]:glTexture()}
	self.party = {core.display.loadImage("/data/gfx/ui/party_top.png")} self.party.tex = {self.party[1]:glTexture()}
	self.bg = {core.display.loadImage("/data/gfx/ui/player-display.png")} self.bg.tex = {self.bg[1]:glTexture()}

	self.portrait = {core.display.loadImage("/data/gfx/ui/party-portrait.png"):glTexture()}
	self.portrait_unsel = {core.display.loadImage("/data/gfx/ui/party-portrait-unselect.png"):glTexture()}

	self.items = {}
end

function _M:mouseTooltip(text, w, h, x, y, click)
	self.mouse:registerZone(x, y, w, h, function(button, mx, my, xrel, yrel, bx, by, event)
		game.tooltip_x, game.tooltip_y = 1, 1; game.tooltip:displayAtMap(nil, nil, game.w, game.h, text)
		if click and event == "button" and button == "left" then
			click()
		end
	end)
end

function _M:makeTexture(text, x, y, r, g, b, max_w)
	local s = self.surface_line
	s:erase(0, 0, 0, 0)
	s:drawColorStringBlended(self.font, text, 0, 0, r, g, b, true, max_w)

	local item = { s:glTexture() }
	item.x = x
	item.y = y
	item.w = self.w
	item.h = self.font_h
	self.items[#self.items+1] = item

	return item.w, item.h, item.x, item.y
end

function _M:makeTextureBar(text, nfmt, val, max, x, y, r, g, b, bar_col, bar_bgcol)
	local s = self.surface_line
	s:erase(0, 0, 0, 0)
	s:erase(bar_bgcol.r, bar_bgcol.g, bar_bgcol.b, 255, self.bars_x, h, self.bars_w, self.font_h)
	s:erase(bar_col.r, bar_col.g, bar_col.b, 255, self.bars_x, h, self.bars_w * val / max, self.font_h)

	s:drawColorStringBlended(self.font, text, 0, 0, r, g, b, true)
	s:drawColorStringBlended(self.font, (nfmt or "%d/%d"):format(val, max), self.bars_x, 0, r, g, b)

	local item = { s:glTexture() }
	item.x = x
	item.y = y
	item.w = self.w
	item.h = self.font_h
	self.items[#self.items+1] = item

	return item.w, item.h, item.x, item.y
end

function _M:makePortrait(a, current, x, y)
	local s = self.surface_portrait
	local def = game.party.members[a]
	s:erase(0, 0, 0, 255, 6, 6, 32, 32)
	local hl = 32 * math.max(0, a.life) / a.max_life
	s:erase(colors.RED.r * 0.7, colors.RED.g * 0.7, colors.RED.b * 0.7, 255, 6, 32+6-hl, 32, hl)

	self:mouseTooltip("#GOLD##{bold}#"..a.name.."\n#WHITE##{normal}#Life: "..math.floor(100 * a.life / a.max_life).."%\nLevel: "..a.level.."\n"..def.title, 40, 40, x, y, function()
		if def.control == "full" then
			game.party:select(a)
		end
	end)

	local item = { s:glTexture() }
	item.x = x
	item.y = y
	item.w = 40
	item.h = 40
	self.items[#self.items+1] = item

	local item = function(dx, dy)
		a:toScreen(nil, dx+x+4, dy+y+1, 32, 32)
	end
	self.items[#self.items+1] = item

	local p = current and self.portrait or self.portrait_unsel

	local item = { p[1], p[2], p[3], }
	item.x = x
	item.y = y
	item.w = 40
	item.h = 40
	self.items[#self.items+1] = item
end

-- Displays the stats
function _M:display()
	local player = game.player
	if not player or not player.changed or not game.level then return end

	self.mouse:reset()
	self.items = {}

	local cur_exp, max_exp = player.exp, player:getExpChart(player.level+1)
	local h = 6
	local x = 2

	-- Party members
	if #game.party.m_list >= 2 and game.level then
		self.items[#self.items+1] = {unpack(self.party.tex)}
		self.items[#self.items].w = self.party[2]
		self.items[#self.items].h = self.party[3]
		self.items[#self.items].x = 0
		self.items[#self.items].y = h
		h = h + self.party[3] + 3

		local nb = math.floor(self.w / 42)
		local off = (self.w - nb * 42) /2

		local w = (1 + nb > #game.party.m_list) and ((self.w - (#game.party.m_list - 0.5) * 42) / 2) or off
		h = h  + 42
		for i = 1, #game.party.m_list do
			local a = game.party.m_list[i]
			self:makePortrait(a, a == player, w, h - 42)
			w = w + 42
			if w + 42 > self.w and i < #game.party.m_list then
				w = (i + nb > #game.party.m_list) and ((self.w - (#game.party.m_list - i - 0.5) * 42) / 2) or off
				h = h + 42
			end
		end
		h = h + 2
	end

	self.items[#self.items+1] = {unpack(self.top.tex)}
	self.items[#self.items].w = self.top[2]
	self.items[#self.items].h = self.top[3]
	self.items[#self.items].x = 0
	self.items[#self.items].y = h
	h = h + self.top[3] + 5

	-- Player
	self.font:setStyle("bold")
	self:makeTexture(("%s#{normal}#"):format(player.name), 0, h, colors.GOLD.r, colors.GOLD.g, colors.GOLD.b, self.w) h = h + self.font_h
	self.font:setStyle("normal")

	self:mouseTooltip(self.TOOLTIP_LEVEL, self:makeTexture(("Level / Exp: #00ff00#%s / %2d%%"):format(player.level, 100 * cur_exp / max_exp), x, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_GOLD, self:makeTexture(("Gold: #00ff00#%0.2f"):format(player.money or 0), x, h, 255, 255, 255)) h = h + self.font_h

	if game.level and game.level.turn_counter then
		self:makeTexture(("Turns remaining: %d"):format(game.level.turn_counter / 10), x, h, 255, 0, 0) h = h + self.font_h
		h = h + self.font_h
	end

	if player:getAir() < player.max_air then
		self:mouseTooltip(self.TOOLTIP_AIR, self:makeTexture(("Air level: %d/%d"):format(player:getAir(), player.max_air), x, h, 255, 0, 0)) h = h + self.font_h
		h = h + self.font_h
	end

	if player:attr("encumbered") then
		self:mouseTooltip(self.TOOLTIP_ENCUMBERED, self:makeTexture("Encumbered!", x, h, 255, 0, 0)) h = h + self.font_h
		h = h + self.font_h
	end

	self:mouseTooltip(self.TOOLTIP_STRDEXCON, self:makeTexture(("Str/Dex/Con: #00ff00#%3d/%3d/%3d"):format(player:getStr(), player:getDex(), player:getCon()), x, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_MAGWILCUN, self:makeTexture(("Mag/Wil/Cun: #00ff00#%3d/%3d/%3d"):format(player:getMag(), player:getWil(), player:getCun()), x, h, 255, 255, 255)) h = h + self.font_h
	h = h + self.font_h

	self:mouseTooltip(self.TOOLTIP_LIFE, self:makeTextureBar("#c00000#Life:", nil, player.life, player.max_life, x, h, 255, 255, 255, colors.DARK_RED, colors.VERY_DARK_RED)) h = h + self.font_h

	if player:knowTalent(player.T_STAMINA_POOL) then
		self:mouseTooltip(self.TOOLTIP_STAMINA, self:makeTextureBar("#ffcc80#Stamina:", nil, player:getStamina(), player.max_stamina, x, h, 255, 255, 255, {r=0xff / 3, g=0xcc / 3, b=0x80 / 3}, {r=0xff / 6, g=0xcc / 6, b=0x80 / 6})) h = h + self.font_h
	end
	if player:knowTalent(player.T_MANA_POOL) then
		self:mouseTooltip(self.TOOLTIP_MANA, self:makeTextureBar("#7fffd4#Mana:", nil, player:getMana(), player.max_mana, x, h, 255, 255, 255,
			{r=0x7f / 2, g=0xff / 2, b=0xd4 / 2},
			{r=0x7f / 5, g=0xff / 5, b=0xd4 / 5}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_EQUILIBRIUM_POOL) then
		self:mouseTooltip(self.TOOLTIP_EQUILIBRIUM, self:makeTextureBar("#00ff74#Equi:", ("%d"):format(player:getEquilibrium()), math.min(1, math.log(1 + player:getEquilibrium() / 100)), 100, x, h, 255, 255, 255,
			{r=0x00 / 2, g=0xff / 2, b=0x74 / 2},
			{r=0x00 / 5, g=0xff / 5, b=0x74 / 5}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_POSITIVE_POOL) then
		self:mouseTooltip(self.TOOLTIP_POSITIVE, self:makeTextureBar("#7fffd4#Positive:", nil, player:getPositive(), player.max_positive, x, h, 255, 255, 255,
			{r=colors.GOLD.r / 2, g=colors.GOLD.g / 2, b=colors.GOLD.b / 2},
			{r=colors.GOLD.r / 5, g=colors.GOLD.g / 5, b=colors.GOLD.b / 5}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_NEGATIVE_POOL) then
		self:mouseTooltip(self.TOOLTIP_NEGATIVE, self:makeTextureBar("#7fffd4#Negative:", nil, player:getNegative(), player.max_negative, x, h, 255, 255, 255,
			{r=colors.GREY.r / 2, g=colors.GREY.g / 2, b=colors.GREY.b / 2},
			{r=colors.GREY.r / 5, g=colors.GREY.g / 5, b=colors.GREY.b / 5}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_VIM_POOL) then
		self:mouseTooltip(self.TOOLTIP_VIM, self:makeTextureBar("#904010#Vim:", nil, player:getVim(), player.max_vim, x, h, 255, 255, 255,
			{r=0x90 / 3, g=0x40 / 3, b=0x10 / 3},
			{r=0x90 / 6, g=0x40 / 6, b=0x10 / 6}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_HATE_POOL) then
		self:mouseTooltip(self.TOOLTIP_HATE, self:makeTextureBar("#F53CBE#Hate:", "%0.1f/%d", player:getHate(), 10, x, h, 255, 255, 255,
			{r=colors.GREY.r / 2, g=colors.GREY.g / 2, b=colors.GREY.b / 2},
			{r=colors.GREY.r / 5, g=colors.GREY.g / 5, b=colors.GREY.b / 5}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_PARADOX_POOL) then
		self:mouseTooltip(self.TOOLTIP_PARADOX, self:makeTextureBar("#LIGHT_STEEL_BLUE#Paradox:", ("       %d"):format(player:getParadox()), math.min(1, math.log(1 + player:getParadox() / 100)), 100, x, h, 255, 255, 255,
			{r=176 / 2, g=196 / 2, b=222 / 2},
			{r=176 / 2, g=196 / 2, b=222 / 2}
		)) h = h + self.font_h
	end
	if player:knowTalent(player.T_PSI_POOL) then
		self:mouseTooltip(self.TOOLTIP_PSI, self:makeTextureBar("#7fffd4#Psi:", nil, player:getPsi(), player.max_psi, x, h, 255, 255, 255,
			{r=colors.BLUE.r / 2, g=colors.BLUE.g / 2, b=colors.BLUE.b / 2},
			{r=colors.BLUE.r / 5, g=colors.BLUE.g / 5, b=colors.BLUE.b / 5}
		)) h = h + self.font_h
	end

	local quiver = player:getInven("QUIVER")
	local ammo = quiver and quiver[1]
	if ammo then
		self:mouseTooltip(self.TOOLTIP_COMBAT_AMMO, self:makeTexture(("#ANTIQUE_WHITE#Ammo:       #ffffff#%d"):format(ammo:getNumber()), 0, h, 255, 255, 255)) h = h + self.font_h
	end

	if savefile_pipe.saving then
		h = h + self.font_h
		self:makeTextureBar("Saving:", "%d%%", 100 * savefile_pipe.current_nb / savefile_pipe.total_nb, 100, x, h, colors.YELLOW.r, colors.YELLOW.g, colors.YELLOW.b,
			{r=0x95 / 3, g=0xa2 / 3,b= 0x80 / 3},
			{r=0x68 / 6, g=0x72 / 6, b=0x00 / 6}
		)

		h = h + self.font_h
	end

	h = h + self.font_h
	for tid, act in pairs(player.sustain_talents) do
		if act then
			local t = player:getTalentFromId(tid)
			local displayName = t.name
			if t.getDisplayName then displayName = t.getDisplayName(player, t, player:isTalentActive(tid)) end
			local desc = "#GOLD##{bold}#"..displayName.."#{normal}##WHITE#\n"..tostring(player:getTalentFullDescription(t))
			self:mouseTooltip(desc, self:makeTexture(("#LIGHT_GREEN#%s"):format(displayName), x, h, 255, 255, 255)) h = h + self.font_h
		end
	end
	for eff_id, p in pairs(player.tmp) do
		local e = player.tempeffect_def[eff_id]
		local dur = p.dur + 1
		local name = e.desc
		if e.display_desc then name = e.display_desc(self, p) end
		local desc = e.long_desc(player, p)
		if e.status == "detrimental" then
			self:mouseTooltip(desc, self:makeTexture(("#LIGHT_RED#%s(%d)"):format(name, dur), x, h, 255, 255, 255)) h = h + self.font_h
		else
			self:mouseTooltip(desc, self:makeTexture(("#LIGHT_GREEN#%s(%d)"):format(name, dur), x, h, 255, 255, 255)) h = h + self.font_h
		end
	end
	if game.level and game.level.arena then
		h = h + self.font_h
		local arena = game.level.arena
		if arena.score > world.arena.scores[1].score then
			self:makeTexture(("Score(TOP): %d"):format(arena.score), x, h, 255, 255, 100) h = h + self.font_h
		else
			self:makeTexture(("Score: %d"):format(arena.score), x, h, 255, 255, 255) h = h + self.font_h
		end
		if arena.currentWave > world.arena.bestWave then
			self:makeTexture(("Wave(TOP) %d"):format(arena.currentWave), x, h, 255, 255, 100)
		elseif arena.currentWave > world.arena.lastScore.wave then
			self:makeTexture(("Wave %d"):format(arena.currentWave), x, h, 100, 100, 255)
		else
			self:makeTexture(("Wave %d"):format(arena.currentWave), x, h, 255, 255, 255)
		end
		if arena.event > 0 then
			if arena.event == 1 then
				self:makeTexture((" [MiniBoss]"), x + (self.font_w * 13), h, 255, 255, 100)
			elseif arena.event == 2 then
				self:makeTexture((" [Boss]"), x + (self.font_w * 13), h, 255, 0, 255)
			elseif arena.event == 3 then
				self:makeTexture((" [Final]"), x + (self.font_w * 13), h, 255, 10, 15)
			end
		end
		h = h + self.font_h
		if arena.pinch == true then
			self:makeTexture(("Bonus: %d (x%.1f)"):format(arena.bonus, arena.bonusMultiplier), x, h, 255, 50, 50) h = h + self.font_h
		else
			self:makeTexture(("Bonus: %d (x%.1f)"):format(arena.bonus, arena.bonusMultiplier), x, h, 255, 255, 255) h = h + self.font_h
		end
		if arena.display then
			h = h + self.font_h
			self:makeTexture(arena.display[1], x, h, 255, 0, 255) h = h + self.font_h
			self:makeTexture(" VS", x, h, 255, 0, 255) h = h + self.font_h
			self:makeTexture(arena.display[2], x, h, 255, 0, 255) h = h + self.font_h
		else
			self:makeTexture("Rank: "..arena.printRank(arena.rank, arena.ranks), x, h, 255, 255, 255) h = h + self.font_h
		end
		h = h + self.font_h
	end

end

function _M:toScreen()
	self:display()

	self.bg.tex[1]:toScreen(self.display_x, self.display_y, self.w, self.h)
	for i = 1, #self.items do
		local item = self.items[i]
		if type(item) == "table" then
			item[1]:toScreenFull(self.display_x + item.x, self.display_y + item.y, item.w, item.h, item[2], item[3])
		else
			item(self.display_x, self.display_y)
		end
	end
end
