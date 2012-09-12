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
	name = "azdadazdazdazd",
	type = {"wild-gift/malleable-body", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 30,
	no_energy = true,
	tactical = { BUFF = 2 },
	getDur = function(self, t) return math.max(5, math.floor(self:getTalentLevel(t) * 2)) end,
	action = function(self, t)

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
	name = "ervevev",
	type = {"wild-gift/malleable-body", 2},
	require = gifts_req2,
	points = 5,
	mode = "passive",
	getPower = function(self, t) return 20 + self:combatTalentMindDamage(t, 5, 500) / 10 end,

	info = function(self, t)
		local p = t.getPower(self, t)
		return ([[Improve your fungus to allow it to take a part of any healing you receive and improve it.
		Each time you are healed you get a regeneration effect for 6 turns that heals you of %d%% of the direct heal you received.
		The effect will increase with your Mindpower.]]):
		format(p)
	end,
}

newTalent{
	name = "zeczczeczec", 
	type = {"wild-gift/malleable-body", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 5,
	cooldown = 8,

	action = function(self, t)

		return true
	end,
	info = function(self, t)
		return ([[Both of you swap place in an instant, creatures attacking one will target the other.
		While swaping you briefly merge together, boosting all your nature and acid damage by %d%% for 6 turns and healing you for %d.
		Damage and healing increase with Mindpower.]]):
		format(15 + self:combatTalentMindDamage(t, 5, 300) / 10, 40 + self:combatTalentMindDamage(t, 5, 300))
	end,
}

newTalent{
	name = "Indiscernible Anatomy",
	type = {"wild-gift/malleable-body", 4},
	require = gifts_req4,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:attr("ignore_direct_crits", 15)
	end,
	on_unlearn = function(self, t)
		self:attr("ignore_direct_crits", -15)
	end,
	info = function(self, t)
		return ([[Your body internal organs are melted together, making it much harder to gain critical hits.
		All direct critical hits (physical, mental, spells) against you have %d%% chances to instead do their normal damage.]]):
		format(self:getTalentLevelRaw(t) * 15)
	end,
}
