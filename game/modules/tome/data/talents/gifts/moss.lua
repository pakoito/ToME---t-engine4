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

local function activate_moss(self, btid)
	for tid, lev in pairs(self.talents) do
		if tid ~= btid and self.talents_def[tid].type[1] == "wild-gift/moss" and not self.talents_cd[tid] then
			self.talents_cd[tid] = 3
		end
	end
end

newTalent{
	name = "Grasping Moss",
	type = {"wild-gift/moss", 1},
	require = gifts_req1,
	points = 5,
	cooldown = 20,
	equilibrium = 5,
	no_energy = true,
	tactical = { ATTACKAREA = {NATURE=1}, DISABLE = {pin = 1} },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 4, 30) end,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	getSlow = function(self, t) return 30 + math.ceil(self:getTalentLevel(t) * 6) end,
	getPin = function(self, t) return 20 + math.ceil(self:getTalentLevel(t) * 5) end,
	range = 0,
	radius = function(self, t)
		return 2 + math.floor(self:getTalentLevelRaw(t)/2)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, self:spellCrit(t.getDuration(self, t)),
			DamageType.GRASPING_MOSS, {dam=self:mindCrit(t.getDamage(self, t)), pin=t.getPin(self, t), slow=t.getSlow(self, t)},
			self:getTalentRadius(t),
			5, nil,
			engine.Entity.new{alpha=75, display='', color_br=60, color_bg=10, color_bb=60},
			nil, false, false
		)
		activate_moss(self, t.id)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local slow = t.getSlow(self, t)
		local pin = t.getPin(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Instantly grow a moss circle of radius %d at your feet.
		Each turn the moss deals %0.2f nature damage to any foes with in its radius.
		This moss is very thick and sticky, all foes passing through it have their movement speed reduced by %d%% and have %d%% chances to be stuck on the ground for 4 turns.
		The moss lasts %d turns.
		Using a moss talent takes no turn but places all other moss talents on a 3 turns cooldown.
		The damage will increase with your Mindpower.]]):
		format(radius, damDesc(self, DamageType.NATURE, damage), slow, pin, duration)
	end,
}

newTalent{
	name = "Nurishing Moss",
	type = {"wild-gift/moss", 2},
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

		local tg = {type="ball", radius=3, range=0, talent=t, selffire=false, friendlyfire=false}
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
	name = "Slippery Moss",
	type = {"wild-gift/moss", 3},
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
	name = "Halucigenic Moss",
	type = {"wild-gift/moss", 4},
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
