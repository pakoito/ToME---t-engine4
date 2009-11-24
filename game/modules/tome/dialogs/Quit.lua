require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init()
	engine.Dialog.init(self, "Realy exit ToME?", 200, 150)
end

function _M:drawDialog(s)
	s:drawString(self.font, "Press Y to quit, any other keys to stay", 2, 2, 255,255,255)
end
