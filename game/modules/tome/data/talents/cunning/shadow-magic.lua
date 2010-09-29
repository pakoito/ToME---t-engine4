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
	name = "Shadow Combat",
	type = {"cunning/shadow-magic", 1},
	mode = "sustained",
	points = 5,
	require = cuns_req1,
	sustain_stamina = 20,
	cooldown = 5,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Channel raw magical energy into your melee attacks, each doing %d darkness damage and costing %.2f mana.]]):
		format(damDesc(self, DamageType.DARKNESS, 3 + self:getTalentLevel(t) * 2), 1 + self:getTalentLevelRaw(t) / 1.5)
	end,
}

newTalent{
	name = "Shadow Cunning",
	type = {"cunning/shadow-magic", 2},
	mode = "passive",
	points = 5,
	require = cuns_req2,
	info = function(self, t)
		return ([[The user gains a bonus to spellpower equal to %d%% of their cunning.]]):
		format(15 + self:getTalentLevel(t) * 3)
	end,
}

newTalent{
	name = "Shadow Feed",
	type = {"cunning/shadow-magic", 3},
	points = 5,
	random_ego = "utility",
	cooldown = 5,
	stamina = 100,
	require = cuns_req3,
	range = 20,
	action = function(self, t)
		self:incMana(40 + self:getTalentLevel(t) * 12)
		return true
	end,
	info = function(self, t)
		return ([[Regenerates %d mana at the cost of 100 stamina.]]):format(40 + self:getTalentLevel(t) * 12)
	end,
}

newTalent{
	name = "Shadowstep",
	type = {"cunning/shadow-magic", 4},
	points = 5,
	random_ego = "attack",
	cooldown = 5,
	stamina = 100,
	require = cuns_req4,
	range = function(self, t) return math.floor(5 + self:getTalentLevel(t)) end,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > self:getTalentRange(t) then return nil end

		local l = line.new(self.x, self.y, x, y)
		local lx, ly = l()
		local tx, ty = self.x, self.y
		lx, ly = l()
		while lx and ly do
			if game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
			tx, ty = lx, ly
			lx, ly = l()
		end

		self:move(tx, ty, true)

		-- Attack ?
		if math.floor(core.fov.distance(self.x, self.y, x, y)) == 1 then
			if target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, 2 + self:getTalentLevel(t), {})
			else
				game.logSeen(target, "%s is not dazed!", target.name:capitalize())
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Step through the shadows to your target, dazing it for %d turns.
		Dazed targets can not act, but any damage will free them.]]):
		format(2 + self:getTalentLevel(t))
	end,
}
