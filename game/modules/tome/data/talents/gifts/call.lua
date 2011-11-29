-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	name = "Meditation",
	type = {"wild-gift/call", 1},
	require = gifts_req1,
	points = 5,
	message = "@Source@ meditates on nature.",
	cooldown = 150,
	range = 10,
	no_npc_use = true,
	action = function(self, t)
		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self and self:reactionToward(actor) < 0 then seen = true end
		end, nil)
		if seen then
			game.logPlayer(self, "There's too much going on for you to use Meditation right now!")
			return
		end

		local dur = 17 - self:getTalentLevel(t)
		local e = 10 + self:getWil(50, true) * self:getTalentLevel(t)
		local tt = e / 2
		local pt = (e - tt) / dur
		self:setEffect(self.EFF_MEDITATION, dur, {per_turn=pt, final=tt})

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local dur = 17 - self:getTalentLevel(t)
		local e = 10 + self:getWil(50, true) * self:getTalentLevel(t)
		local tt = e / 2
		local pt = (e - tt) / dur
		return ([[Meditate on your link with Nature. You are considered dazed for %d turns
		Each turn you regenerate %d equilibrium and %d at the end.
		If you are hit while meditating you will stop.
		Meditating require peace and quiet and may not be cast with hostile creatures in sight.
		The effects will increase with your Willpower stat.]]):
		format(17 - self:getTalentLevel(t), pt, tt)
	end,
}

newTalent{ short_name = "NATURE_TOUCH",
	name = "Nature's Touch",
	type = {"wild-gift/call", 2},
	require = gifts_req2,
	random_ego = "defensive",
	points = 5,
	equilibrium = 10,
	cooldown = 15,
	range = 1,
	requires_target = true,
	no_npc_use = true,
	is_heal = true,
	action = function(self, t)
		local tg = {default_target=self, type="hit", nowarning=true, range=self:getTalentRange(t), first_target="friend"}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		if not target.undead then
			target:heal(20 + self:combatTalentStatDamage(t, "wil", 30, 500))
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[Touch a target (or yourself) to infuse it with Nature, healing it for %d(heal does not work on undead).
		Heal will increase with your Willpower stat.]]):
		format(20 + self:combatTalentStatDamage(t, "wil", 30, 500))
	end,
}

newTalent{
	name = "Earth's Eyes",
	type = {"wild-gift/call", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "utility",
	equilibrium = 3,
	cooldown = 10,
	range = 100,
	radius = function(self, t) return math.ceil(3 + self:getTalentLevel(t)) end,
	requires_target = true,
	no_npc_use = true,
	action = function(self, t)
		local x, y = self:getTarget{type="ball", nolock=true, no_restrict=true, nowarning=true, range=100, radius=self:getTalentRadius(t)}
		if not x then return nil end

		self:magicMap(math.ceil(3 + self:getTalentLevel(t)), x, y)
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Using your connection to Nature you can see remote areas in a radius of %d.]]):
		format(radius)
	end,
}

newTalent{
	name = "Nature's Balance",
	type = {"wild-gift/call", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 20,
	cooldown = 50,
	range = 10,
	tactical = { BUFF = 2 },
	action = function(self, t)
		local nb = math.ceil(self:getTalentLevel(t) + 2)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[2] <= self:getTalentLevelRaw(t) and tt.type[1]:find("^wild%-gift/") then
				tids[#tids+1] = tid
			end
		end
		for i = 1, nb do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		self.changed = true
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[Your deep link with Nature allows you to reset the cooldown of %d of your wild gifts of level %d or less.]]):
		format(math.ceil(self:getTalentLevel(t) + 2), self:getTalentLevelRaw(t))
	end,
}

