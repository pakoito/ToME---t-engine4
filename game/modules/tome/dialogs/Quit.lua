require "engine.class"
require "engine.Dialog"
local Savefile = require "engine.Savefile"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init()
	engine.Dialog.init(self, "Realy exit ToME?", 300, 100)
	self:keyCommands{
		_y = function()
			local save = Savefile.new(game.save_name)
			save:saveGame(game)
			save:close()
			util.showMainMenu()
		end,
		__DEFAULT = function()
			game:unregisterDialog(self)
			game.quit_dialog = false
		end,
	}
end

function _M:drawDialog(s, w, h)
	s:drawColorStringCentered(self.font, "Press Y to quit, any other keys to stay", 2, 2, self.iw - 2, self.ih - 2)
end
