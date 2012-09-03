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
	name = "Sleep",
	type = {"psionic/dreaming", 1},
	points = 5, 
	require = psi_wil_req1,
	cooldown = function(self, t) return math.max(4, 9 - self:getTalentLevelRaw(t)) end,
	psi = 5,
	tactical = { DISABLE = {sleep = 1} },
	direct_hit = true,
	requires_target = true,
	range = 7,
	radius = function(self, t) return 1 + math.floor(self:getTalentLevel(t)/4) end,
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)/3) end,
	getInsomniaPower= function(self, t)
		local t = self:getTalentFromId(self.T_SANDMAN)
		local reduction = t.getInsomniaPower(self, t)
		return 20 - reduction
	end,
	getSleepPower = function(self, t) 
		local power = self:combatTalentMindDamage(t, 5, 25)
		if self:knowTalent(self.T_SANDMAN) then
			local t = self:getTalentFromId(self.T_SANDMAN)
			power = power * t.getSleepPowerBonus(self, t)
		end
		return math.ceil(power)
	end,
	doContagiousSleep = function(self, target, p, t)
		local tg = {type="ball", radius=1, talent=t}
		self:project(tg, target.x, target.y, function(tx, ty)
			local t2 = game.level.map(tx, ty, Map.ACTOR)
			if t2 and t2 ~= target and rng.percent(p.contagious) and t2:canBe("sleep") and not t2:hasEffect(t2.EFF_SLEEP) then
				t2:setEffect(t2.EFF_SLEEP, p.dur, {src=self, power=p.power, waking=p.waking, insomnia=p.insomnia, no_ct_effect=true, apply_power=self:combatMindpower()})
				game.level.map:particleEmitter(target.x, target.y, 1, "generic_charge", {rm=0, rM=0, gm=100, gM=200, bm=200, bM=255, am=35, aM=90})
			end
		end)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		--Contagious?
		local is_contagious = 0
		if self:getTalentLevel(t) >= 5 then
			is_contagious = 25
		end
		--Restless?
		local is_waking =0
		if self:knowTalent(self.T_RESTLESS_NIGHT) then
			local t = self:getTalentFromId(self.T_RESTLESS_NIGHT)
			is_waking = t.getDamage(self, t)
		end

		local power = self:mindCrit(t.getSleepPower(self, t))
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target then
				if target:canBe("sleep") then
					target:setEffect(target.EFF_SLEEP, t.getDuration(self, t), {src=self, power=power,  contagious=is_contagious, waking=is_waking, insomnia=t.getInsomniaPower(self, t), no_ct_effect=true, apply_power=self:combatMindpower()})
					game.level.map:particleEmitter(target.x, target.y, 1, "generic_charge", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
				else
					game.logSeen(self, "%s resists the sleep!", target.name:capitalize())
				end
			end
		end)
		game:playSoundNear(self, "talents/dispel")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		local power = t.getSleepPower(self, t)
		local insomnia = t.getInsomniaPower(self, t)
		return([[Puts targets in a radius of %d to sleep for %d turns, rendering them unable to act.  Every %d points of damage the target suffers will reduce the effect duration by one turn.
		When Sleep ends the target will suffer from Insomnia for a number of turns equal to the amount of time it was asleep (up to ten turns max), granting it %d%% sleep immunity for each turn of the Insomnia effect.
		At talent level 5 Sleep will become contagious and has a 25%% chance to spread to nearby targets each turn.
		The damage threshold will scale with your mindpower.]]):format(radius, duration, power, insomnia)
	end,
}

newTalent{
	name = "Lucid Dreamer",
	type = {"psionic/dreaming", 2},
	points = 5,
	require = psi_wil_req2,
	mode = "sustained",
	sustain_psi = 20,
	cooldown = 12,
	tactical = { BUFF=2 },
	getPower = function(self, t) return self:combatTalentMindDamage(t, 5, 25) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local power = t.getPower(self, t)
		local ret = {
			phys = self:addTemporaryValue("combat_physresist", power),
			mental = self:addTemporaryValue("combat_mentalresist", power),
			spell = self:addTemporaryValue("combat_spellresist", power),
			dreamer = self:addTemporaryValue("lucid_dreamer", power),
			sleep = self:addTemporaryValue("sleep", 1),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physresist", p.phys)
		self:removeTemporaryValue("combat_mentalresist", p.mental)
		self:removeTemporaryValue("combat_spellresist", p.spell)
		self:removeTemporaryValue("lucid_dreamer", p.dreamer)
		self:removeTemporaryValue("sleep", p.sleep)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[Slip into a lucid dream.  While in this state you are considered sleeping but can still act, are immune to insomnia, inflict %d%% more damage to targets under the effects of Insomnia, and your physical, mental, and spell saves are increased by %d.
		Note that being asleep may make you more vulnerable to certain effects (such as Inner Demons, Night Terror, and Waking Nightmare).
		The saving throw bonuses scale with your mindpower.]]):format(power, power)
	end,
}

newTalent{
	name = "Dream Walk",
	type = {"psionic/dreaming", 3},
	points = 5, 
	require = psi_wil_req3,
	psi= 10,
	cooldown = 10,
	tactical = { ESCAPE = 1, CLOSEIN = 1 },
	range = 7,
	radius = function(self, t) return math.max(0, 7 - math.floor(self:getTalentLevel(t))) end,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t)}
	end,
	direct_hit = true,
	is_teleport = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			game.logPlayer(self, "You do not have line of sight to this location.")
			return nil
		end
		local __, x, y = self:canProject(tg, x, y)
		local teleport = self:getTalentRadius(t)
		target = game.level.map(x, y, Map.ACTOR)
		if (target and target:attr("sleep")) or game.zone.is_dream_scape then
			teleport = 0
		end
		
		game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})

		-- since we're using a precise teleport we'll look for a free grid first
		local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		if tx and ty then
			if not self:teleportRandom(tx, ty, teleport) then
				game.logSeen(self, "The dream walk fizzles!")
			end
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
		game:playSoundNear(self, "talents/teleport")

		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[You move through the dream world, reappearing near the target location (%d teleport accuracy).  If the target is a sleeping creature you'll instead appear as close to them as possible.]]):format(radius)
	end,
}

newTalent{
	name = "Dream Prison",
	type = {"psionic/dreaming", 4},
	points = 5,
	require = psi_wil_req4,
	mode = "sustained",
	sustain_psi = 40,
	cooldown = function(self, t) return 50 - self:getTalentLevelRaw(t) * 5 end,
	tactical = { DISABLE = function(self, t, target) if target and target:attr("sleep") then return 4 else return 0 end end},
	range = 7,
	requires_target = true,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRange(t), range=0}
	end,
	direct_hit = true,
	getDrain = function(self, t) return 5 - math.min(4, self:getTalentLevel(t)/2) end,
	remove_on_zero = true,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local drain = self:getMaxPsi() * t.getDrain(self, t) / 100
		local ret = {
			drain = self:addTemporaryValue("psi_regen", -drain),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("psi_regen", p.drain)
		return true
	end,
	info = function(self, t)
		local drain = t.getDrain(self, t)
		return ([[Imprisons all sleeping targets within range in their dream state, effectively extending sleeping effects for as long as Dream Prison is maintainted.
		This powerful effect constantly drains %0.2f%% of your maximum Psi per turn and is considered a psionic channel as such it will break if you move, use a talent that consumes a turn, or activate an item.
		(Note that sleeping effects that happen each turn, such as Nightmare's damage and Sleep's contagion, will cease to function for the duration of the effect.)]]):format(drain)
	end,
}