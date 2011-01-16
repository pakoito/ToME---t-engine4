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

newTalent{
	name = "Perfect Control",
	type = {"psionic/finer-energy-manipulations", 1},
	require = psi_cun_req1,
	cooldown = 100,
	psi = 15,
	points = 5,
	action = function(self, t)
		self:setEffect(self.EFF_CONTROL, 5 + self:getTalentLevelRaw(t), {power=15 + math.ceil(self:getTalentLevel(t)*(1 + self:getCun(8)))})
		return true
	end,
	info = function(self, t)
		local boost = 15 + math.ceil(self:getTalentLevel(t)*(1 + self:getCun(8)))
		local dur = 5 + self:getTalentLevelRaw(t)
		return ([[Encase your body in a sheath of thought-quick forces, allowing you to control your body's movements directly without the inefficiency of dealing with crude mechanisms like nerves and muscles.
		Increases attack by %d and critical strike chance by %0.2f%% for %d turns. The effect scales with Cunning.]]):
		format(boost, 0.3*boost, dur)
	end,
}

newTalent{
	name = "Reshape Weapon",
	type = {"psionic/finer-energy-manipulations", 2},
	require = psi_cun_req2,
	cooldown = 1,
	psi = 100,
	points = 5,
	action = function(self, t)
		self:showInventory("Reshape which weapon?", self:getInven("INVEN"), function(o) return o.type == "weapon" and not o.fully_reshaped end, function(o, item)
			--o.wielder = o.wielder or {}
			if (o.old_atk or 0) < math.floor(self:getTalentLevel(t)*(1 + self:getWil(4))) then
				o.combat.atk = (o.combat.atk or 0) - (o.old_atk or 0)
				o.combat.dam = (o.combat.dam or 0) - (o.old_dam or 0)
				o.combat.atk = (o.combat.atk or 0) + math.floor(self:getTalentLevel(t)*(1 + self:getWil(4)))
				o.combat.dam = (o.combat.dam or 0) + math.floor(self:getTalentLevel(t)*(1 + self:getWil(4)))
				o.old_atk = math.floor(self:getTalentLevel(t)*(1 + self:getWil(4)))
				o.old_dam = math.floor(self:getTalentLevel(t)*(1 + self:getWil(4)))
				game.logPlayer(self, "You reshape your %s.", o:getName{do_colour=true, no_count=true})
				if not o.been_reshaped then
					o.name = "reshaped" .. " "..o.name..""
					o.been_reshaped = true
				end
			else
				game.logPlayer(self, "You cannot reshape your %s any further.", o:getName{do_colour=true, no_count=true})
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Manipulate forces on the molecular level to realign, rebalance, and hone your weapon. Permanently increases the attack and damage of any weapon by %d.
		This value scales with Willpower.]]):
		format(math.floor(self:getTalentLevel(t)*(1 + self:getWil(4))))
	end,
}

newTalent{
	name = "Reshape Armor",
	type = {"psionic/finer-energy-manipulations", 3},
	require = psi_cun_req3,
	cooldown = 1,
	psi = 100,
	points = 5,
	action = function(self, t)
		self:showInventory("Reshape which piece of armor?", self:getInven("INVEN"), function(o) return o.type == "armor" and not o.fully_reshaped end, function(o, item)
			if (o.old_fat or 0) < math.ceil(0.5*self:getTalentLevel(t)*(1 + self:getWil(4))) then
				o.wielder = o.wielder or {}
				if not o.been_reshaped then
					o.orig_arm = (o.wielder.combat_armor or 0)
					o.orig_fat = (o.wielder.fatigue or 0)
				end
				o.wielder.combat_armor = o.orig_arm
				o.wielder.fatigue = o.orig_fat
				o.wielder.combat_armor = (o.wielder.combat_armor or 0) + math.ceil(0.1*self:getTalentLevel(t)*(1 + self:getWil(4)))
				o.wielder.fatigue = (o.wielder.fatigue or 0) - math.ceil(0.5*self:getTalentLevel(t)*(1 + self:getWil(4)))
				if o.wielder.fatigue < 0 then o.wielder.fatigue = 0 end
				o.old_fat = math.ceil(0.5*self:getTalentLevel(t)*(1 + self:getWil(4)))
				game.logPlayer(self, "You reshape your %s.", o:getName{do_colour=true, no_count=true})
				if not o.been_reshaped then
					o.name = "reshaped" .. " "..o.name..""
					o.been_reshaped = true
				end
			else
				game.logPlayer(self, "You cannot reshape your %s any further.", o:getName{do_colour=true, no_count=true})
			end
		end)
		return true
	end,
	info = function(self, t)
		local arm = math.ceil(0.1*self:getTalentLevel(t)*(1 + self:getWil(4)))
		local fat = math.ceil(0.5*self:getTalentLevel(t)*(1 + self:getWil(4)))
		return ([[Manipulate forces on the molecular level to realign, rebalance, and hone your weapon. Permanently increases the armor rating of any piece of armor by %d. Also permanently reduces the fatigue rating of any piece of armor by %d.
		These values scale with Willpower.]]):
		format(arm, fat)
	end,
}

newTalent{
	name = "Matter is Energy",
	type = {"psionic/finer-energy-manipulations", 4},
	require = psi_cun_req4,
	cooldown = 50,
	psi = 0,
	points = 5,
	action = function(self, t)
		self:showInventory("Use which gem?", self:getInven("INVEN"), function(gem) return gem.type == "gem" and gem.material_level and gem.material_level == 5 end, function(gem, gem_item)
			self:removeObject(self:getInven("INVEN"), gem_item)
			--game.logPlayer(self, "You imbue your %s with %s.", o:getName{do_colour=true, no_count=true}, gem:getName{do_colour=true, no_count=true})
			local quant = 30 + self:getTalentLevel(t)*self:getCun(30)
			self:incPsi(quant)
			self.changed = true
		end)
		return true
	end,
	info = function(self, t)
		local quant = 30 + self:getTalentLevel(t)*self:getCun(30)
		return ([[Matter is energy, as any good Mindslayer knows. Unfortunately, the various bonds and particles involved are just too numerous and complex to make the conversion feasible in most cases. Fortunately, the organized, crystalline structure of gems makes it possible to transform a small percentage of its matter into usable energy.
		Turns a high-quality (material level 5) gem into %d energy. This value scales with Cunning.]]):
		format(quant)
	end,
}

