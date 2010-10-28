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
	name = "Stalactitic Missiles",
	type = {"spell/stone",1},
	require = spells_req1,
	points = 5,
	random_ego = "attack",
	mana = 10,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	direct_hit = true,
	reflectable = true,
	proj_speed = 20,
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="stone_shards", trail="earthtrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.SPLIT_BLEED, self:spellCrit(self:combatTalentSpellDamage(t, 15, 120)), nil)
		game:playSoundNear(self, "talents/earth")
		--missile #2
		local tg2 = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="stone_shards", trail="earthtrail"}}
		local x, y = self:getTarget(tg2)
		if not x or not y then return nil end
		self:projectile(tg2, x, y, DamageType.SPLIT_BLEED, self:spellCrit(self:combatTalentSpellDamage(t, 15, 120)), nil)
		game:playSoundNear(self, "talents/earth")
		--missile #3 (Talent Level 4 Bonus Missile)
		if self:getTalentLevel(t) >= 5 then
			local tg3 = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="stone_shards", trail="earthtrail"}}
			local x, y = self:getTarget(tg3)
			if not x or not y then return nil end
			self:projectile(tg3, x, y, DamageType.SPLIT_BLEED, self:spellCrit(self:combatTalentSpellDamage(t, 15, 120)), nil)
			game:playSoundNear(self, "talents/earth")
		else end
		return true
	end,
	info = function(self, t)
		return ([[Conjures stalactite shaped rocks that you target individually at any target or targets in range.  Each missile deals %0.2f physical damage and an additional %0.2f bleeding damage over six turns.
		At talent level 1 you conjure two missile with an additional missile at talent level 5.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(t, 20, 120)/2), damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(t, 20, 120)/2))
	end,
}

newTalent{
	name = "Body of Stone",
	type = {"spell/stone",2},
	require = spells_req2,
	points = 5,
	mode = "sustained",
	sustain_mana = 70,
	cooldown = 12,
	activate = function(self, t)
		local fire = self:combatTalentSpellDamage(t, 5, 80)
		local light = self:combatTalentSpellDamage(t, 5, 50)
		local phys = self:combatTalentSpellDamage(t, 5, 20)
		local kb = self:getTalentLevel(t)/10
		local cdr = self:getTalentLevel(t)/2
		local rad = 5 + self:combatSpellpower(0.1) * self:getTalentLevel(t)
		game:playSoundNear(self, "talents/earth")
		return {
			particle = self:addParticles(Particles.new("stone_skin", 1)),
			move = self:addTemporaryValue("never_move", 1),
			knock = self:addTemporaryValue("knockback_immune", kb),
			detect = self:addTemporaryValue("detect_range", rad),
			tremor = self:addTemporaryValue("detect_actor", 1),
			cdred = self:addTemporaryValue("talent_cd_reduction", {
				[self.T_STALACTITIC_MISSILES] = cdr,
				[self.T_STRIKE] = cdr,
				[self.T_EARTHQUAKE] = cdr,
			}),
			res = self:addTemporaryValue("resists", {
				[DamageType.FIRE] = fire,
				[DamageType.LIGHTNING] = light,
				[DamageType.PHYSICAL] = phys,
			}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("never_move", p.move)
		self:removeTemporaryValue("knockback_immune", p.knock)
		self:removeTemporaryValue("detect_actor", p.tremor)
		self:removeTemporaryValue("detect_range", p.detect)
		self:removeTemporaryValue("talent_cd_reduction", p.cdred)
		self:removeTemporaryValue("resists", p.res)
		return true
	end,
	info = function(self, t)
		return ([[You root yourself into the earth and transform your flesh into stone.  While this spell is sustained you may not move and any forced movement will end the effect.
		Your stoned form and your affinity with the earth while the spell is active has the following effects:
		* Reduces the cooldown of Stalactitic Missiles, Earthquake, and Strike by %d
		* Grants %d%% Fire Resistance, %d%% Lightning Resistance, %d%% Physical Resistance, and %d%% Knockback Resistance
		* Sense foes around you in a radius of %d.
		Resistances and Sense radius scale with the Magic Stat.]])
		:format((self:getTalentLevel(t)/2), self:combatTalentSpellDamage(t, 5, 80), self:combatTalentSpellDamage(t, 5, 50), self:combatTalentSpellDamage(t, 5, 20), (self:getTalentLevel(t)*10), (5 + self:combatSpellpower(0.1) * self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Earthquake",
	type = {"spell/stone",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 50,
	cooldown = 30,
	tactical = {
		ATTACKAREA = 40,
	},
	range = 20,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local duration = 3 + self:getTalentLevel(t)
		local radius = 2 + (self:getTalentLevel(t)/2)
		local dam = self:combatTalentSpellDamage(t, 15, 70)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.PHYSICAL_STUN, dam,
			radius,
			5, nil,
			{type="quake"},
			nil, self:spellFriendlyFire()
		)

		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Causes a violent earthquake that deals %0.2f physical damage in a radius of %d each turn for %d turns and potentially stuns all creatures it affects.
		The damage and duration will increase with the Magic stat]]):format(damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(t, 15, 70)), 2 + (self:getTalentLevel(t)/2), 3 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Crystalline Focus",
	type = {"spell/stone",4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 80,
	cooldown = 30,
	activate = function(self, t)
		game:playSoundNear(self, "talents/earth")
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.PHYSICAL] = self:getTalentLevelRaw(t) * 2}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.PHYSICAL] = self:getTalentLevelRaw(t) * 10}),
			particle = self:addParticles(Particles.new("crystalline_focus", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		return true
	end,
	info = function(self, t)
		return ([[Concentrate on maintaining a Crystalline Focus, increasing all your physical damage by %d%% and ignoring %d%% physical resistance of your targets.]])
		:format(self:getTalentLevelRaw(t) * 2, self:getTalentLevelRaw(t) * 10)
	end,
}
