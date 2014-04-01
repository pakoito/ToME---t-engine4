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
local Dialog = require "engine.ui.Dialog"
local Shader = require "engine.Shader"

module(..., package.seeall, class.inherit(Dialog))

__show_only = true

local title_font = core.display.newFont("/data/font/DroidSans-Bold.ttf", 32)
local aura = {
	Shader.new("awesomeaura", {flameScale=0.6, time_factor=8000}),
	Shader.new("awesomeaura", {flameScale=0.6, time_factor=8000}),
--	Shader.new("crystalineaura", {time_factor=8000}),
}
local aura_texture = {
	core.display.loadImage("/data/gfx/flame_credits.png"):glTexture(),
	core.display.loadImage("/data/gfx/spikes_credits.png"):glTexture(),
}
local fallback_colors = {
	colors.GOLD,
	colors.FIREBRICK,
}
local outline = Shader.new("textoutline", {})

local credits = {
	{img="/data/gfx/background/tome-logo.png"},
	false,
	{"Project Lead", title=1},
	{"Nicolas 'DarkGod' Casalini"},
	false,
	false,

	{"Lead Coder", title=2},
	{"Nicolas 'DarkGod' Casalini"},
	false,
	false,

	{"World Builders", title=1},
	{"Aaron 'Sage Acrin' Vandegrift"},
	{"Chris 'Shibari' Davidson"},
	{"Em 'Susramanian' Jay"},
	{"Eric 'Edge2054' Wykoff"},
	{"Evan 'Fortescue' Williams"},
	{"Hetdegon"},
	{"John 'Benli' Truchard"},
	{"Shoob"},
	{"Taylor 'PureQuestion' Miller"},
	{"Thomas 'Tomisgo' Cretan"},
	false,
	false,

	{"Graphic Artists", title=2},
	{"Assen 'Rexorcorum' Kanev"},
	{"Raymond 'Shockbolt' Gaustadnes"},
	{"Ross 'Daftigod' Raphael"},
	false,
	false,

	{"Expert Shaders Design", title=1},
	{"Alex 'Suslik' Sannikov"},
	false,
	false,

	{"Soundtracks", title=2},
	{"Anne van Schothorst"},
	{"Carlos Saura"},
	{"Matti Paalanen - 'Celestial Aeon Project'"},
	false,
	false,

	{"Sound Designer", title=1},
	{"Kenneth 'Elvisman2001' Toomey"},
	{"Ryan Sim"},
	false,
	false,

	{"Lore Creation and Writing", title=2},
	{"Burb Lulls"},
	{"Darren Grey"},
	{"Gwai"},
	{"Nicolas 'DarkGod' Casalini"},
	{"Ron Billingsley"},
	false,
	false,

	{"Code Helpers", title=1},
	{"Antagonist"},
	{"Graziel"},
	{"Hachem Muche"},
	{"Jules 'Quicksilver' Bean"},
	{"Madmonk"},
	{"Neil Stevens"},
	{"Shani"},
	{"Shibari"},
	{"Tiger Eye"},
	{"Yufra"},
	false,
	false,

	{"Community Managers", title=2},
	{"Aura of the Dawn"},
	{"Faeryan"},
	{"Lord Xandor"},
	{"Michael 'Dekar' Olscher"},
	{"Reenen 'Canderel' Laurie"},
	{"The Revanchist"},
	{"Yottle"},
	false,
	false,

	{"Text Editors", title=1},
	{"Brian Jeffears"},
	{"Greg Wooledge"},
	{"Ralph Versteegen"},
	false,
	false,

	{"The Community", title=2},
	{"A huge global thank to all members"},
	{"of the community, for being supportive,"},
	{"fun and full of great ideas."},
	{"You rock gals and guys!"},
	false,
	false,

	{"Others", title=1},
	{"J.R.R Tolkien - making the world an interesting place"},
	false,
	{"Lua Creators - making the world a better place"},
	{"Lua - http://lua.org/"},
	{"LibSDL - http://libsdl.org/"},
	{"OpenGL - http://www.opengl.org/"},
	{"OpenAL - http://kcat.strangesoft.net/openal.html"},
	{"zlib - http://www.zlib.net/"},
	{"LuaJIT - http://luajit.org/"},
	{"lpeg - http://www.inf.puc-rio.br/~roberto/lpeg/"},
	{"LuaSocket - http://w3.impa.br/~diego/software/luasocket/"},
	{"Physfs - https://icculus.org/physfs/"},
	{"Awesomium - http://awesomium.com/"},
	{"Font: Droid - http://www.droidfonts.com/"},
	{"Font: Vera - http://www.gnome.org/fonts/"},
	{"Font: INSULA, USENET: http://www.dafont.com/fr/apostrophic-labs.d128"},
	{"Font: SVBasicManual: http://www.dafont.com/fr/johan-winge.d757"},
	{"Font FSEX300: http://www.fixedsysexcelsior.com/"},
	{"Font: square: http://strlen.com/square"},
}

function _M:init()
	Dialog.init(self, "", game.w, game.h, nil, nil, nil, nil, false, "invisible")

	self:loadUI{}
	self:setupUI(false, false)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}

	self.list = { self:makeEntry(credits[1]) }
	self.next_credit = 2
end

function _M:makeLogo(img)
	local txt = {y=game.h}
	local i, w, h = core.display.loadImage(img)
	txt._tex, txt._tex_w, txt._tex_h = i:glTexture()
	txt.w, txt.h = w, h
	txt.step_h = h
	txt.offset_y = 0
	txt.img = true
	return txt
end

function _M:makeEntry(credit)
	if not credit then return {none=true, y=game.h, h=32, step_h=32, offset_y=0} end

	if credit.img then return self:makeLogo(credit.img) end

	local txt
	if credit.title then
		local w, h = title_font:size(credit[1]) + 20, 32 * 2
		local s = core.display.newSurface(w, h)
		s:alpha(0)
		s:drawStringBlended(title_font, credit[1], 10, 16, 255, 255, 255, false)
		txt = {title=credit.title}
		txt.w, txt.h = w, h
		txt._tex, txt._tex_w, txt._tex_h = s:glTexture()
		txt._texf = txt._tex:generateSDM(false)
		txt.step_h = txt.h
		txt.offset_y = 0
	else
		local w, h = title_font:size(credit[1]) + 20, 36
		local s = core.display.newSurface(w, h)
		s:alpha(0)
		s:drawStringBlended(title_font, credit[1], 10, 0, 255, 255, 255, false)
		txt = {}
		txt.w, txt.h = w, h
		txt._tex, txt._tex_w, txt._tex_h = s:glTexture()
		txt.step_h = 32
		txt.offset_y = 0
	end
	txt.y = game.h
	return txt
end

function _M:displayCredit(txt, x, y)
	if txt.none then return end
	local x, y = x + (game.w - txt.w) / 2, y + txt.y - txt.offset_y
	if aura[1].shad and aura[2].shad then
		if txt.title then
			aura_texture[txt.title]:bind(1)
			aura[txt.title].shad:use(true)
			if aura[txt.title].shad.uniQuadSize then aura[txt.title].shad:uniQuadSize(txt.w/txt._tex_w, txt.h/txt._tex_h) end
			if aura[txt.title].shad.uniTexSize then aura[txt.title].shad:uniTexSize(txt._tex_w, txt._tex_h) end
			txt._texf:toScreenPrecise(x, y, txt.w, txt.h, 0, txt.w/txt._tex_w, 0, txt.h/txt._tex_h)
			aura[txt.title].shad:use(false)

			outline.shad:use(true)
			outline.shad:uniOutlineSize(0.7, 0.7)
			outline.shad:uniTextSize(txt._tex_w, txt._tex_h)
			txt._tex:toScreenFull(x, y, txt.w, txt.h, txt._tex_w, txt._tex_h)
			outline.shad:use(false)
		else
			outline.shad:use(true)
			outline.shad:uniOutlineSize(0.7, 0.7)
			outline.shad:uniTextSize(txt._tex_w, txt._tex_h)
			txt._tex:toScreenFull(x, y, txt.w, txt.h, txt._tex_w, txt._tex_h)
			outline.shad:use(false)
		end
	else
		if not txt.img then txt._tex:toScreenFull(x + 3, y + 3, txt.w, txt.h, txt._tex_w, txt._tex_h, 0, 0, 0, 1) end
		if txt.title and not txt.img then
			local c = fallback_colors[txt.title]
			txt._tex:toScreenFull(x, y, txt.w, txt.h, txt._tex_w, txt._tex_h, c.r/255, c.g/255, c.b/255, 1)
		else
			txt._tex:toScreenFull(x, y, txt.w, txt.h, txt._tex_w, txt._tex_h)
		end
	end
end

function _M:innerDisplay(x, y, nb_keyframes)
	for i = #self.list, 1, -1 do
		local txt = self.list[i]
		self:displayCredit(txt, x, y)

		txt.y = txt.y - nb_keyframes * 1.5
		if i == #self.list and txt.y < game.h then
			if credits[self.next_credit] ~= nil then
				local t = self:makeEntry(credits[self.next_credit])
				self.next_credit = self.next_credit + 1
				t.y = txt.y + txt.step_h
				table.insert(self.list, t)
			end
			if #self.list == 1 and credits[self.next_credit] == nil then
				game:unregisterDialog(self)
			end
		elseif i == 1 and txt.y + txt.h < 0 then
			table.remove(self.list, 1)
		end
	end
end
