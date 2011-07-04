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
	name = "Flame", image = true,
	type = {"spell/fire",1},
	require = spells_req1,
	points = 5,
	random_ego = "attack",
	mana = 12,
	cooldown = 3,
	tactical = { ATTACK = 2 },
	range = 10,
	reflectable = true,
	proj_speed = 20,
	requires_target = true,
	target = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire", trail="firetrail"}}
		if self:getTalentLevel(t) >= 5 then tg.type = "beam" end
		return tg
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 290) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local grids = nil
		if self:getTalentLevel(t) < 5 then
			grids = self:projectile(tg, x, y, DamageType.FIREBURN, self:spellCrit(t.getDamage(self, t)), function(self, tg, x, y, grids)
				game.level.map:particleEmitter(x, y, 1, "flame")
				if self:attr("burning_wake") then
					game.level.map:addEffect(self, x, y, 4, engine.DamageType.INFERNO, self:attr("burning_wake"), 0, 5, nil, {type="inferno"}, nil, self:spellFriendlyFire())
				end
			end)
		else
			grids = self:project(tg, x, y, DamageType.FIREBURN, self:spellCrit(t.getDamage(self, t)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
		end

		if self:attr("burning_wake") and grids then
			for px, ys in pairs(grids) do
				for py, _ in pairs(ys) do
					game.level.map:addEffect(self, px, py, 4, engine.DamageType.INFERNO, self:attr("burning_wake"), 0, 5, nil, {type="inferno"}, nil, self:spellFriendlyFire())
				end
			end
		end

		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Conjures up a bolt of fire, setting the target ablaze and doing %0.2f fire damage over 3 turns.
		At level 5 it will create a beam of flames.
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Flameshock",
	type = {"spell/fire",2},
	require = spells_req2,
	points = 5,
	random_ego = "attack",
	mana = 30,
	cooldown = 18,
	tactical = { ATTACK = 1, DISABLE = 3 },
	range = 0,
	radius = function(self, t)
		return 3 + self:getTalentLevelRaw(t)
	end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 120) end,
	getStunDuration = function(self, t) return self:getTalentLevelRaw(t) + 2 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FLAMESHOCK, {dur=t.getStunDuration(self, t), dam=self:spellCrit(t.getDamage(self, t))})

		if self:attr("burning_wake") then
			local l = line.new(self.x, self.y, x, y)
			local lx, ly = l()
			local dir = lx and coord_to_dir[lx - self.x][ly - self.y] or 6

			game.level.map:addEffect(self,
				self.x, self.y, 4,
				DamageType.INFERNO, self:attr("burning_wake"),
				tg.radius,
				{angle=math.deg(math.atan2(y - self.y, x - self.x))}, 55,
				{type="inferno"},
				nil, self:spellFriendlyFire()
			)
		end
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local stunduration = t.getStunDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Conjures up a cone of flame with radius %d. Any target caught in the area will take %0.2f fire damage and be paralyzed for %d turns.
		The damage will increase with the Magic stat]]):
		format(radius, damDesc(self, DamageType.FIRE, damage), stunduration)
	end,
}

newTalent{
	name = "Fireflash",
	type = {"spell/fire",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 40,
	cooldown = 8,
	tactical = { ATTACKAREA = 2 },
	range = 7,
	radius = function(self, t)
		return 1 + self:getTalentLevelRaw(t)
	end,
	proj_speed = 4,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t, display={particle="bolt_fire", trail="firetrail"}}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 280) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.FIRE, self:spellCrit(t.getDamage(self, t)), function(self, tg, x, y, grids)
			game.level.map:particleEmitter(x, y, tg.radius, "fireflash", {radius=tg.radius, tx=x, ty=y})
			if self:attr("burning_wake") then
				game.level.map:addEffect(self,
					x, y, 4,
					engine.DamageType.INFERNO, self:attr("burning_wake"),
					tg.radius,
					5, nil,
					{type="inferno"},
					nil, tg.selffire
				)
			end
		end)
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Conjures up a bolt of fire moving toward the target that explodes into a flash of fire doing %0.2f fire damage in a radius of %d.
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.FIRE, damage), radius)
	end,
}

newTalent{
	name = "Inferno",
	type = {"spell/fire",4},
	require = spells_req4,
	points = 5,
	random_ego = "attack",
	mana = 100,
	cooldown = 30,
	tactical = { ATTACKAREA = 3 },
	range = 10,
	radius = 5,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	getDuration = function(self, t) return 5 + self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.INFERNO, t.getDamage(self, t),
			self:getTalentRadius(t),
			5, nil,
			{type="inferno"},
			nil, self:spellFriendlyFire()
		)

		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Raging flames burn foes and allies alike doing %0.2f fire damage in a radius of %d each turn for %d turns.
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.FIRE, damage), radius, duration)
	end,
}
