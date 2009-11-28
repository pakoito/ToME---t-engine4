require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor)
	self.actor = actor
	engine.Dialog.init(self, "Levelup: "..actor.name, game.w, game.h)

--	self.

	self:keyCommands{
		_ESCAPE = function()
			game:unregisterDialog(self)
		end,
	}
end

function _M:drawDialog(s, w, h)
	s:drawColorStringCentered(self.font, "Stats points left: "..self.actor.unused_stats, 2, 2, self.iw - 2, self.ih - 2)
end
