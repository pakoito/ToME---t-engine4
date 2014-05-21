-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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


newTalent{
	name = "Realign",
	type = {"psionic/finer-energy-manipulations", 1},
	require = psi_cun_req1,
	points = 5,
	psi = 30,
	cooldown = 20,
	tactical = { HEAL = 2 },
	getHeal = function(self, t) return 40 + self:combatTalentMindDamage(t, 20, 450) end,
	is_heal = true,
	numCure = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3, "log"))
	end,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:mindCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		
		local effs = {}
		-- Go through all temporary effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.type == "physical" and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end


		for i = 1, t.numCure(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)


			if eff[1] == "effect" then
				self:removeEffect(eff[2])
				known = true
			end
		end
		if known then
			game.logSeen(self, "%s is cured!", self.name:capitalize())
		end
		
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		local cure = t.numCure(self, t)
		return ([[Realign and readjust your body with the power of your mind, curing up to %d detrimental physical effects and healing for %d life.
		The life healed will increase with your Mindpower.]]):
		format(cure, heal)
	end,
}

newTalent{
	name = "Reshape Weapon/Armour", image = "talents/reshape_weapon.png",
	type = {"psionic/finer-energy-manipulations", 2},
	require = psi_cun_req2,
	cooldown = 1,
	psi = 0,
	points = 5,
	no_npc_use = true,
	no_unlearn_last = true,
	boost = function(self, t)
		return math.floor(self:combatTalentMindDamage(t, 5, 20))
	end,
	arm_boost = function(self, t)
		return math.floor(self:combatTalentMindDamage(t, 5, 20))
	end,
	fat_red = function(self, t)
		return math.floor(self:combatTalentMindDamage(t, 2, 10)) -- Limit Wil effect < 10%
	end,
	action = function(self, t)
		local d d = self:showInventory("Reshape which weapon?", self:getInven("INVEN"), function(o) return not o.quest and (o.type == "weapon" and o.subtype ~= "mindstar") or (o.type == "armor" and (o.slot == "BODY" or o.slot == "OFFHAND" )) and not o.fully_reshaped end, function(o, item)
			--o.wielder = o.wielder or {}
			if o.combat then
				if (o.old_atk or 0) < t.boost(self, t) then
					o.combat.atk = (o.combat.atk or 0) - (o.old_atk or 0)
					o.combat.dam = (o.combat.dam or 0) - (o.old_dam or 0)
					o.combat.atk = (o.combat.atk or 0) + t.boost(self, t)
					o.combat.dam = (o.combat.dam or 0) + t.boost(self, t)
					o.old_atk = t.boost(self, t)
					o.old_dam = t.boost(self, t)
					game.logPlayer(self, "You reshape your %s.", o:getName{do_colour=true, no_count=true})
					o.special = true
					if not o.been_reshaped then
						o.name = "reshaped" .. " "..o.name..""
						o.been_reshaped = true
					end
					d.used_talent = true
				else
					game.logPlayer(self, "You cannot reshape your %s any further.", o:getName{do_colour=true, no_count=true})
				end
			else
				if (o.old_fat or 0) < t.fat_red(self, t) or o.wielder.combat_armor < o.orig_arm + t.arm_boost(self,t) then	-- Allow armor only improvements
					o.wielder = o.wielder or {}
					if not o.been_reshaped then
						o.orig_arm = (o.wielder.combat_armor or 0)
						o.orig_fat = (o.wielder.fatigue or 0)
					end
					o.wielder.combat_armor = o.orig_arm
					o.wielder.fatigue = o.orig_fat
					o.wielder.combat_armor = (o.wielder.combat_armor or 0) + t.arm_boost(self, t)
					o.wielder.fatigue = (o.wielder.fatigue or 0) - t.fat_red(self, t)
					if o.wielder.fatigue < 0 and not (o.orig_fat < 0) then
						o.wielder.fatigue = 0
					elseif o.wielder.fatigue < 0 and o.orig_fat < 0 then
						o.wielder.fatigue = o.orig_fat
					end
					o.old_fat = t.fat_red(self, t)
					game.logPlayer(self, "You reshape your %s.", o:getName{do_colour=true, no_count=true})
					if not o.been_reshaped then
						o.orig_name = o.name
						o.been_reshaped = true
					end
					o.name = "reshaped["..tostring(t.arm_boost(self,t))..","..tostring(o.wielder.fatigue-o.orig_fat).."%] "..o.orig_name..""
					d.used_talent = true
				else
					game.logPlayer(self, "You cannot reshape your %s any further.", o:getName{do_colour=true, no_count=true})
				end
			end
		end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		local weapon_boost = t.boost(self, t)
		local arm = t.arm_boost(self, t)
		local fat = t.fat_red(self, t)
		return ([[Manipulate forces on the molecular level to realign, rebalance, and hone your weapon or armour. Mindstars object to being adjusted however, prefering a natural state.
		Permanently increases the Accuracy and damage of any weapon by %d. Permanently increases the armour rating of any piece of Armour by %d, and permanently reduces the fatigue rating of any piece of armour by %d.
		These values scale with your Mindpower.]]):
		format(weapon_boost, arm, fat)
	end,
}

newTalent{
	name = "Matter is Energy",
	type = {"psionic/finer-energy-manipulations", 3},
	require = psi_cun_req3,
	cooldown = 50,
	psi = 0,
	points = 5,
	no_npc_use = true,
	energy_per_turn = function(self, t)
		return self:combatTalentMindDamage(t, 10, 40)
	end,
	action = function(self, t)
		local d d = self:showInventory("Use which gem?", self:getInven("INVEN"), function(gem) return gem.type == "gem" and gem.material_level and not gem.unique end, function(gem, gem_item)
			self:removeObject(self:getInven("INVEN"), gem_item)
			local amt = t.energy_per_turn(self, t)
			local dur = 3 + 2*(gem.material_level or 0)
			self:setEffect(self.EFF_PSI_REGEN, dur, {power=amt})
			self.changed = true
			d.used_talent = true
			local gem_names = {
				GEM_DIAMOND = "Diamond",
				GEM_PEARL = "Pearl",
				GEM_MOONSTONE = "Moonstone", 
				GEM_FIRE_OPAL = "Fire Opal",
				GEM_BLOODSTONE = "Bloodstone",
				GEM_RUBY = "Ruby",
				GEM_AMBER = "Amber",
				GEM_TURQUOISE = "Turquoise",
				GEM_JADE = "Jade",
				GEM_SAPPHIRE = "Sapphire",
				GEM_QUARTZ = "Quartz",
				GEM_EMERALD = "Emerald",
				GEM_LAPIS_LAZULI = "Lapis Lazuli",
				GEM_GARNET = "Garnet",
				GEM_ONYX = "Onyx",
				GEM_AMETHYST = "Amethyst", 
				GEM_OPAL = "Opal", 
				GEM_TOPAZ = "Topaz",
				GEM_AQUAMARINE = "Aquamarine",
				GEM_AMETRINE = "Ametrine",
				GEM_ZIRCON = "Zircon",
				GEM_SPINEL = "Spinel",
				GEM_CITRINE = "Citrine",
				GEM_AGATE = "Agate",
			}
			self:setEffect(self.EFF_CRYSTAL_BUFF, dur, {name=gem_names[gem.define_as], gem=gem.define_as})
		end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		local amt = t.energy_per_turn(self, t)
		return ([[Matter is energy, as any good Mindslayer knows. Unfortunately, the various bonds and particles involved are just too numerous and complex to make the conversion feasible in most cases. Fortunately, the organized, crystalline structure of gems makes it possible to transform a small percentage of its matter into usable energy.
		Grants %d energy per turn for between five and thirteen turns, depending on the quality of the gem used.
		Also the basic effect of the gem lingers on you while this effect lasts.]]):
		format(amt)
	end,
}

newTalent{
	name = "Resonant Focus",
	type = {"psionic/finer-energy-manipulations", 4},
	require = psi_cun_req4,
	mode = "passive",
	points = 5,
	bonus = function(self,t) return self:combatTalentScale(t, 10, 40) end,
	on_learn = function(self, t)
		if self:isTalentActive(self.T_BEYOND_THE_FLESH) then
			if self.__to_recompute_beyond_the_flesh then return end
			self.__to_recompute_beyond_the_flesh = true
			game:onTickEnd(function()
				self.__to_recompute_beyond_the_flesh = nil
				local t = self:getTalentFromId(self.T_BEYOND_THE_FLESH)
				self:forceUseTalent(t.id, {ignore_energy=true, ignore_cd=true, no_talent_fail=true})
				if t.on_pre_use(self, t) then self:forceUseTalent(t.id, {ignore_energy=true, ignore_cd=true, no_talent_fail=true, talent_reuse=true}) end
			end)
		end
	end,
	info = function(self, t)
		local inc = t.bonus(self,t)
		return ([[By carefully synchronising your mind to the resonant frequencies of you psionic focus, you strengthen its effects.
		For conventional weapons, this increases the percentage of your willpower and cunning that is used in place of strength and dexterity, from 80%% to %d%%.
		For mindstars, this increases the pull chance by +%d%%.
		For gems, this increases the bonus stats by %d.]]):
		format(80+inc, inc, math.ceil(inc/5))
	end,
}
