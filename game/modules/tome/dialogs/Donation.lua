-- ToME - Tales of Maj'Eyal
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
local Separator = require "engine.ui.Separator"
local List = require "engine.ui.List"
local Button = require "engine.ui.Button"
local Numberbox = require "engine.ui.Numberbox"
local Textzone = require "engine.ui.Textzone"
local Checkbox = require "engine.ui.Checkbox"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(source)
	self.donation_source = source or "ingame"
	Dialog.init(self, "Donations", 500, 300)

	local desc
	local recur = false

	if not profile.auth or not tonumber(profile.auth.donated) or tonumber(profile.auth.donated) <= 1 then
		-- First time donation
		desc = Textzone.new{width=self.iw, auto_height=true, text=[[Hi, I am Nicolas (DarkGod), the maker of this game.
It is my dearest hope that you find my game enjoyable, and that you will continue to do so for many years to come!

ToME is free and open-source and will stay that way, but that does not mean I can live without money, so I have come to disturb you here and now to ask for your kindness.
If you feel that the (many) hours you have spent having fun were worth it, please consider making a donation for the future of the game.

Donators are also granted a few special features: #GOLD#Custom character tiles#WHITE# and #GOLD#Exploration mode (infinite lives)#WHITE#.]]}
	else
		-- Recurring donation
		recur = true
		desc = Textzone.new{width=self.iw, auto_height=true, text=[[Thank you for supporting ToME, your donation was greatly appreciated.
If you want to continue supporting ToME you are welcome to make a new donation or even a reccuring one which helps ensure the future of the game.
Thank you for your kindness!]]}
	end

	self.c_donate = Numberbox.new{title="Donation amount: ", number=10, max=1000, min=5, chars=5, fct=function() end}
	local euro = Textzone.new{auto_width=true, auto_height=true, text=[[€]]}
	self.c_recur = Checkbox.new{title="Make it a recurring montly donation", default=recur, fct=function() end}
	local ok = require("engine.ui.Button").new{text="Accept", fct=function() self:ok() end}
	local cancel = require("engine.ui.Button").new{text="Cancel", fct=function() self:cancel() end}

	self:loadUI{
		{left=0, top=0, ui=desc},
		{left=5, bottom=5 + ok.h, ui=self.c_donate},
		{left=5+self.c_donate.w, bottom=10 + ok.h, ui=euro},
		{right=5, bottom=5 + ok.h, ui=self.c_recur},
		{left=0, bottom=0, ui=ok},
		{right=0, bottom=0, ui=cancel},
	}
	self:setFocus(self.c_donate)
	self:setupUI(false, true)
end

function _M:cancel()
	game:unregisterDialog(self)
end

function _M:ok()
	if not tonumber(self.c_donate.number) or tonumber(self.c_donate.number) < 5 then return end

	game:unregisterDialog(self)
	self:simplePopup("Thank you", "Thank you, a paypal page should now open in your browser.")

	local url = ("http://te4.org/ingame-donate/%s/%s/%s/EUR/%s"):format(self.c_donate.number, self.c_recur.checked and "monthly" or "onetime", (profile.auth and profile.auth.drupid) and profile.auth.drupid or "0", self.donation_source)
	util.browserOpenUrl(url)
end
