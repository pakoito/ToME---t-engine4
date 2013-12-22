-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
local List = require "engine.ui.List"
local Checkbox = require "engine.ui.Checkbox"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(on_change)
	self.on_change = on_change
	self:generateList()

	local w, h, fullscreen, borderless = core.display.size()

	Dialog.init(self, "Switch Resolution", 300, 20)

	self.c_list = List.new{width=self.iw, nb_items=#self.list, list=self.list, fct=function(item) self:use(item) end}
	self.c_fs = Checkbox.new{title="Fullscreen", default=fullscreen,
		fct=function() end,
		on_change=function(s) if s then self.c_bl.checked = false end end
	}
	self.c_bl = Checkbox.new{title="Borderless", default=borderless,
		fct=function() end,
		on_change=function(s) if s then self.c_fs.checked = false end end
	}

	self:loadUI{
		{left=0, top=0, ui=self.c_fs},
		{left=self.c_fs.w + 5, top=0, ui=self.c_bl},
		{left=0, top=self.c_fs.h, ui=self.c_list},
	}
	self:setFocus(self.c_list)
	self:setupUI(true, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:use(item)
	local mode = " Windowed"
	if self.c_fs.checked then mode = " Fullscreen"
	elseif self.c_bl.checked then mode = " Borderless"
	end
	local r = item.r..mode
	local _, _, w, h = r:find("^([0-9]+)x([0-9]+)")
	
	-- See if we need a restart (confirm).
	if core.display.setWindowSizeRequiresRestart(w, h, self.c_fs.checked
		, self.c_bl.checked) then
		Dialog:yesnoPopup("Engine Restart Required"
			, "Continue?" .. (game.creating_player and "" or " (progress will be saved)")
			, function(restart)
				if restart then
					local resetPos = Dialog:yesnoPopup("Reset Window Position?"
						, "Simply restart or restart+reset window position?"
						, function(simplyRestart)
							if not simplyRestart then
								core.display.setWindowPos(0, 0)
								game:onWindowMoved(0, 0)
							end
							game:setResolution(r, true)
							-- Save game and reboot
							if not game.creating_player then game:saveGame() end
							util.showMainMenu(false, nil, nil
								, game.__mod_info.short_name, game.save_name
								, false)
						end, "Restart", "Restart with reset")
				end
			end, "Yes", "No")
	else
		game:setResolution(r, true)
	end
	
	game:unregisterDialog(self)
	if self.on_change then self.on_change(r) end
end

function _M:generateList()
	local l = {}
	local seen = {}
	for r, d in pairs(game.available_resolutions) do
		seen[d[1]] = seen[d[1]] or {}
		if not seen[d[1]][d[2]] then 
			l[#l+1] = r
			seen[d[1]][d[2]] = true
		end
	end
	table.sort(l, function(a,b)
		if game.available_resolutions[a][2] == game.available_resolutions[b][2] then
			return (game.available_resolutions[a][3] and 1 or 0) < (game.available_resolutions[b][3] and 1 or 0)
		elseif game.available_resolutions[a][1] == game.available_resolutions[b][1] then
			return game.available_resolutions[a][2] < game.available_resolutions[b][2]
		else
			return game.available_resolutions[a][1] < game.available_resolutions[b][1]
		end
	end)

	-- Makes up the list
	local list = {}
	local i = 0
	for _, r in ipairs(l) do
		local _, _, w, h = r:find("^([0-9]+)x([0-9]+)")
		local r = w.."x"..h
		list[#list+1] = { name=string.char(string.byte('a') + i)..")  "..r, r=r }
		i = i + 1
	end
	self.list = list
end
