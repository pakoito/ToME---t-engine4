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
	name = "Mitosis",
	type = {"wild-gift/ooze", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 30,
	no_energy = true,
	tactical = { BUFF = 2 },
	getDur = function(self, t) return math.max(5, math.floor(self:getTalentLevel(t) * 2)) end,
	action = function(self, t)
		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space for mitosis!")
			return
		end

		local dur = t.getDur(self, t)
		self:setEffect(self.EFF_MITOSIS, t.getDur(self, t), {power=10 + self:combatTalentMindDamage(t, 5, 200) / 10})

		local m = self:clone{
			no_drops = true,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDur(self, t),
			ai_target = {actor=nil},
			ai = "summoned", ai_real = "tactical",
			name = "Mitosis of "..self.name,
			desc = "Acidic mitosis of "..self.name..".",
		}
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil

		m.energy.value = 0
		m.forceLevelup = function() end
		m.die = nil
		m.on_die = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.puuid = nil
		m.on_takehit = nil
		m.can_talk = nil
		m.clone_on_hit = nil
		m.exp_worth = 0
		m.no_inventory_access = true
		m.player = true
		m:unlearnTalent(m.T_MITOSIS, m:getTalentLevel(m.T_MITOSIS))
		m.remove_from_party_on_death = true

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "shadow")

		if game.party:hasMember(self) then
			game.party:addMember(m, {
				control="full",
				type="mitosis",
				title="Mitosis of "..self.name,
				temporary_level=1,
				orders = {target=true},
			})
		end

		game:playSoundNear(self, "talents/spell_generic2")

		return true
	end,
	info = function(self, t)
		local dur = t.getDur(self, t)
		return ([[Your body is more like that of an ooze, you can split into two for %d turns.
		Your original self has the original ooze aspect while your mitosis gains the acid aspect.
		If you know the Oozing Blades tree all the talents inside are exchanged for those of the Corrosive Blades tree.
		Your two selves share the same healthpool.
		While you are split both of you gain %d%% all resistances.
		Resistances will increase with Mindpower.]]):
		format(dur, 10 + self:combatTalentMindDamage(t, 5, 200) / 10)
	end,
}

newTalent{
	name = "Reabsorb",
	type = {"wild-gift/ooze", 2},
	require = gifts_req2,
	points = 5,
	mode = "passive",
	getPower = function(self, t) return 20 + self:combatTalentMindDamage(t, 5, 500) / 10 end,
	on_pre_use = function(self, t)
		if not game.party:findMember{type="mitosis"} then return end
		return true
	end,
	info = function(self, t)
		local p = t.getPower(self, t)
		return ([[Improve your fungus to allow it to take a part of any healing you receive and improve it.
		Each time you are healed you get a regeneration effect for 6 turns that heals you of %d%% of the direct heal you received.
		The effect will increase with your Mindpower.]]):
		format(p)
	end,
}

newTalent{
	name = "Swap",
	type = {"wild-gift/ooze", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 5,
	cooldown = 8,
	on_pre_use = function(self, t)
		if not game.party:findMember{type="mitosis"} then return end
		return true
	end,
	action = function(self, t)
		local target = game.party:findMember{type="mitosis"}

		local dur = 1 + self:getTalentLevel(t)
		self:setEffect(self.EFF_MITOSIS_SWAP, 6, {power=15 + self:combatTalentMindDamage(t, 5, 300) / 10})
		target:setEffect(target.EFF_MITOSIS_SWAP, 6, {power=15 + self:combatTalentMindDamage(t, 5, 300) / 10})

		self:heal(40 + self:combatTalentMindDamage(t, 5, 300))

		-- Displace
		game.level.map:remove(self.x, self.y, Map.ACTOR)
		game.level.map:remove(target.x, target.y, Map.ACTOR)
		game.level.map(self.x, self.y, Map.ACTOR, target)
		game.level.map(target.x, target.y, Map.ACTOR, self)
		self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local eq = t.getEq(self, t)
		local turn = t.getTurn(self, t)
		return ([[Both of you swap place in an instant, creatures attacking one will target the other.
		While swpaing you briefly merge together, boosting all your nature and acid damage by %d%% for 6 turns and healing you for %d%.
		Damage and healing increase with Mindpower.]]):
		format(15 + self:combatTalentMindDamage(t, 5, 300) / 10, 40 + self:combatTalentMindDamage(t, 5, 300))
	end,
}

newTalent{
	name = "One With The Ooze",
	type = {"wild-gift/ooze", 4},
	require = gifts_req4,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:attr("blind_immune", 0.2)
		self:attr("poison_immune", 0.2)
		self:attr("disease_immune", 0.2)
		self:attr("cut_immune", 0.2)
		self:attr("confusion_immune", 0.2)
	end,
	on_unlearn = function(self, t)
		self:attr("blind_immune", -0.2)
		self:attr("poison_immune", -0.2)
		self:attr("disease_immune", -0.2)
		self:attr("cut_immune", -0.2)
		self:attr("confusion_immune", -0.2)
	end,
	info = function(self, t)
		return ([[Your body becomes even more ooze-like, granting %d%% disease, poison, cuts, confusion and blindness resistances.]]):
		format(self:getTalentLevelRaw(t) * 20)
	end,
}
