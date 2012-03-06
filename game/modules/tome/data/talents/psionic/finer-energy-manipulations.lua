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

newTalent{
	name = "Perfect Control",
	type = {"psionic/finer-energy-manipulations", 1},
	require = psi_cun_high1,
	cooldown = 50,
	psi = 15,
	points = 5,
	tactical = { BUFF = 2 },
	getBoost = function(self, t)
		return 15 + math.ceil(self:getTalentLevel(t)*self:combatStatTalentIntervalDamage(t, "combatMindpower", 1, 9))
	end,
	action = function(self, t)
		self:setEffect(self.EFF_CONTROL, 5 + self:getTalentLevelRaw(t), {power= t.getBoost(self, t)})
		return true
	end,
	info = function(self, t)
		local boost = t.getBoost(self, t)
		local dur = 5 + self:getTalentLevelRaw(t)
		return ([[Encase your body in a sheath of thought-quick forces, allowing you to control your body's movements directly without the inefficiency of dealing with crude mechanisms like nerves and muscles.
		Increases attack by %d and critical strike chance by %0.2f%% for %d turns.]]):
		format(boost, 0.5*boost, dur)
	end,
}

newTalent{
	name = "Reshape Weapon",
	type = {"psionic/finer-energy-manipulations", 2},
	require = psi_cun_high2,
	cooldown = 1,
	psi = 0,
	points = 5,
	no_npc_use = true,
	no_unlearn_last = true,
	boost = function(self, t)
		return math.floor(self:combatStatTalentIntervalDamage(t, "combatMindpower", 3, 20))
	end,
	action = function(self, t)
		local d d = self:showInventory("Reshape which weapon?", self:getInven("INVEN"), function(o) return not o.quest and o.type == "weapon" and not o.fully_reshaped end, function(o, item)
			--o.wielder = o.wielder or {}
			if (o.old_atk or 0) < t.boost(self, t) then
				o.combat.atk = (o.combat.atk or 0) - (o.old_atk or 0)
				o.combat.dam = (o.combat.dam or 0) - (o.old_dam or 0)
				o.combat.atk = (o.combat.atk or 0) + t.boost(self, t)
				o.combat.dam = (o.combat.dam or 0) + t.boost(self, t)
				o.old_atk = t.boost(self, t)
				o.old_dam = t.boost(self, t)
				game.logPlayer(self, "You reshape your %s.", o:getName{do_colour=true, no_count=true})
				if not o.been_reshaped then
					o.name = "reshaped" .. " "..o.name..""
					o.been_reshaped = true
				end
				d.used_talent = true
			else
				game.logPlayer(self, "You cannot reshape your %s any further.", o:getName{do_colour=true, no_count=true})
			end
		end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		local weapon_boost = t.boost(self, t)
		return ([[Manipulate forces on the molecular level to realign, rebalance, and hone your weapon. Permanently increases the accuracy and damage of any weapon by %d.]]):
		format(weapon_boost)
	end,
}

newTalent{
	name = "Reshape Armour", short_name = "RESHAPE_ARMOR",
	type = {"psionic/finer-energy-manipulations", 3},
	require = psi_cun_high3,
	cooldown = 1,
	psi = 0,
	points = 5,
	no_npc_use = true,
	no_unlearn_last = true,
	arm_boost = function(self, t)
		local arm_values = {
		0 + self:getWil(2),
		1 + self:getWil(2),
		1 + self:getWil(2),
		2 + self:getWil(2),
		2 + self:getWil(2)
		}
		local index = util.bound(self:getTalentLevelRaw(t), 1, 5)
		return arm_values[index] * (self:getTalentLevel(t) / self:getTalentLevelRaw(t))
	end,
	fat_red = function(self, t)
		local fat_values = {
		1 + self:getWil(3),
		1 + self:getWil(3),
		2 + self:getWil(3),
		2 + self:getWil(3),
		3 + self:getWil(3)
		}
		local index = util.bound(self:getTalentLevelRaw(t), 1, 5)
		return fat_values[index] * (self:getTalentLevel(t) / self:getTalentLevelRaw(t))
	end,
	action = function(self, t)
		local d d = self:showInventory("Reshape which piece of armour?", self:getInven("INVEN"), function(o) return not o.quest and o.type == "armor" and not o.fully_reshaped end, function(o, item)
			if (o.old_fat or 0) < t.fat_red(self, t) then
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
					o.name = "reshaped" .. " "..o.name..""
					o.been_reshaped = true
				end
				d.used_talent = true
			else
				game.logPlayer(self, "You cannot reshape your %s any further.", o:getName{do_colour=true, no_count=true})
			end
		end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		local arm = t.arm_boost(self, t)
		local fat = t.fat_red(self, t)
		return ([[Manipulate forces on the molecular level to realign, rebalance, and reinforce a piece of armour. Permanently increases the armour rating of any piece of armour by %d. Also permanently reduces the fatigue rating of any piece of armour by %d.
		These values scale with Willpower.]]):
		format(arm, fat)
	end,
}

newTalent{
	name = "Matter is Energy",
	type = {"psionic/finer-energy-manipulations", 4},
	require = psi_cun_high4,
	cooldown = 50,
	psi = 0,
	points = 5,
	no_npc_use = true,
	energy_per_turn = function(self, t)
		return self:combatStatTalentIntervalDamage(t, "combatMindpower", 10, 40, 0.25)
	end,
	action = function(self, t)
		local d d = self:showInventory("Use which gem?", self:getInven("INVEN"), function(gem) return gem.type == "gem" and gem.material_level and not gem.unique end, function(gem, gem_item)
			self:removeObject(self:getInven("INVEN"), gem_item)
			local amt = t.energy_per_turn(self, t)
			local dur = 3 + 2*(gem.material_level or 0)
			self:setEffect(self.EFF_PSI_REGEN, dur, {power=amt})
			self.changed = true
			d.used_talent = true
		end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		local amt = t.energy_per_turn(self, t)
		return ([[Matter is energy, as any good Mindslayer knows. Unfortunately, the various bonds and particles involved are just too numerous and complex to make the conversion feasible in most cases. Fortunately, the organized, crystalline structure of gems makes it possible to transform a small percentage of its matter into usable energy.
		Grants %d energy per turn for between five and thirteen turns, depending on the quality of the gem used.]]):
		format(amt)
	end,
}

