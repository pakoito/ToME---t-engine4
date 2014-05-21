-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	name = "Transcendent Electrokinesis",
	type = {"psionic/charged-mastery", 1},
	require = psi_cun_high1,
	points = 5,
	psi = 20,
	cooldown = 30,
	tactical = { BUFF = 3 },
	getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 20) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10)) end,
	action = function(self, t)
		self:setEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS, t.getDuration(self, t), {power=t.getPower(self, t)})
		self:removeEffect(self.EFF_TRANSCENDENT_PYROKINESIS)
		self:removeEffect(self.EFF_TRANSCENDENT_TELEKINESIS)
		self.talents_cd[self.T_CHARGE_LEECH] = 0
		self.talents_cd[self.T_CHARGED_AURA] = 0
		self.talents_cd[self.T_CHARGED_SHIELD] = 0
		self.talents_cd[self.T_BRAIN_STORM] = 0
		return true
	end,
	info = function(self, t)
		return ([[For %d turns your electrokinesis transcends your normal limits, increasing your lightning damage and resistance penetration by %d%%.
		Charged Shield, Charged Leech, Charged Aura and Brainstorm will have their cooldowns reset.
		Charged Aura will increase to radius 2, or apply its damage bonus to all your weapons, whichever is applicable.
		Charged Shield will have 100%% damage absorption efficiency.
		Brainstorm will also inflict blindness.
		Charged Leech will also inflict confusion.
		Damage bonus and penetration scale with your mindpower.
		Only one Transcendent talent may be in effect at a time.]]):format(t.getDuration(self, t), t.getPower(self, t))
	end,
}

newTalent{
	name = "Thought Sense",
	type = {"psionic/charged-mastery", 2},
	require = psi_cun_high2, 
	points = 5,
	psi = 20,
	cooldown = 30,
	tactical = { BUFF = 3 },
	getDefense = function(self, t) return self:combatTalentMindDamage(t, 20, 40) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 12)) end,
	action = function(self, t)
		self:setEffect(self.EFF_THOUGHTSENSE, t.getDuration(self, t), {range=10, def=t.getDefense(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Detect the neural activity of any creatures in a radius of 10 for %d turns.
		This reveals their location and boosts your defense by %d.
		Duration and defense scale with your mindpower.]]):format(t.getDuration(self, t), t.getDefense(self, t))
	end,
}

newTalent{
	name = "Static Net",
	type = {"psionic/charged-mastery", 3},
	require = psi_cun_high3,
	points = 5,
	random_ego = "attack",
	psi = 32,
	cooldown = 13,
	tactical = { ATTACKAREA = { LIGHTNING = 2 } },
	range = 8,
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getSlow = function(self, t) return self:combatTalentSpellDamage(t, 5, 50)/100 end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 100) end,
	getWeaponDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 9)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.STATIC_NET, {dam=t.getDamage(self, t), slow=t.getSlow(self, t), weapon=t.getWeaponDamage(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="ice_vapour"},
			nil, true
		)
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Cast a net of static electricity in a radius of 3 for %d turns.
		Enemies standing in the net will take %0.2f lightning damage and be slowed by %d%%.
		If you move through the net, static will build up on your weapon and add %0.2f extra lightning damage to your next attack per tile of static you collect.
		These effect scale with your mindpower.]]):
		format(duration, damDesc(self, DamageType.LIGHTNING, damage), t.getSlow(self, t)*100, damDesc(self, DamageType.LIGHTNING, t.getWeaponDamage(self, t)))
	end,
}

newTalent{
	name = "Heartstart",
	type = {"psionic/charged-mastery", 4},
	require = psi_cun_high4,
	points = 5,
	mode = "sustained",
	sustain_psi = 30,
	cooldown = 60,
	tactical = { BUFF = 10},
	getPower = function(self, t) return 10 + self:combatTalentMindDamage(t, 0, 300) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		local effs = {}
		-- Go through all spell effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.subtype.stun then
				self:removeEffect(eff_id)
			end
		end
		self:setEffect(self.EFF_HEART_STARTED, t.getDuration(self, t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Store an electric charge for saving your life at a later time. If you go below zero life while this is active, it will deactivate. 
		When this sustain deactivates, you will be cured of all stun/daze/freeze effects and will be able to survive with up to %d negative health for %d turns.]]):
		format(t.getPower(self, t), t.getDuration(self, t))
	end,
}

