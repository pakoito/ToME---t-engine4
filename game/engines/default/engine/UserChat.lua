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
require "engine.ui.Base"
local KeyBind = require "engine.KeyBind"
local Mouse = require "engine.Mouse"

--- Module that handles multiplayer chats
module(..., package.seeall, class.inherit(engine.ui.Base))

local ls, ls_w, ls_h = _M:getImage("ui/selection-left-sel.png")
local ms, ms_w, ms_h = _M:getImage("ui/selection-middle-sel.png")
local rs, rs_w, rs_h = _M:getImage("ui/selection-right-sel.png")
local l, l_w, l_h = _M:getImage("ui/selection-left.png")
local m, m_w, m_h = _M:getImage("ui/selection-middle.png")
local r, r_w, r_h = _M:getImage("ui/selection-right.png")

--- Creates the log zone
function _M:init()
	self.changed = true
	self.channels_changed = true
	self.cur_channel = "global"
	self.channels = {}
	self.max = 50
end

--- Hook up in the current running game
function _M:setupOnGame()
	KeyBind:load("chat")
	_G.game.key:bindKeys() -- Make sure it updates

	_G.game.key:addBinds{
		USERCHAT_TALK = function()
			self:talkBox()
		end,
	}
end

function _M:addMessage(channel, user, msg)
	local log = self.channels[channel].log
	table.insert(log, 1, {user=user, msg=msg})
	while #log > self.max do table.remove(log) end
	self.changed = true
end

function _M:event(e)
	if e.se == "Talk" then
		e.msg = e.msg:removeColorCodes()

		self.channels[e.channel] = self.channels[e.channel] or {users={}, log={}}
		self:addMessage(e.channel, e.user, e.msg)

		if type(game) == "table" and game.log then game.log("#YELLOW#<%s> %s", e.user, e.msg) end
	elseif e.se == "Join" then
		self.channels[e.channel] = self.channels[e.channel] or {users={}, log={}}
		self.channels[e.channel].users[e.user] = true
		self.channels_changed = true
		self:addMessage(e.channel, e.user, "#{italic}##FIREBRICK#has joined the channel#{normal}#")
		if type(game) == "table" and game.log and e.channel == self.cur_channel then game.log("#{italic}##FIREBRICK#%s has joined channel %s (press space to talk).#{normal}#", e.user, e.channel) end
	elseif e.se == "Part" then
		self.channels[e.channel] = self.channels[e.channel] or {users={}, log={}}
		self.channels[e.channel].users[e.user] = nil
		self.channels_changed = true
		self:addMessage(e.channel, e.user, "#{italic}##FIREBRICK#has left the channel#{normal}#")
		if type(game) == "table" and game.log and e.channel == self.cur_channel then game.log("#{italic}##FIREBRICK#%s has left channel %s.#{normal}#", e.user, e.channel) end
	elseif e.se == "UserInfo" then
		local info = e.data:unserialize()
		if not info then return end
	end
end

function _M:join(channel)
	if not profile.auth then return end
	core.profile.pushOrder(string.format("o='ChatJoin' channel=%q", channel))
	self.cur_channel = channel
	self.channels[channel] = self.channels[channel] or {users={}, log={}}
	self.channels_changed = true
	self.changed = true
end

function _M:selectChannel(channel)
	if not self.channels[channel] then return end
	self.cur_channel = channel
	self.channels_changed = true
	self.changed = true
end

function _M:talk(msg)
	if not profile.auth then return end
	if not msg or msg == "" then return end
	msg = msg:removeColorCodes()
	core.profile.pushOrder(string.format("o='ChatTalk' channel=%q msg=%q", self.cur_channel, msg))
end

function _M:getUserInfo(user)
	if not profile.auth then return end
	if not user then return end
	core.profile.pushOrder(string.format("o='ChatUserInfo' user=%q", user))
end

--- Request a line to send
-- TODO: make it better than a simple dialog
function _M:talkBox()
	if not profile.auth then return end
	local d = require("engine.dialogs.GetText").new("Talk", self.cur_channel, 0, 250, function(text)
		self:talk(text)
	end)
	d.key:addBind("EXIT", function() game:unregisterDialog(d) end)
	game:registerDialog(d)
end


----------------------------------------------------------------
-- UI Section
----------------------------------------------------------------

--- Resize the display area
function _M:resize(x, y, w, h, fontname, fontsize, color, bgcolor)
	self.color = color or {255,255,255}
	if type(bgcolor) ~= "string" then
		self.bgcolor = bgcolor or {0,0,0}
	else
		self.bgcolor = {0,0,0}
		self.bg_image = bgcolor
	end
	self.font = core.display.newFont(fontname or "/data/font/Vera.ttf", fontsize or 12)
	self.font_h = self.font:lineSkip()

	self.scroll = 0
	self.changed = true

	self.display_x, self.display_y = math.floor(x), math.floor(y)
	self.w, self.h = math.floor(w), math.floor(h)
	self.fw, self.fh = self.w - 4, self.font:lineSkip()
	self.max_display = math.floor(self.h / self.fh)

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

	local sb, sb_w, sb_h = self:getImage("ui/scrollbar.png")
	local ssb, ssb_w, ssb_h = self:getImage("ui/scrollbar-sel.png")

	self.scrollbar = { bar = {}, sel = {} }
	self.scrollbar.sel.w, self.scrollbar.sel.h, self.scrollbar.sel.tex, self.scrollbar.sel.texw, self.scrollbar.sel.texh = ssb_w, ssb_h, ssb:glTexture()
	local s = core.display.newSurface(sb_w, self.h)
	s:erase(200,0,0)
	for i = 0, self.h do s:merge(sb, 0, i) end
	self.scrollbar.bar.w, self.scrollbar.bar.h, self.scrollbar.bar.tex, self.scrollbar.bar.texw, self.scrollbar.bar.texh = ssb_w, self.h, s:glTexture()

	self.mouse = Mouse.new()
	self.mouse.delegate_offset_x = self.display_x
	self.mouse.delegate_offset_y = self.display_y
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if event == "button" and button == "left" and y <= ls_h then
			local w = 0
			local last_ok = nil
			for i = 1, #self.display_chans do
				local item = self.display_chans[i]
				last_ok = item
				w = w + item.w + 4
				if w > x then break end
			end
			if last_ok then self:selectChannel(last_ok.name) end
		end
	end)
end

function _M:display()
	-- Changed channels list
	if self.channels_changed then
		self.display_chans = {}
		local list = {}
		for name, data in pairs(self.channels) do list[#list+1] = name end
		table.sort(list, function(a,b) if a == "global" then return 1 elseif b == "global" then return nil else return a < b end end)
		for i, name in ipairs(list) do
			local oname = name
			local nb_users = 0
			for _, _ in pairs(self.channels[name].users) do nb_users = nb_users + 1 end
			name = "["..name:capitalize().." ("..nb_users..")]"
			local len = self.font_mono:size(name)

			local s = core.display.newSurface(len + ls_w + rs_w, ls_h)
			s:erase(0, 0, 0, 0)
			if oname == self.cur_channel then
				s:merge(ls, 0, 0)
				for i = ls_w, len + ls_w, ms_w do s:merge(ms, i, 0) end
				s:merge(rs, len + ls_w, 0)
			end
			s:drawColorStringBlended(self.font_mono, name, ls_w, (ls_h - self.font_mono_h) / 2, 0x8d, 0x55, 0xff, oname ~= self.cur_channel, len)
			local item = {name=oname, w=len + ls_w + rs_w, h=ls_h}
			item._tex, item._tex_w, item._tex_h = s:glTexture()
			self.display_chans[#self.display_chans+1] = item
		end
		self.channels_changed = false
	end

	-- If nothing changed, return the same surface as before
	if not self.changed then return end
	self.changed = false

	-- Erase and the display
	self.dlist = {}
	local h = 0
	local log = {}
	if self.channels[self.cur_channel] then log = self.channels[self.cur_channel].log end
	local old_style = self.font:getStyle()
	for z = 1 + self.scroll, #log do
		local stop = false
		local tstr = ("<%s> %s"):format(log[z].user, log[z].msg):toTString()
		local gen = tstring.makeLineTextures(tstr, self.w - 4, self.font_mono)
		for i = #gen, 1, -1 do
			self.dlist[#self.dlist+1] = gen[i]
			h = h + self.fh
			if h > self.h - self.fh - ls_h then stop=true break end
		end
		if stop then break end
	end
	self.font:setStyle(old_style)
	return
end

function _M:toScreen()
	self:display()
	if self.bg_texture then self.bg_texture:toScreenFull(self.display_x, self.display_y, self.w, self.h, self.bg_texture_w, self.bg_texture_h) end
	local h = self.display_y + self.h -  self.fh
	for i = 1, #self.dlist do
		local item = self.dlist[i]
		item._tex:toScreenFull(self.display_x, h, self.fw, self.fh, item._tex_w, item._tex_h)
		h = h - self.fh
	end

	local w = 0
	for i = 1, #self.display_chans do
		local item = self.display_chans[i]
		item._tex:toScreenFull(self.display_x + w, self.display_y, item.w, item.h, item._tex_w, item._tex_h)
		w = w + item.w + 4
	end

	if true then
		local pos = self.scroll * (self.h - self.fh) / (self.max - self.max_display + 1)

		self.scrollbar.bar.tex:toScreenFull(self.display_x + self.w - self.scrollbar.bar.w, self.display_y, self.scrollbar.bar.w, self.scrollbar.bar.h, self.scrollbar.bar.texw, self.scrollbar.bar.texh)
		self.scrollbar.sel.tex:toScreenFull(self.display_x + self.w - self.scrollbar.sel.w, self.display_y + self.h - self.scrollbar.sel.h - pos, self.scrollbar.sel.w, self.scrollbar.sel.h, self.scrollbar.sel.texw, self.scrollbar.sel.texh)
	end
end

--- Scroll the zone
-- @param i number representing how many lines to scroll
function _M:scrollUp(i)
	self.scroll = self.scroll + i
	if self.scroll > #self.log - 1 then self.scroll = #self.log - 1 end
	if self.scroll < 0 then self.scroll = 0 end
	self.changed = true
end
