-- The basic stuff used to damage a grid
defaultProjector(function(src, x, y, type, dam)
print(src, x, y, type, dam)
	local target = game.level.map(x, y, Map.ACTOR)
	if target then
		game.logSeen(target, "%s hits %s for #aaaaaa#%0.2f %s damage#ffffff#.", src.name:capitalize(), target.name, dam, DamageType:get(type).name)
		target:takeHit(dam, src)
	end
end)

newDamageType{
	name = "mana", type = "MANA",
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
