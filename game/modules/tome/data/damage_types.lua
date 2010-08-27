-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

-- The basic stuff used to damage a grid
setDefaultProjector(function(src, x, y, type, dam)
	local target = game.level.map(x, y, Map.ACTOR)
	if target then
		print("[PROJECTOR] starting dam", dam)

		-- Difficulty settings
		if game.difficulty == game.DIFFICULTY_EASY and target:resolveSource().player then
			dam = dam * 0.8
		elseif game.difficulty == game.DIFFICULTY_NIGHTMARE then
			if target:resolveSource().player then dam = dam * 1.7
			elseif src:resolveSource().player then dam = dam * 0.7 end
		elseif game.difficulty == game.DIFFICULTY_INSANE then
			if target:resolveSource().player then dam = dam * 1.5
			elseif src:resolveSource().player then dam = dam * 0.5 end
		end
		print("[PROJECTOR] after difficulty dam", dam)

		-- Increases damage
		if src.inc_damage then
			local inc = (src.inc_damage.all or 0) + (src.inc_damage[type] or 0)
			dam = dam + (dam * inc / 100)
		end

		-- Reduce damage with resistance
		if target.resists then
			local pen = 0
			if src.resists_pen then pen = (src.resists_pen.all or 0) + (src.resists_pen[type] or 0) end
			local res = (target.resists.all or 0) + (target.resists[type] or 0)
			res = res * (100 - pen) / 100
			print("[PROJECTOR] res", res, (100 - res) / 100, " on dam", dam)
			if res >= 100 then dam = 0
			elseif res <= -100 then dam = dam * 2
			else dam = dam * ((100 - res) / 100)
			end
		end
		print("[PROJECTOR] final dam", dam)

		local flash = game.flash.NEUTRAL
		if target == game.player then flash = game.flash.BAD end
		if src == game.player then flash = game.flash.GOOD end

		local srcname = src.x and src.y and game.level.map.seens(src.x, src.y) and src.name:capitalize() or "Something"
		game.logSeen(target, flash, "%s hits %s for %s%0.2f %s damage#LAST#.", srcname, target.name, DamageType:get(type).text_color or "#aaaaaa#", dam, DamageType:get(type).name)
		local sx, sy = game.level.map:getTileToScreen(x, y)
		if target:takeHit(dam, src) then
			if src == game.player or target == game.player then
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "Kill!", {255,0,255})
			end
		else
			if src == game.player then
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, tostring(-math.ceil(dam)), {0,255,0})
			elseif target == game.player then
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, tostring(-math.ceil(dam)), {255,0,0})
			end
		end

		if src.attr and src:attr("martyrdom") then
			DamageType.defaultProjector(target, src.x, src.y, type, dam * src.martyrdom / 100)
		end
		return dam
	end
	return 0
end)

local function tryDestroy(who, inven, dam, destroy_prop, proof_prop, msg)
	if not inven then return end
	for i = #inven, 1, -1 do
		local o = inven[i]
		if o[destroy_prop] and not o[proof_prop] then
			for j, test in ipairs(o[destroy_prop]) do
				if dam >= test[1] and rng.percent(test[2]) then
					game.logPlayer(who, msg, o:getName{do_color=true, no_count=true})
					local obj = who:removeObject(inven, i)
					obj:removed()
					break
				end
			end
		end
	end
end

newDamageType{
	name = "physical", type = "PHYSICAL",
}

-- Arcane is basic (usualy) unresistable damage
newDamageType{
	name = "arcane", type = "ARCANE", text_color = "#PURPLE#",
}
-- The elemental damges
newDamageType{
	name = "fire", type = "FIRE", text_color = "#LIGHT_RED#",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType.defaultProjector(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if realdam > 0 and target and not target:attr("fire_proof") then
			tryDestroy(target, target:getInven("INVEN"), realdam, "fire_destroy", "fire_proof", "The burst of heat destroys your %s!")
		end
	end,
}
newDamageType{
	name = "cold", type = "COLD", text_color = "#1133F3#",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType.defaultProjector(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if realdam > 0 and target and not target:attr("cold_proof") then
			tryDestroy(target, target:getInven("INVEN"), realdam, "cold_destroy", "cold_proof", "The intense cold destroys your %s!")
		end
	end,
}

-- Nature & Blight: Opposing damage types
newDamageType{
	name = "nature", type = "NATURE", text_color = "#LIGHT_GREEN#",
}
newDamageType{
	name = "blight", type = "BLIGHT", text_color = "#DARK_GREEN#",
}

newDamageType{
	name = "lightning", type = "LIGHTNING", text_color = "#ROYAL_BLUE#",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType.defaultProjector(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if realdam > 0 and target and not target:attr("elec_proof") then
			tryDestroy(target, target:getInven("INVEN"), realdam, "elec_destroy", "elec_proof", "The burst of lightning destroys your %s!")
		end
	end,
}
-- Acid detroys potions
newDamageType{
	name = "acid", type = "ACID", text_color = "#GREEN#",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType.defaultProjector(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if realdam > 0 and target and not target:attr("acid_proof") then
			tryDestroy(target, target:getInven("INVEN"), realdam, "acid_destroy", "acid_proof", "The splash of acid destroys your %s!")
		end
	end,
}

-- Lite up the room
newDamageType{
	name = "lite", type = "LITE", text_color = "#YELLOW#",
	projector = function(src, x, y, type, dam)
		-- Dont lit magically unlit grids
		local g = game.level.map(x, y, Map.TERRAIN+1)
		if g and g.unlit then
			if g.unlit <= dam then game.level.map:remove(x, y, Map.TERRAIN+1)
			else return end
		end

		game.level.map.lites(x, y, true)
	end,
}

-- Light damage
newDamageType{
	name = "light", type = "LIGHT", text_color = "#YELLOW#",
}

-- Darkness damage
newDamageType{
	name = "darkness", type = "DARKNESS", text_color = "#DARK_GREY#",
}

-- Mind damage
newDamageType{
	name = "mind", type = "MIND", text_color = "#YELLOW#",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatMindpower() * 0.7, target:combatMentalResist(), 0, 95, 15) then
				return DamageType.defaultProjector(src, x, y, type, dam)
			else
				game.logSeen(target, "%s resists the mind attack!", target.name:capitalize())
				return 0
			end
		end
	end,
}

-- Silence
newDamageType{
	name = "SILENCE", type = "SILENCE",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatMindpower() * 0.7, target:combatMentalResist(), 0, 95, 15) then
				target:setEffect(target.EFF_SILENCED, math.ceil(dam), {})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
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
newDamageType{
	name = "blinding ink", type = "BLINDING_INK",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatAttackStr(), target:combatMentalResist(), 0, 95, 15) and target:canBe("blind") then
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
		local dur = 3
		local perc = 50
		if _G.type(dam) == "table" then dam, dur, perc = dam.dam, dam.dur, (dam.initial or perc) end
		local init_dam = dam * perc / 100
		if init_dam > 0 then DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, init_dam) end
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Set on fire!
			dam = dam - init_dam
			target:setEffect(target.EFF_BURNING, dur, {src=src, power=dam / dur})
		end
	end,
}

-- Darkness + Stun
newDamageType{
	name = "darkstun", type = "DARKSTUN",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Set on fire!
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 4, {})
			else
				game.logSeen(target, "%s resists the darkness!", target.name:capitalize())
			end
		end
	end,
}

-- Cold + Stun
newDamageType{
	name = "coldstun", type = "COLDSTUN",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 4, {})
			else
				game.logSeen(target, "%s resists the stun!", target.name:capitalize())
			end
		end
	end,
}

-- Fire DOT + Stun
newDamageType{
	name = "flameshock", type = "FLAMESHOCK",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Set on fire!
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe("stun") then
				target:setEffect(target.EFF_BURNING_SHOCK, dam.dur, {src=src, power=dam.dam / dam.dur})
			else
				game.logSeen(target, "%s resists the searing flame!", target.name:capitalize())
			end
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

-- Cold damage + freeze ground
newDamageType{
	name = "coldnevermove", type = "COLDNEVERMOVE",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe("pin") and target:canBe("stun") and not target:attr("fly") and not target:attr("levitation") then
				target:setEffect(target.EFF_FROZEN_FEET, dam.dur, {})
			end
		end
	end,
}

-- Freezes target, chcks for spellresistance
newDamageType{
	name = "freeze", type = "FREEZE",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Freeze it, if we pass the test
			local sx, sy = game.level.map:getTileToScreen(x, y)
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe("stun") then
				target:setEffect(target.EFF_FROZEN, dam, {src=src})

				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "Frozen!", {0,255,155})
			else
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "Resist!", {0,255,155})
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Cold/physical damage + repulsion; checks for spell power against physical resistance
newDamageType{
	name = "wave", type = "WAVE",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam / 2)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam / 2)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, 1)
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the wave!", target.name:capitalize())
			end
		end
	end,
}

-- Fireburn damage + repulsion; checks for spell power against physical resistance
newDamageType{
	name = "fire knockback", type = "FIREKNOCKBACK",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		if _G.type(dam) ~= "table" then dam = {dam=dam, dist=3} end
		tmp = tmp or {}
		if target and not tmp[target] then
			tmp[target] = true
			DamageType:get(DamageType.FIREBURN).projector(src, x, y, DamageType.FIREBURN, dam.dam)
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, dam.dist)
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the punch!", target.name:capitalize())
			end
		end
	end,
}

-- Physical damage + repulsion; checks for spell power against physical resistance
newDamageType{
	name = "spellknockback", type = "SPELLKNOCKBACK",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not tmp[target] then
			tmp[target] = true
			DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam)
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, 3)
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the punch!", target.name:capitalize())
			end
		end
	end,
}

-- Physical damage + repulsion; checks for mind power against physical resistance
newDamageType{
	name = "mindknockback", type = "MINDKNOCKBACK",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not tmp[target] then
			tmp[target] = true
			DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam)
			if target:checkHit(src:combatMindpower() * 0.8, target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, 3)
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the punch!", target.name:capitalize())
			end
		end
	end,
}

-- Physical damage + repulsion; checks for attack power against physical resistance
newDamageType{
	name = "physknockback", type = "PHYSKNOCKBACK",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not tmp[target] then
			tmp[target] = true
			DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam)
			if target:checkHit(src:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, dam.dist)
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
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("poison") then
			target:setEffect(target.EFF_POISONED, 5, {src=src, power=dam / 6})
		end
	end,
}

-- Spydric poison: prevents movement
newDamageType{
	name = "spydric poison", type = "SPYDRIC_POISON",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.NATURE).projector(src, x, y, DamageType.NATURE, dam.dam / dam.dur)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("poison") then
			target:setEffect(target.EFF_SPYDRIC_POISON, dam.dur, {src=src, power=dam.dam / dam.dur})
		end
	end,
}

-- Bleeding damage
newDamageType{
	name = "bleed", type = "BLEED",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam / 6)
		dam = dam - dam / 6
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("cut") then
			-- Set on fire!
			target:setEffect(target.EFF_CUT, 5, {src=src, power=dam / 5})
		end
	end,
}

-- Slime damage
newDamageType{
	name = "slime", type = "SLIME",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.NATURE).projector(src, x, y, DamageType.NATURE, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(target.EFF_SLOW, 3, {power=0.3})
		end
	end,
}

-- Poisoning damage
newDamageType{
	name = "dig", type = "DIG",
	projector = function(src, x, y, typ, dam)
		local feat = game.level.map(x, y, Map.TERRAIN)
		if feat then
			if feat.dig then
				local newfeat_name, newfeat, silence = feat.dig, nil, false
				if type(feat.dig) == "function" then newfeat_name, newfeat, silence = feat.dig(src, x, y, feat) end
				game.level.map(x, y, Map.TERRAIN, newfeat or game.zone.grid_list[newfeat_name])
				if not silence then
					game.logSeen({x=x,y=y}, "%s turns into %s.", feat.name:capitalize(), (newfeat or game.zone.grid_list[newfeat_name]).name)
				end
			end
		end
	end,
}

-- Slowness
newDamageType{
	name = "slow", type = "SLOW",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Freeze it, if we pass the test
			local sx, sy = game.level.map:getTileToScreen(x, y)
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 20) then
				target:setEffect(target.EFF_SLOW, 7, {power=dam})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Time prison, invulnerability and stun
newDamageType{
	name = "time prison", type = "TIME_PRISON",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Freeze it, if we pass the test
			local sx, sy = game.level.map:getTileToScreen(x, y)
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 20) then
				target:setEffect(target.EFF_TIME_PRISON, dam, {})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Confusion
newDamageType{
	name = "confusion", type = "CONFUSION",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit((dam.power_check or src.combatSpellpower)(src), (dam.resist_check or target.combatMentalResist)(target), 0, 95, 15) and target:canBe("confusion") then
				target:setEffect(target.EFF_CONFUSED, dam.dur, {power=dam.dam})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Physical + Blind
newDamageType{
	name = "sand", type = "SAND",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, dam.dur, {})
			else
				game.logSeen(target, "%s resists the sandstorm!", target.name:capitalize())
			end
		end
	end,
}

-- Physical + Pinned
newDamageType{
	name = "pinning", type = "PINNING",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, dam.dur, {})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Drain Exp
newDamageType{
	name = "drain experience", type = "DRAINEXP",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit((dam.power_check or src.combatSpellpower)(src), (dam.resist_check or target.combatMentalResist)(target), 0, 95, 15) then
				target:gainExp(-dam.dam*2)
				game.logSeen(target, "%s drains %s experience!", src.name:capitalize(), target.name)
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Drain Life
newDamageType{
	name = "drain life", type = "DRAINLIFE",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam, healfactor=0.4} end
		local realdam = DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			src:heal(realdam * dam.healfactor)
			game.logSeen(target, "%s drains %s life!", src.name:capitalize(), target.name)
		end
	end,
}

-- Drain Vim
newDamageType{
	name = "drain vim", type = "DRAIN_VIM",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam, vim=0.2} end
		local realdam = DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam.dam)
		src:incVim(realdam * dam.vim)
	end,
}

-- Retch: heal undead; damage living
newDamageType{
	name = "retch", type = "RETCH",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target.undead then
			target:heal(dam)
		elseif target then
			DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam)
		end
	end,
}

-- Holy light, damage demon/undead; heal ohers
newDamageType{
	name = "holy light", type = "HOLY_LIGHT",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not target.undead and not target.demon then
			target:heal(dam / 2)
		elseif target then
			DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam)
		end
	end,
}

-- Heals
newDamageType{
	name = "healing", type = "HEAL",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:heal(dam, src)
		end
	end,
}

-- Corrupted blood, blight damage + potential diseases
newDamageType{
	name = "corrupted blood", type = "CORRUPTED_BLOOD",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("disease") then
			local eff = rng.table{{target.EFF_ROTTING_DISEASE, "con"}, {target.EFF_DECREPITUDE_DISEASE, "dex"}, {target.EFF_WEAKNESS_DISEASE, "str"}}
			target:setEffect(eff[1], dam.dur or 5, { src = src, [eff[2]] = dam.disease_power, dam = dam.disease_dam or (dam.dam / 5) })
		end
	end,
}
