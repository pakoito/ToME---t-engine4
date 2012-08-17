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
	name = "Earthen Missiles",
	type = {"spell/stone",1},
	require = spells_req_high1,
	points = 5,
	random_ego = "attack",
	mana = 10,
	cooldown = 6,
	tactical = { ATTACK = { PHYSICAL = 1, cut = 1} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	proj_speed = 20,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="stone_shards", trail="earthtrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local damage = t.getDamage(self, t)
		self:projectile(tg, x, y, DamageType.SPLIT_BLEED, self:spellCrit(damage), nil)
		game:playSoundNear(self, "talents/earth")
		--missile #2
		local tg2 = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="stone_shards", trail="earthtrail"}}
		local x, y = self:getTarget(tg2)
		if x and y then
			self:projectile(tg2, x, y, DamageType.SPLIT_BLEED, self:spellCrit(damage), nil)
			game:playSoundNear(self, "talents/earth")
		end
		--missile #3 (Talent Level 5 Bonus Missile)
		if self:getTalentLevel(t) >= 5 then
			local tg3 = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="stone_shards", trail="earthtrail"}}
			local x, y = self:getTarget(tg3)
			if x and y then
				self:projectile(tg3, x, y, DamageType.SPLIT_BLEED, self:spellCrit(damage), nil)
				game:playSoundNear(self, "talents/earth")
			end
		else end
		return true
	end,
	info = function(self, t)
		local count = 2
		if self:getTalentLevel(t) >= 5 then
			count = count + 1
		end
		local damage = t.getDamage(self, t)
		return ([[Conjures %d missile shaped rocks that you target individually at any target or targets in range.  Each missile deals %0.2f physical damage and an additional %0.2f bleeding damage every turn for 5 turns.
		At talent level 5 you can conjure one additional missile.
		The damage will increase with your Spellpower.]]):format(count,damDesc(self, DamageType.PHYSICAL, damage/2), damDesc(self, DamageType.PHYSICAL, damage/12))
	end,
}

newTalent{
	name = "Body of Stone",
	type = {"spell/stone",2},
	require = spells_req_high2,
	points = 5,
	mode = "sustained",
	sustain_mana = 70,
	cooldown = 12,
	no_npc_use = true,
	tactical = { BUFF = 2 },
	getFireRes = function(self, t) return self:combatTalentSpellDamage(t, 5, 80) end,
	getLightningRes = function(self, t) return self:combatTalentSpellDamage(t, 5, 50) end,
	getAcidRes = function(self, t) return self:combatTalentSpellDamage(t, 5, 20) end,
	getStunRes = function(self, t) return self:getTalentLevel(t)/10 end,
	getCooldownReduction = function(self, t) return self:getTalentLevel(t)/2 end,
	activate = function(self, t)
		local cdr = t.getCooldownReduction(self, t)
		game:playSoundNear(self, "talents/earth")
		return {
			particle = self:addParticles(Particles.new("stone_skin", 1)),
			move = self:addTemporaryValue("never_move", 1),
			stun = self:addTemporaryValue("stun_immune", t.getStunRes(self, t)),
			cdred = self:addTemporaryValue("talent_cd_reduction", {
				[self.T_EARTHEN_MISSILES] = cdr,
				[self.T_MUDSLIDE] = cdr,
				[self.T_EARTHQUAKE] = cdr,
			}),
			res = self:addTemporaryValue("resists", {
				[DamageType.FIRE] = t.getFireRes(self, t),
				[DamageType.LIGHTNING] = t.getLightningRes(self, t),
				[DamageType.ACID] = t.getAcidRes(self, t),
			}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("never_move", p.move)
		self:removeTemporaryValue("stun_immune", p.stun)
		self:removeTemporaryValue("talent_cd_reduction", p.cdred)
		self:removeTemporaryValue("resists", p.res)
		return true
	end,
	info = function(self, t)
		local fireres = t.getFireRes(self, t)
		local lightningres = t.getLightningRes(self, t)
		local acidres = t.getAcidRes(self, t)
		local cooldownred = t.getCooldownReduction(self, t)
		local stunres = t.getStunRes(self, t)
		return ([[You root yourself into the earth and transform your flesh into stone.  While this spell is sustained you may not move and any forced movement will end the effect.
		Your stoned form and your affinity with the earth while the spell is active has the following effects:
		* Reduces the cooldown of Earthen Missiles, Earthquake, and Mudslide by %d
		* Grants %d%% Fire Resistance, %d%% Lightning Resistance, %d%% Acid Resistance, and %d%% Stun Resistance
		Resistances scale with the Magic Stat.]])
		:format(cooldownred, fireres, lightningres, acidres, stunres*100)
	end,
}

newTalent{
	name = "Earthquake",
	type = {"spell/stone",3},
	require = spells_req_high3,
	points = 5,
	random_ego = "attack",
	mana = 50,
	cooldown = 30,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { stun = 3 } },
	range = 10,
	radius = function(self, t)
		return 2 + (self:getTalentLevel(t)/2)
	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	getDuration = function(self, t) return 3 + self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.PHYSICAL_STUN, t.getDamage(self, t),
			self:getTalentRadius(t),
			5, nil,
			{type="quake"},
			nil, self:spellFriendlyFire()
		)

		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[Causes a violent earthquake that deals %0.2f physical damage in a radius of %d each turn for %d turns and potentially stuns all creatures it affects.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.PHYSICAL, damage), radius, duration)
	end,
}

newTalent{
	name = "Crystalline Focus",
	type = {"spell/stone",4},
	require = spells_req_high4,
	points = 5,
	mode = "sustained",
	sustain_mana = 50,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getPhysicalDamageIncrease = function(self, t) return self:getTalentLevelRaw(t) * 2 end,
	getResistPenalty = function(self, t) return self:getTalentLevelRaw(t) * 10 end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/earth")
		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=-0.01, radius=1.1}, {type="stone", hide_center=1, xy={self.x, self.y}}))
		else
			particle = self:addParticles(Particles.new("crystalline_focus", 1))
		end
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.PHYSICAL] = t.getPhysicalDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.PHYSICAL] = t.getResistPenalty(self, t)}),
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
		local damageinc = t.getPhysicalDamageIncrease(self, t)
		local ressistpen = t.getResistPenalty(self, t)
		return ([[Concentrate on maintaining a Crystalline Focus, increasing all your physical damage by %d%% and ignoring %d%% physical resistance of your targets.]])
		:format(damageinc, ressistpen)
	end,
}
