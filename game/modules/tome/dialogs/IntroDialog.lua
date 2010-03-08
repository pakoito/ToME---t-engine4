require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor)
	self.actor = actor
	engine.Dialog.init(self, "Welcome to ToME "..actor.name, 500, 300)

	self:keyCommands(nil, {
		ACCEPT = "EXIT",
		EXIT = function()
			game:unregisterDialog(self)
		end,
	})
end

function _M:drawDialog(s)
	local f, err = loadfile("/data/texts/intro-"..self.actor.starting_intro..".lua")
	if not f and err then error(err) end
	setfenv(f, {name=self.actor.name})
	local str = f()
	local lines = str:splitLines(self.iw - 10, self.font)
	for i = 1, #lines do
		s:drawColorString(self.font, lines[i], 5, 4 + i * self.font:lineSkip())
	end
	self.changed = false
end
