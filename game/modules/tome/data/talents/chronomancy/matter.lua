-- ToME -  Tales of Maj'Eyal
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

newTalent{
	name = "Dust to Dust",
	type = {"chronomancy/matter",1},
	require = chrono_req1,
	points = 5,
	paradox = 6,
	cooldown = 3,
	tactical = { ATTACKAREA = 2 },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 220)*getParadoxModifier(self, pm) end,
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
		return ([[Fires a beam that attempts to turn matter into dust, inflicting %0.2f temporal damage and %0.2f physical damage.
		The damage will scale with your Paradox and Magic stat.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage / 2), damDesc(self, DamageType.PHYSICAL, damage / 2))
	end,
}
--[[newTalent{
	name = "Terraforming",
	type = {"chronomancy/matter",2},
	require = chrono_req2,
	points = 5,
	paradox = 10,
	range = 6,
	no_npc_use = true,
	cooldown = function(self, t) return 20 - math.ceil(self:getTalentLevel(t) *2) or 0 end,
	reflectable = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			self:project(tg, x, y, DamageType.DIG, nil)
		else
			self:project(tg, x, y, DamageType.GROW, nil)
		end
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return (Makes impassable terrain passable and turns passable terrain into walls, trees, etc.
		Additional talent points will lower the cooldown):format()
	end,
}]]

newTalent{
	name = "Carbon Spikes",
	type = {"chronomancy/matter", 2},
	require = chrono_req2, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_paradox = 150,
	cooldown = 12,
	tactical = { BUFF =2, DEFEND = 2 },
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	getArmor = function(self, t) return math.ceil (self:combatTalentSpellDamage(t, 20, 40)) end,
	activate = function(self, t)
		local power = t.getArmor(self, t)
		self.carbon_armor = power
		game:playSoundNear(self, "talents/generic")
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
		return ([[Fragile spikes of carbon protrude from your clothing and armor, increasing your armor rating by %d and inflicting %0.2f bleed damage over six turns on attackers.   Each time you're struck the armor increase will be reduced by 1 until the bonus is less then 1, at which point the spikes will crumble completely and the spell will end.
		The armor and bleed damage will increase with the Magic stat.]]):
		format(armor, damDesc(self, DamageType.PHYSICAL, damage))
	end,
}

newTalent{
	name = "Calcify",
	type = {"chronomancy/matter",3},
	require = chrono_req3,
	points = 5,
	paradox = 20,
	cooldown = 20,
	tactical = { ATTACKAREA = 2, DISABLE = 2 },
        range = 0,
	radius = function(self, t)
		return 1 + self:getTalentLevelRaw(t)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDuration = function(self, t) return 2 + math.floor(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end

			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 10) and target:canBe("stone") and target:canBe("instakill") then
				target:setEffect(target.EFF_STONED, t.getDuration(self, t), {})
			else
				game.logSeen(target, "%s resists the calcification.", target.name:capitalize())
			end
		end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_earth", {radius=tg.radius})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[Attempts to turn all targets around you in a radius of %d to stone for %d turns.  Stoned creatures are unable to act or regen life and are very brittle.
		If a stoned creature is hit by an attack that deals more than 30%% of its life it will shattered and be destroyed.
		Stoned creatures are highly resistant to fire and lightning and somewhat resistant to physical attacks.
		The duration will scale with your Paradox.]]):format(radius, duration)
	end,
}

newTalent{
	name = "Quantum Spike",
	type = {"chronomancy/matter", 4},
	require = chrono_req4,
	points = 5,
	paradox = 20,
	cooldown = 12,
	tactical = { ATTACK = 2 },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.MATTER, self:spellCrit(t.getDamage(self,t)))
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
		The damage will scale with your Paradox and the Magic stat.]]):format(damDesc(self, DamageType.TEMPORAL, damage/2), damDesc(self, DamageType.PHYSICAL, damage/2))
	end,
}

