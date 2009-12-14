-- The basic stuff used to damage a grid
defaultProjector(function(src, x, y, type, dam)
	local target = game.level.map(x, y, Map.ACTOR)
	if target then
		game.logSeen(target, "%s hits %s for #aaaaaa#%0.2f %s damage#ffffff#.", src.name:capitalize(), target.name, dam, DamageType:get(type).name)
		local sx, sy = game.level.map:getTileToScreen(x, y)
		if target:takeHit(dam, src) then
			if src == game.player or target == game.player then
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "Kill!", {255,0,255})
			end
		else
			if src == game.player or target == game.player then
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, tostring(-dam), {255,0,255})
			end
		end
	end
end)

newDamageType{
	name = "physical", type = "PHYSICAL",
}

newDamageType{
	name = "arcane", type = "ARCANE",
}
newDamageType{
	name = "fire", type = "FIRE",
}
newDamageType{
	name = "cold", type = "COLD",
}
newDamageType{
	name = "nature", type = "NATURE",
}
newDamageType{
	name = "lightning", type = "LIGHTNING",
}
newDamageType{
	name = "light", type = "LIGHT",
	projector = function(src, x, y, type, dam)
		game.level.map.lites(x, y, true)
	end,
}

newDamageType{
	name = "fireburn", type = "FIREBURN",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam / 2)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Set on fire!
			target:setEffect(target.EFF_BURNING, 3, {src=src, power=dam / 2 / 3})
		end
	end,
}

newDamageType{
	name = "netherflame", type = "NETHERFLAME",
}
