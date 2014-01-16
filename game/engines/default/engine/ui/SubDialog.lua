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
local KeyBind = require "engine.KeyBind"
local Base = require "engine.ui.Base"
local Focusable = require "engine.ui.Focusable"

--- A generic UI button
module(..., package.seeall, class.inherit(Base, Focusable))

title_shadow = true

function _M:init(title, w, h, x, y, alpha, font, showup, skin)
	self.title = title
	self.alpha = self.alpha or 255
	self.color = self.color or {r=255, g=255, b=255}
	if skin then self.ui = skin end

	local conf = self.ui_conf[self.ui]
	self.frame = self.frame or {
		b7 = "ui/dialogframe_7.png",
		b8 = "ui/dialogframe_8.png",
		b9 = "ui/dialogframe_9.png",
		b1 = "ui/dialogframe_1.png",
		b2 = "ui/dialogframe_2.png",
		b3 = "ui/dialogframe_3.png",
		b4 = "ui/dialogframe_4.png",
		b6 = "ui/dialogframe_6.png",
		b5 = "ui/dialogframe_5.png",
		shadow = conf.frame_shadow,
		a = conf.frame_alpha or 1,
	}
	self.frame.ox1 = self.frame.ox1 or conf.frame_ox1
	self.frame.ox2 = self.frame.ox2 or conf.frame_ox2
	self.frame.oy1 = self.frame.oy1 or conf.frame_oy1
	self.frame.oy2 = self.frame.oy2 or conf.frame_oy2

	self.frame.title_x = 0
	self.frame.title_y = 0
	if conf.title_bar then
		self.frame.title_x = conf.title_bar.x
		self.frame.title_y = conf.title_bar.y
		self.frame.title_w = conf.title_bar.w
		self.frame.title_h = conf.title_bar.h
		self.frame.b7 = self.frame.b7:gsub("dialogframe", "title_dialogframe")
		self.frame.b8 = self.frame.b8:gsub("dialogframe", "title_dialogframe")
		self.frame.b9 = self.frame.b9:gsub("dialogframe", "title_dialogframe")
	end

	self.uis = {}
	self.ui_by_ui = {}
	self.focus_ui = nil
	self.focus_ui_id = 0

	self.force_x = x
	self.force_y = y

	self.first_display = true

	Base.init(self, {}, true)

	self:resize(w, h, true)
end

function _M:resize(w, h, nogen)
	local gamew, gameh = core.display.size()
	self.w, self.h = math.floor(w), math.floor(h)
	self.display_x = math.floor(self.force_x or (gamew - self.w) / 2)
	self.display_y = math.floor(self.force_y or (gameh - self.h) / 2)
	if self.title then
		self.ix, self.iy = 5, 8 + 3 + self.font_bold_h
		self.iw, self.ih = w - 2 * 5, h - 8 - 8 - 3 - self.font_bold_h
	else
		self.ix, self.iy = 5, 8
		self.iw, self.ih = w - 2 * 5, h - 8 - 8
	end

--	self.display_x = util.bound(self.display_x, 0, game.w - (self.w+self.frame.ox2))
--	self.display_y = util.bound(self.display_y, 0, game.h - (self.h+self.frame.oy2))

	if not nogen then self:generate() end
end

function _M:generate()
	local gamew, gameh = core.display.size()

	self.frame.w = self.w - self.frame.ox1 + self.frame.ox2
	self.frame.h = self.h - self.frame.oy1 + self.frame.oy2

	self.b7 = self:getUITexture(self.frame.b7)
	self.b9 = self:getUITexture(self.frame.b9)
	self.b1 = self:getUITexture(self.frame.b1)
	self.b3 = self:getUITexture(self.frame.b3)
	self.b8 = self:getUITexture(self.frame.b8)
	self.b4 = self:getUITexture(self.frame.b4)
	self.b2 = self:getUITexture(self.frame.b2)
	self.b6 = self:getUITexture(self.frame.b6)
	self.b5 = self:getUITexture(self.frame.b5)

	self.overs = {}
	for i, o in ipairs(self.frame.overlays or {}) do
		local ov = self:getUITexture(o.image)
		if o.gen then
			o.gen(ov, self)
		else
			ov.x = o.x
			ov.y = o.y
			ov.a = o.a
		end
		self.overs[#self.overs+1] = ov
	end

	self:updateTitle(self.title)

	self.mouse:registerZone(0, 0, self.w, self.h, function(...) self:mouseEvent(...) end)
	self.key.receiveKey = function(_, ...) self:keyEvent(...) end
	self.key:addCommands{
		_TAB = function() self:moveFocus(1) end,
		_UP = function() self:moveFocus(-1) end,
		_DOWN = function() self:moveFocus(1) end,
		_LEFT = function() self:moveFocus(-1) end,
		_RIGHT = function() self:moveFocus(1) end,
	}
end

function _M:updateTitle(title)
	if not title then return end
	local title = title
	if type(title)=="function" then title = title() end
	self.font_bold:setStyle("bold")
	local tw, th = self.font_bold:size(title)
	local s = core.display.newSurface(tw, th)
	s:erase(0, 0, 0, 0)
	s:drawColorStringBlended(self.font_bold, title, 0, 0, self.color.r, self.color.g, self.color.b, true)
	self.font_bold:setStyle("normal")
	self.title_tex = {s:glTexture()}
	self.title_tex.w = tw
	self.title_tex.h = th
end

function _M:loadUI(t)
	if not t.no_reset then
		self.uis = {}
		self.ui_by_ui = {}
		self.focus_ui = nil
		self.focus_ui_id = 0
	end
	for i, ui in ipairs(t) do
		self.uis[#self.uis+1] = ui
		self.ui_by_ui[ui.ui] = ui

		if not self.focus_ui and ui.ui.can_focus then
			self:setSubFocus(i)
		elseif ui.ui.can_focus then
			ui.ui:setFocus(false)
		end
	end
end

function _M:setupUI(resizex, resizey, on_resize, addmw, addmh)
	local mw, mh = nil, nil

--	resizex, resizey = true, true
	if resizex or resizey then
		mw, mh = 0, 0
		local addw, addh = 0, 0

		for i, ui in ipairs(self.uis) do
			if not ui.absolute then
				if ui.top then mh = math.max(mh, ui.top + ui.ui.h + (ui.padding_h or 0))
				elseif ui.bottom then addh = math.max(addh, ui.bottom + ui.ui.h + (ui.padding_h or 0))
				end
			end

--		print("ui", ui.left, ui.right, ui.ui.w)
			if not ui.absolute then
				if ui.left then mw = math.max(mw, ui.left + ui.ui.w + (ui.padding_w or 0))
				elseif ui.right then addw = math.max(addw, ui.right + ui.ui.w + (ui.padding_w or 0))
				end
			end
		end
--		print("===", mw, addw)
		mw = mw + addw + 5 * 2 + (addmw or 0)

--		print("===", mw, addw)
		local tw, th = 0, 0
		if self.title then tw, th = self.font_bold:size(self.title) end
		mw = math.max(tw + 6, mw)

		mh = mh + addh + 5 + 22 + 3 + (addmh or 0) + th

		if on_resize then on_resize(resizex and mw or self.w, resizey and mh or self.h) end
		self:resize(resizex and mw or self.w, resizey and mh or self.h)
	else
		if on_resize then on_resize(self.w, self.h) end
		self:resize(self.w, self.h)
	end

	for i, ui in ipairs(self.uis) do
		local ux, uy

		if not ui.absolute then
			ux, uy = self.ix, self.iy

			if ui.top then
				if type(ui.top) == "table" then ui.top = self.ui_by_ui[ui.top].y end
				uy = uy + ui.top
			elseif ui.bottom then
				if type(ui.bottom) == "table" then ui.bottom = self.ui_by_ui[ui.bottom].y end
				uy = uy + self.ih - ui.bottom - ui.ui.h
			elseif ui.vcenter then
				if type(ui.vcenter) == "table" then ui.vcenter = self.ui_by_ui[ui.vcenter].y + ui.vcenter.h end
				uy = uy + math.floor(self.ih / 2) + ui.vcenter - ui.ui.h / 2
			end

			if ui.left then
				if type(ui.left) == "table" then ui.left = self.ui_by_ui[ui.left].x + ui.left.w end
				ux = ux + ui.left
			elseif ui.right then
				if type(ui.right) == "table" then ui.right = self.ui_by_ui[ui.right].x end
				ux = ux + self.iw - ui.right - ui.ui.w
			elseif ui.hcenter then
				if type(ui.hcenter) == "table" then ui.hcenter = self.ui_by_ui[ui.hcenter].x + ui.hcenter.w end
				ux = ux + math.floor(self.iw / 2) + ui.hcenter - ui.ui.w / 2
			end
		else
			ux, uy = 0, 0

			if ui.top then uy = uy + ui.top
			elseif ui.bottom then uy = uy + game.h - ui.bottom - ui.ui.h
			elseif ui.vcenter then uy = uy + math.floor(game.h / 2) + ui.vcenter - ui.ui.h / 2 end

			if ui.left then ux = ux + ui.left
			elseif ui.right then ux = ux + game.w - ui.right - ui.ui.w
			elseif ui.hcenter then ux = ux + math.floor(game.w / 2) + ui.hcenter - ui.ui.w / 2 end

			ux = ux - self.display_x
			uy = uy - self.display_y
		end

		ui.x = ux
		ui.y = uy
		ui.ui.mouse.delegate_offset_x = ux
		ui.ui.mouse.delegate_offset_y = uy
		ui.ui:positioned(ux, uy, self.display_x + ux, self.display_y + uy)
	end

	self.setuped = true
end

function _M:setSubFocus(id)
	if self.focus_ui and self.focus_ui.ui.can_focus then self.focus_ui.ui:setFocus(false) end

	if type(id) == "table" then
		for i = 1, #self.uis do
			if self.uis[i].ui == id then id = i break end
		end
		if type(id) == "table" then return end
	end

	local ui = self.uis[id]
	if not ui.ui.can_focus then return end
	self.focus_ui = ui
	self.focus_ui_id = id
	ui.ui:setFocus(true)
end

function _M:moveUIElement(id, left, right, top, bottom)
	if type(id) == "table" then
		for i = 1, #self.uis do
			if self.uis[i].ui == id then id = i break end
		end
		if type(id) == "table" then return end
	end

	self.uis[id].left = left or self.uis[id].left
	self.uis[id].right = right or self.uis[id].right
	self.uis[id].top = top or self.uis[id].top
	self.uis[id].bottom = bottom or self.uis[id].bottom
end

function _M:getUIElement(id)
	if type(id) == "table" then
		for i = 1, #self.uis do
			if self.uis[i].ui == id then id = i break end
		end
		if type(id) == "table" then return end
	end

	return self.uis[id]
end

function _M:toggleDisplay(ui, show)
	if not self.ui_by_ui[ui] then return end
	self.ui_by_ui[ui].hidden = not show
end

function _M:moveFocus(v)
	local id = self.focus_ui_id
	local start = id or 1
	local cnt = 0
	id = util.boundWrap((id or 1) + v, 1, #self.uis)
	while start ~= id and cnt <= #self.uis do
		if self.uis[id] and self.uis[id].ui and self.uis[id].ui.can_focus and not self.uis[id].ui.no_keyboard_focus then
			self:setSubFocus(id)
			break
		end
		id = util.boundWrap(id + v, 1, #self.uis)
		cnt = cnt + 1
	end
end

function _M:on_focus(v)
	if not v then
		self.last_focus = self.focus_ui
		self:setSubFocus({})
	else
		self:setSubFocus(self.focus_ui)
	end
end

function _M:mouseEvent(button, x, y, xrel, yrel, bx, by, event)
	-- Look for focus
	for i = 1, #self.uis do
		local ui = self.uis[i]
		if ui.ui.can_focus and bx >= ui.x and bx <= ui.x + ui.ui.w and by >= ui.y and by <= ui.y + ui.ui.h then
			self:setSubFocus(i)

			-- Pass the event
			ui.ui.mouse:delegate(button, bx, by, xrel, yrel, bx, by, event)
			return
		end
	end
end

function _M:keyEvent(...)
	if not self.focus_ui or not self.focus_ui.ui.key:receiveKey(...) then
		KeyBind.receiveKey(self.key, ...)
	end
end

function _M:display() end

function _M:unload()
end

function _M:drawFrame(x, y, r, g, b, a)
	x = x + self.frame.ox1
	y = y + self.frame.oy1

	-- Corners
	self.b7.t:toScreenFull(x, y, self.b7.w, self.b7.h, self.b7.tw, self.b7.th, r, g, b, a)
	self.b1.t:toScreenFull(x, y + self.frame.h - self.b1.h, self.b1.w, self.b1.h, self.b1.tw, self.b1.th, r, g, b, a)
	self.b9.t:toScreenFull(x + self.frame.w - self.b9.w, y, self.b9.w, self.b9.h, self.b9.tw, self.b9.th, r, g, b, a)
	self.b3.t:toScreenFull(x + self.frame.w - self.b3.w, y + self.frame.h - self.b3.h, self.b3.w, self.b3.h, self.b3.tw, self.b3.th, r, g, b, a)

	-- Sides
	self.b8.t:toScreenFull(x + self.b7.w, y, self.frame.w - self.b7.w - self.b9.w, self.b8.h, self.b8.tw, self.b8.th, r, g, b, a)
	self.b2.t:toScreenFull(x + self.b7.w, y + self.frame.h - self.b3.h, self.frame.w - self.b7.w - self.b9.w, self.b2.h, self.b2.tw, self.b2.th, r, g, b, a)
	self.b4.t:toScreenFull(x, y + self.b7.h, self.b4.w, self.frame.h - self.b7.h - self.b1.h, self.b4.tw, self.b4.th, r, g, b, a)
	self.b6.t:toScreenFull(x + self.frame.w - self.b9.w, y + self.b7.h, self.b6.w, self.frame.h - self.b7.h - self.b1.h, self.b6.tw, self.b6.th, r, g, b, a)

	-- Body
	self.b5.t:toScreenFull(x + self.b7.w, y + self.b7.h, self.frame.w - self.b7.w - self.b3.w , self.frame.h - self.b7.h - self.b3.h, self.b6.tw, self.b6.th, r, g, b, a)

	-- Overlays
	for i = 1, #self.overs do
		local ov = self.overs[i]
		ov.t:toScreenFull(x + ov.x, y + ov.y, ov.w , ov.h, ov.tw, ov.th, r, g, b, a * ov.a)
	end
end

function _M:innerDisplayBack(x, y, nb_keyframes)
end
function _M:innerDisplay(x, y, nb_keyframes)
end

function _M:firstDisplay()
end

function _M:display(x, y, nb_keyframes)
	if self.__hidden then return end

	local zoom = 1

	-- We translate and scale opengl matrix to make the popup effect easily
	local ox, oy = x, y
	local hw, hh = math.floor(self.w / 2), math.floor(self.h / 2)
	local tx, ty = x + hw, y + hh
	x, y = -hw, -hh
	core.display.glTranslate(tx, ty, 0)
	if zoom < 1 then core.display.glScale(zoom, zoom, zoom) end

	-- Draw the frame and shadow
	if self.frame.shadow then self:drawFrame(x + self.frame.shadow.x, y + self.frame.shadow.y, 0, 0, 0, self.frame.shadow.a) end
	self:drawFrame(x, y, 1, 1, 1, self.frame.a)

	-- Title
	if self.title then
		if self.title_shadow then self.title_tex[1]:toScreenFull(x + (self.w - self.title_tex.w) / 2 + 3 + self.frame.title_x, y + 3 + self.frame.title_y, self.title_tex.w, self.title_tex.h, self.title_tex[2], self.title_tex[3], 0, 0, 0, 0.5) end
		self.title_tex[1]:toScreenFull(x + (self.w - self.title_tex.w) / 2 + self.frame.title_x, y + self.frame.title_y, self.title_tex.w, self.title_tex.h, self.title_tex[2], self.title_tex[3])
	end

	self:innerDisplayBack(x, y, nb_keyframes, tx, ty)

	-- UI elements
	for i = 1, #self.uis do
		local ui = self.uis[i]
		if not ui.hidden then ui.ui:display(x + ui.x, y + ui.y, nb_keyframes, ox + ui.x, oy + ui.y) end
	end

	self:innerDisplay(x, y, nb_keyframes, tx, ty)

	if self.first_display then self:firstDisplay() self.first_display = false end

	-- Restiore normal opengl matrix
	if zoom < 1 then core.display.glScale() end
	core.display.glTranslate(-tx, -ty, 0)
end
