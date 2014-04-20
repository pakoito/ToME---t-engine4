-- ToME - Tales of Maj'Eyal
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
local TreeList = require "engine.ui.TreeList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local GetQuantity = require "engine.dialogs.GetQuantity"
local Tabs = require "engine.ui.Tabs"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "Game Options", game.w * 0.8, game.h * 0.8)

	self.c_desc = Textzone.new{width=math.floor(self.iw / 2 - 10), height=self.ih, text=""}

	local tabs = {
		{title="UI", kind="ui"},
		{title="Gameplay", kind="gameplay"},
		{title="Online", kind="online"},
		{title="Misc", kind="misc"}
	}
	self:triggerHook{"GameOptions:tabs", tab=function(title, fct)
		local id = #tabs+1
		tabs[id] = {title=title, kind="hooktab"..id}
		self['generateListHooktab'..id] = fct
	end}

	self.c_tabs = Tabs.new{width=self.iw - 5, tabs=tabs, on_change=function(kind) self:switchTo(kind) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_tabs},
		{left=0, top=self.c_tabs.h, ui=self.c_list},
		{right=0, top=self.c_tabs.h, ui=self.c_desc},
		{hcenter=0, top=5+self.c_tabs.h, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:select(item)
	if item and self.uis[3] then
		self.uis[3].ui = item.zone
	end
end

function _M:switchTo(kind)
	self['generateList'..kind:capitalize()](self)
	self:triggerHook{"GameOptions:generateList", list=self.list, kind=kind}

	self.c_list = TreeList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, scrollbar=true, columns={
		{width=60, display_prop="name"},
		{width=40, display_prop="status"},
	}, tree=self.list, fct=function(item) end, select=function(item, sel) self:select(item) end}
	if self.uis and self.uis[2] then
		self.c_list.mouse.delegate_offset_x = self.uis[2].ui.mouse.delegate_offset_x
		self.c_list.mouse.delegate_offset_y = self.uis[2].ui.mouse.delegate_offset_y
		self.uis[2].ui = self.c_list
	end
end

function _M:generateListUi()
	-- Makes up the list
	local list = {}
	local i = 0

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Make the movement of creatures and projectiles 'smooth'. When set to 0 movement will be instantaneous.\nThe higher this value the slower the movements will appear.\n\nNote: This does not affect the turn-based idea of the game. You can move again while your character is still moving, and it will correctly update and compute a new animation."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Smooth creatures movement#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.smooth_move)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("Enter movement speed(lower is faster)", "From 0 to 60", config.settings.tome.smooth_move, 60, function(qty)
			game:saveSettings("tome.smooth_move", ("tome.smooth_move = %d\n"):format(qty))
			config.settings.tome.smooth_move = qty
			engine.Map.smooth_scroll = qty
			self.c_list:drawItem(item)
		end))
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Enables or disables 'twitch' movement.\nWhen enabled creatures will do small bumps when moving and attacking.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Twitch creatures movement and attack#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.twitch_move and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.tome.twitch_move = not config.settings.tome.twitch_move
		game:saveSettings("tome.twitch_move", ("tome.twitch_move = %s\n"):format(tostring(config.settings.tome.twitch_move)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Enables smooth fog-of-war.\nDisabling it will make the fog of war look 'blocky' but might gain a slight performance increase.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Smooth fog of war#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.smooth_fov and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.tome.smooth_fov = not config.settings.tome.smooth_fov
		game:saveSettings("tome.smooth_fov", ("tome.smooth_fov = %s\n"):format(tostring(config.settings.tome.smooth_fov)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Select the interface look. Metal is the default one. Simple is basic but takes less screen space.\nYou must restart the game for the change to take effect."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Interface Style#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.ui_theme2):capitalize()
	end, fct=function(item)
		local uis = {{name="Metal", ui="metal"}, {name="Stone", ui="stone"}, {name="Simple", ui="simple"}}
		self:triggerHook{"GameOptions:UIs", uis=uis}
		Dialog:listPopup("Interface style", "Select style", uis, 300, 200, function(sel)
			if not sel or not sel.ui then return end
			game:saveSettings("tome.ui_theme2", ("tome.ui_theme2 = %q\n"):format(sel.ui))
			config.settings.tome.ui_theme2 = sel.ui
			self.c_list:drawItem(item)
		end)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Select the HUD look. 'Minimalist' is the default one.\n#LIGHT_RED#This will take effect on next restart."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#HUD Style#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.uiset_mode):capitalize()
	end, fct=function(item)
		local huds = {{name="Minimalist", ui="Minimalist"}, {name="Classic", ui="Classic"}}
		self:triggerHook{"GameOptions:HUDs", huds=huds}
		Dialog:listPopup("HUD style", "Select style", huds, 300, 200, function(sel)
			if not sel or not sel.ui then return end
			game:saveSettings("tome.uiset_mode", ("tome.uiset_mode = %q\n"):format(sel.ui))
			config.settings.tome.uiset_mode = sel.ui
			self.c_list:drawItem(item)
		end)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Select the fonts look. Fantasy is the default one. Basic is simplified and smaller.\nYou must restart the game for the change to take effect."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Font Style#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.fonts.type):capitalize()
	end, fct=function(item)
		Dialog:listPopup("Font style", "Select font", {{name="Fantasy", type="fantasy"}, {name="Basic", type="basic"}}, 300, 200, function(sel)
			if not sel or not sel.type then return end
			game:saveSettings("tome.fonts", ("tome.fonts = { type = %q, size = %q }\n"):format(sel.type, config.settings.tome.fonts.size))
			config.settings.tome.fonts.type = sel.type
			self.c_list:drawItem(item)
		end)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Select the fonts size.\nYou must restart the game for the change to take effect."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Font Size#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.fonts.size):capitalize()
	end, fct=function(item)
		Dialog:listPopup("Font size", "Select font", {{name="Normal", size="normal"},{name="Small", size="small"},{name="Big", size="big"},}, 300, 200, function(sel)
			if not sel or not sel.size then return end
			game:saveSettings("tome.fonts", ("tome.fonts = { type = %q, size = %q }\n"):format(config.settings.tome.fonts.type, sel.size))
			config.settings.tome.fonts.size = sel.size
			self.c_list:drawItem(item)
		end)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"How many seconds before log and chat lines begin to fade away.\nIf set to 0 the logs will never fade away."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Log fade time#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.log_fade)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("Fade time (in seconds)", "From 0 to 20", config.settings.tome.log_fade, 20, function(qty)
			qty = util.bound(qty, 0, 20)
			game:saveSettings("tome.log_fade", ("tome.log_fade = %d\n"):format(qty))
			config.settings.tome.log_fade = qty
			game.uiset.logdisplay:enableFading(config.settings.tome.log_fade)
			profile.chat:enableFading(config.settings.tome.log_fade)
			self.c_list:drawItem(item)
		end, 0))
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"How long will flying text messages be visible on screen.\nThe range is 1 (very short) to 100 (10x slower) than the normal duration, which varies with each individual message."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Duration of flying text#WHITE##{normal}#", status=function(item)
		return tostring((config.settings.tome.flyers_fade_time or 10) )
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("Relative duration", "From 1 to 100", (config.settings.tome.flyers_fade_time or 10), 100, function(qty)
			qty = util.bound(qty, 1, 100)
			config.settings.tome.flyers_fade_time = qty
			game:saveSettings("tome.flyers_fade_time", ("tome.flyers_fade_time = %d\n"):format(qty))
			self.c_list:drawItem(item)
		end, 1))
	end,}

	if game.uiset:checkGameOption("icons_temp_effects") then
		local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Uses the icons for status effects instead of text.#WHITE#"}
		list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Icons status effects#WHITE##{normal}#", status=function(item)
			return tostring(config.settings.tome.effects_icons and "enabled" or "disabled")
		end, fct=function(item)
			config.settings.tome.effects_icons = not config.settings.tome.effects_icons
			game:saveSettings("tome.effects_icons", ("tome.effects_icons = %s\n"):format(tostring(config.settings.tome.effects_icons)))
			game.player.changed = true
			self.c_list:drawItem(item)
		end,}
	end

	if game.uiset:checkGameOption("icons_hotkeys") then
		local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Uses the icons hotkeys toolbar or the textual one.#WHITE#"}
		list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Icons hotkey toolbar#WHITE##{normal}#", status=function(item)
			return tostring(config.settings.tome.hotkey_icons and "enabled" or "disabled")
		end, fct=function(item)
			config.settings.tome.hotkey_icons = not config.settings.tome.hotkey_icons
			game:saveSettings("tome.hotkey_icons", ("tome.hotkey_icons = %s\n"):format(tostring(config.settings.tome.hotkey_icons)))
			game.player.changed = true
			game:resizeIconsHotkeysToolbar()
			self.c_list:drawItem(item)
		end,}
	end

	if game.uiset:checkGameOption("hotkeys_rows") then
		local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Number of rows to show in the icons hotkeys toolbar.#WHITE#"}
		list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Icons hotkey toolbar rows#WHITE##{normal}#", status=function(item)
			return tostring(config.settings.tome.hotkey_icons_rows)
		end, fct=function(item)
			game:registerDialog(GetQuantity.new("Number of icons rows", "From 1 to 4", config.settings.tome.hotkey_icons_rows, 4, function(qty)
				qty = util.bound(qty, 1, 4)
				game:saveSettings("tome.hotkey_icons_rows", ("tome.hotkey_icons_rows = %d\n"):format(qty))
				config.settings.tome.hotkey_icons_rows = qty
				game:resizeIconsHotkeysToolbar()
				self.c_list:drawItem(item)
			end, 1))
		end,}
	end

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Size of the icons in the hotkeys toolbar.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Icons hotkey toolbar icon size#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.hotkey_icons_size)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("Icons size", "From 32 to 64", config.settings.tome.hotkey_icons_size, 64, function(qty)
			qty = util.bound(qty, 32, 64)
			game:saveSettings("tome.hotkey_icons_size", ("tome.hotkey_icons_size = %d\n"):format(qty))
			config.settings.tome.hotkey_icons_size = qty
			game:resizeIconsHotkeysToolbar()
			self.c_list:drawItem(item)
		end, 32))
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"If disabled lore popups will only appear the first time you see the lore on your profile.\nIf enabled it will appear the first time you see it with each character.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Always show lore popup.#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.lore_popup and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.tome.lore_popup = not config.settings.tome.lore_popup
		game:saveSettings("tome.lore_popup", ("tome.lore_popup = %s\n"):format(tostring(config.settings.tome.lore_popup)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"If disabled items with activations will not be auto-added to your hotkeys, you will need to manualty drag them from the inventory screen.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Always add objects to hotkeys.#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.auto_hotkey_object and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.tome.auto_hotkey_object = not config.settings.tome.auto_hotkey_object
		game:saveSettings("tome.auto_hotkey_object", ("tome.auto_hotkey_object = %s\n"):format(tostring(config.settings.tome.auto_hotkey_object)))
		self.c_list:drawItem(item)
	end,}


	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Toggles between a bottom or side display for tactial healthbars.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Healthbars position.#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.small_frame_side and "Sides" or "Bottom")
	end, fct=function(item)
		config.settings.tome.small_frame_side = not config.settings.tome.small_frame_side
		game:saveSettings("tome.small_frame_side", ("tome.small_frame_side = %s\n"):format(tostring(config.settings.tome.small_frame_side)))
		self.c_list:drawItem(item)
	end,}

	self.list = list
end

function _M:generateListGameplay()
	-- Makes up the list
	local list = {}
	local i = 0

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Defines the distance from the screen edge at which scrolling will start. If set high enough the game will always center on the player.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Scroll distance#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.scroll_dist)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("Scroll distance", "From 1 to 30", config.settings.tome.scroll_dist, 30, function(qty)
			qty = util.bound(qty, 1, 30)
			game:saveSettings("tome.scroll_dist", ("tome.scroll_dist = %d\n"):format(qty))
			config.settings.tome.scroll_dist = qty
			self.c_list:drawItem(item)
		end, 1))
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Enables or disables weather effects in some zones.\nDisabling it can gain some performance. It will not affect previously visited zones.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Weather effects#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.weather_effects and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.tome.weather_effects = not config.settings.tome.weather_effects
		game:saveSettings("tome.weather_effects", ("tome.weather_effects = %s\n"):format(tostring(config.settings.tome.weather_effects)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Enables or disables day/night light variations effects..#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Day/night light cycle#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.daynight and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.tome.daynight = not config.settings.tome.daynight
		game:saveSettings("tome.daynight", ("tome.daynight = %s\n"):format(tostring(config.settings.tome.daynight)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Enables easy movement using the mouse by left-clicking on the map.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Use mouse to move#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.mouse_move and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.mouse_move = not config.settings.mouse_move
		game:saveSettings("mouse_move", ("mouse_move = %s\n"):format(tostring(config.settings.mouse_move)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Enables quick melee targeting.\nTalents that require a melee target will automatically target when pressing a direction key instead of requiring a confirmation.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Quick melee targeting#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.immediate_melee_keys and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.tome.immediate_melee_keys = not config.settings.tome.immediate_melee_keys
		game:saveSettings("tome.immediate_melee_keys", ("tome.immediate_melee_keys = %s\n"):format(tostring(config.settings.tome.immediate_melee_keys)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Enables quick melee targeting auto attacking.\nTalents that require a melee target will automatically target and confirm if there is only one hostile creatue around.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Quick melee targeting auto attack#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.immediate_melee_keys_auto and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.tome.immediate_melee_keys_auto = not config.settings.tome.immediate_melee_keys_auto
		game:saveSettings("tome.immediate_melee_keys_auto", ("tome.immediate_melee_keys_auto = %s\n"):format(tostring(config.settings.tome.immediate_melee_keys_auto)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Enables mouse targeting. If disabled mouse movements will not change the target when casting a spell or using a talent.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Mouse targeting#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.disable_mouse_targeting and "disabled" or "enabled")
	end, fct=function(item)
		config.settings.tome.disable_mouse_targeting = not config.settings.tome.disable_mouse_targeting
		game:saveSettings("tome.disable_mouse_targeting", ("tome.disable_mouse_targeting = %s\n"):format(tostring(config.settings.tome.disable_mouse_targeting)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"New games begin with some talent points auto-assigned.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Auto-assign talent points at birth#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.autoassign_talents_on_birth and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.tome.autoassign_talents_on_birth = not config.settings.tome.autoassign_talents_on_birth
		game:saveSettings("tome.autoassign_talents_on_birth", ("tome.autoassign_talents_on_birth = %s\n"):format(tostring(config.settings.tome.autoassign_talents_on_birth)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Always rest to full before auto-exploring.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Rest before auto-explore#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.rest_before_explore and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.tome.rest_before_explore = not config.settings.tome.rest_before_explore
		game:saveSettings("tome.rest_before_explore", ("tome.rest_before_explore = %s\n"):format(tostring(config.settings.tome.rest_before_explore)))
		self.c_list:drawItem(item)
	end,}

	self.list = list
end

function _M:generateListOnline()
	-- Makes up the list
	local list = {}
	local i = 0

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Configure the chat filters to select what kind of messages to see.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Chat message filters#WHITE##{normal}#", status=function(item)
		return "select to configure"
	end, fct=function(item)
		game:registerDialog(require("engine.dialogs.ChatFilter").new({
			{name="Deaths", kind="death"},
			{name="Object & Creatures links", kind="link"},
		}))
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Configure the chat ignore filter.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Chat ignore list#WHITE##{normal}#", status=function(item)
		return "select to configure"
	end, fct=function(item)	game:registerDialog(require("engine.dialogs.ChatIgnores").new()) end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Configure the chat channels to listen to.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Chat channels#WHITE##{normal}#", status=function(item)
		return "select to configure"
	end, fct=function(item)	game:registerDialog(require("engine.dialogs.ChatChannels").new()) end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Allow various events that are pushed by the server when playing online\nDisabling this will make you miss cool and fun zones.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Allow online events#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.allow_online_events and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.tome.allow_online_events = not config.settings.tome.allow_online_events
		game:saveSettings("tome.allow_online_events", ("tome.allow_online_events = %s\n"):format(tostring(config.settings.tome.allow_online_events)))
		self.c_list:drawItem(item)
	end,}

	self.list = list
end

function _M:generateListMisc()
	-- Makes up the list
	local list = {}
	local i = 0

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Saves in the background, allowing you to continue playing.\n#LIGHT_RED#Disabling it is not recommended.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Save in the background#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.background_saves and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.background_saves = not config.settings.background_saves
		game:saveSettings("background_saves", ("background_saves = %s\n"):format(tostring(config.settings.background_saves)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Forces the game to save each level instead of each zone.\nThis makes it save more often but the game will use less memory when deep in a dungeon.\n\n#LIGHT_RED#Changing this option will not affect already visited zones.\n*THIS DOES NOT MAKE A FULL SAVE EACH LEVEL*.\n#LIGHT_RED#Disabling it is not recommended#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Zone save per level#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.save_zone_levels and "enabled" or "disabled")
	end, fct=function(item)
		config.settings.tome.save_zone_levels = not config.settings.tome.save_zone_levels
		game:saveSettings("tome.save_zone_levels", ("tome.save_zone_levels = %s\n"):format(tostring(config.settings.tome.save_zone_levels)))
		self.c_list:drawItem(item)
	end,}

	self.list = list
end
