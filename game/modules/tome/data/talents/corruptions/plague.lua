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
	name = "Virulent Disease",
	type = {"corruption/plague", 1},
	require = corrs_req1,
	points = 5,
	vim = 8,
	cooldown = 3,
	random_ego = "attack",
	tactical = { ATTACK = {BLIGHT = 2} },
	requires_target = true,
	no_energy = true,
	range = function(self, t) return 4 + math.floor(self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local diseases = {{self.EFF_WEAKNESS_DISEASE, "str"}, {self.EFF_ROTTING_DISEASE, "con"}, {self.EFF_DECREPITUDE_DISEASE, "dex"}}
		local disease = rng.table(diseases)

		-- Try to rot !
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			if target:canBe("disease") then
				local str, dex, con = not target:hasEffect(self.EFF_WEAKNESS_DISEASE) and target:getStr() or 0, not target:hasEffect(self.EFF_DECREPITUDE_DISEASE) and target:getDex() or 0, not target:hasEffect(self.EFF_ROTTING_DISEASE) and target:getCon() or 0

				if str >= dex and str >= con then
					disease = {self.EFF_WEAKNESS_DISEASE, "str"}
				elseif dex >= str and dex >= con then
					disease = {self.EFF_DECREPITUDE_DISEASE, "dex"}
				elseif con > 0 then
					disease = {self.EFF_ROTTING_DISEASE, "con"}
				end

				target:setEffect(disease[1], 6, {src=self, dam=self:spellCrit(7 + self:combatTalentSpellDamage(t, 6, 65)), [disease[2]]=self:combatTalentSpellDamage(t, 5, 35), apply_power=self:combatSpellpower()})
			else
				game.logSeen(target, "%s resists the disease!", target.name:capitalize())
			end
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[Fires a bolt of pure filth, diseasing your target with a disease doing %0.2f blight damage per turns for 6 turns and reducing one of its physical stats (strength, constitution, dexterity) by %d. The three diseases can stack.
		Virulent Disease will always try to apply a disease the target does not currently have, and also one that will have the most debilitaing effect for the target.
		The effect will increase with your Magic stat.]]):
		format(damDesc(self, DamageType.BLIGHT, 7 + self:combatTalentSpellDamage(t, 6, 65)), self:combatTalentSpellDamage(t, 5, 35))
	end,
}

newTalent{
	name = "Cyst Burst",
	type = {"corruption/plague", 2},
	require = corrs_req2,
	points = 5,
	vim = 18,
	cooldown = 9,
	range = 7,
	radius = function(self, t)
		return 1 + math.floor(self:getTalentLevelRaw(t) / 2)
	end,
	tactical = { ATTACK = function(self, t, target)
		-- Count the number of diseases on the target
		local val = 0
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.disease then
				val = val + 1
			end
		end
		return val
	end },
	requires_target = true,
	target = function(self, t)
		-- Target trying to combine the bolt and the ball disease spread
		return {type="ballbolt", radius=self:getTalentRadius(t), range=self:getTalentRange(t)}
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(self:combatTalentSpellDamage(t, 15, 85))
		local diseases = {}

		-- Try to rot !
		local source = nil
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.disease then
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
			self:project({type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t)}, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target or target == source or target == self or (self:reactionToward(target) >= 0) then return end

				for _, disease in ipairs(diseases) do
					if disease.id == self.EFF_WEAKNESS_DISEASE or disease.id == self.EFF_DECREPITUDE_DISEASE or disease.id == self.EFF_ROTTING_DISEASE or disease.id == self.EFF_EPIDEMIC then
						target:setEffect(disease.id, 6, {src=self, dam=disease.params.dam, str=disease.params.str, dex=disease.params.dex, con=disease.params.con, heal_factor=disease.params.heal_factor, resist=disease.params.resist, apply_power=self:combatSpellpower()})
					end
				end
				game.level.map:particleEmitter(px, py, 1, "slime")
			end)
		end
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[Make your target's diseases burst, doing %0.2f blight damage for each disease it is infected with.
		This will also spread any decrepitude, weakness, rotting or epidemic diseases to any nearby foes in a radius of %d.
		The damage will increase with your Magic stat.]]):
		format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 15, 85)), self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Catalepsy",
	type = {"corruption/plague", 3},
	require = corrs_req3,
	points = 5,
	vim = 20,
	cooldown = 15,
	range = 6,
	tactical = { DISABLE = function(self, t, target)
		-- Make sure the target has a disease
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.disease then
				return 2
			end
		end
	end },
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return (100 + self:combatTalentSpellDamage(t, 0, 50)) / 100 end,
	getDuration = function(self, t) return math.floor(2 + self:getTalentLevel(t) / 2) end,
	getRadius = function(self, t) return 2 + math.floor(self:getTalentLevel(t)/3) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t)}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local source = nil
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			-- List all diseases
			local diseases = {}
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.disease then
					diseases[#diseases+1] = {id=eff_id, params=p}
				end
			end
			-- Make them EXPLODE !!!
			for i, d in ipairs(diseases) do
				target:removeEffect(d.id)
				DamageType:get(DamageType.BLIGHT).projector(self, px, py, DamageType.BLIGHT, d.params.dam * d.params.dur * t.getDamage(self, t))
			end

			if #diseases > 0 and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatSpellpower()})
			elseif #diseases > 0 then
				game.logSeen(target, "%s resists the stun!", target.name:capitalize())
			end
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		return ([[All your foes within a radius %d ball infected with a disease enter a catalepsy, stunning them for %d turns and dealing %d%% of all remaining disease damage instantly.]]):
		format(radius, duration, damage * 100)
	end,
}

newTalent{
	name = "Epidemic",
	type = {"corruption/plague", 4},
	require = corrs_req4,
	points = 5,
	vim = 20,
	cooldown = 13,
	range = 6,
	radius = 2,
	tactical = { ATTACK = {BLIGHT = 2} },
	requires_target = true,
	do_spread = function(self, t, carrier)
		-- List all diseases
		local diseases = {}
		for eff_id, p in pairs(carrier.tmp) do
			local e = carrier.tempeffect_def[eff_id]
			if e.subtype.disease then
				diseases[#diseases+1] = {id=eff_id, params=p}
			end
		end

		if #diseases == 0 then return end
		self:project({type="ball", radius=self:getTalentRadius(t)}, carrier.x, carrier.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target or target == carrier or target == self then return end

			local disease = rng.table(diseases)
			local params = disease.params
			params.src = self
			local disease_spread = {
				src=self, dam=disease.params.dam, str=disease.params.str, dex=disease.params.dex, con=disease.params.con, apply_power=self:combatSpellpower(),
				heal_factor=disease.params.heal_factor, burst=disease.params.burst, rot_timer=disease.params.rot_timer, resist=disease.params.resist, make_ghoul=disease.params.make_ghoul,
			}
			if target:canBe("disease") then
				target:setEffect(disease.id, 6, disease_spread)
			else
				game.logSeen(target, "%s resists the disease!", target.name:capitalize())
			end
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
			if not target or (self:reactionToward(target) >= 0) then return end
			target:setEffect(self.EFF_EPIDEMIC, 6, {src=self, dam=self:spellCrit(self:combatTalentSpellDamage(t, 15, 70)), heal_factor=40 + self:getTalentLevel(t) * 4, resist=30 + self:getTalentLevel(t) * 6, apply_power=self:combatSpellpower()})
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[Infects the target with a very contagious disease doing %0.2f damage per turn for 6 turns.
		If any blight damage from non-diseases hits the target, the epidemic may activate and spread a random disease to nearby targets within a radius 2 ball.
		Creatures suffering from that disease will also suffer healing reduction (%d%%) and diseases immunity reduction (%d%%).
		Epidemic is an extremely potent disease, as such it fully ignores the target's diseases immunity.
		The damage will increase with your Magic stat, and the spread chance increases with the blight damage.]]):
		format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 15, 70)), 40 + self:getTalentLevel(t) * 4, 30 + self:getTalentLevel(t) * 6)
	end,
}
