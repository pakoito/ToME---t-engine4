require "config"
require "engine.class"
require "engine.Key"

--- Receieves keypresses and acts upon them
module(..., package.seeall, class.inherit(engine.Key))

function _M:init()
	engine.Key.init(self)
	self.commands = {}
	self.on_input = false
	self.locale_convert = {}

	-- Fullscreen toggle
	self:addCommand(self._RETURN, {"alt"}, function() core.display.fullscreen() end)
end

--- Adds the profiler keybind (ctrl, alt, chift, p)
function _M:setupProfiler()
	-- Profiler
	self:addCommand(self._p, {"ctrl","alt","shift"}, function()
		if not _G.profiling then
			print("Starting profiler")
			_G.profiling = true
			profiler.start("profiler.log")
		else
			profiler.stop()
			print("Stopped profiler")
		end
	end)
end

function _M:receiveKey(sym, ctrl, shift, alt, meta, unicode)
	-- Convert locale
	sym = self.locale_convert[sym] or sym

	if not self.commands[sym] and not self.commands[self.__DEFAULT] then
		if self.on_input and unicode then self.on_input(unicode) end
		return
	end
	if self.commands[sym] and (ctrl or shift or alt or meta) and not self.commands[sym].anymod then
		local mods = {}
		if alt then mods[#mods+1] = "alt" end
		if ctrl then mods[#mods+1] = "ctrl" end
		if meta then mods[#mods+1] = "meta" end
		if shift then mods[#mods+1] = "shift" end
		mods = table.concat(mods,',')
		if self.commands[sym][mods] then
			self.commands[sym][mods](sym, ctrl, shift, alt, meta, unicode)
		end
	elseif self.commands[sym] and self.commands[sym].plain then
		self.commands[sym].plain(sym, ctrl, shift, alt, meta, unicode)
	elseif self.commands[self.__DEFAULT] and self.commands[self.__DEFAULT].plain then
		self.commands[self.__DEFAULT].plain(sym, ctrl, shift, alt, meta, unicode)
	end
end

--- Adds a key/command combinaison
-- @param sym the key to handle
-- @param mods a table with the mod keys needed, i.e: {"ctrl", "alt"}
-- @param fct the function to call when the key is pressed
function _M:addCommand(sym, mods, fct, anymod)
	if type(sym) == "string" then sym = self[sym] end
	if not sym then return end

	if sym == self.__TEXTINPUT then return self:setTextInput(mods) end

	self.commands[sym] = self.commands[sym] or {}
	if not fct then
		self.commands[sym].plain = mods
	else
		table.sort(mods)
		self.commands[sym][table.concat(mods,',')] = fct
	end
	if anymod then self.commands[sym].anymod = true end
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
	local aliases = {}
	for k, e in pairs(t) do
		if type(e) == "function" then
			if type(k) == "string" then
				self:addCommand(k, e)
			elseif type(k) == "table" then
				local sym = table.remove(k, 1)
				local anymod = false
				if k[1] == "anymod" then k, e, anymod = e, nil, true end
				self:addCommand(sym, k, e, anymod)
			end
		elseif e[1] == "alias" then
			aliases[#aliases+1] = {k, e[2]}
		end
	end

	for i, alias in ipairs(aliases) do
		self:addCommands{[alias[1]] = self.commands[self[alias[2]]].plain}
	end
end

--- Receieves any unbound keys as UTF8 characters (if possible)
-- @param fct the function to call for each key, get a single parameter to pass the UTF8 string
function _M:setTextInput(fct)
	self.on_input = fct
end

--- Loads a locale converter
-- WARNING: This only converts the "sym" key, *NOT* the unicode key
-- @param file the locale convertion file to load
function _M:loadLocaleConvertion(file)
	local f, err = loadfile(file)
	if not f and err then error(err) end
	setfenv(f, setmetatable({
		locale = config.settings.keyboard.locale,
	}, {__index=engine.Key}))
	conv = f() or {}

	for k, e in pairs(conv) do
		self.locale_convert[k] = e
	end
end
