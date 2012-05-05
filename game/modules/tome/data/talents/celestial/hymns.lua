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

local function cancelHymns(self)
	local hymns = {self.T_HYMN_OF_SHADOWS, self.T_HYMN_OF_DETECTION, self.T_HYMN_OF_PERSEVERANCE, self.T_HYMN_OF_MOONLIGHT}
	for i, t in ipairs(hymns) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
	end
end

newTalent{
	name = "Hymn of Shadows",
	type = {"celestial/hymns", 1},
	mode = "sustained",
	require = divi_req1,
	points = 5,
	cooldown = 12,
	sustain_negative = 20,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 10,
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	getDarknessDamageIncrease = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	activate = function(self, t)
		cancelHymns(self)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.DARKNESS]= t.getDamageOnMeleeHit(self, t)}),
			phys = self:addTemporaryValue("inc_damage", {[DamageType.DARKNESS] = t.getDarknessDamageIncrease(self, t)}),
			particle = self:addParticles(Particles.new("darkness_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("inc_damage", p.phys)
		return true
	end,
	info = function(self, t)
		local darknessinc = t.getDarknessDamageIncrease(self, t)
		local darknessdamage = t.getDamageOnMeleeHit(self, t)
		return ([[Chant the glory of the moon, granting you %d%% more darkness damage.
		In addition it surrounds you with a shield of shadows, damaging anything that attacks you for %0.2f darkness damage.
		You may only have one Hymn active at once.
		The damage and damage increase will improve with the Magic stat]]):
		format(darknessinc, damDesc(self, DamageType.DARKNESS, darknessdamage))
	end,
}

newTalent{
	name = "Hymn of Detection",
	type = {"celestial/hymns", 2},
	mode = "sustained",
	require = divi_req2,
	points = 5,
	cooldown = 12,
	sustain_negative = 20,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 10,
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	getSeeInvisible = function(self, t) return self:combatTalentSpellDamage(t, 2, 35) end,
	getSeeStealth = function(self, t) return self:combatTalentSpellDamage(t, 2, 15) end,
	getInfraVisionPower = function(self, t) return math.floor(5 + self:getTalentLevel(t)) end,
	activate = function(self, t)
		cancelHymns(self)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.DARKNESS]= t.getDamageOnMeleeHit(self, t)}),
			invis = self:addTemporaryValue("see_invisible", t.getSeeInvisible(self, t)),
			stealth = self:addTemporaryValue("see_stealth", t.getSeeStealth(self, t)),
			infravision = self:addTemporaryValue("infravision", t.getInfraVisionPower(self, t)),
			particle = self:addParticles(Particles.new("darkness_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("infravision", p.infravision)
		self:removeTemporaryValue("see_invisible", p.invis)
		self:removeTemporaryValue("see_stealth", p.stealth)
		return true
	end,
	info = function(self, t)
		local infra = t.getInfraVisionPower(self, t)
		local invis = t.getSeeInvisible(self, t)
		local stealth = t.getSeeStealth(self, t)
		local darknessdamage = t.getDamageOnMeleeHit(self, t)
		return ([[Chant the glory of the moon, granting you infravision up to %d grids, stealth detection (+%d power), invisibility detection (+%d power).
		In addition it surrounds you with a shield of darkness, damaging anything that attacks you for %0.2f darkness damage.
		You may only have one Hymn active at once.
		The damage will increase with the Magic stat]]):
		format(infra, stealth, invis, damDesc(self, DamageType.DARKNESS, darknessdamage))
	end,
}

newTalent{
	name = "Hymn of Perseverance",
	type = {"celestial/hymns",3},
	mode = "sustained",
	require = divi_req3,
	points = 5,
	cooldown = 12,
	sustain_negative = 20,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 10,
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	getImmunities = function(self, t) return 0.15 + self:getTalentLevel(t) / 14 end,
	activate = function(self, t)
		cancelHymns(self)
		local dam = self:combatTalentSpellDamage(t, 5, 25)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.DARKNESS]=t.getDamageOnMeleeHit(self, t)}),
			stun = self:addTemporaryValue("stun_immune", t.getImmunities(self, t)),
			confusion = self:addTemporaryValue("confusion_immune", t.getImmunities(self, t)),
			blind = self:addTemporaryValue("blind_immune", t.getImmunities(self, t)),
			particle = self:addParticles(Particles.new("darkness_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("stun_immune", p.stun)
		self:removeTemporaryValue("confusion_immune", p.confusion)
		self:removeTemporaryValue("blind_immune", p.blind)
		return true
	end,
	info = function(self, t)
		local immunities = t.getImmunities(self, t)
		local darknessdamage = t.getDamageOnMeleeHit(self, t)
		return ([[Chant the glory of the moon, granting you %d%% stun, blindness and confusion resistances.
		In addition it surrounds you with a shield of darkness, damaging anything that attacks you for %0.2f darkness damage.
		You may only have one Hymn active at once.
		The damage will increase with the Magic stat]]):
		format(100 * (immunities), damDesc(self, DamageType.DARKNESS, darknessdamage))
	end,
}

newTalent{
	name = "Hymn of Moonlight",
	type = {"celestial/hymns",4},
	mode = "sustained",
	require = divi_req4,
	points = 5,
	cooldown = 12,
	sustain_negative = 20,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 5,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 7, 80) end,
	getTargetCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	getNegativeDrain = function(self, t) return 9 - self:getTalentLevelRaw(t) end,
	do_beams = function(self, t)
		if self:getNegative() < t.getNegativeDrain(self, t) then return end

		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 5, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		local drain = t.getNegativeDrain(self, t)

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			if self:getNegative() - 1 < drain then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.DARKNESS, rng.avg(1, self:spellCrit(t.getDamage(self, t)), 3))
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(a.x-self.x), math.abs(a.y-self.y)), "shadow_beam", {tx=a.x-self.x, ty=a.y-self.y})
			game:playSoundNear(self, "talents/spell_generic")
			self:incNegative(-drain)
		end
	end,
	activate = function(self, t)
		cancelHymns(self)
		game:playSoundNear(self, "talents/spell_generic")
		game.logSeen(self, "#DARK_GREY#A shroud of shadow dances around %s!", self.name)
		return {
		}
	end,
	deactivate = function(self, t, p)
		game.logSeen(self, "#DARK_GREY#The shroud of shadows around %s disappears.", self.name)
		return true
	end,
	info = function(self, t)
		local targetcount = t.getTargetCount(self, t)
		local damage = t.getDamage(self, t)
		local drain = t.getNegativeDrain(self, t)
		return ([[Conjures a shroud of dancing shadows with a radius of 5 that follows you as long as this spell is active.
		Each turn a random shadow beam will hit up to %d of your foes for 1 to %0.2f damage.
		This powerful spell will drain %d negative energy for each beam, no beam will fire if energy is too low.
		The damage will increase with the Magic stat]]):
		format(targetcount, damDesc(self, DamageType.DARKNESS, damage), drain)
	end,
}
