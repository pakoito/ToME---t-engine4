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

local Object = require "mod.class.Object"

newTalent{
	name = "Consume Soul",
	type = {"spell/animus",1},
	require = spells_req1,
	points = 5,
	soul = 1,
	cooldown = 10,
	tactical = { HEAL = 1, MANA = 1 },
	getHeal = function(self, t) return (40 + self:combatTalentSpellDamage(t, 10, 520)) * (necroEssenceDead(self, true) and 1.5 or 1) end,
	is_heal = true,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		self:incMana(self:spellCrit(t.getHeal(self, t)) / 3, self)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=2.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=1.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
		end
		game:playSoundNear(self, "talents/heal")
		if necroEssenceDead(self, true) then necroEssenceDead(self)() end
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[Crush and consume one of your captured souls, healing your for %d life and restoring %d mana.
		The life and mana healed will increase with your Spellpower.]]):
		format(heal, heal / 3)
	end,
}

newTalent{
	name = "Animus Hoarder",
	type = {"spell/animus",2},
	require = spells_req2,
	mode = "sustained",
	points = 5,
	sustain_mana = 50,
	cooldown = 30,
	tactical = { BUFF = 3 },
	getMax = function(self, t) return math.floor(self:combatTalentScale(t, 2, 8)) end,
	getChance = function(self, t) return math.floor(self:combatTalentScale(t, 10, 80)) end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "max_soul", t.getMax(self, t))
		self:talentTemporaryValue(ret, "extra_soul_chance", t.getChance(self, t))
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local max, chance = t.getMax(self, t), t.getChance(self, t)
		return ([[Your hunger for souls grows ever more. When you kill a creature you rip away its animus with great force, granting you %d%% chances to gain one more soul.
		In addition you are able to store %d more souls.]]):
		format(chance, max)
	end,
}

-- Kinda copied from Creeping Darkness
newTalent{
	name = "Cold Flameazdazdazds",
	type = {"spell/animus",3},
	require = spells_req3,
	points = 5,
	mana = 40,
	cooldown = 22,
	range = 5,
	radius = 3,
	tactical = { ATTACK = { COLD = 2 }, DISABLE = { stun = 1 } },
	requires_target = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		local darkCount = t.getDarkCount(self, t)
		return ([[Cold Flames slowly spread from %d spots in a radius of %d around the targeted location. The flames deal %0.2f cold damage, and have a chance of freezing.
		Damage improves with your Spellpower.]]):format(darkCount, radius, damDesc(self, DamageType.COLD, damage))
	end,
}

newTalent{
	name = "Essence of the Dead",
	type = {"spell/animus",4},
	require = spells_req4,
	points = 5,
	mana = 20,
	soul = 2,
	cooldown = 20,
	tactical = { BUFF = 3 },
	getnb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	action = function(self, t)
		self:setEffect(self.EFF_ESSENCE_OF_THE_DEAD, 1, {nb=t.getnb(self, t)})
		return true
	end,
	info = function(self, t)
		local nb = t.getnb(self, t)
		return ([[Crush and consume two souls to empower your next %d spells, granting them a special effect.
		Affected spells are:
		- Undeath Link: in addition to the heal a shield is created for half the heal life_leech_value
		- Create Minions: allows you to summon 2 more minions
		- Assemble: allows you to summon a second bone golem
		- Invoke Darkness: becomes a cone of darkness
		- Shadow Tunnel: teleported minions will also be healed for 30%% of their max life
		- Cold Flames: freeze chance increased to 100%%
		- Ice Shards: each shard becomes a beam
		- Consume Soul: effect increased by 50%%]]):
		format(nb)
	end,
}
