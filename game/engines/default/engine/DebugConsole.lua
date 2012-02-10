-- TE4 - T-Engine 4
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
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

-- Globals to all instances of the console
offset = 0
history = {}
line = ""
line_pos = 0
com_sel = 0
commands = {}

function _M:init()
	engine.Dialog.init(self, "Lua Console", core.display.size())
	game:onTickEnd(function() self.key:unicodeInput(true) end)
	self:keyCommands{
		_RETURN = function()
			table.insert(self.commands, self.line)
			self.com_sel = #self.commands + 1
			table.insert(self.history, self.line)
			-- Handle assignment and simple printing
			if self.line:match("^=") then self.line = "return "..self.line:sub(2) end
			local f, err = loadstring(self.line)
			if err then
				table.insert(self.history, err)
			else
				local res = {pcall(f)}
				for i, v in ipairs(res) do
					if i > 1 then
						table.insert(self.history, "    "..(i-1).." :=: "..tostring(v))
						-- Handle printing a table
						if type(v) == "table" then
							for k, vv in pairs(v) do
								table.insert(self.history, "        "..tostring(k).." :=: "..tostring(vv) )
							end
						end
					end
				end
			end
			self.line = ""
			self.line_pos = 0
			self.offset = 0
			self.changed = true
		end,
		_UP = function()
			self.com_sel = util.bound(self.com_sel - 1, 0, #self.commands)
			if self.commands[self.com_sel] then
				if #self.line == 0 or self.line_pos == #self.line then
					self.line_pos = #self.commands[self.com_sel]
				end
				self.line = self.commands[self.com_sel]
			end
			self.changed = true
		end,
		_DOWN = function()
			self.com_sel = util.bound(self.com_sel + 1, 1, #self.commands)
			if self.commands[self.com_sel] then
				if #self.line == 0 or self.line_pos == #self.line then
					self.line_pos = #self.commands[self.com_sel]
				end
				self.line = self.commands[self.com_sel]
			else
				self.line = ""
				self.line_pos = 0
			end
			self.changed = true
		end,
		_LEFT = function()
			self.line_pos = util.bound(self.line_pos - 1, 0, #self.line)
			self.changed = true
		end,
		_RIGHT = function()
			self.line_pos = util.bound(self.line_pos + 1, 0, #self.line)
			self.changed = true
		end,
		_HOME = function()
			self.line_pos = 0
			self.changed = true
		end,
		_END = function()
			self.line_pos = #self.line
			self.changed = true
		end,
		_ESCAPE = function()
			game:unregisterDialog(self)
		end,
		_BACKSPACE = function()
			self.line = self.line:sub(1, self.line_pos - 1) .. self.line:sub(self.line_pos + 1)
			self.line_pos = util.bound(self.line_pos - 1, 0, #self.line)
			self.changed = true
		end,
		__TEXTINPUT = function(c)
			self.line = self.line:sub(1, self.line_pos) .. c .. self.line:sub(self.line_pos + 1)
			self.line_pos = util.bound(self.line_pos + 1, 0, #self.line)
			self.changed = true
		end,
		[{"_v", "ctrl"}] = function(c)
			local s = core.key.getClipboard()
			if s then
				self.line = self.line:sub(1, self.line_pos) .. s .. self.line:sub(self.line_pos + 1)
				self.line_pos = util.bound(self.line_pos + #s, 0, #self.line)
				self.changed = true
			end
		end,
		[{"_c", "ctrl"}] = function(c)
			core.key.setClipboard(self.line)
		end,
		_TAB = function()
			local find_base
			find_base = function(remaining)
				-- Don't try to auto-complete strings, check by counting quotation marks
				local _, nsinglequote = remaining:gsub("\'", "")
				local _, ndoublequote = remaining:gsub("\"", "")
				if (nsinglequote % 2 ~= 0) or (ndoublequote % 2 ~= 0) then
					return nil, "Cannot auto-complete strings."
				end
				-- Work from the back of the line to the front
				local string_to_complete = remaining:match("[%d%w_%[%]%.:\'\"]+$") or ""
				-- Find the trailing tail
				local tail = string_to_complete:match("[%d%w_]+$") or ""
				local linking_char = string_to_complete:sub(#string_to_complete - #tail, #string_to_complete - #tail)
				-- Only handle numerical keys to auto-complete
				if linking_char == "[" and not tonumber(tail) then
					return find_base(tail)
				end
				-- Drop the linking character
				local head = string_to_complete:sub(1, util.bound(#string_to_complete - #tail - 1, 0))
				if #head > 0 then
					local f, err = loadstring("return " .. head)
					if err then
						return nil, err
					else
						local res = {pcall(f)}
						if res[1] and res[2] then
							return res[2], tail
						else
							return nil, ([[%s does not exist.]]):format(head)
						end
					end
				-- Global namespace if there is no head
				else
					return _G, tail
				end
			end
			local base, to_complete = find_base(self.line)
			if not base then
				if to_complete then
					table.insert(self.history, ([[----- %s -----]]):format(to_complete))
					self.changed = true
				end
				return
			end
			local set = {}
			local recurs_bases
			recurs_bases = function(base)
				for k, v in pairs(base) do
					-- Need to handle numbers, too
					if type(k) == "number" and tonumber(to_complete) then
						if tostring(k):match("^" .. to_complete) then
							set[tostring(k)] = true
						end
					elseif type(k) == "string" then
						if k:match("^" .. to_complete) then
							set[k] = true
						end
					end
				end
				-- Check the metatable __index
				local mt = getmetatable(base)
				if mt and mt.__index and type(mt.__index) == "table" then
					recurs_bases(mt.__index)
				end
			end
			recurs_bases(base)
			-- Convert to a sorted array
			local array = {}
			for k, _ in pairs(set) do
				array[#array+1] = k
			end
			table.sort(array, function(a, b) return a < b end)
			-- If there is one possibility, complete it
			if #array == 1 then
				self.line = self.line:sub(1, #self.line - #to_complete) .. array[1]
				self.line_pos = self.line_pos - #to_complete + #array[1]
			elseif #array > 1 then
				table.insert(self.history, "----- Auto-complete possibilities: -----")
				for i, k in ipairs(array) do
					table.insert(self.history, k)
				end
				-- Find the longest common substring and complete it
				local substring = array[1]:sub(#to_complete+1)
				for i=2,#array do
					local min_len = math.min(#array[i], #substring)
					for j=#to_complete,min_len do
						if substring:sub(j, j) ~= array[i]:sub(j, j) then
							substring = substring:sub(#to_complete+1, util.bound(j-1, 0))
							break
						end
					end
					if #substring == 0 then break end
				end
				-- Complete to the longest common substring
				if #substring > 0 then
					self.line = self.line .. substring
					self.line_pos = self.line_pos + #substring
				end
			else
				table.insert(self.history, "----- No auto-complete possibilities. -----")
			end
			self.changed = true
		end,
	}
	-- Scroll message log
	self:mouseZones{
		{ x=0, y=0, w=game.w, h=game.h, mode={button=true}, norestrict=true, fct=function(button) if button ~= "none" then game:unregisterDialog(self) end end},
		{ x=0, y=0, w=self.iw, h=self.ih, mode={button=true}, fct=function(button, x, y, xrel, yrel, tx, ty)
			if button == "wheelup" then self:scrollUp(1) end
			if button == "wheeldown" then self:scrollUp(-1) end
		end },
	}
end

function _M:drawDialog(s, w, h)
	local buffer = (self.ih % self.font_h) / 2
	local i, dh = #self.history - self.offset, self.ih - buffer - self.font:lineSkip()
	-- Start at the bottom and work up
	-- Draw the current command
	s:drawStringBlended(self.font, self.line:sub(1, self.line_pos) .. "|" .. self.line:sub(self.line_pos+1), 0, dh, 255, 255, 255)
	dh = dh - self.font:lineSkip()
	-- Now draw the history with any offset
	while dh > buffer do
		if not self.history[i] then break end
		s:drawStringBlended(self.font, self.history[i], 0, dh, 255, 255, 255)
		i = i - 1
		dh = dh - self.font:lineSkip()
	end
	self.changed = false
end

--- Scroll the zone
-- @param i number representing how many lines to scroll
function _M:scrollUp(i)
	self.offset = self.offset + i
	if self.offset > #self.history - 1 then self.offset = #self.history - 1 end
	if self.offset < 0 then self.offset = 0 end
	self.changed = true
end
