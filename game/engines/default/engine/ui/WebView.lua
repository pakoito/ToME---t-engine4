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
local Base = require "engine.ui.Base"
local Focusable = require "engine.ui.Focusable"

--- A web browser
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.w = assert(t.width, "no webview width")
	self.h = assert(t.height, "no webview height")
	self.url = assert(t.url, "no webview url")
	self.on_title = t.on_title
	self.allow_downloads = t.allow_downloads or {}
	self.has_frame = t.has_frame
	self.never_clean = t.never_clean
	self.allow_popup = t.allow_popup
	self.allow_login = t.allow_login
	self.custom_calls = t.custom_calls or {}
	if self.allow_login == nil then self.allow_login = true end

	if self.allow_login and self.url:find("^http://te4%.org/") and profile.auth then
		local param = "_te4ah="..profile.auth.hash.."&_te4ad="..profile.auth.drupid

		local first = self.url:find("?", 1, 1)
		if first then self.url = self.url.."&"..param
		else self.url = self.url.."?"..param end
	end

	if self.url:find("^http://te4%.org/")  then
		local param = "_te4"

		local first = self.url:find("?", 1, 1)
		if first then self.url = self.url.."&"..param
		else self.url = self.url.."?"..param end
	end

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	local handlers = {
		on_title = function(title) if self.on_title then self.on_title(title) end end,
		on_popup = function(url, w, h) if self.allow_popup then
			local Dialog = require "engine.ui.Dialog"
			Dialog:webPopup(url, w, h)
		end end,
		on_loading = function(url, status)
			self.loading = status
		end,
		on_crash = function()
			print("WebView crashed, closing C view")
			self.view = nil
		end,
	}
	if self.allow_downloads then self:onDownload(handlers) end
	self.view = core.webview.new(self.w, self.h, handlers)
	if not self.view:usable() then
		self.unusable = true
		return
	end

	self.custom_calls.lolzor = function(nb, str)
		print("call from js got: ", nb, str)
		return "PLAP"
	end

	self.custom_calls._nextDownloadName = function(name)
		if name then self._next_download_name = {name=name, time=os.time()}
		else self._next_download_name = nil
		end
	end

	for name, fct in pairs(self.custom_calls) do 
		handlers[name] = fct
		self.view:setMethod(name)
	end
	self.view:loadURL(self.url)
	self.loading = 0
	self.loading_rotation = 0
	self.scroll_inertia = 0

	if self.has_frame then
		self.frame = Base:makeFrame("ui/tooltip/", self.w + 8, self.h + 8)
	end
	self.loading_icon = self:getUITexture("ui/waiter/loading.png")

	self.mouse:allowDownEvent(true)
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if not self.view then return end
		if event == "button" then
			if button == "wheelup" then self.scroll_inertia = math.min(self.scroll_inertia, 0) - 5
			elseif button == "wheeldown" then self.scroll_inertia = math.max(self.scroll_inertia, 0) + 5
			elseif button == "left" then self.view:injectMouseButton(true, 1)
--			elseif button == "middle" then self.view:injectMouseButton(true, 2)
--			elseif button == "right" then self.view:injectMouseButton(true, 3)
			end				
		elseif event == "button-down" then
			if button == "wheelup" then self.scroll_inertia = math.min(self.scroll_inertia, 0) - 5
			elseif button == "wheeldown" then self.scroll_inertia = math.max(self.scroll_inertia, 0) + 5
			elseif button == "left" then self.view:injectMouseButton(false, 1)
--			elseif button == "middle" then self.view:injectMouseButton(false, 2)
--			elseif button == "right" then self.view:injectMouseButton(false, 3)
			end				
		else
			self.view:injectMouseMove(bx, by)
		end
	end)
	
	if core.webview.kind == "awesomium" then
		function self.key.receiveKey(_, sym, ctrl, shift, alt, meta, unicode, isup, key, ismouse, keysym)
			if not self.view then return end
			local symb = self.key.sym_to_name[sym]
			if not symb then return end
			local asymb = self.awesomiumMapKey[symb]
			if not asymb then return end
			self.view:injectKey(isup, symb, asymb, unicode)
		end
	elseif core.webview.kind == "cef3" then
		function self.key.receiveKey(_, sym, ctrl, shift, alt, meta, unicode, isup, key, ismouse, keysym)
			if not self.view then return end
			if unicode then
				keysym = unicode:sub(1):byte()
				self.view:injectKey(true, keysym, 0, unicode)
				return
			end
			self.view:injectKey(isup, keysym, 0, "")
		end
	end
end

function _M:on_focus(v)
	game:onTickEnd(function() self.key:unicodeInput(v) end)
	if self.view then self.view:focus(v) end
end

function _M:makeDownloadbox(downid, file)
	local Dialog = require "engine.ui.Dialog"
	local Waitbar = require "engine.ui.Waitbar"
	local Button = require "engine.ui.Button"

	local d = Dialog.new("Download: "..file, 600, 100)
	local b = Button.new{text="Cancel", fct=function() self.view:downloadAction(downid, false) game:unregisterDialog(d) end}
	local w = Waitbar.new{size=600, text=file}
	d:loadUI{
		{left=0, top=0, ui=w},
		{right=0, bottom=0, ui=b},
	}
	d:setupUI(true, true)
	function d:updateFill(...) w:updateFill(...) end
	return d
end

function _M:on_dialog_cleanup()
	if not self.never_clean then
		self.downloader = nil
		self.view = nil
	end
end

function _M:onDownload(handlers)
	local Dialog = require "engine.ui.Dialog"

	handlers.on_download_request = function(downid, url, file, mime)
		if mime == "application/t-engine-addon" and self.allow_downloads.addons and url:find("^http://te4%.org/") then
			local path = fs.getRealPath("/addons/")
			if path then
				local name = file
				if self._next_download_name and os.time() - self._next_download_name.time <= 3 then name = self._next_download_name.name self._next_download_name = nil end
				Dialog:yesnoPopup("Confirm addon install/update", "Are you sure you want to install this addon: #LIGHT_GREEN##{bold}#"..name.."#{normal}##LAST# ?", function(ret)
					if ret then
						print("Accepting addon download to:", path..file)
						self.download_dialog = self:makeDownloadbox(downid, file)
						self.download_dialog.install_kind = "Addon"
						game:registerDialog(self.download_dialog)
						self.view:downloadAction(downid, path..file)
					else
						self.view:downloadAction(downid, false)
					end
				end)
				return
			end
		elseif mime == "application/t-engine-module" and self.allow_downloads.modules and url:find("^http://te4%.org/") then
			local path = fs.getRealPath("/modules/")
			if path then
				local name = file
				if self._next_download_name and os.time() - self._next_download_name.time <= 3 then name = self._next_download_name.name self._next_download_name = nil end
				Dialog:yesnoPopup("Confirm module install/update", "Are you sure you want to install this module: #LIGHT_GREEN##{bold}#"..name.."#{normal}##LAST# ?", function(ret)
					if ret then
						print("Accepting module download to:", path..file)
						self.download_dialog = self:makeDownloadbox(downid, file)
						self.download_dialog.install_kind = "Game Module"
						game:registerDialog(self.download_dialog)
						self.view:downloadAction(downid, path..file)
					else
						self.view:downloadAction(downid, false)
					end
				end)
				return
			end
		end
		self.view:downloadAction(downid, false)
	end

	handlers.on_download_update = function(downid, cur_size, total_size, percent, speed)
		if not self.download_dialog then return end
		self.download_dialog:updateFill(cur_size, total_size, ("%d%% - %d KB/s"):format(cur_size * 100 / total_size, speed / 1024))
	end

	handlers.on_download_finish = function(downid)
		if not self.download_dialog then return end
		game:unregisterDialog(self.download_dialog)
		if self.download_dialog.install_kind == "Addon" then
			Dialog:simplePopup("Addon installed!", "Addon installation successful. New addons are only active for new characters.")
		elseif self.download_dialog.install_kind == "Game Module" then
			Dialog:simplePopup("Game installed!", "Game installation successful. Have fun!")
		end
		self.download_dialog = nil
	end
end

function _M:display(x, y, nb_keyframes, screen_x, screen_y, offset_x, offset_y, local_x, local_y)
	if self.scroll_inertia > 0 then self.scroll_inertia = math.max(self.scroll_inertia - 1, 0)
	elseif self.scroll_inertia < 0 then self.scroll_inertia = math.min(self.scroll_inertia + 1, 0)
	end

	if self.frame then
		self:drawFrame(self.frame, x - 4, y - 4, 0, 0, 0, 0.3, self.w, self.h) -- shadow
		self:drawFrame(self.frame, x - 4, y - 4, 1, 1, 1, 0.75) -- unlocked frame
	end

	if self.view then
		if self.scroll_inertia ~= 0 then self.view:injectMouseWheel(0, self.scroll_inertia) end
		self.view:toScreen(x, y)
	end

	if self.loading < 1 then
		self.loading_rotation = self.loading_rotation + nb_keyframes * 8
		core.display.glMatrix(true)
		core.display.glTranslate(x + self.loading_icon.w / 2, y + self.loading_icon.h / 2, 0)
		core.display.glRotate(self.loading_rotation, 0, 0, 1)
		self.loading_icon.t:toScreenFull(-self.loading_icon.w / 2, -self.loading_icon.h / 2, self.loading_icon.w, self.loading_icon.h, self.loading_icon.tw, self.loading_icon.th)
		core.display.glMatrix(false)
	end
end


_M.awesomiumMapKey = {
	-- _BACK (08) BACKSPACE key
	_BACKSPACE = 0x08,

	-- _TAB (09) TAB key
	_TAB = 0x09,

	-- _CLEAR (0C) CLEAR key
	_CLEAR = 0x0C,

	-- _RETURN (0D)
	_RETURN = 0x0D,

	-- _SHIFT (10) SHIFT key
	_SHIFT = 0x10,

	-- _CONTROL (11) CTRL key
	_CONTROL = 0x11,

	-- _MENU (12) ALT key
	_MENU = 0x12,

	-- _PAUSE (13) PAUSE key
	_PAUSE = 0x13,

	-- _CAPITAL (14) CAPS LOCK key
	_CAPITAL = 0x14,

	-- _KANA (15) Input Method Editor (IME) Kana mode
	_KANA = 0x15,

	-- _HANGUEL (15) IME Hanguel mode (maintained for compatibility; use _HANGUL)
	-- _HANGUL (15) IME Hangul mode
	_HANGUL = 0x15,

	-- _JUNJA (17) IME Junja mode
	_JUNJA = 0x17,

	-- _FINAL (18) IME final mode
	_FINAL = 0x18,
    
	-- _HANJA (19) IME Hanja mode
	_HANJA = 0x19,
    
	-- _KANJI (19) IME Kanji mode
	_KANJI = 0x19,
    
	-- _ESCAPE (1B) ESC key
	_ESCAPE = 0x1B,
    
	-- _CONVERT (1C) IME convert
	_CONVERT = 0x1C,
    
	-- _NONCONVERT (1D) IME nonconvert
	_NONCONVERT = 0x1D,
    
	-- _ACCEPT (1E) IME accept
	_ACCEPT = 0x1E,
    
	-- _MODECHANGE (1F) IME mode change request
	_MODECHANGE = 0x1F,
    
	-- _SPACE (20) SPACEBAR
	_SPACE = 0x20,
    
	-- _PRIOR (21) PAGE UP key
	_PRIOR = 0x21,
    
	-- _NEXT (22) PAGE DOWN key
	_NEXT = 0x22,
    
	-- _END (23) END key
	_END = 0x23,
    
	-- _HOME (24) HOME key
	_HOME = 0x24,
    
	-- _LEFT (25) LEFT ARROW key
	_LEFT = 0x25,
    
	-- _UP (26) UP ARROW key
	_UP = 0x26,
    
	-- _RIGHT (27) RIGHT ARROW key
	_RIGHT = 0x27,
    
	-- _DOWN (28) DOWN ARROW key
	_DOWN = 0x28,
    
	-- _SELECT (29) SELECT key
	_SELECT = 0x29,
    
	-- _PRINT (2A) PRINT key
	_PRINT = 0x2A,
    
	-- _EXECUTE (2B) EXECUTE key
	_EXECUTE = 0x2B,
    
	-- _SNAPSHOT (2C) PRINT SCREEN key
	_SNAPSHOT = 0x2C,
    
	-- _INSERT (2D) INS key
	_INSERT = 0x2D,
    
	-- _DELETE (2E) DEL key
	_DELETE = 0x2E,
    
	-- _HELP (2F) HELP key
	_HELP = 0x2F,
    
	-- (30) 0 key
	_0 = 0x30,
    
	-- (31) 1 key
	_1 = 0x31,
    
	-- (32) 2 key
	_2 = 0x32,
    
	-- (33) 3 key
	_3 = 0x33,
    
	-- (34) 4 key
	_4 = 0x34,
    
	-- (35) 5 key;
	_5 = 0x35,
    
	-- (36) 6 key
	_6 = 0x36,
    
	-- (37) 7 key
	_7 = 0x37,
    
	-- (38) 8 key
	_8 = 0x38,
    
	-- (39) 9 key
	_9 = 0x39,
    
	-- (41) A key
	_a = 0x41,
    
	-- (42) b key
	_b = 0x42,
    
	-- (43) c key
	_c = 0x43,
    
	-- (44) d key
	_d = 0x44,
    
	-- (45) e key
	_e = 0x45,
    
	-- (46) f key
	_f = 0x46,
    
	-- (47) g key
	_g = 0x47,
    
	-- (48) h key
	_h = 0x48,
    
	-- (49) i key
	_i = 0x49,
    
	-- (4a) j key
	_j = 0x4a,
    
	-- (4b) k key
	_k = 0x4b,
    
	-- (4c) l key
	_l = 0x4c,
    
	-- (4d) m key
	_m = 0x4d,
    
	-- (4e) n key
	_n = 0x4e,
    
	-- (4f) o key
	_o = 0x4f,
    
	-- (50) p key
	_p = 0x50,
    
	-- (51) q key
	_q = 0x51,
    
	-- (52) r key
	_r = 0x52,
    
	-- (53) s key
	_s = 0x53,
    
	-- (54) t key
	_t = 0x54,
    
	-- (55) u key
	_u = 0x55,
    
	-- (56) v key
	_v = 0x56,
    
	-- (57) w key
	_w = 0x57,
    
	-- (58) x key
	_x = 0x58,
    
	-- (59) y key
	_y = 0x59,
    
	-- (5a) z key
	_z = 0x5a,
    
	-- _LWIN (5B) Left Windows key (Microsoft Natural keyboard)
	_LWIN = 0x5B,
    
	-- _RWIN (5C) Right Windows key (Natural keyboard)
	_RWIN = 0x5C,
    
	-- _APPS (5D) Applications key (Natural keyboard)
	_APPS = 0x5D,
    
	-- _SLEEP (5F) Computer Sleep key
	_SLEEP = 0x5F,
    
	-- _NUMPAD0 (60) Numeric keypad 0 key
	_NUMPAD0 = 0x60,
    
	-- _NUMPAD1 (61) Numeric keypad 1 key
	_NUMPAD1 = 0x61,
    
	-- _NUMPAD2 (62) Numeric keypad 2 key
	_NUMPAD2 = 0x62,
    
	-- _NUMPAD3 (63) Numeric keypad 3 key
	_NUMPAD3 = 0x63,
    
	-- _NUMPAD4 (64) Numeric keypad 4 key
	_NUMPAD4 = 0x64,
    
	-- _NUMPAD5 (65) Numeric keypad 5 key
	_NUMPAD5 = 0x65,
    
	-- _NUMPAD6 (66) Numeric keypad 6 key
	_NUMPAD6 = 0x66,
    
	-- _NUMPAD7 (67) Numeric keypad 7 key
	_NUMPAD7 = 0x67,
    
	-- _NUMPAD8 (68) Numeric keypad 8 key
	_NUMPAD8 = 0x68,
    
	-- _NUMPAD9 (69) Numeric keypad 9 key
	_NUMPAD9 = 0x69,
    
	-- _MULTIPLY (6A) Multiply key
	_MULTIPLY = 0x6A,
    
	-- _ADD (6B) Add key
	_ADD = 0x6B,
    
	-- _SEPARATOR (6C) Separator key
	_SEPARATOR = 0x6C,
    
	-- _SUBTRACT (6D) Subtract key
	_SUBTRACT = 0x6D,
    
	-- _DECIMAL (6E) Decimal key
	_DECIMAL = 0x6E,
    
	-- _DIVIDE (6F) Divide key
	_DIVIDE = 0x6F,
    
	-- _F1 (70) F1 key
	_F1 = 0x70,
    
	-- _F2 (71) F2 key
	_F2 = 0x71,
    
	-- _F3 (72) F3 key
	_F3 = 0x72,
    
	-- _F4 (73) F4 key
	_F4 = 0x73,
    
	-- _F5 (74) F5 key
	_F5 = 0x74,
    
	-- _F6 (75) F6 key
	_F6 = 0x75,
    
	-- _F7 (76) F7 key
	_F7 = 0x76,
    
	-- _F8 (77) F8 key
	_F8 = 0x77,
    
	-- _F9 (78) F9 key
	_F9 = 0x78,
    
	-- _F10 (79) F10 key
	_F10 = 0x79,
    
	-- _F11 (7A) F11 key
	_F11 = 0x7A,
    
	-- _F12 (7B) F12 key
	_F12 = 0x7B,
    
	-- _F13 (7C) F13 key
	_F13 = 0x7C,
    
	-- _F14 (7D) F14 key
	_F14 = 0x7D,
    
	-- _F15 (7E) F15 key
	_F15 = 0x7E,
    
	-- _F16 (7F) F16 key
	_F16 = 0x7F,
    
	-- _F17 (80H) F17 key
	_F17 = 0x80,
    
	-- _F18 (81H) F18 key
	_F18 = 0x81,
    
	-- _F19 (82H) F19 key
	_F19 = 0x82,
    
	-- _F20 (83H) F20 key
	_F20 = 0x83,
    
	-- _F21 (84H) F21 key
	_F21 = 0x84,
    
	-- _F22 (85H) F22 key
	_F22 = 0x85,
    
	-- _F23 (86H) F23 key
	_F23 = 0x86,
    
	-- _F24 (87H) F24 key
	_F24 = 0x87,
    
	-- _NUMLOCK (90) NUM LOCK key
	_NUMLOCK = 0x90,
    
	-- _SCROLL (91) SCROLL LOCK key
	_SCROLL = 0x91,
    
	-- _LSHIFT (A0) Left SHIFT key
	_LSHIFT = 0xA0,
    
	-- _RSHIFT (A1) Right SHIFT key
	_RSHIFT = 0xA1,
    
	-- _LCONTROL (A2) Left CONTROL key
	_LCONTROL = 0xA2,
    
	-- _RCONTROL (A3) Right CONTROL key
	_RCONTROL = 0xA3,
    
	-- _LMENU (A4) Left MENU key
	_LMENU = 0xA4,
    
	-- _RMENU (A5) Right MENU key
	_RMENU = 0xA5,
    
	-- _BROWSER_BACK (A6) Windows 2000/XP: Browser Back key
	_BROWSER_BACK = 0xA6,
    
	-- _BROWSER_FORWARD (A7) Windows 2000/XP: Browser Forward key
	_BROWSER_FORWARD = 0xA7,
    
	-- _BROWSER_REFRESH (A8) Windows 2000/XP: Browser Refresh key
	_BROWSER_REFRESH = 0xA8,
    
	-- _BROWSER_STOP (A9) Windows 2000/XP: Browser Stop key
	_BROWSER_STOP = 0xA9,
    
	-- _BROWSER_SEARCH (AA) Windows 2000/XP: Browser Search key
	_BROWSER_SEARCH = 0xAA,
    
	-- _BROWSER_FAVORITES (AB) Windows 2000/XP: Browser Favorites key
	_BROWSER_FAVORITES = 0xAB,
    
	-- _BROWSER_HOME (AC) Windows 2000/XP: Browser Start and Home key
	_BROWSER_HOME = 0xAC,
    
	-- _VOLUME_MUTE (AD) Windows 2000/XP: Volume Mute key
	_VOLUME_MUTE = 0xAD,
    
	-- _VOLUME_DOWN (AE) Windows 2000/XP: Volume Down key
	_VOLUME_DOWN = 0xAE,
    
	-- _VOLUME_UP (AF) Windows 2000/XP: Volume Up key
	_VOLUME_UP = 0xAF,
    
	-- _MEDIA_NEXT_TRACK (B0) Windows 2000/XP: Next Track key
	_MEDIA_NEXT_TRACK = 0xB0,
    
	-- _MEDIA_PREV_TRACK (B1) Windows 2000/XP: Previous Track key
	_MEDIA_PREV_TRACK = 0xB1,
    
	-- _MEDIA_STOP (B2) Windows 2000/XP: Stop Media key
	_MEDIA_STOP = 0xB2,
    
	-- _MEDIA_PLAY_PAUSE (B3) Windows 2000/XP: Play/Pause Media key
	_MEDIA_PLAY_PAUSE = 0xB3,
    
	-- _LAUNCH_MAIL (B4) Windows 2000/XP: Start Mail key
	_MEDIA_LAUNCH_MAIL = 0xB4,
    
	-- _LAUNCH_MEDIA_SELECT (B5) Windows 2000/XP: Select Media key
	_MEDIA_LAUNCH_MEDIA_SELECT = 0xB5,
    
	-- _LAUNCH_APP1 (B6) Windows 2000/XP: Start Application 1 key
	_MEDIA_LAUNCH_APP1 = 0xB6,
    
	-- _LAUNCH_APP2 (B7) Windows 2000/XP: Start Application 2 key
	_MEDIA_LAUNCH_APP2 = 0xB7,
    
	-- _OEM_1 (BA) Used for miscellaneous characters; it can vary by keyboard. Windows 2000/XP: For the US standard keyboard, the ';:' key
	_OEM_1 = 0xBA,
    
	-- _OEM_PLUS (BB) Windows 2000/XP: For any country/region, the '+' key
	_OEM_PLUS = 0xBB,
    
	-- _OEM_COMMA (BC) Windows 2000/XP: For any country/region, the ',' key
	_OEM_COMMA = 0xBC,
    
	-- _OEM_MINUS (BD) Windows 2000/XP: For any country/region, the '-' key
	_OEM_MINUS = 0xBD,
    
	-- _OEM_PERIOD (BE) Windows 2000/XP: For any country/region, the '.' key
	_OEM_PERIOD = 0xBE,
    
	-- _OEM_2 (BF) Used for miscellaneous characters; it can vary by keyboard. Windows 2000/XP: For the US standard keyboard, the '/?' key
	_OEM_2 = 0xBF,
    
	-- _OEM_3 (C0) Used for miscellaneous characters; it can vary by keyboard. Windows 2000/XP: For the US standard keyboard, the '`~' key
	_OEM_3 = 0xC0,
    
	-- _OEM_4 (DB) Used for miscellaneous characters; it can vary by keyboard. Windows 2000/XP: For the US standard keyboard, the '[{' key
	_OEM_4 = 0xDB,
    
	-- _OEM_5 (DC) Used for miscellaneous characters; it can vary by keyboard. Windows 2000/XP: For the US standard keyboard, the '\|' key
	_OEM_5 = 0xDC,
    
	-- _OEM_6 (DD) Used for miscellaneous characters; it can vary by keyboard. Windows 2000/XP: For the US standard keyboard, the ']}' key
	_OEM_6 = 0xDD,
    
	-- _OEM_7 (DE) Used for miscellaneous characters; it can vary by keyboard. Windows 2000/XP: For the US standard keyboard, the 'single-quote/double-quote' key
	_OEM_7 = 0xDE,
    
	-- _OEM_8 (DF) Used for miscellaneous characters; it can vary by keyboard.
	_OEM_8 = 0xDF,
    
	-- _OEM_102 (E2) Windows 2000/XP: Either the angle bracket key or the backslash key on the RT 102-key keyboard
	_OEM_102 = 0xE2,
    
	-- _PROCESSKEY (E5) Windows 95/98/Me, Windows NT 4.0, Windows 2000/XP: IME PROCESS key
	_PROCESSKEY = 0xE5,
    
	-- _PACKET (E7) Windows 2000/XP: Used to pass Unicode characters as if they were keystrokes. The _PACKET key is the low word of a 32-bit Virtual Key value used for non-keyboard input methods. For more information, see Remark in KEYBDINPUT,SendInput, WM_KEYDOWN, and WM_KEYUP
	_PACKET = 0xE7,
    
	-- _ATTN (F6) Attn key
	_ATTN = 0xF6,
    
	-- _CRSEL (F7) CrSel key
	_CRSEL = 0xF7,
    
	-- _EXSEL (F8) ExSel key
	_EXSEL = 0xF8,
    
	-- _EREOF (F9) Erase EOF key
	_EREOF = 0xF9,
    
	-- _PLAY (FA) Play key
	_PLAY = 0xFA,
    
	-- _ZOOM (FB) Zoom key
	_ZOOM = 0xFB,

	-- _NONAME (FC) Reserved for future use
	_NONAME = 0xFC,
    
	-- _PA1 (FD) PA1 key
	_PA1 = 0xFD,
    
	-- _OEM_CLEAR (FE) Clear key
	_OEM_CLEAR = 0xFE,
    
	_UNKNOWN = 0,
}