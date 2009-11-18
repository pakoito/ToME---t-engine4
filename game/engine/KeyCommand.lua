require "engine.class"
require "engine.Key"
module(..., package.seeall, class.inherit(engine.Key))

function _M:init()
	engine.Key.init(self)
	self.commands = {}
end

function _M:receiveKey(sym, ctrl, shift, alt, meta, unicode)
	if not self.commands[sym] then return end
	if ctrl or shift or alt or meta then
		local mods = {}
		if alt then mods[#mods+1] = "alt" end
		if ctrl then mods[#mods+1] = "ctrl" end
		if meta then mods[#mods+1] = "meta" end
		if shift then mods[#mods+1] = "shift" end
		mods = table.concat(mods,',')
		if self.commands[sym][mods] then
			self.commands[sym][mods](sym, ctrl, shift, alt, meta, unicode)
		end
	elseif self.commands[sym].plain then
		self.commands[sym].plain(sym, ctrl, shift, alt, meta, unicode)
	end
end

function _M:addCommand(sym, mods, fct)
	self.commands[sym] = self.commands[sym] or {}
	if not mods or #mods == 0 then
		self.commands[sym].plain = fct
	else
		table.sort(mods)
		self.commands[sym][table.concat(mods,',')] = fct
	end
end
