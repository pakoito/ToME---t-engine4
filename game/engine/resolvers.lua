resolvers = {}
resolvers.calc = {}

--- Resolves a rng range
function resolvers.rngrange(x, y)
	return {__resolver="rngrange", x, y}
end
function resolvers.calc.rngrange(t)
	return rng.range(t[1], t[2])
end

--- Average random
function resolvers.rngavg(x, y)
	return {__resolver="rngavg", x, y}
end
function resolvers.calc.rngavg(t)
	return rng.avg(t[1], t[2])
end

--- Random bonus based on level
resolvers.current_level = 1
function resolvers.mbonus(max, add)
	return {__resolver="mbonus", max, add}
end
function resolvers.calc.mbonus(t)
	return rng.mbonus(t[1], resolvers.current_level, 50) + (t[2] or 0)
end

--- Talents resolver
function resolvers.talents(list)
	return {__resolver="talents", list}
end
function resolvers.calc.talents(t, e)
	local ts = {}
	for i, tid in ipairs(t[1]) do ts[tid] = true end
	return ts
end
