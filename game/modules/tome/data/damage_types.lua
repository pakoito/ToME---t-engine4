-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

		local hd = {"DamageProjector:base", src=src, x=x, y=y, type=type, dam=dam}
		if src:triggerHook(hd) then dam = hd.dam end

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

		-- Item-granted damage ward talent
		if target:hasEffect(target.EFF_WARD) then
			local e = target.tempeffect_def[target.EFF_WARD]
			dam = e.absorb(type, dam, target.tmp[target.EFF_WARD], target, src)
		end

		-- Block talent from shields
		if target:attr("block") then
			local e = target.tempeffect_def[target.EFF_BLOCKING]
			dam = e.do_block(type, dam, target.tmp[target.EFF_BLOCKING], target, src)
		end
		if target.isTalentActive and target:isTalentActive(target.T_FORGE_SHIELD) then
			local t = target:getTalentFromId(target.T_FORGE_SHIELD)
			dam = t.doForgeShield(type, dam, t, target, src)
		end

		-- Increases damage
		local mind_linked = false
		if src.inc_damage then
			local inc = (src.inc_damage.all or 0) + (src.inc_damage[type] or 0)

			-- Increases damage for the entity type (Demon, Undead, etc)
			if target.type and src.inc_damage_actor_type then
				local incEntity = src.inc_damage_actor_type[target.type]
				if incEntity and incEntity ~= 0 then
					print("[PROJECTOR] before inc_damage_actor_type", dam + (dam * inc / 100))
					inc = inc + src.inc_damage_actor_type[target.type]
					print("[PROJECTOR] after inc_damage_actor_type", dam + (dam * inc / 100))
				end
			end

			-- Increases damage to sleeping targets
			if target:attr("sleep") and src.attr and src:attr("night_terror") then
				inc = inc + src:attr("night_terror")
				print("[PROJECTOR] after night_terror", dam + (dam * inc / 100))
			end
			-- Increases damage to targets with Insomnia
			if src.attr and src:attr("lucid_dreamer") and target:hasEffect(target.EFF_INSOMNIA) then
				inc = inc + src:attr("lucid_dreamer")
				print("[PROJECTOR] after lucid_dreamer", dam + (dam * inc / 100))
			end
			-- Mind Link
			if type == DamageType.MIND and target:hasEffect(target.EFF_MIND_LINK_TARGET) then
				local eff = target:hasEffect(target.EFF_MIND_LINK_TARGET)
				if eff.src == src or eff.src == src.summoner then
					mind_linked = true
					inc = inc + eff.power
					print("[PROJECTOR] after mind_link", dam + (dam * inc / 100))
				end
			end

			dam = dam + (dam * inc / 100)
		end

		-- Rigor mortis
		if src.necrotic_minion and target:attr("inc_necrotic_minions") then
			dam = dam + dam * target:attr("inc_necrotic_minions") / 100
			print("[PROJECTOR] after necrotic increase dam", dam)
		end

		-- Blast the iceblock
		if src.attr and src:attr("encased_in_ice") then
			local eff = src:hasEffect(src.EFF_FROZEN)
			eff.hp = eff.hp - dam
			local srcname = src.x and src.y and game.level.map.seens(src.x, src.y) and src.name:capitalize() or "Something"
			if eff.hp < 0 and not eff.begone then
				game.logSeen(src, "%s forces the iceblock to shatter.", src.name:capitalize())
				game:onTickEnd(function() src:removeEffect(src.EFF_FROZEN) end)
				eff.begone = game.turn
			else
				game:delayedLogDamage(src, {name="Iceblock", x=src.x, y=src.y}, dam, ("%s%d %s#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", math.ceil(dam), DamageType:get(type).name))
				if eff.begone and eff.begone < game.turn and eff.hp < 0 then
					game.logSeen(src, "%s forces the iceblock to shatter.", src.name:capitalize())
					src:removeEffect(src.EFF_FROZEN)
				end
			end
			return 0
		end

		-- dark vision increases damage done in creeping dark
		if src and game.level.map:checkAllEntities(x, y, "creepingDark") then
			local dark = game.level.map:checkAllEntities(x, y, "creepingDark")
			if dark.summoner == src and dark.damageIncrease > 0 and not dark.projecting then
				game.logPlayer(src, "You strike in the darkness. (+%d damage)", (dam * dark.damageIncrease / 100))
				dam = dam + (dam * dark.damageIncrease / 100)
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
			target:setEffect(target.EFF_SMEARED, 6, {src=src, power=smear/6, no_ct_effect=true})
			dam = 0
		end

		-- affinity healing, we store it to apply it after damage is resolved
		local affinity_heal = 0
		if target.damage_affinity then
			affinity_heal = math.max(0, dam * ((target.damage_affinity.all or 0) + (target.damage_affinity[type] or 0)) / 100)
		end

		-- reduce by resistance to entity type (Demon, Undead, etc)
		if target.resists_actor_type and src and src.type then
			local res = math.min(target.resists_actor_type[src.type] or 0, target.resists_cap_actor_type or 100)
			if res ~= 0 then
				print("[PROJECTOR] before entity", src.type, "resists dam", dam)
				if res >= 100 then dam = 0
				elseif res <= -100 then dam = dam * 2
				else dam = dam * ((100 - res) / 100)
				end
				print("[PROJECTOR] after entity", src.type, "resists dam", dam)
			end
		end

		-- Reduce damage with resistance
		if target.resists then
			local pen = 0
			if src.resists_pen then pen = (src.resists_pen.all or 0) + (src.resists_pen[type] or 0) end
			local dominated = target:hasEffect(target.EFF_DOMINATED)
			if dominated and dominated.source == src then pen = pen + (dominated.resistPenetration or 0) end
			if target:attr("sleep") and src.attr and src:attr("night_terror") then pen = pen + src:attr("night_terror") end
			local res = target:combatGetResist(type)
			pen = util.bound(pen, 0, 100)
			if res > 0 then	res = res * (100 - pen) / 100 end
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

		-- Flat damage reduction ("armour")
		if target.flat_damage_armor then
			local dec = (target.flat_damage_armor.all or 0) + (target.flat_damage_armor[type] or 0)
			dam = math.max(0, dam - dec)
			print("[PROJECTOR] after flat damage armor", dam)
		end

		-- Flat damage cap
		if target.flat_damage_cap and target.max_life then
			local cap = nil
			if target.flat_damage_cap.all then cap = target.flat_damage_cap.all end
			if target.flat_damage_cap[type] then cap = target.flat_damage_cap[type] end
			if cap and cap > 0 then
				dam = math.max(math.min(dam, cap * target.max_life / 100), 0)
				print("[PROJECTOR] after flat damage cap", dam)
			end
		end

		if src:attr("stunned") then
			dam = dam * 0.3
			print("[PROJECTOR] stunned dam", dam)
		end
		if src:attr("invisible_damage_penalty") then
			dam = dam * util.bound(1 - src.invisible_damage_penalty, 0, 1)
			print("[PROJECTOR] invisible dam", dam)
		end
		if src:attr("numbed") then
			dam = dam - dam * src:attr("numbed") / 100
			print("[PROJECTOR] numbed dam", dam)
		end

		-- Curse of Misfortune: Unfortunate End (chance to increase damage enough to kill)
		if src and src.hasEffect and src:hasEffect(src.EFF_CURSE_OF_MISFORTUNE) then
			local eff = src:hasEffect(src.EFF_CURSE_OF_MISFORTUNE)
			local def = src.tempeffect_def[src.EFF_CURSE_OF_MISFORTUNE]
			dam = def.doUnfortunateEnd(src, eff, target, dam)
		end
		-- Sanctuary: reduces damage if it comes from outside of Gloom
		if target.isTalentActive and target:isTalentActive(target.T_GLOOM) and target:knowTalent(target.T_SANCTUARY) then
			if tmp and tmp.sanctuaryDamageChange then
				-- projectile was targeted outside of gloom
				dam = dam * (100 + tmp.sanctuaryDamageChange) / 100
				print("[PROJECTOR] Sanctuary (projectile) dam", dam)
			elseif src and src.x and src.y then
				-- assume instantaneous projection and check range to source
				local t = target:getTalentFromId(target.T_GLOOM)
				if core.fov.distance(target.x, target.y, src.x, src.y) > target:getTalentRange(t) then
					t = target:getTalentFromId(target.T_SANCTUARY)
					dam = dam * (100 + t.getDamageChange(target, t)) / 100
					print("[PROJECTOR] Sanctuary (source) dam", dam)
				end
			end
		end

		-- Psychic Projection
		if src.attr and src:attr("is_psychic_projection") and not game.zone.is_dream_scape then
			if (target.subtype and target.subtype == "ghost") or mind_linked then
				dam = dam
			else
				dam = 0
			end
		end

		print("[PROJECTOR] final dam", dam)

		local hd = {"DamageProjector:final", src=src, x=x, y=y, type=type, dam=dam}
		if src:triggerHook(hd) then dam = hd.dam end

		local source_talent = src.__projecting_for and src.__projecting_for.project_type and (src.__projecting_for.project_type.talent_id or src.__projecting_for.project_type.talent) and src.getTalentFromId and src:getTalentFromId(src.__projecting_for.project_type.talent or src.__projecting_for.project_type.talent_id)
		local dead
		dead, dam = target:takeHit(dam, src, {damtype=type, source_talent=source_talent})

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

		if target ~= src and target.attr and target:attr("damage_resonance") and not target:hasEffect(target.EFF_RESONANCE) then
			target:setEffect(target.EFF_RESONANCE, 5, {damtype=type, dam=target:attr("damage_resonance_on_hit")})
		end

		if not target.dead and dam > 0 and type == DamageType.MIND and src and src.knowTalent and src:knowTalent(src.T_MADNESS) then
			local t = src:getTalentFromId(src.T_MADNESS)
			t.doMadness(target, t, src)
		end

		-- Curse of Nightmares: Nightmare
		if not target.dead and dam > 0 and src and target.hasEffect and target:hasEffect(src.EFF_CURSE_OF_NIGHTMARES) then
			local eff = target:hasEffect(target.EFF_CURSE_OF_NIGHTMARES)
			eff.isHit = true -- handle at the end of the turn
		end

		if not target.dead and dam > 0 and target:attr("elemental_harmony") and not target:hasEffect(target.EFF_ELEMENTAL_HARMONY) then
			if type == DamageType.FIRE or type == DamageType.COLD or type == DamageType.LIGHTNING or type == DamageType.ACID or type == DamageType.NATURE then
				target:setEffect(target.EFF_ELEMENTAL_HARMONY, 5 + math.ceil(target:attr("elemental_harmony")), {power=target:attr("elemental_harmony"), type=type, no_ct_effect=true})
			end
		end

		-- damage affinity healing
		if not target.dead and affinity_heal > 0 then
			target:heal(affinity_heal)
			game.logSeen(target, "%s is healed by the %s%s#LAST# damage!", target.name:capitalize(), DamageType:get(type).text_color or "#aaaaaa#", DamageType:get(type).name)
		end

		if dam > 0 and source_talent then
			local t = source_talent

			if src:attr("spellshock_on_damage") and target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and not target:hasEffect(target.EFF_SPELLSHOCKED) then
				target:crossTierEffect(target.EFF_SPELLSHOCKED, src:combatSpellpower())
			end

			if src.__projecting_for then
				if src.talent_on_spell and next(src.talent_on_spell) and t.is_spell and not src.turn_procs.spell_talent then
					for id, d in pairs(src.talent_on_spell) do
						if rng.percent(d.chance) and t.id ~= d.talent then
							src.turn_procs.spell_talent = true
							local old = src.__projecting_for
							src:forceUseTalent(d.talent, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=d.level, ignore_ressources=true})
							src.__projecting_for = old
						end
					end
				end

				if src.talent_on_wild_gift and next(src.talent_on_wild_gift) and t.is_nature and not src.turn_procs.wild_gift_talent then
					for id, d in pairs(src.talent_on_wild_gift) do
						if rng.percent(d.chance) and t.id ~= d.talent then
							src.turn_procs.wild_gift_talent = true
							local old = src.__projecting_for
							src:forceUseTalent(d.talent, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=d.level, ignore_ressources=true})
							src.__projecting_for = old
						end
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
	death_message = {"battered", "bludgeoned", "sliced", "maimed", "raked", "bled", "impaled", "dissected", "disembowelled", "decapitated", "stabbed", "pierced", "torn limb from limb", "crushed", "shattered", "smashed", "cleaved", "swiped", "struck", "mutilated", "tortured", "skewered", "squished", "mauled", "chopped into tiny pieces", "splattered", "ground", "minced", "punctured", "hacked apart", "eviscerated"},
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
	death_message = {"frozen", "chilled", "iced", "cooled", "frozen and shattered into a million little shards"},
}
newDamageType{
	name = "lightning", type = "LIGHTNING", text_color = "#ROYAL_BLUE#",
	antimagic_resolve = true,
	projector = function(src, x, y, type, dam)
		local realdam = DamageType.defaultProjector(src, x, y, type, dam)
		return realdam
	end,
	death_message = {"electrocuted", "shocked", "bolted", "volted", "amped", "zapped"},
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
	death_message = {"slimed", "splurged", "treehugged", "naturalised"},
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
	death_message = {"diseased", "poxed", "infected", "plagued", "debilitated by noxious blight before falling", "fouled", "tainted"},
}

-- Light damage
newDamageType{
	name = "light", type = "LIGHT", text_color = "#YELLOW#",
	antimagic_resolve = true,
	death_message = {"radiated", "seared", "purified", "sun baked", "jerkied", "tanned"},
}

-- Darkness damage
newDamageType{
	name = "darkness", type = "DARKNESS", text_color = "#GREY#",
	antimagic_resolve = true,
	death_message = {"shadowed", "darkened", "swallowed by the void"},
}

-- Mind damage
newDamageType{
	name = "mind", type = "MIND", text_color = "#YELLOW#",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			local mindpower, mentalresist, alwaysHit, crossTierChance
			if _G.type(dam) == "table" then dam, mindpower, mentalresist, alwaysHit, crossTierChance = dam.dam, dam.mindpower, dam.mentalresist, dam.alwaysHit, dam.crossTierChance end
			local hit_power = mindpower or src:combatMindpower()
			if alwaysHit or target:checkHit(hit_power, mentalresist or target:combatMentalResist(), 0, 95, 15) then
				if crossTierChance and rng.percent(crossTierChance) then
					target:crossTierEffect(target.EFF_BRAINLOCKED, src:combatMindpower())
				end
				return DamageType.defaultProjector(src, x, y, type, dam)
			else
				game.logSeen(target, "%s resists the mind attack!", target.name:capitalize())
				return DamageType.defaultProjector(src, x, y, type, dam / 2)
			end
		end
		return 0
	end,
	death_message = {"psyched", "mentally tortured", "mindraped"},
}

-- Temporal damage
newDamageType{
	name = "temporal", type = "TEMPORAL", text_color = "#LIGHT_STEEL_BLUE#",
	antimagic_resolve = true,
	death_message = {"timewarped", "temporally distorted", "spaghettified across the whole of space and time", "paradoxed", "replaced by a time clone (and no one ever knew the difference)", "grandfathered", "time dilated"},
}

-- Temporal + Stun
newDamageType{
	name = "temporalstun", type = "TEMPORALSTUN",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 4, {apply_power=src:combatSpellpower()})
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
		if a then
			a:setEffect(a.EFF_LUMINESCENCE, math.ceil(dam.turns), {power=dam.power, no_ct_effect=true})
		end
	end,
}

-- Silence
newDamageType{
	name = "SILENCE", type = "SILENCE",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("silence") then
				target:setEffect(target.EFF_SILENCED, math.ceil(dam.dur), {apply_power=dam.power_check or src:combatMindpower() * 0.7})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Silence
newDamageType{
	name = "arcane silence", type = "ARCANE_SILENCE",
	projector = function(src, x, y, type, dam)
		local chance = 100
		if _G.type(dam) == "table" then dam, chance = dam.dam, dam.chance end

		local target = game.level.map(x, y, Map.ACTOR)
		local realdam = DamageType:get(DamageType.ARCANE).projector(src, x, y, DamageType.ARCANE, dam)
		if target then
			if rng.percent(chance) and target:canBe("silence") then
				target:setEffect(target.EFF_SILENCED, 3, {apply_power=src:combatSpellpower()})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
		return realdam
	end,
}

-- Silence
newDamageType{
	name = "% chance to silence target", type = "RANDOM_SILENCE",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(dam) then
			if target:canBe("silence") then
				target:setEffect(target.EFF_SILENCED, 4, {apply_power=src:combatAttack()*0.7, no_ct_effect=true})
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
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, math.ceil(dam), {apply_power=src:combatSpellpower()})
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
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, math.ceil(dam), {apply_power=src:combatAttack()})
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
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, math.ceil(dam), {apply_power=src:combatPhysicalpower(), apply_save="combatPhysicalResist"})
			else
				game.logSeen(target, "%s avoids the blinding ink!", target.name:capitalize())
			end
		end
	end,
}
newDamageType{
	name = "blindness", type = "BLINDCUSTOMMIND",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, math.ceil(dam.turns), {apply_power=dam.power, apply_save="combatMentalResist", no_ct_effect=true})
			else
				game.logSeen(target, "%s resists the blinding light!", target.name:capitalize())
			end
		end
	end,
}

-- Lite + Light damage
newDamageType{
	name = "bright light", type = "LITE_LIGHT",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.LITE).projector(src, x, y, DamageType.LITE, 1)
		return DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam)
	end,
}

-- Fire damage + DOT
newDamageType{
	name = "fire burn", type = "FIREBURN", text_color = "#LIGHT_RED#",
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
			target:setEffect(target.EFF_BURNING, dur, {src=src, power=dam / dur, no_ct_effect=true})
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
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 4, {apply_power=src:combatSpellpower()})
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
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 4, {apply_power=src:combatSpellpower()})
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
			if target:canBe("stun") then
				target:setEffect(target.EFF_BURNING_SHOCK, dam.dur, {src=src, power=dam.dam / dam.dur, apply_power=src:combatSpellpower()})
			else
				game.logSeen(target, "%s resists the searing flame!", target.name:capitalize())
			end
		end
	end,
}

-- Cold damage + freeze chance
newDamageType{
	name = "ice", type = "ICE", text_color = "#1133F3#",
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
		if _G.type(dam) == "number" then dam = {dam=dam, dur=4} end
		DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("pin") and target:canBe("stun") and not target:attr("fly") and not target:attr("levitation") then
				target:setEffect(target.EFF_FROZEN_FEET, dam.dur, {apply_power=src:combatSpellpower()})
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
			if target:canBe("stun") then
				target:setEffect(target.EFF_FROZEN, dam.dur, {hp=dam.hp * 1.5, apply_power=src:combatSpellpower(), min_dur=1})
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
			if target:canBe("blind") then
				target:setEffect(target.EFF_DIM_VISION, 7, {sight=dam, apply_power=src:combatAttack()})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

-- Acid damage + blind chance
newDamageType{
	name = "acid blind", type = "ACID_BLIND", text_color = "#GREEN#",
	projector = function(src, x, y, type, dam)
		local realdam = DamageType:get(DamageType.ACID).projector(src, x, y, DamageType.ACID, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(25) then
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, 3, {src=src, apply_power=src:combatSpellpower()})
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
		local realdam = DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(25) then
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, 3, {src=src, apply_power=src:combatSpellpower()})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
		return realdam
	end,
}

-- Lightning damage + daze chance
newDamageType{
	name = "lightning daze", type = "LIGHTNING_DAZE", text_color = "#ROYAL_BLUE#",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam, daze=25} end
		local realdam = DamageType:get(DamageType.LIGHTNING).projector(src, x, y, DamageType.LIGHTNING, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(dam.daze) then
			if target:canBe("stun") then
				game:onTickEnd(function() target:setEffect(target.EFF_DAZED, 3, {src=src, apply_power=src:combatSpellpower()}) end) -- Do it at the end so we don't break our own daze
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
		local srcx, srcy = dam.x, dam.y
		dam = dam.dam
		DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam / 2)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam / 2)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(srcx, srcy, 1)
				target:crossTierEffect(target.EFF_OFFBALANCE, src:combatSpellpower())
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
				target:crossTierEffect(target.EFF_OFFBALANCE, src:combatSpellpower())
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the punch!", target.name:capitalize())
			end
		end
	end,
}

-- Fireburn damage + repulsion; checks for mind power against physical resistance
newDamageType{
	name = "fire knockback mind", type = "FIREKNOCKBACK_MIND",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		if _G.type(dam) ~= "table" then dam = {dam=dam, dist=3} end
		tmp = tmp or {}
		if target and not tmp[target] then
			tmp[target] = true
			DamageType:get(DamageType.FIREBURN).projector(src, x, y, DamageType.FIREBURN, dam.dam)
			if target:checkHit(src:combatMindpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, dam.dist)
				target:crossTierEffect(target.EFF_OFFBALANCE, src:combatMindpower())
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the punch!", target.name:capitalize())
			end
		end
	end,
}

-- Darkness damage + repulsion; checks for spell power against mental resistance
newDamageType{
	name = "darkness knockback", type = "DARKKNOCKBACK",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		if _G.type(dam) ~= "table" then dam = {dam=dam, dist=3} end
		tmp = tmp or {}
		if target and not tmp[target] then
			tmp[target] = true
			DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam)
			if target:checkHit(src:combatSpellpower(), target:combatMentalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, dam.dist)
				target:crossTierEffect(target.EFF_BRAINLOCKED, src:combatSpellpower())
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the darkness!", target.name:capitalize())
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
		if _G.type(dam) ~= "table" then dam = {dam=dam, dist=3} end
		tmp = tmp or {}
		if target and not tmp[target] then
			tmp[target] = true
			realdam = DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam)
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, dam.dist)
				target:crossTierEffect(target.EFF_OFFBALANCE, src:combatSpellpower())
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
				target:crossTierEffect(target.EFF_OFFBALANCE, src:combatMindpower())
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
		if _G.type(dam) ~= "table" then dam = {dam=dam, dist=3} end
		if target and not tmp[target] then
			tmp[target] = true
			DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam)
			if target:checkHit(src:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(dam.x or src.x, dam.y or src.y, dam.dist)
				target:crossTierEffect(target.EFF_OFFBALANCE, src:combatPhysicalpower())
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end
	end,
}

-- Fear check + repulsion; checks for mind power against physical resistance
newDamageType{
	name = "fear knockback", type = "FEARKNOCKBACK",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		tmp = tmp or {}
		if target and not tmp[target] then
			tmp[target] = true
			if target:checkHit(src:combatMindpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("fear") then
				target:knockback(dam.x, dam.y, dam.dist)
				target:crossTierEffect(target.EFF_BRAINLOCKED, src:combatMindpower())
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the frightening sight!", target.name:capitalize())
			end
		end
	end,
}

-- Poisoning damage
newDamageType{
	name = "poison", type = "POISON", text_color = "#LIGHT_GREEN#",
	projector = function(src, x, y, t, dam)
		local power
		if type(dam) == "table" then
			power = dam.apply_power
			dam = dam.dam
		end
		local realdam = DamageType:get(DamageType.NATURE).projector(src, x, y, DamageType.NATURE, dam / 6)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("poison") then
			target:setEffect(target.EFF_POISONED, 5, {src=src, power=dam / 6, apply_power=power or (src.combatAttack and src:combatAttack()) or 0})
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
				if e.status == status and (e.type == "magical" or e.type == "physical") then
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
			target:setEffect(target.EFF_SPYDRIC_POISON, dam.dur, {src=src, power=dam.dam / dam.dur, no_ct_effect=true})
		end
	end,
}

-- Insidious poison: prevents healing
newDamageType{
	name = "insidious poison", type = "INSIDIOUS_POISON", text_color = "#LIGHT_GREEN#",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam, dur=7, heal_factor=dam} end
		DamageType:get(DamageType.NATURE).projector(src, x, y, DamageType.NATURE, dam.dam / dam.dur)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("poison") then
			target:setEffect(target.EFF_INSIDIOUS_POISON, dam.dur, {src=src, power=dam.dam / dam.dur, heal_factor=dam.heal_factor, no_ct_effect=true})
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
			target:setEffect(target.EFF_CUT, 5, {src=src, power=dam / 5, no_ct_effect=true})
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
			target:setEffect(target.EFF_CUT, 5, {src=src, power=dam * 0.1, no_ct_effect=true})
		end
	end,
}

-- Slime damage
newDamageType{
	name = "slime", type = "SLIME", text_color = "#LIGHT_GREEN#",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam, power=0.15} end
		DamageType:get(DamageType.NATURE).projector(src, x, y, DamageType.NATURE, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(target.EFF_SLOW, 3, {power=dam.power, no_ct_effect=true})
		end
	end,
}


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
			target:setEffect(target.EFF_SLOW, 7, {power=dam, apply_power=src:combatSpellpower()})
		end
	end,
}

newDamageType{
	name = "congeal time", type = "CONGEAL_TIME",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Freeze it, if we pass the test
			local sx, sy = game.level.map:getTileToScreen(x, y)
			target:setEffect(target.EFF_CONGEAL_TIME, 7, {slow=dam.slow, proj=dam.proj, apply_power=src:combatSpellpower()})
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
			if src == target then
				target:setEffect(target.EFF_TIME_PRISON, dam, {no_ct_effect=true})
				target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=src:combatSpellpower(0.3), no_ct_effect=true})
			elseif target:checkHit(src:combatSpellpower() - (target:attr("continuum_destabilization") or 0), target:combatSpellResist(), 0, 95, 15) then
				target:setEffect(target.EFF_TIME_PRISON, dam, {apply_power=src:combatSpellpower() - (target:attr("continuum_destabilization") or 0), apply_save="combatSpellResist", no_ct_effect=true})
				target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=src:combatSpellpower(0.3), no_ct_effect=true})
			else
				game.logSeen(target, "%s resists the time prison.", target.name:capitalize())
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
			if target:canBe("confusion") then
				target:setEffect(target.EFF_CONFUSED, dam.dur, {power=dam.dam, apply_power=(dam.power_check or src.combatSpellpower)(src)})
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
			if target:canBe("confusion") then
				target:setEffect(target.EFF_CONFUSED, 4, {power=75, apply_power=(dam.power_check or src.combatSpellpower)(src), no_ct_effect=true})
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
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, dam.dam, {apply_power=(dam.power_check or src.combatSpellpower)(src), no_ct_effect=true})
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
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, dam.dur, {apply_power=src:combatPhysicalpower(), apply_save="combatPhysicalResist"})
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
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, dam.dur, {apply_power=src:combatPhysicalpower()})
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
	name = "drain life", type = "DRAINLIFE", text_color = "#DARK_GREEN#",
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
		local target = game.level.map(x, y, Map.ACTOR)
		local realdam = DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam.dam)
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
		if target and target:attr("demon") then
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
		if target and (target:attr("undead") or target.retch_heal) then
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
		if target and not target:attr("undead") and not target:attr("demon") then
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
			target:attr("allow_on_heal", 1)
			target:heal(dam, src)
			target:attr("allow_on_heal", -1)
		end
	end,
}

newDamageType{
	name = "healing power", type = "HEALING_POWER",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not target:attr("undead") then
			target:setEffect(target.EFF_EMPOWERED_HEALING, 1, {power=(dam/100)})
			target:attr("allow_on_heal", 1)
			target:heal(dam, src)
			target:attr("allow_on_heal", -1)
		elseif target then
			DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam)
		end
	end,
}

-- Corrupted blood, blight damage + potential diseases
newDamageType{
	name = "corrupted blood", type = "CORRUPTED_BLOOD", text_color = "#DARK_GREEN#",
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
		if target and not target:attr("undead") and not target:attr("construct") then
			target:setEffect(target.EFF_SLOW, 4, {power=0.2, no_ct_effect=true})
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
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2, {src=src, apply_power=src:combatSpellpower(), min_dur=1})
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
			target:setEffect(target.EFF_CUT, 5, {src=src, power=dam / 11, no_ct_effect=true})
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
	name = "gravity pin", type = "GRAVITYPIN",
	projector = function(src, x, y, type, dam)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		local reapplied = false
		if target then
			-- silence the apply message if the target already has the effect
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.desc == "Pinned to the ground" then
					reapplied = true
				end
			end
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, 2, {apply_power=src:combatSpellpower(), min_dur=1}, reapplied)
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
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
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam) -- This damage type can deal damage multiple times, use with accordingly
		-- check knockback
		if target and not target:attr("never_move") and not tmp[target] then
			tmp[target] = true
			if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(src.x, src.y, 2)
				target:crossTierEffect(target.EFF_OFFBALANCE, src:combatSpellpower())
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
				target:setEffect(target.EFF_SANCTITY, 1, {power=dam, no_ct_effect=true})
			elseif target:canBe("silence") then
				target:setEffect(target.EFF_SILENCED, 2, {apply_power=src:combatSpellpower(), min_dur=1}, true)
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
				target:setEffect(target.EFF_SHIFTING_SHADOWS, 1, {power= dam, no_ct_effect=true})
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
				target:setEffect(target.EFF_BLAZING_LIGHT, 1, {power= 1 + (dam / 4), no_ct_effect=true})
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
				target:setEffect(target.EFF_WARDING, 1, {power=dam, no_ct_effect=true})
			elseif target ~= src then
				DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam )
				DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam)
				if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
					target:knockback(src.x, src.y, 1)
					target:crossTierEffect(target.EFF_OFFBALANCE, src:combatSpellpower())
					game.logSeen(target, "%s is knocked back!", target.name:capitalize())
				else
					game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
				end
			end
		end
	end,
}

newDamageType{
	name = "mindslow", type = "MINDSLOW",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			local sx, sy = game.level.map:getTileToScreen(x, y)
			target:setEffect(target.EFF_SLOW, 4, {power=dam, apply_power=src:combatMindpower()})
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
			if target:canBe("stun") then
				target:setEffect(target.EFF_FROZEN, dam, {hp=70 + src:combatMindpower() * 10, apply_power=src:combatMindpower()})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

newDamageType{
	name = "implosion", type = "IMPLOSION",
	projector = function(src, x, y, type, dam)
		local dur = 3
		local perc = 50
		if _G.type(dam) == "table" then dam, dur, perc = dam.dam, dam.dur, (dam.initial or perc) end
		local init_dam = dam
		if init_dam > 0 then DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, init_dam) end
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(target.EFF_IMPLODING, dur, {src=src, power=dam})
		end
	end,
}

-- Temporal + Stat damage
newDamageType{
	name = "reverse aging", type = "CLOCK",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			local dam = 2 + math.ceil(dam / 15)
			target:setEffect(target.EFF_TURN_BACK_THE_CLOCK, 3, {power=dam, apply_power=src:combatSpellpower(), min_dur=1})
		end
		-- Reduce Con then deal the damage
		DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam)
	end,
}

-- Temporal Over Time
newDamageType{
	name = "wasting", type = "WASTING", text_color = "#LIGHT_STEEL_BLUE#",
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
			target:setEffect(target.EFF_WASTING, dur, {src=src, power=dam / dur, no_ct_effect=true})
		end
		return init_dam
	end,
}

newDamageType{
	name = "stop", type = "STOP",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, dam, {apply_power=src:combatSpellpower()})
			else
				game.logSeen(target, "%s has not been stopped!", target.name:capitalize())
			end
		end
	end,
}

newDamageType{
	name = "rethread", type = "RETHREAD",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		local chance = rng.range(1, 4)
		-- Pull random effect
		if target then
			if src then src:incParadox(-dam.reduction) end
			if chance == 1 then
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, 3, {apply_power=src:combatSpellpower()})
				else
					game.logSeen(target, "%s resists the stun!", target.name:capitalize())
				end
			elseif chance == 2 then
				if target:canBe("blind") then
					target:setEffect(target.EFF_BLINDED, 3, {apply_power=src:combatSpellpower()})
				else
					game.logSeen(target, "%s resists the blindness!", target.name:capitalize())
				end
			elseif chance == 3 then
				if target:checkHit(src:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("pin") then
					target:setEffect(target.EFF_PINNED, 3, {apply_power=src:combatSpellpower()})
				else
					game.logSeen(target, "%s resists the pin!", target.name:capitalize())
				end
			elseif chance == 4 then
				if target:canBe("confusion") then
					target:setEffect(target.EFF_CONFUSED, 3, {power=60, apply_power=src:combatSpellpower()})
				else
					game.logSeen(target, "%s resists the confusion!", target.name:capitalize())
				end
			end
		end
		-- deal damage last so we get paradox from each target
		DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam.dam)
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

newDamageType{
	name = "devour life", type = "DEVOUR_LIFE",
	projector = function(src, x, y, type, dam)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		local target = game.level.map(x, y, Map.ACTOR) -- Get the target first to make sure we heal even on kill
		dam.dam = math.max(0, math.min(target.life, dam.dam))
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
		DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		local reapplied = false
		if target then
			-- silence the apply message if the target already has the effect
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.desc == "Slow" then
					reapplied = true
				end
			end
			target:setEffect(target.EFF_SLOW, 3, {power=dam.slow, apply_power=src:combatSpellpower()}, reapplied)
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
				target:setEffect(target.EFF_PINNED, 5, {no_ct_effect=true})
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
				target:setEffect(target.EFF_MANAWORM, 5, {power=dam * 5, src=src, no_ct_effect=true})
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
				if e.subtype.bane then return end
			end

			local what = rng.percent(50) and "blind" or "confusion"
			if target:canBe(what) then
				target:setEffect(what == "blind" and target.EFF_BANE_BLINDED or target.EFF_BANE_CONFUSED, math.ceil(dam.dur), {src=src, power=50, dam=dam.dam, apply_power=src:combatSpellpower()})
			else
				game.logSeen(target, "%s resists the bane!", target.name:capitalize())
			end
		end
	end,
}

-- Darkness damage + speed reduction + minion damage inc
newDamageType{
	name = "rigor mortis", type = "RIGOR_MORTIS",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam)
			target:setEffect(target.EFF_SLOW, dam.dur, {power=dam.speed, apply_power=src:combatSpellpower()})
			target:setEffect(target.EFF_RIGOR_MORTIS, dam.dur, {power=dam.minion, apply_power=src:combatSpellpower()})
		end
	end,
}

newDamageType{
	name = "abyssal shroud", type = "ABYSSAL_SHROUD",
	projector = function(src, x, y, type, dam)
		--make it dark
		game.level.map.remembers(x, y, false)
		game.level.map.lites(x, y, false)

		local target = game.level.map(x, y, Map.ACTOR)
		local reapplied = false
		if target then
			-- silence the apply message it if the target already has the effect
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.desc == "Abyssal Shroud" then
					reapplied = true
				end
			end
			target:setEffect(target.EFF_ABYSSAL_SHROUD, 2, {power=dam.power, lite=dam.lite, apply_power=src:combatSpellpower(), min_dur=1}, reapplied)
			DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam)
		end
	end,
}

newDamageType{
	name = "% chance to summon an orc spirit", type = "GARKUL_INVOKE",
	projector = function(src, x, y, type, dam)
		if not rng.percent(dam) then return end
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then return end

		if game.party:hasMember(src) and game.party:findMember{type="garkul spirit"} then return end

		-- Find space
		local x, y = util.findFreeGrid(src.x, src.y, 5, true, {[engine.Map.ACTOR]=true})
		if not x then return end

		print("Invoking garkul spirit on", x, y)

		local NPC = require "mod.class.NPC"
		local orc = NPC.new{
			type = "humanoid", subtype = "orc",
			display = "o", color=colors.UMBER,
			combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },
			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
			infravision = 10,
			lite = 1,
			rank = 2,
			size_category = 3,
			resolvers.racial(),
			resolvers.sustains_at_birth(),
			autolevel = "warrior",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
			stats = { str=20, dex=8, mag=6, con=16 },
			name = "orc spirit", color=colors.SALMON, image = "npc/humanoid_orc_orc_berserker.png",
			desc = [[An orc clad in a massive armour, wielding a huge axe.]],
			level_range = {35, nil}, exp_worth = 0,
			max_life = resolvers.rngavg(110,120), life_rating = 12,
			resolvers.equip{
				{type="weapon", subtype="battleaxe", autoreq=true},
				{type="armor", subtype="massive", autoreq=true},
			},
			combat_armor = 0, combat_def = 5,

			resolvers.talents{
				[src.T_ARMOUR_TRAINING]={base=4, every=5, max=5},
				[src.T_WEAPON_COMBAT]={base=2, every=10, max=4},
				[src.T_WEAPONS_MASTERY]={base=2, every=10, max=4},
				[src.T_RUSH]={base=3, every=7, max=6},
				[src.T_STUNNING_BLOW]={base=3, every=7, max=6},
				[src.T_BERSERKER]={base=3, every=7, max=6},
			},

			faction = src.faction,
			summoner = src,
			summon_time = 6,
		}

		orc:resolve() orc:resolve(nil, true)
		game.zone:addEntity(game.level, orc, "actor", x, y)
		orc:forceLevelup(src.level)

		orc.remove_from_party_on_death = true
		game.party:addMember(orc, {control="no", type="garkul spirit", title="Garkul Spirit"})
		orc:setTarget(target)
	end,
}

-- speed reduction, hateful whisper
newDamageType{
	name = "nightmare", type = "NIGHTMARE",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:reactionToward(target) < 0 then
			if rng.chance(10) and not target:hasEffect(target.EFF_HATEFUL_WHISPER) then
				src:forceUseTalent(src.T_HATEFUL_WHISPER, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=1, ignore_ressources=true})
			end

			if rng.chance(30) then
				target:setEffect(target.EFF_SLOW, 3, {power=0.3})
			end
		end
	end,
}

newDamageType{
	name = "weakness", type = "WEAKNESS",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			local reapplied = target:hasEffect(target.EFF_WEAKENED)
			target:setEffect(target.EFF_WEAKENED, dam.dur, { power=dam.incDamage }, reapplied)
		end
	end,
}

-- Generic apply temporary effect
newDamageType{
	name = "temp effect", type = "TEMP_EFFECT",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			local ok = false
			if dam.friends then if src:reactionToward(target) >= 0 then ok = true end
			elseif dam.foes then if src:reactionToward(target) < 0 then ok = true end
			else ok = true
			end
			if ok and (not dam.check_immune or target:canBe(dam.check_immune)) then target:setEffect(dam.eff, dam.dur, table.clone(dam.p)) end
		end
	end,
}

newDamageType{
	name = "manaburn", type = "MANABURN", text_color = "#PURPLE#",
	projector = function(src, x, y, type, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			local mana = dam
			local vim = dam / 2
			local positive = dam / 4
			local negative = dam / 4

			mana = math.min(target:getMana(), mana)
			vim = math.min(target:getVim(), vim)
			positive = math.min(target:getPositive(), positive)
			negative = math.min(target:getNegative(), negative)

			target:incMana(-mana)
			target:incVim(-vim)
			target:incPositive(-positive)
			target:incNegative(-negative)

			local dam = math.max(mana, vim * 2, positive * 4, negative * 4)
			return DamageType:get(DamageType.ARCANE).projector(src, x, y, DamageType.ARCANE, dam)
		end
		return 0
	end,
}

newDamageType{
	name = "leaves", type = "LEAVES",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if src:reactionToward(target) < 0 then
				local reapplied = target:hasEffect(target.EFF_CUT)
				target:setEffect(target.EFF_CUT, 2, { power=dam.dam }, reapplied)
			else
				local reapplied = target:hasEffect(target.EFF_LEAVES_COVER)
				target:setEffect(target.EFF_LEAVES_COVER, 1, { power=dam.chance }, reapplied)
			end
		end
	end,
}

-- Distortion; Includes knockback, penetrate, stun, and explosion paramters
newDamageType{
	name = "distortion", type = "DISTORTION",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		tmp = tmp or {}
		if target and not tmp[target] then
			tmp[target] = true
			local old_pen = 0
			-- Spike resists pen
			if dam.penetrate then
				old_pen = src.resists_pen and src.resists_pen[engine.DamageType.PHYSICAL] or 0
				src.resists_pen[engine.DamageType.PHYSICAL] = 100
			end
			-- Handle distortion effects
			if target:hasEffect(target.EFF_DISTORTION) then
				-- Explosive?
				if dam.explosion then
					src:project({type="ball", target.x, target.y, radius=dam.radius}, target.x, target.y, engine.DamageType.DISTORTION, {dam=src:mindCrit(dam.explosion)})
					game.level.map:particleEmitter(target.x, target.y, dam.radius, "generic_blast", {radius=dam.radius, tx=target.x, ty=target.y, rm=255, rM=255, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
					dam.explosion_done = true
				end
				-- Stun?
				if dam.stun then
					dam.do_stun = true
				end
			end
			-- Our damage
			target:setEffect(target.EFF_DISTORTION, 1, {})
			if not dam.explosion_done then
				DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam)
			end
			-- Do knockback
			if dam.knockback then
				if target:checkHit(src:combatMindpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
					target:knockback(src.x, src.y, dam.knockback)
					target:crossTierEffect(target.EFF_OFFBALANCE, src:combatMindpower())
					game.logSeen(target, "%s is knocked back!", target.name:capitalize())
				else
					game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
				end
			end
			-- Do stun
			if dam.do_stun then
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, dam.stun, {apply_power=src:combatMindpower()})
				else
					game.logSeen(target, "%s resists the stun!", target.name:capitalize())
				end
			end
			-- Reset resists pen
			if dam.penetrate then
				src.resists_pen[engine.DamageType.PHYSICAL] = old_pen
			end
		end
	end,
}

-- Mind/Fire damage with lots of parameter options
newDamageType{
	name = "dreamforge", type = "DREAMFORGE",
	projector = function(src, x, y, type, dam, tmp)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		local power, dur, dist, do_particles
		tmp = tmp or {}
		if _G.type(dam) == "table" then dam, power, dur, dist, do_particles = dam.dam, dam.power, dam.dur, dam.dist, dam.do_particles end
		if target and not tmp[target] then
			if src:checkHit(src:combatMindpower(), target:combatMentalResist(), 0, 95) then
				DamageType:get(DamageType.MIND).projector(src, x, y, DamageType.MIND, {dam=dam/2, alwaysHit=true})
				DamageType:get(DamageType.FIREBURN).projector(src, x, y, DamageType.FIREBURN, dam/2)
				if power and power > 0 then
					local silent = true and target:hasEffect(target.EFF_BROKEN_DREAM) or false
					target:setEffect(target.EFF_BROKEN_DREAM, dur, {power=power}, silent)
					target:crossTierEffect(target.EFF_BRAINLOCKED, src:combatMindpower())
				end
				-- Do knockback
				if dist then
					if target:canBe("knockback") then
						target:knockback(src.x, src.y, dist)
						target:crossTierEffect(target.EFF_OFFBALANCE, src:combatMindpower())
						game.logSeen(target, "%s is knocked back!", target.name:capitalize())
					else
						game.logSeen(target, "%s resists the forge bellow!", target.name:capitalize())
					end
				end
				if do_particles then
					if rng.percent(50) then
						game.level.map:particleEmitter(target.x, target.y, 1, "generic_discharge", {rm=225, rM=255, gm=160, gM=160, bm=0, bM=0, am=35, aM=90})
					elseif hit then
						game.level.map:particleEmitter(target.x, target.y, 1, "generic_discharge", {rm=225, rM=255, gm=225, gM=255, bm=255, bM=255, am=35, aM=90})
					end
				end
			else -- Save for half damage
				DamageType:get(DamageType.MIND).projector(src, x, y, DamageType.MIND, {dam=dam/4, alwaysHit=true})
				DamageType:get(DamageType.FIREBURN).projector(src, x, y, DamageType.FIREBURN, dam/4)
				game.logSeen(target, "%s resists the dream forge!", target.name:capitalize())
			end
		end
	end,
}