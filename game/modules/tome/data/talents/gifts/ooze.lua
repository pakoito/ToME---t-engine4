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
	name = "Mitosis",
	type = {"wild-gift/ooze", 1},
	require = gifts_req1,
	mode = "sustained",
	cooldown = 10,
	sustain_equilibrium = 10,
	getDur = function(self, t) return math.max(5, math.floor(self:getTalentLevel(t) * 2)) end,
	getMax = function(self, t) return math.floor(self:getCun() / 10) end,
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
			display = "j", color=colors.GREEN, image = "npc/vermin_oozes_green_ooze.png",
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

			resists = { [DamageType.LIGHT] = -50, [DamageType.COLD] = -50 },
			fear_immune = 1,

			blood_color = colors.GREEN,
			level_range = {self.level, self.level}, exp_worth = 0,
			max_life = 30,

			combat = { dam=5, atk=0, apr=5, damtype=DamageType.POISON },

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true, is_mucus_ooze = true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5,
			max_summon_time = math.ceil(self:getTalentLevel(t)) + 5,
		}
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_BONE_SHIELD, true, 2) end
		setupSummon(self, m, x, y)
		m.max_life = life
		m.life = life

		game:playSoundNear(self, "talents/spell_generic2")

		return true
	end,
	info = function(self, t)
		return ([[Your body is more like that of an ooze. When you get hit you have %d%% chances to split and create a Bloated Ooze with as much health as you have taken damage (up to %d).
		All damage you take will be split equaly between you and your Bloated Oozes.
		You may have up to %d Oozes active at any time (based on your Cunning).]]):
		format(t.getChance(self, t), t.getMax(self, t))
	end,
}

newTalent{
	name = "Reabsorb",
	type = {"wild-gift/ooze", 2},
	require = gifts_req2,
	points = 5,
	mode = "passive",
	getPower = function(self, t) return 20 + self:combatTalentMindDamage(t, 5, 500) / 10 end,
	on_pre_use = function(self, t)
		if not game.party:findMember{type="mitosis"} then return end
		return true
	end,
	info = function(self, t)
		local p = t.getPower(self, t)
		return ([[Improve your fungus to allow it to take a part of any healing you receive and improve it.
		Each time you are healed you get a regeneration effect for 6 turns that heals you of %d%% of the direct heal you received.
		The effect will increase with your Mindpower.]]):
		format(p)
	end,
}

newTalent{
	name = "Swap", short_name = "MITOSIS_SWAP",
	type = {"wild-gift/ooze", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 5,
	cooldown = 8,
	on_pre_use = function(self, t)
		if not game.party:findMember{type="mitosis"} then return end
		return true
	end,
	action = function(self, t)
		local target = game.party:findMember{type="mitosis"}

		local dur = 1 + self:getTalentLevel(t)
		self:setEffect(self.EFF_MITOSIS_SWAP, 6, {power=15 + self:combatTalentMindDamage(t, 5, 300) / 10})
		target:setEffect(target.EFF_MITOSIS_SWAP, 6, {power=15 + self:combatTalentMindDamage(t, 5, 300) / 10})

		self:heal(40 + self:combatTalentMindDamage(t, 5, 300))

		-- Displace
		game.level.map:remove(self.x, self.y, Map.ACTOR)
		game.level.map:remove(target.x, target.y, Map.ACTOR)
		game.level.map(self.x, self.y, Map.ACTOR, target)
		game.level.map(target.x, target.y, Map.ACTOR, self)
		self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		return ([[Both of you swap place in an instant, creatures attacking one will target the other.
		While swaping you briefly merge together, boosting all your nature and acid damage by %d%% for 6 turns and healing you for %d.
		Damage and healing increase with Mindpower.]]):
		format(15 + self:combatTalentMindDamage(t, 5, 300) / 10, 40 + self:combatTalentMindDamage(t, 5, 300))
	end,
}

newTalent{
	name = "One With The Ooze",
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
	end,
	on_unlearn = function(self, t)
		self:attr("blind_immune", -0.2)
		self:attr("poison_immune", -0.2)
		self:attr("disease_immune", -0.2)
		self:attr("cut_immune", -0.2)
		self:attr("confusion_immune", -0.2)
	end,
	info = function(self, t)
		return ([[Your body becomes even more ooze-like, granting %d%% disease, poison, cuts, confusion and blindness resistances.]]):
		format(self:getTalentLevelRaw(t) * 20)
	end,
}
