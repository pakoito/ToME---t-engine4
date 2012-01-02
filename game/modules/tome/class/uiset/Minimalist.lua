-- ToME - Tales of Maj'Eyal
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
local UI = require "engine.ui.Base"
local UISet = require "mod.class.uiset.UISet"
local DebugConsole = require "engine.DebugConsole"
local PlayerDisplay = require "mod.class.PlayerDisplay"
local HotkeysDisplay = require "engine.HotkeysDisplay"
local HotkeysIconsDisplay = require "engine.HotkeysIconsDisplay"
local ActorsSeenDisplay = require "engine.ActorsSeenDisplay"
local LogDisplay = require "engine.LogDisplay"
local LogFlasher = require "engine.LogFlasher"
local FlyingText = require "engine.FlyingText"
local Shader = require "engine.Shader"
local Tooltip = require "mod.class.Tooltip"
local TooltipsData = require "mod.class.interface.TooltipsData"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(UISet, TooltipsData))

local move_handle = {core.display.loadImage("/data/gfx/ui/move_handle.png"):glTexture()}

local frames_colors = {
	ok = {0.3, 0.6, 0.3},
	sustain = {0.6, 0.6, 0},
	cooldown = {0.6, 0, 0},
	disabled = {0.65, 0.65, 0.65},
}

-- Load the various shaders used to display resources
air_c = {0x92/255, 0xe5, 0xe8}
air_sha = Shader.new("resources", {color=air_c, speed=100, amp=0.8, distort={2,2.5}})
life_c = {0xc0/255, 0, 0}
life_sha = Shader.new("resources", {color=life_c, speed=1000, distort={1.5,1.5}})
shield_c = {0.5, 0.5, 0.5}
shield_sha = Shader.new("resources", {color=shield_c, speed=5000, a=0.8, distort={0.5,0.5}})
stam_c = {0xff/255, 0xcc/255, 0x80/255}
stam_sha = Shader.new("resources", {color=stam_c, speed=700, distort={1,1.4}})
mana_c = {106/255, 146/255, 222/255}
mana_sha = Shader.new("resources", {color=mana_c, speed=1000, distort={0.4,0.4}})
soul_c = {128/255, 128/255, 128/255}
soul_sha = Shader.new("resources", {color=soul_c, speed=1200, distort={0.4,-0.4}})
equi_c = {0x00/255, 0xff/255, 0x74/255}
equi_sha = Shader.new("resources", {color=equi_c, amp=0.8, speed=20000, distort={0.3,0.25}})
paradox_c = {0x2f/255, 0xa0/255, 0xb4/255}
paradox_sha = Shader.new("resources", {color=paradox_c, amp=0.8, speed=20000, distort={0.1,0.25}})
pos_c = {colors.GOLD.r/255, colors.GOLD.g/255, colors.GOLD.b/255}
pos_sha = Shader.new("resources", {color=pos_c, speed=1000, distort={1.6,0.2}})
neg_c = {colors.DARK_GREY.r/255, colors.DARK_GREY.g/255, colors.DARK_GREY.b/255}
neg_sha = Shader.new("resources", {color=neg_c, speed=1000, distort={1.6,-0.2}})
vim_c = {0x90/255, 0x40/255, 0x10/255}
vim_sha = Shader.new("resources", {color=vim_c, speed=1000, distort={0.4,0.4}})
hate_c = {colors.GREY.r/255, colors.GREY.g/255, colors.GREY.b/255}
hate_sha = Shader.new("resources", {color=hate_c, speed=1000, distort={0.4,0.4}})
psi_c = {colors.BLUE.r/255, colors.BLUE.g/255, colors.BLUE.b/255}
psi_sha = Shader.new("resources", {color=psi_c, speed=2000, distort={0.4,0.4}})
save_c = pos_c
save_sha = pos_sha

sshat = {core.display.loadImage("/data/gfx/ui/resources/shadow.png"):glTexture()}
bshat = {core.display.loadImage("/data/gfx/ui/resources/back.png"):glTexture()}
shat = {core.display.loadImage("/data/gfx/ui/resources/fill.png"):glTexture()}
fshat = {core.display.loadImage("/data/gfx/ui/resources/front.png"):glTexture()}
fshat_life = {core.display.loadImage("/data/gfx/ui/resources/front_life.png"):glTexture()}
fshat_life_dark = {core.display.loadImage("/data/gfx/ui/resources/front_life_dark.png"):glTexture()}
fshat_shield = {core.display.loadImage("/data/gfx/ui/resources/front_life_armored.png"):glTexture()}
fshat_shield_dark = {core.display.loadImage("/data/gfx/ui/resources/front_life_armored_dark.png"):glTexture()}
fshat_stamina = {core.display.loadImage("/data/gfx/ui/resources/front_stamina.png"):glTexture()}
fshat_stamina_dark = {core.display.loadImage("/data/gfx/ui/resources/front_stamina_dark.png"):glTexture()}
fshat_mana = {core.display.loadImage("/data/gfx/ui/resources/front_mana.png"):glTexture()}
fshat_mana_dark = {core.display.loadImage("/data/gfx/ui/resources/front_mana_dark.png"):glTexture()}
fshat_soul = {core.display.loadImage("/data/gfx/ui/resources/front_souls.png"):glTexture()}
fshat_soul_dark = {core.display.loadImage("/data/gfx/ui/resources/front_souls_dark.png"):glTexture()}
fshat_equi = {core.display.loadImage("/data/gfx/ui/resources/front_nature.png"):glTexture()}
fshat_equi_dark = {core.display.loadImage("/data/gfx/ui/resources/front_nature_dark.png"):glTexture()}
fshat_paradox = {core.display.loadImage("/data/gfx/ui/resources/front_paradox.png"):glTexture()}
fshat_paradox_dark = {core.display.loadImage("/data/gfx/ui/resources/front_paradox_dark.png"):glTexture()}
fshat_hate = {core.display.loadImage("/data/gfx/ui/resources/front_hate.png"):glTexture()}
fshat_hate_dark = {core.display.loadImage("/data/gfx/ui/resources/front_hate_dark.png"):glTexture()}
fshat_positive = {core.display.loadImage("/data/gfx/ui/resources/front_positive.png"):glTexture()}
fshat_positive_dark = {core.display.loadImage("/data/gfx/ui/resources/front_positive_dark.png"):glTexture()}
fshat_negative = {core.display.loadImage("/data/gfx/ui/resources/front_negative.png"):glTexture()}
fshat_negative_dark = {core.display.loadImage("/data/gfx/ui/resources/front_negative_dark.png"):glTexture()}
fshat_vim = {core.display.loadImage("/data/gfx/ui/resources/front_vim.png"):glTexture()}
fshat_vim_dark = {core.display.loadImage("/data/gfx/ui/resources/front_vim_dark.png"):glTexture()}
fshat_psi = {core.display.loadImage("/data/gfx/ui/resources/front_psi.png"):glTexture()}
fshat_psi_dark = {core.display.loadImage("/data/gfx/ui/resources/front_psi_dark.png"):glTexture()}
fshat_air = {core.display.loadImage("/data/gfx/ui/resources/front_air.png"):glTexture()}
fshat_air_dark = {core.display.loadImage("/data/gfx/ui/resources/front_air_dark.png"):glTexture()}

ammo_shadow_default = {core.display.loadImage("/data/gfx/ui/resources/ammo_shadow_default.png"):glTexture()}
ammo_default = {core.display.loadImage("/data/gfx/ui/resources/ammo_default.png"):glTexture()}
ammo_shadow_arrow = {core.display.loadImage("/data/gfx/ui/resources/ammo_shadow_arrow.png"):glTexture()}
ammo_arrow = {core.display.loadImage("/data/gfx/ui/resources/ammo_arrow.png"):glTexture()}
ammo_shadow_shot = {core.display.loadImage("/data/gfx/ui/resources/ammo_shadow_shot.png"):glTexture()}
ammo_shot = {core.display.loadImage("/data/gfx/ui/resources/ammo_shot.png"):glTexture()}
_M['ammo_shadow_alchemist-gem'] = {core.display.loadImage("/data/gfx/ui/resources/ammo_shadow_alchemist-gem.png"):glTexture()}
_M['ammo_alchemist-gem'] = {core.display.loadImage("/data/gfx/ui/resources/ammo_alchemist-gem.png"):glTexture()}

font_sha = core.display.newFont("/data/font/USENET_.ttf", 14, true)
font_sha:setStyle("bold")
sfont_sha = core.display.newFont("/data/font/USENET_.ttf", 12, true)
sfont_sha:setStyle("bold")

icon_green = { core.display.loadImage("/data/gfx/ui/talent_frame_ok.png"):glTexture() }
icon_yellow = { core.display.loadImage("/data/gfx/ui/talent_frame_sustain.png"):glTexture() }
icon_red = { core.display.loadImage("/data/gfx/ui/talent_frame_cooldown.png"):glTexture() }

local portrait = {core.display.loadImage("/data/gfx/ui/party-portrait.png"):glTexture()}
local portrait_unsel = {core.display.loadImage("/data/gfx/ui/party-portrait-unselect.png"):glTexture()}

local pf_bg = {core.display.loadImage("/data/gfx/ui/playerframe/back.png"):glTexture()}
local pf_shadow = {core.display.loadImage("/data/gfx/ui/playerframe/shadow.png"):glTexture()}
local pf_defend = {core.display.loadImage("/data/gfx/ui/playerframe/defend.png"):glTexture()}
local pf_attack = {core.display.loadImage("/data/gfx/ui/playerframe/attack.png"):glTexture()}
local pf_levelup = {core.display.loadImage("/data/gfx/ui/playerframe/levelup.png"):glTexture()}
local pf_encumber = {core.display.loadImage("/data/gfx/ui/playerframe/encumber.png"):glTexture()}
local pf_exp = {core.display.loadImage("/data/gfx/ui/playerframe/exp.png"):glTexture()}
local pf_exp_levelup = {core.display.loadImage("/data/gfx/ui/playerframe/exp_levelup.png"):glTexture()}

local mm_bg = {core.display.loadImage("/data/gfx/ui/minimap/back.png"):glTexture()}
local mm_comp = {core.display.loadImage("/data/gfx/ui/minimap/compass.png"):glTexture()}
local mm_shadow = {core.display.loadImage("/data/gfx/ui/minimap/shadow.png"):glTexture()}
local mm_transp = {core.display.loadImage("/data/gfx/ui/minimap/transp.png"):glTexture()}

local sep = {core.display.loadImage("/data/gfx/ui/hotkeys/separator.png"):glTexture()}
local sep_vines = {core.display.loadImage("/data/gfx/ui/hotkeys/separator_vines.png"):glTexture()}


function _M:init()
	UISet.init(self)

	self.mhandle = {}
	self.res = {}
	self.party = {}
	self.tbuff = {}
	self.pbuff = {}

	self.mhandle_pos = {
		player = {x=296, y=73},
		resources = {x=fshat[6] - move_handle[6], y=0},
		minimap = {x=208, y=176},
	}

	local w, h = core.display.size()
	self.places = {
		player = {x=0, y=0, scale=1},
		resources = {x=0, y=111, scale=1},
		minimap = {x=w - 239, y=0, scale=1},
	}
	table.merge(self.places, config.settings.tome.uiset_minimalist and config.settings.tome.uiset_minimalist.places or {}, true)

	self.buffs_base = UI:makeFrame("ui/icon-frame/frame", 40, 40)

	self.side_4 = 0
	self.side_6 = 0
	self.side_8 = 0
end

function _M:boundPlaces(w, h)
	w = w or game.w
	h = h or game.h

	for what, d in pairs(self.places) do
		if d.x then
			d.x = math.floor(d.x)
			d.y = math.floor(d.y)
			d.scale = util.bound(d.scale, 0.5, 2)

			d.x = util.bound(d.x, -self.mhandle_pos[what].x * d.scale, w - self.mhandle_pos[what].x * d.scale - move_handle[6] * d.scale)
			d.y = util.bound(d.y, -self.mhandle_pos[what].y * d.scale, self.map_h_stop - self.mhandle_pos[what].y * d.scale - move_handle[7] * d.scale)
		end
	end
end

function _M:saveSettings()
	self:boundPlaces()

	local lines = {}
	lines[#lines+1] = ("tome.uiset_minimalist = {}"):format(w)
	lines[#lines+1] = ("tome.uiset_minimalist.places = {}"):format(w)
	for _, w in ipairs{"player", "resources", "party", "buffs"} do
		lines[#lines+1] = ("tome.uiset_minimalist.places.%s = {}"):format(w)
		if self.places[w] then for k, v in pairs(self.places[w]) do
			lines[#lines+1] = ("tome.uiset_minimalist.places.%s.%s = %d"):format(w, k, v)
		end end
	end
	game:saveSettings("tome.uiset_minimalist", table.concat(lines, "\n"))
end

function _M:toggleUI()
	UISet.toggleUI(self)
	print("Toggling UI", self.no_ui)
	self:resizeIconsHotkeysToolbar()
	self.res = {}
	self.party = {}
	self.tbuff = {}
	self.pbuff = {}
	if game.level then self:setupMinimap(game.level) end
end

function _M:activate()
	local size, size_mono, font, font_mono, font_mono_h, font_h
	if config.settings.tome.fonts.type == "fantasy" then
		size = ({normal=16, small=14, big=18})[config.settings.tome.fonts.size]
		size_mono = ({normal=14, small=10, big=16})[config.settings.tome.fonts.size]
		font = "/data/font/USENET_.ttf"
		font_mono = "/data/font/SVBasicManual.ttf"
	else
		size = ({normal=12, small=10, big=14})[config.settings.tome.fonts.size]
		size_mono = ({normal=12, small=10, big=14})[config.settings.tome.fonts.size]
		font = "/data/font/Vera.ttf"
		font_mono = "/data/font/VeraMono.ttf"
	end
	local f = core.display.newFont(font, size)
	font_h = f:lineSkip()
	f = core.display.newFont(font_mono, size_mono)
	font_mono_h = f:lineSkip()
	self.init_font = font
	self.init_size_font = size
	self.init_font_h = font_h
	self.init_font_mono = font_mono
	self.init_size_mono = size_mono
	self.init_font_mono_h = font_mono_h

	self.buff_font = core.display.newFont(font_mono, size_mono * 2, true)

	self.hotkeys_display_text = HotkeysDisplay.new(nil, 0, game.h - 52, game.w, 52, "/data/gfx/ui/hotkeys/back.png", font_mono, size_mono)
	self.hotkeys_display_text:enableShadow(0.6)
	self.hotkeys_display_text:setColumns(3)
	self:resizeIconsHotkeysToolbar()

	self.logdisplay = LogDisplay.new(0, self.map_h_stop - font_h * config.settings.tome.log_lines - sep[7], (game.w) / 2, font_h * config.settings.tome.log_lines, nil, font, size, nil, nil)
	self.logdisplay.resizeToLines = function() self.logdisplay:resize(0, self.map_h_stop - font_h * config.settings.tome.log_lines -16, (game.w) / 2, font_h * config.settings.tome.log_lines) end
	self.logdisplay:enableShadow(1)
	self.logdisplay:enableFading(config.settings.tome.log_fade or 3)

	profile.chat:resize(0 + (game.w) / 2, self.map_h_stop - font_h * config.settings.tome.log_lines - sep[7], (game.w) / 2, font_h * config.settings.tome.log_lines, font, size, nil, nil)
	profile.chat.resizeToLines = function() profile.chat:resize(0 + (game.w) / 2, self.map_h_stop - font_h * config.settings.tome.log_lines -16, (game.w) / 2, font_h * config.settings.tome.log_lines) end
	profile.chat:enableShadow(1)
	profile.chat:enableFading(config.settings.tome.log_fade or 3)
	profile.chat:enableDisplayChans(false)

	self.npcs_display = ActorsSeenDisplay.new(nil, 0, game.h - font_mono_h * 4.2, game.w, font_mono_h * 4.2, "/data/gfx/ui/talents-list.png", font_mono, size_mono)
	self.npcs_display:setColumns(3)

	game.log = function(style, ...) if type(style) == "number" then game.uiset.logdisplay(...) else game.uiset.logdisplay(style, ...) end end
	game.logChat = function(style, ...)
		if true or not config.settings.tome.chat_log then return end
		if type(style) == "number" then
		local old = game.uiset.logdisplay.changed
		game.uiset.logdisplay(...) else game.uiset.logdisplay(style, ...) end
		if game.uiset.show_userchat then game.uiset.logdisplay.changed = old end
	end
	game.logSeen = function(e, style, ...) if e and e.x and e.y and game.level.map.seens(e.x, e.y) then game.log(style, ...) end end
	game.logPlayer = function(e, style, ...) if e == game.player or e == game.party then game.log(style, ...) end end

	self:boundPlaces()
end

function _M:setupMinimap(level)
	level.map._map:setupMiniMapGridSize(3)
end

function _M:resizeIconsHotkeysToolbar()
	local h = 52
	if config.settings.tome.hotkey_icons then h = (4 + config.settings.tome.hotkey_icons_size) * config.settings.tome.hotkey_icons_rows end

	local oldstop = self.map_h_stop_up or (game.h - h)
	self.map_h_stop = game.h - h
	self.map_h_stop_up = game.h - h - sep[7]

	self.hotkeys_display_icons = HotkeysIconsDisplay.new(nil, 0, game.h - h, game.w, h, "/data/gfx/ui/hotkeys/back.png", self.init_font_mono, self.init_size_mono, config.settings.tome.hotkey_icons_size, config.settings.tome.hotkey_icons_size)
	self.hotkeys_display_icons:enableShadow(0.6)

	if self.no_ui then
		self.map_h_stop = game.h
		game:resizeMapViewport(game.w, self.map_h_stop)
		self.logdisplay.display_y = self.logdisplay.display_y + self.map_h_stop_up - oldstop
		profile.chat.display_y = profile.chat.display_y + self.map_h_stop_up - oldstop
		game:setupMouse()
		return
	end

	if game.inited then
		game:resizeMapViewport(game.w, self.map_h_stop)
		self.logdisplay.display_y = self.logdisplay.display_y + self.map_h_stop_up - oldstop
		profile.chat.display_y = profile.chat.display_y + self.map_h_stop_up - oldstop
		game:setupMouse()
	end

	self.hotkeys_display = config.settings.tome.hotkey_icons and self.hotkeys_display_icons or self.hotkeys_display_text
	self.hotkeys_display.actor = game.player
end


function _M:getMapSize()
	local w, h = core.display.size()
	return 0, 0, w, (self.map_h_stop or 80) - 16
end

function _M:uiMoveResize(what, button, mx, my, xrel, yrel, bx, by, event)
	game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, "Left mouse drag&drop to move the frame\nRight mouse drag&drop to scale up/down\nMiddle click to reset to default scale")
	if event == "button" and button == "middle" then self.places[what].scale = 1 self:saveSettings()
	elseif event == "motion" and button == "left" then
		game.mouse:startDrag(mx, my, s, {kind="ui:move", id=what, dx=bx*self.places[what].scale, dy=by*self.places[what].scale},
			function(drag, used) self:saveSettings() end,
			function(drag, _, x, y) if self.places[drag.payload.id] then self.places[drag.payload.id].x = x-drag.payload.dx self.places[drag.payload.id].y = y-drag.payload.dy self:boundPlaces() end end,
			true
		)
	elseif event == "motion" and button == "right" then
		game.mouse:startDrag(mx, my, s, {kind="ui:resize", id=what, bx=bx, by=by},
			function(drag, used) self:saveSettings() end,
--			function(drag, _, x, y) if self.places[drag.payload.id] then self.places[drag.payload.id].scale = util.bound(math.max((x-self.places[drag.payload.id].x)/drag.payload.bx, (y-self.places[drag.payload.id].y)/drag.payload.by), 0.5, 2) self:boundPlaces() end end,
			function(drag, _, x, y) if self.places[drag.payload.id] then self.places[drag.payload.id].scale = util.bound(math.max((x-self.places[drag.payload.id].x)/drag.payload.bx), 0.5, 2) self:boundPlaces() end end,
			true
		)
	end
end

function _M:showResourceTooltip(x, y, w, h, id, desc, is_first)
	if not game.mouse:updateZone(id, x, y, w, h, nil, self.places.resources.scale) then
		game.mouse:registerZone(x, y, w, h, function(button, mx, my, xrel, yrel, bx, by, event)
			if is_first then
				if event == "out" then self.mhandle.resources = nil return
				else self.mhandle.resources = true end

				-- Move handle
				if bx >= self.mhandle_pos.resources.x and bx <= self.mhandle_pos.resources.x + move_handle[6] and by >= self.mhandle_pos.resources.y and by <= self.mhandle_pos.resources.y + move_handle[7] then self:uiMoveResize("resources", button, mx, my, xrel, yrel, bx, by, event) end
			end

			game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, desc)
		end, nil, id, true, self.places.resources.scale)
	end
end

function _M:displayResources(scale, bx, by)
	local player = game.player
	if player then
		local stop = self.map_h_stop - fshat[7]
		local x, y = 0, 0

		-----------------------------------------------------------------------------------
		-- Air
		if player.air < player.max_air then
			sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
			bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
			if air_sha.shad then air_sha.shad:use(true) end
			local p = player:getAir() / player.max_air
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], air_c[1], air_c[2], air_c[3], 1)
			if air_sha.shad then air_sha.shad:use(false) end

			if not self.res.air or self.res.air.vc ~= player.air or self.res.air.vm ~= player.max_air or self.res.air.vr ~= player.air_regen then
				self.res.air = {
					vc = player.air, vm = player.max_air, vr = player.air_regen,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d/%d"):format(player.air, player.max_air), 255, 255, 255):glTexture()},
					regen={core.display.drawStringBlendedNewSurface(sfont_sha, ("%+0.2f"):format(player.air_regen), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.air.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])
			dt = self.res.air.regen
			dt[1]:toScreenFull(2+x+144, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+144, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			local front = fshat_air_dark
			if player.air >= player.max_air * 0.5 then front = fshat_air end
			front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])
			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:air", self.TOOLTIP_AIR)
			y = y + fshat[7]
			if y > stop then x = x + fshat[6] y = 0 end
		elseif game.mouse:getZone("res:air") then game.mouse:unregisterZone("res:air") end

		-----------------------------------------------------------------------------------
		-- Life & shield
		sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
		bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
		if life_sha.shad then life_sha.shad:use(true) end
		local p = math.min(1, math.max(0, player.life / player.max_life))
		shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], life_c[1], life_c[2], life_c[3], 1)
		if life_sha.shad then life_sha.shad:use(false) end

		if not self.res.life or self.res.life.vc ~= player.life or self.res.life.vm ~= player.max_life or self.res.life.vr ~= player.life_regen then
			self.res.life = {
				vc = player.life, vm = player.max_life, vr = player.life_regen,
				cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d/%d"):format(player.life, player.max_life), 255, 255, 255):glTexture()},
				regen={core.display.drawStringBlendedNewSurface(sfont_sha, ("%+0.2f"):format(player.life_regen), 255, 255, 255):glTexture()},
			}
		end
		local dt = self.res.life.cur
		dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
		dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])
		dt = self.res.life.regen
		dt[1]:toScreenFull(2+x+144, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
		dt[1]:toScreenFull(x+144, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

		local shield, max_shield = 0, 0
		if player:attr("time_shield") then shield = shield + player.time_shield_absorb max_shield = max_shield + player.time_shield_absorb_max end
		if player:attr("damage_shield") then shield = shield + player.damage_shield_absorb max_shield = max_shield + player.damage_shield_absorb_max end
		if player:attr("displacement_shield") then shield = shield + player.displacement_shield max_shield = max_shield + player.displacement_shield_max end
		if max_shield > 0 then
			if shield_sha.shad then shield_sha.shad:use(true) end
			local p = math.min(1, math.max(0, shield / max_shield))
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], shield_c[1], shield_c[2], shield_c[3], 0.8)
			if shield_sha.shad then shield_sha.shad:use(false) end

			if not self.res.shield or self.res.shield.vc ~= shield or self.res.shield.vm ~= max_shield then
				self.res.shield = {
					vc = shield, vm = max_shield,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d/%d"):format(shield, max_shield), 255, 215, 0):glTexture()},
				}
			end
			local dt = self.res.shield.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:shield", self.TOOLTIP_DAMAGE_SHIELD.."\n---\n"..self.TOOLTIP_LIFE, true)
			if game.mouse:getZone("res:life") then game.mouse:unregisterZone("res:life") end
		else
			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:life", self.TOOLTIP_LIFE, true)
			if game.mouse:getZone("res:shield") then game.mouse:unregisterZone("res:shield") end
		end

		local front = fshat_life_dark
		if max_shield > 0 then
			front = fshat_shield_dark
			if shield >= max_shield * 0.8 then front = fshat_shield end
		elseif player.life >= player.max_life then front = fshat_life end
		front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])
		y = y + fshat[7]
		if y > stop then x = x + fshat[6] y = 0 end

		if self.mhandle.resources then
			move_handle[1]:toScreenFull(fshat[6] - move_handle[6], 0, move_handle[6], move_handle[7], move_handle[2], move_handle[3])
		end

		-----------------------------------------------------------------------------------
		-- Stamina
		if player:knowTalent(player.T_STAMINA_POOL) then
			sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
			bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
			if stam_sha.shad then stam_sha.shad:use(true) end
			local p = player:getStamina() / player.max_stamina
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], stam_c[1], stam_c[2], stam_c[3], 1)
			if stam_sha.shad then stam_sha.shad:use(false) end

			if not self.res.stamina or self.res.stamina.vc ~= player.stamina or self.res.stamina.vm ~= player.max_stamina or self.res.stamina.vr ~= player.stamina_regen then
				self.res.stamina = {
					vc = player.stamina, vm = player.max_stamina, vr = player.stamina_regen,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d/%d"):format(player.stamina, player.max_stamina), 255, 255, 255):glTexture()},
					regen={core.display.drawStringBlendedNewSurface(sfont_sha, ("%+0.2f"):format(player.stamina_regen), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.stamina.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])
			dt = self.res.stamina.regen
			dt[1]:toScreenFull(2+x+144, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+144, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			local front = fshat_stamina_dark
			if player.stamina >= player.max_stamina then front = fshat_stamina end
			front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])

			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:stamina", self.TOOLTIP_STAMINA)
			y = y + fshat[7]
			if y > stop then x = x + fshat[6] y = 0 end
		elseif game.mouse:getZone("res:stamina") then game.mouse:unregisterZone("res:stamina") end

		-----------------------------------------------------------------------------------
		-- Mana
		if player:knowTalent(player.T_MANA_POOL) then
			sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
			bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
			if mana_sha.shad then mana_sha.shad:use(true) end
			local p = player:getMana() / player.max_mana
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], mana_c[1], mana_c[2], mana_c[3], 1)
			if mana_sha.shad then mana_sha.shad:use(false) end

			if not self.res.mana or self.res.mana.vc ~= player.mana or self.res.mana.vm ~= player.max_mana or self.res.mana.vr ~= player.mana_regen then
				self.res.mana = {
					vc = player.mana, vm = player.max_mana, vr = player.mana_regen,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d/%d"):format(player.mana, player.max_mana), 255, 255, 255):glTexture()},
					regen={core.display.drawStringBlendedNewSurface(sfont_sha, ("%+0.2f"):format(player.mana_regen), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.mana.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])
			dt = self.res.mana.regen
			dt[1]:toScreenFull(2+x+144, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+144, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			local front = fshat_mana_dark
			if player.mana >= player.max_mana then front = fshat_mana end
			front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])
			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:mana", self.TOOLTIP_MANA)
			y = y + fshat[7]
			if y > stop then x = x + fshat[6] y = 0 end
		elseif game.mouse:getZone("res:mana") then game.mouse:unregisterZone("res:mana") end

		-----------------------------------------------------------------------------------
		-- Souls
		if player:isTalentActive(player.T_NECROTIC_AURA) then
			local pt = player:isTalentActive(player.T_NECROTIC_AURA)

			sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
			bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
			if soul_sha.shad then soul_sha.shad:use(true) end
			local p = pt.souls / pt.souls_max
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], soul_c[1], soul_c[2], soul_c[3], 1)
			if soul_sha.shad then soul_sha.shad:use(false) end

			if not self.res.soul or self.res.soul.vc ~= pt.souls or self.res.soul.vm ~= pt.souls_max then
				self.res.soul = {
					vc = pt.souls, vm = player.souls_max,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d/%d"):format(pt.souls, pt.souls_max), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.soul.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			local front = fshat_soul_dark
			if pt.souls >= pt.souls_max then front = fshat_soul end
			front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])
			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:necrotic", self.TOOLTIP_NECROTIC_AURA)
			y = y + fshat[7]
			if y > stop then x = x + fshat[6] y = 0 end
		elseif game.mouse:getZone("res:necrotic") then game.mouse:unregisterZone("res:necrotic") end

		-----------------------------------------------------------------------------------
		-- Equilibirum
		if player:knowTalent(player.T_EQUILIBRIUM_POOL) then
			sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
			bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
			local _, chance = player:equilibriumChance()
			local s = math.max(50, 10000 - (math.sqrt(100 - chance) * 2000))
			if equi_sha.shad then
				equi_sha:setUniform("speed", s)
				equi_sha.shad:use(true)
			end
			local p = chance / 100
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], equi_c[1], equi_c[2], equi_c[3], 1)
			if equi_sha.shad then equi_sha.shad:use(false) end

			if not self.res.equilibrium or self.res.equilibrium.vc ~= player.equilibrium or self.res.equilibrium.vr ~= chance then
				self.res.equilibrium = {
					vc = player.equilibrium, vr = chance,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d"):format(player.equilibrium), 255, 255, 255):glTexture()},
					regen={core.display.drawStringBlendedNewSurface(sfont_sha, ("%d%%"):format(100-chance), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.equilibrium.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])
			dt = self.res.equilibrium.regen
			dt[1]:toScreenFull(2+x+144, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+144, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			local front = fshat_equi
			if chance <= 85 then front = fshat_equi_dark end
			front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])
			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:equi", self.TOOLTIP_EQUILIBRIUM)
			y = y + fshat[7]
			if y > stop then x = x + fshat[6] y = 0 end
		elseif game.mouse:getZone("res:equi") then game.mouse:unregisterZone("res:equi") end

		-----------------------------------------------------------------------------------
		-- Positive
		if player:knowTalent(player.T_POSITIVE_POOL) then
			sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
			bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
			if pos_sha.shad then pos_sha.shad:use(true) end
			local p = player:getPositive() / player.max_positive
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], pos_c[1], pos_c[2], pos_c[3], 1)
			if pos_sha.shad then pos_sha.shad:use(false) end

			if not self.res.positive or self.res.positive.vc ~= player.positive or self.res.positive.vm ~= player.max_positive or self.res.positive.vr ~= player.positive_regen then
				self.res.positive = {
					vc = player.positive, vm = player.max_positive, vr = player.positive_regen,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d/%d"):format(player.positive, player.max_positive), 255, 255, 255):glTexture()},
					regen={core.display.drawStringBlendedNewSurface(sfont_sha, ("%+0.2f"):format(player.positive_regen), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.positive.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])
			dt = self.res.positive.regen
			dt[1]:toScreenFull(2+x+144, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+144, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			local front = fshat_positive_dark
			if player.positive >= player.max_positive * 0.7 then front = fshat_positive end
			front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])
			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:positive", self.TOOLTIP_POSITIVE)
			y = y + fshat[7]
			if y > stop then x = x + fshat[6] y = 0 end
		elseif game.mouse:getZone("res:positive") then game.mouse:unregisterZone("res:positive") end

		-----------------------------------------------------------------------------------
		-- Negative
		if player:knowTalent(player.T_NEGATIVE_POOL) then
			sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
			bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
			if neg_sha.shad then neg_sha.shad:use(true) end
			local p = player:getNegative() / player.max_negative
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], neg_c[1], neg_c[2], neg_c[3], 1)
			if neg_sha.shad then neg_sha.shad:use(false) end

			if not self.res.negative or self.res.negative.vc ~= player.negative or self.res.negative.vm ~= player.max_negative or self.res.negative.vr ~= player.negative_regen then
				self.res.negative = {
					vc = player.negative, vm = player.max_negative, vr = player.negative_regen,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d/%d"):format(player.negative, player.max_negative), 255, 255, 255):glTexture()},
					regen={core.display.drawStringBlendedNewSurface(sfont_sha, ("%+0.2f"):format(player.negative_regen), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.negative.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])
			dt = self.res.negative.regen
			dt[1]:toScreenFull(2+x+144, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+144, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			local front = fshat_negative_dark
			if player.negative >= player.max_negative * 0.7  then front = fshat_negative end
			front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])
			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:negative", self.TOOLTIP_NEGATIVE)
			y = y + fshat[7]
			if y > stop then x = x + fshat[6] y = 0 end
		elseif game.mouse:getZone("res:negative") then game.mouse:unregisterZone("res:negative") end

		-----------------------------------------------------------------------------------
		-- Paradox
		if player:knowTalent(player.T_PARADOX_POOL) then
			sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
			bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
			local _, chance = player:paradoxFailChance()
			local s = math.max(50, 10000 - (math.sqrt(chance) * 2000))
			if paradox_sha.shad then
				paradox_sha:setUniform("speed", s)
				paradox_sha.shad:use(true)
			end
			local p = 1 - chance / 100
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], paradox_c[1], paradox_c[2], paradox_c[3], 1)
			if paradox_sha.shad then paradox_sha.shad:use(false) end

			if not self.res.paradox or self.res.paradox.vc ~= player.paradox or self.res.paradox.vr ~= chance then
				self.res.paradox = {
					vc = player.paradox, vr = chance,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d"):format(player.paradox), 255, 255, 255):glTexture()},
					regen={core.display.drawStringBlendedNewSurface(sfont_sha, ("%d%%"):format(chance), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.paradox.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])
			dt = self.res.paradox.regen
			dt[1]:toScreenFull(2+x+144, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+144, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			local front = fshat_paradox
			if chance <= 10 then front = fshat_paradox_dark end
			front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])
			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:paradox", self.TOOLTIP_PARADOX)
			y = y + fshat[7]
			if y > stop then x = x + fshat[6] y = 0 end
		elseif game.mouse:getZone("res:paradox") then game.mouse:unregisterZone("res:paradox") end

		-----------------------------------------------------------------------------------
		-- Vim
		if player:knowTalent(player.T_VIM_POOL) then
			sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
			bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
			if vim_sha.shad then vim_sha.shad:use(true) end
			local p = player:getVim() / player.max_vim
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], vim_c[1], vim_c[2], vim_c[3], 1)
			if vim_sha.shad then vim_sha.shad:use(false) end

			if not self.res.vim or self.res.vim.vc ~= player.vim or self.res.vim.vm ~= player.max_vim or self.res.vim.vr ~= player.vim_regen then
				self.res.vim = {
					vc = player.vim, vm = player.max_vim, vr = player.vim_regen,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d/%d"):format(player.vim, player.max_vim), 255, 255, 255):glTexture()},
					regen={core.display.drawStringBlendedNewSurface(sfont_sha, ("%+0.2f"):format(player.vim_regen), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.vim.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])
			dt = self.res.vim.regen
			dt[1]:toScreenFull(2+x+144, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+144, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			local front = fshat_vim_dark
			if player.vim >= player.max_vim then front = fshat_vim end
			front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])
			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:vim", self.TOOLTIP_VIM)
			y = y + fshat[7]
			if y > stop then x = x + fshat[6] y = 0 end
		elseif game.mouse:getZone("res:vim") then game.mouse:unregisterZone("res:vim") end

		-----------------------------------------------------------------------------------
		-- Hate
		if player:knowTalent(player.T_HATE_POOL) then
			sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
			bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
			if hate_sha.shad then hate_sha.shad:use(true) end
			local p = player:getHate() / player.max_hate
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], hate_c[1], hate_c[2], hate_c[3], 1)
			if hate_sha.shad then hate_sha.shad:use(false) end

			if not self.res.hate or self.res.hate.vc ~= player.hate or self.res.hate.vm ~= player.max_hate or self.res.hate.vr ~= player.hate_regen then
				self.res.hate = {
					vc = player.hate, vm = player.max_hate, vr = player.hate_regen,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d/%d"):format(player.hate, player.max_hate), 255, 255, 255):glTexture()},
					regen={core.display.drawStringBlendedNewSurface(sfont_sha, ("%+0.2f"):format(player.hate_regen), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.hate.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])
			dt = self.res.hate.regen
			dt[1]:toScreenFull(2+x+144, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+144, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			local front = fshat_hate_dark
			if player.hate >= 10 then front = fshat_hate end
			front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])
			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:hate", self.TOOLTIP_HATE)
			y = y + fshat[7]
			if y > stop then x = x + fshat[6] y = 0 end
		elseif game.mouse:getZone("res:hate") then game.mouse:unregisterZone("res:hate") end

		-----------------------------------------------------------------------------------
		-- Psi
		if player:knowTalent(player.T_PSI_POOL) then
			sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
			bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
			if psi_sha.shad then psi_sha.shad:use(true) end
			local p = player:getPsi() / player.max_psi
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], psi_c[1], psi_c[2], psi_c[3], 1)
			if psi_sha.shad then psi_sha.shad:use(false) end

			if not self.res.psi or self.res.psi.vc ~= player.psi or self.res.psi.vm ~= player.max_psi or self.res.psi.vr ~= player.psi_regen then
				self.res.psi = {
					vc = player.psi, vm = player.max_psi, vr = player.psi_regen,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d/%d"):format(player.psi, player.max_psi), 255, 255, 255):glTexture()},
					regen={core.display.drawStringBlendedNewSurface(sfont_sha, ("%+0.2f"):format(player.psi_regen), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.psi.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])
			dt = self.res.psi.regen
			dt[1]:toScreenFull(2+x+144, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+144, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			local front = fshat_psi_dark
			if player.psi >= player.max_psi then front = fshat_psi end
			front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])
			self:showResourceTooltip(bx+x*scale, by+y*scale, fshat[6], fshat[7], "res:psi", self.TOOLTIP_PSI)
			y = y + fshat[7]
			if y > stop then x = x + fshat[6] y = 0 end
		elseif game.mouse:getZone("res:psi") then game.mouse:unregisterZone("res:psi") end

		-----------------------------------------------------------------------------------
		-- Ammo
		local quiver = player:getInven("QUIVER")
		local ammo = quiver and quiver[1]
		if ammo then
			local amt = ammo:getNumber()
			local shad, bg
			if ammo.type == "alchemist-gem" then shad, bg = _M["ammo_shadow_alchemist-gem"], _M["ammo_alchemist-gem"]
			else shad, bg = _M["ammo_shadow_"..ammo.subtype] or ammo_shadow_default, _M["ammo_"..ammo.subtype] or ammo_default
			end

			shad[1]:toScreenFull(x, y, shad[6], shad[7], shad[2], shad[3])
			bg[1]:toScreenFull(x, y, bg[6], bg[7], bg[2], bg[3])

			if not self.res.ammo or self.res.ammo.vc ~= amt then
				self.res.ammo = {
					vc = amt,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d"):format(amt), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.ammo.cur
			dt[1]:toScreenFull(2+x+44, 2+y+3 + (bg[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+44, y+3 + (bg[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			y = y + bg[7]
			if y > stop then x = x + fshat[6] y = 0 end
		end

		-----------------------------------------------------------------------------------
		-- Saving
		if savefile_pipe.saving then
			sshat[1]:toScreenFull(x-6, y+8, sshat[6], sshat[7], sshat[2], sshat[3])
			bshat[1]:toScreenFull(x, y, bshat[6], bshat[7], bshat[2], bshat[3])
			if save_sha.shad then save_sha.shad:use(true) end
			local p = savefile_pipe.current_nb / savefile_pipe.total_nb
			shat[1]:toScreenPrecise(x+49, y+10, shat[6] * p, shat[7], 0, p * 1/shat[4], 0, 1/shat[5], save_c[1], save_c[2], save_c[3], 1)
			if save_sha.shad then save_sha.shad:use(false) end

			if not self.res.save or self.res.save.vc ~= p then
				self.res.save = {
					vc = p,
					cur = {core.display.drawStringBlendedNewSurface(font_sha, ("Saving... %d%%"):format(p * 100), 255, 255, 255):glTexture()},
				}
			end
			local dt = self.res.save.cur
			dt[1]:toScreenFull(2+x+64, 2+y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
			dt[1]:toScreenFull(x+64, y+10 + (shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3])

			local front = fshat
			front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3])
			y = y + fshat[7]
			if y > stop then x = x + fshat[6] y = 0 end
		end

		-- Compute how much space to reserve on the side
		self.side_4 = x + fshat[6]
--		Map.viewport_padding_4 = math.floor(scale * (self.side_4 / Map.tile_w))
	end
end

function _M:handleEffect(player, eff_id, e, p, x, y, hs, bx, by)
	local dur = p.dur + 1

	if not self.tbuff[eff_id..":"..dur] then
		local name = e.desc
		local desc = nil
		local eff_subtype = table.concat(table.keys(e.subtype), "/")
		if e.display_desc then name = e.display_desc(self, p) end
		if p.save_string and p.amount_decreased and p.maximum and p.total_dur then
			desc = ("#{bold}##GOLD#%s\n(%s: %s)#WHITE##{normal}#\n"):format(name, e.type, eff_subtype)..e.long_desc(player, p).." "..("%s reduced the duration of this effect by %d turns, from %d to %d."):format(p.save_string, p.amount_decreased, p.maximum, p.total_dur)
		else
			desc = ("#{bold}##GOLD#%s\n(%s: %s)#WHITE##{normal}#\n"):format(name, e.type, eff_subtype)..e.long_desc(player, p)
		end

		local txt = nil
		if e.decrease > 0 then
			dur = tostring(dur)
			txt = self.buff_font:draw(dur, 40, colors.WHITE.r, colors.WHITE.g, colors.WHITE.b, true)[1]
			txt.fw, txt.fh = self.buff_font:size(dur)
		end
		local icon = e.status ~= "detrimental" and frames_colors.ok or frames_colors.cooldown

		local desc_fct = function(button, mx, my, xrel, yrel, bx, by, event)
			game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, desc)
		end
		if not game.mouse:updateZone("tbuff"..eff_id, bx+x, by+y, hs, hs, desc_fct) then
			game.mouse:unregisterZone("tbuff"..eff_id)
			game.mouse:registerZone(bx+x, by+y, hs, hs, desc_fct, nil, "tbuff"..eff_id)
		end

		self.tbuff[eff_id..":"..dur] = {eff_id, "tbuff"..eff_id, function(x, y)
			core.display.drawQuad(x, y, hs, hs, 0, 0, 0, 255)
			e.display_entity:toScreen(self.hotkeys_display_icons.tiles, x+4, y+4, 32, 32)
			UI:drawFrame(self.buffs_base, x, y, icon[1], icon[2], icon[3], 1)
			if txt then
				txt._tex:toScreenFull(x+4+2 + (40 - txt.fw)/2, y+4+2 + (40 - txt.fh)/2, txt.w, txt.h, txt._tex_w, txt._tex_h, 0, 0, 0, 0.7)
				txt._tex:toScreenFull(x+4 + (40 - txt.fw)/2, y+4 + (40 - txt.fh)/2, txt.w, txt.h, txt._tex_w, txt._tex_h)
			end
		end}
	end

	self.tbuff[eff_id..":"..dur][3](x, y)
end

function _M:displayBuffs(scale, bx, by)
	local player = game.player
	if player then
		if player.changed then
			for _, d in pairs(self.pbuff) do if not player.sustain_talents[d[1]] then game.mouse:unregisterZone(d[2]) end end
			for _, d in pairs(self.tbuff) do if not player.tmp[d[1]] then game.mouse:unregisterZone(d[2]) end end
			self.tbuff = {} self.pbuff = {}
		end

		local hs = 40
		local stop = self.map_h_stop - hs
		local x, y = -hs, 0

		for tid, act in pairs(player.sustain_talents) do
			if act then
				if not self.pbuff[tid] then
					local t = player:getTalentFromId(tid)
					local displayName = t.name
					if t.getDisplayName then displayName = t.getDisplayName(player, t, player:isTalentActive(tid)) end
					local desc = "#GOLD##{bold}#"..displayName.."#{normal}##WHITE#\n"..tostring(player:getTalentFullDescription(t))

					if not game.mouse:updateZone("pbuff"..tid, bx+x, by+y, hs, hs) then
						game.mouse:unregisterZone("pbuff"..tid)
						game.mouse:registerZone(bx+x, by+y, hs, hs, function(button, mx, my, xrel, yrel, bx, by, event)
							game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, desc)
						end, nil, "pbuff"..tid)
					end

					self.pbuff[tid] = {tid, "pbuff"..tid, function(x, y)
						core.display.drawQuad(x, y, hs, hs, 0, 0, 0, 255)
						t.display_entity:toScreen(self.hotkeys_display_icons.tiles, x+4, y+4, 32, 32)
						UI:drawFrame(self.buffs_base, x, y, frames_colors.sustain[1], frames_colors.sustain[2], frames_colors.sustain[3], 1)
					end}
				end

				self.pbuff[tid][3](x, y)

				y = y + hs
				if y + hs >= stop then y = 0 x = x - hs end
			end
		end

		local good_e, bad_e = {}, {}
		for eff_id, p in pairs(player.tmp) do
			local e = player.tempeffect_def[eff_id]
			if e.status == "detrimental" then bad_e[eff_id] = p else good_e[eff_id] = p end
		end

		for eff_id, p in pairs(good_e) do
			local e = player.tempeffect_def[eff_id]
			self:handleEffect(player, eff_id, e, p, x, y, hs, bx, by)
			y = y + hs
			if y + hs >= stop then y = 0 x = x - hs end
		end
		for eff_id, p in pairs(bad_e) do
			local e = player.tempeffect_def[eff_id]
			self:handleEffect(player, eff_id, e, p, x, y, hs, bx, by)
			y = y + hs
			if y + hs >= stop then y = 0 x = x - hs end
		end
	end
end

function _M:displayParty(scale, bx, by)
	if game.player.changed and next(self.party) then
		for a, d in pairs(self.party) do if not game.party:hasMember(a) then game.mouse:unregisterZone(d[2]) print("==UNREG part ", d[1].name, d[2]) end end
		self.party = {}
	end

	-- Party members
	if #game.party.m_list >= 2 and game.level then
		local hs = portrait[7] + 3
		local stop = self.map_h_stop - hs
		local x, y = 0, 0

		for i = 1, #game.party.m_list do
			local a = game.party.m_list[i]

			if not self.party[a] then
				local def = game.party.members[a]

				self.party[a] = {a, "party"..a.uid, function(x, y)
					core.display.drawQuad(x, y, 40, 40, 0, 0, 0, 255)
					if life_sha.shad then life_sha.shad:use(true) end
					local p = math.min(1, math.max(0, a.life / a.max_life))
					core.display.drawQuad(x+1, y+1 + (1-p)*hs, 38, p*38, life_c[1]*255, life_c[2]*255, life_c[3]*255, 178)
					if life_sha.shad then life_sha.shad:use(false) end

					a:toScreen(nil, x+4, y+4, 32, 32)
					local p = (game.player == a) and portrait or portrait_unsel
					p[1]:toScreenFull(x, y, p[6], p[7], p[2], p[3])
				end}

				local text = "#GOLD##{bold}#"..a.name.."\n#WHITE##{normal}#Life: "..math.floor(100 * a.life / a.max_life).."%\nLevel: "..a.level.."\n"..def.title
				local desc_fct = function(button, mx, my, xrel, yrel, bx, by, event)
					game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, text)
					if event == "button" and button == "left" then if def.control == "full" then game.party:select(a) end end
				end
				if not game.mouse:updateZone("party"..a.uid, bx+x, by+y, hs, hs, desc_fct) then
					game.mouse:unregisterZone("party"..a.uid)
					game.mouse:registerZone(bx+x, by+y, hs, hs, desc_fct, nil, "party"..a.uid)
				end
			end

			self.party[a][3](x, y)

			x = x + hs
			if x + hs > stop then x = 0 y = y - hs end
		end

		-- Compute how much space to reserve on the side
--		Map.viewport_padding_8 = math.floor(scale * y / Map.tile_w)
	end
end

function _M:displayPlayer(scale, bx, by)
	local player = game.player
	if not game.player then return end

	pf_shadow[1]:toScreenFull(0, 0, pf_shadow[6], pf_shadow[7], pf_shadow[2], pf_shadow[3])
	pf_bg[1]:toScreenFull(0, 0, pf_bg[6], pf_bg[7], pf_bg[2], pf_bg[3])
	player:toScreen(nil, 22, 22, 40, 40)

	if (not config.settings.tome.actor_based_movement_mode and self or player).bump_attack_disabled then
		pf_defend[1]:toScreenFull(22, 67, pf_defend[6], pf_defend[7], pf_defend[2], pf_defend[3])
	else
		pf_attack[1]:toScreenFull(22, 67, pf_attack[6], pf_attack[7], pf_attack[2], pf_attack[3])
	end

	if player.unused_stats > 0 or player.unused_talents > 0 or player.unused_generics > 0 or player.unused_talents_types > 0 then
		local glow = (1+math.sin(core.game.getTime() / 500)) / 2 * 100 + 120
		pf_levelup[1]:toScreenFull(269, 78, pf_levelup[6], pf_levelup[7], pf_levelup[2], pf_levelup[3], 1, 1, 1, glow / 255)
		pf_exp_levelup[1]:toScreenFull(108, 74, pf_exp_levelup[6], pf_exp_levelup[7], pf_exp_levelup[2], pf_exp_levelup[3], 1, 1, 1, glow / 255)
	end

	local cur_exp, max_exp = player.exp, player:getExpChart(player.level+1)
	local p = math.min(1, math.max(0, cur_exp / max_exp))
	pf_exp[1]:toScreenPrecise(117, 85, pf_exp[6] * p, pf_exp[7], 0, p * 1/pf_exp[4], 0, 1/pf_exp[5])

	if not self.res.exp or self.res.exp.vc ~= p then
		self.res.exp = {
			vc = p,
			cur = {core.display.drawStringBlendedNewSurface(sfont_sha, ("%d%%"):format(p * 100), 255, 255, 255):glTexture()},
		}
	end
	local dt = self.res.exp.cur
	dt[1]:toScreenFull(2+87 - dt[6] / 2, 2+89 - dt[7] / 2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
	dt[1]:toScreenFull(87 - dt[6] / 2, 89 - dt[7] / 2, dt[6], dt[7], dt[2], dt[3])

	if not self.res.money or self.res.money.vc ~= player.money then
		self.res.money = {
			vc = player.money,
			cur = {core.display.drawStringBlendedNewSurface(font_sha, ("%d"):format(player.money), 255, 215, 0):glTexture()},
		}
	end
	local dt = self.res.money.cur
	dt[1]:toScreenFull(2+112 - dt[6] / 2, 2+43, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
	dt[1]:toScreenFull(112 - dt[6] / 2, 43, dt[6], dt[7], dt[2], dt[3])

	if not self.res.pname or self.res.pname.vc ~= player.name then
		self.res.pname = {
			vc = player.name,
			cur = {core.display.drawStringBlendedNewSurface(font_sha, player.name, 255, 255, 255):glTexture()},
		}
	end
	local dt = self.res.pname.cur
	dt[1]:toScreenFull(2+166, 2+13, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
	dt[1]:toScreenFull(166, 13, dt[6], dt[7], dt[2], dt[3])

	if not self.res.plevel or self.res.plevel.vc ~= player.level then
		self.res.plevel = {
			vc = player.level,
			cur = {core.display.drawStringBlendedNewSurface(font_sha, "Lvl "..player.level, 255, 255, 255):glTexture()},
		}
	end
	local dt = self.res.plevel.cur
	dt[1]:toScreenFull(2+253, 2+46, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7)
	dt[1]:toScreenFull(253, 46, dt[6], dt[7], dt[2], dt[3])

	if player:attr("encumbered") then
		local glow = (1+math.sin(core.game.getTime() / 500)) / 2 * 100 + 120
		pf_encumber[1]:toScreenFull(162, 38, pf_encumber[6], pf_encumber[7], pf_encumber[2], pf_encumber[3], 1, 1, 1, glow / 255)
	end

	if self.mhandle.player then
		move_handle[1]:toScreenFull(self.mhandle_pos.player.x, self.mhandle_pos.player.y, move_handle[6], move_handle[7], move_handle[2], move_handle[3])
	end

	if not game.mouse:updateZone("pframe", bx, by, pf_bg[6], pf_bg[7], nil, scale) then
		game.mouse:unregisterZone("pframe")

		local desc_fct = function(button, mx, my, xrel, yrel, bx, by, event)
			if event == "out" then self.mhandle.player = nil return
			else self.mhandle.player = true end

			-- Attack/defend
			if bx >= 22 and bx <= 22 + pf_defend[6] and by >= 67 and by <= 67 + pf_defend[7] then
				game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, "Toggle for movement mode")
				if event == "button" and button == "left" then game.key:triggerVirtual("TOGGLE_BUMP_ATTACK") end
			-- Character sheet
			elseif bx >= 22 and bx <= 22 + 40 and by >= 22 and by <= 22 + 40 then
				game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, "Show character infos")
				if event == "button" and button == "left" then game.key:triggerVirtual("SHOW_CHARACTER_SHEET") end
			-- Levelup
			elseif bx >= 269 and bx <= 269 + pf_levelup[6] and by >= 78 and by <= 78 + pf_levelup[7] and (player.unused_stats > 0 or player.unused_talents > 0 or player.unused_generics > 0 or player.unused_talents_types > 0) then
				game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, "Click to assign stats and talents!")
				if event == "button" and button == "left" then game.key:triggerVirtual("LEVELUP") end
			-- Move handle
			elseif bx >= self.mhandle_pos.player.x and bx <= self.mhandle_pos.player.x + move_handle[6] and by >= self.mhandle_pos.player.y and by <= self.mhandle_pos.player.y + move_handle[7] then
				self:uiMoveResize("player", button, mx, my, xrel, yrel, bx, by, event)
			end
		end
		game.mouse:registerZone(bx, by, pf_bg[6], pf_bg[7], desc_fct, nil, "pframe", true, scale)
	end
end

function _M:displayMinimap(scale, bx, by)
	if self.no_minimap then return end

	local map = game.level.map

	mm_shadow[1]:toScreenFull(0, 2, mm_shadow[6], mm_shadow[7], mm_shadow[2], mm_shadow[3])
	mm_bg[1]:toScreenFull(0, 0, mm_bg[6], mm_bg[7], mm_bg[2], mm_bg[3])
	if game.player.x then game.minimap_scroll_x, game.minimap_scroll_y = util.bound(game.player.x - 25, 0, map.w - 50), util.bound(game.player.y - 25, 0, map.h - 50)
	else game.minimap_scroll_x, game.minimap_scroll_y = 0, 0 end

	mm_comp[1]:toScreenFull(169, 178, mm_comp[6], mm_comp[7], mm_comp[2], mm_comp[3])

	map:minimapDisplay(50, 30, game.minimap_scroll_x, game.minimap_scroll_y, 50, 50, 0.85)
	mm_transp[1]:toScreenFull(50, 30, mm_transp[6], mm_transp[7], mm_transp[2], mm_transp[3])

	if self.mhandle.minimap then
		move_handle[1]:toScreenFull(self.mhandle_pos.minimap.x, self.mhandle_pos.minimap.y, move_handle[6], move_handle[7], move_handle[2], move_handle[3])
	end

	if not game.mouse:updateZone("minimap", bx, by, mm_bg[6], mm_bg[7], nil, scale) then
		game.mouse:unregisterZone("minimap")

		local desc_fct = function(button, mx, my, xrel, yrel, bx, by, event)
			if event == "out" then self.mhandle.minimap = nil return
			else self.mhandle.minimap = true end

			game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, "Left mouse to move\nRight mouse to scroll\nMiddle mouse to show full map")

			-- Move handle
			if bx >= self.mhandle_pos.minimap.x and bx <= self.mhandle_pos.minimap.x + move_handle[6] and by >= self.mhandle_pos.minimap.y and by <= self.mhandle_pos.minimap.y + move_handle[7] then
				self:uiMoveResize("minimap", button, mx, my, xrel, yrel, bx, by, event)
				return
			end

			if bx >= 50 and bx <= 50 + 150 and by >= 30 and by <= 30 + 150 then
				if button == "left" and not xrel and not yrel and event == "button" then
					local tmx, tmy = math.floor((bx-50) / 3), math.floor((by-30) / 3)
					game.player:mouseMove(tmx + game.minimap_scroll_x, tmy + game.minimap_scroll_y)
				elseif button == "right" then
					local tmx, tmy = math.floor((bx-50) / 3), math.floor((by-30) / 3)
					game.level.map:moveViewSurround(tmx + game.minimap_scroll_x, tmy + game.minimap_scroll_y, 1000, 1000)
				elseif event == "button" and button == "middle" then
					game.key:triggerVirtual("SHOW_MAP")
				end
			end
		end
		game.mouse:registerZone(bx, by, pf_bg[6], pf_bg[7], desc_fct, nil, "minimap", true, scale)
	end
end

function _M:display(nb_keyframes)
	local d = core.display

	-- Now the map, if any
	game:displayMap(nb_keyframes)

	if self.no_ui then return end

	-- Minimap display
	if game.level and game.level.map then
		d.glTranslate(self.places.minimap.x, self.places.minimap.y, 0)
		d.glScale(self.places.minimap.scale, self.places.minimap.scale, self.places.minimap.scale)
		self:displayMinimap(self.places.minimap.scale, self.places.minimap.x, self.places.minimap.y)
		d.glScale()
		d.glTranslate(-self.places.minimap.x, -self.places.minimap.y, -0)

		self.side_8 = mm_bg[7]
	end

	-- Player
	d.glTranslate(self.places.player.x, self.places.player.y, 0)
	d.glScale(self.places.player.scale, self.places.player.scale, self.places.player.scale)
	self:displayPlayer(self.places.player.scale, self.places.player.x, self.places.player.y)
	d.glScale()
	d.glTranslate(-self.places.player.x, -self.places.player.y, -0)

	-- Resources
	d.glTranslate(self.places.resources.x, self.places.resources.y, 0)
	d.glScale(self.places.resources.scale, self.places.resources.scale, self.places.resources.scale)
	self:displayResources(self.places.resources.scale, self.places.resources.x, self.places.resources.y)
	d.glScale()
	d.glTranslate(-self.places.resources.x, -self.places.resources.y, -0)

	-- Buffs
	d.glTranslate(game.w, self.side_8, 0)
	self:displayBuffs(1, game.w, self.side_8)
	d.glTranslate(-game.w, -self.side_8, -0)

	-- Party
	d.glTranslate(self.side_4, 0, 0)
	self:displayParty(1, self.side_4, 0)
	d.glTranslate(-self.side_4, -0, -0)

	-- We display the player's interface
	profile.chat:toScreen()
	self.logdisplay:toScreen()

	if game.show_npc_list then
		self.npcs_display:toScreen()
	else
		self.hotkeys_display:toScreen()
	end

	sep[1]:toScreenFull(0, self.map_h_stop_up, game.w, sep[7], sep[2], sep[3])
	sep_vines[1]:toScreenFull(0, self.map_h_stop_up - 3, game.w, sep_vines[7], sep_vines[2], sep_vines[3])
end

function _M:setupMouse(mouse)
	-- Scroll message log
	mouse:registerZone(profile.chat.display_x, profile.chat.display_y, profile.chat.w, profile.chat.h, function(button, mx, my, xrel, yrel, bx, by, event)
		profile.chat.mouse:delegate(button, mx, my, xrel, yrel, bx, by, event)
	end)
	-- Use hotkeys with mouse
	mouse:registerZone(self.hotkeys_display.display_x, self.hotkeys_display.display_y, game.w, game.h, function(button, mx, my, xrel, yrel, bx, by, event)
		if self.show_npc_list then return end
		if event == "out" then self.hotkeys_display.cur_sel = nil return end
		if event == "button" and button == "left" and ((self.zone and self.zone.wilderness) or (game.key ~= game.normal_key)) then return end
		self.hotkeys_display:onMouse(button, mx, my, event == "button",
			function(text)
				text = text:toTString()
				text:add(true, "---", true, {"font","italic"}, {"color","GOLD"}, "Left click to use", true, "Right click to configure", true, "Press 'm' to setup", {"color","LAST"}, {"font","normal"})
				game:tooltipDisplayAtMap(game.w, game.h, text)
			end,
			function(i, hk)
				if button == "right" and hk[1] == "talent" then
					local d = require("mod.dialogs.UseTalents").new(game.player)
					d:use({talent=hk[2], name=game.player:getTalentFromId(hk[2]).name}, "right")
					return true
				end
			end
		)
	end, nil, "hotkeys", true)

	-- Chat tooltips
	profile.chat:onMouse(function(user, item, button, event, x, y, xrel, yrel, bx, by)
		local mx, my = core.mouse.get()
		if not item or not user or item.faded == 0 then game.mouse:delegate(button, mx, my, xrel, yrel, nil, nil, event, "playmap") return end

		local str = tstring{{"color","GOLD"}, {"font","bold"}, user.name, {"color","LAST"}, {"font","normal"}, true}
		if user.donator and user.donator ~= "none" then
			local text, color = "Donator", colors.WHITE
			if user.donator == "oneshot" then text, color = "Donator", colors.LIGHT_GREEN
			elseif user.donator == "recurring" then text, color = "Recurring Donator", colors.LIGHT_BLUE end
			str:add({"color",unpack(colors.simple(color))}, text, {"color", "LAST"}, true)
		end
		str:add({"color","ANTIQUE_WHITE"}, "Playing: ", {"color", "LAST"}, user.current_char, true)
		str:add({"color","ANTIQUE_WHITE"}, "Game: ", {"color", "LAST"}, user.module, "(", user.valid, ")",true)

		local extra = {}
		if item.extra_data and item.extra_data.mode == "tooltip" then
			local rstr = tstring{item.extra_data.tooltip, true, "---", true, "Linked by: "}
			rstr:merge(str)
			extra.log_str = rstr
		else
			extra.log_str = str
			if button == "right" and event == "button" then
				extra.add_map_action = { name="Show chat user", fct=function() profile.chat:showUserInfo(user.login) end }
			end
		end
		game.mouse:delegate(button, mx, my, xrel, yrel, nil, nil, event, "playmap", extra)
	end)
end
