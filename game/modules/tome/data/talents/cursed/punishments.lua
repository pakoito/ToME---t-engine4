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
	name = "Cursed Ground",
	type = {"cursed/punishments", 1},
	require = cursed_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 3,
	hate =  0.2,
	range = 4,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 40, 220)
	end,
	getDuration = function(self, t)
		return 3 + self:getTalentLevel(t) * 3
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, friendly_fire=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)

		local Trap = require "mod.class.Trap"
		local t = Trap.new{
			type = "elemental",
			id_by_type=true,
			unided_name = "trap",
			name = "cursed ground",
			color={48,48,132},
			display = '^',
			faction = self.faction,
			x = x, y = y,
			summoner = self,
			summoner_gain_exp = true,
			damage = damage,
			duration = duration,
			canAct = false,
			energy = {value=0},
			triggered = function(self, x, y, who)
				self.summoner:project({type="ball", x=x,y=y, radius=0}, x, y, engine.DamageType.MIND, self.damage)
				game.level.map:particleEmitter(x, y, 1, "cursed_ground", {})
				return true, true
			end,
			act = function(self)
				self:useEnergy()
				self.duration = self.duration - 1
				if self.duration <= 0 then
					game.level.map:remove(self.x, self.y, engine.Map.TRAP)
					game.level:removeEntity(self)
				end
			end,
		}
		t:identify(true)

		t:resolve()
		t:resolve(nil, true)
		t:setKnown(self, true)
		game.level:addEntity(t)
		game.zone:addEntity(game.level, t, "trap", x, y)
		--game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[You mark the ground with a terrible curse. Anyone passing the mark triggers a blast of %d mind damage. The mark lasts for %d turns or until triggered.
		The damage will increase with the Willpower stat.]]):format(damDesc(self, DamageType.MIND, damage), duration)
	end,
}

newTalent{
	name = "Reproach",
	type = {"cursed/punishments", 2},
	require = cursed_wil_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 3,
	hate =  0.5,
	range = 2.5,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 40, 220)
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		
		local damage = t.getDamage(self, t)
		self:project(tg, target.x, target.y, DamageType.MIND, damage)
		game.level.map:particleEmitter(target.x, target.y, 1, "reproach", { dx = self.x - target.x, dy = self.y - target.y })
		game:playSoundNear(self, "talents/fire")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[You unleash your hateful mind on any who dare approach you. Blast the selected target for %d mind damage.
		The damage will increase with the Willpower stat.]]):format(damDesc(self, DamageType.MIND, damage))
	end,
}

newTalent{
	name = "Agony",
	type = {"cursed/punishments", 3},
	require = cursed_wil_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 3,
	hate =  0.5,
	range = 12,
	getDuration = function(self, t)
		return 10
	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 10, 40)
	end,
	getMindpower = function(self, t)
		return math.floor(50 + math.sqrt(self:getTalentLevel(t)) * 25)
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local tg = {type="hit", range=range}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		
		local damage = t.getDamage(self, t)
		local mindpower = t.getMindpower(self, t)
		local duration = t.getDuration(self, t)
		target:setEffect(target.EFF_AGONY, duration, {
			source = self,
			mindpower = self:combatMindpower() * mindpower / 100,
			damage = damage,
			range = range,
		})
			
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local mindpower = t.getMindpower(self, t)
		local duration = t.getDuration(self, t)
		return ([[Unleash agony upon your target. The pain will grow as the near you inflicing up to %d damage. They will suffer for %d turns unless they manage to resist. (+%d%% mindpower)
		The damage will increase with the Willpower stat.]]):format(damDesc(self, DamageType.MIND, damage), duration, mindpower)
	end,
}

newTalent{
	name = "Tortured Sanity",
	type = {"cursed/punishments", 4},
	require = cursed_wil_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 30,
	hate =  2,
	range = function(self, t)
		return 3 + self:getTalentLevel(t)
	end,
	getDuration = function(self, t)
		return 3
	end,
	getChance = function(self, t)
		return 20 + self:getTalentLevel(t) * 6
	end,
	action = function(self, t)
		local tg = {type="ball", x=self.x, y=self.y, radius=self:getTalentRange(t)}
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		local grids = self:project(tg, self.x, self.y,
			function(x, y, target, self)
				local target = game.level.map(x, y, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					if target:canBe("stun") and rng.percent(chance) then
						if target:checkHit(self:combatMindpower(), target:combatMentalResist(), 0, 95, 5) then
							target:setEffect(target.EFF_DAZED, duration, {src=self})
							game.level.map:particleEmitter(x, y, 1, "cursed_ground", {})
						else
							game.logSeen(self, "%s holds on to its sanity.", self.name:capitalize())
						end
					end
				end
			end,
			nil, nil)
			
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([[Your will reaches into the minds of all nearby enemies and tortures their sanity. Anyone within range has a %d%% chance of being dazed for %d turns.]]):format(chance, duration)
	end,
}

