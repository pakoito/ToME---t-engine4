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
	name = "Blood Spray",
	type = {"corruption/blood", 1},
	require = corrs_req1,
	points = 5,
	cooldown = 7,
	vim = 24,
	tactical = { ATTACKAREA = {BLIGHT = 2} },
	range = 0,
	radius = function(self, t)
		return math.ceil(3 + self:getTalentLevel(t))
	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.CORRUPTED_BLOOD, {
			dam = self:spellCrit(self:combatTalentSpellDamage(t, 10, 190)),
			disease_chance = 20 + self:getTalentLevel(t) * 10,
			disease_dam = self:spellCrit(self:combatTalentSpellDamage(t, 10, 220)) / 6,
			disease_power = self:combatTalentSpellDamage(t, 10, 20),
			dur = 6,
		})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_blood", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[You extract corrupted blood from your own body, hitting everything in a frontal cone of radius %d for %0.2f blight damage.
		Each affected creature has a %d%% chance of being infected by a random disease doing %0.2f blight damage over 6 turns.
		The damage will increase with Magic stat.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 10, 190)), 20 + self:getTalentLevel(t) * 10, damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 10, 220)))
	end,
}

newTalent{
	name = "Blood Grasp",
	type = {"corruption/blood", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 5,
	vim = 20,
	range = 10,
	proj_speed = 20,
	tactical = { ATTACK = {BLIGHT = 2}, HEAL = 2 },
	requires_target = true,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_blood"}}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.DRAINLIFE, {dam=self:spellCrit(self:combatTalentSpellDamage(t, 10, 290)), healfactor=0.5}, {type="blood"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Project a bolt of corrupted blood doing %0.2f blight damage and healing you for half the damage done.
		The damage will increase with Magic stat.]]):format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 10, 290)))
	end,
}

newTalent{
	name = "Blood Boil",
	type = {"corruption/blood", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 12,
	vim = 30,
	tactical = { ATTACKAREA = {BLIGHT = 2}, DISABLE = 2 },
	range = 0,
	radius = function(self, t)
		return 2 + self:getTalentLevelRaw(t)
	end,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.BLOOD_BOIL, self:spellCrit(self:combatTalentSpellDamage(t, 28, 190)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_blood", {radius=tg.radius})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Make the blood of all creatures around you in radius %d boil, doing %0.2f blight damage and slowing them by 20%%.
		The damage will increase with Magic stat.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 28, 190)))
	end,
}

newTalent{
	name = "Blood Fury",
	type = {"corruption/blood", 4},
	mode = "sustained",
	require = corrs_req4,
	points = 5,
	sustain_vim = 60,
	cooldown = 30,
	tactical = { BUFF = 2 },
	on_crit = function(self, t)
		self:setEffect(self.EFF_BLOOD_FURY, 5, {power=self:combatTalentSpellDamage(t, 10, 30)})
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		local ret = {
			per = self:addTemporaryValue("combat_spellcrit", self:combatTalentSpellDamage(t, 10, 14)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_spellcrit", p.per)
		return true
	end,
	info = function(self, t)
		return ([[Concentrate on the corruption you bring, increasing your spell critical chance by %d%%.
		Each time your spells go critical you enter a blood rage for 5 turns, increasing your blight and acid damage by %d%%.
		The damage will increase with your Magic stat.]]):
		format(self:combatTalentSpellDamage(t, 10, 14), self:combatTalentSpellDamage(t, 10, 30))
	end,
}
