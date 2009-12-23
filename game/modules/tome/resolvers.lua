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
		end
	end
	-- Delete the origin field
	return nil
end
