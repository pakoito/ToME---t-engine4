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
	name = "Draconic Body",
	mode = "passive",
	cooldown = 40,
	require = { special={desc="Be close to the draconic world", fct=function(self) return game.state.birth.ignore_prodigies_special_reqs or (self:attr("drake_touched") and self:attr("drake_touched") >= 2) end} },
	trigger = function(self, t, value)
		if self.life - value < self.max_life * 0.3 and not self:isTalentCoolingDown(t) then
			self:heal(self.max_life * 0.4)
			self:startTalentCooldown(t)
			game.logSeen(self,"%s's draconic body hardens and heals!",self.name) --I5 
		end
	end,
	info = function(self, t)
		return ([[Your body hardens and recovers quickly. When pushed below 30%% life, you are healed for 40%% of your total life.]])
		:format()
	end,
}

uberTalent{
	name = "Bloodspring",
	mode = "passive",
	cooldown = 12,
	require = { special={desc="Have let Melinda be sacrificed", fct=function(self) return game.state.birth.ignore_prodigies_special_reqs or (self:hasQuest("kryl-feijan-escape") and self:hasQuest("kryl-feijan-escape"):isStatus(engine.Quest.FAILED)) end} },
	trigger = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, 4,
			DamageType.WAVE, {dam={dam=100 + self:getCon() * 3, healfactor=0.5}, x=self.x, y=self.y, st=DamageType.DRAINLIFE, power=50 + self:getCon() * 2},
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
		return ([[When a single blow deals more than 20%% of your total life, a torrent of blood gushes from your body, creating a bloody tidal wave for 4 turns that deals %0.2f blight damage, heals you for 50%% of the damage done, and knocks foes back.
		The damage increases with your Constitution.]])
		:format(100 + self:getCon() * 3)
	end,
}

uberTalent{
	name = "Eternal Guard",
	mode = "passive",
	require = { special={desc="Know the Block talent", fct=function(self) return self:knowTalent(self.T_BLOCK) end} },
	info = function(self, t)
		return ([[Your block now lasts 1 more turn, and does not end when hit.]])
		:format()
	end,
}

uberTalent{
	name = "Never Stop Running",
	mode = "sustained",
	cooldown = 20,
	sustain_stamina = 10,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	require = { special={desc="Know at least 20 levels of stamina-using talents", fct=function(self) return knowRessource(self, "stamina", 20) end} },
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "move_stamina_instead_of_energy", 20)
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[While this talent is active, you dig deep into your stamina reserves, allowing you to move without taking a turn but costing 20 stamina for each tile you cross.]])
		:format()
	end,
}

uberTalent{
	name = "Armour of Shadows",
	mode = "passive",
	require = { special={desc="Have dealt over 50000 darkness damage", fct=function(self) return
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
		return ([[You know how to protect yourself with the deepest shadows. As long as you stand on an unlit tile, you gain 30 Armour and 50%% Armour hardiness.
		Any time you deal darkness damage, you will unlight both the target terrain and your tile.]])
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
		return ([[Your back is as hard as stone. Each time you are affected by a physical effect, your body hardens, making you immune to all other physical effects for 5 turns.]])
		:format()
	end,
}

uberTalent{
	name = "Fungal Blood",
	require = { special={desc="Be able to use infusions", fct=function(self) return not self.inscription_restrictions or self.inscription_restrictions['inscriptions/infusions'] end} },
	tactical = { HEAL = function(self) return not self:hasEffect(self.EFF_FUNGAL_BLOOD) and 0 or math.ceil(self:hasEffect(self.EFF_FUNGAL_BLOOD).power / 150) end },
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_FUNGAL_BLOOD) and self:hasEffect(self.EFF_FUNGAL_BLOOD).power > 0 and not self:attr("undead") end,
	trigger = function(self, t)
		if self.inscription_restrictions and not self.inscription_restrictions['inscriptions/infusions'] then return end
		self:setEffect(self.EFF_FUNGAL_BLOOD, 6, {power=self:getCon() * 2})
	end,
	no_energy = true,
	action = function(self, t)
		local eff = self:hasEffect(self.EFF_FUNGAL_BLOOD)
		self:attr("allow_on_heal", 1)
		self:heal(math.min(eff.power, self:getCon() * self.max_life / 100))
		self:attr("allow_on_heal", -1)
		self:removeEffect(self.EFF_FUNGAL_BLOOD)
		return true
	end,
	info = function(self, t)
		return ([[Fungal spores have colonized your blood, so that each time you use an infusion you store %d fungal power.
		You may use this prodigy to release the power as a heal (never more than than %d life).
		Fungal power lasts for up to 6 turns, losing 10 potency each turn.
		The amount of fungal power produced, and the maximum heal possible, increase with your Constitution.]])
		:format(self:getCon() * 2, self:getCon() * self.max_life / 100)
	end,
}

uberTalent{
	name = "Corrupted Shell",
	mode = "passive",
	require = { special={desc="Have received at least 7500 blight damage and destroyed Zigur with the Grand Corruptor.", fct=function(self) return
		(self.damage_intake_log and self.damage_intake_log[DamageType.BLIGHT] and self.damage_intake_log[DamageType.BLIGHT] >= 7500) and
		(game.state.birth.ignore_prodigies_special_reqs or (
			self:hasQuest("anti-antimagic") and 
			self:hasQuest("anti-antimagic"):isStatus(engine.Quest.DONE) and
			not self:hasQuest("anti-antimagic"):isStatus(engine.Quest.COMPLETED, "grand-corruptor-treason")
		))
	end} },
	on_learn = function(self, t)
		self.max_life = self.max_life + 150
	end,
	info = function(self, t)
		return ([[Thanks to your newfound knowledge of corruption, you've learned some tricks for toughening your body... but only if you are healthy enough to withstand the strain from the changes.
		Improves your life by 150, your Defense by %d, and your saves by %d, as your natural toughness and reflexes are pushed beyond their normal limits.
		Your saves and Defense will improve with your Constitution.]])
		:format(self:getCon() / 3, self:getCon() / 3)
	end,
}
