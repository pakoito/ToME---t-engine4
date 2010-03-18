require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(title, actor, filter, action)
	self.action = action
	self.filter = filter
	self.actor = actor
	engine.Dialog.init(self, title or "Inventory", game.w * 0.8, game.h * 0.8, nil, nil, nil, core.display.newFont("/data/font/VeraMono.ttf", 12))

	self:generateList()

	self.list = self.inven_list
	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih * 0.8 - 5) / self.font_h) - 1

	self:keyCommands({
		__TEXTINPUT = function(c)
			if self.list.chars[c] then
				self.sel = self.list.chars[c]
				self:use()
			end
		end,
	},{
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_LEFT = function() self.list = self.equip_list self.sel = util.bound(self.sel, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_RIGHT = function() self.list = self.inven_list self.sel = util.bound(self.sel, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
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
	if self.list[self.sel] and self.list[self.sel].item then
		if self.action(self.list[self.sel].object, self.list[self.sel].inven, self.list[self.sel].item) then
			game:unregisterDialog(self)
		end
	end
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local chars = {}
	local i = 0
	for inven_id =  1, #self.actor.inven_def do
		if self.actor.inven[inven_id] and self.actor.inven_def[inven_id].is_worn then
			list[#list+1] = { name=self.actor.inven_def[inven_id].name, color={0x90, 0x90, 0x90}, inven=inven_id }

			for item, o in ipairs(self.actor.inven[inven_id]) do
				if not self.filter or self.filter(o) then
					local char = string.char(string.byte('a') + i)
					list[#list+1] = { name=char..") "..o:getName(), color=o:getDisplayColor(), object=o, inven=inven_id, item=item }
					chars[char] = #list
					i = i + 1
				end
			end
		end
	end
	list.chars = chars
	self.equip_list = list

	-- Makes up the list
	local list = {}
	local chars = {}
	local i = 0
	for item, o in ipairs(self.actor:getInven("INVEN")) do
		if not self.filter or self.filter(o) then
			local char = string.char(string.byte('a') + i)
			list[#list+1] = { name=char..") "..o:getName(), color=o:getDisplayColor(), object=o, inven=self.actor.INVEN_INVEN, item=item }
			chars[char] = #list
			i = i + 1
		end
	end
	list.chars = chars
	self.inven_list = list
	self.changed = true

	self.list = self.inven_list
	self.sel = 1
	self.scroll = 1
end

function _M:drawDialog(s)
	if self.list[self.sel] and not self.list[self.sel].item then
		lines = self.actor.inven_def[self.list[self.sel].inven].description:splitLines(self.iw / 2 - 10, self.font)
	elseif self.list[self.sel] and self.list[self.sel] and self.list[self.sel].object then
		lines = self.list[self.sel].object:getDesc():splitLines(self.iw - 10, self.font)
	else
		lines = {}
	end

	local sh = self.ih - 4 - #lines * self.font:lineSkip()
	h = sh
	self:drawWBorder(s, 3, sh, self.iw - 6)
	for i = 1, #lines do
		s:drawColorString(self.font, lines[i], 5, 2 + h)
		h = h + self.font:lineSkip()
	end

	self:drawSelectionList(s, 2, 5, self.font_h, self.equip_list, self.list == self.equip_list and self.sel or -1, "name", self.scroll, self.max)
	self:drawHBorder(s, self.iw / 2, 2, sh - 4)
	self:drawSelectionList(s, self.iw / 2 + 5, 5, self.font_h, self.inven_list, self.list == self.inven_list and self.sel or -1, "name", self.scroll, self.max)
end
