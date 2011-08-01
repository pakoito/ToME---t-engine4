-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	name = "Blurred Mortality",
	type = {"spell/necrosis",1},
	require = spells_req1,
	mode = "sustained",
	points = 5,
	sustain_mana = 30,
	cooldown = 30,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		local ret = {
			die_at = self:addTemporaryValue("die_at", -50 * self:getTalentLevelRaw(t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("die_at", p.die_at)
		return true
	end,
	info = function(self, t)
		return ([[The line between life and death blurs for you, you can only die when you reach %d life.
		However when bellow 0 you can not see how much life you have left.]]):
		format(50 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Impending Doom",
	type = {"spell/necrosis",2},
	require = spells_req2,
	points = 5,
	random_ego = "attack",
	mana = 30,
	cooldown = 18,
	tactical = { ATTACK = 1, DISABLE = 3 },
	range = 0,
	radius = function(self, t)
		return 3 + self:getTalentLevelRaw(t)
	end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 120) end,
	getStunDuration = function(self, t) return self:getTalentLevelRaw(t) + 2 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FLAMESHOCK, {dur=t.getStunDuration(self, t), dam=self:spellCrit(t.getDamage(self, t))})

		if self:attr("burning_wake") then
			local l = line.new(self.x, self.y, x, y)
			local lx, ly = l()
			local dir = lx and coord_to_dir[lx - self.x][ly - self.y] or 6

			game.level.map:addEffect(self,
				self.x, self.y, 4,
				DamageType.INFERNO, self:attr("burning_wake"),
				tg.radius,
				{angle=math.deg(math.atan2(y - self.y, x - self.x))}, 55,
				{type="inferno"},
				nil, self:spellFriendlyFire()
			)
		end
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local stunduration = t.getStunDuration(self, t)
		return ([[Conjures up a cone of flame. Any target caught in the area will take %0.2f fire damage and be paralyzed for %d turns.
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.FIRE, damage), stunduration)
	end,
}

newTalent{
	name = "Reanimation",
	type = {"spell/necrosis",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 40,
	cooldown = 8,
	tactical = { ATTACKAREA = 2 },
	range = 7,
	radius = function(self, t)
		return 1 + self:getTalentLevelRaw(t)
	end,
	proj_speed = 4,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t, display={particle="bolt_fire", trail="firetrail"}}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 280) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.FIRE, self:spellCrit(t.getDamage(self, t)), function(self, tg, x, y, grids)
			game.level.map:particleEmitter(x, y, tg.radius, "fireflash", {radius=tg.radius, tx=x, ty=y})
			if self:attr("burning_wake") then
				game.level.map:addEffect(self,
					x, y, 4,
					engine.DamageType.INFERNO, self:attr("burning_wake"),
					tg.radius,
					5, nil,
					{type="inferno"},
					nil, tg.selffire
				)
			end
		end)
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Conjures up a bolt of fire moving toward the target that explodes into a flash of fire doing %0.2f fire damage in a radius of %d.
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.FIRE, damage), radius)
	end,
}

newTalent{
	name = "Lichform",
	type = {"spell/necrosis",4},
	require = spells_req4,
	mode = "sustained",
	points = 5,
	sustain_mana = 150,
	cooldown = 30,
	no_npc_use = true,
	becomeLich = function(self, t)
		self.descriptor.race = "Undead"
		self.descriptor.subrace = "Lich"
		self.moddable_tile = "skeleton"
		self.moddable_tile_nude = true
		self.moddable_tile_base = "base_lich_01.png"
		self.moddable_tile_ornament = nil
		self.blood_color = colors.GREY
		self:attr("poison_immune", 1)
		self:attr("disease_immune", 0.5)
		self:attr("stun_immune", 0.5)
		self:attr("cut_immune", 1)
		self:attr("fear_immune", 1)
		self:attr("no_breath", 1)
		self:attr("undead", 1)
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 20
		self.resists[DamageType.DARKNESS] = (self.resists[DamageType.DARKNESS] or 0) + 20
		self.inscription_restrictions = self.inscription_restrictions or {}
		self.inscription_restrictions["inscriptions/runes"] = true
		self.inscription_restrictions["inscriptions/taints"] = true

		local level = self:getTalentLevel(t)
		if level < 2 then
			self:incIncStat("mag", -3) self:incIncStat("wil", -3)
			self.resists.all = (self.resists.all or 0) - 10
		elseif level < 3 then
			-- nothing
		elseif level < 4 then
			self:incIncStat("mag", 3) self:incIncStat("wil", 3)
			self.life_rating = self.life_rating + 1
		elseif level < 5 then
			self:incIncStat("mag", 3) self:incIncStat("wil", 3)
			self:attr("combat_spellresist", 10) self:attr("combat_mentalresist", 10)
			self.life_rating = self.life_rating + 2
		elseif level < 6 then
			self:incIncStat("mag", 5) self:incIncStat("wil", 5)
			self:attr("combat_spellresist", 10) self:attr("combat_mentalresist", 10)
			self.resists_cap.all = (self.resists_cap.all or 0) + 10
			self.life_rating = self.life_rating + 2
		else
			self:incIncStat("mag", 6) self:incIncStat("wil", 6) self:incIncStat("cun", 6)
			self:attr("combat_spellresist", 15) self:attr("combat_mentalresist", 15)
			self.resists_cap.all = (self.resists_cap.all or 0) + 15
			self.life_rating = self.life_rating + 3
		end

		require("engine.ui.Dialog"):simplePopup("Lichform", "#GREY#You feel your life slip away, only to be replaced by pure arcane forces! Your flesh starts to rot on your bones, your eyes fall apart as you are reborn into a Lich!")
	end,
	on_pre_use = function(self, t)
		if self:attr("undead") then return false else return true end
	end,
	activate = function(self, t)
		local ret = {
			mana = self:addTemporaryValue("mana_regen", -4),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("mana_regen", p.mana)
		return true
	end,
	info = function(self, t)
		return ([[Your true goal. The purpose of all necromancy, to become a powerful and everliving Lich!
		If you are killed while this spell is active the arcane forces you unleash will be able to rebuild you body into Lichform.
		All liches gain the following intrinsic:
		- Poison, cuts, fear immunity
		- Disease resistance 50%%
		- Stun resistance 50%%
		- Cold and darkness resistance 20%%
		- No need to breathe
		- Infusions do not work
		Also:
		At level 1: -3 to all stats, -10%% to all resistances. Such meagre devotion!
		At level 2: Nothing
		At level 3: +3 Magic and Willpower, +1 life rating (not retroactive)
		At level 4: +3 Magic and Willpower, +2 life rating (not retroactive), +10 spell and mental saves
		At level 5: +5 Magic and Willpower, +2 life rating (not retroactive), +10 spell and mental saves, all resistances cap raised by 10%%
		At level 6: +6 Magic, Willpower and Cunning, +3 life rating (not retroactive), +15 spell and mental saves, all resistances cap raised by 15%%. Fear my power!
		While active it will drain 4 mana per turns.]]):
		format()
	end,
}
