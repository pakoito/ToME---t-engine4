-- ToME - Tales of Maj'Eyal
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
		display = 'g', color=colors.WHITE, image = "player/alchemy_golem.png",
		level_range = {1, 50}, exp_worth=0,
		life_rating = 13,
		never_anger = true,

		combat = { dam=10, atk=10, apr=0, dammod={str=1} },

		body = { INVEN = 1000, MAINHAND=1, BODY=1, GEM=2 },
		infravision = 20,
		rank = 3,
		size_category = 4,

		resolvers.talents{
			[Talents.T_MASSIVE_ARMOUR_TRAINING]=1,
			[Talents.T_HEAVY_ARMOUR_TRAINING]=1,
			[Talents.T_WEAPON_COMBAT]=2,
			[Talents.T_MANA_POOL]=1,
			[Talents.T_STAMINA_POOL]=1,
			[Talents.T_GOLEM_KNOCKBACK]=1,
		},

		resolvers.equip{
			{type="weapon", subtype="battleaxe", autoreq=true, id=true},
			{type="armor", subtype="heavy", autoreq=true, id=true}
		},

		talents_types = {
			["golem/fighting"] = true,
			["golem/arcane"] = true,
		},
		inscription_restrictions = { ["inscriptions/runes"] = true, },

		hotkey = {},
		hotkey_page = 1,

		ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_astar" },
		energy = { mod=1 },
		stats = { str=14, dex=12, mag=12, con=12 },

		-- No natural exp gain
		gainExp = function() end,
		forceLevelup = function(self) if self.summoner then return mod.class.Actor.forceLevelup(self, self.summoner.level) end end,

		-- Break control when losing LOS
		on_act = function(self)
			if game.player ~= self then return end
			if not self:hasLOS(self.summoner.x, self.summoner.y) then
				if not self:hasEffect(self.EFF_GOLEM_OFS) then
					self:setEffect(self.EFF_GOLEM_OFS, 8, {})
				end
			else
				if self:hasEffect(self.EFF_GOLEM_OFS) then
					self:removeEffect(self.EFF_GOLEM_OFS)
				end
			end
		end,

		on_can_control = function(self, vocal)
			if not self:hasLOS(self.summoner.x, self.summoner.y) then
				if vocal then game.logPlayer(game.player, "Your golem is out of sight, you can not establish direct control.") end
				return false
			end
			return true
		end,

		unused_stats = 0,
		unused_talents = 0,
		unused_generics = 0,
		unused_talents_types = 0,

		no_points_on_levelup = function(self)
			self.unused_stats = self.unused_stats + 2
			if self.level >= 2 and self.level % 3 == 0 then self.unused_talents = self.unused_talents + 1 end
		end,

		keep_inven_on_death = true,
--		no_auto_resists = true,
		open_door = true,
		cut_immune = 1,
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
	no_npc_use = true,
	getHeal = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		return self:combatTalentSpellDamage(t, 15, 350, ((ammo and ammo.alchemist_power or 0) + self:combatSpellpower()) / 2)
	end,
	action = function(self, t)
		if not self.alchemy_golem then
			self.alchemy_golem = game.zone:finishEntity(game.level, "actor", makeGolem())
			game.party:addMember(self.alchemy_golem, {control="full", type="golem", title="Golem"})
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
			local chat = Chat.new("alchemist-golem", self.alchemy_golem, self, {golem=self.alchemy_golem, player=self})
			chat:invoke()

		-- heal the golem
		elseif (game.level:hasEntity(self.alchemy_golem) or self:hasEffect(self.EFF_GOLEM_MOUNT)) and self.alchemy_golem.life < self.alchemy_golem.max_life then
			if not ammo or ammo:getNumber() < 2 then
				game.logPlayer(self, "You need to ready 2 alchemist gems in your quiver to heal your golem.")
				return
			end
			for i = 1, 2 do self:removeObject(self:getInven("QUIVER"), 1) end
			self.alchemy_golem:heal(t.getHeal(self, t))

		-- resurrect the golem
		elseif not self:hasEffect(self.EFF_GOLEM_MOUNT) then
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
			self.alchemy_golem:setTarget(nil)
			self.alchemy_golem:removeAllEffects()
		end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[Interact with your golem
		- If it is destroyed you will take some time to reconstruct it (takes 15 alchemist gems).
		- If it is alive you will be able to talk to it, change its weapon and armour or repair it for %d (takes 2 alchemist gems)]]):
		format(heal)
	end,
}

newTalent{
	name = "Golem Power",
	type = {"spell/golemancy", 1},
	mode = "passive",
	require = spells_req1,
	points = 5,
	on_learn = function(self, t)
		self.alchemy_golem:learnTalent(Talents.T_WEAPON_COMBAT, true)
		self.alchemy_golem:learnTalent(Talents.T_WEAPONS_MASTERY, true)
	end,
	on_unlearn = function(self, t)
		self.alchemy_golem:unlearnTalent(Talents.T_WEAPON_COMBAT, true)
		self.alchemy_golem:unlearnTalent(Talents.T_WEAPONS_MASTERY, true)
	end,
	info = function(self, t)
		local attack = self:getTalentFromId(Talents.T_WEAPON_COMBAT).getAttack(self, t)
		local damage = self:getTalentFromId(Talents.T_WEAPONS_MASTERY).getDamage(self, t)
		return ([[Improves your golem proficiency with weapons. Increasing its attack by %d and damage by %d%%.]]):
		format(attack, 100 * damage)
	end,
}

newTalent{
	name = "Golem Resilience",
	type = {"spell/golemancy", 2},
	mode = "passive",
	require = spells_req2,
	points = 5,
	on_learn = function(self, t)
		self.alchemy_golem:learnTalent(Talents.T_HEALTH, true)
		self.alchemy_golem:learnTalent(Talents.T_HEAVY_ARMOUR_TRAINING, true)
		self.alchemy_golem:learnTalent(Talents.T_MASSIVE_ARMOUR_TRAINING, true)
	end,
	on_unlearn = function(self, t)
		self.alchemy_golem:unlearnTalent(Talents.T_HEALTH, true)
		self.alchemy_golem:unlearnTalent(Talents.T_HEAVY_ARMOUR_TRAINING, true)
		self.alchemy_golem:unlearnTalent(Talents.T_MASSIVE_ARMOUR_TRAINING, true)
	end,
	info = function(self, t)
		local health = self:getTalentFromId(Talents.T_HEALTH).getHealth(self, t)
		local heavyarmor = self:getTalentFromId(Talents.T_HEAVY_ARMOUR_TRAINING).getArmor(self, t)
		local massivearmor = self:getTalentFromId(Talents.T_MASSIVE_ARMOUR_TRAINING).getArmor(self, t)
		return ([[Improves your golem armour training and health. Increases armor by %d when wearing heavy armor or by %d when wearing massive armor also increases health by %d.]]):
		format(heavyarmor, massivearmor, health)
	end,
}

newTalent{
	name = "Invoke Golem",
	type = {"spell/golemancy",3},
	require = spells_req3,
	points = 5,
	mana = 10,
	cooldown = 20,
	no_npc_use = true,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 15, 50) end,
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

		golem:setEffect(golem.EFF_MIGHTY_BLOWS, 5, {power=t.getPower(self, t)})
		if golem == mover then
			golem:move(x, y, true)
		end
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local power=t.getPower(self, t)
		return ([[You invoke your golem to your side, granting it a temporary melee power increase of %d for 5 turns.]]):
		format(power)
	end,
}

newTalent{
	name = "Golem Portal",
	type = {"spell/golemancy",4},
	require = spells_req4,
	points = 5,
	mana = 40,
	cooldown = function(self, t) return 15 - self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "Your golem is currently inactive.")
			return
		end

		local chance = self:getTalentLevelRaw(t) * 15 + 25
		local px, py = self.x, self.y
		local gx, gy = golem.x, golem.y

		self:move(gx, gy, true)
		golem:move(px, py, true)
		self:move(gx, gy, true)
		golem:move(px, py, true)
		game.level.map:particleEmitter(px, py, 1, "teleport")
		game.level.map:particleEmitter(gx, gy, 1, "teleport")

		for uid, e in pairs(game.level.entities) do
			local _, _, tgt = e:getTarget()
			if e:reactionToward(self) < 0 and tgt == self and rng.percent(chance) then
				e:setTarget(golem)
				game.logSeen(e, "%s focuses on %s.", e.name:capitalize(), golem.name)
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Teleport to your golem and your golem to your place. Your foes will be confused and those that were attacking you will have %d%% chances to target your golem instead.]]):
		format(self:getTalentLevelRaw(t) * 15 + 25)
	end,
}
