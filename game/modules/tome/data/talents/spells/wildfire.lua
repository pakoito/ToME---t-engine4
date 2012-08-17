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
	name = "Blastwave",
	type = {"spell/wildfire",1},
	require = spells_req_high1,
	points = 5,
	mana = 12,
	cooldown = 5,
	tactical = { ATTACKAREA = { FIRE = 2 }, DISABLE = { knockback = 2 }, ESCAPE = { knockback = 2 },
		CURE = function(self, t, target)
			if self:attr("burning_wake") and self:attr("cleansing_flame") then
				return 1
			end
	end },
	direct_hit = true,
	requires_target = true,
	range = 0,
	radius = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 180) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.FIREKNOCKBACK, {dist=3, dam=self:spellCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_fire", {radius=tg.radius})
		if self:attr("burning_wake") then
			game.level.map:addEffect(self,
				self.x, self.y, 4,
				DamageType.INFERNO, self:attr("burning_wake"),
				tg.radius,
				5, nil,
				{type="inferno"},
				nil, self:spellFriendlyFire()
			)
		end
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[A wave of fire emanates from you with radius %d, knocking back anything caught inside and setting them ablaze and doing %0.2f fire damage over 3 turns.
		The damage will increase with your Spellpower.]]):format(radius, damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Burning Wake",
	type = {"spell/wildfire",2},
	require = spells_req_high2,
	mode = "sustained",
	points = 5,
	sustain_mana = 40,
	cooldown = 30,
	tactical = { BUFF=2, ATTACKAREA = { FIRE = 1 } },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 55) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		local cft = self:getTalentFromId(self.T_CLEANSING_FLAMES)
		return {
			bw = self:addTemporaryValue("burning_wake", t.getDamage(self, t)),
			cf = self:addTemporaryValue("cleansing_flames", cft.getChance(self, cft)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("burning_wake", p.bw)
		self:removeTemporaryValue("cleansing_flames", p.cf)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Your Flame, Flameshock, Fireflash and Blastwave spells leave a burning wake on the ground, burning all for %0.2f fire damage for 4 turns.
		The damage will increase with your Spellpower.]]):format(damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Cleansing Flames",
	type = {"spell/wildfire",3},
	require = spells_req_high3,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return self:getTalentLevelRaw(t) * 10 end,
	info = function(self, t)
		return ([[When your Burning Wake talent is active, your inferno and burning wake effects have %d%% chance each turn to remove a status effect(physical, magical, curse or hex) from the targets.
		If the target is hostile it will remove a beneficial effect.
		If the target is friendly it will remove a detrimental effect (but still burn).]]):format(t.getChance(self, t))
	end,
}

newTalent{
	name = "Wildfire",
	type = {"spell/wildfire",4},
	require = spells_req_high4,
	points = 5,
	mode = "sustained",
	sustain_mana = 50,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getFireDamageIncrease = function(self, t) return self:getTalentLevelRaw(t) * 2 end,
	getResistPenalty = function(self, t) return self:getTalentLevelRaw(t) * 10 end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")

		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {radius=1.1}, {type="flames", hide_center=0, xy={self.x, self.y}}))
		else
			particle = self:addParticles(Particles.new("wildfire", 1))
		end
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.FIRE] = t.getFireDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.FIRE] = t.getResistPenalty(self, t)}),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		return true
	end,
	info = function(self, t)
		local damageinc = t.getFireDamageIncrease(self, t)
		local ressistpen = t.getResistPenalty(self, t)
		return ([[Surround yourself with Wildfire, increasing all your fire damage by %d%% and ignoring %d%% fire resistance of your targets.]])
		:format(damageinc, ressistpen)
	end,
}
