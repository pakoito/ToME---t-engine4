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

local Object = require "engine.Object"

newTalent{
	name = "Ice Claw",
	type = {"wild-gift/cold-drake", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	equilibrium = 3,
	cooldown = 7,
	range = 1,
	tactical = { ATTACK = { COLD = 2 } },
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) - 1 end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:attackTarget(target, (self:getTalentLevel(t) >= 4) and DamageType.ICE or DamageType.COLD, 1.4 + self:getTalentLevel(t) / 8, true)
		return true
	end,
	info = function(self, t)
		return ([[You call upon the mighty claw of a cold drake, doing %d%% weapon damage as cold damage.
		At level 4 the attack becomes pure ice, giving a chance to freeze the target.
		Each point in cold drake talents also increases your cold resistance by 1%%.]]):format(100 * (1.4 + self:getTalentLevel(t) / 8))
	end,
}

newTalent{
	name = "Icy Skin",
	type = {"wild-gift/cold-drake", 2},
	require = gifts_req2,
	mode = "sustained",
	points = 5,
	cooldown = 10,
	sustain_equilibrium = 30,
	range = 10,
	tactical = { ATTACK = { COLD = 1 }, DEFEND = 2 },
	on_learn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) - 1 end,
	getDamage = function(self, t) return self:combatTalentStatDamage(t, "wil", 10, 700) / 10 end,
	getArmor = function(self, t) return self:combatTalentStatDamage(t, "wil", 6, 600) / 10 end,
	activate = function(self, t)
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.COLD]=t.getDamage(self, t)}),
			armor = self:addTemporaryValue("combat_armor", t.getArmor(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("combat_armor", p.armor)
		return true
	end,
	info = function(self, t)
		return ([[Your skin forms icy scales, damaging all that hit you for %0.2f cold damage and increasing your armor by %d.
		Each point in cold drake talents also increases your cold resistance by 1%%.
		The damage and defense will scale with your Willpower stat.]]):format(damDesc(self, DamageType.COLD, t.getDamage(self, t)), t.getArmor(self, t))
	end,
}

newTalent{
	name = "Ice Wall",
	type = {"wild-gift/cold-drake", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "defensive",
	equilibrium = 10,
	cooldown = 30,
	range = 10,
	tactical = { DISABLE = 2 },
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) - 1 end,
	action = function(self, t)
		local halflength = 1 + math.floor(self:getTalentLevel(t) / 2)
		local block = function(_, lx, ly)
			return game.level.map:checkAllEntities(lx, ly, "block_move")
		end
		local tg = {type="wall", range=self:getTalentRange(t), halflength=halflength, talent=t, halfmax_spots=halflength+1, block_radius=block}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end

		self:project(tg, x, y, function(px, py, tg, self)
			local oe = game.level.map(px, py, Map.TERRAIN)
			if oe.special then return end
			if not oe or oe:attr("temporary") or game.level.map:checkAllEntities(px, py, "block_move") then return end
			local e = Object.new{
				old_feat = oe,
				name = "ice wall", image = "npc/iceblock.png",
				type = "wall", subtype = "ice",
				display = '#', color=colors.LIGHT_BLUE, back_color=colors.BLUE,
				always_remember = true,
				can_pass = {pass_wall=1},
				block_move = true,
				block_sight = false,
				temporary = 4 + self:getTalentLevel(t),
				x =px, y = py,
				canAct = false,
				act = function(self)
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
						game.level:removeEntity(self)
						game.level.map:updateMap(self.x, self.y)
					end
				end,
				summoner_gain_exp = true,
				summoner = self,
			}
			
			game.level:addEntity(e)
			game.level.map(px, py, Map.TERRAIN, e)
		--	game.nicer_tiles:updateAround(game.level, px, py)
		--	game.level.map:updateMap(px, py)
		end)
		return true
	end,
	info = function(self, t)
		return ([[Summons an icy wall of %d length for %d turns. Ice walls are transparent.
		Each point in cold drake talents also increases your cold resistance by 1%%.]]):format(3 + math.floor(self:getTalentLevel(t) / 2) * 2, 4 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Ice Breath",
	type = {"wild-gift/cold-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ breathes ice!",
	tactical = { ATTACKAREA = { COLD = 2 }, DISABLE = { stun = 1 } },
	range = 0,
	radius = function(self, t) return 4 + self:getTalentLevelRaw(t) end,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) - 1 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ICE, self:mindCrit(self:combatTalentStatDamage(t, "str", 30, 430)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_cold", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[You breathe ice in a frontal cone of radius %d. Any target caught in the area will take %0.2f cold damage and has a 25%% to be frozen for a few turns(higher rank enemies will be frozen for a shorter time).
		The damage will increase with the Strength stat.
		Each point in cold drake talents also increases your cold resistance by 1%%.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.COLD, self:combatTalentStatDamage(t, "str", 30, 430)))
	end,
}

