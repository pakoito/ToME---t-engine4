newTalent{
	name = "Lightning",
	type = {"spell/air", 1},
	require = spells_req1,
	points = 5,
	mana = 10,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(1, self:spellCrit(20 + self:combatSpellpower(0.8) * self:getTalentLevel(t)), 3), {type="lightning"})
		return true
	end,
	info = function(self, t)
		return ([[Conjures up mana into a powerful beam of lightning doing 1 to %0.2f damage
		The damage will increase with the Magic stat]]):format(20 + self:combatSpellpower(0.8) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Noxious Cloud",
	type = {"spell/air",2},
	require = spells_req2,
	points = 5,
	mana = 45,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 15,
	action = function(self, t)
		local duration = self:getTalentLevel(t)
		local radius = 3
		local dam = 4 + self:combatSpellpower(0.11) * self:getTalentLevel(t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = game.target:pointAtRange(self.x, self.y, x, y, 15)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.NATURE, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=30, color_bg=180, color_bb=60}
		)
		return true
	end,
	info = function(self, t)
		return ([[Noxious fumes raises from the ground doing %0.2f nature damage in a radius of 3 each turns for %d turns.
		The damage and duration will increase with the Magic stat]]):format(4 + self:combatSpellpower(0.11) * self:getTalentLevel(t), self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Wings of Wind",
	type = {"spell/air",3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	sustain_mana = 100,
	tactical = {
		MOVEMENT = 10,
	},
	activate = function(self, t)
		return {
			fly = self:addTemporaryValue("fly", math.floor(self:getTalentLevel(t))),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("fly", p.fly)
		return true
	end,
	info = function(self, t)
		return ([[Grants the caster a pair of wings made of pure wind, allowing her to fly up to %d height.]]):
		format(math.floor(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Thunderstorm",
	type = {"spell/air", 4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 250,
	cooldown = 15,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 5,
	do_storm = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 5, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t)}
		for i = 1, math.floor(self:getTalentLevel(t)) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.LIGHTNING, rng.avg(1, self:spellCrit(20 + self:combatSpellpower(0.8) * self:getTalentLevel(t)), 3), {type="lightning"})
		end
	end,
	activate = function(self, t)
		game.logSeen(self, "#0080FF#A furious lightning storm forms around %s!", self.name)
		return {
			drain = self:addTemporaryValue("mana_regen", -2),
		}
	end,
	deactivate = function(self, t, p)
		game.logSeen(self, "#0080FF#A furious lightning storm forms around %s!", self.name)
		self:removeTemporaryValue("mana_regen", p.drain)
		return true
	end,
	info = function(self, t)
		return ([[Conjures a furious raging lightning storm with a radius of 5 that follows you as long as this spell is active.
		Each turn a random lightning bolt will hit up to %d of your foes for 1 to %0.2f damage.
		This powerfull spell will continuously drain mana while active.
		The damage will increase with the Magic stat]]):format(self:getTalentLevel(t), 20 + self:combatSpellpower(0.8) * self:getTalentLevel(t))
	end,
}
