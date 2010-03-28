require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(what)
	self.what = what

	local f, err = loadfile("/data/texts/unlock-"..self.what..".lua")
	if not f and err then error(err) end
	setfenv(f, {})
	self.name, self.str = f()

	game.logPlayer(game.player, "#VIOLET#Option unlocked: "..self.name)

	engine.Dialog.init(self, "Option unlocked: "..self.name, 600, 400)

	self:keyCommands(nil, {
		ACCEPT = "EXIT",
		EXIT = function()
			game:unregisterDialog(self)
		end,
	})
end

function _M:drawDialog(s)
	local lines = self.str:splitLines(self.iw - 10, self.font)
	local r, g, b
	for i = 1, #lines do
		r, g, b = s:drawColorString(self.font, lines[i], 5, 4 + i * self.font:lineSkip(), r, g, b)
	end
	self.changed = false
end
