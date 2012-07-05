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
local Chat = require "engine.Chat"

newTalent{
	name = "Life Tap", short_name = "GOLEMANCY_LIFE_TAP",
	type = {"spell/advanced-golemancy", 1},
	require = spells_req_high1,
	points = 5,
	mana = 25,
	cooldown = 12,
	tactical = { HEAL = 2 },
	is_heal = true,
	getPower = function(self, t) return 70 + self:combatTalentSpellDamage(t, 15, 450) end,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "Your golem is currently inactive.")
			return
		end

		local power = math.min(t.getPower(self, t), golem.life)
		golem.life = golem.life - power -- Direct hit, bypass all checks
		golem.changed = true
		self:attr("allow_on_heal", 1)
		self:heal(power)
		self:attr("allow_on_heal", -1)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local power=t.getPower(self, t)
		return ([[You tap into your golem's life energies to replenish your own. Drains %d life.]]):
		format(power)
	end,
}

newTalent{
	name = "Gem Golem",
	type = {"spell/advanced-golemancy",2},
	require = spells_req_high2,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[Insert a pair of gems into your golem, providing it with the gem bonuses and changing its melee attack damage type.
		Gem level usable: %d
		Gem changing is done when refitting your golem (use Refit Golem at full life).]]):format(self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Supercharge Golem",
	type = {"spell/advanced-golemancy", 3},
	require = spells_req_high3,
	points = 5,
	mana = 20,
	cooldown = function(self, t) return math.floor(25 - self:getTalentLevel(t)) end,
	tactical = { DEFEND = 1, ATTACK=1 },
	getPower = function(self, t) return (60 + self:combatTalentSpellDamage(t, 15, 450)) / 7, 7, 20 + self:getTalentLevel(t) * 7 end,
	action = function(self, t)
		local regen, dur, hp = t.getPower(self, t)

		-- ressurect the golem
		if not game.level:hasEntity(self.alchemy_golem) or self.alchemy_golem.dead then
			self.alchemy_golem.dead = nil
			self.alchemy_golem.life = self.alchemy_golem.max_life / 100 * hp

			-- Find space
			local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to supercharge!")
				return
			end
			game.zone:addEntity(game.level, self.alchemy_golem, "actor", x, y)
			self.alchemy_golem:setTarget(nil)
			self.alchemy_golem.ai_state.tactic_leash_anchor = self
			self.alchemy_golem:removeAllEffects()
		end

		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "Your golem is currently inactive.")
			return
		end

		golem:setEffect(golem.EFF_SUPERCHARGE_GOLEM, dur, {regen=regen})

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local regen, turns, life = t.getPower(self, t)
		return ([[You activate a special mode of your golem, boosting its regeneration rate by %0.2f life per turn for %d turns.
		If your golem was dead it is instantly brought back to life with %d%% life.
		While supercharged your golem enrages and deals 25%% more damage.]]):
		format(regen, turns, life)
	end,
}



newTalent{
	name = "Runic Golem",
	type = {"spell/advanced-golemancy",4},
	require = spells_req_high4,
	mode = "passive",
	points = 5,
	no_npc_use = true,
	on_learn = function(self, t)
		self.alchemy_golem.life_regen = self.alchemy_golem.life_regen + 1
		self.alchemy_golem.mana_regen = self.alchemy_golem.mana_regen + 1
		self.alchemy_golem.stamina_regen = self.alchemy_golem.stamina_regen + 1
		local lev = self:getTalentLevelRaw(t)
		if lev == 1 or lev == 3 or lev == 5 then
			self.alchemy_golem.max_inscriptions = self.alchemy_golem.max_inscriptions + 1
			self.alchemy_golem.inscriptions_slots_added = self.alchemy_golem.inscriptions_slots_added + 1
		end
	end,
	on_unlearn = function(self, t)
		self.alchemy_golem.life_regen = self.alchemy_golem.life_regen - 1
		self.alchemy_golem.mana_regen = self.alchemy_golem.mana_regen - 1
		self.alchemy_golem.stamina_regen = self.alchemy_golem.stamina_regen - 1
		local lev = self:getTalentLevelRaw(t)
		if lev == 0 or lev == 2 or lev == 4 then
			self.alchemy_golem.max_inscriptions = self.alchemy_golem.max_inscriptions - 1
			self.alchemy_golem.inscriptions_slots_added = self.alchemy_golem.inscriptions_slots_added - 1
		end
	end,
	info = function(self, t)
		return ([[Increases your golem's life, mana and stamina regeneration rates by %0.2f.
		At level 1, 3 and 5 the golem also gains a new rune slot.
		Even without this talent, Golems start with three rune slots]]):
		format(self:getTalentLevelRaw(t))
	end,
}
