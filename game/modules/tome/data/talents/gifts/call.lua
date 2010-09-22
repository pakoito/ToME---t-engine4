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
	name = "Meditation",
	type = {"wild-gift/call", 1},
	require = gifts_req1,
	points = 5,
	message = "@Source@ meditates on nature.",
	equilibrium = 0,
	cooldown = 150,
	range = 20,
	action = function(self, t)
		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then seen = true end
		end, nil)
		if seen then
			game.log("There's too much going on for you to use Meditation right now!")
			return
		end
		self:setEffect(self.EFF_STUNNED, 17 - self:getTalentLevel(t), {})
		self:incEquilibrium(-10 - self:getWil(50) * self:getTalentLevel(t))
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[Meditate on your link with Nature. You are considered stunned for %d turns and regenerate %d equilibrium.
		Meditating require peace and quiet and may not be cast with hostile creatures in sight.
		The effect will increase with your Willpower stat.]]):
		format(17 - self:getTalentLevel(t), 10 + self:getWil(50) * self:getTalentLevel(t))
	end,
}

newTalent{ short_name = "NATURE_TOUCH",
	name = "Nature's Touch",
	type = {"wild-gift/call", 2},
	require = gifts_req2,
	random_ego = "defensive",
	points = 5,
	equilibrium = 10,
	cooldown = 20,
	range = 1,
	requires_target = true,
	action = function(self, t)
		local tg = {default_target=self, type="hit", nowarning=true, range=self:getTalentRange(t), first_target="friend"}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		if not target.undead then
			target:heal(20 + self:getWil(50) * self:getTalentLevel(t))
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[Touch a target (or yourself) to infuse it with Nature, healing it for %d.
		The effect will increase with your Willpower stat.]]):
		format(20 + self:getWil(50) * self:getTalentLevel(t))
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
	requires_target = true,
	action = function(self, t)
		local x, y = self:getTarget{type="ball", nolock=true, no_restrict=true, nowarning=true, range=100, radius=math.ceil(3 + self:getTalentLevel(t))}
		if not x then return nil end

		self:magicMap(math.ceil(3 + self:getTalentLevel(t)), x, y)
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[Using your connection to Nature you can see remote areas in a radius of %d.]]):
		format(math.ceil(3 + self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Nature's Balance",
	type = {"wild-gift/call", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 20,
	cooldown = 50,
	range = 20,
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
