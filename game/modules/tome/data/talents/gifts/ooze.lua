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
	getMax = function(self, t) return math.max(1, math.floor(self:getCun() / 10)) end,
	getChance = function(self, t) return 25 + math.floor(self:getCun() / 3) end,
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
			stats = { wil=10, dex=10, mag=3, str=self:getTalentLevel(t) / 5 * 4, con=self:getWil(), cun=self:getCun() },
			global_speed_base = 0.5,
			combat = {sound="creatures/jelly/jelly_hit"},
			combat_armor = self:getTalentLevel(t) * 5, combat_def = self:getTalentLevel(t) * 5,
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
			summon_time = math.ceil(self:getTalentLevel(t)) + 5,
			max_summon_time = math.ceil(self:getTalentLevel(t)) + 5,
		}
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_BONE_SHIELD, true, 2) end
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
		When you get hit you have a %d%% chance to split and create a Bloated Ooze with as much health as you have taken damage (up to %d).
		All damage you take will be split equaly between you and your Bloated Oozes.
		You may have up to %d Oozes active at any time (based on your Cunning).
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
	equilibrium = 1,
	cooldown = 12,
	tactical = { PROTECT = 2, ATTACKAREA = { ARCANE = 1 } },
	getDam = function(self, t) return self:combatTalentMindDamage(t, 15, 200) end,
	on_pre_use = function(self, t)
		if not game.level then return false end
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

		self:setEffect(self.EFF_PAIN_SUPPRESSION, math.ceil(3 + self:getTalentLevel(t)), {power=50})

		local tg = {type="ball", radius=3, range=0, talent=t, selffire=false}
		self:project(tg, self.x, self.y, DamageType.MANABURN, self:mindCrit(t.getDam(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "acidflash", {radius=tg.radius})

		return true
	end,
	info = function(self, t)
		return ([[You randomly merge with an adjacent bloated ooze, granting your a 50%% damage resistance for %d turns.
		The merging also releases a burst of antimagic all around, dealing %0.2f manaburn damage in radius %d.
		The effect will increase with your Mindpower.]]):
		format(
			math.ceil(3 + self:getTalentLevel(t)),
			damDesc(self, DamageType.ARCANE, t.getDam(self, t)),
			3
		)
	end,
}

newTalent{
	name = "Call of the Ooze",
	type = {"wild-gift/ooze", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 5,
	cooldown = 8,
	action = function(self, t)
		local ot = self:getTalentFromId(self.T_MITOSIS)
		for i = 1, math.floor(self:getTalentLevel(t)) do
			ot.spawn(self, ot, self:combatTalentMindDamage(t, 30, 300))
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
		return ([[Instantly call all your bloated oozes to fight and if below the maximum number of oozes allowed by the Mitosis talent, at most %d will be created (with %d life).
		Each of them will be transported near a random foe in sight grab its attention.
		Taking advantage of the situation you channel a melee attack though all of them to their foes dealing %d%% weapon damage as acid.]]):
		format(self:getTalentLevel(t), self:combatTalentMindDamage(t, 30, 300), self:combatTalentWeaponDamage(t, 0.6, 2.2) * 100)
	end,
}

newTalent{
	name = "Indiscernible Anatomy",
	type = {"wild-gift/ooze", 4},
	require = gifts_req4,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:attr("blind_immune", 0.2)
		self:attr("poison_immune", 0.2)
		self:attr("disease_immune", 0.2)
		self:attr("cut_immune", 0.2)
		self:attr("confusion_immune", 0.2)
		self:attr("ignore_direct_crits", 15)
	end,
	on_unlearn = function(self, t)
		self:attr("blind_immune", -0.2)
		self:attr("poison_immune", -0.2)
		self:attr("disease_immune", -0.2)
		self:attr("cut_immune", -0.2)
		self:attr("confusion_immune", -0.2)
		self:attr("ignore_direct_crits", -15)
	end,
	info = function(self, t)
		return ([[Your body's internal organs are melted together, making it much harder to suffer critical hits.
		All direct critical hits (physical, mental, spells) against you have a %d%% chance to instead do their normal damage.
		In addition you gain %d%% disease, poison, cuts, confusion and blindness resistances.]]):
		format(self:getTalentLevelRaw(t) * 15, self:getTalentLevelRaw(t) * 20)
	end,
}
