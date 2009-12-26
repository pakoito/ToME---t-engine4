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

-- Arcane is basic (usualy) unreistable damage
newDamageType{
	name = "arcane", type = "ARCANE",
}
-- The four elemental damges
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

-- Light up the room
newDamageType{
	name = "light", type = "LIGHT",
	projector = function(src, x, y, type, dam)
		game.level.map.lites(x, y, true)
	end,
}

-- Fire damage + DOT
newDamageType{
	name = "fireburn", type = "FIREBURN",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam / 2)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Set on fire!
			target:setEffect(target.EFF_BURNING, 3, {src=src, power=dam / 6})
		end
	end,
}

-- Irresistible fire damage
newDamageType{
	name = "netherflame", type = "NETHERFLAME",
}

-- Freezes target, chcks for spellresistance
newDamageType{
	name = "freeze", type = "FREEZE",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Freeze it, if we pass the test
			local sx, sy = game.level.map:getTileToScreen(x, y)
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
				target:setEffect(target.EFF_FROZEN, dam, {src=src})

				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "Frozen!", {0,255,155})
			else
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "Resist!", {0,255,155})
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Cold damage + repulsion; checks for spell power against physical resistance
newDamageType{
	name = "wave", type = "WAVE",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) then
				target:knockBack(src.x, src.y, 1)
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the wave!", target.name:capitalize())
			end
		end
	end,
}

-- Physical damage + repulsion; checks for spell power against physical resistance
newDamageType{
	name = "spellknockback", type = "SPELLKNOCKBACK",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) then
				target:knockBack(src.x, src.y, 2)
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the punch!", target.name:capitalize())
			end
		end
	end,
}

-- Poisoning damage
newDamageType{
	name = "poison", type = "POISON",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.NATURE).projector(src, x, y, DamageType.NATURE, dam / 6)
		dam = dam - dam / 6
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Set on fire!
			target:setEffect(target.EFF_POISONED, 5, {src=src, power=dam / 5})
		end
	end,
}
