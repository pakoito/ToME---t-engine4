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
	name = "Congeal Time",
	type = {"spell/temporal",1},
	require = spells_req1,
	points = 5,
	random_ego = "utility",
	mana = 20,
	cooldown = 30,
	tactical = { DISABLE = 2 },
	reflectable = true,
	proj_speed = 2,
	range = 6,
	direct_hit = true,
	requires_target = true,
	getSlow = function(self, t) return self:getTalentLevel(t) * 0.08 end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t, display={particle="bolt_arcane"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.SLOW, 1 - 1 / (1 + t.getSlow(self, t)), {type="manathrust"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local slow = t.getSlow(self, t)
		return ([[Project a bolt of time distortion, decreasing the target's global speed by %d%% for 7 turns.]]):
		format(100 * slow)
	end,
}

newTalent{
	name = "Time Shield",
	type = {"spell/temporal", 2},
	require = spells_req2,
	points = 5,
	mana = 50,
	cooldown = 30,
	tactical = { DEFEND = 2 },
	range = 10,
	getMaxAbsorb = function(self, t) return 50 + self:combatTalentSpellDamage(t, 50, 350) end,
	getDuration = function(self, t) return util.bound(5 + math.floor(self:getTalentLevel(t)), 5, 15) end,
	action = function(self, t)
		self:setEffect(self.EFF_TIME_SHIELD, t.getDuration(self, t), {power=t.getMaxAbsorb(self, t)})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local maxabsorb = t.getMaxAbsorb(self, t)
		local duration = t.getDuration(self, t)
		return ([[This intricate spell erects a time shield around the caster, preventing any incoming damage and sending it forward in time.
		Once either the maximum damage (%d) is absorbed, or the time runs out (%d turns), the stored damage will return as self-damage over time (5 turns).
		Max absorption will increase with the Magic stat]]):
		format(maxabsorb, duration)
	end,
}

newTalent{
	name = "Time Prison",
	type = {"spell/temporal", 3},
	require = spells_req3,
	points = 5,
	random_ego = "utility",
	mana = 140,
	cooldown = 40,
	tactical = { DISABLE = 1, ESCAPE = 3, PROTECT = 3 },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDuration = function(self, t) return 4 + self:combatSpellpower(0.03) * self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.TIME_PRISON, t.getDuration(self, t), {type="manathrust"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Removes the target from the flow of time for %d turns. In this state the target can neither act nor be harmed.
		The duration will increase with the Magic stat]]):
		format(duration)
	end,
}

newTalent{
	name = "Essence of Speed",
	type = {"spell/temporal",4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 250,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getHaste = function(self, t) return self:getTalentLevel(t) * 0.07 end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local power = 1 - 1 / (1 + t.getHaste(self, t))
		return {
			speed = self:addTemporaryValue("energy", {mod=power}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("energy", p.speed)
		return true
	end,
	info = function(self, t)
		local haste = t.getHaste(self, t)
		return ([[Increases the caster's global speed by %d%%.]]):
		format(100 * haste)
	end,
}

