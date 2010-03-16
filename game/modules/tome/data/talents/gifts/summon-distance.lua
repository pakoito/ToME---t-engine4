newTalent{ short_name = "FIRE_IMP_BOLT",
	name = "Fire Bolt",
	type = {"spell/other",1},
	points = 5,
	mana = 10,
	range = 20,
	reflectable = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:spellCrit(12 + self:combatSpellpower(0.8) * self:getTalentLevel(t)), {type="flame"})
		return true
	end,
	info = function(self, t)
		return ([[Conjures up a bolt of fire doing %0.2f fire damage.
		The damage will increase with the Magic stat]]):format(12 + self:combatSpellpower(0.8) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Fire Imp",
	type = {"gift/summon-distance", 1},
	require = gifts_req1,
	points = 5,
	message = "@Source@ summons a Fire Imp!",
	equilibrium = 2,
	cooldown = 10,
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		tx, ty = game.target:pointAtRange(self.x, self.y, tx, ty, self:getTalentRange(t))
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end
		print("Invoking Fire Imp on", x, y)

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "demon", subtype = "lesser",
			display = "u", color=colors.RED,
			name = "fire imp", faction = self.faction,
			desc = [[]],
			autolevel = "caster",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { str=5, dex=5, mag=15, wil=15, con=7 },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(5,10),
			life_rating = 8,

			combat_armor = 0, combat_def = 0,
			combat = { dam=1, atk=1, },

			max_mana = 150,
			resolvers.talents{
				[self.T_MANA_POOL]=1,
				[self.T_FIRE_IMP_BOLT]=self:getTalentLevelRaw()
			},

			summoner = self, summoner_gain_exp=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5,
			ai_target = {actor=target}
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		return ([[Summon a Fire Imp to burn your foes to death.]])
	end,
}
