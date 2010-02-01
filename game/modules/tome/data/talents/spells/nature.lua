newTalent{
	name = "Regeneration",
	type = {"spell/nature", 1},
	require = spells_req1,
	points = 5,
	mana = 30,
	cooldown = 10,
	tactical = {
		HEAL = 10,
	},
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 10, {power=5 + self:combatSpellpower(0.07) * self:getTalentLevel(t)})
		return true
	end,
	info = function(self, t)
		return ([[Call upon the forces of nature to regenerate your body for %d life every turn for 10 turns.
		The life healed will increase with the Magic stat]]):format(5 + self:combatSpellpower(0.07) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Heal",
	type = {"spell/nature", 2},
	require = spells_req2,
	points = 5,
	mana = 60,
	cooldown = 10,
	tactical = {
		HEAL = 10,
	},
	action = function(self, t)
		self:heal(self:spellCrit(10 + self:combatSpellpower(0.5) * self:getTalentLevel(t)), self)
		return true
	end,
	info = function(self, t)
		return ([[Call upon the forces of nature to heal your body for %d life.
		The life healed will increase with the Magic stat]]):format(10 + self:combatSpellpower(0.5) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Nature's Call",
	type = {"spell/nature", 3},
	require = spells_req3,
	points = 5,
	mana = 60,
	cooldown = 100,
	tactical = {
		ATTACK = 10,
	},
	action = function(self, t)
		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to invoke the guardian!")
			return
		end
		print("Invoking gardian on", x, y)

		local NPC = require "mod.class.NPC"
		local bear = NPC.new{
			type = "animal", subtype = "bear",
			display = "q", color=colors.LIGHT_GREEN,
			name = "guardian bear", faction = "players",
			desc = [[A bear summoned by the powers of nature to help you.]],
			autolevel = "warrior",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=5, },
			energy = { mod=1 },
			stats = { str=18, dex=13, mag=5, con=15 },
			tmasteries = resolvers.tmasteries{ ["physical/other"]=0.25 },

			talents = resolvers.talents{ [Talents.T_STUN]=2 },
			max_stamina = 100,

			resists = { [DamageType.COLD] = 20, [DamageType.NATURE] = 20 },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(100,150),
			life_rating = 10,

			combat_armor = 7, combat_def = 3,
			combat = { dam=resolvers.rngavg(12,25), atk=10, apr=10, physspeed=2 },

			summoner = self,
			summon_time = util.bound(self:getTalentLevel(t) * self:combatSpellpower(0.15), 5, 90),
		}

		bear:resolve()
		bear:move(x, y, true)
		game.level:addEntity(bear)
		bear:added()

		return true
	end,
	info = function(self, t)
		return ([[Call upon the forces of nature to summon a bear ally for %d turns.
		The power of the ally will increase with the Magic stat]]):format(util.bound(self:getTalentLevel(t) * self:combatSpellpower(0.15), 5, 90))
	end,
}
