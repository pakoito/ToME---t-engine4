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

uberTalent{
	name = "Fast As Lightning",
	mode = "passive",
	trigger = function(self, t, ox, oy)
		local dx, dy = (self.x - ox), (self.y - oy)
		if dx ~= 0 then dx = dx / math.abs(dx) end
		if dy ~= 0 then dy = dy / math.abs(dy) end
		local dir = util.coordToDir(dx, dy, 0)

		local eff = self:hasEffect(self.EFF_FAST_AS_LIGHTNING)
		if eff and eff.blink then
			if eff.dir ~= dir then
				self:removeEffect(self.EFF_FAST_AS_LIGHTNING)
			else
				return
			end
		end

		self:setEffect(self.EFF_FAST_AS_LIGHTNING, 1, {})
		eff = self:hasEffect(self.EFF_FAST_AS_LIGHTNING)

		if not eff.dir then eff.dir = dir eff.nb = 0 end

		if eff.dir ~= dir then
			self:removeEffect(self.EFF_FAST_AS_LIGHTNING)
			self:setEffect(self.EFF_FAST_AS_LIGHTNING, 1, {})
			eff = self:hasEffect(self.EFF_FAST_AS_LIGHTNING)
			eff.dir = dir eff.nb = 0
			game.logSeen(self, "#LIGHT_BLUE#%s slows from critical velocity!", self.name:capitalize())
		end

		eff.nb = eff.nb + 1

		if eff.nb >= 3 and not eff.blink then
			self:effectTemporaryValue(eff, "prob_travel", 5)
			game.logSeen(self, "#LIGHT_BLUE#%s reaches critical velocity!", self.name:capitalize())
			local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
			game.flyers:add(sx, sy, 30, rng.float(-3, -2), (rng.range(0,2)-1) * 0.5, "CRITICAL VELOCITY!", {0,128,255})
			eff.particle = self:addParticles(Particles.new("megaspeed", 1, {angle=util.dirToAngle((dir == 4 and 6) or (dir == 6 and 4 or dir))}))
			eff.blink = true
			game:playSoundNear(self, "talents/thunderstorm")
		end
	end,
	info = function(self, t)
		return ([[When moving over 800%% speed for at least 3 turns in the same direction you become so fast you can blink throught obstacles as if they were not there.
		Changing direction will break the effect.]])
		:format()
	end,
}

uberTalent{
	name = "Tricky Defenses",
	mode = "passive",
	require = { special={desc="Antimagic", fct=function(self) return self:knowTalentType("wild-gift/antimagic") end} },
	info = function(self, t)
		return ([[You are full of tricks and surprises, your Antimagic Shield can absorb %d%% more damage.
		The increase scales with Cunning.]])
		:format(self:getCun() / 2)
	end,
}

uberTalent{
	name = "Endless Woes",
	mode = "passive",
	trigger = function(self, t, target, damtype, dam)
		if dam < 100 then return end
		if damtype == DamageType.ACID and rng.percent(15) then
			target:setEffect(target.EFF_ACID_SPLASH, 5, {src=self, dam=(dam * self:getCun() / 2.5) / 100 / 5, atk=self:getCun() / 2, apply_power=self:combatSpellpower()})
		elseif damtype == DamageType.BLIGHT and target:canBe("disease") and rng.percent(10) then
			local diseases = {{self.EFF_WEAKNESS_DISEASE, "str"}, {self.EFF_ROTTING_DISEASE, "con"}, {self.EFF_DECREPITUDE_DISEASE, "dex"}}
			local disease = rng.table(diseases)
			target:setEffect(disease[1], 5, {src=self, dam=(dam * self:getCun() / 2.5) / 100 / 5, [disease[2]]=self:getCun() / 3, apply_power=self:combatSpellpower()})
		elseif damtype == DamageType.DARKNESS and target:canBe("blind") and rng.percent(15) then
			target:setEffect(target.EFF_BLINDED, 5, {apply_power=self:combatSpellpower()})
		end
	end,
	info = function(self, t)
		return ([[Surround yourself with a malovelant aura.
		Any acid damage you do has 15%% chances to apply lasting acid that deals %d%% of the initial damage for 5 turns and reduces accuracy by %d.
		Any blight damage you do has 10%% chances to cause a random disease that deals %d%% of the initial damage for 5 turns and reducing a stat by %d.
		Any darkness damage you do has 15%% chances to blind the target for 5 turns.
		This only triggers for hits over 100 damage.
		Values increase with Cunning.]])
		:format(self:getCun() / 2.5, self:getCun() / 2, self:getCun() / 2.5, self:getCun() / 2)
	end,
}
