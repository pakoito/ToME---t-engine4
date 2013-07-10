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

newTalent{
	name = "Willful Tormenter",
	type = {"corruption/torment", 1},
	require = corrs_req1,
	mode = "sustained",
	points = 5,
	cooldown = 20,
	tactical = { BUFF = 2 },
	VimBonus = function(self, t) return self:combatTalentScale(t, 20, 75, 0.75) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/flame")
		return {
			vim = self:addTemporaryValue("max_vim", t.VimBonus(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("max_vim", p.vim)

		while self:getMaxVim() < 0 do
			local l = {}
			for tid, _ in pairs(self.sustain_talents) do
				local t = self:getTalentFromId(tid)
				if t.sustain_vim then l[#l+1] = tid end
			end
			if #l == 0 then break end
			self:forceUseTalent(rng.table(l), {ignore_energy=true, no_equilibrium_fail=true, no_paradox_fail=true})
		end

		return true
	end,
	info = function(self, t)
		return ([[You set your mind toward a single goal: the destruction of all your foes.
		Increases the maximum amount of vim you can store by %d.]]):
		format(t.VimBonus(self, t))
	end,
}

newTalent{
	name = "Blood Lock",
	type = {"corruption/torment", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 16,
	vim = 12,
	range = 10,
	radius = 2,
	tactical = { DISABLE = 1 },
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 12)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_BLOOD_LOCK, t.getDuration(self, t), {src=self, dam=self:combatTalentSpellDamage(t, 4, 90), apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Reach out and touch the blood and health of your foes. Any creatures caught in the radius 2 ball will be unable to heal above their current life value (at the time of the casting) for %d turns.]]):
		format(t.getDuration(self, t))
	end,
}

newTalent{
	name = "Overkill",
	type = {"corruption/torment", 3},
	require = corrs_req3,
	points = 5,
	mode = "sustained",
	cooldown = 20,
	sustain_vim = 18,
	tactical = { BUFF = 2 },
	oversplash = function(self,t) return self:combatLimit(self:combatTalentSpellDamage(t, 10, 70), 100, 20, 0, 66.7, 46.7) end, -- Limit to <100%
	activate = function(self, t)
		game:playSoundNear(self, "talents/flame")
		return {ov = self:addTemporaryValue("overkill", t.oversplash(self,t)),}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("overkill", p.ov)
		return true
	end,
	info = function(self, t)
		return ([[When you kill a creature, the remainder of the damage done will not be lost. Instead, %d%% of it will splash in a radius 2 as blight damage.
		The splash damage will increase with your Spellpower.]]):format(t.oversplash(self,t))
	end,
}

newTalent{
	name = "Blood Vengeance",
	type = {"corruption/torment", 4},
	require = corrs_req4,
	points = 5,
	mode = "sustained",
	cooldown = 20,
	getPower = function(self, t) return self:combatTalentLimit(t, 5, 15, 10), self:combatLimit(self:combatTalentSpellDamage(t, 10, 90), 100, 20, 0, 50, 61.3) end, -- Limit threshold > 5%, chance < 100%
	sustain_vim = 22,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		local l, c = t.getPower(self, t)
		game:playSoundNear(self, "talents/flame")
		return {
			l = self:addTemporaryValue("reduce_spell_cooldown_on_hit", l),
			c = self:addTemporaryValue("reduce_spell_cooldown_on_hit_chance", c),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("reduce_spell_cooldown_on_hit", p.l)
		self:removeTemporaryValue("reduce_spell_cooldown_on_hit_chance", p.c)
		return true
	end,
	info = function(self, t)
		local l, c = t.getPower(self, t)
		return ([[When you are dealt a blow that reduces your life by at least %d%%, you have a %d%% chance to reduce the remaining cooldown of all your spells by 1.
		The chance will increase with your Spellpower.]]):
		format(l, c)
	end,
}
