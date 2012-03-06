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
	name = "Blood Red Moon",
	type = {"celestial/eclipse", 1},
	mode = "passive",
	require = divi_req1,
	points = 5,
	on_learn = function(self, t)
		self.combat_spellcrit = self.combat_spellcrit + 3
	end,
	on_unlearn = function(self, t)
		self.combat_spellcrit = self.combat_spellcrit - 3
	end,
	info = function(self, t)
		return ([[Increases your spell critical chance by %d%%.]]):
		format(3 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Totality",
	type = {"celestial/eclipse", 2},
	require = divi_req2,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	positive = 10,
	negative = 10,
	getDuration = function(self, t) return 4 + math.ceil(self:getTalentLevel(t)) end,
	getResistancePenetration = function(self, t) return 5 + (self:getCun() / 10) * self:getTalentLevel(t) end,
	getCooldownReduction = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		self:setEffect(self.EFF_TOTALITY, t.getDuration(self, t), {power=t.getResistancePenetration(self, t)})
		for tid, cd in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[1]:find("^celestial/") then
				self.talents_cd[tid] = cd - t.getCooldownReduction(self, t)
			end
		end
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local penetration = t.getResistancePenetration(self, t)
		local cooldownreduction = t.getCooldownReduction(self, t)
		return ([[Increases your light and darkness resistance penetration by %d%% for %d turns and brings all your celestial talents on cooldown, %d turns closer to being off cooldown.
		The resistance penetration will increase with your Cunning stat.]]):
		format(penetration, duration, cooldownreduction)
	end,
}

newTalent{
	name = "Corona",
	type = {"celestial/eclipse", 3},
	mode = "sustained",
	require = divi_req3,
	points = 5,
	proj_speed = 3,
	range = 6,
	cooldown = 30,
	tactical = { BUFF = 2 },
	sustain_negative = 10,
	sustain_positive = 10,
	getTargetCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	getLightDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 70) end,
	getDarknessDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 70) end,
	on_crit = function(self, t)
		if self:getPositive() < 2 or self:getNegative() < 2 then
		--	self:forceUseTalent(t.id, {ignore_energy=true})
			return nil
		end
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

		local corona = rng.range(1, 100)
			if corona > 50 then
				local tg = {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, display={particle="bolt_light"}}
				self:projectile(tg, a.x, a.y, DamageType.LIGHT, t.getLightDamage(self, t), {type="light"})
				self:incPositive(-2)
			else
				local tg = {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, display={particle="bolt_dark"}}
				self:projectile(tg, a.x, a.y, DamageType.DARKNESS, t.getDarknessDamage(self, t), {type="shadow"})
				self:incNegative(-2)
			end
		end
	end,
	activate = function(self, t)
		local ret = {
		}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local targetcount = t.getTargetCount(self, t)
		local lightdamage = t.getLightDamage(self, t)
		local darknessdamage = t.getDarknessDamage(self, t)
		return ([[Each time one of your spells is a critical you project a bolt of light or shadow at %d targets in a radius of 10, doing %0.2f light damage or %0.2f darkness damage.
		This effect costs 2 positive or 2 negative energy each time it's triggered and will not trigger if either your positive or negative energy is below 2.
		The damage scales with the Magic stat.]]):
		format(targetcount, damDesc(self, DamageType.LIGHT, lightdamage), damDesc(self, DamageType.DARKNESS, darknessdamage))
	end,
}

newTalent{
	name = "Darkest Light",
	type = {"celestial/eclipse", 4},
	mode = "sustained",
	require = divi_req4,
	points = 5,
	cooldown = 30,
	sustain_negative = 10,
	tactical = { DEFEND = 2, ESCAPE = 2 },
	getInvisibilityPower = function(self, t) return 5 + (self:getCun() / 15) * self:getTalentLevel(t) end,
	getEnergyConvert = function(self, t) return math.max(0, 6 - self:getTalentLevelRaw(t)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) end,
	getRadius = function(self, t) return 2 + self:getTalentLevel(t) / 2 end,
	activate = function(self, t)
		local timer = t.getEnergyConvert(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {
			invisible = self:addTemporaryValue("invisible", t.getInvisibilityPower(self, t)),
			invisible_damage_penalty = self:addTemporaryValue("invisible_damage_penalty", 0.5),
			fill = self:addTemporaryValue("positive_regen", timer),
			drain = self:addTemporaryValue("negative_regen", - timer),
		}
		self:resetCanSeeCacheOf()
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("invisible", p.invisible)
		self:removeTemporaryValue("invisible_damage_penalty", p.invisible_damage_penalty)
		self:removeTemporaryValue("positive_regen", p.fill)
		self:removeTemporaryValue("negative_regen", p.drain)
		local tg = {type="ball", range=0, selffire=true, radius= t.getRadius(self, t), talent=t}
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		tg.selffire = false
		local grids = self:project(tg, self.x, self.y, DamageType.LIGHT, self:spellCrit(t.getDamage(self, t) + self.positive))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y, max_alpha=80})
		game:playSoundNear(self, "talents/flame")
		self.positive = 0
		self:resetCanSeeCacheOf()
		return true
	end,
	info = function(self, t)
		local invisibilitypower = t.getInvisibilityPower(self, t)
		local convert = t.getEnergyConvert(self, t)
		local damage = t.getDamage(self, t)
		local radius = t.getRadius(self, t)
		return ([[This powerful spell grants you %d bonus invisibility, but converts %d negative energy into positive energy each turn.  Once your positive energy exceeds your negative energy, or you deactivate the talent, the effect ends in an explosion of light, converting all of your positive energy into damage and inflicting an additional %0.2f damage on everything in a radius of %d.
		As you become invisible you fade out of phase with reality, all your damage is reduced by 50%%.
		You may not cast Twilight while this spell is active and you should take off your light source otherwise you will still easily be spotted.
		The invisibility bonus will increase with your Cunning stat and the explosion damage will increase with the Magic Stat..]]):
		format(invisibilitypower, convert, damDesc(self, DamageType.LIGHT, damage), radius)
	end,
}
