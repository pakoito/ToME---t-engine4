require "engine.class"
require "engine.Mouse"

--- Represent a game
-- A module should subclass it and initialize anything it needs to play inside
module(..., package.seeall, class.make)

--- Constructor
-- Sets up the default keyhandler.
-- Also requests the display size and stores it in "w" and "h" properties
function _M:init(keyhandler)
	self.key = keyhandler
	self.level = nil
	self.log = function() end
	self.logSeen = function() end
	self.w, self.h = core.display.size()
	self.dialogs = {}

	self.mouse = engine.Mouse.new()
	self.mouse:setCurrent()
end

--- Starts the game
-- Modules should reimplement it to do whatever their game needs
function _M:run()
end

--- Sets the current level
-- @param level an engine.Level (or subclass) object
function _M:setLevel(level)
	self.level = level
end

--- Tells the game engine to play this game
function _M:setCurrent()
	core.game.set_current_game(self)
	_M.current = self
end

--- Displays the screen
-- Called by the engine core to redraw the screen every frame
function _M:display()
	for i, d in ipairs(self.dialogs) do
		d:display():toScreen(d.display_x, d.display_y)
	end
end

--- This is the "main game loop", do something here
function _M:tick()
end

--- Called by the engine when the user tries to close the window
function _M:onQuit()
end

--- Registers a dialog to display
function _M:registerDialog(d)
	table.insert(self.dialogs, d)
	self.dialogs[d] = #self.dialogs
end

--- Undisplay a dialog, removing its own keyhandler if needed
function _M:unregisterDialog(d)
	if not self.dialogs[d] then return end
	table.remove(self.dialogs, self.dialogs[d])
	self.dialogs[d] = nil
	d:unload()
end
