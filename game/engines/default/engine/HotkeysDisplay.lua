-- TE4 - T-Engine 4
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

function _M:init(actor, x, y, w, h, bgcolor)
	self.actor = actor
	if type(bgcolor) ~= "string" then
		self.bgcolor = bgcolor or {0,0,0}
	else
		self.bgcolor = {0,0,0}
		self.bg_image = bgcolor
	end
	self.font = core.display.newFont("/data/font/VeraMono.ttf", 10)
	self.font_h = self.font:lineSkip()
	self.clics = {}
	self:resize(x, y, w, h)
end

--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = math.floor(x), math.floor(y)
	self.w, self.h = math.floor(w), math.floor(h)
	self.surface = core.display.newSurface(w, h)
	self.texture, self.texture_w, self.texture_h = self.surface:glTexture()
	if self.actor then self.actor.changed = true end

	local cw, ch = self.font:size(" ")
	self.font_w = cw
	self.max_char_w = math.min(127, math.floor(w / self.font_w))

	if self.bg_image then
		local fill = core.display.loadImage(self.bg_image)
		local fw, fh = fill:getSize()
		self.bg_surface = core.display.newSurface(w, h)
		self.bg_surface:erase(0, 0, 0)
		for i = 0, w, fw do for j = 0, h, fh do
			self.bg_surface:merge(fill, i, j)
		end end
	end
end

local page_to_hotkey = {"", "SECOND_", "THIRD_"}

-- Displays the hotkeys, keybinds & cooldowns
function _M:display()
	local a = self.actor
	if not a or not a.changed then return self.surface end

	local hks = {}
	for i = 1, 12 do
		local j = i + (12 * (a.hotkey_page - 1))
		local ks = game.key:formatKeyString(game.key:findBoundKeys("HOTKEY_"..page_to_hotkey[a.hotkey_page]..i))
		if a.hotkey[j] and a.hotkey[j][1] == "talent" then
			hks[#hks+1] = {a.hotkey[j][2], j, "talent", ks}
		elseif a.hotkey[j] and a.hotkey[j][1] == "inventory" then
			hks[#hks+1] = {a.hotkey[j][2], j, "inventory", ks}
		end
	end

	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])
	if self.bg_surface then self.surface:merge(self.bg_surface, 0, 0) end

	local x = 0
	local y = 0
	self.clics = {}

	for ii, ts in ipairs(hks) do
		local s
		local i = ts[2]
		local txt, color = "", {0,255,0}
		if ts[3] == "talent" then
			local tid = ts[1]
			local t = a:getTalentFromId(tid)
			local can_use = a:preUseTalent(t, true, true)
			if not can_use then
				txt = t.name
				color = {190,190,190}
			elseif a:isTalentCoolingDown(t) then
				txt = ("%s (%d)"):format(t.name, a:isTalentCoolingDown(t))
				color = {255,0,0}
			elseif a:isTalentActive(t.id) then
				txt = t.name
				color = {255,255,0}
			else
				txt = t.name
				color = {0,255,0}
			end
		elseif ts[3] == "inventory" then
			local o = a:findInAllInventories(ts[1], {no_add_name=true, force_id=true, no_count=true})
			local cnt = 0
			if o then cnt = o:getNumber() end
			txt = ("%s (%d)"):format(o and o:getName{no_count=true} or ts[1], cnt)
			if cnt == 0 then
				color = {128,128,128}
			end
		end

		txt = ("%2d) %-"..(self.max_char_w-4-24).."s Key: %s"):format(i, txt, ts[4])
		local w, h = self.font:size(txt)
		if self.cur_sel and self.cur_sel == i then self.surface:erase(0, 50, 120, nil, x, y, w+4, h+4) end
		self.surface:drawStringBlended(self.font, txt, x+2, y+2, color[1], color[2], color[3])
		self.clics[i] = {x,y,w+4,h+4}

		if y + self.font_h * 2 > self.h then
			x = x + self.w / 2
			y = 0
		else
			y = y + self.font_h
		end
	end

	self.surface:updateTexture(self.texture)
	return self.surface
end

function _M:toScreen()
	self:display()
	self.texture:toScreenFull(self.display_x, self.display_y, self.w, self.h, self.texture_w, self.texture_h)
end

--- Call when a mouse event arrives in this zone
-- This is optional, only if you need mouse support
function _M:onMouse(button, mx, my, click, on_over)
	local a = self.actor
	mx, my = mx - self.display_x, my - self.display_y
	for i, zone in pairs(self.clics) do
		if mx >= zone[1] and mx < zone[1] + zone[3] and my >= zone[2] and my < zone[2] + zone[4] then
			if button == "left" and click then
				a:activateHotkey(i)
			elseif button == "right" and click then
				a.hotkey[i] = nil
				a.changed = true
			else
				a.changed = true
				self.cur_sel = i
				if on_over then
					local text = ""
					if a.hotkey[i] and a.hotkey[i][1] == "talent" then
						local t = self.actor:getTalentFromId(a.hotkey[i][2])
						text = tstring{{"color","GOLD"}, {"font", "bold"}, t.name, {"font", "normal"}, {"color", "LAST"}, true}
						text:merge(self.actor:getTalentFullDescription(t))
					elseif a.hotkey[i] and a.hotkey[i][1] == "inventory" then
						local o = a:findInAllInventories(a.hotkey[i][2])
						if o then text = o:getDesc() else text = "Missing!" end
					end
					on_over(text)
				end
			end
			return
		end
	end
	self.cur_sel = nil
end
