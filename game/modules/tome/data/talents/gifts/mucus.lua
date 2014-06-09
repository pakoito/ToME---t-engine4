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

isOnMucus = function(map, x, y)
	for i, e in ipairs(map.effects) do
		if e.damtype == DamageType.MUCUS and e.grids[x] and e.grids[x][y] then return true end
	end
end

newTalent{
	name = "Mucus",
	type = {"wild-gift/mucus", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 0,
	cooldown = 20,
	no_energy = true,
	tactical = { BUFF = 2, EQUILIBRIUM = 2,
		ATTACKAREA = function(self, t)
			if self:getTalentLevel(t)>=4 then return {NATURE = 1 } end
		end
	},
	getDur = function(self, t) return math.floor(self:combatTalentLimit(t, 20, 4, 6.5)) end, -- Limit < 20
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	-- note meditation recovery: local pt = 2 + self:combatTalentMindDamage(t, 20, 120) / 10 = O(<1)
	getEqui = function(self, t) return self:combatTalentMindDamage(t, 2, 8) end,
	-- Called by MUCUS effect in mod.data.timed_effects.physical.lua
	trigger = function(self, t, x, y, rad, eff) -- avoid stacking on map tile
		local oldmucus = eff and eff[x] and eff[x][y] -- get previous mucus at this spot
		if not oldmucus or oldmucus.duration <= 0 then -- make new mucus
			local mucus=game.level.map:addEffect(self,
				x, y, t.getDur(self, t),
				DamageType.MUCUS, {dam=t.getDamage(self, t), self_equi=t.getEqui(self, t), equi=1, bonus_level = 0},
				rad,
				5, nil,
				{zdepth=6, type="mucus"},
				nil, true
			)
			if eff then
				eff[x] = eff[x] or {}
				eff[x][y]=mucus
			end
		else
			if oldmucus.duration > 0 then -- Enhance existing mucus
				oldmucus.duration = t.getDur(self, t)
				oldmucus.dam.bonus_level = oldmucus.dam.bonus_level + 1
				oldmucus.dam.self_equi = oldmucus.dam.self_equi + 1
				oldmucus.dam.dam = t.getDamage(self, t) * (1+ self:combatTalentLimit(oldmucus.dam.bonus_level, 1, 0.25, 0.7)) -- Limit < 2x damage
			end
		end
	end,
	action = function(self, t)
		local dur = t.getDur(self, t)
		self:setEffect(self.EFF_MUCUS, dur, {})
		return true
	end,
	info = function(self, t)
		local dur = t.getDur(self, t)
		local dam = t.getDamage(self, t)
		local equi = t.getEqui(self, t)
		return ([[For %d turns, you lay down mucus where you walk or stand.
		The mucus is placed automatically every turn and lasts %d turns.
		At talent level 4 or greater, the mucus will expand to a radius 1 area from where it is placed.
		Your mucus will poison all foes crossing it, dealing %0.1f nature damage every turn for 5 turns (stacking).
		In addition, each turn, you will restore %0.1f Equilibrium while in your own mucus, and other friendly creatures in your mucus will restore 1 Equilibrium both for you and for themselves.
		The Poison damage and Equilibrium regeneration increase with your Mindpower, and laying down more mucus in the same spot will intensify its effects and refresh its duration.]]):
		format(dur, dur, damDesc(self, DamageType.NATURE, dam), equi)
	end,
}

newTalent{
	name = "Acid Splash",
	type = {"wild-gift/mucus", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 10,
	cooldown = 10,
	range = 7,
	radius = function(self, t) return 2 + (self:getTalentLevel(t) >= 5 and 1 or 0) end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false} end,
	tactical = { ATTACKAREA = { ACID = 2, NATURE = 1 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 220) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local grids, px, py = self:project(tg, x, y, DamageType.ACID, self:mindCrit(t.getDamage(self, t)))
		if self:knowTalent(self.T_MUCUS) then
			self:callTalent(self.T_MUCUS, nil, px, py, tg.radius, self:hasEffect(self.EFF_MUCUS))
		end
		game.level.map:particleEmitter(px, py, tg.radius, "acidflash", {radius=tg.radius, tx=px, ty=py})

		local tgts = {}
		for x, ys in pairs(grids) do for y, _ in pairs(ys) do
			local target = game.level.map(x, y, Map.ACTOR)
			if target and self:reactionToward(target) < 0 then tgts[#tgts+1] = target end
		end end

		if #tgts > 0 then
			if game.party:hasMember(self) then
				for act, def in pairs(game.party.members) do
					local target = rng.table(tgts)
					if act.summoner and act.summoner == self and act.is_mucus_ooze then
						act.inc_damage.all = (act.inc_damage.all or 0) - 50
						act:forceUseTalent(act.T_MUCUS_OOZE_SPIT, {force_target=target, ignore_energy=true})
						act.inc_damage.all = (act.inc_damage.all or 0) + 50
					end
				end
			else
				for _, act in pairs(game.level.entities) do
					local target = rng.table(tgts)
					if act.summoner and act.summoner == self and act.is_mucus_ooze then
						act.inc_damage.all = (act.inc_damage.all or 0) - 50
						act:forceUseTalent(act.T_MUCUS_OOZE_SPIT, {force_target=target, ignore_energy=true})
						act.inc_damage.all = (act.inc_damage.all or 0) + 50
					end
				end
			end
		end


		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[Calling upon nature, you cause the ground to erupt in an radius %d acidic explosion, dealing %0.1f acid damage to all creatures and creating mucus in the area.
		Any Mucus Oozes you have active will, if in line of sight, instantly spit slime (at reduced power) at one of the targets hit by the splash.
		The damage increases with your Mindpower.]]):
		format(self:getTalentRadius(t), damDesc(self, DamageType.ACID, dam))
	end,
}

newTalent{ short_name = "MUCUS_OOZE_SPIT", 
	name = "Slime Spit", image = "talents/slime_spit.png",
	type = {"wild-gift/other",1},
	points = 5,
	equilibrium = 2,
	mesage = "@Source@ spits slime!",
	range = 6,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = { NATURE = 2 } },
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t, selffire=false, friendlyfire=false}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SLIME, self:mindCrit(self:combatTalentMindDamage(t, 8, 110)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "ooze_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Spits a beam of slime doing %0.2f slime damage.
		The damage will increase with mindpower.]]):format(damDesc(self, DamageType.SLIME, self:combatTalentMindDamage(t, 8, 80)))
	end,
}

newTalent{
	name = "Living Mucus",
	type = {"wild-gift/mucus", 3},
	require = gifts_req3,
	points = 5,
	mode = "passive",
	getMax = function(self, t) return math.floor(math.max(1, self:combatStatScale("cun", 0.5, 5))) end,
	getChance = function(self, t) return self:combatLimit(self:combatTalentMindDamage(t, 5, 300), 50, 12.6, 26, 32, 220) end, -- Limit < 50% --> 12.6 @ 36, 32 @ 220
	getSummonTime = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	-- by MUCUS damage type in mod.data.damage_types.lua
	spawn = function(self, t)
		local notok, nb, sumlim = checkMaxSummon(self, true, 1, "is_mucus_ooze")
		if notok or nb >= t.getMax(self, t) or not self:canBe("summon") then return end

		local ps = {}
		for i, e in ipairs(game.level.map.effects) do
			if e.damtype == DamageType.MUCUS then
				for x, ys in pairs(e.grids) do for y, _ in pairs(ys) do
					if self:canMove(x, y) then ps[#ps+1] = {x=x, y=y} end
				end end
			end
		end
		if #ps == 0 then return end
		local p = rng.table(ps)

		local m = mod.class.NPC.new{
			type = "vermin", subtype = "oozes",
			display = "j", color=colors.GREEN, image = "npc/vermin_oozes_green_ooze.png",
			name = "mucus ooze",
			faction = self.faction,
			desc = "It's made from mucus and it's oozing.",
			sound_moam = {"creatures/jelly/jelly_%d", 1, 3},
			sound_die = {"creatures/jelly/jelly_die_%d", 1, 2},
			sound_random = {"creatures/jelly/jelly_%d", 1, 3},
			body = { INVEN = 10 },
			autolevel = "wildcaster",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { str=10, dex=10, mag=3, con=self:combatTalentScale(t, 0.8, 4, 0.75), wil=self:combatStatScale("wil", 10, 100, 0.75), cun=self:combatStatScale("cun", 10, 100, 0.75) },
			global_speed_base = 0.7,
			combat = {sound="creatures/jelly/jelly_hit"},
			combat_armor = 1, combat_def = 1,
			rank = 1,
			size_category = 3,
			infravision = 10,
			cut_immune = 1,
			blind_immune = 1,

			resists = { [DamageType.LIGHT] = -50, [DamageType.COLD] = -50 },
			fear_immune = 1,

			blood_color = colors.GREEN,
			level_range = {self.level, self.level}, exp_worth = 0,
			max_life = 30,

			combat = { dam=5, atk=0, apr=5, damtype=DamageType.POISON },

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true, is_mucus_ooze = true,
			summon_time = t.getSummonTime(self, t),
			max_summon_time = math.floor(self:combatTalentScale(t, 6, 10)),
		}
		m:learnTalent(m.T_MUCUS_OOZE_SPIT, true, self:getTalentLevelRaw(t))
		setupSummon(self, m, p.x, p.y)
		return true
	end,
	on_crit = function(self, t)
		if game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.is_mucus_ooze then
					act.summon_time = util.bound(act.summon_time + 2, 1, act.max_summon_time)
				end
			end
		else
			for _, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.is_mucus_ooze then
					act.summon_time = util.bound(act.summon_time + 2, 1, act.max_summon_time)
				end
			end
		end
	end,
	info = function(self, t)
		return ([[Your mucus is brought to near sentience.
		Each turn, there is a %d%% chance that a random spot of your mucus will spawn a Mucus Ooze.
		Mucus Oozes last %d turns and will attack any of your foes by spitting slime at them.
		You may have up to %d Mucus Oozes active at any time (based on your Cunning).
		Any time you deal a mental critical, the remaining time on all of your Mucus Oozes will increase by 2.
		The spawn chance increases with your Mindpower.]]):
		format(t.getChance(self, t), t.getSummonTime(self, t), t.getMax(self, t))
	end,
}

newTalent{
	name = "Oozewalk",
	type = {"wild-gift/mucus", 4},
	require = gifts_req4,
	points = 5,
	cooldown = 7,
	equilibrium = 10,
	range = 10,
	tactical = { CLOSEIN = 2 },
	getNb = function(self, t) return math.ceil(self:combatTalentScale(t, 1.1, 2.9, "log")) end,
	getEnergy = function(self,t)
		local tl = math.max(0, self:getTalentLevel(t) - 1.8)
		return 1-tl/(tl + 2.13)
	end,
	on_pre_use = function(self, t)
		return game.level and game.level.map and isOnMucus(game.level.map, self.x, self.y)
	end,
	action = function(self, t)
		local tg = {type="hit", nolock=true, pass_terrain=true, nowarning=true, range=self:getTalentRange(t), requires_knowledge=false}
		local x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code does not restrict the target coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)
		if not x then return nil end
		if not isOnMucus(game.level.map, x, y) then return nil end
		if not self:canMove(x, y) then return nil end

		local energy = 1 - t.getEnergy(self, t)
		self.energy.value = self.energy.value + game.energy_to_act * self.energy.mod * energy

		self:removeEffectsFilter(function(t) return t.type == "physical" or t.type == "magical" end, t.getNb(self, t))

		game.level.map:particleEmitter(self.x, self.y, 1, "slime")
		self:move(x, y, true)
		game.level.map:particleEmitter(self.x, self.y, 1, "slime")

		return true
	end,
	info = function(self, t)
		local nb = t.getNb(self, t)
		local energy = t.getEnergy(self, t)
		return ([[You temporarily merge with your mucus, cleansing yourself of %d physical or magical effects.
		You can then reemerge on any tile within sight and range that is also covered by mucus.
		This is quick, requiring only %d%% of a turn to perform, but you must be in contact with your mucus.]]):
		format(nb, (energy) * 100)
	end,
}
