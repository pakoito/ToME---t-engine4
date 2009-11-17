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

function inherit(base)
	return function(c)
		c.new = function(...)
			local obj = {}
			setmetatable(c, {__index=base})
			setmetatable(obj, {__index=c})
			if obj.init then obj:init(...) end
			return obj
		end
		return c
	end
end

function _M:clone(t, deep)
	local n = {}
	for k, e in pairs(self) do
		n[k] = e
	end
	if t then
		for k, e in pairs(t) do
			n[k] = e
		end
	end
	setmetatable(n, getmetatable(self))
	if n.cloned then n:cloned(self) end
	return n
end
