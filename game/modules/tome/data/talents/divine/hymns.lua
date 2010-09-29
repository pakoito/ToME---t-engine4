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

local function cancelHymns(self)
	local hymns = {self.T_HYMN_OF_SHADOWS, self.T_HYMN_OF_DETECTION, self.T_HYMN_OF_PERSEVERANCE, self.T_HYMN_OF_MOONLIGHT}
	for i, t in ipairs(hymns) do
		if self:isTalentActive(t) then
			local old = self.energy.value
			self.energy.value = 100000
			self:useTalent(t)
			self.energy.value = old
		end
	end
end

newTalent{
	name = "Hymn of Shadows",
	type = {"divine/hymns", 1},
	mode = "sustained",
	require = divi_req1,
	points = 5,
	cooldown = 30,
	sustain_negative = 20,
	tactical = {
		BUFF = 10,
	},
	range = 20,
	activate = function(self, t)
		cancelHymns(self)
		local power = self:combatTalentSpellDamage(t, 10, 50)
		local dam = self:combatTalentSpellDamage(t, 5, 25)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.DARKNESS]=dam}),
			phys = self:addTemporaryValue("inc_damage", {[DamageType.DARKNESS] = power}),
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
		return ([[Chant the glory of the moon, granting you %d%% more darkness damage.
		In addition it surrounds you with a shield of shadows, damaging anything that attacks you for %0.2f darkness damage.
		You may only have one Hymn active at once.
		The damage will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 10, 50), damDesc(self, DamageType.DARKNESS, self:combatTalentSpellDamage(t, 5, 25)))
	end,
}

newTalent{
	name = "Hymn of Detection",
	type = {"divine/hymns", 2},
	mode = "sustained",
	require = divi_req2,
	points = 5,
	cooldown = 30,
	sustain_negative = 20,
	tactical = {
		BUFF = 10,
	},
	range = 20,
	activate = function(self, t)
		cancelHymns(self)
		local dam = self:combatTalentSpellDamage(t, 5, 25)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.DARKNESS]=dam}),
			infravision = self:addTemporaryValue("infravision", math.floor(5 + self:getTalentLevel(t))),
			particle = self:addParticles(Particles.new("darkness_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("infravision", p.infravision)
		return true
	end,
	info = function(self, t)
		return ([[Chant the glory of the moon, granting you infravision up to %d grids.
		In addition it surrounds you with a shield of darkness, damaging anything that attacks you for %0.2f darkness damage.
		You may only have one Hymn active at once.
		The resistance and damage will increase with the Magic stat]]):format(math.floor(5 + self:getTalentLevel(t)), damDesc(self, DamageType.DARKNESS, self:combatTalentSpellDamage(t, 5, 25)))
	end,
}

newTalent{
	name = "Hymn of Perseverance",
	type = {"divine/hymns",3},
	mode = "sustained",
	require = divi_req3,
	points = 5,
	cooldown = 30,
	sustain_negative = 20,
	tactical = {
		BUFF = 10,
	},
	range = 20,
	activate = function(self, t)
		cancelHymns(self)
		local dam = self:combatTalentSpellDamage(t, 5, 25)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.DARKNESS]=dam}),
			stun = self:addTemporaryValue("stun_immune", 0.2 + self:getTalentLevel(t) / 10),
			confusion = self:addTemporaryValue("confusion_immune", 0.2 + self:getTalentLevel(t) / 10),
			blind = self:addTemporaryValue("blind_immune", 0.2 + self:getTalentLevel(t) / 10),
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
		return ([[Chant the glory of the moon, granting you %d%% stun, blindness and confusion resistances.
		In addition it surrounds you with a shield of darkness, damaging anything that attacks you for %0.2f light damage.
		You may only have one Hymn active at once.
		The damage will increase with the Magic stat]]):format(100 * (0.2 + self:getTalentLevel(t) / 10), damDesc(self, DamageType.DARKNESS, self:combatTalentSpellDamage(t, 5, 25)))
	end,
}

newTalent{
	name = "Hymn of Moonlight",
	type = {"divine/hymns",4},
	mode = "sustained",
	require = divi_req4,
	points = 5,
	cooldown = 30,
	sustain_negative = 20,
	tactical = {
		BUFF = 10,
	},
	range = 20,
	do_beams = function(self, t)
		if self:getNegative() <= 0 then
			local old = self.energy.value
			self.energy.value = 100000
			self:useTalent(self.T_HYMN_OF_MOONLIGHT)
			self.energy.value = old
			return
		end

		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 5, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, math.floor(self:getTalentLevel(t)) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.DARKNESS, rng.avg(1, self:spellCrit(self:combatTalentSpellDamage(t, 7, 80)), 3))
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(a.x-self.x), math.abs(a.y-self.y)), "shadow_beam", {tx=a.x-self.x, ty=a.y-self.y})
			game:playSoundNear(self, "talents/spell_generic")
		end
	end,
	activate = function(self, t)
		cancelHymns(self)
		game:playSoundNear(self, "talents/spell_generic")
		game.logSeen(self, "#DARK_GREY#A shroud of shadow dances around %s!", self.name)
		return {
			drain = self:addTemporaryValue("negative_regen", -1 * self:getTalentLevelRaw(t)),
		}
	end,
	deactivate = function(self, t, p)
		game.logSeen(self, "#DARK_GREY#The shroud of shadows around %s disappears.", self.name)
		self:removeTemporaryValue("negative_regen", p.drain)
		return true
	end,
	info = function(self, t)
		return ([[Conjures a shroud of dancing shadows with a radius of 5 that follows you as long as this spell is active.
		Each turn a random shadow beam will hit up to %d of your foes for 1 to %0.2f damage.
		This powerful spell will continuously drain negative energy while active.
		The damage will increase with the Magic stat]]):format(self:getTalentLevel(t), damDesc(self, DamageType.DARKNESS, self:combatTalentSpellDamage(t, 7, 80)))
	end,
}
