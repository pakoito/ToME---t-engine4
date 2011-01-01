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
function _M:receiveKey(sym, ctrl, shift, alt, meta, unicode, isup)
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

_UNKNOWN		= 0
_FIRST		= 0
_BACKSPACE		= 8
_TAB		= 9
_CLEAR		= 12
_RETURN		= 13
_PAUSE		= 19
_ESCAPE		= 27
_SPACE		= 32
_EXCLAIM		= 33
_QUOTEDBL		= 34
_HASH		= 35
_DOLLAR		= 36
_AMPERSAND		= 38
_QUOTE		= 39
_LEFTPAREN		= 40
_RIGHTPAREN		= 41
_ASTERISK		= 42
_PLUS		= 43
_COMMA		= 44
_MINUS		= 45
_PERIOD		= 46
_SLASH		= 47
_0			= 48
_1			= 49
_2			= 50
_3			= 51
_4			= 52
_5			= 53
_6			= 54
_7			= 55
_8			= 56
_9			= 57
_COLON		= 58
_SEMICOLON		= 59
_LESS		= 60
_EQUALS		= 61
_GREATER		= 62
_QUESTION		= 63
_AT			= 64

_LEFTBRACKET	= 91
_BACKSLASH		= 92
_RIGHTBRACKET	= 93
_CARET		= 94
_UNDERSCORE		= 95
_BACKQUOTE		= 96
_a			= 97
_b			= 98
_c			= 99
_d			= 100
_e			= 101
_f			= 102
_g			= 103
_h			= 104
_i			= 105
_j			= 106
_k			= 107
_l			= 108
_m			= 109
_n			= 110
_o			= 111
_p			= 112
_q			= 113
_r			= 114
_s			= 115
_t			= 116
_u			= 117
_v			= 118
_w			= 119
_x			= 120
_y			= 121
_z			= 122
_DELETE		= 127
-- End of ASCII mapped keysyms

-- International keyboard syms
_WORLD_0		= 160		-- 0xA0
_WORLD_1		= 161
_WORLD_2		= 162
_WORLD_3		= 163
_WORLD_4		= 164
_WORLD_5		= 165
_WORLD_6		= 166
_WORLD_7		= 167
_WORLD_8		= 168
_WORLD_9		= 169
_WORLD_10		= 170
_WORLD_11		= 171
_WORLD_12		= 172
_WORLD_13		= 173
_WORLD_14		= 174
_WORLD_15		= 175
_WORLD_16		= 176
_WORLD_17		= 177
_WORLD_18		= 178
_WORLD_19		= 179
_WORLD_20		= 180
_WORLD_21		= 181
_WORLD_22		= 182
_WORLD_23		= 183
_WORLD_24		= 184
_WORLD_25		= 185
_WORLD_26		= 186
_WORLD_27		= 187
_WORLD_28		= 188
_WORLD_29		= 189
_WORLD_30		= 190
_WORLD_31		= 191
_WORLD_32		= 192
_WORLD_33		= 193
_WORLD_34		= 194
_WORLD_35		= 195
_WORLD_36		= 196
_WORLD_37		= 197
_WORLD_38		= 198
_WORLD_39		= 199
_WORLD_40		= 200
_WORLD_41		= 201
_WORLD_42		= 202
_WORLD_43		= 203
_WORLD_44		= 204
_WORLD_45		= 205
_WORLD_46		= 206
_WORLD_47		= 207
_WORLD_48		= 208
_WORLD_49		= 209
_WORLD_50		= 210
_WORLD_51		= 211
_WORLD_52		= 212
_WORLD_53		= 213
_WORLD_54		= 214
_WORLD_55		= 215
_WORLD_56		= 216
_WORLD_57		= 217
_WORLD_58		= 218
_WORLD_59		= 219
_WORLD_60		= 220
_WORLD_61		= 221
_WORLD_62		= 222
_WORLD_63		= 223
_WORLD_64		= 224
_WORLD_65		= 225
_WORLD_66		= 226
_WORLD_67		= 227
_WORLD_68		= 228
_WORLD_69		= 229
_WORLD_70		= 230
_WORLD_71		= 231
_WORLD_72		= 232
_WORLD_73		= 233
_WORLD_74		= 234
_WORLD_75		= 235
_WORLD_76		= 236
_WORLD_77		= 237
_WORLD_78		= 238
_WORLD_79		= 239
_WORLD_80		= 240
_WORLD_81		= 241
_WORLD_82		= 242
_WORLD_83		= 243
_WORLD_84		= 244
_WORLD_85		= 245
_WORLD_86		= 246
_WORLD_87		= 247
_WORLD_88		= 248
_WORLD_89		= 249
_WORLD_90		= 250
_WORLD_91		= 251
_WORLD_92		= 252
_WORLD_93		= 253
_WORLD_94		= 254
_WORLD_95		= 255		-- 0xFF

-- Numeric keypad
_KP0		= 256
_KP1		= 257
_KP2		= 258
_KP3		= 259
_KP4		= 260
_KP5		= 261
_KP6		= 262
_KP7		= 263
_KP8		= 264
_KP9		= 265
_KP_PERIOD		= 266
_KP_DIVIDE		= 267
_KP_MULTIPLY	= 268
_KP_MINUS		= 269
_KP_PLUS		= 270
_KP_ENTER		= 271
_KP_EQUALS		= 272

-- Arrows + Home/End pad
_UP			= 273
_DOWN		= 274
_RIGHT		= 275
_LEFT		= 276
_INSERT		= 277
_HOME		= 278
_END		= 279
_PAGEUP		= 280
_PAGEDOWN		= 281

-- Function keys
_F1			= 282
_F2			= 283
_F3			= 284
_F4			= 285
_F5			= 286
_F6			= 287
_F7			= 288
_F8			= 289
_F9			= 290
_F10		= 291
_F11		= 292
_F12		= 293
_F13		= 294
_F14		= 295
_F15		= 296

-- Key state modifier keys
_NUMLOCK		= 300
_CAPSLOCK		= 301
_SCROLLLOCK		= 302
_RSHIFT		= 303
_LSHIFT		= 304
_RCTRL		= 305
_LCTRL		= 306
_RALT		= 307
_LALT		= 308
_RMETA		= 309
_LMETA		= 310
_LSUPER		= 311		-- Left "Windows" key
_RSUPER		= 312		-- Right "Windows" key
_MODE		= 313		-- "Alt Gr" key
_COMPOSE		= 314		-- Multi-key compose key

-- Miscellaneous function keys
_HELP		= 315
_PRINT		= 316
_SYSREQ		= 317
_BREAK		= 318
_MENU		= 319
_POWER		= 320		-- Power Macintosh power key
_EURO		= 321		-- Some European keyboards
_UNDO		= 322		-- Atari keyboard has Undo

__DEFAULT 	= -10000
__TEXTINPUT 	= -10001

-- Reverse sym calc
_M.sym_to_name = {}
for k, e in pairs(_M) do
	if type(k) == "string" and type(e) == "number" then
		_M.sym_to_name[e] = k
	end
end
