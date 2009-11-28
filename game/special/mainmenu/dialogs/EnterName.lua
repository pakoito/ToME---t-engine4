require "engine.class"
require "engine.Dialog"
require "engine.Savefile"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(runmod)
	engine.Dialog.init(self, "Enter your character's name?", 300, 100)
	self.runmod = runmod
	self.name = ""
	self:keyCommands{
		_RETURN = function()
			if self.name:len() >= 3 then
				game:unregisterDialog(self)

				-- Ok run the module
				local M = self.runmod.load()
				_G.game = M.new()
				_G.game:setPlayerName(self.name)

				-- Delete the corresponding savefile if any
				local save = engine.Savefile.new(_G.game.save_name)
				save:delete()
				save:close()

				-- And now run it!
				_G.game:run()
			else
				engine.Dialog:simplePopup("Error", "Character name must be between 3 and 25 characters.")
			end
		end,
		_BACKSPACE = function()
			self.name = self.name:sub(1, self.name:len() - 1)
		end,
		__TEXTINPUT = function(c)
			if self.name:len() < 25 then
				self.name = self.name .. c
				self.changed = true
			end
		end,
	}
end

function _M:drawDialog(s, w, h)
	s:drawColorStringCentered(self.font, "Enter your characters name:", 2, 2, self.iw - 2, self.ih - 2 - self.font:lineSkip())
	s:drawColorStringCentered(self.font, self.name, 2, 2 + self.font:lineSkip(), self.iw - 2, self.ih - 2 - self.font:lineSkip())
end
