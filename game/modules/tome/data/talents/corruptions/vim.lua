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
	name = "Soul Rot",
	type = {"corruption/vim", 1},
	require = corrs_req1,
	points = 5,
	cooldown = 4,
	vim = 10,
	range = 10,
	proj_speed = 10,
	tactical = { ATTACK = {BLIGHT = 2} },
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.BLIGHT, self:spellCrit(self:combatTalentSpellDamage(t, 20, 250), self:getTalentLevel(t) * 5), {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Projects a bolt of pure blight, doing %0.2f blight damage.
		This spell has an improved critical strike chance of +%0.2f%%.
		The damage will increase with Magic stat.]]):format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 20, 250)), self:getTalentLevel(t) * 5)
	end,
}

newTalent{
	name = "Vimsense",
	type = {"corruption/vim", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 25,
	vim = 25,
	requires_target = true,
	no_npc_use = true,
	action = function(self, t)
		local rad = 10
		self:setEffect(self.EFF_SENSE, 3 + self:getTalentLevel(t), {
			range = rad,
			actor = 1,
			on_detect = function(self, x, y)
				local a = game.level.map(x, y, engine.Map.ACTOR)
				if not a or self:reactionToward(a) >= 0 then return end
				a:setTarget(game.player)
				a:setEffect(a.EFF_VIMSENSE, 2, {power=self:combatTalentSpellDamage(self.T_VIMSENSE, 10, 45)})
			end,
		})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Feel the very existence of creatures around you for %d turns in a radius of 10.
		The evil touch will reduce their blight resistance by %d%% but also make them aware of you.
		The resistance will decrease with Magic stat.]]):format(3 + self:getTalentLevel(t), self:combatTalentSpellDamage(t, 10, 45))
	end,
}

newTalent{
	name = "Leech",
	type = {"corruption/vim", 3},
	require = corrs_req3,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[Each time a creature affected by vimsense hurts you you regain %0.2f vim and %0.2f health.]]):
		format(3 + self:getTalentLevel(t) * 0.7, 5 + self:getTalentLevel(t) * 3)
	end,
}

newTalent{
	name = "Dark Portal",
	type = {"corruption/vim", 4},
	require = corrs_req4,
	points = 5,
	vim = 30,
	cooldown = 15,
	tactical = { ATTACKAREA = {BLIGHT = 1}, DISABLE = 2, ESCAPE = 2 },
	range = 7,
	action = function(self, t)
		local tg = {type="ball", radius=3, range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local actors = {}
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or target == self then return end
			if not target:canBe("teleport") then game.logSeen("%s resists the portal!") return end
			actors[#actors+1] = target
		end)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, 1, "demon_teleport")
		game.level.map:particleEmitter(self.x, self.y, 1, "demon_teleport")

		for i, a in ipairs(actors) do
			local tx, ty = util.findFreeGrid(self.x, self.y, 20, true, {[Map.ACTOR]=true})
			if tx and ty then a:move(tx, ty, true) end
			if a:canBe("disease") then
				local diseases = {{self.EFF_WEAKNESS_DISEASE, "str"}, {self.EFF_ROTTING_DISEASE,"con"}, {self.EFF_DECREPITUDE_DISEASE,"dex"}}
				local disease = rng.table(diseases)
				a:setEffect(disease[1], 6, {src=self, dam=self:spellCrit(self:combatTalentSpellDamage(t, 12, 80)), [disease[2]]=self:combatTalentSpellDamage(t, 5, 25)})
			end
		end

		local tx, ty = util.findFreeGrid(x, y, 20, true, {[Map.ACTOR]=true})
		if tx and ty then self:move(tx, ty, true) end

		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Open a dark portal to the target zone. All creatures caught inside will be teleported to your location and you to theirs.
		All creatures(except you) traversing the portal will catch a random disease doing %0.2f blight damage per turn for 6 turns and reducing one of its physical stats (strength, constitution, dexterity) by %d.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 12, 80)), self:combatTalentSpellDamage(t, 5, 25))
	end,
}
