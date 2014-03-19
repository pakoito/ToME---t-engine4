-- TE4 - T-Engine 4
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

module(..., package.seeall, class.make)

function _M:init(actor, x, y, w, h, bgcolor, fontname, fontsize)
	self.actor = actor
	if type(bgcolor) ~= "string" then
		self.bgcolor = bgcolor or {0,0,0}
	else
		self.bgcolor = {0,0,0}
		self.bg_image = bgcolor
	end
	self.font = core.display.newFont(fontname or "/data/font/DroidSansMono.ttf", fontsize or 10)
	self.font_h = self.font:lineSkip()
	self.clics = {}
	self.items = {}
	self.cache = {}
	setmetatable(self.cache, {__mode="v"})
	self:resize(x, y, w, h)
	self.nb_cols = 1
end

--- Sets the display into nb columns
function _M:setColumns(nb)
	self.nb_cols = nb
end

function _M:enableShadow(v)
	self.shadow = v
end

--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = math.floor(x), math.floor(y)
	self.w, self.h = math.floor(w), math.floor(h)
	self.surface = core.display.newSurface(w, h)
	self.texture, self.texture_w, self.texture_h = self.surface:glTexture()
	if self.actor then self.actor.changed = true end

	if self.bg_image then
		local fill = core.display.loadImage(self.bg_image)
		local fw, fh = fill:getSize()
		self.bg_surface = core.display.newSurface(w, h)
		self.bg_surface:erase(0, 0, 0)
		for i = 0, w, fw do for j = 0, h, fh do
			self.bg_surface:merge(fill, i, j)
		end end
		self.bg_texture, self.bg_texture_w, self.bg_texture_h = self.bg_surface:glTexture()
	end
end

local page_to_hotkey = {"", "SECOND_", "THIRD_", "FOURTH_", "FIFTH_"}

-- Displays the hotkeys, keybinds & cooldowns
function _M:display()
	local a = self.actor
	if not a or not a.changed then return self.surface end

	local page = a.hotkey_page
	if page == 1 and core.key.modState("ctrl") then page = 2
	elseif page == 1 and core.key.modState("shift") then page = 3 end

	local hks = {}
	for i = 1, 12 do
		local j = i + (12 * (page - 1))
		if a.hotkey[j] and a.hotkey[j][1] == "talent" then
			hks[#hks+1] = {a.hotkey[j][2], i, "talent"}
		elseif a.hotkey[j] and a.hotkey[j][1] == "inventory" then
			hks[#hks+1] = {a.hotkey[j][2], i, "inventory"}
		end
	end

	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])
	if self.bg_surface then self.surface:merge(self.bg_surface, 0, 0) end

	local x = 0
	local y = 0
	self.clics = {}
	self.items = {}

	for ii, ts in ipairs(hks) do
		local s
		local i = ts[2]
		local txt, color = "", {0,255,0}
		if ts[3] == "talent" then
			local tid = ts[1]
			local t = a:getTalentFromId(tid)
			if a:isTalentCoolingDown(t) then
				txt = ("%s (%d)"):format(t.name, a:isTalentCoolingDown(t))
				color = {255,0,0}
			elseif a:isTalentActive(t.id) then
				txt = t.name
				color = {255,255,0}
			elseif not a:preUseTalent(t, true, true) then
				txt = t.name
				color = {190,190,190}
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

		txt = ("%1d/%2d) %s"):format(page, i, txt)
		local w, h, gen
		if self.cache[txt] then
			gen = self.cache[txt]
			w, h = gen.fw, gen.fh
		else
			w, h = self.font:size(txt)
			gen = self.font:draw(txt, self.w / self.nb_cols, color[1], color[2], color[3], true)[1]
			gen.fw, gen.fh = w, h
		end
		gen.x, gen.y = x, y
		gen.i = i
		self.items[#self.items+1] = gen
		self.clics[i + (12 * (page - 1))] = {x,y,w+4,h+4}

		if y + self.font_h * 2 > self.h then
			x = x + self.w / self.nb_cols
			y = 0
		else
			y = y + self.font_h
		end
	end
end

function _M:toScreen()
	self:display()
	if self.bg_texture then self.bg_texture:toScreenFull(self.display_x, self.display_y, self.w, self.h, self.bg_texture_w, self.bg_texture_h) end
	for i = 1, #self.items do
		local item = self.items[i]
		if self.cur_sel == item.i then core.display.drawQuad(self.display_x + item.x, self.display_y + item.y, item.w, item.h, 0, 50, 120, 180) end
		if self.shadow then item._tex:toScreenFull(self.display_x + item.x + 2, self.display_y + item.y + 2, item.w, item.h, item._tex_w, item._tex_h, 0, 0, 0, self.shadow) end
		item._tex:toScreenFull(self.display_x + item.x, self.display_y + item.y, item.w, item.h, item._tex_w, item._tex_h)
	end
end

--- Call when a mouse event arrives in this zone
-- This is optional, only if you need mouse support
function _M:onMouse(button, mx, my, click, on_over, on_click)
	local a = self.actor

	if button == "wheelup" and click then
		a:prevHotkeyPage()
		return
	elseif button == "wheeldown" and click then
		a:nextHotkeyPage()
		return
	end

	mx, my = mx - self.display_x, my - self.display_y
	for i, zone in pairs(self.clics) do
		if mx >= zone[1] and mx < zone[1] + zone[3] and my >= zone[2] and my < zone[2] + zone[4] then
			if on_click and click then
				if on_click(i, a.hotkey[i]) then click = false end
			end
			if button == "left" and click then
				a:activateHotkey(i)
			elseif button == "right" and click then
				a.hotkey[i] = nil
				a.changed = true
			else
				a.changed = true
				local oldsel = self.cur_sel
				self.cur_sel = i
				if on_over and self.cur_sel ~= oldsel then
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
