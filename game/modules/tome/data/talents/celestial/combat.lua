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

-- This concept plays well but vs. low damage levels spam bumping can make stupidly large shields
-- Leaving as is for now but will likely change somehow
newTalent{
	name = "Weapon of Light",
	type = {"celestial/combat", 1},
	mode = "sustained",
	require = divi_req1,
	points = 5,
	cooldown = 10,
	sustain_positive = 10,
	tactical = { BUFF = 2 },
	range = 10,
	getDamage = function(self, t) return 7 + self:combatSpellpower(0.092) * self:combatTalentScale(t, 1, 7) end,
	getShieldFlat = function(self, t)
		return t.getDamage(self, t) / 2
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			dam = self:addTemporaryValue("melee_project", {[DamageType.LIGHT]=t.getDamage(self, t)}),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("melee_project", p.dam)
		return true
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if hitted and self:hasEffect(self.EFF_DAMAGE_SHIELD) and (self:reactionToward(target) < 0) then
			-- Shields can't usually merge, so change the parameters manually 
			local shield = self:hasEffect(self.EFF_DAMAGE_SHIELD)
			local shield_power = t.getShieldFlat(self, t)

			shield.power = shield.power + shield_power
			self.damage_shield_absorb = self.damage_shield_absorb + shield_power
			self.damage_shield_absorb_max = self.damage_shield_absorb_max + shield_power
			shield.dur = math.max(2, shield.dur)
		end

	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local shieldflat = t.getShieldFlat(self, t)
		return ([[Infuse your weapon with the power of the Sun, adding %0.2f light damage on each melee hit.
		Additionally, if you have a temporary damage shield active, melee attacks will increase its power by %d.
		The damage dealt and shield bonus will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.LIGHT, damage), shieldflat)
	end,
}

-- Boring scaling, TL4 effect?
newTalent{
	name = "Wave of Power",
	type = {"celestial/combat",2},
	require = divi_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	positive = 10,
	tactical = { ATTACK = 2 },
	requires_target = true,
	range = function(self, t) return 2 + math.max(0, self:combatStatScale("str", 0.8, 8)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.9, 2.5) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			self:attackTarget(target, nil, t.getDamage(self, t), true)
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[In a pure display of power, you project a melee attack, doing %d%% damage.
		The range will increase with your Strength.]]):
		format(100 * damage)
	end,
}

-- Interesting interactions with shield timing, lots of synergy and antisynergy in general
newTalent{
	name = "Weapon of Wrath",
	type = {"celestial/combat", 3},
	mode = "sustained",
	require = divi_req3,
	points = 5,
	cooldown = 10,
	sustain_positive = 10,
	tactical = { BUFF = 2 },
	range = 10,
	getMartyrDamage = function(self, t) return self:combatTalentScale(t, 5, 25) end,
	getLifeDamage = function(self, t) return self:combatTalentScale(t, 0.1, 0.8) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		-- Is this any better than having the callback call getLifeDamage?  I figure its better to calculate it once
		local ret = {
			martyr = self:addTemporaryValue("weapon_of_wrath_martyr", t.getMartyrDamage(self, t)),
			damage = self:addTemporaryValue("weapon_of_wrath_life", t.getLifeDamage(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("weapon_of_wrath_martyr", p.martyr)
		self:removeTemporaryValue("weapon_of_wrath_life", p.damage)
		return true
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if hitted and self:attr("weapon_of_wrath_martyr") and not self.turn_procs.weapon_of_wrath and not target.dead then
			target:setEffect(target.EFF_MARTYRDOM, 4, {power = self:attr("weapon_of_wrath_martyr")})

			local damage = self:attr("weapon_of_wrath_life") * (self.max_life - math.max(0, self.life)) -- avoid problems with die_at
			if damage == 0 then return end
			damage = math.min(300, damage) -- No need to try to scale this in a clever way, NPC HP is too variant

			local tg = {type="hit", range=10, selffire=true, talent=t}
			self:project(tg, target.x, target.y, DamageType.FIRE, damage)

			self.turn_procs.weapon_of_wrath = true
		end
	end,
	info = function(self, t)
		local martyr = t.getMartyrDamage(self, t)
		local damagepct = t.getLifeDamage(self, t)
		local damage = damagepct * (self.max_life - math.max(0, self.life))
		return ([[Your weapon attacks burn with righteous fury dealing %d%% of your lost HP (Current:  %d) fire damage up to 300 damage and causing your target to take %d%% of the damage they deal.]]):
		format(damagepct*100, damage, martyr)
	end,
} 

-- Core class defense to be compared with Bone Shield, Aegis, Indiscernable Anatomy, etc
-- !H/Shield could conceivably reactivate this in the same fight with Crusade spam if it triggers with Suncloak up, 2H never will without running
newTalent{
	name = "Second Life",
	type = {"celestial/combat", 4},
	require = divi_req4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_positive = 30,
	cooldown = 30,
	tactical = { DEFEND = 2 },
	getLife = function(self, t) return self.max_life * self:combatTalentLimit(t, 1.5, 0.09, 0.4) end, -- Limit < 150% max life (to survive a large string of hits between turns)
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {}
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.6, rotation=0, radius=2, img="flamesgeneric"}, {type="sunaura", time_factor=6000}))
		else
			ret.particle = self:addParticles(Particles.new("golden_shield", 1))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[Any attack that would drop you below 1 hit point instead triggers Second Life, deactivating the talent, setting your hit points to 1, then healing you for %d.]]):
		format(t.getLife(self, t))
	end,
}



