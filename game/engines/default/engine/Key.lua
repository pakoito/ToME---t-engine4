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

--- Basic keypress handler
-- The engine calls receiveKey when a key is pressed
module(..., package.seeall, class.make)

function _M:init()
	self.status = {}
end

--- Called when a key is pressed
-- @param sym a number representing the key, see all the _FOO fields
-- @param ctrl is the control key pressed?
-- @param shift is the shit key pressed?
-- @param alt is the alt key pressed?
-- @param meta is the meta key pressed?
-- @param unicode the unicode representation of the key, if possible
-- @param isup true if the key was released, false if pressed
-- @param key the unicode representation of the key pressed (without accounting for modifiers)
function _M:receiveKey(sym, ctrl, shift, alt, meta, unicode, isup, key)
	print(sym, ctrl, shift, alt, meta, unicode, isup)
	self:handleStatus(sym, ctrl, shift, alt, meta, unicode, isup)
end

--- Maintain the self.status table, which can be used to know if a key is currently pressed
function _M:handleStatus(sym, ctrl, shift, alt, meta, unicode, isup)
	self.status[sym] = not isup
end

--- Setups as the current game keyhandler
function _M:setCurrent()
	core.key.set_current_handler(self)
--	if game then game.key = self end
	_M.current = self
end

_UNKNOWN = 0
_a = 4
_b = 5
_c = 6
_d = 7
_e = 8
_f = 9
_g = 10
_h = 11
_i = 12
_j = 13
_k = 14
_l = 15
_m = 16
_n = 17
_o = 18
_p = 19
_q = 20
_r = 21
_s = 22
_t = 23
_u = 24
_v = 25
_w = 26
_x = 27
_y = 28
_z = 29

_1 = 30
_2 = 31
_3 = 32
_4 = 33
_5 = 34
_6 = 35
_7 = 36
_8 = 37
_9 = 38
_0 = 39

_RETURN = 40
_ESCAPE = 41
_BACKSPACE = 42
_TAB = 43
_SPACE = 44

_MINUS = 45
_EQUALS = 46
_LEFTBRACKET = 47
_RIGHTBRACKET = 48
_BACKSLASH = 49
_NONUSHASH = 50
_SEMICOLON = 51
_APOSTROPHE = 52
_GRAVE = 53
_COMMA = 54
_PERIOD = 55
_SLASH = 56

_CAPSLOCK = 57

_F1 = 58
_F2 = 59
_F3 = 60
_F4 = 61
_F5 = 62
_F6 = 63
_F7 = 64
_F8 = 65
_F9 = 66
_F10 = 67
_F11 = 68
_F12 = 69

_PRINTSCREEN = 70
_SCROLLLOCK = 71
_PAUSE = 72
_INSERT = 73
_HOME = 74
_PAGEUP = 75
_DELETE = 76
_END = 77
_PAGEDOWN = 78
_RIGHT = 79
_LEFT = 80
_DOWN = 81
_UP = 82

_NUMLOCKCLEAR = 83
_KP_DIVIDE = 84
_KP_MULTIPLY = 85
_KP_MINUS = 86
_KP_PLUS = 87
_KP_ENTER = 88
_KP_1 = 89
_KP_2 = 90
_KP_3 = 91
_KP_4 = 92
_KP_5 = 93
_KP_6 = 94
_KP_7 = 95
_KP_8 = 96
_KP_9 = 97
_KP_0 = 98
_KP_PERIOD = 99

_NONUSBACKSLASH = 100
_APPLICATION = 101
_POWER = 102
_KP_EQUALS = 103
_F13 = 104
_F14 = 105
_F15 = 106
_F16 = 107
_F17 = 108
_F18 = 109
_F19 = 110
_F20 = 111
_F21 = 112
_F22 = 113
_F23 = 114
_F24 = 115
_EXECUTE = 116
_HELP = 117
_MENU = 118
_SELECT = 119
_STOP = 120
_AGAIN = 121
_UNDO = 122
_CUT = 123
_COPY = 124
_PASTE = 125
_FIND = 126
_MUTE = 127
_VOLUMEUP = 128
_VOLUMEDOWN = 129
_KP_COMMA = 133
_KP_EQUALSAS400 = 134

_INTERNATIONAL1 = 135
_INTERNATIONAL2 = 136
_INTERNATIONAL3 = 137
_INTERNATIONAL4 = 138
_INTERNATIONAL5 = 139
_INTERNATIONAL6 = 140
_INTERNATIONAL7 = 141
_INTERNATIONAL8 = 142
_INTERNATIONAL9 = 143
_LANG1 = 144
_LANG2 = 145
_LANG3 = 146
_LANG4 = 147
_LANG5 = 148
_LANG6 = 149
_LANG7 = 150
_LANG8 = 151
_LANG9 = 152

_ALTERASE = 153
_SYSREQ = 154
_CANCEL = 155
_CLEAR = 156
_PRIOR = 157
_RETURN2 = 158
_SEPARATOR = 159
_OUT = 160
_OPER = 161
_CLEARAGAIN = 162
_CRSEL = 163
_EXSEL = 164

_KP_00 = 176
_KP_000 = 177
_THOUSANDSSEPARATOR = 178
_DECIMALSEPARATOR = 179
_CURRENCYUNIT = 180
_CURRENCYSUBUNIT = 181
_KP_LEFTPAREN = 182
_KP_RIGHTPAREN = 183
_KP_LEFTBRACE = 184
_KP_RIGHTBRACE = 185
_KP_TAB = 186
_KP_BACKSPACE = 187
_KP_A = 188
_KP_B = 189
_KP_C = 190
_KP_D = 191
_KP_E = 192
_KP_F = 193
_KP_XOR = 194
_KP_POWER = 195
_KP_PERCENT = 196
_KP_LESS = 197
_KP_GREATER = 198
_KP_AMPERSAND = 199
_KP_DBLAMPERSAND = 200
_KP_VERTICALBAR = 201
_KP_DBLVERTICALBAR = 202
_KP_COLON = 203
_KP_HASH = 204
_KP_SPACE = 205
_KP_AT = 206
_KP_EXCLAM = 207
_KP_MEMSTORE = 208
_KP_MEMRECALL = 209
_KP_MEMCLEAR = 210
_KP_MEMADD = 211
_KP_MEMSUBTRACT = 212
_KP_MEMMULTIPLY = 213
_KP_MEMDIVIDE = 214
_KP_PLUSMINUS = 215
_KP_CLEAR = 216
_KP_CLEARENTRY = 217
_KP_BINARY = 218
_KP_OCTAL = 219
_KP_DECIMAL = 220
_KP_HEXADECIMAL = 221

_LCTRL = 224
_LSHIFT = 225
_LALT = 226
_LGUI = 227
_RCTRL = 228
_RSHIFT = 229
_RALT = 230
_RGUI = 231
_MODE = 257
_AUDIONEXT = 258
_AUDIOPREV = 259
_AUDIOSTOP = 260
_AUDIOPLAY = 261
_AUDIOMUTE = 262
_MEDIASELECT = 263
_WWW = 264
_MAIL = 265
_CALCULATOR = 266
_COMPUTER = 267
_AC_SEARCH = 268
_AC_HOME = 269
_AC_BACK = 270
_AC_FORWARD = 271
_AC_STOP = 272
_AC_REFRESH = 273
_AC_BOOKMARKS = 274
_BRIGHTNESSDOWN = 275
_BRIGHTNESSUP = 276
_DISPLAYSWITCH = 277
_KBDILLUMTOGGLE = 278
_KBDILLUMDOWN = 279
_KBDILLUMUP = 280
_EJECT = 281
_SLEEP = 282

__DEFAULT 	= -10000
__TEXTINPUT 	= -10001

-- Reverse sym calc
_M.sym_to_name = {}
for k, e in pairs(_M) do
	if type(k) == "string" and type(e) == "number" then
		_M.sym_to_name[e] = k
	end
end
