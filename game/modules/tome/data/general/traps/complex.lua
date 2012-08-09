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

local DamageType = require "engine.DamageType"

newEntity{ define_as = "TRAP_COMPLEX",
	type = "complex", id_by_type=true, unided_name = "trap",
	display = '^',
	triggered = function(self, x, y, who)
		return true
	end,
}

newEntity{ base = "TRAP_COMPLEX",
	subtype = "boulder",
	name = "giant boulder trap", image = "trap/trap_pressure_plate_01.png",
	detect_power = resolvers.mbonus(40, 5), disarm_power = resolvers.mbonus(50, 10),
	rarity = 3, level_range = {1, nil},
	color = colors.UMBER,
	message = "@Target@ walks on a trap, there is a loud noise.",
	pressure_trap = true,
	on_added = function(self, level, x, y)
		local walls = {}
		for i, dir in ipairs{4,6,8,2} do
			local i, j = x, y
			local g
			repeat
				i, j = util.coordAddDir(i, j, dir)
				g = game.level.map(i, j, engine.Map.TERRAIN)
			until not g or g:check("block_move")
			if g and not g.is_door and core.fov.distance(x, y, i, j) >= 2 then
				i, j = util.coordAddDir(i, j, util.opposedDir(dir, i, j))
				walls[#walls+1] = {x=i, y=j}
			end
		end
		if #walls == 0 then game.level.map:remove(x, y, engine.Map.TRAP) return end

		local spot = rng.table(walls)
		local l = line.new(spot.x, spot.y, x, y)
		self.spawn_x, self.spawn_y = l()
		print("Boulder trap spawn", self.spawn_x, self.spawn_y)
		self.x, self.y = x, y
		self.on_added = nil
	end,
	str = resolvers.mbonus(200, 30),
	dam = resolvers.mbonus_level(300, 5),
	combatPhysicalpower = function(self) return mod.class.interface.Combat:rescaleCombatStats(self.str) end,
	triggered = function(self, x, y, who)
		if not self.spawn_x then return end
		local tg = {name="huge boulder", type="bolt", range=core.fov.distance(x, y, self.spawn_x, self.spawn_y), x=self.spawn_x, y=self.spawn_y, speed=2, display={image="trap/trap_big_boulder_01.png"}, blur_move=4}
		self:projectile(tg, x, y, engine.DamageType.PHYSKNOCKBACK, {dam=self.dam, dist=3, x=self.spawn_x, y=self.spawn_y})
		return true
	end,
}

newEntity{ base = "TRAP_COMPLEX",
	subtype = "arcane",
	name = "spinning beam", image = "trap/trap_glyph_explosion_01_64.png",
	detect_power = resolvers.mbonus(40, 5), disarm_power = resolvers.mbonus(50, 10),
	rarity = 3, level_range = {1, nil},
	color=colors.PURPLE,
	message = "@Target@ walks on a trap, the beam changes.",
	on_added = function(self, level, x, y)
		self.x, self.y = x, y
		self.rad = rng.range(2, 8)
		local tries = {}
		local list = {i=1}
		local sa = rng.range(0, 359)
		local dir = rng.percent(50) and 1 or -1
		for a = sa, sa + 359 * dir, dir do
			local rx, ry = math.floor(math.cos(math.rad(a)) * self.rad), math.floor(math.sin(math.rad(a)) * self.rad)
			if not tries[rx] or not tries[rx][ry] then
				tries[rx] = tries[rx] or {}
				tries[rx][ry] = true
				list[#list+1] = {x=rx+x, y=ry+y}
			end
		end
		self.list = list
		self.on_added = nil
	end,
	dammode = rng.table{engine.DamageType.ARCANE_SILENCE, engine.DamageType.DARKSTUN, engine.DamageType.COLDNEVERMOVE},
	dam = resolvers.mbonus_level(300, 5),
	mag = resolvers.mbonus(200, 30),
	combatSpellpower = function(self) return mod.class.interface.Combat:rescaleCombatStats(self.mag) end,
	triggered = function(self, x, y, who)
		if self:reactionToward(who) < 0 then
			local dammode = self.dammode
			while dammode == self.dammode do dammode = rng.table{engine.DamageType.ARCANE_SILENCE, engine.DamageType.DARKSTUN, engine.DamageType.COLDNEVERMOVE} end
			self.dammode = dammode

			if not self.added_to_level then game.level:addEntity(self) self.added_to_level = true end
		end
		return true
	end,
	disarmed = function(self, x, y, who)
		game.level:removeEntity(self, true)
	end,
	canAct = false,
	energy = {value=0},
	act = function(self)
		if game.level.map(self.x, self.y, engine.Map.TRAP) ~= self then game.level:removeEntity(self, true) return end

		local x, y = self.list[self.list.i].x, self.list[self.list.i].y
		self.list.i = util.boundWrap(self.list.i + 1, 1, #self.list)

		local tg = {type="beam", range=self.rad, friendlyfire=false}
		self:project(tg, x, y, self.dammode, self.dam, nil)
		local _ _, x, y = self:canProject(tg, x, y)
		if self.dammode == engine.DamageType.ARCANE_SILENCE then
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "mana_beam", {tx=x-self.x, ty=y-self.y})
		elseif self.dammode == engine.DamageType.DARKSTUN then
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "dark_lightning", {tx=x-self.x, ty=y-self.y})
		elseif self.dammode == engine.DamageType.COLDNEVERMOVE then
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "icebeam", {tx=x-self.x, ty=y-self.y})
		end

		self:useEnergy()
	end,
}

newEntity{ base = "TRAP_COMPLEX",
	subtype = "nature",
	name = "poison cloud", image = "trap/trap_acid_blast_01.png",
	detect_power = resolvers.mbonus(40, 5), disarm_power = resolvers.mbonus(50, 10),
	rarity = 3, level_range = {1, nil},
	color=colors.GREEN,
	message = "@Target@ walks on a poison spore.",
	on_added = function(self, level, x, y)
		self.x, self.y = x, y
		self.rad = rng.range(2, 8)
		self.on_added = nil
	end,
	dam = resolvers.mbonus_level(450, 30),
	triggered = function(self, x, y, who)
		if self:reactionToward(who) < 0 then
			if not self.added_to_level then game.level:addEntity(self) self.added_to_level = true end
			self:firePoison()
		end
		return true
	end,
	disarmed = function(self, x, y, who)
		game.level:removeEntity(self, true)
	end,
	canAct = false,
	energy = {value=0},
	nb = 3,
	firePoison = function(self)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, 5,
			engine.DamageType.POISON, {dam=self.dam, power=self.dam},
			self.rad,
			5, nil,
			{type="vapour"},
			nil, 0, 100
		)
		self:useEnergy(game.energy_to_act * 7)
		self.nb = self.nb - 1
	end,
	act = function(self)
		if game.level.map(self.x, self.y, engine.Map.TRAP) ~= self then game.level:removeEntity(self, true) return end
		if self.nb <= 0 then game.level:removeEntity(self, true) print("The poison spore looks somewhat drained.") return end

		local ok = false
		local tg = {type="ball", radius=self.rad, friendlyfire=false}
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if target and self:reactionToward(target) < 0 then ok = true end
		end)
		if not ok then
			self:useEnergy()
		else
			self:firePoison()
		end
	end,
}

newEntity{ base = "TRAP_COMPLEX",
	subtype = "arcane",
	name = "delayed explosion trap", image = "trap/trap_fire_rune_01.png",
	detect_power = resolvers.mbonus(40, 5), disarm_power = resolvers.mbonus(50, 10),
	rarity = 3, level_range = {1, nil},
	color=colors.RED,
	pressure_trap = true,
	message = "Flames start to appear arround @target@.",
	dam = resolvers.mbonus_level(300, 15),
	triggered = function(self, x, y, who)
		if self:reactionToward(who) >= 0 then return end

		local ps, p = {}, self.points or {}
		self.x, self.y = x, y
		self:project({type="ball", radius=3}, x, y, function(px, py)
			local g = game.level.map(px, py, engine.Map.TERRAIN)
			if not g:check("block_move") then
				ps[#ps+1] = {x=px, y=py}
			end
		end)
		for i = 1, 4 do
			if #ps == 0 then break end
			p[#p+1] = rng.tableRemove(ps)
			p[#p].e = game.level.map:particleEmitter(p[#p].x, p[#p].y, 1, "bolt_fire")
		end
		self.points = p

		game.level:addEntity(self)
		return true
	end,
	canAct = false,
	energy = {value=0, mod=0.20},
	act = function(self)
		local tg = {type="ball", radius=1, friendlyfire=false}
		for i, d in ipairs(self.points) do
			game.level.map:removeParticleEmitter(d.e)
			self:project(tg, d.x, d.y, engine.DamageType.FIRE, self.dam, nil)
			game.level.map:particleEmitter(d.x, d.y, 1, "ball_fire", {radius=1})
		end
		self.points = {}
		self:useEnergy()
		game.level:removeEntity(self)
	end,
}

newEntity{ base = "TRAP_COMPLEX",
	subtype = "arcane",
	name = "cold flames trap", image = "trap/trap_frost_rune_01.png",
	detect_power = resolvers.mbonus(40, 5), disarm_power = resolvers.mbonus(50, 10),
	rarity = 3, level_range = {1, nil},
	color=colors.BLUE,
	pressure_trap = true,
	message = "Cold flames start to appear arround @target@.",
	dam = resolvers.mbonus_level(150, 5),
	triggered = function(self, x, y, who)
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			name = "cold flames trap",
			type = "trap", subtype = "arcane",
			combatSpellpower = function(self) return self.dam end,
			getTarget = function(self) return self.x, self.y end,
			dam = self.dam,
			x = x, y = y,
			faction = self.faction,
		}
		m:forceUseTalent(m.T_COLD_FLAMES, {ignore_cd=true, ignore_energy=true, force_level=2, ignore_ressources=true})
		return true
	end,
}
