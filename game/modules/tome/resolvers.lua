--- Resolves equipment creation for an actor
function resolvers.equip(t)
	return {__resolver="equip", t}
end
--- Actually resolve the equipment creation
function resolvers.calc.equip(t, e)
	-- Iterate of object requests, try to create them and equip them
	for i, filter in ipairs(t[1]) do
		print("Equipment resolver", filter.type, filter.subtype)
		local o = game.zone:makeEntity(game.level, "object", filter)
		if o then
			print("Zone made us an equipment according to filter!", o:getName())
			e:wearObject(o, true, false)

			-- Do not drop it unless it is an ego or better
			if not o.egoed and not o.unique then o.no_drop = true end
		end
	end
	-- Delete the origin field
	return nil
end

--- Resolves drops creation for an actor
function resolvers.drops(t)
	return {__resolver="drops", t}
end
--- Actually resolve the drops creation
function resolvers.calc.drops(t, e)
	t = t[1]
	if not rng.percent(t.chance) then return nil end

	-- Iterate of object requests, try to create them and drops them
	for i = 1, (t.nb or 1) do
		local filter = t[rng.range(1, #t)]
		print("Drops resolver", filter.type, filter.subtype)
		local o = game.zone:makeEntity(game.level, "object", filter)
		if o then
			print("Zone made us an drop according to filter!", o:getName())
			e:addObject(e.INVEN_INVEN, o)
		end
	end
	-- Delete the origin field
	return nil
end
