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

uberTalent{
	name = "Draconic Body",
	mode = "passive",
	cooldown = 40,
	require = { special={desc="Be close to the draconic world", fct=function(self) return self:attr("drake_touched") and self:attr("drake_touched") >= 2 end} },
	trigger = function(self, t, value)
		if self.life - value < self.max_life * 0.3 and not self:isTalentCoolingDown(t) then
			self:heal(self.max_life * 0.4)
			self:startTalentCooldown(t)
		end
	end,
	info = function(self, t)
		return ([[Your body hardens, when pushed below 30%% life you are healed for 40%% of your total life.]])
		:format()
	end,
}

uberTalent{
	name = "Bloodspring",
	mode = "passive",
	cooldown = 12,
	require = { special={desc="Let Melinda be sacrificed", fct=function(self) return game.state.birth.ignore_prodigies_special_reqs or (self:hasQuest("kryl-feijan-escape") and self:hasQuest("kryl-feijan-escape"):isStatus(engine.Quest.FAILED)) end} },
	trigger = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, 4,
			DamageType.WAVE, {dam=100 + self:getCon() * 3, x=self.x, y=self.y, st=DamageType.BLIGHT, power=50 + self:getCon() * 2},
			1,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=200, color_bg=60, color_bb=20},
			function(e)
				e.radius = e.radius + 0.5
				return true
			end,
			false
		)
		game:playSoundNear(self, "talents/tidalwave")
		self:startTalentCooldown(t)
	end,
	info = function(self, t)
		return ([[When a single blow deals more than 20%% of your total life blood gushes of your body, creating a bloody tidal wave for 4 turns that deals %0.2f blight damage and knocks back foes.
			Damage increases with the Constitution stat.]])
		:format(100 + self:getCon() * 3)
	end,
}

uberTalent{
	name = "Eternal Guard",
	mode = "passive",
	require = { special={desc="Know the Block talent", fct=function(self) return self:knowTalent(self.T_BLOCK) end} },
	info = function(self, t)
		return ([[Your block now lasts 2 more turns.]])
		:format()
	end,
}

uberTalent{
	name = "Never Stop Running",
	mode = "sustained",
	cooldown = 20,
	sustain_stamina = 10,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	require = { special={desc="Know at least 20 levels of stamina using talents", fct=function(self) return knowRessource(self, "stamina", 20) end} },
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "move_stamina_instead_of_energy", 20)
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[While this talent is active you dig deep into your stamina reserves, allowing you to move without taking a turn but drains 20 stamina each move.]])
		:format()
	end,
}

uberTalent{
	name = "Armour of Shadows",
	mode = "passive",
	require = { special={desc="Dealt over 50000 darkness damage", fct=function(self) return
		self.damage_log and (
			(self.damage_log[DamageType.DARKNESS] and self.damage_log[DamageType.DARKNESS] >= 50000)
		)
	end} },
	on_learn = function(self, t)
		self:attr("darkness_darkens", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("darkness_darkens", -1)
	end,
	info = function(self, t)
		return ([[You know how to meld in the shadows. As long as you stand on an unlit tile you gain 30 armour and 50%% armour hardiness.
		Also all darkness damage you deal will unlight the target terrain.]])
		:format()
	end,
}

uberTalent{
	name = "Spine of the World",
	mode = "passive",
	trigger = function(self, t)
		if self:hasEffect(self.EFF_SPINE_OF_THE_WORLD) then return end
		self:setEffect(self.EFF_SPINE_OF_THE_WORLD, 4, {})
	end,
	info = function(self, t)
		return ([[Your back is has hard as stone. Each time you are affected by a physical effect your body hardens, for 5 turns you will become immune to all physical effects.]])
		:format()
	end,
}

uberTalent{
	name = "Fungal Blood",
	require = { special={desc="Be able to use infusions.", fct=function(self) return not self.inscription_restrictions or self.inscription_restrictions['inscriptions/infusions'] end} },
	tactical = { HEAL = function(self) return not self:hasEffect(self.EFF_FUNGAL_BLOOD) and 0 or math.ceil(self:hasEffect(self.EFF_FUNGAL_BLOOD).power / 150) end },
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_FUNGAL_BLOOD) and self:hasEffect(self.EFF_FUNGAL_BLOOD).power > 0 and not self:attr("undead") end,
	trigger = function(self, t)
		if self.inscription_restrictions and not self.inscription_restrictions['inscriptions/infusions'] then return end
		self:setEffect(self.EFF_FUNGAL_BLOOD, 6, {power=self:getCon() * 1.5})
	end,
	action = function(self, t)
		local eff = self:hasEffect(self.EFF_FUNGAL_BLOOD)
		self:heal(math.min(eff.power, self:getCon() * self.max_life / 100))
		self:removeEffect(self.EFF_FUNGAL_BLOOD)
		return true
	end,
	info = function(self, t)
		return ([[Fungal spores colonize your blood, each time you use an infusion you store %d fungal power.
		When you use this prodigy the power is released as a heal (never higher than %d).
		Fungal power is stored for 6 turns and loses 10 potency each turn.
		Fungal power generated and max heal increases with Constitution.]])
		:format(self:getCon() * 1.5, self:getCon() * self.max_life / 100)
	end,
}
