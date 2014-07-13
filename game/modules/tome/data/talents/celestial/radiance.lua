-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

function radianceRadius(self)
	if self:hasEffect(self.EFF_RADIANCE_DIM) then
		return 1
	else
		return self:getTalentRadius(self:getTalentFromId(self.T_RADIANCE))
	end
end

newTalent{
	name = "Radiance",
	type = {"celestial/radiance", 1},
	mode = "passive",
	require = divi_req1,
	points = 5,
	radius = function(self, t) return self:combatTalentScale(t, 3, 7) end,
	getResist = function(self, t) return self:combatTalentLimit(t, 100, 25, 75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "radiance_aura", radianceRadius(self))
		self:talentTemporaryValue(p, "blind_immune", t.getResist(self, t) / 100)
	end,
	info = function(self, t)
		return ([[You are so infused with sunlight that your body glows permanently in radius %d, even in dark places.
		Your vision adapts to this glow, giving you %d%% blindness resistance.
		The light radius overrides your normal light if it is bigger (it does not stack).
		]]):
		format(radianceRadius(self), t.getResist(self, t))
	end,
}

newTalent{
	name = "Illumination",
	type = {"celestial/radiance", 2},
	require = divi_req2,
	points = 5,
	mode = "passive",
	getPower = function(self, t) return 15 + self:combatTalentSpellDamage(t, 1, 100) end,
	getDef = function(self, t) return 5 + self:combatTalentSpellDamage(t, 1, 35) end,
	callbackOnActBase = function(self, t)
		local radius = radianceRadius(self)
		local grids = core.fov.circle_grids(self.x, self.y, radius, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do local target = game.level.map(x, y, Map.ACTOR) if target and self ~= target then
			if (self:reactionToward(target) < 0) then
				target:setEffect(target.EFF_ILLUMINATION, 1, {power=t.getPower(self, t), def=t.getDef(self, t)})
				local ss = self:isTalentActive(self.T_SEARING_SIGHT)
				if ss then
					local dist = core.fov.distance(self.x, self.y, target.x, target.y) - 1
					local coeff = math.max(0.1, 1 - (0.1*dist)) -- 10% less damage per distance
					DamageType:get(DamageType.LIGHT).projector(self, target.x, target.y, DamageType.LIGHT, ss.dam * coeff)
					if ss.daze and rng.percent(ss.daze) and target:canBe("stun") then
						target:setEffect(target.EFF_DAZED, 3, {apply_power=self:combatSpellpower()})
					end
				end
		end
		end end end		
	end,
	info = function(self, t)
		return ([[The light of your Radiance allows you to see that which would normally be unseen.
		All enemies in your Radiance aura have their invisibility and stealth power reduced by %d.
		In addition, all actors affected by illumination are easier to see and therefore hit; their defense is reduced by %d and all evasion bonuses from being unseen are negated.
		The effects increase with your Spellpower.]]):
		format(t.getPower(self, t), t.getDef(self, t))
	end,
}

-- This doesn't work well in practice.. Its powerful but it leads to cheesy gameplay, spams combat logs, maybe even lags
-- It can stay like this for now but may be worth making better
newTalent{
	name = "Searing Sight",
	type = {"celestial/radiance",3},
	require = divi_req3,
	mode = "sustained",
	points = 5,
	cooldown = 15,
	range = function(self) return radianceRadius(self) end,
	tactical = { ATTACKAREA = {LIGHT=1} },
	sustain_positive = 10,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 35) end,
	getDaze = function(self, t) return self:combatTalentLimit(t, 35, 5, 20) end,
	updateParticle = function(self, t)
		local p = self:isTalentActive(self.T_SEARING_SIGHT)
		if not p then return end
		self:removeParticles(p.particle)
		p.particle = self:addParticles(Particles.new("circle", 1, {toback=true, oversize=1, a=20, appear=4, speed=-0.2, img="radiance_circle", radius=self:getTalentRange(t)}))
	end,
	activate = function(self, t)
		local daze = nil
		if self:getTalentLevel(t) >= 4 then daze = t.getDaze(self, t) end
		return {
			particle = self:addParticles(Particles.new("circle", 1, {toback=true, oversize=1, a=20, appear=4, speed=-0.2, img="radiance_circle", radius=self:getTalentRange(t)})),
			dam=t.getDamage(self, t),
			daze=daze,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[Your Radiance is so powerful it burns all foes caught in it, doing up to %0.1f light damage (reduced with distance) to all foes caught inside.
		At level 4 the light is so bright it has %d%% chance to daze them for 3 turns.
		The damage increases with your Spellpower.]]):
		format(damDesc(self, DamageType.LIGHT, t.getDamage(self, t)), t.getDaze(self, t))
	end,
}

newTalent{
	name = "Judgement",
	type = {"celestial/radiance", 4},
	require = divi_req4,
	points = 5,
	cooldown = 25,
	positive = 20,
	tactical = { ATTACKAREA = {LIGHT = 2} },
	radius = function(self) return radianceRadius(self) end,
	range = function(self) return radianceRadius(self) end,
	getMoveDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 40) end,
	getExplosionDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 150) end,
	action = function(self, t)

		local tg = {type="ball", range=self:getTalentRange(t), radius = self:getTalentRadius(t), selffire = false, friendlyfire = false, talent=t}

		local movedam = self:spellCrit(t.getMoveDamage(self, t))
		local dam = self:spellCrit(t.getExplosionDamage(self, t))

		self:project(tg, self.x, self.y, function(tx, ty)
			local target = game.level.map(tx, ty, engine.Map.ACTOR)
			if not target then return end

			local proj = require("mod.class.Projectile"):makeHoming(
				self,
				{particle="bolt_light", trail="lighttrail"},
				{speed=1, name="Judgement", dam=dam, movedam=movedam},
				target,
				self:getTalentRange(t),
				function(self, src)
					local DT = require("engine.DamageType")
					DT:get(DT.JUDGEMENT).projector(src, self.x, self.y, DT.JUDGEMENT, self.def.movedam)
				end,
				function(self, src, target)
					local DT = require("engine.DamageType")
					local grids = src:project({type="ball", radius=1, x=self.x, y=self.y}, self.x, self.y, DT.JUDGEMENT, self.def.dam)
					game.level.map:particleEmitter(self.x, self.y, 1, "sunburst", {radius=1, grids=grids, tx=self.x, ty=self.y})
					game:playSoundNear(self, "talents/lightning")
				end
			)
			game.zone:addEntity(game.level, proj, "projectile", self.x, self.y)
		end)
		
		-- EFF_RADIANCE_DIM does nothing by itself its just used by radianceRadius
		self:setEffect(self.EFF_RADIANCE_DIM, 5, {})

		return true
	end,
	info = function(self, t)
		return ([[Fire a glowing orb of light at each enemy within your Radiance.  Each orb will slowly follow its target until it connects dealing %d light damage to anything else it contacts along the way.  When the target is reached the orb will explode dealing %d light damage and healing you for 50%% of the damage dealt.  This powerful ability will dim your Radiance, reducing its radius to 1 for 5 turns.]]):
		format(t.getMoveDamage(self, t), t.getExplosionDamage(self, t))
	end,
}

