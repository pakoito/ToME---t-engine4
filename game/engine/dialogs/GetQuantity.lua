require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(title, prompt, act)
	engine.Dialog.init(self, title or "Quantity?", 300, 100)
	self.prompt = prompt
	self.act = act
	self.qty = 0
	self:keyCommands{
		_RETURN = function()
			game:unregisterDialog(self)
			act(self.qty)
		end,
		_BACKSPACE = function()
			local b = tostring(self.qty)
			b = b:sub(1, b:len() - 1)
			if b == '' then self.qty = 0
			else self.qty = tonumber(b)
			end
		end,
		__TEXTINPUT = function(c)
			if not (c == '0' or c == '1' or c == '2' or c == '3' or c == '4' or c == '5' or c == '6' or c == '7' or c == '8' or c == '9') then return end
			if self.qty >= 10000000 then return end
			local b = tostring(self.qty)
			if self.qty == 0 then b = "" end
			self.qty = tonumber(b .. c)
			self.changed = true
		end,
	}
end

function _M:drawDialog(s, w, h)
	s:drawColorStringCentered(self.font, self.prompt or "Quantity:", 2, 2, self.iw - 2, self.ih - 2 - self.font:lineSkip())
	s:drawColorStringCentered(self.font, tostring(self.qty), 2, 2 + self.font:lineSkip(), self.iw - 2, self.ih - 2 - self.font:lineSkip())
end
