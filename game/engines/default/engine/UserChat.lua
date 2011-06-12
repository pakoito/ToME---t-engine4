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
local KeyBind = require "engine.KeyBind"
local Mouse = require "engine.Mouse"
local Dialog = require "engine.ui.Dialog"
local Slider = require "engine.ui.Slider"
local Base = require "engine.ui.Base"

--- Module that handles multiplayer chats
module(..., package.seeall, class.inherit(Base))

--- Creates the log zone
function _M:init()
	self.changed = true
	self.channels_changed = true
	self.cur_channel = "global"
	self.channels = {}
	self.max = 500
end

--- Hook up in the current running game
function _M:setupOnGame()
	KeyBind:load("chat")
	_G.game.key:bindKeys() -- Make sure it updates

	_G.game.key:addBinds{
		USERCHAT_TALK = function()
			self:talkBox()
		end,
		USERCHAT_SWITCH_CHANNEL = function()
			if not self.display_chans then return end
			for i = 1, #self.display_chans do
				if self.display_chans[i].name == self.cur_channel then
					self:selectChannel(self.display_chans[util.boundWrap(i + 1, 1, #self.display_chans)].name)
					if game.logChat then game.logChat("Talking in channel: %s", self.cur_channel) end
					break
				end
			end
		end,
	}

	local ok, UC = pcall(require, "mod.class.UserChatExtension")
	if ok and UC then self.uc_ext = UC.new(self) end
end

function _M:addMessage(channel, login, name, msg, extra_data, no_change)
	local log = self.channels[channel].log
	table.insert(log, 1, {login=login, name=name, msg=msg, extra_data=extra_data})
	while #log > self.max do table.remove(log) end
	self.changed = true
	if not no_change and channel ~= self.cur_channel then self.channels[channel].changed = true self.channels_changed = true end
end

function _M:event(e)
	if e.se == "Talk" then
		e.msg = e.msg:removeColorCodes()

		self.channels[e.channel] = self.channels[e.channel] or {users={}, log={}}
		self:addMessage(e.channel, e.login, e.name, e.msg)

		if type(game) == "table" and game.logChat and self.cur_channel == e.channel then
			game.logChat("#YELLOW#<%s> %s", e.name, e.msg)
		end
	elseif e.se == "Whisper" then
		e.msg = e.msg:removeColorCodes()

		self.channels[self.cur_channel] = self.channels[self.cur_channel] or {users={}, log={}}
		self:addMessage(self.cur_channel, e.login, e.name, "#GOLD#<whisper>#LAST#"..e.msg)

		if type(game) == "table" and game.logChat then
			game.logChat("#GOLD#<Whisper from %s> %s", e.name, e.msg)
		end
	elseif e.se == "Achievement" then
		e.msg = e.msg:removeColorCodes()

		self.channels[e.channel] = self.channels[e.channel] or {users={}, log={}}
		self:addMessage(e.channel, e.login, e.name, "#{italic}##LIGHT_BLUE#has earned the achievement <"..e.msg..">#{normal}#", nil, true)

		if type(game) == "table" and game.logChat and self.cur_channel == e.channel then
			game.logChat("#LIGHT_BLUE#%s has earned the achievement <%s>", e.name, e.msg)
		end
	elseif e.se == "SerialData" then
		self.channels[e.channel] = self.channels[e.channel] or {users={}, log={}}
		if self.uc_ext then
			self.uc_ext:event(e)
		end
	elseif e.se == "Join" then
		self.channels[e.channel] = self.channels[e.channel] or {users={}, log={}}
		self.channels[e.channel].users[e.login] = {name=e.name, login=e.login}
		self.channels_changed = true
		self:addMessage(e.channel, e.login, e.name, "#{italic}##FIREBRICK#has joined the channel#{normal}#", nil, true)
		if type(game) == "table" and game.logChat and e.channel == self.cur_channel then
			game.logChat("#{italic}##FIREBRICK#%s has joined channel %s (press space to talk).#{normal}#", e.login, e.channel)
		end
		self:updateChanList()
	elseif e.se == "Part" then
		self.channels[e.channel] = self.channels[e.channel] or {users={}, log={}}
		self.channels[e.channel].users[e.login] = nil
		self.channels_changed = true
		self:addMessage(e.channel, e.login, e.name, "#{italic}##FIREBRICK#has left the channel#{normal}#", nil, true)
		if type(game) == "table" and game.logChat and e.channel == self.cur_channel then
			game.logChat("#{italic}##FIREBRICK#%s has left channel %s.#{normal}#", e.login, e.channel)
		end
		self:updateChanList()
	elseif e.se == "UserInfo" then
		local info = e.data:unserialize()
		if not info then return end
	elseif e.se == "ChannelList" then
		local info = zlib.decompress(e.data):unserialize()
		if not info then return end
		if not e.channel or not self.channels[e.channel] then return end
		self.channels[e.channel].users = {}
		for _, user in ipairs(info.users) do
			self.channels[e.channel].users[user.login] = {
				login=user.login,
				name=user.name,
				current_char=user.current_char and user.current_char.title or "unknown",
				module=user.current_char and user.current_char.module or "unknown",
				valid=user.current_char and user.current_char.valid and "validate" or "not validated",
			}
		end
		self.channels_changed = true
	end
end

function _M:join(channel)
	if not profile.auth then return end
	core.profile.pushOrder(string.format("o='ChatJoin' channel=%q", channel))
	self.cur_channel = channel
	self.channels[channel] = self.channels[channel] or {users={}, log={}}
	self.channels_changed = true
	self.changed = true
	self:updateChanList(true)
end

function _M:selectChannel(channel)
	if not self.channels[channel] then return end
	self.channels[channel].changed = false
	self.cur_channel = channel
	self.channels_changed = true
	self.changed = true
	self.scroll = 0
	self:updateChanList(true)
end

function _M:talk(msg)
	if not profile.auth then return end
	if not msg or msg == "" then return end
	msg = msg:removeColorCodes()
	core.profile.pushOrder(string.format("o='ChatTalk' channel=%q msg=%q", self.cur_channel, msg))
end

function _M:whisper(to, msg)
	if not profile.auth then return end
	if not to or not msg or msg == "" then return end
	msg = msg:removeColorCodes()
	core.profile.pushOrder(string.format("o='ChatWhisper' target=%q msg=%q", to, msg))
end

function _M:achievement(name)
	if not profile.auth then return end
	core.profile.pushOrder(string.format("o='ChatAchievement' channel=%q msg=%q", self.cur_channel, name))
end

--- Request a line to send
function _M:talkBox()
	if not profile.auth then return end
	local Talkbox = require "engine.dialogs.Talkbox"
	local d = Talkbox.new(self)
	game:registerDialog(d)

	self:updateChanList()
end

--- Sets the current talk target, channel or whisper
function _M:setCurrentTarget(channel, name)
	if channel and not self.channels[name] then return end
	self.cur_target = {channel and "channel" or "whisper", name}
	if channel then self:selectChannel(name) end
end

--- Gets the current talk target, channel or whisper
function _M:getCurrentTarget()
	if not self.cur_target then return "channel", self.cur_channel end
	return self.cur_target[1], self.cur_target[2]
end

function _M:findChannel(name)
	for cname, data in pairs(self.channels) do
		if cname:lower() == name:lower() then return cname end
	end
end

function _M:findUser(name)
	for login, data in pairs(self.channels[self.cur_channel].users) do
		if data.name:lower() == name:lower() then return data.name end
	end
end

function _M:updateChanList(force)
	local time = os.time()
	if force or not self.last_chan_update or self.last_chan_update + 60 < time then
		self.last_chan_update = time
		core.profile.pushOrder(string.format("o='ChatChannelList' channel=%q", self.cur_channel))
	end
end

--- Display user infos
function _M:showUserInfo(login)
	if not profile.auth then return end

	local popup = Dialog:simplePopup("Requesting...", "Requesting user info...", nil, true)
	popup.__showup = nil
	core.display.forceRedraw()

	core.profile.pushOrder(string.format("o='ChatUserInfo' login=%q", login))
	local data = nil
	profile:waitEvent("UserInfo", function(e) data=e.data end, 5000)
	game:unregisterDialog(popup)

	if not data then
		Dialog:simplePopup("Error", "The server does not know about this player.")
		return
	end
	data = zlib.decompress(data):unserialize()

	local UserInfo = require "engine.dialogs.UserInfo"
	game:registerDialog(UserInfo.new(data))
end

----------------------------------------------------------------
-- UI Section
----------------------------------------------------------------

--- Make a dialog popup with the full log
function _M:showLogDialog(title, shadow)
	local log = {}
	if self.channels[self.cur_channel] then
		for _, i in ipairs(self.channels[self.cur_channel].log) do
			log[#log+1] = ("<%s> %s"):format(i.name, i.msg)
		end
	end
	local d = require("engine.dialogs.ShowLog").new(title or "Chat Log", shadow, {log=log})
	game:registerDialog(d)
end

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

	self.frame_sel = self:makeFrame("ui/selector-sel", 1, 5 + self.font_h)
	self.frame = self:makeFrame("ui/selector", 1, 5 + self.font_h)

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

	self.scrollbar = Slider.new{size=self.h - 20, max=1, inverse=true}

	self.mouse = Mouse.new()
	self.mouse.delegate_offset_x = self.display_x
	self.mouse.delegate_offset_y = self.display_y
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if button == "wheelup" then self:scrollUp(1)
		elseif button == "wheeldown" then self:scrollUp(-1)
		elseif event == "button" and button == "left" and y <= self.frame.h then
			local w = 0
			local last_ok = nil
			for i = 1, #self.display_chans do
				local item = self.display_chans[i]
				last_ok = item
				w = w + item.w + 4
				if w > x then break end
			end
			if last_ok then
				local old = self.cur_channel
				self:selectChannel(last_ok.name)
				if old == self.cur_channel then self:showLogDialog(nil, self.shadow) end
			end
		else
			if not self.on_mouse or not self.dlist then return end
			local citem = nil
			for i = 1, #self.dlist do
				local item = self.dlist[i]
				if item.dh and y >= item.dh - self.mouse.delegate_offset_y then citem = item break end
			end
			if citem and citem.login and self.channels[self.cur_channel].users[citem.login] then
				self.on_mouse(self.channels[self.cur_channel].users[citem.login], citem, button, event)
			end
		end
	end)

	self.last_chan_update = 0
end

function _M:enableShadow(v)
	self.shadow = v
end

function _M:onMouse(fct)
	self.on_mouse = fct
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
			local len, lenh = self.font_mono:size(name)

			local s = core.display.newSurface(len + self.frame.b4.w + self.frame.b6.w, self.frame.h)
			s:drawColorStringBlended(self.font_mono, name, self.frame.b4.w, (self.frame.h - self.font_h) / 2, 0xFF, 0xFF, 0xFF, true, len)
			local item = {name=oname, w=len + self.frame.b4.w + self.frame.b6.w, h=self.frame.h, sel=oname == self.cur_channel}
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
		local tstr = ("<%s> %s"):format(log[z].name, log[z].msg):toTString()
		local gen = tstring.makeLineTextures(tstr, self.w, self.font_mono)
		for i = #gen, 1, -1 do
			gen[i].login = log[z].login
			gen[i].extra_data = log[z].extra_data
			self.dlist[#self.dlist+1] = gen[i]
			h = h + self.fh
			if h > self.h - self.fh - self.fh then stop=true break end
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
		item.dh = h
		if self.shadow then item._tex:toScreenFull(self.display_x+2, h+2, item.w, item.h, item._tex_w, item._tex_h, 0,0,0, self.shadow) end
		item._tex:toScreenFull(self.display_x, h, item.w, item.h, item._tex_w, item._tex_h)
		h = h - self.fh
	end

	local w = 0
	for i = 1, #self.display_chans do
		local item = self.display_chans[i]
		local f = item.sel and self.frame_sel or self.frame
		f.w = item.w

		Base:drawFrame(f, self.display_x + w, self.display_y)
		if self.channels[item.name].changed then
			local glow = (1+math.sin(core.game.getTime() / 500)) / 2 * 100 + 120
			Base:drawFrame(f, self.display_x + w, self.display_y, 139/255, 210/255, 77/255, glow / 255)
		end
		item._tex:toScreenFull(self.display_x + w, self.display_y, item.w, item.h, item._tex_w, item._tex_h)
		w = w + item.w + 4
	end

	if true then
		self.scrollbar.pos = self.scroll
		self.scrollbar.max = self.max - self.max_display + 1
		self.scrollbar:display(self.display_x + self.w - self.scrollbar.w, self.display_y)
	end
end

--- Scroll the zone
-- @param i number representing how many lines to scroll
function _M:scrollUp(i)
	local log = {}
	if self.channels[self.cur_channel] then log = self.channels[self.cur_channel].log end
	self.scroll = self.scroll + i
	if self.scroll > #log - 1 then self.scroll = #log - 1 end
	if self.scroll < 0 then self.scroll = 0 end
	self.changed = true
end
