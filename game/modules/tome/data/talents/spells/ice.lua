-- ToME - Tales of Middle-Earth
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
	name = "Ice Shards",
	type = {"spell/ice",1},
	require = spells_req1,
	points = 5,
	mana = 12,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	reflectable = true,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=1, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ICE, self:spellCrit(self:combatTalentSpellDamage(t, 18, 200)))
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "ice_shards", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a bolt of fire, setting the target ablaze and doing %0.2f fire damage over 3 turns.
		The damage will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 25, 200))
	end,
}

newTalent{
	name = "Frozen Ground",
	type = {"spell/ice",2},
	require = spells_req2,
	points = 5,
	mana = 12,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	reflectable = true,
	action = function(self, t)
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a bolt of fire, setting the target ablaze and doing %0.2f fire damage over 3 turns.
		The damage will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 25, 290))
	end,
}

newTalent{
	name = "Shatter",
	type = {"spell/ice",3},
	require = spells_req3,
	points = 5,
	mana = 12,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	reflectable = true,
	action = function(self, t)
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a bolt of fire, setting the target ablaze and doing %0.2f fire damage over 3 turns.
		The damage will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 25, 290))
	end,
}

newTalent{
	name = "Uttercold",
	type = {"spell/ice",4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 80,
	cooldown = 30,
	activate = function(self, t)
		game:playSoundNear(self, "talents/ice")
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.COLD] = self:getTalentLevelRaw(t) * 2}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.COLD] = self:getTalentLevelRaw(t) * 10}),
			particle = self:addParticles(Particles.new("uttercold", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		return true
	end,
	info = function(self, t)
		return ([[Surround yourself with Wildfire, increasing all your fire damage by %d%% and ignoring %d%% fire resistance of your targets.]])
		:format(self:getTalentLevelRaw(t) * 2, self:getTalentLevelRaw(t) * 10)
	end,
}
