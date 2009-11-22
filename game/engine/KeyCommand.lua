require "engine.class"
require "engine.Key"

--- Receieves keypresses and acts upon them
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

--- Adds a key/command combinaison
-- @param sym the key to handle
-- @param mods a table with the mod keys needed, i.e: {"ctrl", "alt"}
-- @param fct the function to call when the key is pressed
function _M:addCommand(sym, mods, fct)
	if type(sym) == "string" then sym = self[sym] end
	if not sym then return end

	self.commands[sym] = self.commands[sym] or {}
	if not fct then
		self.commands[sym].plain = mods
	else
		table.sort(mods)
		self.commands[sym][table.concat(mods,',')] = fct
	end
end

--- Adds many key/command at once
-- @usage self.key:addCommands{<br/>
--   _LEFT = function()<br/>
--     print("left")<br/>
--   end,<br/>
--   _RIGHT = function()<br/>
--     print("right")<br/>
--   end,<br/>
--   {{"x","ctrl"}] = function()<br/>
--     print("control+x")<br/>
--   end,<br/>
-- }

function _M:addCommands(t)
	for k, e in pairs(t) do
		if type(k) == "string" then
			self:addCommand(k, e)
		elseif type(k) == "table" then
			local sym = table.remove(k, 1)
			self:addCommand(sym, k, e)
		end
	end
end
