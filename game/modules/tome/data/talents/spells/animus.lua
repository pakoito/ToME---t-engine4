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

newTalent{
	name = "Animus Purge",
	type = {"spell/animus",3},
	require = spells_req3,
	points = 5,
	mana = 50,
	soul = 4,
	cooldown = 15,
	range = 6,
	proj_speed = 20,
	requires_target = true,
	no_npc_use = true,
	direct_hit = function(self, t) if self:getTalentLevel(t) >= 3 then return true else return false end end,
	target = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		return tg
	end,
	getMaxLife = function(self, t) return self:combatTalentLimit(t, 50, 10, 25) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 35, 330) end,
	on_pre_use = function(self, t)
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self then
					if act.type == "undead" and act.subtype == "husk" then return false end
				end
			end
			return true
		else return false end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local m = game.level.map(px, py, Map.ACTOR)
			if not m or not m.max_life or not m.life then return end
			local dam = self:spellCrit(t.getDamage(self, t))
			local olddie = rawget(m, "die")
			m.die = function() end
			DamageType:get(DamageType.DARKNESS).projector(self, px, py, DamageType.DARKNESS, dam)
			m.die = olddie
			game.level.map:particleEmitter(px, py, 1, "dark")
			if 100 * m.life / m.max_life <= t.getMaxLife(self, t) and self:checkHit(self:combatSpellpower(), m:combatSpellResist()) and m:canBe("instakill") and m.rank <= 3.2 and not m:attr("undead") and not m.summoner and not m.summon_time then
				m.type = "undead"
				m.subtype = "husk"
				m:attr("no_life_regen", 1)
				m:attr("no_healing", 1)
				m.ai_state.tactic_leash = 100
				m.remove_from_party_on_death = true
				m.no_inventory_access = true
				m.no_party_reward = true
				m.life = m.max_life
				m.move_others = true
				m.summoner = self
				m.summoner_gain_exp = true
				m.unused_stats = 0
				m.dead = nil
				m.undead = 1
				m.no_breath = 1
				m.unused_talents = 0
				m.unused_generics = 0
				m.unused_talents_types = 0
				m.silent_levelup = true
				m.clone_on_hit = nil
				if m:knowTalent(m.T_BONE_SHIELD) then m:unlearnTalent(m.T_BONE_SHIELD, m:getTalentLevelRaw(m.T_BONE_SHIELD)) end
				if m:knowTalent(m.T_MULTIPLY) then m:unlearnTalent(m.T_MULTIPLY, m:getTalentLevelRaw(m.T_MULTIPLY)) end
				m.no_points_on_levelup = true
				m.faction = self.faction

				m.on_act = function(self)
					if game.player ~= self then return end
					if not self.summoner.dead and not self:hasLOS(self.summoner.x, self.summoner.y) then
						if not self:hasEffect(self.EFF_HUSK_OFS) then
							self:setEffect(self.EFF_HUSK_OFS, 3, {})
						end
					else
						if self:hasEffect(self.EFF_HUSK_OFS) then
							self:removeEffect(self.EFF_HUSK_OFS)
						end
					end
				end

				m.on_can_control = function(self, vocal)
					if not self:hasLOS(self.summoner.x, self.summoner.y) then
						if vocal then game.logPlayer(game.player, "Your husk is out of sight; you cannot establish direct control.") end
						return false
					end
					return true
				end

				m:removeEffectsFilter({status="detrimental"}, nil, true)
				game.level.map:particleEmitter(px, py, 1, "demon_teleport")

				applyDarkEmpathy(self, m)

				game.party:addMember(m, {
					control="full",
					type="husk",
					title="Lifeless Husk",
					orders = {leash=true, follow=true},
					on_control = function(self)
						self:hotkeyAutoTalents()
					end,
				})
				game:onTickEnd(function() self:incSoul(2) end)

				self:logCombat(m, "#GREY##Source# rips apart the animus of #target# and creates an undead husk.")
			end
		end)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Try to crush the soul of your foe, doing %0.2f darkness damage (that can never kill the target).
		If the target is left with less than %d%% life you try to take control of its body.
		Should this succeed the target becomes your permanent minion (unaffected by your aura) and you regain 2 souls.
		Husks prossess the same abilities as they had in life (affected by Dark Empathy), are healed to full when created but can never heal or be healed by any means.
		Only one husk can be controlled at any time.
		Bosses, other undeads and summoned creatures can not be turned into husks.
		The damage and chance will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.DARKNESS, damage), t.getMaxLife(self, t))
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
		- Undeath Link: in addition to the heal a shield is created for half the heal power
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
