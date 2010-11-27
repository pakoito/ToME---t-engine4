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
	name = "Shield of Light",
	type = {"divine/guardian", 1},
	mode = "sustained",
	require = divi_req_high1,
	points = 5,
	cooldown = 10,
	sustain_positive = 10,
	tactical = {
		BUFF = 10,
	},
	range = 20,
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Shield of Light without a shield!")
			return nil
		end

		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
		}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Infuse your shield with light energy, healing you for %0.2f each time you take damage.
		Each heal will drain 3 positive energy. The spell ends when energy reaches 0.
		The healing done will increase with the Magic stat]]):format(self:combatTalentSpellDamage(self.T_SHIELD_OF_LIGHT, 1, 25))
	end,
}

newTalent{
	name = "Brandish",
	type = {"divine/guardian", 2},
	require = divi_req_high2,
	points = 5,
	cooldown = 8,
	positive = 20,
	requires_target = true,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Brandish without a shield!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end

		-- First attack with weapon
		self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3), true)
		-- Second attack with shield
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))

		-- Light Burst
		if hit then
			local tg = {type="ball", range=1, friendlyfire=true, radius=2 + self:getTalentLevel(t) / 2, talent=t}
			self:project(tg, x, y, DamageType.LITE, 1)
			tg.friendlyfire = false
			local grids = self:project(tg, self.x, self.y, DamageType.LIGHT, self:combatTalentSpellDamage(t, 20, 150))
			game.level.map:particleEmitter(x, y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
			game:playSoundNear(self, "talents/flame")
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon and a shield strike doing %d%% damage.  If the shield strike hits your shield will explode in a burst of light, inflicting %0.2f light damage on all within a radius of %d of the target, lighting up the affected grids.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.3, self:getTalentLevel(self.T_SHIELD_EXPERTISE)), damDesc(self, DamageType.LIGHT, self:combatTalentSpellDamage(t, 20, 150)), 2 + self:getTalentLevel(t) / 2)
	end,
}

newTalent{
	name = "Retribution",
	type = {"divine/guardian", 3},
	require = divi_req_high3, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_positive = 20,
	cooldown = 10,
	range = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Retribution without a shield!")
			return nil
		end
		local power = self:combatTalentSpellDamage(t, 28, 170)
		self.retribution_absorb = power
		self.retribution_strike = power
		game:playSoundNear(self, "talents/generic")
		return {
			shield = self:addTemporaryValue("retribution", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("retribution", p.shield)
		self.retribution_absorb = nil
		self.retribution_strike = nil
		return true
	end,
	info = function(self, t)
		return ([[You start absorbing half of all damage you take into your shield.  Once you're shield has absorbed %0.2f damage it will explode in a burst of light, inflicting damage in a radius of %d.
		The amount absorbed will increase with the Magic stat.]]):format(damDesc(self, DamageType.LIGHT, self:combatTalentSpellDamage(t, 28, 170)), 1 + self:getTalentLevelRaw(t))
	end,
}




newTalent{
	name = "Second Life",
	type = {"divine/guardian", 4},
	require = divi_req_high4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_positive = 60,
	cooldown = 50,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[Any attack that would drop you below 1 hit point triggers Second Life, deactivating the talent and setting your hit points to %d.]]):format(self.max_life * (0.05 + self:getTalentLevel(self.T_SECOND_LIFE)/25))
	end,
}

