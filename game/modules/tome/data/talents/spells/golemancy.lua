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
local Chat = require "engine.Chat"

function getGolem(self)
	if game.level:hasEntity(self.alchemy_golem) then
		return self.alchemy_golem, self.alchemy_golem
	elseif self:hasEffect(self.EFF_GOLEM_MOUNT) then
		return self, self.alchemy_golem
	end
end

local function makeGolem()
	return require("mod.class.NPC").new{
		type = "construct", subtype = "golem",
		display = 'g', color=colors.WHITE,
		level_range = {1, 50}, exp_worth=0,
		life_rating = 13,

		combat = { dam=10, atk=10, apr=0, dammod={str=1} },

		body = { INVEN = 50, MAINHAND=1, OFFHAND=1, BODY=1,},
		infravision = 20,
		rank = 3,
		size_category = 4,

		resolvers.talents{
			[Talents.T_MASSIVE_ARMOUR_TRAINING]=1,
			[Talents.T_HEAVY_ARMOUR_TRAINING]=1,
			[Talents.T_WEAPON_COMBAT]=2,
		},

		resolvers.equip{
			{type="weapon", subtype="battleaxe", autoreq=true},
			{type="armor", subtype="heavy", autoreq=true}
		},

		autolevel = "alchemy-golem",
		ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=4, ai_move="move_astar" },
		energy = { mod=1 },
		stats = { str=14, dex=12, mag=10, con=12 },

		keep_inven_on_death = true,
--		no_auto_resists = true,
		open_door = true,
		blind_immune = 1,
		fear_immune = 1,
		poison_immune = 1,
		disease_immune = 1,
		stone_immune = 1,
		see_invisible = 30,
		no_breath = 1,
	}
end

newTalent{
	name = "Refit Golem",
	type = {"spell/golemancy-base", 1},
	require = spells_req1,
	points = 1,
	cooldown = 20,
	mana = 10,
	action = function(self, t)
		if not self.alchemy_golem then
			self.alchemy_golem = game.zone:finishEntity(game.level, "actor", makeGolem())
			game.persistant_actors[self.alchemy_golem] = 1
			if not self.alchemy_golem then return end
			self.alchemy_golem.faction = self.faction
			self.alchemy_golem.name = "golem (servant of "..self.name..")"
			self.alchemy_golem.summoner = self
			self.alchemy_golem.summoner_gain_exp = true

			-- Find space
			local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to refit!")
				return
			end
			game.zone:addEntity(game.level, self.alchemy_golem, "actor", x, y)
			return
		end

		local wait = function()
			local co = coroutine.running()
			local ok = false
			self:restInit(20, "refitting", "refitted", function(cnt, max)
				if cnt > max then ok = true end
				coroutine.resume(co)
			end)
			coroutine.yield()
			if not ok then
				game.logPlayer(self, "You have been interrupted!")
				return false
			end
			return true
		end

		local ammo = self:hasAlchemistWeapon()

		-- talk to the golem
		if game.level:hasEntity(self.alchemy_golem) and self.alchemy_golem.life >= self.alchemy_golem.max_life then
			local chat = Chat.new("alchemist-golem", self.alchemy_golem, self)
			chat:invoke()

		-- heal the golem
		elseif game.level:hasEntity(self.alchemy_golem) and self.alchemy_golem.life < self.alchemy_golem.max_life then
			if not ammo or ammo:getNumber() < 2 then
				game.logPlayer(self, "You need to ready 2 alchemist gems in your quiver to heal your golem.")
				return
			end
			for i = 1, 2 do self:removeObject(self:getInven("QUIVER"), 1) end
			self.alchemy_golem:heal(self:combatTalentSpellDamage(t, 15, 350, (ammo.alchemist_power + self:combatSpellpower()) / 2))

		-- resurrect the golem
		else
			if not ammo or ammo:getNumber() < 15 then
				game.logPlayer(self, "You need to ready 15 alchemist gems in your quiver to heal your golem.")
				return
			end
			if not wait() then return end
			for i = 1, 15 do self:removeObject(self:getInven("QUIVER"), 1) end

			self.alchemy_golem.dead = nil
			if self.alchemy_golem.life < 0 then self.alchemy_golem.life = self.alchemy_golem.max_life / 3 end

			-- Find space
			local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to refit!")
				return
			end
			game.zone:addEntity(game.level, self.alchemy_golem, "actor", x, y)
		end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		local heal = 0
		if ammo then self:combatTalentSpellDamage(t, 15, 150, (ammo.alchemist_power + self:combatSpellpower()) / 2) end
		return ([[Interract with your golem
		- If it is destroyed you will take some time to reconstruct it (takes 15 alchemist gems).
		- If it is alive you will be able to talk to it, change its weapon and armour or heal it (%d; takes 2 alchemist gems)]]):
		format(heal)
	end,
}

newTalent{
	name = "Golem: Taunt", short_name = "GOLEM_TAUNT",
	type = {"spell/golemancy", 1},
	require = spells_req1,
	points = 5,
	cooldown = function(self, t)
		return 20 - self:getTalentLevelRaw(t) * 2
	end,
	range = 10,
	mana = 5,
	requires_target = true,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "Your golem is currently inactive.")
			return
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		game.target.source_actor = mover
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = self
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(mover.x, mover.y, x, y)) > self:getTalentRange(t) then return nil end

		mover:setTarget(target)
		target:setTarget(mover)
		game.logPlayer(self, "Your golem provokes %s to attack it.", target.name:capitalize())

		return true
	end,
	info = function(self, t)
		return ([[Orders your golem to taunt a target, forcing it to attack the golem.]]):format()
	end,
}

newTalent{
	name = "Golem: Knockback",
	type = {"spell/golemancy", 2},
	require = spells_req2,
	points = 5,
	cooldown = 10,
	range = 10,
	mana = 5,
	requires_target = true,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "Your golem is currently inactive.")
			return
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		game.target.source_actor = mover
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = self
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(mover.x, mover.y, x, y)) > self:getTalentRange(t) then return nil end

		mover:setTarget(target)

		local l = line.new(mover.x, mover.y, x, y)
		local lx, ly = l()
		local tx, ty = mover.x, mover.y
		lx, ly = l()
		while lx and ly do
			if game.level.map:checkAllEntities(lx, ly, "block_move", mover) then break end
			tx, ty = lx, ly
			lx, ly = l()
		end

		mover:move(tx, ty, true)

		-- Attack ?
		if math.floor(core.fov.distance(mover.x, mover.y, x, y)) > 1 then return true end
		local hit = golem:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.8, 1.6), true)

		-- Try to knockback !
		if hit then
			if target:checkHit(golem:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
				target:knockback(mover.x, mover.y, 3)
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Your golem rushes to the target, knocking it back and doing %d%% damage.]]):format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.6))
	end,
}

newTalent{
	name = "Golem: Crush",
	type = {"spell/golemancy", 3},
	require = spells_req3,
	points = 5,
	cooldown = 10,
	range = 10,
	mana = 5,
	requires_target = true,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "Your golem is currently inactive.")
			return
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		game.target.source_actor = mover
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = self
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(mover.x, mover.y, x, y)) > self:getTalentRange(t) then return nil end

		mover:setTarget(target)

		local l = line.new(mover.x, mover.y, x, y)
		local lx, ly = l()
		local tx, ty = mover.x, mover.y
		lx, ly = l()
		while lx and ly do
			if game.level.map:checkAllEntities(lx, ly, "block_move", mover) then break end
			tx, ty = lx, ly
			lx, ly = l()
		end

		mover:move(tx, ty, true)

		-- Attack ?
		if math.floor(core.fov.distance(mover.x, mover.y, x, y)) > 1 then return true end
		local hit = golem:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.8, 1.6), true)

		-- Try to knockback !
		if hit then
			if target:checkHit(golem:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 10 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_PINNED, 2 + self:getTalentLevel(t), {})
			else
				game.logSeen(target, "%s resists the crushing!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Your golem rushes to the target, crushing it and doing %d%% damage.]]):format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.6))
	end,
}

newTalent{
	name = "Invoke Golem",
	type = {"spell/golemancy",4},
	require = spells_req4,
	points = 5,
	mana = 10,
	cooldown = 20,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "Your golem is currently inactive.")
			return
		end

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to invoke!")
			return
		end

		golem:setEffect(golem.EFF_MIGHTY_BLOWS, 5, {power=self:combatTalentSpellDamage(t, 15, 50)})
		if golem == mover then
			golem:move(x, y, true)
		end
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[You invoke your golem to your side, granting it a temporary melee power increase of %d for 5 turns.]]):format(self:combatTalentSpellDamage(t, 15, 50))
	end,
}
