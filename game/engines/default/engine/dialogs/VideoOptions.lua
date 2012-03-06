-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
local TreeList = require "engine.ui.TreeList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local GetQuantity = require "engine.dialogs.GetQuantity"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "Video Options", game.w * 0.8, game.h * 0.8)

	self.c_desc = Textzone.new{width=math.floor(self.iw / 2 - 10), height=self.ih, text=""}

	self:generateList()

	self.c_list = TreeList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, scrollbar=true, columns={
		{width=60, display_prop="name"},
		{width=40, display_prop="status"},
	}, tree=self.list, fct=function(item) end, select=function(item, sel) self:select(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=0, ui=self.c_desc},
		{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:select(item)
	if item and self.uis[2] then
		self.uis[2].ui = item.zone
	end
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local i = 0

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text="Display resolution."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Resolution#WHITE##{normal}#", status=function(item)
		return config.settings.window.size
	end, fct=function(item)
		local menu = require("engine.dialogs.DisplayResolution").new(function() self.c_list:drawItem(item) end)
		game:registerDialog(menu)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Request this display refresh rate.\nSet it lower to reduce CPU load, higher to increase interface responsiveness.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Requested FPS#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.display_fps)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("Enter density", "From 5 to 60", config.settings.display_fps, 60, function(qty)
			qty = util.bound(qty, 5, 60)
			game:saveSettings("display_fps", ("display_fps = %d\n"):format(qty))
			config.settings.display_fps = qty
			core.game.setFPS(qty)
			self.c_list:drawItem(item)
		end), 5)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Controls the particle effects density.\nThis option allows to change the density of the many particle effects in the game.\nIf the game is slow when displaying spell effects try to lower this setting.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Particle effects density#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.particles_density)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("Enter density", "From 0 to 100", config.settings.particles_density, 100, function(qty)
			game:saveSettings("particles_density", ("particles_density = %d\n"):format(qty))
			config.settings.particles_density = qty
			self.c_list:drawItem(item)
		end))
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Activates antialiased texts.\nTexts will look nicer but it can be slower on some computers.\n\n#LIGHT_RED#You must restart the game for it to take effect.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Antialiased texts#WHITE##{normal}#", status=function(item)
		return tostring(core.display.getTextBlended() and "enabled" or "disabled")
	end, fct=function(item)
		local state = not core.display.getTextBlended()
		core.display.setTextBlended(state)
		game:saveSettings("aa_text", ("aa_text = %s\n"):format(tostring(state)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Activates framebuffers.\nThis option allows for some special graphical effects.\nIf you encounter weird graphical glitches try to disable it.\n\n#LIGHT_RED#You must restart the game for it to take effect.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Framebuffers#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.fbo_active and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.fbo_active = not config.settings.fbo_active
		game:saveSettings("fbo_active", ("fbo_active = %s\n"):format(tostring(config.settings.fbo_active)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Activates OpenGL Shaders.\nThis option allows for some special graphical effects.\nIf you encounter weird graphical glitches try to disable it.\n\n#LIGHT_RED#You must restart the game for it to take effect.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#OpenGL Shaders#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.shaders_active and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.shaders_active = not config.settings.shaders_active
		game:saveSettings("shaders_active", ("shaders_active = %s\n"):format(tostring(config.settings.shaders_active)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Use the custom cursor.\nDisabling it will use your normal operating system cursor.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Mouse cursor#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.mouse_cursor and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.mouse_cursor = not config.settings.mouse_cursor
		game:updateMouseCursor()
		game:saveSettings("mouse_cursor", ("mouse_cursor = %s\n"):format(tostring(config.settings.mouse_cursor)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Gamma correction setting.\nIncrease this to get a brighter display.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Gamma correction#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.gamma_correction)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("Gamma correction", "From 50 to 300", config.settings.gamma_correction, 300, function(qty)
			qty = util.bound(qty, 50, 300)
			game:saveSettings("gamma_correction", ("gamma_correction = %d\n"):format(qty))
			config.settings.gamma_correction = qty
			game:setGamma(config.settings.gamma_correction / 100)
			self.c_list:drawItem(item)
		end), 50)
	end,}

	self.list = list
end
