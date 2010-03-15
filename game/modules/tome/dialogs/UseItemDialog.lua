require "engine.class"
require "engine.Dialog"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor, object, item, inven, onuse)
	self.actor = actor
	self.object = object
	self.inven = inven
	self.item = item
	self.onuse = onuse

	self.font = core.display.newFont("/data/font/Vera.ttf", 12)
	self:generateList()
	local name = object:getName()
	local nw, nh = self.font:size(name)
	engine.Dialog.init(self, name, math.max(nw, self.max) + 10, self.maxh + 10 + 25, nil, nil, nil, self.font)

	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 45) / self.font_h) - 1

	self:keyCommands(nil, {
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		ACCEPT = function() self:use() end,
		EXIT = function() game:unregisterDialog(self) end,
	})
	self:mouseZones{
		{ x=2, y=45, w=350, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.changed = true
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" then self:learn(true)
			elseif button == "right" then self:learn(false)
			end
			self.changed = true
		end },
	}
end

function _M:use()
	if not self.list[self.sel] then return end
	local act = self.list[self.sel].action

	if act == "use" then self.actor:playerUseItem(self.object, self.item)
	elseif act == "drop" then self.actor:doDrop(self.inven, self.item)
	elseif act == "wear" then self.actor:doWear(self.inven, self.item, self.object)
	elseif act == "takeoff" then self.actor:doTakeoff(self.inven, self.item, self.object)
	end

	self.onuse(self.inven, self.item, self.object)

	game:unregisterDialog(self)
end

function _M:generateList()
	local list = {}

	if self.object:canUseObject() then list[#list+1] = {name="Use", action="use"} end
	if self.inven == self.actor.INVEN_INVEN and self.object:wornInven() then list[#list+1] = {name="Wield/Wear", action="wear"} end
	if self.inven ~= self.actor.INVEN_INVEN and self.object:wornInven() then list[#list+1] = {name="Take off", action="takeoff"} end
	if self.inven == self.actor.INVEN_INVEN then list[#list+1] = {name="Drop", action="drop"} end

	self.max = 0
	self.maxh = 0
	for i, v in ipairs(list) do
		local w, h = self.font:size(v.name)
		self.max = math.max(self.max, w)
		self.maxh = self.maxh + h
	end

	self.list = list
end

function _M:drawDialog(s)
	local h = 2
	self:drawSelectionList(s, 2, h, self.font_h, self.list, self.sel, "name")
	self.changed = false
end
