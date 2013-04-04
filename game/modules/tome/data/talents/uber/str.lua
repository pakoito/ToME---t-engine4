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

uberTalent{
	name = "Flexible Combat",
	mode = "passive",
	on_learn = function(self, t)
		self:attr("unharmed_attack_on_hit", 1)
		self:attr("show_gloves_combat", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("unharmed_attack_on_hit", -1)
		self:attr("show_gloves_combat", -1)
	end,
	info = function(self, t)
		return ([[Each time you make a melee attack, you have a 60%% chance to do an additional unarmed strike.]])
		:format()
	end,
}

uberTalent{
	name = "You Shall Be My Weapon!", short_name="TITAN_S_SMASH", image = "talents/titan_s_smash.png",
	mode = "activated",
	require = { special={desc="Be of at least size category 'big' (also required to use it)", fct=function(self) return self.size_category and self.size_category >= 4 end} },
	requires_target = true,
	tactical = { ATTACK = 4 },
	on_pre_use = function(self, t) return self.size_category and self.size_category >= 4 end,
	cooldown = 12,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local hit = self:attackTarget(target, nil, 3.5 + 0.8 * (self.size_category - 4), true)

		if target:attr("dead") or not hit then return true end

		local dx, dy = (target.x - self.x), (target.y - self.y)
		local dir = util.coordToDir(dx, dy, 0)
		local sides = util.dirSides(dir, 0)

		target:knockback(self.x, self.y, 5, function(t2)
			local d = rng.chance(2) and sides.hard_left or sides.hard_right
			local sx, sy = util.coordAddDir(t2.x, t2.y, d)
			local ox, oy = t2.x, t2.y
			t2:knockback(sx, sy, 2, function(t3) return true end)
			if t2:canBe("stun") then t2:setEffect(t2.EFF_STUNNED, 3, {}) end
		end)
		if target:canBe("stun") then target:setEffect(target.EFF_STUNNED, 3, {}) end
		return true
	end,
	info = function(self, t)
		return ([[You deal a massive blow to your foe, smashing it for 350%% weapon damage and knocking it back 6 tiles away.
		For each size category over 'big' you gain an additional +80%% weapon damage.
		All foes in its path will be knocked to the side and stunned for 3 turns.]])
		:format()
	end,
}

uberTalent{
	name = "Massive Blow",
	mode = "activated",
	require = { special={desc="Have dug at least 30 walls/trees/... and dealt over 50000 damage with a two-handed weapon", fct=function(self) return 
		self.dug_times and self.dug_times >= 30 and 
		self.damage_log and self.damage_log.weapon.twohanded and self.damage_log.weapon.twohanded >= 50000
	end} },
	requires_target = true,
	tactical = { ATTACK = 4 },
	cooldown = 12,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local destroyed = false
		target:knockback(self.x, self.y, 4, nil, function(g, x, y)
			if g:attr("dig") and not destroyed then
				DamageType:get(DamageType.DIG).projector(self, x, y, DamageType.DIG, 1)
				destroyed = true
			end
		end)

		self:attackTarget(target, nil, 1.5 + (destroyed and 3.5 or 0), true)
		return true
	end,
	info = function(self, t)
		return ([[You deal a massive blow to your foe, smashing it for 150%% weapon damage and knocking it back 4 tiles away.
		If the knockback makes it hit a wall, it will smash down the wall and deal an additional 350%% weapon damage.]])
		:format()
	end,
}

uberTalent{
	name = "Steamroller",
	mode = "passive",
	require = { special={desc="Know the Rush talent", fct=function(self) return self:knowTalent(self.T_RUSH) end} },
	info = function(self, t)
		return ([[When you rush, the creature you rush to is marked. If you kill it in the next two turns, your rush cooldown is reset.
		Each time this effect triggers, you gain a stacking +20%% damage buff, up to 100%%.]])
		:format()
	end,
}

uberTalent{
	name = "Irresistible Sun",
	cooldown = 25,
	requires_target = true,
	range = 5,
	tactical = { ATTACK = 4, CLOSEIN = 2 },
	require = { special={desc="Have dealt over 50000 light or fire damage", fct=function(self) return
		self.damage_log and (
			(self.damage_log[DamageType.FIRE] and self.damage_log[DamageType.FIRE] >= 50000) or
			(self.damage_log[DamageType.LIGHT] and self.damage_log[DamageType.LIGHT] >= 50000)
		)
	end} },
	action = function(self, t)
		self:setEffect(self.EFF_IRRESISTIBLE_SUN, 6, {dam=50 + self:getStr() * 1.7})
		return true
	end,
	info = function(self, t)
		local dam = (50 + self:getStr() * 1.7) / 3
		return ([[For 6 turns you gain the mass and power of a star, drawing all creatures within radius 5 toward you and dealing %0.2f fire, %0.2f light and %0.2f physical damage to all foes.
		Foes closer to you take up to 150%% more damage.
		Damage will increase with your Strength.]])
		:format(damDesc(self, DamageType.FIRE, dam), damDesc(self, DamageType.LIGHT, dam), damDesc(self, DamageType.PHYSICAL, dam))
	end,
}

uberTalent{
	name = "I Can Carry The World!", short_name = "NO_FATIGUE",
	mode = "passive",
	require = { special={desc="Be able to use massive armours", fct=function(self) return self:getTalentLevelRaw(self.T_ARMOUR_TRAINING) >= 3 end} },
	on_learn = function(self, t)
		self:attr("max_encumber", 500)
	end,
	info = function(self, t)
		return ([[You are strong; fatigue and physical exertion mean nothing to you.
		Fatigue is permanently set to 0 and carrying capacity increased by 500.]])
		:format()
	end,
}

uberTalent{
	name = "Legacy of the Naloren",
	mode = "passive",
	require = { special={desc="Have sided wih Slasul and killed Ukllmswwik", fct=function(self)
		if game.state.birth.ignore_prodigies_special_reqs then return true end
		local q = self:hasQuest("temple-of-creation")
		return q and not q:isCompleted("kill-slasul") and q:isCompleted("kill-drake")
	end} },
	on_learn = function(self, t)
		self:learnTalent(self.T_SPIT_POISON, true, 5, {no_unlearn=true})
		self:learnTalent(self.T_EXOTIC_WEAPONS_MASTERY, true, 5, {no_unlearn=true})
		self.__show_special_talents = self.__show_special_talents or {}
		self.__show_special_talents[self.T_EXOTIC_WEAPONS_MASTERY] = true
		self.can_breath = self.can_breath or {}
		self.can_breath.water = (self.can_breath.water or 0) + 1

		require("engine.ui.Dialog"):simplePopup("Legacy of the Naloren", "Slasul will be happy to know your faith in his cause. You should return to speak to him.")
	end,
	info = function(self, t)
		return ([[You have sided with Slasul and helped him vanquish Ukllmswwik. You are now able to breathe underwater with ease.
		You have also learnt to use tridents and other exotic weapons easily (gaining 5 levels of Exotic Weapon Mastery), and can Spit Poison as nagas do. In addition, should Slasul still live, he may have a further reward for you as thanks...]])
		:format()
	end,
}

uberTalent{
	name = "Superpower",
	mode = "passive",
	info = function(self, t)
		return ([[A strong body is key to a strong mind. And a strong mind is powerful enough to make a strong body.
		Grants a Mindpower bonus equal to 25%% of your Strength.
		Additionally, you treat all weapons as having an additional 30%% Willpower modifier.]])
		:format()
	end,
}
