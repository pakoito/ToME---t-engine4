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
	getSlow = function(self, t) return math.min(self:getTalentLevel(t) * 0.08, 0.6) end,
	getProj = function(self, t) return math.min(90, 5 + self:combatTalentSpellDamage(t, 5, 700) / 10) end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t, display={particle="bolt_arcane"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.CONGEAL_TIME, {
			slow = 1 - 1 / (1 + t.getSlow(self, t)),
			proj = t.getProj(self, t),
		}, {type="manathrust"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local slow = t.getSlow(self, t)
		local proj = t.getProj(self, t)
		return ([[Project a bolt of time distortion, decreasing the target's global speed by %d%% and all projectiles it fires by %d%% for 7 turns.]]):
		format(100 * slow, proj)
	end,
}

newTalent{
	name = "Time Shield",
	type = {"spell/temporal", 2},
	require = spells_req2,
	points = 5,
	mana = 50,
	cooldown = 18,
	tactical = { DEFEND = 2 },
	range = 10,
	no_energy = true,
	getMaxAbsorb = function(self, t) return 50 + self:combatTalentSpellDamage(t, 50, 450) end,
	getDuration = function(self, t) return util.bound(5 + math.floor(self:getTalentLevel(t)), 5, 15) end,
	getDotDuration = function(self, t) return util.bound(4 + math.floor(self:getTalentLevel(t)), 4, 12) end,
	getTimeReduction = function(self, t) return util.bound(15 + math.floor(self:getTalentLevel(t) * 2), 15, 35) end,
	action = function(self, t)
		self:setEffect(self.EFF_TIME_SHIELD, t.getDuration(self, t), {power=t.getMaxAbsorb(self, t), dot_dur=t.getDotDuration(self, t), time_reducer=t.getTimeReduction(self, t)})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local maxabsorb = t.getMaxAbsorb(self, t)
		local duration = t.getDuration(self, t)
		local dotdur = t.getDotDuration(self,t)
		local time_reduc = t.getTimeReduction(self,t)
		return ([[This intricate spell instantly erects a time shield around the caster, preventing any incoming damage and sending it forward in time.
		Once either the maximum damage (%d) is absorbed, or the time runs out (%d turns), the stored damage will return as a temporal wake over time (%d turns).
		Each turn the temporal wake is active a temporal vortex will spawn at your feet, damaging any inside after one turn for three turns.
		While under the effect of Time Shield all newly applied magical, physical and mental effects will have their durations reduced by %d%%.
		Max absorption will increase with your Spellpower.]]):
		format(maxabsorb, duration, dotdur, time_reduc)
	end,
}

newTalent{
	name = "Time Prison",
	type = {"spell/temporal", 3},
	require = spells_req3,
	points = 5,
	random_ego = "utility",
	mana = 120,
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
		Time does not pass at all for the target, no talents will cooldown, no resources will regen, ...
		The duration will increase with your Spellpower.]]):
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
	getHaste = function(self, t) return self:getTalentLevel(t) * 0.09 end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local power = t.getHaste(self, t)
		return {
			speed = self:addTemporaryValue("global_speed_add", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("global_speed_add", p.speed)
		return true
	end,
	info = function(self, t)
		local haste = t.getHaste(self, t)
		return ([[Increases the caster's global speed by %d%%.]]):
		format(100 * haste)
	end,
}
