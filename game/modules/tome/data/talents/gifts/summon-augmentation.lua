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
	name = "Rage",
	type = {"wild-gift/summon-augmentation", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 5,
	cooldown = 15,
	range = 10,
	np_npc_use = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t, first_target="friend"}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or not target.summoner == self or not target.wild_gift_summon then return nil end
		target:setEffect(target.EFF_ALL_STAT, 5, {power=2+math.floor(self:getTalentLevel(t) * 2)})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Induces a killing rage in one of your summons, increasing all its stats by %d for 5 turns.]]):format(2+math.floor(self:getTalentLevel(t) * 2))
	end,
}

newTalent{
	name = "Detonate",
	type = {"wild-gift/summon-augmentation", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 5,
	cooldown = 25,
	range = 10,
	requires_target = true,
	np_npc_use = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t, first_target="friend"}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or not target.summoner == self or not target.wild_gift_summon then return nil end

		if target.name == "ritch flamespitter" then
			local tg = {type="ball", range=self:getTalentRange(t), radius=1 + self:getTalentLevelRaw(t), talent=t}
			target:project(tg, target.x, target.y, DamageType.FIRE, self:combatTalentStatDamage(t, "wil", 30, 400), {type="flame"})
			target:die()
		elseif target.name == "black jelly" then
			local tg = {type="ball", range=self:getTalentRange(t), radius=1 + self:getTalentLevelRaw(t), talent=t}
			target:project(tg, target.x, target.y, DamageType.SLIME, self:combatTalentStatDamage(t, "wil", 30, 300), {type="slime"})
			target:die()
		else
			game.logPlayer("You may not detonate this summon.")
			return nil
		end
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		return ([[Destroys one of your summons, make it detonate in radius of %d.
		Only some summons can be detonated:
		- Ritch Flamespitter: Explodes into a fireball doing %0.2f fire damage
		- Jelly: Explodes into a ball of slowing slime doing %0.2f damage and slowing for 3 turns for 30%%
		The effects improves with your Willpower.]]):format(1 + self:getTalentLevelRaw(t),damDesc(self, DamageType.FIRE, self:combatTalentStatDamage(t, "wil", 30, 400)),damDesc(self, DamageType.SLIME, self:combatTalentStatDamage(t, "wil", 30, 300)))
	end,
}

newTalent{
	name = "Resilience",
	type = {"wild-gift/summon-augmentation", 3},
	require = gifts_req3,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[Improves all your summons' lifetime and Constitution.]])
	end,
}

newTalent{
	name = "Phase Summon",
	type = {"wild-gift/summon-augmentation", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 5,
	cooldown = 25,
	range = 10,
	requires_target = true,
	np_npc_use = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or not target.summoner == self or not target.wild_gift_summon then return nil end

		local dur = 1 + self:getTalentLevel(t)
		self:setEffect(self.EFF_EVASION, dur, {chance=50})
		target:setEffect(target.EFF_EVASION, dur, {chance=50})

		-- Displace
		game.level.map:remove(self.x, self.y, Map.ACTOR)
		game.level.map:remove(target.x, target.y, Map.ACTOR)
		game.level.map(self.x, self.y, Map.ACTOR, target)
		game.level.map(target.x, target.y, Map.ACTOR, self)
		self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		return ([[Switches places with one of your summons. This disorients your foes, granting both you and your summon 50%% evasion for %d turns.]]):format(1 + self:getTalentLevel(t))
	end,
}
