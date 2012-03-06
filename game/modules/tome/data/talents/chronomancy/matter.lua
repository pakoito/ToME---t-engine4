-- ToME -  Tales of Maj'Eyal
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
	name = "Dust to Dust",
	type = {"chronomancy/matter",1},
	require = chrono_req1,
	points = 5,
	paradox = 5,
	cooldown = 3,
	tactical = { ATTACKAREA = {TEMPORAL = 1, PHYSICAL = 1} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.MATTER, self:spellCrit(t.getDamage(self, t)))
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "matter_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Fires a beam that turns matter into dust, inflicting %0.2f temporal damage and %0.2f physical damage.
		The damage will scale with your Paradox and Spellpower.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage / 2), damDesc(self, DamageType.PHYSICAL, damage / 2))
	end,
}

newTalent{
	name = "Carbon Spikes",
	type = {"chronomancy/matter", 2},
	require = chrono_req2, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_paradox = 100,
	cooldown = 12,
	tactical = { BUFF =2, DEFEND = 2 },
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) end,
	getArmor = function(self, t) return math.ceil (self:combatTalentSpellDamage(t, 20, 50)) end,
	do_carbonRegrowth = function(self, t)
		local maxspikes = t.getArmor(self, t)
		if self.carbon_armor < maxspikes then
			self.carbon_armor = self.carbon_armor + 1
		end
	end,
	do_carbonLoss = function(self, t)
		if self.carbon_armor >= 1 then
			self.carbon_armor = self.carbon_armor - 1
		else
			-- Deactivate without loosing energy
			self:forceUseTalent(self.T_CARBON_SPIKES, {ignore_energy=true})
		end
	end,
	activate = function(self, t)
		local power = t.getArmor(self, t)
		self.carbon_armor = power
		game:playSoundNear(self, "talents/spell_generic")
		return {
			armor = self:addTemporaryValue("carbon_spikes", power),
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.BLEED]=t.getDamageOnMeleeHit(self, t)}),			
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("carbon_spikes", p.armor)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self.carbon_armor = nil
		return true
	end,
	info = function(self, t)
		local damage = t.getDamageOnMeleeHit(self, t)
		local armor = t.getArmor(self, t)
		return ([[Fragile spikes of carbon protrude from your flesh, clothing, and armor, increasing your armor rating by %d and inflicting %0.2f bleed damage over six turns on attackers.   Each time you're struck the armor increase will be reduced by 1.  Each turn the spell will regenerate 1 armor up to it's starting value.
		If the armor increase from the spell ever falls below 1 the sustain will deactivate and the effect will end.
		The armor and bleed damage will increase with your Spellpower.]]):
		format(armor, damDesc(self, DamageType.PHYSICAL, damage))
	end,
}

newTalent{
	name = "Destabilize",
	type = {"chronomancy/matter", 3},
	require = chrono_req3,
	points = 5,
	cooldown = 10,
	paradox = 15,
	range = 10,
	tactical = { ATTACK = 2 },
	requires_target = true,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 60)*getParadoxModifier(self, pm) end,
	getExplosion = function(self, t) return self:combatTalentSpellDamage(t, 20, 230)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_TEMPORAL_DESTABILIZATION, 10, {src=self, dam=t.getDamage(self, t), explosion=self:spellCrit(t.getExplosion(self, t))})
			game.level.map:particleEmitter(target.x, target.y, 1, "entropythrust")
		end)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local explosion = t.getExplosion(self, t)
		return ([[Destabilizes the target, inflicting %0.2f temporal damage per turn for 10 turns.  If the target dies while destabilized it will explode doing %0.2f temporal damage and %0.2f physical damage in a radius of 4.
		If the target dies while also under the effects of continuum destabilization all explosion damage will be done as temporal damage.
		The damage will scale with your Paradox and Spellpower.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage), damDesc(self, DamageType.TEMPORAL, explosion/2), damDesc(self, DamageType.PHYSICAL, explosion/2))
	end,
}

newTalent{
	name = "Quantum Spike",
	type = {"chronomancy/matter", 4},
	require = chrono_req4,
	points = 5,
	paradox = 20,
	cooldown = 4,
	tactical = { ATTACK = {TEMPORAL = 1, PHYSICAL = 1} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 300)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		
		-- bonus damage on targets with temporal destabilization
		local damage = t.getDamage(self, t)
		if target then 
			if target:hasEffect(target.EFF_TEMPORAL_DESTABILIZATION) or target:hasEffect(target.EFF_CONTINUUM_DESTABILIZATION) then
				damage = damage * 1.5
			end
		end
		
		
		self:project(tg, x, y, DamageType.MATTER, self:spellCrit(damage))
		game:playSoundNear(self, "talents/arcane")
		
		-- Try to insta-kill
		if target then
			if target:checkHit(self:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("instakill") and target.life > 0 and target.life < target.max_life * 0.2 then
				-- KILL IT !
				game.logSeen(target, "%s has been pulled apart at a molecular level!", target.name:capitalize())
				target:die(self)
			elseif target.life > 0 and target.life < target.max_life * 0.2 then
				game.logSeen(target, "%s resists the quantum spike!", target.name:capitalize())
			end
		end
		
		-- if we kill it use teleport particles for larger effect radius
		if target and target.dead then
			game.level.map:particleEmitter(x, y, 1, "teleport")
		else
			game.level.map:particleEmitter(x, y, 1, "entropythrust")
		end
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Attempts to pull the target apart at a molecular level, inflicing %0.2f temporal damage and %0.2f physical damage.  If the target ends up with low enough life(<20%%) it might be instantly killed.
		Quantum Spike deals 50%% additional damage to targets effected by temporal destabilization and/or continuum destabilization.
		The damage will scale with your Paradox and Spellpower.]]):format(damDesc(self, DamageType.TEMPORAL, damage/2), damDesc(self, DamageType.PHYSICAL, damage/2))
	end,
}

