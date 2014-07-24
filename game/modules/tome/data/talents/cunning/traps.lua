-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

local trap_range = function(self, t)
	if not self:knowTalent(self.T_TRAP_LAUNCHER) then return 1 end
	return math.floor(self:combatTalentScale(self:getTalentLevel(self.T_TRAP_LAUNCHER), 2, 7, "log")) -- 2@1, 7@5
end
local trapPower = function(self,t) return math.max(1,self:combatScale(self:getTalentLevel(self.T_TRAP_MASTERY) * self:getCun(15, true), 0, 0, 75, 75)) end -- Used to determine detection and disarm power, about 75 at level 50
----------------------------------------------------------------
-- Trapping
----------------------------------------------------------------

newTalent{
	name = "Trap Mastery",
	type = {"cunning/trapping", 1},
	points = 5,
	mode = "passive",
	require = cuns_req1,
	getTrapMastery = function(self, t) return self:combatTalentScale(t, 20, 100, 0.5, 0, 0, true) end,
	getPower = trapPower,
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
		local detect_power = t.getPower(self, t)
		local disarm_power = t.getPower(self, t)*1.25
		return ([[Learn how to set up traps. You will learn new traps as follows:
		Level 1: Explosion Trap
		Level 2: Bear Trap
		Level 3: Catapult Trap
		Level 4: Disarm Trap
		Level 5: Nightshade Trap
		New traps can also be learned from special teachers in the world.
		This talent also increases the effectiveness of your traps by %d%% (The effect varies for each trap.) and makes them more difficult to detect and disarm (%d detection 'power' and %d disarm 'power') based on your Cunning.
		If a trap is not triggered 80%% of its stamina cost will be refunded when it expires.]]):
		format(t.getTrapMastery(self,t), detect_power, disarm_power) --I5
	end,
}

newTalent{
	name = "Lure",
	type = {"cunning/trapping", 2},
	points = 5,
	cooldown = 15,
	stamina = 15,
	no_break_stealth = true,
	require = cuns_req2,
	no_npc_use = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 6, 11)) end,
	getDuration = function(self,t) return math.floor(self:combatTalentScale(t, 5, 9, 0.5, 0, 0, true)) end,
	speed = "combat",
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
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
			poison_immune = 1,

			talent_cd_reduction={[Talents.T_TAUNT]=2, },
			resolvers.talents{
				[self.T_TAUNT]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self,t),
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
		local t2 = self:getTalentFromId(self.T_TAUNT)
		local rad = t2.radius(self, t)
		return ([[Project a noisy lure for %d turns that attracts all creatures in a radius %d to it.
		At level 5, when the lure is destroyed, it will trigger some traps in a radius of 2 around it (check individual traps to see if they are triggered).
		Use of this talent will not break stealth.]]):format(t.getDuration(self,t), rad)
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
	speed = "combat",
	radius = function(self, t) return math.max(0,math.floor(self:combatTalentScale(t, 0.5, 2.5))) end,
	getSightLoss = function(self, t) return math.floor(self:combatTalentScale(t,1, 6, "log", 0, 4)) end, -- 1@1 6@5
	tactical = { DISABLE = { blind = 2 } },
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t, display={particle="bolt_dark"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.STICKY_SMOKE, t.getSightLoss(self,t), {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Throws a vial of sticky smoke that explodes in radius %d on your foes, reducing their vision range by %d for 5 turns.
		Creatures affected by smoke bomb can never prevent you from stealthing, even if their proximity would normally forbid it.
		Use of this will not break stealth.]]):
		format(self:getTalentRadius(t), t.getSightLoss(self,t))
	end,
}

newTalent{
	name = "Trap Launcher",
	type = {"cunning/trapping", 4},
	points = 5,
	mode = "passive",
	require = cuns_req4,
	info = function(self, t)
		return ([[Allows you to create self deploying traps that you can launch up to %d grids away.
		At level 5 you learn to do this in total silence, letting you lay traps without breaking stealth.]]):format(trap_range(self, t))
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
		detect_power = math.floor(trapPower(self,t)),
		disarm_power = math.floor(trapPower(self,t)*1.25),
		canAct = false,
		energy = {value=0},
		inc_damage = table.clone(self.inc_damage or {}, true),
		resists_pen = table.clone(self.resists_pen or {}, true),
		act = function(self)
			if self.realact then self:realact() end
			self:useEnergy()
			self.temporary = self.temporary - 1
			if self.temporary <= 0 then
				if game.level.map(self.x, self.y, engine.Map.TRAP) == self then
					game.level.map:remove(self.x, self.y, engine.Map.TRAP)
					if self.summoner and self.stamina then -- Refund
						self.summoner:incStamina(self.stamina * 0.8)
					end
				end
				game.level:removeEntity(self)
			end
		end,
	}
	table.merge(trap, add)
	return Trap.new(trap)
end

function trap_stealth(self, t)
	if self:getTalentLevel(self.T_TRAP_LAUNCHER) >= 5 then
		return true
	end
	return false
end

newTalent{
	name = "Explosion Trap",
	type = {"cunning/traps", 1},
	points = 1,
	cooldown = 8,
	stamina = 15,
	requires_target = true,
	range = trap_range,
	no_break_stealth = trap_stealth,
	tactical = { ATTACKAREA = { FIRE = 2 } },
	no_unlearn_last = true,
	speed = "combat",
	getDamage = function(self, t) return 30 + self:combatStatScale("cun", 8, 80) * self:callTalent(self.T_TRAP_MASTERY, "getTrapMastery")/20 end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local dam = t.getDamage(self, t)
		local t = basetrap(self, t, x, y, 8 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "elemental", name = "explosion trap", color=colors.LIGHT_RED, image = "trap/blast_fire01.png",
			dam = dam,
			stamina = t.stamina,
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
		format(damDesc(self, DamageType.FIRE, t.getDamage(self, t)))
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
	no_break_stealth = trap_stealth,
	no_unlearn_last = true,
	getDamage = function(self, t) return (40 + self:combatStatScale("cun", 10, 100) * self:callTalent(self.T_TRAP_MASTERY, "getTrapMastery")/20)/5 end,
	speed = "combat",
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local dam = t.getDamage(self, t)
		local Trap = require "mod.class.Trap"
		local t = basetrap(self, t, x, y, 8 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "physical", name = "bear trap", color=colors.UMBER, image = "trap/beartrap01.png",
			dam = dam,
			stamina = t.stamina,
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
		return ([[Lay a bear trap. The first creature passing by will be caught in the trap, pinned and bleeding for %0.2f physical damage each turn for 5 turns.]]):
		format(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t))) --I5
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
	no_break_stealth = trap_stealth,
	no_unlearn_last = true,
	getDistance = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(self.T_TRAP_MASTERY), 3, 7)) end,
	speed = "combat",
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end


		local Trap = require "mod.class.Trap"
		local t = basetrap(self, t, x, y, 8 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "physical", name = "catapult trap", color=colors.LIGHT_UMBER, image = "trap/trap_catapult_01_64.png",
			dist = t.getDistance(self, t),
			check_hit = self:combatAttack(),
			stamina = t.stamina,
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
		return ([[Lay a catapult trap that knocks back any creature that steps over it up to %d grids away, dazing them.]]):
		format(t.getDistance(self, t))
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
	no_break_stealth = trap_stealth,
	no_unlearn_last = true,
	getDamage = function(self, t) return 60 + self:combatStatScale("cun", 9, 90) * self:callTalent(self.T_TRAP_MASTERY,"getTrapMastery")/20 end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(self.T_TRAP_MASTERY), 2.1, 4.43)) end,
	speed = "combat",
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local Trap = require "mod.class.Trap"
		local dam = t.getDamage(self, t)
		local t = basetrap(self, t, x, y, 8 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "physical", name = "disarming trap", color=colors.DARK_GREY, image = "trap/trap_magical_disarm_01_64.png",
			dur = t.getDuration(self, t),
			check_hit = self:combatAttack(),
			dam = dam,
			stamina = t.stamina,
			triggered = function(self, x, y, who)
				self:project({type="hit", x=x,y=y}, x, y, engine.DamageType.ACID, self.dam, {type="acid"})
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
		return ([[Lay a tricky trap that maims the arms of creatures passing by with acid doing %0.2f damage and disarming them for %d turns.]]):
		format(damDesc(self, DamageType.ACID, t.getDamage(self, t)), t.getDuration(self, t))
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
	no_break_stealth = trap_stealth,
	no_unlearn_last = true,
	getDamage = function(self, t) return 20 + self:combatStatScale("cun", 10, 100) * self:callTalent(self.T_TRAP_MASTERY,"getTrapMastery")/20 end,
	speed = "combat",
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local dam = t.getDamage(self, t)
		local Trap = require "mod.class.Trap"
		local t = basetrap(self, t, x, y, 5 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "nature", name = "nightshade trap", color=colors.LIGHT_BLUE, image = "trap/poison_vines01.png",
			dam = dam,
			stamina = t.stamina,
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
		return ([[Lay a trap coated with a potent venom, doing %0.2f nature damage to a creature passing by and stunning it for 4 turns.]]):
		format(damDesc(self, DamageType.NATURE, t.getDamage(self, t)))
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
	no_break_stealth = trap_stealth,
	no_unlearn_last = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(self.T_TRAP_MASTERY), 2.5, 4.5)) end,
	getDamage = function(self, t) return 20 + self:combatStatScale("cun", 5, 50) * self:callTalent(self.T_TRAP_MASTERY,"getTrapMastery") / 30 end,
	speed = "combat",
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local Trap = require "mod.class.Trap"
		local dam = t.getDamage(self, t)
		local t = basetrap(self, t, x, y, 5 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "elemental", name = "flash bang trap", color=colors.YELLOW, image = "trap/blast_acid01.png",
			dur = t.getDuration(self, t),
			check_hit = self:combatAttack(),
			lure_trigger = true,
			stamina = t.stamina,
			dam = dam,
			triggered = function(self, x, y, who)
				self:project({type="ball", x=x,y=y, radius=2}, x, y, function(px, py)
					local who = game.level.map(px, py, engine.Map.ACTOR)
					if who == self.summoner then return end
					if who and who:canBe("blind") then
						who:setEffect(who.EFF_BLINDED, self.dur, {apply_power=self.check_hit})
					elseif who and who:canBe("stun") then
						who:setEffect(who.EFF_DAZED, self.dur, {apply_power=self.check_hit})
					elseif who then
						game.logSeen(who, "%s resists the flash bang!", who.name:capitalize())
					end
					engine.DamageType:get(engine.DamageType.PHYSICAL).projector(self.summoner, px, py, engine.DamageType.PHYSICAL, self.dam)
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
		The duration increases with Trap Mastery.
		All foes caught inside take %0.2f physical damage.
		High level lure can trigger this trap.]]):
		format(t.getDuration(self, t), damDesc(self, engine.DamageType.PHYSICAL, t.getDamage(self, t)))
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
	no_break_stealth = trap_stealth,
	no_unlearn_last = true,
	getDamage = function(self, t) return 20 + self:combatStatScale("cun", 5, 50) * self:callTalent(self.T_TRAP_MASTERY,"getTrapMastery")/20 end,
	speed = "combat",
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local dam = t.getDamage(self, t)
		-- Need to pass the actor in to the triggered function for the apply_power to work correctly
		local t = basetrap(self, t, x, y, 8 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "nature", name = "poison gas trap", color=colors.LIGHT_RED, image = "trap/blast_acid01.png",
			dam = dam,
			check_hit = self:combatAttack(),
			stamina = t.stamina,
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
		Each turn, the cloud infects all creatures with a poison that deals %0.2f nature damage over 5 turns.
		High level lure can trigger this trap.]]):
		format(damDesc(self, DamageType.POISON, t.getDamage(self, t)))
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
	no_break_stealth = trap_stealth,
	no_unlearn_last = true,
	getDamage = function(self, t) return 20 + self:combatStatScale("cun", 5, 50) * self:callTalent(self.T_TRAP_MASTERY,"getTrapMastery") / 40 end,
	speed = "combat",
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the trap.") return nil end
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then game.logPlayer(self, "You somehow fail to set the trap.") return nil end

		local dam = t.getDamage(self, t)
		-- Need to pass the actor in to the triggered function for the apply_power to work correctly
		local t = basetrap(self, t, x, y, 8 + self:getTalentLevel(self.T_TRAP_MASTERY), {
			type = "arcane", name = "gravitic trap", color=colors.LIGHT_RED, image = "invis.png",
			embed_particles = {{name="wormhole", rad=1, args={image="shockbolt/terrain/wormhole", speed=1}}},
			dam = dam,
			stamina = t.stamina,
			check_hit = self:combatAttack(),
			triggered = function(self, x, y, who)
				return true, true
			end,
			realact = function(self)
				local tgts = {}
				self:project({type="ball", range=0, friendlyfire=false, radius=5, talent=t}, self.x, self.y, function(px, py)
					local target = game.level.map(px, py, engine.Map.ACTOR)
					if not target then return end
					if self:reactionToward(target) < 0 and not tgts[target] then
						tgts[target] = true
						local ox, oy = target.x, target.y
						engine.DamageType:get(engine.DamageType.TEMPORAL).projector(self.summoner, target.x, target.y, engine.DamageType.TEMPORAL, self.dam)
						if target:canBe("knockback") then
							target:pull(self.x, self.y, 1)
							if target.x ~= ox or target.y ~= oy then
								self.summoner:logCombat(target, "#Target# is pulled towards #Source#'s gravity trap!")
							end
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
		return ([[Lay a trap that creates a gravitic anomaly, pulling in all foes around it in a radius of 5.
		All foes caught inside take %0.2f temporal damage per turn.]]):
		format(damDesc(self, engine.DamageType.TEMPORAL, t.getDamage(self, t)))
	end,
}
