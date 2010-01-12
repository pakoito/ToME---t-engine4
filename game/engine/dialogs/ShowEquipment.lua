require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(title, actor, filter, action)
	self.actor = actor
	self.filter = filter
	self.action = action
	engine.Dialog.init(self, title or "Equipment", game.w * 0.8, game.h * 0.8)

	self:generateList()

	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 5) / self.font_h) - 1

	self:keyCommands({
		__TEXTINPUT = function(c)
			if self.chars[c] then
				self.sel = self.chars[c]
				self:use()
			end
		end,
	}, {
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) end,
		ACCEPT = function() self:use() end,
		EXIT = function() game:unregisterDialog(self) end,
	})
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
	game:unregisterDialog(self)
	if self.list[self.sel] then
		self.action(self.list[self.sel].object, self.list[self.sel].inven, self.list[self.sel].item)
	end
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local chars = {}
	local i = 0
	for inven_id =  1, #self.actor.inven_def do
		if self.actor.inven[inven_id] and self.actor.inven_def[inven_id].is_worn then
			list[#list+1] = { name="#10EF6F#"..self.actor.inven_def[inven_id].name, inven=inven_id }

			for item, o in ipairs(self.actor.inven[inven_id]) do
				if not self.filter or self.filter(o) then
					local char = string.char(string.byte('a') + i)
					local nb = o:getNumber()
					nb = (nb == 1) and "" or nb.." "
					list[#list+1] = { name=char..")  "..nb..o:getName(), object=o, inven=inven_id, item=item }
					chars[char] = #list
					i = i + 1
				end
			end
		end
	end
	self.list = list
	self.chars = chars
end

function _M:drawDialog(s)
	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)

	local talentshelp = ([[Keyboard: #00FF00#up key/down key#FFFFFF# to select an object; #00FF00#enter#FFFFFF# to use.
Mouse: #00FF00#Left click#FFFFFF# to use.
]]):splitLines(self.iw / 2 - 10, self.font)

	local lines = {}
	local h = 2
	for i = 1, #talentshelp do
		s:drawColorString(self.font, talentshelp[i], self.iw / 2 + 5, h)
		h = h + self.font:lineSkip()
	end

	h = h + self.font:lineSkip()
	if not self.list[self.sel].item then
		lines = self.actor.inven_def[self.list[self.sel].inven].description:splitLines(self.iw / 2 - 10, self.font)
	elseif self.list[self.sel] then
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
