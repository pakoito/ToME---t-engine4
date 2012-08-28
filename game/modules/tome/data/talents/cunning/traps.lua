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

local Map = require "engine.Map"

local trap_range = function(self, t) return 1 + math.floor(self:getTalentLevel(self.T_TRAP_LAUNCHER) * 1.2) end

----------------------------------------------------------------
-- Trapping
----------------------------------------------------------------

newTalent{
	name = "Trap Mastery",
	type = {"cunning/trapping", 1},
	points = 5,
	mode = "passive",
	require = cuns_req1,
	on_learn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 1 then
			self:learnTalent(self.T_EXPLOSION_TRAP, true, nil, {no_unlearn=true})
		elseif lev == 2 then
			self:learnTalent(self.T_BEAR_TRAP, true, nil, {no_unlearn=true})
		elseif lev == 3 then
			self:learnTalent(self.T_CATAPULT_TRAP, true, nil, {no_unlearn=true})
		elseif lev == 4 then
			self:learnTalent(self.T_DISARMING_TRAP, true, nil, {no_unlearn=true})
		elseif lev == 5 then
			self:learnTalent(self.T_NIGHTSHADE_TRAP, true, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 0 then
			self:unlearnTalent(self.T_EXPLOSION_TRAP)
		elseif lev == 1 then
			self:unlearnTalent(self.T_BEAR_TRAP)
		elseif lev == 2 then
			self:unlearnTalent(self.T_CATAPULT_TRAP)
		elseif lev == 3 then
			self:unlearnTalent(self.T_DISARMING_TRAP)
		elseif lev == 4 then
			self:unlearnTalent(self.T_NIGHTSHADE_TRAP)
		end
	end,
	info = function(self, t)
		return ([[Learn how to setup traps. Each level you will learn a new kind of trap:
		Level 1: Explosion Trap
		Level 2: Bear Trap
		Level 3: Catapult Trap
		Level 4: Disarm Trap
		Level 5: Nightshade Trap
		New traps can also be learned from special teachers in the world.
		Also increases the effectiveness of your traps by %d%%. (The effect varies for each trap)]]):
		format(self:getTalentLevel(t) * 20)
	end,
}

newTalent{
	name = "Lure",
	type = {"cunning/trapping", 2},
	points = 5,
	cooldown = 20,
	stamina = 15,
	no_break_stealth = true,
	require = cuns_req2,
	no_npc_use = true,
	range = function(self, t) return math.ceil(self:getTalentLevel(t) + 5) end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "construct", subtype = "lure",
			display = "*", color=colors.UMBER,
			name = "lure", faction = self.faction, image = "npc/lure.png",
			desc = [[A noisy lure.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented", ai_state = { talent_in=1, },
			level_range = {1, 1}, exp_worth = 0,

			max_life = 2 * self.level,
			life_rating = 0,
			never_move = 1,

			-- Hard to kill at range
			combat_armor = 10, combat_def = 0, combat_def_ranged = self.level * 2.2,
			-- Hard to kill with spells
			resists = {[DamageType.PHYSICAL] = -90, all = 90},

			talent_cd_reduction={[Talents.T_TAUNT]=2, },
			resolvers.talents{
				[self.T_TAUNT]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true,
			summon_time = 4 + self:getTalentLevelRaw(t),
		}
		if self:getTalentLevel(t) >= 5 then
			m.on_die = function(self, src)
				if not src or src == self then return end
				self:project({type="ball", range=0, radius=2}, self.x, self.y, function(px, py)
					local trap = game.level.map(px, py, engine.Map.TRAP)
					if not trap or not trap.lure_trigger then return end
					trap:trigger(px, py, src)
				end)
			end
		end

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")
		return true
	end,
	info = function(self, t)
		return ([[Project a noisy lure for %d turns that attracts all creatures in a radius %d to it.
		At level 5, when the lure is destroyed it will trigger some traps in a radius of 2 around it (check individual traps to see if they are triggered).
		This can be used while stealthed.]]):format(4 + self:getTalentLevelRaw(t), 3 + self:getTalentLevelRaw(t))
	end,
}
newTalent{
	name = "Sticky Smoke",
	type = {"cunning/trapping", 3},
	points = 5,
	cooldown = 15,
	stamina = 10,
	require = cuns_req3,
	no_break_stealth = true,
	reflectable = true,
	proj_speed = 10,
	requires_target = true,
	range = 10,
	tactical = { DISABLE = { blind = 2 } },
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.STICKY_SMOKE, math.ceil(self:getTalentLevel(t) * 1.2), {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Throws a vial of sticky smoke that explodes on your foe, reducing its vision range by %d for 5 turns.
		This can be used while stealthed.]]):
		format(math.ceil(self:getTalentLevel(t) * 1.2))
	end,
}

newTalent{
	name = "Trap Launcher",
	type = {"cunning/trapping", 4},
	points = 5,
	mode = "passive",
	require = cuns_req4,
	info = function(self, t)
		return ([[Allows you to create self deploying traps that you can launch up to %d grids away.]]):format(trap_range(self, t))
	end,
}

----------------------------------------------------------------
-- Traps
----------------------------------------------------------------

local basetrap = function(self, t, x, y, dur, add)
	local Trap = require "mod.class.Trap"
	local trap = {
		id_by_type=true, unided_name = "trap",
		display = '^',
		faction = self.faction,
		summoner = self, summoner_gain_exp = true,
		temporary = dur,
		x = x, y = y,
		canAct = false,
		energy = {value=0},
		act = function(self)
			if self.realact then self:realact() end
			self:useEnergy()
			self.temporary = self.temporary - 1
			if self.temporary <= 0 then
				if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
				game.level:removeEntity(self)
			end
		end,
	}
	table.merge(trap, add)
	return Trap.new(trap)
end

newTalent{
	name = "Explosion Trap",
	type = {"cunning/traps", 1},
	points = 1,
	cooldown = 8,
	stamina = 15,
	requires_target = true,
	range = trap_range,
	tactical = { ATTACKAREA = { FIRE = 2 } },
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local dam = 30 + self:getCun() * 0.8 * self:getTalentLevel(self.T_TRAP_MASTERY)

		local t = basetrap(self, t, x, y, 8 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "elemental", name = "explosion trap", color=colors.LIGHT_RED, image = "trap/blast_fire01.png",
			dam = dam,
			lure_trigger = true,
			triggered = function(self, x, y, who)
				self:project({type="ball", x=x,y=y, radius=2}, x, y, engine.DamageType.FIREBURN, self.dam)
				game.level.map:particleEmitter(x, y, 2, "fireflash", {radius=2, tx=x, ty=y})
				return true, true
			end,
		})
		t:identify(true)

		t:resolve() t:resolve(nil, true)
		t:setKnown(self, true)
		game.level:addEntity(t)
		game.zone:addEntity(game.level, t, "trap", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Lay a simple yet effective trap that explodes on contact, doing %0.2f fire damage over a few turns in a radius of 2.
		High level lure can trigger this trap.]]):
		format(damDesc(self, DamageType.FIRE, 30 + self:getCun() * 0.8 * self:getTalentLevel(self.T_TRAP_MASTERY)))
	end,
}

newTalent{
	name = "Bear Trap",
	type = {"cunning/traps", 1},
	points = 1,
	cooldown = 12,
	stamina = 10,
	requires_target = true,
	range = trap_range,
	tactical = { DISABLE = { pin = 2 } },
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local dam = (40 + self:getCun() * 0.7 * self:getTalentLevel(self.T_TRAP_MASTERY)) / 5

		local Trap = require "mod.class.Trap"
		local t = basetrap(self, t, x, y, 8 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "physical", name = "bear trap", color=colors.UMBER, image = "trap/beartrap01.png",
			dam = dam,
			check_hit = self:combatAttack(),
			triggered = function(self, x, y, who)
				if who and who:canBe("cut") then who:setEffect(who.EFF_CUT, 5, {src=self.summoner, power=self.dam}) end
				if who:canBe("pin") then
					who:setEffect(who.EFF_PINNED, 5, {apply_power=self.check_hit})
				else
					game.logSeen(who, "%s resists!", who.name:capitalize())
				end
				return true, true
			end,
		})
		t:identify(true)

		t:resolve() t:resolve(nil, true)
		t:setKnown(self, true)
		game.level:addEntity(t)
		game.zone:addEntity(game.level, t, "trap", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Lay a bear trap. The first creature passing by will be caught in the trap, unable to move and bleeding for %0.2f physical damage each turn for 5 turns.]]):
		format(damDesc(self, DamageType.PHYSICAL, (40 + self:getCun() * 0.7 * self:getTalentLevel(self.T_TRAP_MASTERY)) / 5))
	end,
}

newTalent{
	name = "Catapult Trap",
	type = {"cunning/traps", 1},
	points = 1,
	cooldown = 10,
	stamina = 15,
	requires_target = true,
	tactical = { DISABLE = { stun = 2 } },
	range = trap_range,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end


		local Trap = require "mod.class.Trap"
		local t = basetrap(self, t, x, y, 8 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "physical", name = "catapult trap", color=colors.LIGHT_UMBER, image = "trap/trap_catapult_01_64.png",
			dist = 2 + math.ceil(self:getTalentLevel(self.T_TRAP_MASTERY)),
			check_hit = self:combatAttack(),
			triggered = function(self, x, y, who)
				-- Try to knockback !
				local can = function(target)
					if target:checkHit(self.check_hit, target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
						return true
					else
						game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
					end
				end

				if can(who) then
					who:knockback(self.summoner.x, self.summoner.y, self.dist, can)
					if who:canBe("stun") then who:setEffect(who.EFF_DAZED, 5, {}) end
				end
				return true, rng.chance(25)
			end,
		})
		t:identify(true)

		t:resolve() t:resolve(nil, true)
		t:setKnown(self, true)
		game.level:addEntity(t)
		game.zone:addEntity(game.level, t, "trap", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Lay a catapult trap that knocks back any creatures by %d grids away and dazes them.]]):
		format(2 + math.ceil(self:getTalentLevel(self.T_TRAP_MASTERY)))
	end,
}

newTalent{
	name = "Disarming Trap",
	type = {"cunning/traps", 1},
	points = 1,
	cooldown = 25,
	stamina = 25,
	requires_target = true,
	tactical = { DISABLE = { disarm = 2 } },
	range = trap_range,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local Trap = require "mod.class.Trap"
		local t = basetrap(self, t, x, y, 8 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "physical", name = "disarming trap", color=colors.DARK_GREY, image = "trap/trap_magical_disarm_01_64.png",
			dur = 2 + math.ceil(self:getTalentLevel(self.T_TRAP_MASTERY) / 2),
			check_hit = self:combatAttack(),
			triggered = function(self, x, y, who)
				if who:canBe("disarm") then
					who:setEffect(who.EFF_DISARMED, self.dur, {apply_power=self.check_hit})
				else
					game.logSeen(who, "%s resists!", who.name:capitalize())
				end
				return true, true
			end,
		})
		t:identify(true)

		t:resolve() t:resolve(nil, true)
		t:setKnown(self, true)
		game.level:addEntity(t)
		game.zone:addEntity(game.level, t, "trap", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Lay a tricky trap that maims the arms of creatures passing by, disarming them for %d turns.]]):
		format(2 + math.ceil(self:getTalentLevel(self.T_TRAP_MASTERY) / 2))
	end,
}

newTalent{
	name = "Nightshade Trap",
	type = {"cunning/traps", 1},
	points = 1,
	cooldown = 8,
	stamina = 15,
	tactical = { DISABLE = { stun = 2 } },
	requires_target = true,
	range = trap_range,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local dam = 20 + self:getCun() * 0.7 * self:getTalentLevel(self.T_TRAP_MASTERY)

		local Trap = require "mod.class.Trap"
		local t = basetrap(self, t, x, y, 5 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "nature", name = "nightshade trap", color=colors.LIGHT_BLUE, image = "trap/poison_vines01.png",
			dam = dam,
			check_hit = self:combatAttack(),
			triggered = function(self, x, y, who)
				self:project({type="hit", x=x,y=y}, x, y, engine.DamageType.NATURE, self.dam, {type="slime"})
				if who:canBe("stun") then
					who:setEffect(who.EFF_STUNNED, 4, {src=self.summoner, apply_power=self.check_hit})
				end
				return true, true
			end,
		})
		t:identify(true)

		t:resolve() t:resolve(nil, true)
		t:setKnown(self, true)
		game.level:addEntity(t)
		game.zone:addEntity(game.level, t, "trap", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Lay a trap cotted with a potent venom, doing %0.2f nature damage to a creature and stunning it for 4 turns.]]):
		format(damDesc(self, DamageType.COLD, 20 + self:getCun() * 0.7 * self:getTalentLevel(self.T_TRAP_MASTERY)))
	end,
}

newTalent{
	name = "Flash Bang Trap",
	type = {"cunning/traps", 1},
	points = 1,
	cooldown = 12,
	stamina = 12,
	tactical = { DISABLE = { blind = 1, stun = 1 } },
	requires_target = true,
	range = trap_range,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local Trap = require "mod.class.Trap"
		local t = basetrap(self, t, x, y, 5 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "elemental", name = "flash bang trap", color=colors.YELLOW, image = "trap/blast_acid01.png",
			dur = math.floor(self:getTalentLevel(self.T_TRAP_MASTERY) + 4),
			check_hit = self:combatAttack(),
			lure_trigger = true,
			triggered = function(self, x, y, who)
				self:project({type="ball", x=x,y=y, radius=2}, x, y, function(px, py)
					local who = game.level.map(px, py, engine.Map.ACTOR)
					if who and who:canBe("blind") then
						who:setEffect(who.EFF_BLINDED, self.dur, {apply_power=self.check_hit})
					elseif who and who:canBe("stun") then
						who:setEffect(who.EFF_DAZED, self.dur, {apply_power=self.check_hit})
					elseif who then
						game.logSeen(who, "%s resists the flash bang!", who.name:capitalize())
					end
				end)
				game.level.map:particleEmitter(x, y, 2, "sunburst", {radius=2, tx=x, ty=y})
				return true, true
			end,
		})
		t:identify(true)

		t:resolve() t:resolve(nil, true)
		t:setKnown(self, true)
		game.level:addEntity(t)
		game.zone:addEntity(game.level, t, "trap", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Lay a trap that explodes in a radius of 2, blinding or dazing anything caught inside for %d turns.
		Duration increases with Trap Mastery.
		High level lure can trigger this trap.]]):
		format(math.floor(self:getTalentLevel(self.T_TRAP_MASTERY) + 4))
	end,
}

newTalent{
	name = "Poison Gas Trap",
	type = {"cunning/traps", 1},
	points = 1,
	cooldown = 10,
	stamina = 12,
	tactical = { ATTACKAREA = { poison = 2 } },
	requires_target = true,
	range = trap_range,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local dam = 20 + self:getCun() * 0.5 * self:getTalentLevel(self.T_TRAP_MASTERY)

		-- Need to pass the actor in to the triggered function for the apply_power to work correctly
		local t = basetrap(self, t, x, y, 8 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "nature", name = "poison gas trap", color=colors.LIGHT_RED, image = "trap/blast_acid01.png",
			dam = dam,
			check_hit = self:combatAttack(),
			lure_trigger = true,
			triggered = function(self, x, y, who)
				-- Add a lasting map effect
				game.level.map:addEffect(self,
					x, y, 4,
					engine.DamageType.POISON, {dam=self.dam, apply_power=self.check_hit},
					3,
					5, nil,
					{type="vapour"},
					nil, true
				)
				game:playSoundNear(self, "talents/cloud")
				return true, true
			end,
		})
		t:identify(true)

		t:resolve() t:resolve(nil, true)
		t:setKnown(self, true)
		game.level:addEntity(t)
		game.zone:addEntity(game.level, t, "trap", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Lay a trap that explodes in a radius of 3, releasing a thick poisonous cloud lasting 4 turns.
		Each turn the cloud infects all creatures with a poison that deals %0.2f nature damage over 5 turns.
		High level lure can trigger this trap.]]):
		format(20 + self:getCun() * 0.5 * self:getTalentLevel(self.T_TRAP_MASTERY))
	end,
}

newTalent{
	name = "Gravitic Trap",
	type = {"cunning/traps", 1},
	points = 1,
	cooldown = 15,
	stamina = 12,
	tactical = { ATTACKAREA = { temporal = 2 } },
	requires_target = true,
	is_spell = true,
	range = trap_range,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local dam = 20 + self:getCun() * 0.5 * self:getTalentLevel(self.T_TRAP_MASTERY)

		-- Need to pass the actor in to the triggered function for the apply_power to work correctly
		local t = basetrap(self, t, x, y, 8 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "arcane", name = "gravitic trap", color=colors.LIGHT_RED, image = "invis.png",
			embed_particles = {{name="wormhole", rad=1, args={image="shockbolt/terrain/wormhole", speed=1}}},
			dam = dam,
			check_hit = self:combatAttack(),
			triggered = function(self, x, y, who)
				return true, true
			end,
			realact = function(self)
				local tgts = {}
				self:project({type="ball", range=0, friendlyfire=false, radius=5, talent=t}, self.x, self.y, function(px, py)
					local target = game.level.map(px, py, Map.ACTOR)
					if not target then return end
					if self:reactionToward(target) < 0 and not tgts[target] then
						tgts[target] = true
						local ox, oy = target.x, target.y
						target:pull(self.x, self.y, 1)
						if target.x ~= ox or target.y ~= oy then
							game.logSeen(target, "%s is pulled in!", target.name:capitalize())
							DamageType:get(DamageType.TEMPORAL).projector(self.summoner, target.x, target.y, DamageType.TEMPORAL, self.dam)
						end
					end
				end)
			end,
		})
		t:identify(true)

		t:resolve() t:resolve(nil, true)
		t:setKnown(self, true)
		game.level:addEntity(t)
		game.zone:addEntity(game.level, t, "trap", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Lay a trap that explodes in a radius of 3, releasing a thick poisonous cloud lasting 4 turns.
		Each turn the cloud infects all creatures with a poison that deals %0.2f nature damage over 5 turns.
		High level lure can trigger this trap.]]):
		format(20 + self:getCun() * 0.5 * self:getTalentLevel(self.T_TRAP_MASTERY))
	end,
}
