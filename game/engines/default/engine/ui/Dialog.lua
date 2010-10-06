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
local KeyBind = require "engine.KeyBind"
local Base = require "engine.ui.Base"

--- A generic UI button
module(..., package.seeall, class.inherit(Base))

--- Requests a simple, press any key, dialog
function _M:simplePopup(title, text, fct, no_leave)
	local w, h = self.font:size(text:removeColorCodes())
	local tw, th = self.font:size(title:removeColorCodes())
	local d = new(title, math.max(w, tw) + 20, h + 75)
	d:loadUI{{left = 3, top = 3, ui=require("engine.ui.Textzone").new{width=w+10, height=h+5, text=text}}}
	if not no_leave then
		d.key:addBind("EXIT", function() game:unregisterDialog(d) if fct then fct() end end)
		local close = require("engine.ui.Button").new{text="Close", fct=function() d.key:triggerVirtual("EXIT") end}
		d:loadUI{no_reset=true, {hcenter = 0, bottom = 3, ui=close}}
		d:setFocus(close)
	end
	d:setupUI(true, true)
	game:registerDialog(d)
	return d
end

--- Requests a simple, press any key, dialog
function _M:simpleLongPopup(title, text, w, fct, no_leave)
	local list = text:splitLines(w - 10, self.font)
	local d = new(title, w + 20, #list * self.font_h + 75)
	d:loadUI{{left = 3, top = 3, ui=require("engine.ui.Textzone").new{width=w+10, height=self.font_h * #list, text=text}}}
	if not no_leave then
		d.key:addBind("EXIT", function() game:unregisterDialog(d) if fct then fct() end end)
		local close = require("engine.ui.Button").new{text="Close", fct=function() d.key:triggerVirtual("EXIT") end}
		d:loadUI{no_reset=true, {hcenter = 0, bottom = 3, ui=close}}
		d:setFocus(close)
	end
	d:setupUI(true, true)
	game:registerDialog(d)
	return d
end

--- Requests a simple yes-no dialog
function _M:yesnoPopup(title, text, fct, yes_text, no_text)
	local w, h = self.font:size(text:removeColorCodes())
	local tw, th = self.font:size(title:removeColorCodes())
	local d = new(title, math.max(w, tw) + 35, h + 75)

	d.key:addBind("EXIT", function() game:unregisterDialog(d) fct(false) end)
	local ok = require("engine.ui.Button").new{text=yes_text or "Yes", fct=function() game:unregisterDialog(d) fct(true) end}
	local cancel = require("engine.ui.Button").new{text=no_text or "No", fct=function() game:unregisterDialog(d) fct(false) end}
	d:loadUI{
		{left = 3, top = 3, ui=require("engine.ui.Textzone").new{width=w+20, height=h+5, text=text}},
		{left = 3, bottom = 3, ui=ok},
		{right = 3, bottom = 3, ui=cancel},
	}
	d:setFocus(ok)
	d:setupUI(true, true)

	game:registerDialog(d)
	return d
end

--- Requests a long yes-no dialog
function _M:yesnoLongPopup(title, text, w, fct, yes_text, no_text)
	local list = text:splitLines(w - 10, font)
	local d = new(title, w + 20, #list * self.font_h + 75)

	d.key:addBind("EXIT", function() game:unregisterDialog(d) fct(false) end)
	local ok = require("engine.ui.Button").new{text=yes_text or "Yes", fct=function() game:unregisterDialog(d) fct(true) end}
	local cancel = require("engine.ui.Button").new{text=no_text or "No", fct=function() game:unregisterDialog(d) fct(false) end}
	d:loadUI{
		{left = 3, top = 3, ui=require("engine.ui.Textzone").new{width=w+20, height=self.font_h * #list, text=text}},
		{left = 3, bottom = 3, ui=ok},
		{right = 3, bottom = 3, ui=cancel},
	}
	d:setFocus(ok)
	d:setupUI(true, true)

	game:registerDialog(d)
	return d
end


function _M:init(title, w, h, x, y, alpha, font, showup)
	self.title = assert(title, "no dialog title")
	self.alpha = self.alpha or 255
	if showup ~= nil then
		self.__showup = showup
	else
		self.__showup = 2
	end

	self.uis = {}
	self.focus_ui = nil
	self.focus_ui_id = 0

	self.force_x = x
	self.force_y = y

	Base.init(self, {}, true)

	self:resize(w, h, true)
end

function _M:resize(w, h, nogen)
	local gamew, gameh = core.display.size()
	self.w, self.h = math.floor(w), math.floor(h)
	self.display_x = math.floor(self.force_x or (gamew - self.w) / 2)
	self.display_y = math.floor(self.force_y or (gameh - self.h) / 2)
	self.ix, self.iy = 5, 22 + 3
	self.iw, self.ih = w - 2 * 5, h - 8 - 22 - 3

	if not nogen then self:generate() end
end

function _M:generate()
	local gamew, gameh = core.display.size()
	local s = core.display.newSurface(self.w, self.h)
	s:alpha(true)
	s:erase(0, 0, 0, self.alpha)

	local b7, b7_w, b7_h = self:getImage("border_7.png")
	local b9, b9_w, b9_h = self:getImage("border_9.png")
	local b1, b1_w, b1_h = self:getImage("border_1.png")
	local b3, b3_w, b3_h = self:getImage("border_3.png")
	local b8, b8_w, b8_h = self:getImage("border_8.png")
	local b4, b4_w, b4_h = self:getImage("border_4.png")

	s:merge(b7, 0, 0)
	s:merge(b9, self.w - b9_w, 0)
	s:merge(b1, 0, self.h - b1_h)
	s:merge(b3, self.w - b9_w, self.h - b3_h)

	for i = b7_w, self.w - b9_w do
		s:merge(b8, i, 0)
		s:merge(b8, i, 20)
		s:merge(b8, i, self.h - 3)
	end
	for i = b7_h, self.h - b1_h do
		s:merge(b4, 0, i)
		s:merge(b4, self.w - 3, i)
	end

	self.font:setStyle("bold")
	local tw, th = self.font:size(self.title:removeColorCodes())
	s:drawColorStringBlended(self.font, self.title, (self.w - tw) / 2, 4, 255,255,255)
	self.font:setStyle("normal")

	self.mouse:registerZone(0, 0, gamew, gameh, function(button, x, y, xrel, yrel, bx, by, event) if button == "left" and event == "button" then  self.key:triggerVirtual("EXIT") end end)
	self.mouse:registerZone(self.display_x, self.display_y, self.w, self.h, function(...) self:mouseEvent(...) end)
	self.key.receiveKey = function(_, ...) self:keyEvent(...) end
	self.key:addCommand("_TAB", function(...) self.key:triggerVirtual("MOVE_DOWN") end)
	self.key:addBinds{
		MOVE_UP = function() self:moveFocus(-1) end,
		MOVE_DOWN = function() self:moveFocus(1) end,
		MOVE_LEFT = "MOVE_UP",
		MOVE_RIGHT = "MOVE_DOWN",
	}

	self.tex, self.tex_w, self.tex_h = s:glTexture()
end

function _M:loadUI(t)
	if not t.no_reset then
		self.uis = {}
		self.focus_ui = nil
		self.focus_ui_id = 0
	end
	for i, ui in ipairs(t) do
		self.uis[#self.uis+1] = ui

		if not self.focus_ui and ui.ui.can_focus then
			self:setFocus(i)
		elseif ui.ui.can_focus then
			ui.ui:setFocus(false)
		end
	end
end

function _M:setupUI(resizex, resizey, on_resize)
	local mw, mh = nil, nil

--	resizex, resizey = true, true
	if resizex or resizey then
		mw, mh = 0, 0
		local addw, addh = 0, 0

		for i, ui in ipairs(self.uis) do
			if ui.top then mh = math.max(mh, ui.top + ui.ui.h + (ui.padding_h or 0))
			elseif ui.bottom then addh = math.max(addh, ui.bottom + ui.ui.h + (ui.padding_h or 0))
			end

--		print("ui", ui.left, ui.right, ui.ui.w)
			if ui.left then mw = math.max(mw, ui.left + ui.ui.w + (ui.padding_w or 0))
			elseif ui.right then addw = math.max(addw, ui.right + ui.ui.w + (ui.padding_w or 0))
			end
		end
--		print("===", mw, addw)
		mw = mw + addw + 5 * 2
		mh = mh + addh + 5 + 22 + 3
--		print("===", mw, addw)

		if on_resize then on_resize(resizex and mw or self.w, resizey and mh or self.h) end
		self:resize(resizex and mw or self.w, resizey and mh or self.h)
	else
		if on_resize then on_resize(self.w, self.h) end
		self:resize(self.w, self.h)
	end

	for i, ui in ipairs(self.uis) do
		local ux, uy = self.ix, self.iy

		if ui.top then uy = uy + ui.top
		elseif ui.bottom then uy = uy + self.ih - ui.bottom - ui.ui.h
		elseif ui.vcenter then uy = uy + math.floor(self.ih / 2) + ui.vcenter - ui.ui.h / 2 end

		if ui.left then ux = ux + ui.left
		elseif ui.right then ux = ux + self.iw - ui.right - ui.ui.w
		elseif ui.hcenter then ux = ux + math.floor(self.iw / 2) + ui.hcenter - ui.ui.w / 2 end

		ui.x = ux
		ui.y = uy
		ui.ui.mouse.delegate_offset_x = ux
		ui.ui.mouse.delegate_offset_y = uy
	end

	self.setuped = true
end

function _M:setFocus(id)
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

function _M:moveFocus(v)
	local id = self.focus_ui_id
	local start = id or 1
	id = util.boundWrap((id or 1) + v, 1, #self.uis)
	while start ~= id do
		if self.uis[id].ui.can_focus then
			self:setFocus(id)
			break
		end
		id = util.boundWrap(id + v, 1, #self.uis)
	end
end

function _M:mouseEvent(button, x, y, xrel, yrel, bx, by, event)
	-- Look for focus
	for i = 1, #self.uis do
		local ui = self.uis[i]
		if ui.ui.can_focus and bx >= ui.x and bx <= ui.x + ui.ui.w and by >= ui.y and by <= ui.y + ui.ui.h then
			self:setFocus(i)

			-- Pass the event
			ui.ui.mouse:delegate(button, bx, by, xrel, yrel, bx, by, event)
			break
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

function _M:makeKeyChar(i)
	i = i - 1
	if i <= 26 then
		return string.char(string.byte('a') + i)
	elseif i <= 52 then
		return string.char(string.byte('A') + i)
	elseif i <= 62 then
		return string.char(string.byte('0') + i)
	else
		-- Invalid
		return "  "
	end
end

function _M:toScreen(x, y)
	-- Draw with only the texture
	if self.__showup then
		local eff = self.__showup_effect or "pop"
		if eff == "overpop" then
			local zoom = self.__showup / 7
			if self.__showup >= 9 then
				zoom = (9 - (self.__showup - 9)) / 7 - 1
				zoom = 1 + zoom * 0.5
			end
			self.tex:toScreenFull(x + (self.w - self.w * zoom) / 2, y + (self.h - self.h * zoom) / 2, self.w * zoom, self.h * zoom, self.tex_w * zoom, self.tex_h * zoom)
			self.__showup = self.__showup + 1
			if self.__showup >= 11 then self.__showup = nil end
		else
			local zoom = self.__showup / 7
			self.tex:toScreenFull(x + (self.w - self.w * zoom) / 2, y + (self.h - self.h * zoom) / 2, self.w * zoom, self.h * zoom, self.tex_w * zoom, self.tex_h * zoom)
			self.__showup = self.__showup + 1
			if self.__showup >= 7 then self.__showup = nil end
		end
	else
		self.tex:toScreenFull(x, y, self.w, self.h, self.tex_w, self.tex_h)
		for i = 1, #self.uis do
			local ui = self.uis[i]
			ui.ui:display(x + ui.x, y + ui.y)
		end
	end
end
