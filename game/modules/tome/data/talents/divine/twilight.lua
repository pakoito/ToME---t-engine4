-- ToME - Tales of Middle-Earth
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
	name = "Twilight",
	type = {"divine/twilight", 1},
	require = divi_req1,
	points = 5,
	cooldown = 6,
	positive = 15,
	tactical = {
		BUFF = 10,
	},
	range = 20,
	action = function(self, t)
		self:incNegative(20 + 20 * self:getTalentLevel(t))
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[You stand between the darkness and the light, allowing you to convert 15 positive energy into %d negative energy.]]):
		format(20 + 10 * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Jumpgate: Teleport To", short_name = "JUMPGATE_TELEPORT",
	type = {"divine/other", 1},
	points = 1,
	cooldown = 7,
	negative = 14,
	type_no_req = true,
	tactical = {
		MOVE = 10,
	},
	range = 20,
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
		return ([[You stand between the darkness and the light, allowing you to convert 15 positive energy into %d negative energy.]]):
		format(20 + 10 * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Jumpgate",
	type = {"divine/twilight", 2},
	require = divi_req2,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	cooldown = 20,
	negative_sustain = 20,
	tactical = {
		MOVE = 10,
	},
	on_learn = function(self, t)
		if not self:knowTalent(self.T_JUMPGATE_TELEPORT) then
			self:learnTalent(self.T_JUMPGATE_TELEPORT)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:unlearnTalent(self.T_JUMPGATE_TELEPORT)
		end
	end,
	range = function(self, t)
		return 10 + 10 * self:getTalentLevelRaw(t)
	end,
	activate = function(self, t)
		local ret = {
			jumpgate_x = game.player.x,
			jumpgate_y = game.player.y,
			particle = self:addParticles(Particles.new("time_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[Create a shadow jumpgate at your location. As long as you sustain this spell you can use 'Jumpgate: Teleport' to instantly travel to the jumpgate.]])
	end,
}

newTalent{
	name = "Mind Blast",
	type = {"divine/twilight",3},
	require = divi_req3,
	points = 5,
	cooldown = 15,
	negative = 15,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 3,
	action = function(self, t)
		local tg = {type="ball", range=0, radius=self:getTalentRange(t), talent=t, friendlyfire=false}
		self:project(tg, self.x, self.y, DamageType.CONFUSION, {
			dur = 2 + self:getTalentLevelRaw(t),
			dam = 50+self:getTalentLevelRaw(t)*10,
		})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[Let out a mental cry that shatters the will of your targets, confusion them for %d turns.]]):
		format(2 + self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Shadow Simulacrum",
	type = {"divine/twilight", 4},
	require = divi_req4,
	points = 5,
	cooldown = 30,
	negative = 10,
	tactical = {
		ATTACK = 10,
	},
	range = 10,
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

		if target.rank >= 4 or -- No boss
			target.on_die or -- No special die handler
			target.on_acquire_target or -- No special vision handled
			target.seen_by or -- No special vision handled
			target.can_talk or -- No talking things
			target:reactionToward(self) >= 0 -- No friends
			then
			game.logPlayer(self, "%s resists!", target.name:capitalize())
			return true
		end

		local m = target:clone{
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 3,
			ai_target = {actor=target},
			ai = "summoned", ai_real = target.ai,
		}
		m.energy.value = 0
		m.life = m.life / 2

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "shadow")

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Creates a shadowy copy of your target. The copy will attack its progenitor immediately.
		It stays for %d turns.]]):format(math.ceil(self:getTalentLevel(t)) + 3)
	end,
}
