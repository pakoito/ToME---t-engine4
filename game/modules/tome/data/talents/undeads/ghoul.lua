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
	name = "Ghoul",
	type = {"undead/ghoul", 1},
	mode = "passive",
	require = undeads_req1,
	points = 5,
	on_learn = function(self, t)
		self.inc_stats[self.STAT_STR] = self.inc_stats[self.STAT_STR] + 2
		self:onStatChange(self.STAT_STR, 2)
		self.inc_stats[self.STAT_CON] = self.inc_stats[self.STAT_CON] + 2
		self:onStatChange(self.STAT_CON, 2)
	end,
	on_unlearn = function(self, t)
		self.inc_stats[self.STAT_STR] = self.inc_stats[self.STAT_STR] - 2
		self:onStatChange(self.STAT_STR, -2)
		self.inc_stats[self.STAT_CON] = self.inc_stats[self.STAT_CON] - 2
		self:onStatChange(self.STAT_CON, -2)
	end,
	info = function(self, t)
		return ([[Improves your ghoulish body, increasing strength and constitution by %d.]]):format(2 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Ghoulish Leap",
	type = {"undead/ghoul", 2},
	require = undeads_req2,
	points = 5,
	cooldown = 20,
	tactical = { CLOSEIN = 3 },
	direct_hit = true,
	range = function(self, t) return math.floor(4 + self:getTalentLevel(t) * 1.2) end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local l = self:lineFOV(x, y, block_actor)
		local lx, ly, is_corner_blocked = l:step()
		local tx, ty, _ = lx, ly
		while lx and ly do
			if is_corner_blocked or block_actor(_, lx, ly) then break end
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
		end

		-- Find space
		if block_actor(_, tx, ty) then return nil end
		local fx, fy = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not fx then
			return
		end
		self:move(fx, fy, true)

		return true
	end,
	info = function(self, t)
		return ([[Leap toward your target.]])
	end,
}

newTalent{
	name = "Retch",
	type = {"undead/ghoul",3},
	require = undeads_req3,
	points = 5,
	cooldown = 25,
	tactical = { ATTACK = { BLIGHT = 1 }, HEAL = 1 },
	range=1,
	requires_target = true,
	action = function(self, t)
		local duration = self:getTalentLevelRaw(t) * 2 + 5
		local radius = 3
		local dam = 10 + self:combatTalentStatDamage(t, "con", 10, 60)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.RETCH, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=30, color_bg=180, color_bb=60},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local dam = 10 + self:combatTalentStatDamage(t, "con", 10, 60)
		return ([[Vomit on the ground around you, healing any undead in the area and damaging others.
		Lasts %d turns and deals %d blight damage or heals %d life.]]):format(self:getTalentLevelRaw(t) * 2 + 5, damDesc(self, DamageType.BLIGHT, dam), dam * 1.5)
	end,
}

newTalent{
	name = "Gnaw",
	type = {"undead/ghoul", 4},
	require = undeads_req4,
	points = 5,
	cooldown = 15,
	tactical = { ATTACK = {BLIGHT = 2} },
	range = 1,
	requires_target = true,
	getDamage = function(self, t) return 0.2 + self:getTalentLevel(t) / 12 end,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	getDiseaseDamage = function(self, t) return self:combatTalentStatDamage(t, "con", 5, 50) end,
	getStatDamage = function(self, t) return self:combatTalentStatDamage(t, "con", 5, 20) end,
	spawn_ghoul = function (self, target, t)
		local x, y = util.findFreeGrid(target.x, target.y, 10, true, {[Map.ACTOR]=true})
		if not x then return nil end

		local list = mod.class.NPC:loadList("/data/general/npcs/ghoul.lua")
		local m = list.GHOUL:clone()
		if not m then return nil end

		m:resolve() m:resolve(nil, true)
		m.ai = "summoned"
		m.ai_real = "dumb_talented_simple"
		m.faction = self.faction
		m.summoner = self
		m.summoner_gain_exp = true
		m.summon_time = 20
		m.exp_worth = 0
		m.no_drops = true
		
		game.zone:addEntity(game.level, m, "actor", target.x, target.y)
		game.level.map:particleEmitter(target.x, target.y, 1, "slime")
		game:playSoundNear(target, "talents/slime")
		game.logPlayer(game.player, "A #DARK_GREEN#ghoul#LAST# rises from the corpse of %s.", target.name)
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

		-- Damage Stats?
		local str_damage, con_damage, dex_damage = 0
		if self:getTalentLevel(t) >=2 then str_damage = t.getStatDamage(self, t) end
		if self:getTalentLevel(t) >=3 then dex_damage = t.getStatDamage(self, t) end
		if self:getTalentLevel(t) >=4 then con_damage = t.getStatDamage(self, t) end
		
		-- Ghoulify??
		local ghoulify = 0
		if self:getTalentLevel(t) >=5 then ghoulify = 1 end
		
		if hitted then
			if target:canBe("disease") then
				if target.dead and ghoulify > 0 then
					t.spawn_ghoul(self, target, t)
				end
				target:setEffect(target.EFF_GHOUL_ROT, 3 + math.ceil(self:getTalentLevel(t)), {src=self, apply_power=self:combatPhysicalpower(), dam=t.getDiseaseDamage(self, t), str=str_damage, con=con_damage, dex=dex_damage, make_ghoul=ghoulify})
			else
				game.logSeen(target, "%s resists the disease!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local disease_damage = t.getDiseaseDamage(self, t)
		local stat_damage = t.getStatDamage(self, t)
		return ([[Gnaw your target for %d%% damage.  If your attack hits, the target may be infected with ghoul rot for %d turns.
		Each turn Ghoul Rot inflicts %0.2f blight damage.  At talent level two Ghoul Rot also reduces Strength by %d, at level three it reduces Dexterity by %d, and at level four it reduces Constitution by %d.
		At talent level five targets suffering from Ghoul Rot rise as friendly ghouls when slain.
		The blight damage and stat damage scales with your Constitution.]]):
		format(100 * damage, duration, damDesc(self, DamageType.BLIGHT, disease_damage), stat_damage, stat_damage, stat_damage)
	end,
}

