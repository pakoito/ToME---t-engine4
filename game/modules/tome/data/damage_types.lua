-- The basic stuff used to damage a grid
setDefaultProjector(function(src, x, y, type, dam)
	local target = game.level.map(x, y, Map.ACTOR)
	if target then
		-- Reduce damage with resistance
		local res = target.resists[type] or 0
		if res == 10 then dam = 0
		else dam = dam * (100 / (100 - res))
		end

		local flash = game.flash.NEUTRAL
		if target == game.player then flash = game.flash.BAD end
		if src == game.player then flash = game.flash.GOOD end

		game.logSeen(target, flash, "%s hits %s for #aaaaaa#%0.2f %s damage#ffffff#.", src.name:capitalize(), target.name, dam, DamageType:get(type).name)
		local sx, sy = game.level.map:getTileToScreen(x, y)
		if target:takeHit(dam, src) then
			if src == game.player or target == game.player then
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "Kill!", {255,0,255})
			end
		else
			if src == game.player then
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, tostring(-dam), {0,255,0})
			elseif target == game.player then
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, tostring(-dam), {255,0,0})
			end
		end
	end
end)

local function tryDestroy(who, inven, destroy_prop, proof_prop, msg)
	for i = #inven, 1, -1 do
		local o = inven[i]
		print(who, inven, destroy_prop, proof_prop, msg, "::", i)
		if o[destroy_prop] and rng.percent(o[destroy_prop]) and not o[proof_prop] then
			game.logPlayer(who, msg, o:getName())
			who:removeObject(inven, i)
		end
	end
end

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
	projector = function(src, x, y, type, dam)
		DamageType.defaultProjector(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not target:attr("fire_proof") then
			tryDestroy(target, target:getInven("INVEN"), "fire_destroy", "fire_proof", "The burst of heat destroys your %s!")
		end
	end,
}
newDamageType{
	name = "cold", type = "COLD",
	projector = function(src, x, y, type, dam)
		DamageType.defaultProjector(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not target:attr("cold_proof") then
			tryDestroy(target, target:getInven("INVEN"), "cold_destroy", "cold_proof", "The intense cold destroys your %s!")
		end
	end,
}
newDamageType{
	name = "nature", type = "NATURE",
}
newDamageType{
	name = "lightning", type = "LIGHTNING",
	projector = function(src, x, y, type, dam)
		DamageType.defaultProjector(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not target:attr("elec_proof") then
			tryDestroy(target, target:getInven("INVEN"), "elec_destroy", "elec_proof", "The burst of lightning destroys your %s!")
		end
	end,
}
-- Acid detroys potions
newDamageType{
	name = "acid", type = "ACID",
	projector = function(src, x, y, type, dam)
		DamageType.defaultProjector(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not target:attr("acid_proof") then
			tryDestroy(target, target:getInven("INVEN"), "acid_destroy", "acid_proof", "The splash of acid destroys your %s!")
		end
	end,
}

-- Light up the room
newDamageType{
	name = "light", type = "LIGHT",
	projector = function(src, x, y, type, dam)
		game.level.map.lites(x, y, true)
	end,
}

-- Blinds
newDamageType{
	name = "blindness", type = "BLIND",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, math.ceil(dam), {})
			else
				game.logSeen(target, "%s resists the blinding light!", target.name:capitalize())
			end
		end
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

-- Cold damage + freeze chance
newDamageType{
	name = "ice", type = "ICE",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam)
		if rng.percent(25) then
			DamageType:get(DamageType.FREEZE).projector(src, x, y, DamageType.FREEZE, 2)
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
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
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
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
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
