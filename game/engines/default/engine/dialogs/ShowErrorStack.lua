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
local Button = require "engine.ui.Button"
local Textzone = require "engine.ui.Textzone"
local Textbox = require "engine.ui.Textbox"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(errs)
	errs = table.concat(errs, "\n")
	self.errs = errs
	Dialog.init(self, "Lua Error", 700, 500)

	local md5 = require "md5"
	local errmd5 = md5.sumhexa(errs)
	self.errmd5 = errmd5

	fs.mkdir("/error-reports")
	local errdir = "/error-reports/"..game.__mod_info.short_name.."-"..game.__mod_info.version_name
	self.errdir = errdir
	fs.mkdir(errdir)
	local infos = {}
	local f, err = loadfile(errdir.."/"..errmd5)
	if f then
		setfenv(f, infos)
		if pcall(f) then infos.loaded = true end
	end

	local reason = "If you already reported that error, you do not have to do it again (unless you feel the situation is different)."
	if infos.loaded then
		if infos.reported then reason = "You #LIGHT_GREEN#already reported#WHITE# that error, you do not have to do it again (unless you feel the situation is different)."
		else reason = "You have already got this error but #LIGHT_RED#never reported#WHITE# it, please do."
		end
	else reason = "You have #LIGHT_RED#never seen#WHITE# that error, please report it."
	end

	self:saveError(true, infos.reported)

	local errmsg = Textzone.new{text=[[#{bold}#Oh my! It seems there was an error!
The game might still work but this is suspect, please type in your current situation and click on "Send" to send an error report to the game creator.
If you are not currently connected to the internet, please report this bug when you can on the forums at http://forums.te4.org/

]]..reason..[[#{normal}#]], width=690, auto_height=true}
	local errzone = Textzone.new{text=errs, width=690, height=400}
	self.what = Textbox.new{title="What happened?: ", text="", chars=60, max_len=1000, fct=function(text) self:send() end}
	local ok = require("engine.ui.Button").new{text="Send", fct=function() self:send() end}
	local cancel = require("engine.ui.Button").new{text="Close", fct=function() game:unregisterDialog(self) end}
	local cancel_all = require("engine.ui.Button").new{text="Close All", fct=function()
		for i = #game.dialogs, 1, -1 do
			local d = game.dialogs[i]
			if d.__CLASSNAME == "engine.dialogs.ShowErrorStack" then
				game:unregisterDialog(d)
			end
		end
	end}

	local many_errs = false
	for i = #game.dialogs, 1, -1 do local d = game.dialogs[i] if d.__CLASSNAME == "engine.dialogs.ShowErrorStack" then many_errs = true break end end

	local uis = {
		{left=0, top=0, padding_h=10, ui=errmsg},
		{left=0, top=errmsg.h + 10, padding_h=10, ui=errzone},
		{left=0, bottom=ok.h, ui=self.what},
		{left=0, bottom=0, ui=ok},
		{right=0, bottom=0, ui=cancel},
	}
	if many_errs then
		table.insert(uis, #uis, {right=cancel.w, bottom=0, ui=cancel_all})
	end
	self:loadUI(uis)
	self:setFocus(self.what)
	self:setupUI(false, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:saveError(seen, reported)
	local f = fs.open(self.errdir.."/"..self.errmd5, "w")
	f:write(("error = %q\n"):format(self.errs))
	f:write(("seen = %s\n"):format(seen and "true" or "false"))
	f:write(("reported = %s\n"):format(reported and "true" or "false"))
	f:close()
end

function _M:send()
	game:unregisterDialog(self)
	profile:sendError(self.what.text, self.errs)
	game.log("#YELLOW#Error report sent, thank you.")
	self:saveError(true, true)
end
