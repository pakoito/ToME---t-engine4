-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
setDefaultProjector(function(src, x, y, type, dam, tmp, no_martyr)
	if not game.level.map:isBound(x, y) then return 0 end
	local terrain = game.level.map(x, y, Map.TERRAIN)
	if terrain then terrain:check("damage_project", src, x, y, type, dam) end

	local target = game.level.map(x, y, Map.ACTOR)
	if target then
		local rsrc = src.resolveSource and src:resolveSource() or src
		local rtarget = target.resolveSource and target:resolveSource() or target

		print("[PROJECTOR] starting dam", dam)

		-- Difficulty settings
		if game.difficulty == game.DIFFICULTY_EASY and rtarget.player then
			dam = dam * 0.7
		end
		print("[PROJECTOR] after difficulty dam", dam)

		-- Preemptive shielding
		if target.isTalentActive and target:isTalentActive(target.T_PREMONITION) then
			local t = target:getTalentFromId(target.T_PREMONITION)
			t.on_damage(target, t, type)
		end

		-- Increases damage
		if src.inc_damage then
			local inc = (src.inc_damage.all or 0) + (src.inc_damage[type] or 0)
			dam = dam + (dam * inc / 100)
		end

		-- Blast the iceblock
		if src.attr and src:attr("encased_in_ice") then
			local eff = src:hasEffect(src.EFF_FROZEN)
			eff.hp = eff.hp - dam
			local srcname = src.x and src.y and game.level.map.seens(src.x, src.y) and src.name:capitalize() or "Something"
			if eff.hp < 0 then
				game.logSeen(src, "%s forces the iceblock to shatter.", src.name:capitalize())
				src:removeEffect(src.EFF_FROZEN)
			else
				game:delayedLogDamage(src, {name="Iceblock", x=src.x, y=src.y}, dam, ("%s%d %s#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", math.ceil(dam), DamageType:get(type).name))
			end
			return 0
		end

		-- dark vision increases damage done in creeping dark
		if src and src.knowTalent and src:knowTalent(src.T_DARK_VISION) then
			local t = src:getTalentFromId(src.T_DARK_VISION)
			local damageIncrease = t.getDamageIncrease(src, t)
			if damageIncrease > 0
					and src and src.x and src.y
					and core.fov.distance(src.x, src.y, target.x, target.y) > (src.lite or 0) -- outside of lite radius
					and game.level.map:checkAllEntities(x, y, "creepingDark") then -- creeping dark square
				dam = dam + (dam * damageIncrease / 100)
				game.logPlayer(src, "You strike in the darkness. (+%d damage)", damageIncrease)
			end
		end

		if src and src.knowTalent and src:knowTalent(src.T_DARK_VISION)
				and src.x and src.y
				and game.level.map:checkAllEntities(x, y, "creepingDark") then
			local t = src:getTalentFromId(src.T_DARK_VISION)
			local damageIncrease = t.getDamageIncrease(src, t)
			if damageIncrease > 0 and core.fov.distance(src.x, src.y, target.x, target.y) <= src:getTalentRange(t) then
				dam = dam + (dam * damageIncrease / 100)
				game.logPlayer(src, "You strike in the darkness. (+%d damage)", damageIncrease)
			end
		end

		-- Static reduce damage for psionic kinetic shield
		if target.isTalentActive and target:isTalentActive(target.T_KINETIC_SHIELD) then
			local t = target:getTalentFromId(target.T_KINETIC_SHIELD)
			dam = t.ks_on_damage(target, t, type, dam)
		end
		-- Static reduce damage for psionic spiked kinetic shield
		if target:attr("kinspike_shield") then
			local t = target:getTalentFromId(target.T_KINETIC_SHIELD)
			dam = t.kss_on_damage(target, t, type, dam)
		end
		-- Static reduce damage for psionic thermal shield
		if target.isTalentActive and target:isTalentActive(target.T_THERMAL_SHIELD) then
			local t = target:getTalentFromId(target.T_THERMAL_SHIELD)
			dam = t.ts_on_damage(target, t, type, dam)
		end
		-- Static reduce damage for psionic spiked thermal shield
		if target:attr("thermspike_shield") then
			local t = target:getTalentFromId(target.T_THERMAL_SHIELD)
			dam = t.tss_on_damage(target, t, type, dam)
		end
		-- Static reduce damage for psionic charged shield
		if target.isTalentActive and target:isTalentActive(target.T_CHARGED_SHIELD) then
			local t = target:getTalentFromId(target.T_CHARGED_SHIELD)
			dam = t.cs_on_damage(target, t, type, dam)
		end
		-- Static reduce damage for psionic spiked charged shield
		if target:attr("chargespike_shield") then
			local t = target:getTalentFromId(target.T_CHARGED_SHIELD)
			dam = t.css_on_damage(target, t, type, dam)
		end

		if type ~= DamageType.PHYSICAL and target.knowTalent and target:knowTalent(target.T_STONE_FORTRESS) and target:hasEffect(target.EFF_DWARVEN_RESILIENCE) then
			dam = math.max(0, dam - target:combatArmor() * (50 + target:getTalentLevel(target.T_STONE_FORTRESS) * 10) / 100)
		end

		-- Damage Smearing
		if type ~= DamageType.TEMPORAL and target:hasEffect(target.EFF_DAMAGE_SMEARING) then
			local smear = dam
			target:setEffect(target.EFF_SMEARED, 6, {src=src, power=smear/6})
			dam = 0
		end

		-- Reduce damage with resistance
		if target.resists then
			local pen = 0
			if src.resists_pen then pen = (src.resists_pen.all or 0) + (src.resists_pen[type] or 0) end
			local res = target:combatGetResist(type)
			res = res * (100 - pen) / 100
			print("[PROJECTOR] res", res, (100 - res) / 100, " on dam", dam)
			if res >= 100 then dam = 0
			elseif res <= -100 then dam = dam * 2
			else dam = dam * ((100 - res) / 100)
			end
		end
		print("[PROJECTOR] after resists dam", dam)

		-- Static reduce damage
		if target.isTalentActive and target:isTalentActive(target.T_ANTIMAGIC_SHIELD) then
			local t = target:getTalentFromId(target.T_ANTIMAGIC_SHIELD)
			dam = t.on_damage(target, t, type, dam)
		end

		if target.isTalentActive and target:isTalentActive(target.T_ENERGY_DECOMPOSITION) then
			local t = target:getTalentFromId(target.T_ENERGY_DECOMPOSITION)
			dam = t.on_damage(target, t, type, dam)
		end

		if src:attr("stunned") then
			dam = dam * 0.3
			print("[PROJECTOR] stunned dam", dam)
		end
		if src:attr("numbed") then
			dam = dam - dam * src:attr("numbed") / 100
			print("[PROJECTOR] numbed dam", dam)
		end

		print("[PROJECTOR] final dam", dam)

		local dead
		dead, dam = target:takeHit(dam, src, {damtype=type})

		-- Log damage for later
		if not DamageType:get(type).hideMessage then
			local srcname = src.x and src.y and game.level.map.seens(src.x, src.y) and src.name:capitalize() or "Something"
			game:delayedLogDamage(src, target, dam, ("%s%d %s#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", math.ceil(dam), DamageType:get(type).name))
		end

		if src.attr and src:attr("martyrdom") and not no_martyr then
			DamageType.defaultProjector(target, src.x, src.y, type, dam * src.martyrdom / 100, tmp, true)
		end
		if target.attr and target:attr("reflect_damage") and not no_martyr and src.x and src.y then
			DamageType.defaultProjector(target, src.x, src.y, type, dam * target.reflect_damage / 100, tmp, true)
		end

		if target.knowTalent and target:knowTalent(target.T_RESOLVE) then local t = target:getTalentFromId(target.T_RESOLVE) t.on_absorb(target, t, type, dam) end

		if not target.dead and dam > 0 and type == DamageType.MIND and src and src.knowTalent and src:knowTalent(src.T_MADNESS) then
			local t = src:getTalentFromId(src.T_MADNESS)
			t.doMadness(target, t, src)
		end

		if not target.dead and dam > 0 and target:attr("elemental_harmony") and not target:hasEffect(target.EFF_ELEMENTAL_HARMONY) then
			if type == DamageType.FIRE or type == DamageType.COLD or type == DamageType.LIGHTNING or type == DamageType.ACID or type == DamageType.NATURE then
				target:setEffect(target.EFF_ELEMENTAL_HARMONY, 5 + math.ceil(target:attr("elemental_harmony")), {power=target:attr("elemental_harmony"), type=type})
			end
		end

		if dam > 0 and src.__projecting_for and src.__projecting_for.project_type and (src.__projecting_for.project_type.talent_id or src.__projecting_for.project_type.talent) and src.getTalentFromId and not src.__projecting_for.talent_on_hit_done then
			local t = src:getTalentFromId(src.__projecting_for.project_type.talent or src.__projecting_for.project_type.talent_id)
			if src.talent_on_spell and next(src.talent_on_spell) and t.is_spell then
				for id, d in pairs(src.talent_on_spell) do
					if rng.percent(d.chance) and t.id ~= d.talent then
						src.__projecting_for.talent_on_hit_done = true
						local old = src.__projecting_for
						src:forceUseTalent(d.talent, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=d.level, ignore_ressources=true})
						src.__projecting_for = old
					end
				end
			end
		end

		return dam
	end
	return 0
end)

local function tryDestroy(who, inven, dam, destroy_prop, proof_prop, msg)
	do return end -- Disabled for now
	if not inven then return end

	local reduction = 1

	for i = #inven, 1, -1 do
		local o = inven[i]
		if o[destroy_prop] and not o[proof_prop] then
			for j, test in ipairs(o[destroy_prop]) do
				if dam >= test[1] and rng.percent(test[2] * reduction) then
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
	death_message = {"battered", "bludgeoned", "sliced", "maimed", "raked", "bled", "impaled", "dissected", "disembowelled", "decapitated", "stabbed", "pierced", "torn limb from limb", "crushed", "shattered", "smashed", "cleaved", "swiped", "struck", "mutilated", "tortured"},
}

-- Arcane is basic (usually) unresistable damage
newDamageType{
	name = "arcane", type = "ARCANE", text_color = "#PURPLE#",
	antimagic_resolve = true,
	death_message = {"blasted", "energised", "mana-torn", "dweomered", "imploded"},
}
-- The elemental damages
newDamageType{
	name = "fire", type = "FIRE", text_color = "#LIGHT_RED#",
	antimagic_resolve = true,
	projector = function(src, x, y, type, dam)
		if src.fire_convert_to then
			return DamageType:get(src.fire_convert_to[1]).projector(src, x, y, src.fire_convert_to[1], dam * src.fire_convert_to[2] / 100)
		end
		local realdam = DamageType.defaultProjector(src, x, y, type, dam)
		if realdam > 0 then
			if src.player then world:gainAchievement("PYROMANCER", src, realdam) end
		end
		return realdam
	end,
	death_message = {"burnt", "scorched", "blazed", "roasted", "flamed", "fried", "combusted", "toasted", "slowly cooked", "boiled"},
}
newDamageType{
	name = "cold", type = "COLD", text_color = "#1133F3#",
	antimagic_resolve = true,
	projector = function(src, x, y, type, dam)
		local realdam = DamageType.defaultProjector(src, x, y, type, dam)
		if realdam > 0 then
			if src.player then world:gainAchievement("CRYOMANCER", src, realdam) end
		end
		return realdam
	end,
	death_message = {"frozen", "chilled", "iced", "cooled"},
}
newDamageType{
	name = "lightning", type = "LIGHTNING", text_color = "#ROYAL_BLUE#",
	antimagic_resolve = true,
	projector = function(src, x, y, type, dam)
		local realdam = DamageType.defaultProjector(src, x, y, type, dam)
		return realdam
	end,
	death_message = {"electrocuted", "shocked", "bolted", "volted", "amped"},
}
-- Acid destroys potions
newDamageType{
	name = "acid", type = "ACID", text_color = "#GREEN#",
	antimagic_resolve = true,
	projector = function(src, x, y, type, dam)
		local realdam = DamageType.defaultProjector(src, x, y, type, dam)
		return realdam
	end,
	death_message = {"dissolved", "corroded", "scalded", "melted"},
}

-- Nature & Blight: Opposing damage types
newDamageType{
	name = "nature", type = "NATURE", text_color = "#LIGHT_GREEN#",
	antimagic_resolve = true,
	death_message = {"slimed"},
}
newDamageType{
	name = "blight", type = "BLIGHT", text_color = "#DARK_GREEN#",
	antimagic_resolve = true,
	projector = function(src, x, y, type, dam, extra)
		local realdam = DamageType.defaultProjector(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		-- Spread diseases if possible
		if realdam > 0 and target and target:attr("diseases_spread_on_blight") and (not extra or not extra.from_disease) then
			game.logSeen(src, "The diseases of %s spread!", src.name)
			if rng.percent(20 + math.sqrt(realdam) * 5) then
				local t = src:getTalentFromId(src.T_EPIDEMIC)
				t.do_spread(src, t, target)
			end
		end
		return realdam
	end,
	death_message = {"diseased", "poxed", "infected", "plagued", "debilitated by noxious blight before falling", "fouled"},
}

-- Light damage
newDamageType{
	name = "light", type = "LIGHT", text_color = "#YELLOW#",
	antimagic_resolve = true,
	death_message = {"shadowed", "darkened"},
}

-- Darkness damage
newDamageType{
	name = "darkness", type = "DARKNESS", text_color = "#GREY#",
	antimagic_resolve = true,
	death_message = {"shadowed", "darkened"},
}

-- Mind damage
newDamageType{
	name = "mind", type = "MIND", text_color = "#YELLOW#",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			local mindpower, mentalresist
			if _G.type(dam) == "table" then dam, mindpower, mentalresist, factor = dam.dam, dam.mindpower, dam.mentalresist end
			if target:checkHit(mindpower or (src:combatMindpower() * 0.7), mentalresist or target:combatMentalResist(), 0, 95, 15) then
				return DamageType.defaultProjector(src, x, y, type, dam)
			else
				game.logSeen(target, "%s resists the mind attack!", target.name:capitalize())
				return 0
			end
		end
	end,
	death_message = {"psyched", "mentally tortured", "mindraped"},
}

-- Temporal damage
newDamageType{
	name = "temporal", type = "TEMPORAL", text_color = "#LIGHT_STEEL_BLUE#",
	antimagic_resolve = true,
	death_message = {"timewarped", "temporally distorted"},
}

-- Temporal + Stun
newDamageType{
	name = "temporalstun", type = "TEMPORALSTUN",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam)
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

-- Break stealth
newDamageType{
	name = "break stealth", type = "BREAK_STEALTH",
	projector = function(src, x, y, type, dam)
		-- Dont lit magically unlit grids
		local a = game.level.map(x, y, Map.ACTOR)
		if a and a:isTalentActive(a.T_STEALTH) then
			a:breakStealth()
		end
	end,
}

-- Silence
newDamageType{
	name = "SILENCE", type = "SILENCE",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatMindpower() * 0.7, target:combatMentalResist(), 0, 95, 15) and target:canBe("silence") then
				target:setEffect(target.EFF_SILENCED, math.ceil(dam), {})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Silence
newDamageType{
	name = "% chance to silence target", type = "RANDOM_SILENCE",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(dam) then
			if target:checkHit(src:combatAttackDex() * 0.7, target:combatPhysicalResist(), 0, 95, 15) and target:canBe("silence") then
				target:setEffect(target.EFF_SILENCED, 4, {})
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
	name = "blindness", type = "BLINDPHYSICAL",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatAttack(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("blind") then
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
newDamageType{
	name = "blindness", type = "BLINDCUSTOMMIND",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(dam.power, target:combatMentalResist(), 0, 95, 15) and target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, math.ceil(dam.turns), {})
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
		return init_dam
	end,
}
newDamageType{
	name = "fireburn", type = "GOLEM_FIREBURN",
	projector = function(src, x, y, type, dam)
		local realdam = 0
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target ~= src and target ~= src.summoner then
			realdam = DamageType:get(DamageType.FIREBURN).projector(src, x, y, DamageType.FIREBURN, dam)
		end
		return realdam
	end,
}

-- Darkness + Fire
newDamageType{
	name = "shadowflame", type = "SHADOWFLAME",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam / 2)
		DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam / 2)
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

-- Darkness but not over minions
newDamageType{
	name = "minions darkness", type = "MINION_DARKNESS",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and (not target.necrotic_minion or target.summoner ~= src) then
			DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam)
		end
	end,
}

-- Fore but not over minions
newDamageType{
	name = "firey no friends", type = "FIRE_FRIENDS",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target.summoner ~= src then
			DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam)
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
		local realdam = DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam)
		if rng.percent(25) then
			DamageType:get(DamageType.FREEZE).projector(src, x, y, DamageType.FREEZE, {dur=2, hp=70+dam*1.5})
		end
		return realdam
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

-- Freezes target, checks for spellresistance
newDamageType{
	name = "freeze", type = "FREEZE",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Freeze it, if we pass the test
			local sx, sy = game.level.map:getTileToScreen(x, y)
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe("stun") then
				target:setEffect(target.EFF_FROZEN, dam.dur, {hp=dam.hp * 1.5})

				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "Frozen!", {0,255,155})
			else
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "Resist!", {0,255,155})
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Dim vision
newDamageType{
	name = "sticky smoke", type = "STICKY_SMOKE",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("blind") then
				target:setEffect(target.EFF_DIM_VISION, 7, {sight=dam})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Acid damage + blind chance
newDamageType{
	name = "acid blind", type = "ACID_BLIND",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType:get(DamageType.ACID).projector(src, x, y, DamageType.ACID, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(25) then
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, 3, {src=src})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
		return realdam
	end,
}

-- Darkness damage + blind chance
newDamageType{
	name = "blinding darkness", type = "DARKNESS_BLIND",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType:get(DamageType.ACID).projector(src, x, y, DamageType.DARKNESS, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(25) then
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, 3, {src=src})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
		return realdam
	end,
}

-- Lightning damage + daze chance
newDamageType{
	name = "lightning daze", type = "LIGHTNING_DAZE",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam, daze=25} end
		local realdam = DamageType:get(DamageType.LIGHTNING).projector(src, x, y, DamageType.LIGHTNING, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(dam.daze) then
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, 3, {src=src})
				if src:isTalentActive(src.T_HURRICANE) then
					local t = src:getTalentFromId(src.T_HURRICANE)
					t.do_hurricane(src, t, target)
				end
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
		return realdam
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
	name = "spell knockback", type = "SPELLKNOCKBACK",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		local realdam = 0
		tmp = tmp or {}
		if target and not tmp[target] then
			tmp[target] = true
			realdam = DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam)
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, 3)
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the punch!", target.name:capitalize())
			end
		end
		return realdam
	end,
}

-- Physical damage + repulsion; checks for mind power against physical resistance
newDamageType{
	name = "mind knockback", type = "MINDKNOCKBACK",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		tmp = tmp or {}
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
		tmp = tmp or {}
		if target and not tmp[target] then
			tmp[target] = true
			DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam)
			if target:checkHit(src:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, dam.dist)
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end
	end,
}

-- Poisoning damage
newDamageType{
	name = "poison", type = "POISON",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType:get(DamageType.NATURE).projector(src, x, y, DamageType.NATURE, dam / 6)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("poison") then
			target:setEffect(target.EFF_POISONED, 5, {src=src, power=dam / 6})
		end
		return realdam
	end,
}

-- Inferno: fire and maybe remove suff
newDamageType{
	name = "inferno", type = "INFERNO",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:attr("cleansing_flames") and rng.percent(src:attr("cleansing_flames")) then
			local effs = {}
			local status = (src:reactionToward(target) >= 0) and "detrimental" or "beneficial"
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.status == status and (e.type == "magical" or e.type == "physical" or e.type == "curse" or e.type == "hex") then
					effs[#effs+1] = {"effect", eff_id}
				end
			end
			if #effs > 0 then
				local eff = rng.tableRemove(effs)
				target:removeEffect(eff[2])
			end
		end
		return realdam
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

-- Insidious poison: prevents healing
newDamageType{
	name = "insidious poison", type = "INSIDIOUS_POISON",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.NATURE).projector(src, x, y, DamageType.NATURE, dam.dam / dam.dur)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("poison") then
			target:setEffect(target.EFF_INSIDIOUS_POISON, dam.dur, {src=src, power=dam.dam / dam.dur, heal_factor=dam.heal_factor})
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

-- Physical damage + bleeding % of it
newDamageType{
	name = "physical + bleeding", type = "PHYSICALBLEED",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if realdam > 0 and target and target:canBe("cut") then
			target:setEffect(target.EFF_CUT, 5, {src=src, power=dam * 0.1})
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
				game.nicer_tiles:updateAround(game.level, x, y)
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
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0), 0, 95, 20) then
				target:setEffect(target.EFF_TIME_PRISON, dam, {})
				target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=src:combatSpellpower(0.3)})
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

-- Confusion
newDamageType{
	name = "% chances to confuse", type = "RANDOM_CONFUSION",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(dam.dam) then
			if target:checkHit((dam.power_check or src.combatSpellpower)(src), (dam.resist_check or target.combatMentalResist)(target), 0, 95, 15) and target:canBe("confusion") then
				target:setEffect(target.EFF_CONFUSED, dam.dam, {power=75})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- gBlind
newDamageType{
	name = "% chances to blind", type = "RANDOM_BLIND",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(dam.dam) then
			if target:checkHit((dam.power_check or src.combatSpellpower)(src), (dam.resist_check or target.combatMentalResist)(target), 0, 95, 15) and target:canBe("confusion") then
				target:setEffect(target.EFF_BLINDED, dam.dam, {})
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
				game.logSeen(target, "%s drains experience from %s!", src.name:capitalize(), target.name)
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
		local target = game.level.map(x, y, Map.ACTOR) -- Get the target first to make sure we heal even on kill
		local realdam = DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam.dam)
		if target and realdam > 0 then
			src:heal(realdam * dam.healfactor)
			game.logSeen(target, "%s drains life from %s!", src.name:capitalize(), target.name)
		end
	end,
}

-- Drain Vim
newDamageType{
	name = "drain vim", type = "DRAIN_VIM",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam, vim=0.2} end
		local realdam = DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target ~= src and realdam > 0 then
			src:incVim(realdam * dam.vim * target:getRankVimAdjust())
		end
	end,
}

-- Demonfire: heal demon; damage others
newDamageType{
	name = "demonfire", type = "DEMONFIRE",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target.demon then
			target:heal(dam)
			return -dam
		elseif target then
			DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam)
			return dam
		end
	end,
}

-- Retch: heal undead; damage living
newDamageType{
	name = "retch", type = "RETCH",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and (target.undead or target.retch_heal) then
			target:heal(dam * 1.5)
		elseif target then
			DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam)
		end
	end,
}

-- Holy light, damage demon/undead; heal others
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

newDamageType{
	name = "healing power", type = "HEALING_POWER",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not target.undead then
			target:setEffect(target.EFF_EMPOWERED_HEALING, 1, {power=(dam/100)})
			target:heal(dam, src)
		elseif target then
			DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam)
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
		if target and target:canBe("disease") and rng.percent(dam.disease_chance or 20) then
			local eff = rng.table{{target.EFF_ROTTING_DISEASE, "con"}, {target.EFF_DECREPITUDE_DISEASE, "dex"}, {target.EFF_WEAKNESS_DISEASE, "str"}}
			target:setEffect(eff[1], dam.dur or 5, { src = src, [eff[2]] = dam.disease_power or 5, dam = dam.disease_dam or (dam.dam / 5) })
		end
	end,
}

-- blood boiled, blight damage + slow
newDamageType{
	name = "blood boil", type = "BLOOD_BOIL",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not target.undead and not target.construct then
			target:setEffect(target.EFF_SLOW, 4, {power=0.2})
		end
	end,
}

-- life leech (used cursed gloom skill)
newDamageType{
	name = "life leech",
	type = "LIFE_LEECH",
	text_color = "#F53CBE#",
	hideMessage=true,
	hideFlyer=true
}

-- Physical + Stun Chance
newDamageType{
	name = "physical stun", type = "PHYSICAL_STUN",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(25) then
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2, {src=src})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Physical Damage/Cut Split
newDamageType{
	name = "split bleed", type = "SPLIT_BLEED",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam / 2)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam / 12)
		dam = dam - dam / 12
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("cut") then
			-- Set on fire!
			target:setEffect(target.EFF_CUT, 5, {src=src, power=dam / 11})
		end
	end,
}

-- Temporal/Physical damage
newDamageType{
	name = "matter", type = "MATTER",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam / 2)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam / 2)
	end,
}

-- Gravity damage types
newDamageType{
	name = "gravity", type = "GRAVITY",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		if target and target:attr("never_move") then
			dam = dam * 1.5
		end
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam)
	end,
}

newDamageType{
	name = "gravitypin", type = "GRAVITYPIN",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 20) and target:canBe("pin") then
			target:setEffect(target.EFF_PINNED, 2, {}, true)
		else
			game.logSeen(target, "%s resists!", target.name:capitalize())
		end
	end,
}

newDamageType{
	name = "repulsion", type = "REPULSION",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		tmp = tmp or {}
		-- extra damage on pinned targets
		if target and target:attr("never_move") then
			dam = dam * 1.5
		end
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam)
		-- check knockback
		if target and not target:attr("never_move") and not tmp[target] then
			tmp[target] = true
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, 2)
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end
	end,
}

newDamageType{
	name = "grow", type = "GROW",
	projector = function(src, x, y, typ, dam)
		local feat = game.level.map(x, y, Map.TERRAIN)
		if feat then
			if feat.grow then
				local newfeat_name, newfeat, silence = feat.grow, nil, false
				if type(feat.dig) == "function" then newfeat_name, newfeat, silence = feat.grow(src, x, y, feat) end
				game.level.map(x, y, Map.TERRAIN, newfeat or game.zone.grid_list[newfeat_name])
				if not silence then
					game.logSeen({x=x,y=y}, "%s turns into %s.", feat.name:capitalize(), (newfeat or game.zone.grid_list[newfeat_name]).name)
				end
			end
		end
	end,
}

-- Circles
newDamageType{
	name = "sanctity", type = "SANCTITY",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target == src then
				target:setEffect(target.EFF_SANCTITY, 1, {power=dam})
			elseif target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
				target:setEffect(target.EFF_SILENCED, 2, {}, true)
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

newDamageType{
	name = "shiftingshadows", type = "SHIFTINGSHADOWS",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target == src then
				target:setEffect(target.EFF_SHIFTING_SHADOWS, 1, {power= dam})
			else
				DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam)
			end
		end
	end,
}

newDamageType{
	name = "blazinglight", type = "BLAZINGLIGHT",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target == src then
				target:setEffect(target.EFF_BLAZING_LIGHT, 1, {power= 1 + (dam / 4)})
			else
				DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam)
				DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam)
			end
		end
	end,
}

newDamageType{
	name = "warding", type = "WARDING",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target == src then
				target:setEffect(target.EFF_WARDING, 1, {power=dam})
			elseif target ~= src then
				DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam )
				DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam)
				if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
					target:knockback(src.x, src.y, 1)
					game.logSeen(target, "%s is knocked back!", target.name:capitalize())
				else
					game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
				end
			end
		end
	end,
}

newDamageType{
	name = "batter", type = "BATTER",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatMindpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, 3)
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end
	end,
}

newDamageType{
	name = "mindslow", type = "MINDSLOW",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Freeze it, if we pass the test
			local sx, sy = game.level.map:getTileToScreen(x, y)
			if target:checkHit(src:combatMindpower(), target:combatPhysicalResist(), 0, 95, 20) then
				target:setEffect(target.EFF_SLOW, 4, {power=dam})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Freezes target, checks for physresistance
newDamageType{
	name = "mindfreeze", type = "MINDFREEZE",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Freeze it, if we pass the test
			local sx, sy = game.level.map:getTileToScreen(x, y)
			if target:checkHit(src:combatMindpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("stun") then
				target:setEffect(target.EFF_FROZEN, dam, {hp=70 + src:combatMindpower() * 10})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Temporal + Stat damage
newDamageType{
	name = "clock", type = "CLOCK",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			local dam = 2 + math.ceil(dam / 15)
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
				target:setEffect(target.EFF_TURN_BACK_THE_CLOCK, 3, {power=dam})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
		-- Reduce Con then deal the damage
		DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam)
	end,
}

-- Temporal Over Time
newDamageType{
	name = "wasting", type = "WASTING",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		local dur = 3
		local perc = 30
		if _G.type(dam) == "table" then dam, dur, perc = dam.dam, dam.dur, (dam.initial or perc) end
		local init_dam = dam * perc / 100
		if init_dam > 0 then DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, init_dam) end
		if target then
			-- Set on fire!
			dam = dam - init_dam
			target:setEffect(target.EFF_WASTING, dur, {src=src, power=dam / dur})
		end
		return init_dam
	end,
}

newDamageType{
	name = "stop", type = "STOP",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, dam, {})
			else
				game.logSeen(target, "%s has not been stopped!", target.name:capitalize())
			end
		end
	end,
}

newDamageType{
	name = "rethread", type = "RETHREAD",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		local chance = rng.range(1, 4)
		-- Pull random effect
		if target and chance == 1 then
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, 3, {})
			else
				game.logSeen(target, "%s resists the daze!", target.name:capitalize())
			end
		elseif target and chance == 2 then
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, 3, {})
			else
				game.logSeen(target, "%s resists the blindness!", target.name:capitalize())
			end
		elseif target and chance == 3 then
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, 3, {})
			else
				game.logSeen(target, "%s resists the pin!", target.name:capitalize())
			end
		elseif target and chance == 4 then
			if target:checkHit(src:combatSpellpower(), target:combatMentalResist(), 0, 95, 15) and target:canBe("confusion") then
				target:setEffect(target.EFF_CONFUSED, 3, {power=60})
			else
				game.logSeen(target, "%s resists the confusion!", target.name:capitalize())
			end
		end
	end,
}

newDamageType{
	name = "temporal echo", type = "TEMPORAL_ECHO",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			dam = (target.max_life - target.life) * dam
			DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam)
		end
	end,
}

-- Dredge Haste
newDamageType{
	name = "dredge frenzy", type = "DREDGE_FRENZY",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target.dredge then
			target:setEffect(target.EFF_SPEED, 3, {power=0.6})
		end
	end,
}

newDamageType{
	name = "devour life", type = "DEVOUR_LIFE",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		local target = game.level.map(x, y, Map.ACTOR) -- Get the target first to make sure we heal even on kill
		local realdam = DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam)
		if target and realdam > 0 then
			local heal = realdam * (dam.healfactor or 1)
			-- cannot be reduced
			local temp = src.healing_factor
			src.healing_factor = 1
			src:heal(heal)
			src.healing_factor = temp
			game.logSeen(target, "%s consumes %d life from %s!", src.name:capitalize(), heal, target.name)
		end
	end,
	hideMessage=true,
}

newDamageType{
	name = "chronoslow", type = "CHRONOSLOW",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam * 100)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
				target:setEffect(target.EFF_SLOW, 2, {power=dam}, true)
			else
				game.logSeen(target, "%s resists the slow", target.name:capitalize())
			end
		end
	end,
}

newDamageType{
	name = "molten rock", type = "MOLTENROCK",
	projector = function(src, x, y, type, dam)
		return DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam / 2) +
		       DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam / 2)
	end,
}

newDamageType{
	name = "entangle", type = "ENTANGLE",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam/3)
		DamageType:get(DamageType.NATURE).projector(src, x, y, DamageType.NATURE, 2*dam/3)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, 5, {})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

newDamageType{
	name = "manaworm", type = "MANAWORM",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType:get(DamageType.ARCANE).projector(src, x, y, DamageType.ARCANE, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if game.zone.void_blast_hits and game.party:hasMember(target) then game.zone.void_blast_hits = game.zone.void_blast_hits + 1 end

			if target:knowTalent(target.T_MANA_POOL) then
				target:setEffect(target.EFF_MANAWORM, 5, {power=dam * 5, src=src})
				src:disappear(src)
			else
				game.logSeen(target, "%s is unaffected.", target.name:capitalize())
			end
		end
		return realdam
	end,
}

newDamageType{
	name = "void blast", type = "VOID_BLAST",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType:get(DamageType.ARCANE).projector(src, x, y, DamageType.ARCANE, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if game.zone.void_blast_hits and target and game.party:hasMember(target) then
			game.zone.void_blast_hits = game.zone.void_blast_hits + 1
		end
		return realdam
	end,
}

newDamageType{
	name = "circle of death", type = "CIRCLE_DEATH",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and (src:reactionToward(target) < 0 or dam.ff) then
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "bane" then return end
			end

			local what = rng.percent(50) and "blind" or "confusion"
			if target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) and target:canBe(what) then
				target:setEffect(what == "blind" and target.EFF_BANE_BLINDED or target.EFF_BANE_CONFUSED, math.ceil(dam.dur), {src=src, power=50, dam=dam.dam})
			else
				game.logSeen(target, "%s resists the bane!", target.name:capitalize())
			end
		end
	end,
}
