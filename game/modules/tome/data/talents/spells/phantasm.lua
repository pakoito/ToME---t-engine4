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
	name = "Illuminate",
	type = {"spell/phantasm",1},
	require = spells_req1,
	random_ego = "utility",
	points = 5,
	mana = 5,
	cooldown = 14,
	action = function(self, t)
		local tg = {type="ball", range=0, friendlyfire=true, radius=5 + self:getTalentLevel(t), talent=t}
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		if self:getTalentLevel(t) >= 3 then
			tg.friendlyfire = false
			self:project(tg, self.x, self.y, DamageType.BLIND, 3 + self:getTalentLevel(t))
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[Creates a globe of pure light with a radius of %d that illuminates the area.
		At level 3 it also blinds all who see it (except the caster).
		The radius will increase with the Magic stat]]):format(5 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Blur Sight",
	type = {"spell/phantasm", 2},
	mode = "sustained",
	require = spells_req2,
	points = 5,
	sustain_mana = 30,
	cooldown = 10,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		local power = self:combatTalentSpellDamage(t, 4, 30)
		game:playSoundNear(self, "talents/heal")
		return {
			particle = self:addParticles(Particles.new("phantasm_shield", 1)),
			def = self:addTemporaryValue("combat_def", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("combat_def", p.def)
		return true
	end,
	info = function(self, t)
		return ([[The caster's image blurs, granting %d bonus to defense.
		The bonus will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 4, 30))
	end,
}

newTalent{
	name = "Phantasmal Shield",
	type = {"spell/phantasm", 3},
	mode = "sustained",
	require = spells_req3,
	points = 5,
	sustain_mana = 60,
	cooldown = 10,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		local power = self:combatTalentSpellDamage(t, 10, 50)
		game:playSoundNear(self, "talents/heal")
		return {
			particle = self:addParticles(Particles.new("phantasm_shield", 1)),
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.ARCANE]=power}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		return ([[The caster is surrounded by a phantasmal shield. If hit in melee, the shield will deal %d arcane damage to the attacker.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.ARCANE, self:combatTalentSpellDamage(t, 10, 50)))
	end,
}

newTalent{
	name = "Invisibility",
	type = {"spell/phantasm", 4},
	mode = "sustained",
	require = spells_req4,
	points = 5,
	sustain_mana = 200,
	cooldown = 30,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		local power = self:combatTalentSpellDamage(t, 10, 30)
		game:playSoundNear(self, "talents/heal")
		return {
			invisible = self:addTemporaryValue("invisible", power),
			drain = self:addTemporaryValue("mana_regen", -5),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("invisible", p.invisible)
		self:removeTemporaryValue("mana_regen", p.drain)
		return true
	end,
	info = function(self, t)
		return ([[The caster fades from sight, granting %d bonus to invisibility.
		Beware, you should take off your light, otherwise you will still be easily spotted.
		This powerful spell constantly drains your mana while active.
		The bonus will increase with the Magic stat]]):format(self:combatTalentSpellDamage(t, 10, 30))
	end,
}
