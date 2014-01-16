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
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

-- Globals to all instances of the console
offset = 0
history = {
	[[<<<<<------------------------------------------------------------------------------------->>>>>]],
	[[<                          Welcome to the T-Engine Lua Console                                >]],
	[[<--------------------------------------------------------------------------------------------->]],
	[[< You have access to the T-Engine global namespace.                                           >]],
	[[< To execute commands, simply type them and hit Enter.                                        >]],
	[[< To see the return values of a command, start the line off with a "=" character.             >]],
	[[< For a table, this will not show keys inherited from a metatable (usually class functions).  >]],
	[[<--------------------------------------------------------------------------------------------->]],
	[[< Here are some useful keyboard shortcuts:                                                    >]],
	[[<     Left/right arrows  :=: Move the cursor position left/right                              >]],
	[[<     Ctrl+A or Home     :=: Move the cursor to the beginning of the line                     >]],
	[[<     Ctrl+E or End      :=: Move the cursor to the end of the line                           >]],
	[[<     Ctrl+K or Ctrl+End :=: Move the cursor to the end of the line                           >]],
	[[<     Up/down arrows     :=: Move between previous/later executed lines                       >]],
	[[<     Ctrl+Space         :=: Print help for the function to the left of the cursor            >]],
	[[<     Ctrl+Shift+Space   :=: Print the entire definition for the function                     >]],
	[[<     Tab                :=: Auto-complete path strings or tables at the cursor               >]],
	[[<     Page Up            :=: Scrolls up 75% of the history                                    >]],
	[[<     Page Down          :=: Scrolls down 75% of the history                                  >]],
	[[<<<<<------------------------------------------------------------------------------------->>>>>]],
}
line = ""
line_pos = 0
com_sel = 0
commands = {}

local find_base
find_base = function(remaining)
	-- Check if we are in a string by counting quotation marks
	local _, nsinglequote = remaining:gsub("\'", "")
	local _, ndoublequote = remaining:gsub("\"", "")
	if (nsinglequote % 2 ~= 0) or (ndoublequote % 2 ~= 0) then
		-- Only auto-complete paths
		local path_to_complete
		if (nsinglequote % 2 ~= 0) and not (ndoublequote % 2 ~= 0) then
			path_to_complete = remaining:match("[^\']+$")
		elseif (ndoublequote % 2 ~= 0) and not (nsinglequote % 2 ~= 0) then
			path_to_complete = remaining:match("[^\"]+$")
		end
		if path_to_complete and path_to_complete:sub(1, 1) == "/" then
			local tail = path_to_complete:match("[^/]+$") or ""
			local head = path_to_complete:sub(1, #path_to_complete - #tail)
			if fs.exists(head) then
				return head, tail
			else
				return nil, ([[%s is not a valid path]]):format(head)
			end
		else
			return nil, "Cannot auto-complete strings."
		end
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

function _M:init()
	self.cursor = "|"
	self.blink_period = 20
	self.blink = self.blink_period
	local w, h = core.display.size()
	engine.Dialog.init(self, "Lua Console", w, h, 0, 0, nil, core.display.newFont("/data/font/DroidSansMono.ttf", 12))
	game:onTickEnd(function() self.key:unicodeInput(true) end)
	self:keyCommands{
		_RETURN = function()
			table.insert(_M.commands, _M.line)
			_M.com_sel = #_M.commands + 1
			table.insert(_M.history, _M.line)
			-- Handle assignment and simple printing
			if _M.line:match("^=") then _M.line = "return ".._M.line:sub(2) end
			local f, err = loadstring(_M.line)
			if err then
				table.insert(_M.history, err)
			else
				local res = {pcall(f)}
				for i, v in ipairs(res) do
					if i > 1 then
						table.insert(_M.history, "    "..(i-1).." :=: "..tostring(v))
						-- Handle printing a table
						if type(v) == "table" then
							local array = {}
							for k, vv in table.orderedPairs(v) do
								array[#array+1] = tostring(k).." :=: "..tostring(vv)
							end
							self:historyColumns(array, 8)
						end
					end
				end
			end
			_M.line = ""
			_M.line_pos = 0
			_M.offset = 0
			self.changed = true
		end,
		_UP = function()
			_M.com_sel = util.bound(_M.com_sel - 1, 0, #_M.commands)
			if _M.commands[_M.com_sel] then
				if #_M.line == 0 or _M.line_pos == #_M.line then
					_M.line_pos = #_M.commands[_M.com_sel]
				end
				_M.line = _M.commands[_M.com_sel]
			end
			self.changed = true
		end,
		_DOWN = function()
			_M.com_sel = util.bound(_M.com_sel + 1, 1, #_M.commands)
			if _M.commands[_M.com_sel] then
				if #_M.line == 0 or _M.line_pos == #_M.line then
					_M.line_pos = #_M.commands[_M.com_sel]
				end
				_M.line = _M.commands[_M.com_sel]
			else
				_M.line = ""
				_M.line_pos = 0
			end
			self.changed = true
		end,
		_LEFT = function()
			_M.line_pos = util.bound(_M.line_pos - 1, 0, #_M.line)
			self.changed = true
		end,
		_RIGHT = function()
			_M.line_pos = util.bound(_M.line_pos + 1, 0, #_M.line)
			self.changed = true
		end,
		_HOME = function()
			_M.line_pos = 0
			self.changed = true
		end,
		[{"_a","ctrl"}] = function()
			_M.line_pos = 0
			self.changed = true
		end,
		_END = function()
			_M.line_pos = #_M.line
			self.changed = true
		end,
		[{"_e","ctrl"}] = function()
			_M.line_pos = #_M.line
			self.changed = true
		end,
		_ESCAPE = function()
			game:unregisterDialog(self)
		end,
		_BACKSPACE = function()
			_M.line = _M.line:sub(1, _M.line_pos - 1) .. _M.line:sub(_M.line_pos + 1)
			_M.line_pos = util.bound(_M.line_pos - 1, 0, #_M.line)
			self.changed = true
		end,
		_DELETE = function()
			_M.line = _M.line:sub(1, _M.line_pos) .. _M.line:sub(_M.line_pos + 2)
			self.changed = true
		end,
		[{"_END", "ctrl"}] = function()
			_M.line = _M.line:sub(1, _M.line_pos)
			self.changed = true
		end,
		[{"_k", "ctrl"}] = function()
			_M.line = _M.line:sub(1, _M.line_pos)
			self.changed = true
		end,
		__TEXTINPUT = function(c)
			_M.line = _M.line:sub(1, _M.line_pos) .. c .. _M.line:sub(_M.line_pos + 1)
			_M.line_pos = util.bound(_M.line_pos + 1, 0, #_M.line)
			self.changed = true
		end,
		[{"_v", "ctrl"}] = function(c)
			local s = core.key.getClipboard()
			if s then
				_M.line = _M.line:sub(1, _M.line_pos) .. s .. _M.line:sub(_M.line_pos + 1)
				_M.line_pos = util.bound(_M.line_pos + #s, 0, #_M.line)
				self.changed = true
			end
		end,
		[{"_c", "ctrl"}] = function(c)
			core.key.setClipboard(_M.line)
		end,
		_TAB = function()
			self:autoComplete()
		end,
		[{"_SPACE", "ctrl"}] = function(c)
			local base, remaining = find_base(_M.line:sub(1,_M.line_pos))
			local func = base[remaining]
			if not func or type(func) ~= "function" then
				table.insert(_M.history, "<<<<< No function found >>>>>")
				return
			end
			local lines, fname, lnum = self:functionHelp(func)
			if not lines then
				table.insert(_M.history, ([[<<<<< %s >>>>>]]):format(fname))
				return
			end
			table.insert(_M.history, ([[<<<<< Help found in %s at line %d. >>>>>]]):format(fname, lnum))
			for _, line in ipairs(lines) do
				table.insert(_M.history, "    " .. line:gsub("\t", "    "))
			end
		end,
                [{"_SPACE", "ctrl", "shift"}] = function(c)
                        local base, remaining = find_base(_M.line:sub(1,_M.line_pos))
                        local func = base[remaining]
                        if not func or type(func) ~= "function" then
                                table.insert(_M.history, "<<<<< No function found >>>>>")
                                return
                        end
                        local lines, fname, lnum = self:functionHelp(func, true)
                        if not lines then
                                table.insert(_M.history, ([[<<<<< %s >>>>>]]):format(fname))
                                return
                        end
                        table.insert(_M.history, ([[<<<<< Definition found in %s at line %d. >>>>>]]):format(fname, lnum))
                        for _, line in ipairs(lines) do
                                table.insert(_M.history, "    " .. line:gsub("\t", "    "))
                        end
                end,
		_PAGEUP = function()
			local num_lines = math.floor(self.h / self.font_h * 0.75)
			self:scrollUp(num_lines)
		end,
		_PAGEDOWN = function()
			local num_lines = math.floor(self.h / self.font_h * 0.75)
			self:scrollUp(-num_lines)
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

function _M:display()
	-- Blinking cursor
	self.blink = self.blink - 1
	if self.blink <= 0 then
		self.cursor = self.cursor == "|" and " " or "|"
		self.blink = self.blink_period
		self.changed = true
	end
	engine.Dialog.display(self)
end

function _M:drawDialog(s, w, h)
	local buffer = (self.ih % self.font_h) / 2
	local i, dh = #_M.history - _M.offset, self.ih - buffer - self.font:lineSkip()
	-- Start at the bottom and work up
	-- Draw the current command
	s:drawStringBlended(self.font, _M.line:sub(1, _M.line_pos) .. self.cursor .. _M.line:sub(_M.line_pos+1), 0, dh, 255, 255, 255)
	dh = dh - self.font:lineSkip()
	-- Now draw the history with any offset
	while dh > buffer do
		if not _M.history[i] then break end
		s:drawStringBlended(self.font, _M.history[i], 0, dh, 255, 255, 255)
		i = i - 1
		dh = dh - self.font:lineSkip()
	end
	self.changed = false
end

--- Scroll the zone
-- @param i number representing how many lines to scroll
function _M:scrollUp(i)
	_M.offset = _M.offset + i
	if _M.offset > #_M.history - 1 then _M.offset = #_M.history - 1 end
	if _M.offset < 0 then _M.offset = 0 end
	self.changed = true
end

--- Autocomplete the current line
-- Will handle either tables (eg. mod.cla -> mod.class) or paths (eg. "/mod/cla" -> "/mod/class/")
function _M:autoComplete()
	local base, to_complete = find_base(_M.line:sub(1, _M.line_pos))
	if not base then
		if to_complete then
			table.insert(_M.history, ([[<<<<< %s >>>>>]]):format(to_complete))
			self.changed = true
		end
		return
	end
	-- Autocomplete a table
	local set = {}
	if type(base) == "table" then
		local recurs_bases
		recurs_bases = function(base)
			if type(base) ~= "table" then return end
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
	-- Autocomplete a path
	elseif type(base) == "string" then
		-- Make sure the directory exists
		if fs.exists(base) then
			for i, fname in ipairs(fs.list(base)) do
				if fname:sub(1, #to_complete) == to_complete then
					-- Add a "/" to directories
					if fs.isdir(base.."/"..fname) then
						set[fname.."/"] = true
					else
						set[fname] = true
					end
				end
			end
		end
	else
		return
	end
	-- Convert to a sorted array
	local array = {}
	for k, _ in pairs(set) do
		array[#array+1] = k
	end
	table.sort(array, function(a, b) return a < b end)
	-- If there is one possibility, complete it
	if #array == 1 then
		-- Special case for a table...
		if array[1] == to_complete and type(base[to_complete]) == "table" then
			_M.line = _M.line:sub(1, _M.line_pos) .. "." .. _M.line:sub(_M.line_pos + 1)
			_M.line_pos = _M.line_pos + 1
		elseif array[1] == to_complete and type(base[to_complete]) == "function" then
			_M.line = _M.line:sub(1, _M.line_pos) .. "(" .. _M.line:sub(_M.line_pos + 1)
			_M.line_pos = _M.line_pos + 1
		else
			_M.line = _M.line:sub(1, _M.line_pos - #to_complete) .. array[1] .. _M.line:sub(_M.line_pos + 1)
			_M.line_pos = _M.line_pos - #to_complete + #array[1]
		end
	elseif #array > 1 then
		table.insert(_M.history, "<<<<< Auto-complete possibilities: >>>>>")
		self:historyColumns(array)
		-- Find the longest common substring and complete it
		local substring = array[1]:sub(#to_complete+1)
		for i=2,#array do
			local min_len = math.min(#array[i]-#to_complete, #substring)
			for j=1,min_len do
				if substring:sub(j, j) ~= array[i]:sub(#to_complete+j, #to_complete+j) then
					substring = substring:sub(1, util.bound(j-1, 0))
					break
				end
			end
			if #substring == 0 then break end
		end
		-- Complete to the longest common substring
		if #substring > 0 then
			_M.line = _M.line:sub(1, _M.line_pos) .. substring .. _M.line:sub(_M.line_pos + 1)
			_M.line_pos = _M.line_pos + #substring
		end
	else
		table.insert(_M.history, "<<<<< No auto-complete possibilities. >>>>>") 
	end
	self.changed = true
end

--- Prints comments for a function
-- @param function
function _M:functionHelp(func, verbose)
	if type(func) ~= "function" then return nil, "Can only give help on functions." end
	local info = debug.getinfo(func)
	-- Check the path exists
	local fpath = string.gsub(info.source,"@","")
	if not fs.exists(fpath) then return nil, ([[%s does not exist.]]):format(fpath) end
	local f = fs.open(fpath, "r")
	local lines = {}
	local line_num = 0
	local line
	while true do
		line = f:readLine()
		if line then
			line_num = line_num + 1
			if line_num == info.linedefined then
				lines[#lines+1] = line
				break
			elseif line:sub(1,2) == "--" then
				lines[#lines+1] = line
			else
				lines = {}
			end
		else
			break
		end
	end
	if verbose then
		for i=info.linedefined+1,info.lastlinedefined do
			line = f:readLine()
			lines[#lines+1] = line
		end
	end
	f:close()
	return lines, info.short_src, info.linedefined
end

--- Add a list of strings to the history with multiple columns
-- @param strings Array of strings to add to the history
-- @param offset Number of spaces to add on the left-hand side
function _M:historyColumns(strings, offset)
	local offset_str = string.rep(" ", offset and offset or 0)
	local ox, oy = self.font:size(offset_str)
	local longest_key = ""
	local width = 0  --
	local max_width = 80 -- Maximum field width to print
	
--	for i, k in ipairs(strings) do
--		if #k > #longest_key then
--			longest_key = k
--		end
--	end

	for i, k in ipairs(strings) do
		if #k > width then
			longest_key = k
			width = #k
			if width >= max_width then
				width = max_width
				break
			end
		end
	end
	
--	local tx, ty = self.font:size(longest_key .. "  ")
	local tx, ty = self.font:size(string.sub(longest_key,1,width) .. "...  ") --
	local num_columns = math.floor((self.w - ox) / tx)
	local num_rows = math.ceil(#strings / num_columns)

--	local line_format = offset_str..string.rep("%-"..tostring(#longest_key).."s ", num_columns)
	local line_format = offset_str..string.rep("%-"..tostring(math.min(max_width+5,width+5)).."s ", num_columns) --
	
	for i=1,num_rows do
		vals = {}
		for j=1,num_columns do
			vals[j] = strings[i + (j - 1) * num_rows] or ""
			--Truncate and annotate if too long
			if #vals[j] > width then --
				vals[j] = string.sub(vals[j],1,width) .. "..." --
			end --
		end
		table.insert(_M.history, line_format:format(unpack(vals)))
	end
end
