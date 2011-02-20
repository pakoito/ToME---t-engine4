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

local function getHateMultiplier(self, min, max)
	return (min + ((max - min) * math.min(self.hate, 10) / 10))
end

newTalent{
	name = "Rampage",
	type = {"cursed/rampage", 1},
	require = cursed_str_req1,
	points = 5,
	tactical = { ATTACK = 3 },
	cooldown = function(self, t)
		local tReflexes = self:getTalentFromId(self.T_REFLEXES)
		if tReflexes then
			return tReflexes.getCooldown(self, tReflexes)
		else
			return 150
		end
	end,
	hate = 0.5,
	action = function(self, t, hateLoss)
		local hateLoss = 0
		local critical = 0
		local damage = 0
		local speed = 0
		local attack = 0
		local evasion = 0

		local hateMultiplier = getHateMultiplier(self, 0.1, 1.0)

		critical = t.getCritical(self, t) * hateMultiplier
		if not hateLoss then
			hateLoss = t.getHateLoss(self, t)
		end

		local duration = 5
		local tBrutality = self:getTalentFromId(self.T_BRUTALITY)
		if tBrutality then
			duration = tBrutality.getDuration(self, tBrutality)
			damage = tBrutality.getDamage(self, tBrutality) * hateMultiplier
		end

		local tReflexes = self:getTalentFromId(self.T_REFLEXES)
		if tReflexes then
			speed = tReflexes.getSpeed(self, tReflexes) * hateMultiplier
		end

		local tInstincts = self:getTalentFromId(self.T_INSTINCTS)
		if tInstincts then
			attack = tInstincts.getAttack(self, tInstincts) * hateMultiplier
			evasion = tInstincts.getEvasion(self, tInstincts) * hateMultiplier
		end

		self:setEffect(self.EFF_RAMPAGE, duration, { critical = critical, damage = damage, speed = speed, attack = attack, evasion = evasion, hateLoss = hateLoss })

		return true
	end,
	getHateLoss = function(self, t) return 0.75 - 0.05 * self:getTalentLevelRaw(t) end,
	getCritical = function(self, t) return 10 + 8 * self:getTalentLevel(t) end,
	onTakeHit = function(t, self, fractionDamage)
		if fractionDamage < 0.08 then return false end
		if self:hasEffect(self.EFF_RAMPAGE) then return false end
		if rng.percent(3) then
			t.action(self, t, 0)
			return true
		end
	end,
	info = function(self, t)
		local duration = 5
		local tBrutality = self:getTalentFromId(self.T_BRUTALITY)
		if tBrutality then
			duration = tBrutality.getDuration(self, tBrutality)
		end
		local hateLoss = t.getHateLoss(self, t)
		local critical = t.getCritical(self, t)
		return ([[You enter into a terrible rampage for %d turns, destroying everything in your path. There is also a small chance when you are hit that you will rampage.
		%0.2f hate loss per turn. +%d%% (at 0 Hate) to %d%% (at 10+ Hate) critical chance.]]):format(duration, hateLoss, critical * 0.3, critical * 1.0)
	end,
}

newTalent{
	name = "Brutality",
	type = {"cursed/rampage", 2},
	mode = "passive",
	require = cursed_str_req2,
	points = 5,
	on_learn = function(self, t)
	end,
	on_unlearn = function(self, t)
	end,
	getDuration = function(self, t) return 4 + math.floor(1 * self:getTalentLevel(t)) end,
	getDamage = function(self, t) return 10 * self:getTalentLevel(t) end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		return ([[Add brutality to your rampage.
		Rampage lasts %d turns. +%d%% (at 0 Hate) to %d%% (at 10+ Hate) damage.]]):format(duration, damage * 0.1, damage * 1.0)
	end,
}

newTalent{
	name = "Reflexes",
	type = {"cursed/rampage", 3},
	require = cursed_str_req3,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
	end,
	on_unlearn = function(self, t)
	end,
	getCooldown = function(self, t) return 150 - math.floor(10 * self:getTalentLevelRaw(t)) end,
	getSpeed = function(self, t) return 10 * self:getTalentLevel(t) end,
	info = function(self, t)
		local cooldown = t.getCooldown(self, t)
		local speed = t.getSpeed(self, t)
		return ([[Add reflexes to your rampage.
		Rampage cooldown is %d turns. +%d%% (at 0 Hate) to %d%% (at 10+ Hate) speed.]]):format(cooldown, speed * 0.1, speed * 1.0)
	end,
}

newTalent{
	name = "Instincts",
	type = {"cursed/rampage", 4},
	mode = "passive",
	require = cursed_str_req4,
	points = 5,
	on_learn = function(self, t)
	end,
	on_unlearn = function(self, t)
	end,
	getAttack = function(self, t) return 20 + 10 * self:getTalentLevel(t) end,
	getEvasion = function(self, t) return 6 * self:getTalentLevel(t) end,
	info = function(self, t)
		local attack = t.getAttack(self, t)
		local evasion = t.getEvasion(self, t)
		return ([[Add instincts to your rampage.
		+%d%% (at 0 Hate) to %d%% (at 10+ Hate) attack. +%d%% (at 0 Hate) to %d%% (at 10+ Hate) evasion.]]):format(attack * 0.1, attack * 1.0, evasion * 0.1, evasion * 1.0)
	end,
}
