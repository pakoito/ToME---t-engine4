require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(title, x, y, filter, action)
	self.x, self.y = x, y
	self.filter = filter
	self.action = action
	engine.Dialog.init(self, title or "Pickup", game.w * 0.8, game.h * 0.8)

	self:generateList()

	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 5) / self.font_h) - 1

	self:keyCommands{
		_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) end,
		_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) end,
		_RETURN = function() self:use() end,
		_ESCAPE = function() game:unregisterDialog(self) end,
		_ASTERISK = function() while self:use() do end end,
		__TEXTINPUT = function(c)
			if c:find("^[a-z]$") then
				self.sel = util.bound(1 + string.byte(c) - string.byte('a'), 1, #self.list)
				self:use()
			end
		end,
	}
	self:mouseZones{
		{ x=2, y=5, w=350, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" then self:use()
			elseif button == "right" then
			end
		end },
	}
end

function _M:use()
	if self.list[self.sel] then
		self.action(self.list[self.sel].object, self.list[self.sel].item)
	end
	self:generateList()
	if #self.list == 0 then
		game:unregisterDialog(self)
		return false
	end
	return true
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local idx = 1
	local i = 1
	while true do
		local o = game.level.map:getObject(self.x, self.y, idx)
		if not o then break end
		if not self.filter or self.filter(o) then
			local nb = o:getNumber()
			nb = (nb == 1) and "" or nb.." "
			list[#list+1] = { name=string.char(string.byte('a') + i)..")  "..nb..o:getName(), object=o, item=idx }
			i = i + 1
		end
		idx = idx + 1
	end
	self.list = list
	self.sel = 1
end

function _M:drawDialog(s)
	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)

	local talentshelp = ([[Keyboard: #00FF00#up key/down key#FFFFFF# to select an object; #00FF00#enter#FFFFFF# to use.
Mouse: #00FF00#Left click#FFFFFF# to pickup.
]]):splitLines(self.iw / 2 - 10, self.font)

	local lines = {}
	local h = 2
	for i = 1, #talentshelp do
		s:drawColorString(self.font, talentshelp[i], self.iw / 2 + 5, h)
		h = h + self.font:lineSkip()
	end

	h = h + self.font:lineSkip()
	if self.list[self.sel] then
		lines = self.list[self.sel].object:getDesc():splitLines(self.iw / 2 - 10, self.font)
	else
		lines = {}
	end
	self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
	for i = 1, #lines do
		s:drawColorString(self.font, lines[i], self.iw / 2 + 5, 2 + h)
		h = h + self.font:lineSkip()
	end

	-- Talents
	self:drawSelectionList(s, 2, 5, self.font_h, self.list, self.sel, "name", self.scroll, self.max)
end
