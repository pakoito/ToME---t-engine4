local Entity = require "engine.Entity"

module(..., package.seeall, class.make)

function _M:init(w, h)
	getmetatable(self).__call = _M.call
	self.map = core.new_map(w, h)
end

function _M:setCurrent()
	self.map:setCurrent()
end

function _M:call(x, y, pos, entity)
	if entity then
		self.map(x, y, pos, entity.uid)
	else
		return __uids[self.map(x, y, pos)]
	end
end
