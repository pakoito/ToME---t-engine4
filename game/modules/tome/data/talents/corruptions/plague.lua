-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
	name = "Virulent Disease",
	type = {"corruption/plague", 1},
	require = corrs_req1,
	points = 5,
	vim = 8,
	cooldown = 3,
	random_ego = "attack",
	range = function(self, t) return 5 + math.floor(self:getTalentLevel(t) * 1.3) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local diseases = {{self.EFF_WEAKNESS_DISEASE, "str"}, {self.EFF_ROTTING_DISEASE,"con"}, {self.EFF_DECREPITUDE_DISEASE,"dex"}}
		local disease = rng.table(diseases)

		-- Try to rot !
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 12 - self:getTalentLevel(t)) and target:canBe("disease") then
				target:setEffect(disease[1], 6, {src=self, dam=self:combatTalentSpellDamage(t, 5, 45), [disease[2]]=self:combatTalentSpellDamage(t, 5, 25)})
			else
				game.logSeen(target, "%s resists the disease!", target.name:capitalize())
			end
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[Fires a bolt of pure filth, diseasing your target with a random disease doing %0.2f blight damage per turns for 6 turns and reducing one of its physical stats (strength, constitution, dexterity) by %d.
		The effect will increase with your Magic stat.]]):
		format(self:combatTalentSpellDamage(t, 5, 45), self:combatTalentSpellDamage(t, 5, 25))
	end,
}

newTalent{
	name = "Cyst Burst",
	type = {"corruption/plague", 2},
	require = corrs_req2,
	points = 5,
	vim = 18,
	cooldown = 9,
	range = 15,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:combatTalentSpellDamage(t, 15, 85)
		local diseases = {}

		-- Try to rot !
		local source = nil
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "disease" then
					diseases[#diseases+1] = {id=eff_id, params=p}
				end
			end

			if #diseases > 0 then
				DamageType:get(DamageType.BLIGHT).projector(self, px, py, DamageType.BLIGHT, dam * #diseases)
				game.level.map:particleEmitter(px, py, 1, "slime")
			end
			source = target
		end)

		if #diseases > 0 then
			self:project({type="ball", radius=1, range=self:getTalentRange(t)}, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target or target == source or target == self then return end

				local disease = rng.table(diseases)
				target:setEffect(disease.id, 6, {src=self, dam=disease.params.dam, str=disease.params.str, dex=disease.params.dex, con=disease.params.con})
				game.level.map:particleEmitter(px, py, 1, "slime")
			end)
		end
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[Make your target's diseases burst, doing %0.2f blight damage for each diseases it is infected with.
		This will also spread the diseases to any nearby foes in a radius of 1.
		The damage will increase with your Magic stat.]]):
		format(self:combatTalentSpellDamage(t, 15, 85))
	end,
}

newTalent{
	name = "Catalepsy",
	type = {"corruption/plague", 3},
	require = corrs_req3,
	points = 5,
	vim = 35,
	cooldown = 15,
	range = 10,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=2}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dur = math.floor(2 + self:getTalentLevel(t) / 2)

		local source = nil
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			-- List all diseas
			local diseases = {}
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "disease" then
					diseases[#diseases+1] = {id=eff_id, params=p}
				end
			end
			-- Make them EXPLODE !!!
			for i, d in ipairs(diseases) do
				target:removeEffect(d.id)
				DamageType:get(DamageType.BLIGHT).projector(self, px, py, DamageType.BLIGHT, d.params.dam * d.params.dur)
			end

			if #diseases >  0 and target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 8) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, dur, {})
			else
				game.logSeen(target, "%s resists the stun!", target.name:capitalize())
			end
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[All your foes infected with a disease enter a catalepsy, stunning them for %d turns and dealing all the diseases remaining damage instantly.]]):
		format(math.floor(2 + self:getTalentLevel(t) / 2))
	end,
}

newTalent{
	name = "Epidemic",
	type = {"corruption/plague", 4},
	require = corrs_req4,
	points = 5,
	vim = 20,
	cooldown = 13,
	range = 10,
	do_spread = function(self, t, carrier)
		-- List all diseas
		local diseases = {}
		for eff_id, p in pairs(carrier.tmp) do
			local e = carrier.tempeffect_def[eff_id]
			if e.type == "disease" then
				diseases[#diseases+1] = {id=eff_id, params=p}
			end
		end

		if #diseases == 0 then return end
		self:project({type="ball", radius=2}, carrier.x, carrier.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target or target == carrier or target == self then return end

			local disease = rng.table(diseases)
			target:setEffect(disease.id, 6, {src=self, dam=disease.params.dam, str=disease.params.str, dex=disease.params.dex, con=disease.params.con})
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		-- Try to rot !
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 12 - self:getTalentLevel(t)) and target:canBe("disease") then
				target:setEffect(self.EFF_EPIDEMIC, 6, {src=self, dam=self:combatTalentSpellDamage(t, 15, 50)})
			else
				game.logSeen(target, "%s resists the disease!", target.name:capitalize())
			end
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[Infects the target with a very contagious disease doing %0.2f damage per turn for 6 turns.
		If any blight damage from non-diseases hit the target the epidemic will activate and spread diseases to nearby targets.]]):
		format(self:combatTalentSpellDamage(t, 15, 50))
	end,
}
