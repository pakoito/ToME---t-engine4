--- Random bonus based on level
resolvers.current_level = 1
function resolvers.mbonus(max)
	return {__resolver="mbonus", max}
end
function resolvers.calc.mbonus(t)
	return rng.mbonus(t[1], resolvers.current_level, 50)
end
