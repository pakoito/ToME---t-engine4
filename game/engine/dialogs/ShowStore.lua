require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(title, store_inven, actor_inven, store_filter, actor_filter, action)
	self.store_inven = store_inven
	self.actor_inven = actor_inven
	self.store_filter = store_filter
	self.actor_filter = actor_filter
	engine.Dialog.init(self, title or "Store", game.w * 0.8, game.h * 0.8, nil, nil, nil, core.display.newFont("/data/font/VeraMono.ttf", 12))

	self:generateList()

	self.list = self.store_list
	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 5) / self.font_h) - 1

	self:keyCommands({
		__TEXTINPUT = function(c)
			if c:find("^[a-z]$") then
				self.sel = util.bound(1 + string.byte(c) - string.byte('a'), 1, #self.list)
				self:use()
			end
		end,
	},{
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) end,
		MOVE_LEFT = function() end,
		MOVE_RIGHT = function() end,
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
		self.action(self.list[self.sel].object, self.list[self.sel].item)
	end
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local i = 0
	for item, o in ipairs(self.store_inven) do
		if not self.store_filter or self.store_filter(o) then
			list[#list+1] = { name=string.char(string.byte('a') + i)..") "..o:getName(), color=o:getDisplayColor(), object=o, item=item }
			i = i + 1
		end
	end
	self.store_list = list

	-- Makes up the list
	local list = {}
	local i = 0
	for item, o in ipairs(self.actor_inven) do
		if not self.actor_filter or self.actor_filter(o) then
			list[#list+1] = { name=string.char(string.byte('a') + i)..") "..o:getName(), color=o:getDisplayColor(), object=o, item=item }
			i = i + 1
		end
	end
	self.actor_list = list
end

function _M:drawDialog(s)
	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)

	local help = [[Keyboard: #00FF00#up key/down key#FFFFFF# to select an object; #00FF00#enter#FFFFFF# to use.
Mouse: #00FF00#Left click#FFFFFF# to use.
]]
	local talentshelp = help:splitLines(self.iw / 2 - 10, self.font)

--	local lines = {}
--	local h = 2
--	for i = 1, #talentshelp do
--		s:drawColorString(self.font, talentshelp[i], self.iw / 2 + 5, h)
--		h = h + self.font:lineSkip()
--	end

--	h = h + self.font:lineSkip()
--	if self.store_list[self.store_sel] then
--		lines = self.store_list[self.store_sel].object:getDesc():splitLines(self.iw / 2 - 10, self.font)
--	else
--		lines = {}
--	end
--	self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
--	for i = 1, #lines do
--		s:drawColorString(self.font, lines[i], self.iw / 2 + 5, 2 + h)
--		h = h + self.font:lineSkip()
--	end

	self:drawSelectionList(s, 2, 5, self.font_h, self.store_list, self.sel, "name", self.scroll, self.max)
	self:drawSelectionList(s, self.iw / 2 + 5, 5, self.font_h, self.actor_list, self.sel, "name", self.scroll, self.max)
end
