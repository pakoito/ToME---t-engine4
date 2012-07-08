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

local minions_list = {
	bone_giant = {
		type = "undead", subtype = "giant",
		blood_color = colors.GREY,
		display = "K",
		combat = { dam=resolvers.levelup(resolvers.mbonus(45, 20), 1, 1), atk=15, apr=10, dammod={str=0.8} },
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		infravision = 10,
		life_rating = 12,
		max_stamina = 90,
		rank = 2,
		size_category = 4,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
		stats = { str=20, dex=52, mag=16, con=16 },
		resists = { [DamageType.PHYSICAL] = 20, [DamageType.BLIGHT] = 20, [DamageType.COLD] = 50, },
		open_door = 1,
		no_breath = 1,
		confusion_immune = 1,
		poison_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		stun_immune = 1,
		see_invisible = resolvers.mbonus(15, 5),
		undead = 1,
		name = "bone giant", color=colors.WHITE,
		desc = [[A towering creature, made from the bones of dozens of dead bodies. It is covered by an unholy aura.]],
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_giant_bone_giant.png", display_h=2, display_y=-1}}},
		max_life = resolvers.rngavg(100,120),
		level_range = {1, nil}, exp_worth = 0,
		combat_armor = 20, combat_def = 0,
		on_melee_hit = {[DamageType.BLIGHT]=resolvers.mbonus(15, 5)},
		melee_project = {[DamageType.BLIGHT]=resolvers.mbonus(15, 5)},
		resolvers.talents{ T_BONE_ARMOUR={base=3, every=10, max=5}, T_STUN={base=3, every=10, max=5}, },
	},
	h_bone_giant = {
		type = "undead", subtype = "giant",
		blood_color = colors.GREY,
		display = "K",
		combat = { dam=resolvers.levelup(resolvers.mbonus(45, 20), 1, 1), atk=15, apr=10, dammod={str=0.8} },
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		infravision = 10,
		life_rating = 12,
		max_stamina = 90,
		rank = 2,
		size_category = 4,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
		stats = { str=20, dex=52, mag=16, con=16 },
		resists = { [DamageType.PHYSICAL] = 20, [DamageType.BLIGHT] = 20, [DamageType.COLD] = 50, },
		open_door = 1,
		no_breath = 1,
		confusion_immune = 1,
		poison_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		stun_immune = 1,
		see_invisible = resolvers.mbonus(15, 5),
		undead = 1,
		name = "heavy bone giant", color=colors.RED,
		desc = [[A towering creature, made from the bones of hundreds of dead bodies. It is covered by an unholy aura.]],
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_giant_heavy_bone_giant.png", display_h=2, display_y=-1}}},
		level_range = {1, nil}, exp_worth = 0,
		max_life = resolvers.rngavg(100,120),
		combat_armor = 20, combat_def = 0,
		on_melee_hit = {[DamageType.BLIGHT]=resolvers.mbonus(15, 5)},
		melee_project = {[DamageType.BLIGHT]=resolvers.mbonus(15, 5)},
		resolvers.talents{ T_BONE_ARMOUR={base=3, every=10, max=5}, T_THROW_BONES={base=4, every=10, max=7}, T_STUN={base=3, every=10, max=5}, },
	},
	e_bone_giant = {
		type = "undead", subtype = "giant",
		blood_color = colors.GREY,
		display = "K",
		combat = { dam=resolvers.levelup(resolvers.mbonus(45, 20), 1, 1), atk=15, apr=10, dammod={str=0.8} },
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		infravision = 10,
		life_rating = 12,
		max_stamina = 90,
		rank = 2,
		size_category = 4,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
		stats = { str=20, dex=52, mag=16, con=16 },
		resists = { [DamageType.PHYSICAL] = 20, [DamageType.BLIGHT] = 20, [DamageType.COLD] = 50, },
		open_door = 1,
		no_breath = 1,
		confusion_immune = 1,
		poison_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		stun_immune = 1,
		see_invisible = resolvers.mbonus(15, 5),
		undead = 1,
		name = "eternal bone giant", color=colors.GREY,
		desc = [[A towering creature, made from the bones of hundreds of dead bodies. It is covered by an unholy aura.]],
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_giant_eternal_bone_giant.png", display_h=2, display_y=-1}}},
		level_range = {1, nil}, exp_worth = 0,
		max_life = resolvers.rngavg(100,120),
		combat_armor = 40, combat_def = 20,
		on_melee_hit = {[DamageType.BLIGHT]=resolvers.mbonus(15, 5)},
		melee_project = {[DamageType.BLIGHT]=resolvers.mbonus(15, 5)},
		autolevel = "warriormage",
		resists = {all = 50},
		resolvers.talents{ T_BONE_ARMOUR={base=5, every=10, max=7}, T_STUN={base=3, every=10, max=5}, T_SKELETON_REASSEMBLE=5, },
	},
	r_bone_giant = {
		type = "undead", subtype = "giant",
		blood_color = colors.GREY,
		display = "K",
		combat = { dam=resolvers.levelup(resolvers.mbonus(45, 20), 1, 1), atk=15, apr=10, dammod={str=0.8} },
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		infravision = 10,
		life_rating = 12,
		max_stamina = 90,
		rank = 2,
		size_category = 4,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=2, },
		stats = { str=20, dex=52, mag=16, con=16 },
		resists = { [DamageType.PHYSICAL] = 20, [DamageType.BLIGHT] = 20, [DamageType.COLD] = 50, },
		open_door = 1,
		no_breath = 1,
		confusion_immune = 1,
		poison_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		stun_immune = 1,
		see_invisible = resolvers.mbonus(15, 5),
		undead = 1,
		name = "runed bone giant", color=colors.RED,
		desc = [[A towering creature, made from the bones of hundreds of dead bodies, rune-etched and infused with hateful sorceries.]],
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_giant_runed_bone_giant.png", display_h=2, display_y=-1}}},
		level_range = {1, nil}, exp_worth = 0,
		rank = 3,
		max_life = resolvers.rngavg(100,120),
		combat_armor = 20, combat_def = 40,
		melee_project = {[DamageType.BLIGHT]=resolvers.mbonus(15, 15)},
		autolevel = "warriormage",
		resists = {all = 30},
		resolvers.talents{
			T_BONE_ARMOUR={base=5, every=10, max=7},
			T_STUN={base=3, every=10, max=5},
			T_SKELETON_REASSEMBLE=5,
			T_ARCANE_POWER={base=4, every=5, max = 8},
			T_MANATHRUST={base=4, every=5, max = 10},
			T_MANAFLOW={base=5, every=5, max = 10},
			T_STRIKE={base=4, every=5, max = 12},
			T_INNER_POWER={base=4, every=5, max = 10},
			T_EARTHEN_MISSILES={base=5, every=5, max = 10},
		},
		resolvers.sustains_at_birth(),
	},
}

newTalent{
	name = "Undead Explosion",
	type = {"spell/advanced-necrotic-minions",1},
	require = spells_req_high1,
	points = 5,
	mana = 30,
	cooldown = 10,
	tactical = { ATTACKAREA = { BLIGHT = 2 } },
	radius = function(self, t) return 1 + math.floor(self:getTalentLevel(t) / 3) end,
	range = 8,
	requires_target = true,
	no_npc_use = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t,  20, 70) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t, first_target="friend"}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or not target.summoner == self or not target.necrotic_minion then return nil end

		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
		local dam = target.max_life * t.getDamage(self, t) / 100
		target:die()
		target:project(tg, target.x, target.y, DamageType.BLIGHT, dam)
		game.level.map:particleEmitter(target.x, target.y, tg.radius, "ball_acid", {radius=tg.radius})

		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		return ([[Minions are only tools. You may dispose of them... violently.
		Makes the targetted minion explode for %d%% of its maximum life as blight damage.
		Beware! Don't get caught in the blast!]]):
		format(t.getDamage(self, t))
	end,
}

newTalent{
	name = "Assemble",
	type = {"spell/advanced-necrotic-minions",2},
	require = spells_req_high2,
	points = 5,
	mana = 90,
	cooldown = 50,
	tactical = { ATTACK = 10 },
	requires_target = true,
	on_pre_use = function(self, t)
		local nb = 0
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.necrotic_minion then
					if act.subtype == "skeleton" then nb = nb + 1
					elseif act.subtype == "giant" then return end
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.necrotic_minion then
					if act.subtype == "skeleton" then nb = nb + 1
					elseif act.subtype == "giant" then return end
				end
			end
		end
		if nb < 3 then return false end
		return true
	end,
	getLevel = function(self, t)
		local raw = self:getTalentLevelRaw(t)
		if raw <= 0 then return -8 end
		if raw > 8 then return 8 end
		return ({-6, -4, -2, 0, 2, 4, 6, 8})[raw]
	end,
	action = function(self, t)
		local list = {}
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.necrotic_minion and act.subtype == "skeleton" then list[#list+1] = act end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.necrotic_minion and act.subtype == "skeleton" then list[#list+1] = act end
			end
		end
		if #list < 3 then return end

		rng.tableRemove(list):die(self)
		rng.tableRemove(list):die(self)
		rng.tableRemove(list):die(self)

		local kind = ({"bone_giant","bone_giant","h_bone_giant","h_bone_giant","e_bone_giant"})[util.bound(math.floor(self:getTalentLevel(t)), 1, 5)]
		if self:getTalentLevel(t) >= 6 and rng.percent(20) then kind = "r_bone_giant" end

		local minion = require("mod.class.NPC").new(minions_list[kind])
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if minion and x and y then
			local lev = t.getLevel(self, t)
			necroSetupSummon(self, minion, x, y, lev, true)
		end

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[Combines 3 of your skeletons into a bone giant.
		At level 1 it makes a bone giant.
		At level 3 it makes a heavy bone giant.
		At level 5 it makes an eternal bone giant.
		At level 6 it has a 20%% chance to produce a runed bone giant.
		Only one bone giant can be active at any time.]]):
		format()
	end,
}

newTalent{
	name = "Sacrifice",
	type = {"spell/advanced-necrotic-minions",3},
	require = spells_req_high3,
	points = 5,
	mana = 5,
	cooldown = 25,
	tactical = { DEFEND = 1 },
	requires_target = true,
	on_pre_use = function(self, t)
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.necrotic_minion then
					if act.subtype == "giant" then return true end
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.necrotic_minion then
					if act.subtype == "giant" then return true end
				end
			end
		end
		return false
	end,
	getTurns = function(self, t) return math.floor(4 + self:combatTalentSpellDamage(t, 8, 20)) end,
	getPower = function(self, t) return 25 - math.ceil(1 + self:getTalentLevel(t) * 1.5) end,
	action = function(self, t)
		local list = {}
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.necrotic_minion and act.subtype == "giant" then list[#list+1] = act end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.necrotic_minion and act.subtype == "giant" then list[#list+1] = act end
			end
		end
		if #list < 1 then return end

		rng.tableRemove(list):die(self)

		self:setEffect(self.EFF_BONE_SHIELD, t.getTurns(self, t), {power=t.getPower(self, t)})

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[Sacrifice a bone giant minion. Using its bones you make a temporary shield around you that prevents any attacks from doing more than %d%% of your total life.
		The effect lasts %d turns.]]):
		format(t.getPower(self, t), t.getTurns(self, t))
	end,
}


newTalent{
	name = "Minion Mastery",
	type = {"spell/advanced-necrotic-minions",4},
	require = spells_req_high4,
	points = 5,
	mode = "passive",
	info = function(self, t)
		local c = getAdvancedMinionChances(self)
		return ([[Each minion you summon has a chance to be a more advanced form of undead:
		Vampire: %d%%
		Master Vampire: %d%%
		Grave Wight: %d%%
		Barrow Wight: %d%%
		Dread: %d%%
		Lich: %d%%]]):
		format(c.vampire, c.m_vampire, c.g_wight, c.b_wight, c.dread, c.lich)
	end,
}
