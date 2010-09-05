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

-- race & classes
newTalentType{ type="technique/other", name = "other", hide = true, description = "Talents of the various entities of the world." }
newTalentType{ no_silence=true, type="spell/other", name = "other", hide = true, description = "Talents of the various entities of the world." }
newTalentType{ no_silence=true, type="corruption/other", name = "other", hide = true, description = "Talents of the various entities of the world." }
newTalentType{ type="wild-gift/other", name = "other", hide = true, description = "Talents of the various entities of the world." }
newTalentType{ type="other/other", name = "other", hide = true, description = "Talents of the various entities of the world." }
newTalentType{ type="undead/other", name = "other", hide = true, description = "Talents of the various entities of the world." }

local oldTalent = newTalent
local newTalent = function(t) if type(t.hide) == "nil" then t.hide = true end return oldTalent(t) end

-- Multiply!!!
newTalent{
	name = "Multiply",
	type = {"other/other", 1},
	cooldown = 3,
	range = 20,
	action = function(self, t)
		if not self.can_multiply or self.can_multiply <= 0 then print("no more multiply")  return nil end

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		if not x then print("no free space") return nil end

		-- Find a place around to clone
		self.can_multiply = self.can_multiply - 1
		local a = self:clone()
		a.energy.val = 0
		a.exp_worth = 0.1
		a.inven = {}
		a.x, a.y = nil, nil
		if a.can_multiply <= 0 then a:unlearnTalent(t.id) end

		print("[MULTIPLY]", x, y, "::", game.level.map(x,y,Map.ACTOR))
		print("[MULTIPLY]", a.can_multiply, "uids", self.uid,"=>",a.uid, "::", self.player, a.player)
		game.zone:addEntity(game.level, a, "actor", x, y)
		return true
	end,
	info = function(self)
		return ([[Multiply yourself!]])
	end,
}

newTalent{
	short_name = "CRAWL_POISON",
	name = "Poisonous Crawl",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source@ crawls poison onto @target@.",
	cooldown = 5,
	range = 1,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.POISON, 2 + self:getTalentLevel(t), true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self)
		return ([[Crawl onto the target, convering it in poison.]])
	end,
}

newTalent{
	short_name = "CRAWL_ACID",
	name = "Acidic Crawl",
	points = 5,
	type = {"technique/other", 1},
	message = "@Source@ crawls acid onto @target@.",
	cooldown = 2,
	range = 1,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.ACID, self:combatTalentWeaponDamage(t, 1, 1.8), true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self)
		return ([[Crawl onto the target, convering it in acid.]])
	end,
}

newTalent{
	short_name = "SPORE_BLIND",
	name = "Blinding Spores",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source@ releases blinding spores at @target@.",
	cooldown = 2,
	range = 1,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.BLIND, self:combatTalentWeaponDamage(t, 0.8, 1.4), true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self)
		return ([[Releases blinding spores at the target.]])
	end,
}

newTalent{
	short_name = "SPORE_POISON",
	name = "Poisonous Spores",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source@ releases poisonous spores at @target@.",
	cooldown = 2,
	range = 1,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.POISON, 2 + self:getTalentLevel(t), true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self)
		return ([[Releases poisonous spores at the target.]])
	end,
}

newTalent{
	name = "Stun",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2 + self:getTalentLevel(t), {})
			else
				game.logSeen(target, "%s resists the stunning blow!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target doing %d%% damage, if the attack hits, the target is stunned.]]):format(100 * self:combatTalentWeaponDamage(t, 0.5, 1))
	end,
}

newTalent{
	name = "Disarm",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- No check to see if the attack hit
		if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("disarm") then
			target:setEffect(target.EFF_DISARMED, 2 + self:getTalentLevel(t), {})
		else
			game.logSeen(target, "%s resists the blow!", target.name:capitalize())
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target doing %d%% damage and try to disarm the target.]]):format(100 * self:combatTalentWeaponDamage(t, 0.5, 1))
	end,
}

newTalent{
	name = "Constrict",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_CONSTRICTED, (2 + self:getTalentLevel(t)) * 10, {src=self, power=1.5 * self:getTalentLevel(t)})
			else
				game.logSeen(target, "%s resists the constriction!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target doing %d%% damage, if the attack hits, the target is constricted.]]):format(100 * self:combatTalentWeaponDamage(t, 0.5, 1))
	end,
}

newTalent{
	name = "Knockback",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1.5, 2), true)

		-- Try to knockback !
		if hit then
			if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
				target:knockback(self.x, self.y, 4)
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon doing %d%% damage, if the attack hits, the target is knocked back.]]):format(100 * self:combatTalentWeaponDamage(t, 1.5, 2))
	end,
}

newTalent{
	short_name = "BITE_POISON",
	name = "Poisonous Bite",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source@ bites poison into @target@.",
	cooldown = 5,
	range = 1,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self:attackTarget(target, DamageType.POISON, 2 + self:getTalentLevel(t), true)
		return true
	end,
	info = function(self)
		return ([[Bites the target, infecting it with poison.]])
	end,
}

newTalent{
	name = "Summon",
	type = {"other/other", 1},
	cooldown = 4,
	range = 20,
	direct_hit = true,
	action = function(self, t)
		local filters = self.summon or {{type=self.type, subtype=self.subtype, number=1, hasxp=true, lastfor=20}}
		if #filters == 0 then return end
		local filter = rng.table(filters)

		for i = 1, filter.number do
			-- Find space
			local x, y = util.findFreeGrid(self.x, self.y, 10, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to summon!")
				break
			end

			-- Find an actor with that filter
			local m = game.zone:makeEntity(game.level, "actor", filter, nil, true)
			if m then
				if not filter.hasxp then m.exp_worth = 0 end
				m:resolve()

				m.summoner = self
				m.summon_time = filter.lastfor

				game.zone:addEntity(game.level, m, "actor", x, y)

				game.logSeen(self, "%s summons %s!", self.name:capitalize(), m.name)

				-- Learn about summoners
				if game.level.map.seens(self.x, self.y) then
					game:setAllowedBuild("wilder_summoner", true)
				end
			end
		end
		return true
	end,
	info = function(self)
		return ([[Summon allies.]])
	end,
}

newTalent{
	name = "Rotting Disease",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 8,
	message = "@Source@ diseases @target@.",
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to rot !
		if hit then
			if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("disease") then
				target:setEffect(target.EFF_ROTTING_DISEASE, 10 + self:getTalentLevel(t) * 3, {src=self, dam=self:getStr() / 3 + self:getTalentLevel(t) * 2, con=math.floor(4 + target:getCon() * 0.1)})
			else
				game.logSeen(target, "%s resists the disease!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target doing %d%% damage, if the attack hits, the target is diseased.]]):format(100 * self:combatTalentWeaponDamage(t, 0.5, 1))
	end,
}

newTalent{
	name = "Decrepitude Disease",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 8,
	message = "@Source@ diseases @target@.",
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to rot !
		if hit then
			if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("disease") then
				target:setEffect(target.EFF_DECREPITUDE_DISEASE, 10 + self:getTalentLevel(t) * 3, {src=self, dam=self:getStr() / 3 + self:getTalentLevel(t) * 2, dex=math.floor(4 + target:getDex() * 0.1)})
			else
				game.logSeen(target, "%s resists the disease!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target doing %d%% damage, if the attack hits, the target is diseased.]]):format(100 * self:combatTalentWeaponDamage(t, 0.5, 1))
	end,
}

newTalent{
	name = "Weakness Disease",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 8,
	message = "@Source@ diseases @target@.",
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to rot !
		if hit then
			if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("disease") then
				target:setEffect(target.EFF_WEAKNESS_DISEASE, 10 + self:getTalentLevel(t) * 3, {src=self, dam=self:getStr() / 3 + self:getTalentLevel(t) * 2, str=math.floor(4 + target:getStr() * 0.1)})
			else
				game.logSeen(target, "%s resists the disease!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target doing %d%% damage, if the attack hits, the target is diseased.]]):format(100 * self:combatTalentWeaponDamage(t, 0.5, 1))
	end,
}

newTalent{
	name = "Mind Disruption",
	type = {"spell/other", 1},
	points = 5,
	cooldown = 10,
	mana = 16,
	range = 20,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.CONFUSION, {dur=2+self:getTalentLevel(t), dam=50+self:getTalentLevelRaw(t)*10}, {type="manathrust"})
		return true
	end,
	info = function(self)
		return ([[Try to confuse the target's mind for a while.]])
	end,
}

newTalent{
	name = "Water Bolt",
	type = {"spell/other", },
	points = 5,
	mana = 10,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	reflectable = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.COLD, self:spellCrit(12 + self:combatSpellpower(0.25) * self:getTalentLevel(t)), {type="freeze"})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[Condenses ambient water on a target, damaging it for %0.2f.
		The damage will increase with the Magic stat]]):format(12 + self:combatSpellpower(0.25) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Water Jet",
	type = {"spell/other", },
	points = 5,
	mana = 10,
	cooldown = 8,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	direct_hit = true,
	reflectable = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.COLDSTUN, self:spellCrit(12 + self:combatSpellpower(0.20) * self:getTalentLevel(t)), {type="freeze"})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[Condenses ambient water on a target, damaging it for %0.2f and stunning it for 4 turns.
		The damage will increase with the Magic stat]]):format(12 + self:combatSpellpower(0.20) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Grab",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.8, 1.4), true)

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_PINNED, 1 + self:getTalentLevel(t), {})
			else
				game.logSeen(target, "%s resists the grab!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target doing %d%% damage; if the attack hits, the target is pinned to the ground.]]):format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.4))
	end,
}

newTalent{
	name = "Blinding Ink",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ projects ink!",
	tactical = {
		ATTACKAREA = 10,
		DEFEND = 5,
	},
	range = 4,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=4 + self:getTalentLevelRaw(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.BLINDING_INK, 2+self:getTalentLevelRaw(t), {type="dark"})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[You project thick black ink, blinding your targets for %d turns.]]):format(2+self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Spit Poison",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 4,
	cooldown = 6,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.POISON, 20 + (self:getDex() * self:getTalentLevel(t)) * 0.8, {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Spit poison at your target doing %0.2f poison damage.
		The damage will increase with the Dexterity stat]]):format(20 + (self:getDex() * self:getTalentLevel(t)) * 0.8)
	end,
}

newTalent{
	name = "Throw Bones",
	type = {"undead/other", 1},
	points = 5,
	cooldown = 6,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=2}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.BLEED, 20 + (self:getStr() * self:getTalentLevel(t)) * 0.8, {type="archery"})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Throws a pack of bones at your target doing %0.2f physical damage as bleeding.
		The damage will increase with the Strength stat]]):format(20 + (self:getStr() * self:getTalentLevel(t)) * 0.8)
	end,
}

newTalent{
	name = "Lay Web",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 4,
	cooldown = 6,
	message = "@Source@ seems to search the ground...",
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	action = function(self, t)
		local dur = 2 + self:getTalentLevel(t)
		local trap = mod.class.Trap.new{
			type = "web", subtype="web", id_by_type=true, unided_name = "sticky web",
			display = '^', color=colors.YELLOW,
			name = "sticky web", auto_id = true,
			detect_power = 6 * self:getTalentLevel(t), disarm_power = 10 * self:getTalentLevel(t),
			level_range = {self.level, self.level},
			message = "@Target@ is caught in a web!",
			canTrigger = function(self, x, y, who)
				if who.type == "spiderkin" then return false end
				return mod.class.Trap.canTrigger(self, x, y, who)
			end,
			triggered = function(self, x, y, who)
				if who:checkHit(self.disarm_power + 5, who:combatPhysicalResist(), 0, 95, 15) and who:canBe("stun") and who:canBe("pin") then
					who:setEffect(who.EFF_PINNED, dur, {})
				else
					game.logSeen(who, "%s resists!", who.name:capitalize())
				end
				return true, true
			end
		}
		game.level.map(self.x, self.y, Map.TRAP, trap)
		return true
	end,
	info = function(self, t)
		return ([[Lay an invisible web under you trapping all non-spiderkin that passes.]]):format()
	end,
}

newTalent{
	name = "Darkness",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 4,
	cooldown = 6,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="ball", range=0, radius=2 + self:getTalentLevelRaw(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local g = engine.Entity.new{name="darkness", show_tooltip=true, block_sight=true, always_remember=false, unlit=self:getTalentLevel(t) * 10}
			game.level.map(px, py, Map.TERRAIN+1, g)
			game.level.map.remembers(px, py, false)
			game.level.map.lites(px, py, false)
		end, nil, {type="dark"})
		self:teleportRandom(self.x, self.y, 5)
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[Weave darkness, blocking all light but the most powerful and teleport your a short range.
		The damage will increase with the Dexterity stat]]):format(20 + (self:getDex() * self:getTalentLevel(t)) * 0.3)
	end,
}

newTalent{
	name = "Throw Boulder",
	type = {"wild-gift/other", },
	points = 5,
	equilibrium = 5,
	cooldown = 3,
	tactical = {
		ATTACK = 10,
	},
	range = 20,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=1, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSKNOCKBACK, {dist=3+self:getTalentLevelRaw(t), dam=self:spellCrit(12 + self:getStr(50) * self:getTalentLevel(t))}, {type="archery"})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[Throws a huge boulder at a target, damaging it for %0.2f and knocking it back.
		The damage will increase with the Strength stat]]):format(12 + self:getStr(50) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Howl",
	type = {"wild-gift/other", },
	points = 5,
	equilibrium = 5,
	cooldown = 10,
	tactical = {
		ATTACK = 10,
	},
	message = "@Source@ howls",
	range = 20,
	direct_hit = true,
	action = function(self, t)
		local rad = self:getTalentLevel(t) + 5
		for i = self.x - rad, self.x + rad do for j = self.y - rad, self.y + rad do if game.level.map:isBound(i, j) then
			local actor = game.level.map(i, j, game.level.map.ACTOR)
			if actor and not actor.player then
				if self:reactionToward(actor) >= 0 then
					local tx, ty, a = self:getTarget()
					if a then
						actor:setTarget(a)
					end
				else
					actor:setTarget(self)
				end
			end
		end end end
		return true
	end,
	info = function(self, t)
		return ([[Howl a call to your hunting pack.]])
	end,
}

newTalent{
	name = "Shriek",
	type = {"wild-gift/other", },
	points = 5,
	equilibrium = 5,
	cooldown = 10,
	tactical = {
		ATTACK = 10,
	},
	message = "@Source@ shrieks.",
	range = 20,
	direct_hit = true,
	action = function(self, t)
		local rad = self:getTalentLevel(t) + 5
		for i = self.x - rad, self.x + rad do for j = self.y - rad, self.y + rad do if game.level.map:isBound(i, j) then
			local actor = game.level.map(i, j, game.level.map.ACTOR)
			if actor and not actor.player then
				if self:reactionToward(actor) >= 0 then
					local tx, ty, a = self:getTarget()
					if a then
						actor:setTarget(a)
					end
				else
					actor:setTarget(self)
				end
			end
		end end end
		return true
	end,
	info = function(self, t)
		return ([[Shriek to call your allies.]])
	end,
}

newTalent{
	name = "Crush",
	type = {"technique/other", 1},
	require = techs_req1,
	points = 5,
	cooldown = 6,
	stamina = 12,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "You cannot use Crush without a two-handed weapon!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.4))

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttackStr(weapon.combat), target:combatPhysicalResist(), 0, 95, 10 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_PINNED, 2 + self:getTalentLevel(t), {})
			else
				game.logSeen(target, "%s resists the crushing!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with a mighty blow to the legs doing %d%% weapon damage, if the attack hits, the target is unable to move for %d turns.]]):format(100 * self:combatTalentWeaponDamage(t, 1, 1.4), 2+self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Mind Sear",
	type = {"wild-gift/other", 1},
	points = 5,
	cooldown = 2,
	equilibrium = 5,
	range = 15,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.MIND, self:spellCrit(self:combatTalentMindDamage(t, 10, 370)), {type="mind"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self)
		return ([[Sends a telepathic attack, trying to destroy the brains of any target in the beam, doing %0.2f mind damage.
		The damage will increase with Willpower and Cunning stats.]]):format(self:combatTalentMindDamage(t, 10, 370))
	end,
}

newTalent{
	name = "Silence",
	type = {"wild-gift/other", 1},
	points = 5,
	cooldown = 10,
	equilibrium = 5,
	range = 15,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SILENCE, math.floor(4 + self:getTalentLevel(t)), {type="mind"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self)
		return ([[Sends a telepathic attack, silencing the target for %d turns.]]):format(math.floor(4 + self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Telekinetic Blast",
	type = {"wild-gift/other", 1},
	points = 5,
	cooldown = 2,
	equilibrium = 5,
	range = 15,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.MINDKNOCKBACK, self:spellCrit(self:combatTalentMindDamage(t, 10, 170)), {type="mind"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self)
		return ([[Sends a telekinetic attack, knocking back the target and doing %0.2f physical damage.
		The damage will increase with Willpower and Cunning stats.]]):format(self:combatTalentMindDamage(t, 10, 170))
	end,
}

newTalent{
	name = "Soul Rot",
	type = {"corruption/other", 1},
	points = 5,
	cooldown = 3,
	vim = 10,
	range = 20,
	proj_speed = 10,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.BLIGHT, self:spellCrit(self:combatTalentSpellDamage(t, 20, 250)), {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self)
		return ([[Projects a bolt of pure blight, doing %0.2f blight damage.
		The damage will increase with Magic stat.]]):format(self:combatTalentSpellDamage(t, 20, 250))
	end,
}

newTalent{
	name = "Blightzone",
	type = {"corruption/other", 1},
	points = 5,
	cooldown = 13,
	vim = 27,
	range = 20,
	direct_hit = true,
	action = function(self, t)
		local duration = self:getTalentLevel(t) + 2
		local radius = 4
		local dam = self:combatTalentSpellDamage(t, 4, 65)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.BLIGHT, dam,
			radius,
			5, nil,
			{type="blightzone"},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self)
		return ([[Corrupted vapour rises at the target location doing %0.2f blight damage every turn for %d turns.
		The damage will increase with Magic stat.]]):format(self:combatTalentSpellDamage(t, 5, 65), self:getTalentLevel(t) + 2)
	end,
}

newTalent{
	name = "Blood Grasp",
	type = {"corruption/other", 1},
	points = 5,
	cooldown = 5,
	vim = 20,
	range = 20,
	proj_speed = 20,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_blood"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.DRAINLIFE, {dam=self:spellCrit(self:combatTalentSpellDamage(t, 10, 220)), healfactor=0.5}, {type="blood"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self)
		return ([[Projects a bolt of corrupted blood doing %0.2f blight damage and healing the caster for half the damage done.
		The damage will increase with Magic stat.]]):format(self:combatTalentSpellDamage(t, 10, 220))
	end,
}
newTalent{
	name = "Blood Spray",
	type = {"corruption/other", 1},
	points = 5,
	cooldown = 7,
	vim = 24,
	range = function(self, t) return math.ceil(3 + self:getTalentLevel(t)) end,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.CORRUPTED_BLOOD, {
			dam = self:spellCrit(self:combatTalentSpellDamage(t, 10, 170)),
			disease_chance = 20 + self:getTalentLevel(t) * 10,
			disease_dam = self:spellCrit(self:combatTalentSpellDamage(t, 10, 220)) / 6,
			disease_power = self:combatTalentSpellDamage(t, 10, 20),
			dur = 6,
		}, {type="blood"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self)
		return ([[You extract corrupted blood from your own body, hitting everything in a frontal cone for %0.2f blight damage.
		Each affected creature has a %d%% chance of being infected by a random disease doing %0.2f blight damage over 6 turns.
		The damage will increase with Magic stat.]]):format(self:combatTalentSpellDamage(t, 10, 170), 20 + self:getTalentLevel(t) * 10, self:combatTalentSpellDamage(t, 10, 220))
	end,
}
