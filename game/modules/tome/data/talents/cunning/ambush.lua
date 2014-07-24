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

local Map = require "engine.Map"

newTalent{
	name = "Shadow Leash",
	type = {"cunning/ambush", 1},
	require = cuns_req_high1,
	points = 5,
	cooldown = 20,
	stamina = 15,
	mana = 15,
	range = 1,
	tactical = { DISABLE = {disarm = 2} },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	speed = "weapon",
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		if target:canBe("disarm") then
			target:setEffect(target.EFF_DISARMED, t.getDuration(self, t), {apply_power=self:combatAttack()})
		else
			game.logSeen(target, "%s resists the shadow!", target.name:capitalize())
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[For an instant, your weapons turn into a shadow leash that tries to grab the target's weapon, disarming it for %d turns.
		The chance to hit improves with your Accuracy.]]):
		format(duration)
	end,
}

newTalent{
	name = "Shadow Ambush",
	type = {"cunning/ambush", 2},
	require = cuns_req_high2,
	points = 5,
	cooldown = 20,
	stamina = 15,
	mana = 15,
	range = 7,
	tactical = { DISABLE = {silence = 2}, CLOSEIN = 2 },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	speed = "combat",
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		local sx, sy = util.findFreeGrid(self.x, self.y, 5, true, {[engine.Map.ACTOR]=true})
		if not sx then return end

		target:move(sx, sy, true)

		if core.fov.distance(self.x, self.y, sx, sy) <= 1 then
			if target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, 2, {apply_power=self:combatAttack()})
			end
			if target:canBe("silence") then
				target:setEffect(target.EFF_SILENCED, t.getDuration(self, t), {apply_power=self:combatAttack()})
			else
				game.logSeen(target, "%s resists the shadow!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[You reach out with shadowy vines toward your target, pulling it to you and silencing it for %d turns and dazing it for 2 turns.
		The chance to hit improves with your Accuracy.]]):
		format(duration)
	end,
}

newTalent{
	name = "Ambuscade",
	type = {"cunning/ambush", 3},
	points = 5,
	cooldown = 20,
	stamina = 35,
	mana = 35,
	require = cuns_req_high3,
	requires_target = true,
	tactical = { ATTACK = {DARKNESS = 3} },
	getStealthPower = function(self, t) return self:combatScale(self:getCun(15, true) * self:getTalentLevel(t), 25, 0, 100, 75) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getHealth = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 20, 500), 1, 0.2, 0, 0.584, 384) end, -- Limit to < 100% health of summoner
	getDam = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 10, 500), 1.6, 0.4, 0, 0.761 , 361) end, -- Limit to <160% Nerf?
	speed = "spell",
	action = function(self, t)
		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to invoke your shadow!")
			return
		end

		local m = self:cloneFull{
			shader = "shadow_simulacrum",
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=nil},
			ai = "summoned", ai_real = "tactical",
			name = "Shadow of "..self.name,
			desc = [[A dark shadowy shape whose form resembles your own.]],
		}
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil

		m.energy.value = 0
		m.player = nil
		m.max_life = m.max_life * t.getHealth(self, t)
		m.life = util.bound(m.life, 0, m.max_life)
		m.forceLevelup = function() end
		m.die = nil
		m.on_die = function(self) self:removeEffect(self.EFF_ARCANE_EYE,true) end
		m.on_acquire_target = nil
		m.seen_by = nil
		m.puuid = nil
		m.on_takehit = nil
		m.can_talk = nil
		m.clone_on_hit = nil
		m.exp_worth = 0
		m.no_inventory_access = true
		m.no_levelup_access = true
		m.cant_teleport = true
		m:unlearnTalent(m.T_AMBUSCADE,m:getTalentLevelRaw(m.T_AMBUSCADE))
		m:unlearnTalent(m.T_PROJECTION,m:getTalentLevelRaw(m.T_PROJECTION)) -- no recurssive projections
		m:unlearnTalent(m.T_STEALTH,m:getTalentLevelRaw(m.T_STEALTH))
		m:unlearnTalent(m.T_HIDE_IN_PLAIN_SIGHT,m:getTalentLevelRaw(m.T_HIDE_IN_PLAIN_SIGHT))
		m.stealth = t.getStealthPower(self, t)

		self:removeEffect(self.EFF_SHADOW_VEIL) -- Remove shadow veil from creator
		m.remove_from_party_on_death = true
		m.resists[DamageType.LIGHT] = -100
		m.resists[DamageType.DARKNESS] = 130
		m.resists.all = -30
		m.inc_damage.all = ((100 + (m.inc_damage.all or 0)) * t.getDam(self, t)) - 100
		m.force_melee_damage_type = DamageType.DARKNESS

		m.on_act = function(self)
			if self.summoner.dead or not self:hasLOS(self.summoner.x, self.summoner.y) then
				if not self:hasEffect(self.EFF_AMBUSCADE_OFS) then
					self:setEffect(self.EFF_AMBUSCADE_OFS, 2, {})
				end
			else
				if self:hasEffect(self.EFF_AMBUSCADE_OFS) then
					self:removeEffect(self.EFF_AMBUSCADE_OFS)
				end
			end
		end,

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "shadow")

		if game.party:hasMember(self) then
			game.party:addMember(m, {
				control="full",
				type="shadow",
				title="Shadow of "..self.name,
				temporary_level=1,
				orders = {target=true},
				on_control = function(self)
					self.summoner.ambuscade_ai = self.summoner.ai
					self.summoner.ai = "none"
				end,
				on_uncontrol = function(self)
					self.summoner.ai = self.summoner.ambuscade_ai
					game:onTickEnd(function() game.party:removeMember(self) self:removeEffect(self.EFF_ARCANE_EYE, true) self:disappear() end)
				end,
			})
		end
		game:onTickEnd(function() game.party:setPlayer(m) end)

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[You take full control of your own shadow for %d turns.
		Your shadow possesses your talents and stats, has %d%% life and deals %d%% damage, -30%% all resistances, -100%% light resistance and 100%% darkness resistance.
		Your shadow is permanently stealthed (%d power), and all melee damage it deals is converted to darkness damage.
		If you release control early or if it leaves your sight for too long, your shadow will dissipate.]]):
		format(t.getDuration(self, t), t.getHealth(self, t) * 100, t.getDam(self, t) * 100, t.getStealthPower(self, t))
	end,
}

newTalent{
	name = "Shadow Veil",
	type = {"cunning/ambush", 4},
	points = 5,
	cooldown = 18,
	stamina = 30,
	mana = 60,
	require = cuns_req_high4,
	requires_target = true,
	range = 5,
	tactical = { ATTACK = {DARKNESS = 2}, DEFEND = 1 },
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.9, 2.0) end, -- Nerf?
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 18, 4, 8)) end, -- Limit to <18
	getDamageRes = function(self, t) return self:combatTalentScale(t, 15, 35) end,
	getBlinkRange = function(self, t) return math.floor(self:combatTalentScale(t, 5, 7)) end,
	speed = "spell",
	action = function(self, t)
		self:setEffect(self.EFF_SHADOW_VEIL, t.getDuration(self, t), {res=t.getDamageRes(self, t), dam=t.getDamage(self, t), range=t.getBlinkRange(self, t)})
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local res = t.getDamageRes(self, t)
		return ([[You veil yourself in shadows for %d turns, and let them control you.
		While veiled, you become immune to status effects and gain %d%% all damage reduction. Each turn, you blink to a nearby foe (within range %d), hitting it for %d%% darkness weapon damage.
		The shadow cannot teleport.
		While this goes on, you cannot be stopped unless you are killed, and you cannot control your character.]]):
		format(duration, res, t.getBlinkRange(self, t) ,100 * damage)
	end,
}
