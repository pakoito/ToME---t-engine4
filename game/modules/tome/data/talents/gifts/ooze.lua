-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	name = "Mitosis",
	type = {"wild-gift/ooze", 1},
	require = gifts_req1,
	mode = "sustained",
	points = 5,
	cooldown = 10,
	sustain_equilibrium = 10,
	tactical = { BUFF = 2 },
	getMaxHP = function(self, t) return 50 + self:combatTalentMindDamage(t, 30, 250) end,
	getMax = function(self, t) local _, _, max = checkMaxSummon(self, true) return math.min(max, math.max(1, math.floor(self:combatTalentScale(t, 0.5, 2.5)))) end,
	getChance = function(self, t) return self:combatLimit(self:combatTalentStatDamage(t, "cun", 10, 400), 100, 20, 0, 61, 234) end, -- Limit < 100%
	spawn = function(self, t, life)
		if checkMaxSummon(self, true) or not self:canBe("summon") then return end

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local m = mod.class.NPC.new{
			type = "vermin", subtype = "oozes",
			display = "j", color=colors.GREEN, image = "npc/vermin_oozes_bloated_ooze.png",
			name = "bloated ooze",
			desc = "It's made from your own flesh and it's oozing.",
			sound_moam = {"creatures/jelly/jelly_%d", 1, 3},
			sound_die = {"creatures/jelly/jelly_die_%d", 1, 2},
			sound_random = {"creatures/jelly/jelly_%d", 1, 3},
			body = { INVEN = 10 },
			autolevel = "tank",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { wil=10, dex=10, mag=3, str=self:combatTalentScale(t, 0.8, 4, 0.75), con=self:combatStatScale("con", 10, 100, 0.75), cun=self:combatStatScale("cun", 10, 100, 0.75)},
			global_speed_base = 0.5,
			combat = {sound="creatures/jelly/jelly_hit"},
			combat_armor = self:combatTalentScale(t, 5, 25),
			combat_def = self:combatTalentScale(t, 5, 25, 0.75),
			rank = 1,
			size_category = 3,
			infravision = 10,
			cut_immune = 1,
			blind_immune = 1,
			bloated_ooze = 1,

			resists = { all = 50 },
			fear_immune = 1,

			blood_color = colors.GREEN,
			level_range = {self.level, self.level}, exp_worth = 0,
			max_life = 30,
			life_regen = 0,

			combat = { dam=5, atk=0, apr=5, damtype=DamageType.POISON },

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.floor(self:combatTalentScale(t, 6, 10)),
			max_summon_time = math.floor(self:combatTalentScale(t, 6, 10)),
			resolvers.sustains_at_birth(),
		}
		setupSummon(self, m, x, y)
		m.max_life = life
		m.life = life
		if self:isTalentActive(self.T_ACIDIC_SOIL) then
			local st = self:getTalentFromId(self.T_ACIDIC_SOIL)
			m.life_regen = st.getRegen(self, st) * life / 100
		end

		game:playSoundNear(self, "talents/spell_generic2")

		return true
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Your body is more like that of an ooze.
		When you get hit you have up to a %d%% chance to split and create a Bloated Ooze with as much health as you have taken damage (up to %d).
		All damage you take will be split equally between you and your Bloated Oozes.
		You may have up to %d Bloated Oozes active at any time (based on your Cunning and talent level).
		Bloated Oozes are very resilient (50%% all damage resistance) to damage not coming through your shared link.
		The maximum life depends on Mindpower and the chance on Cunning.]]):
		format(t.getChance(self, t), t.getMaxHP(self, t), t.getMax(self, t))
	end,
}

newTalent{
	name = "Reabsorb",
	type = {"wild-gift/ooze", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 10,
	cooldown = 15,
	tactical = { PROTECT = 2, ATTACKAREA = { ARCANE = 1 } },
	getDam = function(self, t) return self:combatTalentMindDamage(t, 15, 200) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	on_pre_use = function(self, t)
		if not game.level or not self.x or not self.y then return false end
		for _, coor in pairs(util.adjacentCoords(self.x, self.y)) do
			local act = game.level.map(coor[1], coor[2], Map.ACTOR)
			if act and act.summoner == self and act.bloated_ooze then
				return true
			end
		end
		return false
	end,
	action = function(self, t)
		local possibles = {}
		for _, coor in pairs(util.adjacentCoords(self.x, self.y)) do
			local act = game.level.map(coor[1], coor[2], Map.ACTOR)
			if act and act.summoner == self and act.bloated_ooze then
				possibles[#possibles+1] = act
			end
		end
		if #possibles == 0 then return end

		local act = rng.table(possibles)
		act:die(self)

		self:setEffect(self.EFF_PAIN_SUPPRESSION, t.getDuration(self, t), {power=40})
		local tg = {type="ball", radius=3, range=0, talent=t, selffire=false, friendlyfire=false}
		self:project(tg, self.x, self.y, DamageType.MANABURN, self:mindCrit(t.getDam(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "acidflash", {radius=tg.radius})

		return true
	end,
	info = function(self, t)
		return ([[You randomly merge with an adjacent bloated ooze, granting you 40%% damage resistance for %d turns.
		The merging also releases a burst of antimagic, dealing %0.2f manaburn damage in radius %d.
		The effect will increase with your Mindpower.]]):
		format(t.getDuration(self, t), damDesc(self, DamageType.ARCANE, t.getDam(self, t)),	3)
	end,
}

newTalent{
	name = "Call of the Ooze",
	type = {"wild-gift/ooze", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 5,
	cooldown = 20,
	getMax = function(self, t) local _, _, max = checkMaxSummon(self, true) return math.min(max, self:callTalent(self.T_MITOSIS, "getMax"), math.max(1, math.floor(self:combatTalentScale(t, 0.5, 2.5)))) end,
	getModHP = function(self, t) return self:combatTalentLimit(t, 1, 0.46, 0.7) end, --  Limit < 1
	action = function(self, t)
		local ot = self:getTalentFromId(self.T_MITOSIS)
		local _, cur_nb, max = checkMaxSummon(self, true, nil, "bloated_ooze")
		for i = cur_nb + 1, t.getMax(self, t) do
			ot.spawn(self, ot, ot.getMaxHP(self, ot) * t.getModHP(self, t))
		end

		local list = {}
		if game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.bloated_ooze then list[#list+1] = act end
			end
		else
			for _, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.is_mucus_ooze then list[#list+1] = act	end
			end
		end

		local tg = {type="ball", radius=self.sight}
		local grids = self:project(tg, self.x, self.y, function() end)
		local tgts = {}
		for x, ys in pairs(grids) do for y, _ in pairs(ys) do
			local target = game.level.map(x, y, Map.ACTOR)
			if target and self:reactionToward(target) < 0 then tgts[#tgts+1] = target end
		end end

		while #tgts > 0 and #list > 0 do
			local ooze = rng.tableRemove(list)
			local target = rng.tableRemove(tgts)

			local tx, ty = util.findFreeGrid(target.x, target.y, 10, true, {[Map.ACTOR]=true})
			if tx then
				local ox, oy = ooze.x, ooze.y
				ooze:move(tx, ty, true)
				if config.settings.tome.smooth_move > 0 then
					ooze:resetMoveAnim()
					ooze:setMoveAnim(ox, oy, 8, 5)
				end
				if core.fov.distance(tx, ty, target.x, target.y) <= 1 then
					target:setTarget(ooze)
					self:attackTarget(target, DamageType.ACID, self:combatTalentWeaponDamage(t, 0.6, 2.2), true)
				end
			end
		end

		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Instantly call all your bloated oozes to fight and if below the maximum number of oozes allowed by the Mitosis talent, at most %d will be created with %d%% of the maximum life allowed by Mitosis.
		Each of them will be transported near a random foe in sight grab its attention.
		Taking advantage of the situation you channel a melee attack though all of them to their foes dealing %d%% weapon damage as acid.]]):
		format(t.getMax(self, t), t.getModHP(self, t)*100, self:combatTalentWeaponDamage(t, 0.6, 2.2) * 100)
	end,
}

newTalent{
	name = "Indiscernible Anatomy",
	type = {"wild-gift/ooze", 4},
	require = gifts_req4,
	points = 5,
	mode = "passive",
	critResist = function(self, t) return self:combatTalentScale(t, 20, 75) end,
	immunities = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.5) end, -- Limit < 100% immunities
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "blind_immune", t.immunities(self, t))
		self:talentTemporaryValue(p, "poison_immune", t.immunities(self, t))
		self:talentTemporaryValue(p, "disease_immune", t.immunities(self, t))
		self:talentTemporaryValue(p, "ignore_direct_crits", t.critResist(self, t))
	end,
	info = function(self, t)
		return ([[Your body's internal organs are melded together, disguising your vital areas.
		All direct critical hits (physical, mental, spells) against you have a %d%% lower Critical multiplier (but always do at least normal damage).
		In addition you gain %d%% disease, poison, cuts, confusion and blindness resistances.]]):
		format(t.critResist(self, t), 100*t.immunities(self, t))
	end,
}
