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
local Module = require "engine.Module"
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local Button = require "engine.ui.Button"
local DownloadDialog = require "engine.dialogs.DownloadDialog"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "Update all game modules", game.w / 3, game.h * 0.5)

	self:generateList()

	self.c_desc = Textzone.new{width=self.iw, auto_height=1, text=[[
All those components will be updated:
]]}

	self.c_list = ListColumns.new{width=self.iw, height=self.ih - self.c_desc.h, scrollbar=true, columns={
		{name="Component", width=80, display_prop="name"},
		{name="Version", width=20, display_prop="version_string"},
	}, list=self.list or {}, fct=function(item) end, select=function(item, sel) end}

	self.c_ok = Button.new{width=self.iw - 20, text="Update All", fct=function() self:updateAll() end}

	self:loadUI{
		{left=0, top=0, ui=self.c_desc},
		{left=0, top=self.c_desc.h, ui=self.c_list},
		{left=0, bottom=0, ui=self.c_ok},
	}
	self:setFocus(self.c_list)
	self:setupUI(false, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:display(...)
	if not self.list then game:unregisterDialog(self) return end
	return Dialog.display(self, ...)
end

function _M:generateList()
	local list = Module:loadRemoteList()
	local mod_list = Module:listModules()
do return end

	local dllist = {}
	for i, mod in ipairs(rawdllist) do
		if mod_list[mod.short_name] then
			local lmod = mod_list[mod.short_name]
			if mod.version[1] * 1000000 + mod.version[2] * 1000 + mod.version[3] > lmod.version[1] * 1000000 + lmod.version[2] * 1000 + lmod.version[3] then
				dllist[#dllist+1] = mod
			end
		end
	end

	if #dllist == 0 then
		Dialog:simplePopup("Nothing to update", "All your game modules are up to date.")
		return
	end

	local engs = {}
	local list = {}
	for i, mod in ipairs(dllist) do
		list[#list+1] = { name="Game: #{bold}##GOLD#"..mod.name.."#{normal}##WHITE#", mod=mod, version_string=("%d.%d.%d"):format(mod.version[1], mod.version[2], mod.version[3]) }

		-- Check for the required engine
		local ename, ev1, ev2, ev3 = mod.engine[4] or "te4", mod.engine[1], mod.engine[2], mod.engine[3]
		local efound = false
		for i, eng in ipairs(__available_engines[ename]) do
			if eng[1] == ev1 and eng[2] == ev2 and eng[3] == ev3 then
				efound = true
				break
			end
		end
		if efound then
			print(" * require installed engine", ename, ev1, ev2, ev3)
		else
			print(" * require download engine", ename, ev1, ev2, ev3)
			engs[("%s:%d.%d.%d"):format(ename, ev1, ev2, ev3)] = {ev1, ev2, ev3, ename}
		end
	end

	for name, eng in pairs(engs) do
		list[#list+1] = { name="Engine: #{italic}##LIGHT_BLUE#"..eng[4].."#{normal}##WHITE#", eng=eng, version_string=("%d.%d.%d"):format(eng[1], eng[2], eng[3]) }
	end
	self.list = list
end

function _M:updateAll()
	local do_next, done
	local files = {}

	local restore = fs.getWritePath()
	fs.setWritePath(engine.homepath)

	do_next = function()
		local next = table.remove(self.list, 1)
		if not next then done() return end

		if next.eng then
			local eversion = next.eng

			-- Download engine
			fs.mkdir("/tmp-dl/engines")
			local fname = ("/tmp-dl/engines/%s-%d.%d.%d.teae"):format(eversion[4], eversion[1], eversion[2], eversion[3])
			local f = fs.open(fname, "w")

			local url = ("http://te4.org/dl/engines/%s-%d.%d.%d.teae"):format(eversion[4], eversion[1], eversion[2], eversion[3])
			local d = DownloadDialog.new(("Downloading engine: %s"):format(next.name), url, function(chunk)
				f:write(chunk)
			end, function(di, data)
				f:close()
				files[#files+1] = fname

				-- Download engine
				fs.mkdir("/tmp-dl/modules")
				fs.mkdir("/modules")
				local fname = ("/tmp-dl/modules/boot-%s-%d.%d.%d.team"):format(eversion[4], eversion[1], eversion[2], eversion[3])
				local f = fs.open(fname, "w")

				local url = ("http://te4.org/dl/engines/boot-%s-%d.%d.%d.team"):format(eversion[4], eversion[1], eversion[2], eversion[3])
				local d = DownloadDialog.new(("Downloading engine boot menu: %s"):format(next.name), url, function(chunk)
					f:write(chunk)
				end, function(di, data)
					f:close()
					files[#files+1] = fname
					do_next()
				end, function(error)
					Dialog:simplePopup("Error!", "There was an error while downloading:\n"..error)
					game:unregisterDialog(self)
				end)

				game:registerDialog(d)
				d:startDownload()

			end, function(error)
				Dialog:simplePopup("Error!", "There was an error while downloading:\n"..error)
				game:unregisterDialog(self)
			end)

			game:registerDialog(d)
			d:startDownload()
		elseif next.mod then
			local mod = next.mod

			fs.mkdir("/tmp-dl/modules")
			fs.mkdir("/modules")
			local fname = ("/tmp-dl/modules/%s-%d.%d.%d.team"):format(mod.short_name, mod.version[1], mod.version[2], mod.version[3])
			local f = fs.open(fname, "w")

			local d = DownloadDialog.new("Downloading: "..next.name, mod.download, function(chunk)
				f:write(chunk)
			end, function(di, data)
				f:close()
				files[#files+1] = fname
				do_next()
			end, function(error)
				Dialog:simplePopup("Error!", "There was an error while downloading:\n"..error)
				game:unregisterDialog(self)
			end)
			game:registerDialog(d)
			d:startDownload()
		end
	end

	done = function()
		for i, file in ipairs(files) do
			local real = file:gsub("^/tmp%-dl/", "/")
			print("Installing", file, "=>", real)
			fs.rename(file, real)
		end
		if restore then fs.setWritePath(restore) end

		Dialog:simplePopup("Update", "All updates installed, the game will now restart", function()
			util.showMainMenu()
		end)
	end

	do_next()
end
