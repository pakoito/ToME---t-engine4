-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	name = "Stoneshield",
	type = {"wild-gift/earthen-power", 1},
	mode = "passive",
	require = gifts_req1,
	points = 5,
	getValues = function(self, t)
		return
			(5 + self:getTalentLevel(t) * 2) / 100,
			5 + self:getTalentLevel(t),
			(5 + self:getTalentLevel(t) * 1.7) / 100,
			4 + self:getTalentLevel(t)
	end,
	info = function(self, t)
		local m, mm, e, em = t.getValues(self, t)
		return ([[Each time you get hit you regenerate %d%% of the damage dealt as mana (up to a maximun of %0.2f) and %d%% as equilibrium (up to %0.2f).
		Also makes all your melee attack also do a shield bash.]]):format(100 * m, mm, 100 * e, em)
	end,
}

newTalent{
	name = "Stone Fortress",
	type = {"wild-gift/earthen-power", 2},
	require = gifts_req2,
	points = 5,
	mode = "passive",
	info = function(self, t)
		return ([[When you use your Resilience of the Dwarves racial power your skin becomes so thick that it even absorbs damage from non physical attacks.
		Non physical damages are reduced by %d%% of your armour value (ignoring hardiness).]]):
		format(50 + self:getTalentLevel(t) * 10)
	end,
}

newTalent{
	name = "Shards",
	type = {"wild-gift/earthen-power", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 4,
	cooldown = 30,
	tactical = { ATTACK = 2 },
	range = 10,
	direct_hit = true,
	proj_speed = 8,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), display={particle="bolt_arcane"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.SLIME, self:combatTalentStatDamage(t, "dex", 30, 290), {type="slime"})
		game:playSoundNear(self, "talents/stone")
		return true
	end,
	info = function(self, t)
		return ([[Spit slime at your target doing %0.2f nature damage and slowing it down by 30%% for 3 turns.
		The damage will increase with the Dexterity stat]]):format(damDesc(self, DamageType.NATURE, self:combatTalentStatDamage(t, "dex", 30, 290)))
	end,
}

newTalent{
	name = "Eldritch Stone",
	type = {"wild-gift/earthen-power", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 5,
	cooldown = 20,
	tactical = { CLOSEIN = 2 },
	requires_target = true,
	range = function(self, t)
		return 5 + self:getTalentLevel(t)
	end,
	radius = function(self, t)
		return util.bound(4 - self:getTalentLevel(t) / 2, 1, 4)
	end,
	getDuration = function(self, t)
		return util.bound(7 - self:getTalentLevel(t) / 2, 2, 7)
	end,
	is_teleport = true,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
		local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=range, radius=radius, requires_knowledge=false}
		local x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code does not restrict the self coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, 1, "slime")
		self:teleportRandom(x, y, self:getTalentRadius(t))
		game.level.map:particleEmitter(self.x, self.y, 1, "slime")

		local duration = t.getDuration(self, t)

		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t.mode == "activated" and not t.innate then
				self.talents_cd[t.id] = duration
			end
		end
		game:playSoundNear(self, "talents/stone")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[You extend slimy roots into the ground, follow them, and re-appear somewhere else in a range of %d with error margin of %d.
		The process is quite a strain on your body and all your talents will be put on cooldown for %d turns.]]):format(range, radius, duration)
	end,
}
