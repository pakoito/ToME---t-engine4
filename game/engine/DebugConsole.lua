require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init()
	engine.Dialog.init(self, "Lua Console", core.display.size())
	self.scroll = 0
	self.history = {}
	self.line = ""
	self:keyCommands{
		_RETURN = function()
			table.insert(self.history, 1, self.line)
			if self.line:match("^=") then self.line = "return "..self.line:sub(2) end
			local f, err = loadstring(self.line)
			if err then
				table.insert(self.history, 1, err)
			else
				local res = {pcall(f)}
				for i, v in ipairs(res) do
					if i > 1 then
						table.insert(self.history, 1, (i-1).." :=: "..tostring(v))
					end
				end
			end
			self.line = ""
			self.changed = true
		end,
		_ESCAPE = function()
			game:unregisterDialog(self)
		end,
		_BACKSPACE = function()
			self.line = self.line:sub(1, self.line:len() - 1)
		end,
		__TEXTINPUT = function(c)
			self.line = self.line .. c
			self.changed = true
		end,
	}
end

function _M:drawDialog(s, w, h)
	local i, dh = 1, 0
	while dh < self.h do
		if not self.history[self.scroll + i] then break end
		s:drawString(self.font, self.history[self.scroll + i], 0, self.ih - (i + 1) * self.font:lineSkip(), 255, 255, 255)
		i = i + 1
		dh = dh + self.font:lineSkip()
	end

	s:drawString(self.font, self.line, 0, self.ih - self.font:lineSkip(), 255, 255, 255)
end
