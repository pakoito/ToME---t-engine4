module("class", package.seeall)

local base = _G

function make(c)
	c.new = function(...)
		local obj = {}
		setmetatable(c, {__index=_M})
		setmetatable(obj, {__index=c})
		if obj.init then obj:init(...) end
		return obj
	end
	return c
end

function _M:clone(deep)
	local n = {}
	for k, e in pairs(self) do
		n[k] = e
	end
	setmetatable(n, getmetatable(self))
	if n.cloned then n:cloned(self) end
	return n
end
