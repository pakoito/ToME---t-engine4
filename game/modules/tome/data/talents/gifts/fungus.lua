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
	name = "Wild Growth",
	type = {"wild-gift/fungus", 1},
	require = gifts_req1,
	points = 5,
	mode = "sustained",
	sustain_equilibrium = 15,
	cooldown = 20,
	tactical = { BUFF = 2 },
	getDur = function(self, t) return math.max(1,  math.floor(self:getTalentLevel(t))) end,
	activate = function(self, t)
		local dur = t.getDur(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {
			dur = self:addTemporaryValue("liferegen_dur", dur),
		}
		if self:knowTalent(self.T_FUNGAL_GROWTH) then
			local t= self:getTalentFromId(self.T_FUNGAL_GROWTH)
			ret.fg = self:addTemporaryValue("fungal_growth", t.getPower(self, t))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("liferegen_dur", p.dur)
		if p.fg then self:removeTemporaryValue("fungal_growth", p.fg) end
		return true
	end,
	info = function(self, t)
		local dur = t.getDur(self, t)
		return ([[Surround yourself with a myriad of tiny, nearly invisible, healing fungus.
		Any regeneration effect active on you will have its duration increased by +%d turns.]]):
		format(dur)
	end,
}

newTalent{
	name = "Fungal Growth",
	type = {"wild-gift/fungus", 2},
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
	name = "Ancestral Life",
	type = {"wild-gift/fungus", 3},
	require = gifts_req3,
	points = 5,
	mode = "passive",
	getEq = function(self, t) return util.bound(math.ceil(self:getTalentLevel(t) / 2), 1, 4) end,
	getTurn = function(self, t) return util.bound(50 + self:combatTalentMindDamage(t, 5, 500) / 10, 50, 160) end,
	info = function(self, t)
		local eq = t.getEq(self, t)
		local turn = t.getTurn(self, t)
		return ([[Your fungus can reach in the primordial ages of the world.
		Each time a regeneration effect is used on you you gain %d%% of a turn.
		Also regeneration effects on you will decrease your equilibrium by %d each turn.]]):
		format(turn, eq)
	end,
}

newTalent{
	name = "Sudden Growth",
	type = {"wild-gift/fungus", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 22,
	cooldown = 25,
	tactical = { HEAL = function(self, t, target) return self.life_regen * 10 end },
	getMult = function(self, t) return util.bound(5 + self:getTalentLevel(t), 3, 12) end,
	action = function(self, t)
		local amt = self.life_regen * t.getMult(self, t)

		self:heal(amt)

		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local mult = t.getMult(self, t)
		return ([[A wave of energy passes through your fungus, making it release immediate healing energies on you, healing you for %d%% of your current life regeneration rate.]]):
		format(mult * 100)
	end,
}
