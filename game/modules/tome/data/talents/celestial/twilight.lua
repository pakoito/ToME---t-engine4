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

--local Object = require "engine.Object"

newTalent{
	name = "Twilight",
	type = {"celestial/twilight", 1},
	require = divi_req1,
	points = 5,
	cooldown = 6,
	positive = 15,
	tactical = { BUFF = 1 },
	range = 10,
	getRestValue = function(self, t) return self:combatTalentLimit(t, 50, 20.5, 34.5) end, -- Limit < 50%
	getNegativeGain = function(self, t) return math.max(0, self:combatScale(self:getTalentLevel(t) * self:getCun(40, true), 24, 4, 220, 200, nil, nil, 40)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "positive_at_rest", t.getRestValue(self, t))
		self:talentTemporaryValue(p, "negative_at_rest", t.getRestValue(self, t))
	end,
	action = function(self, t)
		if self:isTalentActive(self.T_DARKEST_LIGHT) then
			game.logPlayer(self, "You can't use Twilight while Darkest Light is active.")
			return
		end
		self:incNegative(t.getNegativeGain(self, t))
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[You stand between the darkness and the light, allowing you to convert 15 positive energy into %d negative energy.
		Learning this talent will change the default level of positive and negative energies to %d%% of their maximum. Each turn, the energies will slowly fall/rise to this value, instead of 0.
		The negative energy gain will increase with your Cunning.]]):
		format(t.getNegativeGain(self, t), t.getRestValue(self, t))
	end,
}

newTalent{
	name = "Jumpgate: Teleport To", short_name = "JUMPGATE_TELEPORT",
	type = {"celestial/other", 1},
	points = 1,
	cooldown = 7,
	negative = 14,
	type_no_req = true,
	tactical = { ESCAPE = 2 },
	no_npc_use = true,
	no_unlearn_last = true,
	getRange = function(self, t) return math.floor(self:combatTalentScale(t, 13, 18)) end,
	-- Check distance in preUseTalent to grey out the talent
	on_pre_use = function(self, t)
		local eff = self.sustain_talents[self.T_JUMPGATE]
		return eff and core.fov.distance(self.x, self.y, eff.jumpgate_x, eff.jumpgate_y) < t.getRange(self, t)
	end,
	is_teleport = true,
	action = function(self, t)
		local eff = self.sustain_talents[self.T_JUMPGATE]
		if not eff then
			game.logPlayer(self, "You must sustain the Jumpgate spell to be able to teleport.")
			return
		end
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(eff.jumpgate_x, eff.jumpgate_y, 1)
		game.level.map:particleEmitter(eff.jumpgate_x, eff.jumpgate_y, 1, "teleport")
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		return ([[Instantly travel to your jumpgate, as long as you are within %d tiles of it.]]):format(t.getRange(self, t))
 	end,
}

newTalent{
	name = "Jumpgate",
	type = {"celestial/twilight", 2},
	require = divi_req2,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	cooldown = function(self, t)
		local tl = self:getTalentLevelRaw(t)
		if tl < 4 then
			return math.ceil(self:combatLimit(tl, 0, 20, 1, 8, 4))
		else
			return math.ceil(self:combatLimit(tl, 0, 8, 4, 4, 5)) --I5 Limit >0
		end
	end,
	sustain_negative = 20,
	no_npc_use = true,
	tactical = { ESCAPE = 2 },
 	on_learn = function(self, t)
		if self:getTalentLevel(t) >= 4 and not self:knowTalent(self.T_JUMPGATE_TWO) then
			self:learnTalent(self.T_JUMPGATE_TWO, nil, nil, {no_unlearn=true})
 		end
			self:learnTalent(self.T_JUMPGATE_TELEPORT, nil, nil, {no_unlearn=true})
	end,
 	on_unlearn = function(self, t)
		if self:getTalentLevel(t) < 4 and self:knowTalent(self.T_JUMPGATE_TWO) then
 			self:unlearnTalent(self.T_JUMPGATE_TWO)
 		end
			self:unlearnTalent(self.T_JUMPGATE_TELEPORT)
 	end,
	activate = function(self, t)
		local oe = game.level.map(self.x, self.y, engine.Map.TERRAIN)
		if not oe or oe:attr("temporary") then return false end
		local e = mod.class.Object.new{
			old_feat = oe, type = oe.type, subtype = oe.subtype,
			name = "jumpgate", image = oe.image, add_mos = {{image = "terrain/wormhole.png"}},
			display = '&', color=colors.PURPLE,
			temporary = 1, -- This prevents overlapping of terrain changing effects; as this talent is a sustain it does nothing else
		}
		game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN, e)
		
		local ret = {
			jumpgate = e, jumpgate_x = game.player.x, jumpgate_y = game.player.y,
			jumpgate_level = game.zone.short_name .. "-" .. game.level.level,
			particle = self:addParticles(Particles.new("time_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		-- Reset the terrain tile
		game.level.map(p.jumpgate_x, p.jumpgate_y, engine.Map.TERRAIN, p.jumpgate.old_feat)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local jumpgate_teleport = self:getTalentFromId(self.T_JUMPGATE_TELEPORT)
		local range = jumpgate_teleport.getRange(self, jumpgate_teleport)
		return ([[Create a shadow jumpgate at your current location. As long as you sustain this spell, you can use 'Jumpgate: Teleport' to instantly travel to the jumpgate, as long as you are within %d tiles of it.
		Note that any stairs underneath the jumpgate will be unusable while the spell is sustained, and you may need to cancel this sustain in order to leave certain locations.
		At talent level 4, you learn to create and sustain a second jumpgate.]]):format(range)
 	end,
 }


newTalent{
	name = "Mind Blast",
	type = {"celestial/twilight",3},
	require = divi_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	negative = 15,
	tactical = { DISABLE = 3 },
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, selffire=false}
	end,
	getConfuseDuration = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t) + self:getCun(5), 2, 0, 12, 10)) end,
	getConfuseEfficency = function(self, t) return self:combatTalentLimit(t, 60, 15, 45) end, -- Limit < 60% (slightly better than most confusion effects)
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.CONFUSION, {
			dur = t.getConfuseDuration(self, t),
			dam = t.getConfuseEfficency(self, t)
		})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local duration = t.getConfuseDuration(self, t)
		return ([[Let out a mental cry that shatters the will of your targets within radius 3, confusing (%d%% to act randomly) them for %d turns.
		The duration will improve with your Cunning.]]):
		format(t.getConfuseEfficency(self,t),duration)
	end,
}

newTalent{
	name = "Shadow Simulacrum",
	type = {"celestial/twilight", 4},
	require = divi_req4,
	random_ego = "attack",
	points = 5,
	cooldown = 30,
	negative = 10,
	tactical = { DISABLE = 2 },
	requires_target = true,
	range = 5,
	no_npc_use = true,
	getDuration = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t)+self:getCun(10), 3, 0, 18, 15)) end,
	getPercent = function(self, t) return self:combatScale(self:getCun(10, true) * self:getTalentLevel(t), 0, 0, 50, 50) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local target = game.level.map(tx, ty, Map.ACTOR)
		if not target or self:reactionToward(target) >= 0 then return end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		if target:attr("summon_time") then
			game.logPlayer(self, "Wrong target!")
			return
		end

		allowed = 2 + math.ceil(self:getTalentLevelRaw(t) / 2 )

		if target.rank >= 3.5 or -- No boss
			target:reactionToward(self) >= 0 or -- No friends
			target.size_category > allowed
			then
			game.logSeen(target, "%s resists!", target.name:capitalize())
			return true
		end

		local modifier = t.getPercent(self, t)

		local m = target:cloneFull{
			shader = "shadow_simulacrum",
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=target},
			ai = "summoned", ai_real = target.ai,
			resists = { all = modifier, [DamageType.DARKNESS] = 50, [DamageType.LIGHT] = - 50, },
			desc = [[A dark shadowy shape who's form resembles the creature it was taken from.]],
		}
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil

		m.energy.value = 0
		m.life = m.life*modifier/100
		m.forceLevelup = function() end
		-- Handle special things
		m.on_die = nil
		m.puuid = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.can_talk = nil
		m.exp_worth = 0
		m.clone_on_hit = nil
		if m.talents.T_SUMMON then m.talents.T_SUMMON = nil end
		if m.talents.T_MULTIPLY then m.talents.T_MULTIPLY = nil end

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "shadow")

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local allowed = 2 + math.ceil(self:getTalentLevelRaw(t) / 2 )
		local size = "gargantuan"
		if allowed < 4 then
			size = "medium"
		elseif allowed < 5 then
			size = "big"
		elseif allowed < 6 then
			size = "huge"
		end
		return ([[Creates a shadowy copy of a hostile target of up to %s size. The copy will attack its progenitor immediately and lasts for %d turns.
		The duplicate has %d%% of the target's life, %d%% all damage resistance, +50%% darkness resistance and -50%% light resistance.
		The duration, life and all damage resistance scale with your Cunning and this ability will not work on bosses.]]):
		format(size, duration, t.getPercent(self, t), t.getPercent(self, t))
	end,
}

-- Extra Jumpgates

newTalent{
	name = "Jumpgate Two",
	type = {"celestial/other", 1},
	mode = "sustained", no_sustain_autoreset = true,
	points = 1,
	cooldown = 20,
	sustain_negative = 20,
	no_npc_use = true,
	type_no_req = true,
	tactical = { ESCAPE = 2 },
	no_unlearn_last = true,
	on_learn = function(self, t)
		if not self:knowTalent(self.T_JUMPGATE_TELEPORT_TWO) then
			self:learnTalent(self.T_JUMPGATE_TELEPORT_TWO, nil, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:unlearnTalent(self.T_JUMPGATE_TELEPORT_TWO)
		end
	end,
	activate = function(self, t)
		local oe = game.level.map(self.x, self.y, engine.Map.TERRAIN)
		if not oe or oe:attr("temporary") then return false end
		local e = mod.class.Object.new{
			old_feat = oe, type = oe.type, subtype = oe.subtype,
			name = "jumpgate", image = oe.image, add_mos = {{image = "terrain/wormhole.png"}},
			display = '&', color=colors.PURPLE,
			temporary = 1, -- This prevents overlapping of terrain changing effects; as this talent is a sustain it does nothing else
		}
		
		game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN, e)
		local ret = {
			jumpgate2 = e, jumpgate2_x = game.player.x,	jumpgate2_y = game.player.y,
			jumpgate2_level = game.zone.short_name .. "-" .. game.level.level,
			particle = self:addParticles(Particles.new("time_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		-- Reset the terrain tile
		game.level.map(p.jumpgate2_x, p.jumpgate2_y, engine.Map.TERRAIN, p.jumpgate2.old_feat)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local jumpgate_teleport = self:getTalentFromId(self.T_JUMPGATE_TELEPORT_TWO)
		local range = jumpgate_teleport.getRange(self, jumpgate_teleport)
		return ([[Create a second shadow jumpgate at your location. As long as you sustain this spell, you can use 'Jumpgate: Teleport' to instantly travel to the jumpgate, as long as you are within %d tiles of it.]]):format(range)
	end,
}

newTalent{
	name = "Jumpgate Two: Teleport To", short_name = "JUMPGATE_TELEPORT_TWO",
	type = {"celestial/other", 1},
	points = 1,
	cooldown = 7,
	negative = 14,
	type_no_req = true,
	tactical = { ESCAPE = 2 },
	no_npc_use = true,
	getRange = function(self, t) return self:callTalent(self.T_JUMPGATE_TELEPORT, "getRange") end,
	-- Check distance in preUseTalent to grey out the talent
	is_teleport = true,
	no_unlearn_last = true,
	on_pre_use = function(self, t)
		local eff = self.sustain_talents[self.T_JUMPGATE_TWO]
		return eff and core.fov.distance(self.x, self.y, eff.jumpgate2_x, eff.jumpgate2_y) < t.getRange(self, t)
	end,
	action = function(self, t)
		local eff = self.sustain_talents[self.T_JUMPGATE_TWO]
		if not eff then
			game.logPlayer(self, "You must sustain the Jumpgate Two spell to be able to teleport.")
			return
		end
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(eff.jumpgate2_x, eff.jumpgate2_y, 1)
		game.level.map:particleEmitter(eff.jumpgate2_x, eff.jumpgate2_y, 1, "teleport")
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		return ([[Instantly travel to your second jumpgate, as long as you are within %d tiles of it.]]):format(t.getRange(self, t))
	end,
}
