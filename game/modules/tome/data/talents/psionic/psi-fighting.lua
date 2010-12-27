-- ToME - Tales of Maj'Eyal
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

local function cancelAuras(self)
	local auras = {self.T_CHARGED_AURA, self.T_THERMAL_AURA, self.T_KINETIC_AURA,}
	for i, t in ipairs(auras) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
	end
end

local function TKcombatDamage(weapon, self)
	weapon = weapon or self.combat or {}

	local totstat = 0
	-- mswilbonus and mscunbonus replace strength and dexterity bonuses, respectively, when calculating damage. Only applicable to mindslayers.
	local mswilbonus = self:getStat("wil")
	local mscunbonus = self:getStat("cun")
	local dammod = weapon.dammod or {str=0.6}
	for stat, mod in pairs(dammod) do
		if stat == "str" then stat = "wil" end
		if stat == "dex" then stat = "cun" end
		totstat = totstat + self:getStat(stat) * mod
	end

	local add = 0
	if self:knowTalent(Talents.T_ARCANE_DESTRUCTION) then
		add = add + self:combatSpellpower() * self:getTalentLevel(Talents.T_ARCANE_DESTRUCTION) / 9
	end
	if self:isTalentActive(Talents.T_BLOOD_FRENZY) then
		add = add + self.blood_frenzy
	end

	local talented_mod = math.sqrt(self:combatCheckTraining(weapon) / 10) + 1
	local power = math.max(self.combat_dam + (weapon.dam or 1) + add, 1)
	power = (math.sqrt(power / 10) - 1) * 0.8 + 1
	print(("[COMBAT DAMAGE] power(%f) totstat(%f) talent_mod(%f)"):format(power, totstat, talented_mod))
	return totstat / 2 * power * talented_mod
end

local function TKattackTargetWith(target, weapon, damtype, mult, self)
	damtype = damtype or weapon.damtype or DamageType.PHYSICAL
	mult = mult or 1

	-- Does the blow connect? yes .. complex :/
	local def = target:combatDefense()
	local msatkbonus = ((self:getWil(50) - 5) + (self:getCun(50) - 5))
	local atk = self.combat_atk + self:getTalentLevel(Talents.T_WEAPON_COMBAT) * 5 + (weapon.atk or 0) + msatkbonus + (self:getLck() - 50) * 0.4
	if not self:canSee(target) then atk = atk / 3 end
	local dam, apr, armor = TKcombatDamage(weapon, self), self:combatAPR(weapon), target:combatArmor()
	print("[ATTACK] to ", target.name, " :: ", dam, apr, armor, "::", mult)

	-- If hit is over 0 it connects, if it is 0 we still have 50% chance
	local hitted = false
	local crit = false
	local evaded = false
	if self:checkEvasion(target) then
		evaded = true
		game.logSeen(target, "%s evades %s.", target.name:capitalize(), self.name)
	elseif self:checkHit(atk, def) then
		print("[ATTACK] raw dam", dam, "versus", armor, "with APR", apr)
		dam = math.max(0, dam - math.max(0, armor - apr))
		local damrange = self:combatDamageRange(weapon)
		dam = rng.range(dam, dam * damrange)
		print("[ATTACK] after range", dam)
		dam, crit = self:physicalCrit(dam, weapon, target)
		print("[ATTACK] after crit", dam)
		dam = dam * mult
		print("[ATTACK] after mult", dam)
		if crit then game.logSeen(self, "%s performs a critical strike!", self.name:capitalize()) end
		DamageType:get(damtype).projector(self, target.x, target.y, damtype, math.max(0, dam))
		hitted = true
	else
		local srcname = game.level.map.seens(self.x, self.y) and self.name:capitalize() or "Something"
		game.logSeen(target, "%s misses %s.", srcname, target.name)
	end

	-- Spread diseases
	if hitted and self:knowTalent(self.T_CARRIER) and rng.percent(4 * self:getTalentLevelRaw(self.T_CARRIER)) then
		-- Use epidemic talent spreading
		local t = self:getTalentFromId(self.T_EPIDEMIC)
		t.do_spread(self, t, target)
	end

	-- Melee project
	if hitted and not target.dead and weapon.melee_project then for typ, dam in pairs(weapon.melee_project) do
		if dam > 0 then
			DamageType:get(typ).projector(self, target.x, target.y, typ, dam)
		end
	end end
	if hitted and not target.dead then for typ, dam in pairs(self.melee_project) do
		if dam > 0 then
			DamageType:get(typ).projector(self, target.x, target.y, typ, dam)
		end
	end end

	-- Weapon of light cast
	if hitted and not target.dead and self:knowTalent(self.T_WEAPON_OF_LIGHT) and self:isTalentActive(self.T_WEAPON_OF_LIGHT) then
		local dam = 7 + self:getTalentLevel(self.T_WEAPON_OF_LIGHT) * self:combatSpellpower(0.092)
		DamageType:get(DamageType.LIGHT).projector(self, target.x, target.y, DamageType.LIGHT, dam)
		self:incPositive(-3)
		if self:getPositive() <= 0 then
			self:forceUseTalent(self.T_WEAPON_OF_LIGHT, {ignore_energy=true})
		end
	end

	-- Mindslayer Conduit talent damage added
	if hitted and not target.dead and self:knowTalent(self.T_CONDUIT) and self:isTalentActive(self.T_CONDUIT) then
		local t = self:getTalentFromId(self.T_CONDUIT)
		t.do_combat(self, t, target)
	end

	-- Shadow cast
	if hitted and not target.dead and self:knowTalent(self.T_SHADOW_COMBAT) and self:isTalentActive(self.T_SHADOW_COMBAT) and self:getMana() > 0 then
		local dam = 3 + self:getTalentLevel(self.T_SHADOW_COMBAT) * 2
		local mana = 1 + self:getTalentLevelRaw(t) / 1.5
		DamageType:get(DamageType.DARKNESS).projector(self, target.x, target.y, DamageType.DARKNESS, dam)
		self:incMana(-mana)
	end

	-- Autospell cast
	if hitted and not target.dead and self:knowTalent(self.T_ARCANE_COMBAT) and self:isTalentActive(self.T_ARCANE_COMBAT) and rng.percent(20 + self:getTalentLevel(self.T_ARCANE_COMBAT) * (1 + self:getDex(9, true))) then
		local spells = {}
		if self:knowTalent(self.T_FLAME) then spells[#spells+1] = self.T_FLAME end
		if self:knowTalent(self.T_LIGHTNING) then spells[#spells+1] = self.T_LIGHTNING end
		local tid = rng.table(spells)
		if tid then
			print("[ARCANE COMBAT] autocast ",self:getTalentFromId(tid).name)
			local old_cd = self:isTalentCoolingDown(self:getTalentFromId(tid))
			self:forceUseTalent(tid, {ignore_energy=true, force_target=target})
			-- Do not setup a cooldown
			if not old_cd then
				self.talents_cd[tid] = nil
			end
			self.changed = true
		end
	end

	-- On hit talent
	if hitted and not target.dead and weapon.talent_on_hit and next(weapon.talent_on_hit) then
		for tid, data in pairs(weapon.talent_on_hit) do
			if rng.percent(data.chance) then
				self:forceUseTalent(tid, {ignore_energy=true, force_target=target, force_level=data.level})
			end
		end
	end

	-- Shattering Impact
	if hitted and self:attr("shattering_impact") then
		local dam = dam * self.shattering_impact
		self:project({type="ball", radius=1, friendlyfire=false}, target.x, target.y, DamageType.PHYSICAL, dam)
		self:incStamina(-15)
	end

	-- Onslaught
	if hitted and self:attr("onslaught") then
		local dir = util.getDir(target.x, target.y, self.x, self.y)
		local lx, ly = util.coordAddDir(self.x, self.y, dir_sides[dir].left)
		local rx, ry = util.coordAddDir(self.x, self.y, dir_sides[dir].right)
		local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

		if target:checkHit(self:combatAttack(weapon), target:combatPhysicalResist(), 0, 95, 10) and target:canBe("knockback") then
			target:knockback(self.x, self.y, self:attr("onslaught"))
		end
		if lt and lt:checkHit(self:combatAttack(weapon), lt:combatPhysicalResist(), 0, 95, 10) and lt:canBe("knockback") then
			lt:knockback(self.x, self.y, self:attr("onslaught"))
		end
		if rt and rt:checkHit(self:combatAttack(weapon), rt:combatPhysicalResist(), 0, 95, 10) and r+t:canBe("knockback") then
			rt:knockback(self.x, self.y, self:attr("onslaught"))
		end
	end

	-- Reactive target on hit damage
	if hitted then for typ, dam in pairs(target.on_melee_hit) do
		if dam > 0 then
			DamageType:get(typ).projector(target, self.x, self.y, typ, dam)
		end
	end end

	-- Acid splash
	if hitted and target:knowTalent(target.T_ACID_BLOOD) then
		local t = target:getTalentFromId(target.T_ACID_BLOOD)
		t.do_splash(target, t, self)
	end

	-- Bloodbath
	if hitted and crit and self:knowTalent(self.T_BLOODBATH) then
		local t = self:getTalentFromId(self.T_BLOODBATH)
		t.do_bloodbath(self, t)
	end

	-- Mortal Terror
	if hitted and not target.dead and self:knowTalent(self.T_MORTAL_TERROR) then
		local t = self:getTalentFromId(self.T_MORTAL_TERROR)
		t.do_terror(self, t, target, dam)
	end

	-- Special effect
	if hitted and not target.dead and weapon.special_on_hit and weapon.special_on_hit.fct then
		weapon.special_on_hit.fct(weapon, self, target)
	end

	-- Regen on being hit
	if hitted and not target.dead and target:attr("stamina_regen_on_hit") then target:incStamina(target.stamina_regen_on_hit) end
	if hitted and not target.dead and target:attr("mana_regen_on_hit") then target:incMana(target.mana_regen_on_hit) end
	if hitted and not target.dead and target:attr("equilibrium_regen_on_hit") then target:incEquilibrium(-target.equilibrium_regen_on_hit) end

	-- Riposte!
	if not hitted and not target.dead and not evaded and not target:attr("stunned") and not target:attr("dazed") and not target:attr("stoned") and target:knowTalent(target.T_RIPOSTE) and rng.percent(target:getTalentLevel(target.T_RIPOSTE) * (5 + target:getDex(5))) then
		game.logSeen(self, "%s ripostes!", target.name:capitalize())
		target:attackTarget(self, nil, nil, true)
	end

	return self:combatSpeed(weapon), hitted
end



newTalent{
	name = "Telekinetic Smash",
	type = {"psionic/psi-fighting", 1},
	require = psi_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	psi = 10,
	range = 1,
	action = function(self, t)

		local tkweapon = self:getInven("MAINHAND")[1]
		if type(tkweapon) == "boolean" then tkweapon = nil end
		if not tkweapon then
			game.logPlayer(self, "You cannot do that without a weapon in your hands.")
			return nil
		end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self:attackTargetWith(target, tkweapon.combat, nil, self:combatTalentWeaponDamage(t, 1.5, 3))
		return true
	end,
	info = function(self, t)
		return ([[Gather your will and brutally smash the target with your mainhand weapon, doing %d%% weapon damage.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1.5, 3))
	end,
}

newTalent{
	name = "Augmentation",
	type = {"psionic/psi-fighting", 2},
	require = psi_wil_req2,
	points = 5,
	mode = "sustained",
	cooldown = 0,
	sustain_psi = 10,
	activate = function(self, t)
		local str_power = math.floor(0.1*self:getTalentLevel(t)*self:getWil())
		local dex_power = math.floor(0.1*self:getTalentLevel(t)*self:getCun())
		return {
			stats = self:addTemporaryValue("inc_stats", {
				[self.STAT_STR] = str_power,
				[self.STAT_DEX] = dex_power,
			}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_stats", p.stats)
		return true
	end,
	info = function(self, t)
		local inc = 10*self:getTalentLevel(t)
		local str_power = math.floor(0.1*self:getTalentLevel(t)*self:getWil())
		local dex_power = math.floor(0.1*self:getTalentLevel(t)*self:getCun())
		return ([[While active, you give your flesh and blood body a little aid in the form of precisely applied mental forces. Increases Strength and Dexterity by %d%% of your Willpower and Cunning, respectively.
		Strength increased by %d
		Dexterity increased by %d]]):
		format(inc, str_power, dex_power)
	end,
}

newTalent{
	name = "Conduit",
	type = {"psionic/psi-fighting", 3},
	require = psi_wil_req3, no_sustain_autoreset = true,
	cooldown = 1,
	mode = "sustained",
	sustain_psi = 0,
	points = 5,
	

	activate = function(self, t)
		local ret = {
		k_aura_on = self:isTalentActive(self.T_KINETIC_AURA),
		t_aura_on = self:isTalentActive(self.T_THERMAL_AURA),
		c_aura_on = self:isTalentActive(self.T_CHARGED_AURA),	
		}
		local cur_psi = self:getPsi()
		self:incPsi(-5000)
		--self.sustain_talents[t.id] = {}
		cancelAuras(self)
		self:incPsi(cur_psi)
		return ret
	end,

	do_combat = function(self, t, target)
		local mult = 1 + 0.1*(self:getTalentLevel(t))
		local auras = self:isTalentActive(t.id)
		if auras.k_aura_on then
			local k_aura = self:getTalentFromId(self.T_KINETIC_AURA)
			local k_dam = mult * k_aura.getAuraStrength(self, k_aura)
			DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, k_dam)
		end
		if auras.t_aura_on then
			local t_aura = self:getTalentFromId(self.T_THERMAL_AURA)
			local t_dam = mult * t_aura.getAuraStrength(self, t_aura)
			DamageType:get(DamageType.FIRE).projector(self, target.x, target.y, DamageType.FIRE, t_dam)
		end
		if auras.c_aura_on then
			local c_aura = self:getTalentFromId(self.T_CHARGED_AURA)
			local c_dam = mult * c_aura.getAuraStrength(self, c_aura)
			DamageType:get(DamageType.LIGHTNING).projector(self, target.x, target.y, DamageType.LIGHTNING, c_dam)
		end
	end,

	deactivate = function(self, t)
		return true
	end,
	info = function(self, t)
		local mult = 1 + 0.1*(self:getTalentLevel(t))
		return ([[When activated, turns off any active auras and uses your telekinetically-wielded weapon as a conduit for the energies that were being channeled through those auras.
		Any auras used by Conduit will not start to cool down until Conduit has been deactivated. The damage from each aura applied by Conduit is multiplied by %0.2f, and does not drain energy.]]):
		format(mult)
	end,
}

newTalent{
	name = "Frenzied Psifighting",
	type = {"psionic/psi-fighting", 4},
	require = psi_wil_req4,
	cooldown = 20,
	psi = 30,
	points = 5,
	action = function(self, t)
		local targets = 1 + math.ceil(self:getTalentLevel(t)/5)
		self:setEffect(self.EFF_PSIFRENZY, 3 * self:getTalentLevelRaw(t), {power=targets})
		return true
	end,
	--getTargNum = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)/5) end,
	info = function(self, t)
		local targets = 1 + math.ceil(self:getTalentLevel(t)/5)
		local dur = 3 * self:getTalentLevelRaw(t)
		return ([[Your telekinetically wielded weapon enters a frenzy for %d turns, striking up to %d targets every turn.]]):
		format(dur, targets)
	end,
}

newTalent{
	name = "Telekinetic Grasp",
	type = {"psionic/other", 1},
	points = 1,
	cooldown = 0,
	psi = 0,
	type_no_req = true,
	no_npc_use = true,
	action = function(self, t)
		local inven = self:getInven("INVEN")
		self:showInventory("Telekinetically grasp which item?", inven, function(o)
			return (o.type == "weapon" or o.type == "gem") and o.subtype ~= "longbow" and o.subtype ~= "sling" and o.material_level
		end, function(o, item)
			o = self:removeObject(inven, item)
			local pf = self:getInven("PSIONIC_FOCUS")
			-- Remove old one
			local old = self:removeObject(pf, 1, true)
			
			-- Force "wield"
			self:addObject(pf, o)
			game.logSeen(self, "%s wears: %s.", self.name:capitalize(), o:getName{do_color=true})
			
			-- Put back the old one in inventory
			if old then self:addObject(inven, old) end
			self:sortInven()
		end)
		end,
	info = function(self, t)
		return ([[Encase a weapon or gem in mentally-controlled forces, holding it aloft and bringing it to bear with the power of your mind alone.]])
	end,
}

newTalent{
	name = "Beyond the Flesh",
	type = {"psionic/other", 1},
	points = 1,
	mode = "sustained",
	cooldown = 0,
	sustain_psi = 0,
	range = 1,
	direct_hit = true,
	btf_damage= function(self)
		local o = self:getInven("PSIONIC_FOCUS")[1]
		if o.type == "weapon" then
			return TKcombatDamage(o, self)
		else
			return 0
		end
	end,
	do_tkautoattack = function(self, t)
		local targnum = 1
		if self:hasEffect(self.EFF_PSIFRENZY) then targnum = 1 + math.ceil(0.2*self:getTalentLevel(self.T_FRENZIED_PSIFIGHTING)) end
		local speed, hit = nil, false
		local sound, sound_miss = nil, nil
		--dam = self:getTalentLevel(t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 1, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly pick a target
		local tg = {type="hit", range=1, talent=t}
		for i = 1, targnum do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			
			if self:getInven(self.INVEN_PSIONIC_FOCUS) then
				for i, o in ipairs(self:getInven(self.INVEN_PSIONIC_FOCUS)) do
					if o.combat and not o.archery then
						print("[ATTACK] attacking with", o.name)
						--local s, h = self:TKattackTargetWith(a, o.combat, nil, self:combatTalentWeaponDamage(t, 0.7, 1.7))
						local s, h = TKattackTargetWith(a, o.combat, nil, 1, self)
						speed = math.max(speed or 0, s)
						hit = hit or h
						if hit and not sound then sound = o.combat.sound
						elseif not hit and not sound_miss then sound_miss = o.combat.sound_miss end
						if not o.combat.no_stealth_break then break_stealth = true end
					end
				end
			else
				return nil
			end

		end
		return hit
	end,	
	activate = function (self, t)
		local tkweapon = self:getInven("PSIONIC_FOCUS")[1]
		if type(tkweapon) == "boolean" then tkweapon = nil end
		if not tkweapon or tkweapon.type == "gem" then
			game.logPlayer(self, "You cannot do that without a telekinetically-wielded weapon.")
			return nil
		end
		return true
	end,
	deactivate =  function (self, t)
		return true
	end,
	info = function(self, t)
		local atk = 0
		local dam = 0
		local apr = 0
		local crit = 0
		local speed = 1
		local o = self:getInven("PSIONIC_FOCUS")[1]
		if type(o) == "boolean" then o = nil end
		if not o then
			return ([[Allows you to wield a weapon telekinetically, directing it with your willpower and cunning rather than crude flesh. When activated, the telekinetically-wielded weapon will attack a random melee-range target each turn.
			The telekinetically-wielded weapon uses Willpower in place of Strength and Cunning in place of Dexterity to determine attack and damage.
			You are not telekinetically wielding anything right now.]])
		end
		if o.type == "weapon" then
			local msatkbonus = ((self:getWil(50) - 5) + (self:getCun(50) - 5))
			atk = self.combat_atk + self:getTalentLevel(Talents.T_WEAPON_COMBAT) * 5 + (o.atk or 0) + msatkbonus + (self:getLck() - 50) * 0.4 
			dam = TKcombatDamage(o.combat, self)
			apr = self:combatAPR(o.combat)
			crit = self:combatCrit(o.combat)
			speed = self:combatSpeed(o.combat)
		end
		return ([[Allows you to wield a weapon telekinetically, directing it with your willpower and cunning rather than crude flesh. When activated, the telekinetically-wielded weapon will attack a random melee-range target each turn.
		The telekinetically-wielded weapon uses Willpower in place of Strength and Cunning in place of Dexterity to determine attack and damage.
		Combat stats:
		Attack %d 
		Damage: %d
		APR: %d
		Crit: %0.2f
		Speed: %0.2f]]):
		format(atk, dam, apr, crit, speed)
	end,
}

