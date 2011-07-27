-- TE4 - T-Engine 4
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
local Entity = require "engine.Entity"
local Tiles = require "engine.Tiles"

module(..., package.seeall, class.make)

function _M:init(actor, x, y, w, h, bgcolor, fontname, fontsize, icon_w, icon_h)
	self.actor = actor
	if type(bgcolor) ~= "string" then
		self.bgcolor = bgcolor or {0,0,0}
	else
		self.bgcolor = {0,0,0}
		self.bg_image = bgcolor
	end
	self.font = core.display.newFont(fontname or "/data/font/VeraMono.ttf", fontsize or 10)
	self.fontbig = core.display.newFont(fontname or "/data/font/VeraMono.ttf", (fontsize or 10) * 2)
	self.font_h = self.font:lineSkip()
	self.clics = {}
	self.items = {}
	self.cache = {}
	setmetatable(self.cache, {__mode="v"})
	self:resize(x, y, w, h)
	self.nb_cols = 1
	self.icon_w, self.icon_h = icon_w, icon_h
	self.tiles = Tiles.new(icon_w, icon_h, fontname or "/data/font/VeraMono.ttf", fontsize or 10, true, true)

	local fw, fh = core.display.loadImage("/data/gfx/ui/talent_frame_ok.png"):getSize()
	self.frames = {w=math.floor(fw * icon_w / 64), h=math.floor(fh * icon_h / 64), rw=icon_w / 64, rh=icon_h / 64}
	self.frames.fx = math.floor((self.frames.w - icon_w) / 2)
	self.frames.fy = math.floor((self.frames.h - icon_h) / 2)
	self.frames.ok = { core.display.loadImage("/data/gfx/ui/talent_frame_ok.png"):glTexture() }
	self.frames.disabled = { core.display.loadImage("/data/gfx/ui/talent_frame_disabled.png"):glTexture() }
	self.frames.cooldown = { core.display.loadImage("/data/gfx/ui/talent_frame_cooldown.png"):glTexture() }
	self.frames.sustain = { core.display.loadImage("/data/gfx/ui/talent_frame_sustain.png"):glTexture() }

	self.default_entity = Entity.new{display='?', color=colors.WHITE}
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

local page_to_hotkey = {"", "SECOND_", "THIRD_"}

-- Displays the hotkeys, keybinds & cooldowns
function _M:display()
	local a = self.actor
	if not a or not a.changed then return self.surface end

	local page = a.hotkey_page
	if page == 1 and core.key.modState("ctrl") then page = 2
	elseif page == 1 and core.key.modState("shift") then page = 3 end

	local hks = {}
	for page=1,3 do
	for i = 1, 12 do
		local j = i + (12 * (page - 1))
		if a.hotkey[j] and a.hotkey[j][1] == "talent" then
			hks[#hks+1] = {a.hotkey[j][2], j, "talent", i, page}
		elseif a.hotkey[j] and a.hotkey[j][1] == "inventory" then
			hks[#hks+1] = {a.hotkey[j][2], j, "inventory", i, page}
		end
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
		local lpage = ts[5]
		local color, angle, txt = nil, 0, nil
		local display_entity = nil
		local frame = "ok"
		if ts[3] == "talent" then
			local tid = ts[1]
			local t = a:getTalentFromId(tid)
			display_entity = t.display_entity
			if a:isTalentCoolingDown(t) then
				color = {255,0,0}
				angle = 360 * (1 - (a.talents_cd[t.id] / a:getTalentCooldown(t)))
				txt = tostring(a:isTalentCoolingDown(t))
				frame = "cooldown"
			elseif a:isTalentActive(t.id) then
				color = {255,255,0}
				frame = "sustain"
			elseif not a:preUseTalent(t, true, true) then
				color = {190,190,190}
				frame = "disabled"
			end
		elseif ts[3] == "inventory" then
			local o = a:findInAllInventories(ts[1], {no_add_name=true, force_id=true, no_count=true})
			local cnt = 0
			if o then cnt = o:getNumber() end
			if cnt == 0 then
				color = {128,128,128}
				frame = "disabled"
			end
			display_entity = o
			if o and o.use_talent then
				local t = a:getTalentFromId(o.use_talent.id)
				display_entity = t.display_entity
			end
			if o and (o.use_talent or o.use_power) then
				angle = 360 * ((o.power / o.max_power))
				color = {255,0,0}
				local need = (o.use_talent and o.use_talent.power) or (o.use_power and o.use_power.power) or 0
				if o.power < need then
					if o.power_regen and o.power_regen > 0 then
						frame = "cooldown"
						txt = tostring(math.ceil((need - o.power) / o.power_regen))
					else frame = "disabled" end
				end
			end
		end

		local w, h = self.icon_w, self.icon_h
		self.font:setStyle("bold")
		local key = self.font:draw(("%d/%d"):format(ts[4], lpage), w, colors.ANTIQUE_WHITE.r, colors.ANTIQUE_WHITE.g, colors.ANTIQUE_WHITE.b, true)[1]
		self.font:setStyle("normal")

		local gtxt = nil
		if txt then
			gtxt = self.fontbig:draw(txt, w, colors.WHITE.r, colors.WHITE.g, colors.WHITE.b, true)[1]
			gtxt.fw, gtxt.fh = self.fontbig:size(txt)
		end

		x = self.frames.w * (i-1)
		y = 0
		self.items[#self.items+1] = {i=i, x=x, y=y, e=display_entity or self.default_entity, color=color, angle=angle, key=key, gtxt=gtxt, frame=frame, pagesel=lpage==page}
		self.clics[i] = {x,y,w,h}
	end
end

function _M:toScreen()
	self:display()
	if self.bg_texture then self.bg_texture:toScreenFull(self.display_x, self.display_y, self.w, self.h, self.bg_texture_w, self.bg_texture_h) end
	for i = 1, #self.items do
		local item = self.items[i]
		local key = item.key
		local gtxt = item.gtxt
		local frame = self.frames[item.frame]
		local pagesel = item.pagesel and 1 or 0.5
		frame[1]:toScreenFull(self.display_x + item.x, self.display_y + item.y, self.frames.w, self.frames.h, frame[2] * self.frames.rw, frame[3] * self.frames.rh, pagesel, pagesel, pagesel, 255)
		item.e:toScreen(self.tiles, self.display_x + item.x + self.frames.fx, self.display_y + item.y + self.frames.fy, self.icon_w, self.icon_h)

		if self.shadow then key._tex:toScreenFull(self.display_x + item.x + 1 + self.frames.fx + self.icon_w - key.w, self.display_y + item.y + 1 + self.icon_h - key.h, key.w, key.h, key._tex_w, key._tex_h, 0, 0, 0, self.shadow) end
		key._tex:toScreenFull(self.display_x + item.x + self.frames.fx + self.icon_w - key.w, self.display_y + item.y + self.icon_h - key.h, key.w, key.h, key._tex_w, key._tex_h)

		if item.color then core.display.drawQuadPart(self.display_x + item.x + self.frames.fx, self.display_y + item.y + self.frames.fy, self.icon_w, self.icon_h, item.angle, item.color[1], item.color[2], item.color[3], 128) end

		if self.cur_sel == item.i then core.display.drawQuad(self.display_x + item.x + self.frames.fx, self.display_y + item.y + self.frames.fy, self.icon_w, self.icon_h, 128, 128, 255, 80) end

		if gtxt then
			if self.shadow then gtxt._tex:toScreenFull(self.display_x + item.x + self.frames.fy + 2 + (self.icon_w - gtxt.fw) / 2, self.display_y + item.y + self.frames.fy + 2 + (self.icon_h - gtxt.fh) / 2, gtxt.w, gtxt.h, gtxt._tex_w, gtxt._tex_h, 0, 0, 0, self.shadow) end
			gtxt._tex:toScreenFull(self.display_x + item.x + self.frames.fx + (self.icon_w - gtxt.fw) / 2, self.display_y + item.y + self.frames.fy + (self.icon_h - gtxt.fh) / 2, gtxt.w, gtxt.h, gtxt._tex_w, gtxt._tex_h)
		end
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
						local o = a:findInAllInventories(a.hotkey[i][2], {no_add_name=true, force_id=true, no_count=true})
						if o then
							text = o:getDesc()
						else text = "Missing!" end
					end
					on_over(text)
				end
			end
			return
		end
	end
	self.cur_sel = nil
end
