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

-- Thought Forms
newTalent{
	name = "Thought-Form: Bowman",
	short_name = "TF_BOWMAN",
	type = {"psionic/other", 1},
	points = 5, 
	require = psi_wil_req1,
	sustain_psi = 20,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 24,
	range = function(self, t)
		local t = self:getTalentFromId(self.T_OVER_MIND)
		return 10 + t.getRangeBonus(self, t)
	end,
	getStatBonus = function(self, t) 
		local t = self:getTalentFromId(self.T_THOUGHT_FORMS)
		return t.getStatBonus(self, t)
	end,
	activate = function(self, t)
		cancelThoughtForms(self)
		
		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end
		
		-- Do our stat bonuses here so we only roll for crit once	
		local stat_bonus = math.floor(self:mindCrit(t.getStatBonus(self, t)))
	
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			name = "thought-forged bowman", summoner = self,
			shader = "shadow_simulacrum",
			shader_args = { color = {0.8, 0.8, 0.8}, base = 0.8, time_factor = 4000 },
			desc = [[A thought-forged bowman.  It appears ready for battle.]],
			body = { INVEN = 10, MAINHAND = 1, BODY = 1, QUIVER=1, HANDS = 1, FEET = 1},
			-- Make a moddable tile
			resolvers.generic(function(e)
				if e.summoner.female then
					e.female = true
				end
				e.image = e.summoner.image
				e.moddable_tile = e.summoner.moddable_tile and e.summoner.moddable_tile or nil
				e.moddable_tile_base = e.summoner.moddable_tile_base and e.summoner.moddable_tile_base or nil
				e.moddable_tile_ornament = e.summoner.moddable_tile_ornament and e.summoner.moddable_tile_ornament or nil
				if e.summoner.image == "invis.png" and e.summoner.add_mos then
					local summoner_image, summoner_h, summoner_y = e.summoner.add_mos[1].image or nil, e.summoner.add_mos[1].display_h or nil, e.summoner.add_mos[1].display_y or nil
					if summoner_image and summoner_h and summoner_y then
						e.add_mos = {{image=summoner_image, display_h=summoner_h, display_y=summoner_y}}
					end
				end
			end),
			-- Disable our sustain when we die
			on_die = function(self)
				game:onTickEnd(function() 
					if self.summoner:isTalentActive(self.summoner.T_TF_BOWMAN) then
						self.summoner:forceUseTalent(self.summoner.T_TF_BOWMAN, {ignore_energy=true})
					end
					if self.summoner:isTalentActive(self.summoner.T_OVER_MIND) then
						self.summoner:forceUseTalent(self.summoner.T_OVER_MIND, {ignore_energy=true})
					end
				end)
				-- Pass our summoner back as the target if we're controlled...  to prevent super cheese.
				if game.player == self then
					local tg = {type="ball", radius=10}
					self:project(tg, self.x, self.y, function(tx, ty)
						local target = game.level.map(tx, ty, Map.ACTOR)
						if target and target.ai_target.actor == self then
							target:setTarget(self.summoner)
						end
					end)
				end
			end,
			-- Keep them on a leash
			on_act = function(self)
				local t = self.summoner:getTalentFromId(self.summoner.T_TF_BOWMAN)
				if not game.level:hasEntity(self.summoner) or self.summoner.dead or not self.summoner:isTalentActive(self.summoner.T_TF_BOWMAN) then
					self:die(self)
				end
				if game.level:hasEntity(self.summoner) and core.fov.distance(self.x, self.y, self.summoner.x, self.summoner.y) > self.summoner:getTalentRange(t) then
					local Map = require "engine.Map"
					local x, y = util.findFreeGrid(self.summoner.x, self.summoner.y, 5, true, {[Map.ACTOR]=true})
					if not x then
						return
					end
					-- Clear it's targeting on teleport
					self:setTarget(nil)
					self:move(x, y, true)
					game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=225, rM=255, gm=225, gM=255, bm=225, bM=255, am=35, aM=90})
				end
			end,
			-- Hack to make sure we top off ammo after every battle
			on_move = function(self)
				if game.player ~= self then
					local a = self:hasAmmo()
					if not a then print("[Thought-Form Bowman Ammo] - ERROR, NO AMMO") end
					if a and a.combat.shots_left < a.combat.capacity and not self.ai_target.actor and not self:hasEffect(self.EFF_RELOADING) then
						self:forceUseTalent(self.T_RELOAD, {})
					end
				end
			end,

			ai = "summoned", ai_real = "tactical",
			ai_state = { ai_move="move_dmap", talent_in=3, ally_compassion=10 },
			ai_tactic = resolvers.tactic("ranged"),
			
			max_life = resolvers.rngavg(100,110),
			life_rating = 12,
			combat_armor = 0, combat_def = 0,
			stats = { mag=self:getMag(), wil=self:getWil(), cun=self:getCun()},
			inc_stats = {
				str = stat_bonus / 2,
				dex = stat_bonus,
				con = stat_bonus / 2,
			},
			
			resolvers.talents{ 
				[Talents.T_WEAPON_COMBAT]= math.ceil(self.level/10),
				[Talents.T_BOW_MASTERY]= math.ceil(self.level/10),
				
				[Talents.T_CRIPPLING_SHOT]= math.ceil(self.level/10),
				[Talents.T_STEADY_SHOT]= math.ceil(self.level/10),
				[Talents.T_RAPID_SHOT]= math.ceil(self.level/10),
				
				[Talents.T_PSYCHOMETRY]= math.floor(self:getTalentLevel(self.T_TRANSCENDENT_THOUGHT_FORMS)),
				[Talents.T_BIOFEEDBACK]= math.floor(self:getTalentLevel(self.T_TRANSCENDENT_THOUGHT_FORMS)),
				[Talents.T_LUCID_DREAMER]= math.floor(self:getTalentLevel(self.T_TRANSCENDENT_THOUGHT_FORMS)),
			},
			resolvers.equip{
				{type="weapon", subtype="longbow", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
				{type="ammo", subtype="arrow", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
				{type="armor", subtype="light", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
				{type="armor", subtype="hands", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
				{type="armor", subtype="feet", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
			},
			resolvers.sustains_at_birth(),
		}

		setupThoughtForm(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		
		local ret = {
			summon = m
		}
		if self:knowTalent(self.T_TF_UNITY) then
			local t = self:getTalentFromId(self.T_TF_UNITY)
			ret.speed = self:addTemporaryValue("combat_mindspeed", t.getSpeedPower(self, t)/100)
		end
		return ret
	end,
	deactivate = function(self, t, p)
		if p.summon and p.summon.summoner == self then
			p.summon:die(p.summon)
		end
		if p.speed then self:removeTemporaryValue("combat_mindspeed", p.speed) end
		return true
	end,
	info = function(self, t)
		local stat = t.getStatBonus(self, t)
		return ([[Forge a bowman clad in leather armor from your thoughts.  The bowman learns bow mastery, combat accuracy, steady shot, crippling shot, and rapid shot as it levels up and has %d improved strength, %d dexterity, and %d constitution.
		The stat bonuses will improve with your mindpower.]]):format(stat/2, stat, stat/2)
	end,
}

newTalent{
	name = "Thought-Form: Warrior",
	short_name = "TF_WARRIOR",
	type = {"psionic/other", 1},
	points = 5, 
	require = psi_wil_req1,
	sustain_psi = 20,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 24,
	range = function(self, t)
		local t = self:getTalentFromId(self.T_OVER_MIND)
		return 10 + t.getRangeBonus(self, t)
	end,
	getStatBonus = function(self, t) 
		local t = self:getTalentFromId(self.T_THOUGHT_FORMS)
		return t.getStatBonus(self, t)
	end,
	activate = function(self, t)
		cancelThoughtForms(self)
		
		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end
		
		-- Do our stat bonuses here so we only roll for crit once		
		local stat_bonus = math.floor(self:mindCrit(t.getStatBonus(self, t)))
	
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			name = "thought-forged warrior", summoner = self, 
			shader = "shadow_simulacrum",
			shader_args = { color = {0.8, 0.8, 0.8}, base = 0.8, time_factor = 4000 },
			desc = [[A thought-forged warrior wielding a massive hammer and clad in heavy armor.  It appears ready for battle.]],
			body = { INVEN = 10, MAINHAND = 1, BODY = 1, HANDS = 1, FEET = 1},
			-- Make a moddable tile
			resolvers.generic(function(e)
				if e.summoner.female then
					e.female = true
				end
				e.image = e.summoner.image
				e.moddable_tile = e.summoner.moddable_tile and e.summoner.moddable_tile or nil
				e.moddable_tile_base = e.summoner.moddable_tile_base and e.summoner.moddable_tile_base or nil
				e.moddable_tile_ornament = e.summoner.moddable_tile_ornament and e.summoner.moddable_tile_ornament or nil
				if e.summoner.image == "invis.png" and e.summoner.add_mos then
					local summoner_image, summoner_h, summoner_y = e.summoner.add_mos[1].image or nil, e.summoner.add_mos[1].display_h or nil, e.summoner.add_mos[1].display_y or nil
					if summoner_image and summoner_h and summoner_y then
						e.add_mos = {{image=summoner_image, display_h=summoner_h, display_y=summoner_y}}
					end
				end
			end),
			-- Disable our sustain when we die
			on_die = function(self)
				game:onTickEnd(function() 
					if self.summoner:isTalentActive(self.summoner.T_TF_WARRIOR) then
						self.summoner:forceUseTalent(self.summoner.T_TF_WARRIOR, {ignore_energy=true})
					end
					if self.summoner:isTalentActive(self.summoner.T_OVER_MIND) then
						self.summoner:forceUseTalent(self.summoner.T_OVER_MIND, {ignore_energy=true})
					end
				end)
				-- Pass our summoner back as the target if we're controlled...  to prevent super cheese.
				if game.player == self then
					local tg = {type="ball", radius=10}
					self:project(tg, self.x, self.y, function(tx, ty)
						local target = game.level.map(tx, ty, Map.ACTOR)
						if target and target.ai_target.actor == self then
							target:setTarget(self.summoner)
						end
					end)
				end
			end,
			-- Keep them on a leash
			on_act = function(self)
				local t = self.summoner:getTalentFromId(self.summoner.T_TF_WARRIOR)
				if not game.level:hasEntity(self.summoner) or self.summoner.dead or not self.summoner:isTalentActive(self.summoner.T_TF_WARRIOR) then
					self:die(self)
				end
				if game.level:hasEntity(self.summoner) and core.fov.distance(self.x, self.y, self.summoner.x, self.summoner.y) > self.summoner:getTalentRange(t) then
					local Map = require "engine.Map"
					local x, y = util.findFreeGrid(self.summoner.x, self.summoner.y, 5, true, {[Map.ACTOR]=true})
					if not x then
						return
					end
					-- Clear it's targeting on teleport
					self:setTarget(nil)
					self:move(x, y, true)
					game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=225, rM=255, gm=225, gM=255, bm=225, bM=255, am=35, aM=90})
				end
			end,
			
			ai = "summoned", ai_real = "tactical",
			ai_state = { ai_move="move_dmap", talent_in=3, ally_compassion=10 },
			ai_tactic = resolvers.tactic("melee"),
			
			max_life = resolvers.rngavg(100,110),
			life_rating = 15,
			combat_armor = 0, combat_def = 0,
			stats = { mag=self:getMag(), wil=self:getWil(), cun=self:getCun()},
			inc_stats = {
				str = stat_bonus,
				dex = stat_bonus / 2,
				con = stat_bonus / 2,
			},
			
			resolvers.talents{ 
				[Talents.T_ARMOUR_TRAINING]= 3,
				[Talents.T_WEAPON_COMBAT]= math.ceil(self.level/10),
				[Talents.T_WEAPONS_MASTERY]= math.ceil(self.level/10),
				
				[Talents.T_RUSH]= math.ceil(self.level/10),
				[Talents.T_DEATH_DANCE]= math.ceil(self.level/10),
				[Talents.T_BERSERKER]= math.ceil(self.level/10),

				[Talents.T_PSYCHOMETRY]= math.floor(self:getTalentLevel(self.T_TRANSCENDENT_THOUGHT_FORMS)),
				[Talents.T_BIOFEEDBACK]= math.floor(self:getTalentLevel(self.T_TRANSCENDENT_THOUGHT_FORMS)),
				[Talents.T_LUCID_DREAMER]= math.floor(self:getTalentLevel(self.T_TRANSCENDENT_THOUGHT_FORMS)),
			},
			resolvers.equip{
				{type="weapon", subtype="battleaxe", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
				{type="armor", subtype="heavy", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
				{type="armor", subtype="hands", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
				{type="armor", subtype="feet", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
			},
			resolvers.sustains_at_birth(),
		}

		setupThoughtForm(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		
		local ret = {
			summon = m
		}
		if self:knowTalent(self.T_TF_UNITY) then
			local t = self:getTalentFromId(self.T_TF_UNITY)
			ret.power = self:addTemporaryValue("combat_mindpower", t.getOffensePower(self, t))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		if p.summon and p.summon.summoner == self then
			p.summon:die(p.summon)
		end
		if p.power then self:removeTemporaryValue("combat_mindpower", p.power) end
		return true
	end,
	info = function(self, t)
		local stat = t.getStatBonus(self, t)
		return ([[Forge a warrior wielding a battle-axe from your thoughts.  The warrior learns weapon mastery, combat accuracy, berserker, death dance, and rush as it levels up and has %d improved strength, %d dexterity, and %d constitution.
		The stat bonuses will improve with your mindpower.]]):format(stat, stat/2, stat/2)
	end,
}

newTalent{
	name = "Thought-Form: Defender",
	short_name = "TF_DEFENDER",
	type = {"psionic/other", 1},
	points = 5, 
	require = psi_wil_req1,
	sustain_psi = 20,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 24,
	range = function(self, t)
		local t = self:getTalentFromId(self.T_OVER_MIND)
		return 10 + t.getRangeBonus(self, t)
	end,
	getStatBonus = function(self, t) 
		local t = self:getTalentFromId(self.T_THOUGHT_FORMS)
		return t.getStatBonus(self, t)
	end,
	activate = function(self, t)
		cancelThoughtForms(self)
		
		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end
		
		-- Do our stat bonuses here so we only roll for crit once	
		local stat_bonus = math.floor(self:mindCrit(t.getStatBonus(self, t)))
	
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			name = "thought-forged defender", summoner = self,
			shader = "shadow_simulacrum",
			shader_args = { color = {0.8, 0.8, 0.8}, base = 0.8, time_factor = 4000 },
			desc = [[A thought-forged defender clad in massive armor.  It wields a sword and shield and appears ready for battle.]],
			body = { INVEN = 10, MAINHAND = 1, OFFHAND = 1, BODY = 1, HANDS = 1, FEET = 1},
			-- Make a moddable tile
			resolvers.generic(function(e)
				if e.summoner.female then
					e.female = true
				end
				e.image = e.summoner.image
				e.moddable_tile = e.summoner.moddable_tile and e.summoner.moddable_tile or nil
				e.moddable_tile_base = e.summoner.moddable_tile_base and e.summoner.moddable_tile_base or nil
				e.moddable_tile_ornament = e.summoner.moddable_tile_ornament and e.summoner.moddable_tile_ornament or nil
				if e.summoner.image == "invis.png" and e.summoner.add_mos then
					local summoner_image, summoner_h, summoner_y = e.summoner.add_mos[1].image or nil, e.summoner.add_mos[1].display_h or nil, e.summoner.add_mos[1].display_y or nil
					if summoner_image and summoner_h and summoner_y then
						e.add_mos = {{image=summoner_image, display_h=summoner_h, display_y=summoner_y}}
					end
				end
			end),
			-- Disable our sustain when we die
			on_die = function(self)
				game:onTickEnd(function() 
					if self.summoner:isTalentActive(self.summoner.T_TF_DEFENDER) then
						self.summoner:forceUseTalent(self.summoner.T_TF_DEFENDER, {ignore_energy=true})
					end
					if self.summoner:isTalentActive(self.summoner.T_OVER_MIND) then
						self.summoner:forceUseTalent(self.summoner.T_OVER_MIND, {ignore_energy=true})
					end
				end)
				-- Pass our summoner back as the target if we're controlled...  to prevent super cheese.
				if game.player == self then
					local tg = {type="ball", radius=10}
					self:project(tg, self.x, self.y, function(tx, ty)
						local target = game.level.map(tx, ty, Map.ACTOR)
						if target and target.ai_target.actor == self then
							target:setTarget(self.summoner)
						end
					end)
				end
			end,
			-- Keep them on a leash
			on_act = function(self)
				local t = self.summoner:getTalentFromId(self.summoner.T_TF_DEFENDER)
				if not game.level:hasEntity(self.summoner) or self.summoner.dead or not self.summoner:isTalentActive(self.summoner.T_TF_DEFENDER) then
					self:die(self)
				end
				if game.level:hasEntity(self.summoner) and core.fov.distance(self.x, self.y, self.summoner.x, self.summoner.y) > self.summoner:getTalentRange(t) then
					local Map = require "engine.Map"
					local x, y = util.findFreeGrid(self.summoner.x, self.summoner.y, 5, true, {[Map.ACTOR]=true})
					if not x then
						return
					end
					-- Clear it's targeting on teleport
					self:setTarget(nil)
					self:move(x, y, true)
					game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=225, rM=255, gm=225, gM=255, bm=225, bM=255, am=35, aM=90})
				end
			end,		
			
			ai = "summoned", ai_real = "tactical",
			ai_state = { ai_move="move_dmap", talent_in=3, ally_compassion=10 },
			ai_tactic = resolvers.tactic("tank"),
			
			max_life = resolvers.rngavg(100,110),
			life_rating = 15,
			combat_armor = 0, combat_def = 0,
			stats = { mag=self:getMag(), wil=self:getWil(), cun=self:getCun()},
			inc_stats = {
				str = stat_bonus / 2,
				dex = stat_bonus / 2,
				con = stat_bonus,
			},
			
			resolvers.talents{ 
				[Talents.T_ARMOUR_TRAINING]= 3 + math.ceil(self.level/10),
				[Talents.T_WEAPON_COMBAT]= math.ceil(self.level/10),
				[Talents.T_WEAPONS_MASTERY]= math.ceil(self.level/10),
				
				[Talents.T_SHIELD_PUMMEL]= math.ceil(self.level/10),
				[Talents.T_SHIELD_WALL]= math.ceil(self.level/10),
				

				[Talents.T_PSYCHOMETRY]= math.floor(self:getTalentLevel(self.T_TRANSCENDENT_THOUGHT_FORMS)),
				[Talents.T_BIOFEEDBACK]= math.floor(self:getTalentLevel(self.T_TRANSCENDENT_THOUGHT_FORMS)),
				[Talents.T_LUCID_DREAMER]= math.floor(self:getTalentLevel(self.T_TRANSCENDENT_THOUGHT_FORMS)),

			},
			resolvers.equip{
				{type="weapon", subtype="longsword", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
				{type="armor", subtype="shield", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
				{type="armor", subtype="massive", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
				{type="armor", subtype="hands", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
				{type="armor", subtype="feet", autoreq=true, forbid_power_source={arcane=true, technique=true}, not_properties = {"unique"} },
			},
			resolvers.sustains_at_birth(),
		}

		setupThoughtForm(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		
		local ret = {
			summon = m
		}
		if self:knowTalent(self.T_TF_UNITY) then
			local t = self:getTalentFromId(self.T_TF_UNITY)
			ret.resist = self:addTemporaryValue("resists", {all= t.getDefensePower(self, t)})
		end
		return ret
	end,
	deactivate = function(self, t, p)
		if p.summon and p.summon.summoner == self then
			p.summon:die(p.summon)
		end
		if p.resist then self:removeTemporaryValue("resists", p.resist) end
		return true
	end,
	info = function(self, t)
		local stat = t.getStatBonus(self, t)
		return ([[Forge a defender wielding a sword and shield from your thoughts.  The solider learns armor training, weapon mastery, combat accuracy, shield pummel, and shield wall as it levels up and has %d improved strength, %d dexterity, and %d constitution.
		The stat bonuses will improve with your mindpower.]]):format(stat/2, stat/2, stat)
	end,
}

newTalent{
	name = "Thought-Forms",
	short_name = "THOUGHT_FORMS",
	type = {"psionic/thought-forms", 1},
	points = 5, 
	require = psi_wil_req1,
	mode = "passive",
	range = function(self, t)
		local t = self:getTalentFromId(self.T_OVER_MIND)
		return 10 + t.getRangeBonus(self, t)
	end,
	getStatBonus = function(self, t) return self:combatTalentMindDamage(t, 5, 50) end,
	on_learn = function(self, t)
		if self:getTalentLevel(t) >= 1 and not self:knowTalent(self.T_TF_BOWMAN) then
			self:learnTalent(self.T_TF_BOWMAN, true)
		end
		if self:getTalentLevel(t) >= 3 and not self:knowTalent(self.T_TF_WARRIOR) then
			self:learnTalent(self.T_TF_WARRIOR, true)
		end
		if self:getTalentLevel(t) >= 5 and not self:knowTalent(self.T_TF_DEFENDER) then
			self:learnTalent(self.T_TF_DEFENDER, true)
		end
	end,	
	on_unlearn = function(self, t)
		if self:getTalentLevel(t) < 1 and self:knowTalent(self.T_TF_BOWMAN) then
			self:unlearnTalent(self.T_TF_BOWMAN)
		end
		if self:getTalentLevel(t) < 3 and self:knowTalent(self.T_TF_WARRIOR) then
			self:unlearnTalent(self.T_TF_WARRIOR)
		end
		if self:getTalentLevel(t) < 5 and self:knowTalent(self.T_TF_DEFENDER) then
			self:unlearnTalent(self.T_TF_DEFENDER)
		end
	end,
	info = function(self, t)
		local bonus = t.getStatBonus(self, t)
		local range = self:getTalentRange(t)
		return([[Forge a guardian from your thoughts alone.  Your guardian's primary stat will be improved by %d, it's two secondary stats by %d, and it will have magic, cunning, and willpower equal to your own.
		At talent level one you may forge a mighty bowman clad in leather armor, at level three a powerful warrior wielding a two-handed weapon, and at level five a strong defender using a sword and shield.
		Thought forms can only be maintained up to a range of %d and will rematerialize next to you if this range is exceeded.
		Only one thought-form may be active at a time and the stat bonuses will improve with your mindpower.]]):format(bonus, bonus/2, range)
	end,
}

newTalent{
	name = "Transcendent Thought-Forms",
	short_name = "TRANSCENDENT_THOUGHT_FORMS",
	type = {"psionic/thought-forms", 2},
	points = 5, 
	require = psi_wil_req2,
	mode = "passive",
	info = function(self, t)
		local level = self:getTalentLevel(t)
		return([[Your thought-forms now know Lucid Dreamer, Biofeedback, and Psychometry at talent level %d.]]):format(level)
	end,
}

newTalent{
	name = "Over Mind",
	type = {"psionic/thought-forms", 3},
	points = 5, 
	require = psi_wil_req3,
	sustain_psi = 50,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 24,
	no_npc_use = true,
	getControlBonus = function(self, t) return self:combatTalentMindDamage(t, 5, 50) end,
	getRangeBonus = function(self, t) return self:getTalentLevelRaw(t) end,
	on_pre_use = function(self, t, silent) if not game.party:findMember{type="thought-form"} then if not silent then game.logPlayer(self, "You must have an active Thought-Form to use this talent!") end return false end return true end,
	activate = function(self, t)
		-- Find our thought-form
		local target = game.party:findMember{type="thought-form"}
		
		-- Modify the control permission
		local old_control = game.party:hasMember(target).control
		game.party:hasMember(target).control = "full"
				
		-- Store life bonus and heal value
		local life_bonus = target.max_life * (t.getControlBonus(self, t)/100)
		
		-- Switch on TickEnd so every thing applies correctly
		game:onTickEnd(function() 
			game.level.map:particleEmitter(self.x, self.y, 1, "generic_discharge", {rm=225, rM=255, gm=225, gM=255, bm=225, bM=255, am=35, aM=90})
			game.party:hasMember(target).on_control = function(self)
				self.summoner.over_mind_ai = self.summoner.ai
				self.summoner.ai = "none"
				self:hotkeyAutoTalents()
			end
			game.party:hasMember(target).on_uncontrol = function(self)
				self.summoner.ai = self.summoner.over_mind_ai
				if self.summoner:isTalentActive(self.summoner.T_OVER_MIND) then
					self.summoner:forceUseTalent(self.summoner.T_OVER_MIND, {ignore_energy=true})
				end
				game.level.map:particleEmitter(self.x, self.y, 1, "generic_discharge", {rm=225, rM=255, gm=225, gM=255, bm=225, bM=255, am=35, aM=90})
				game.level.map:particleEmitter(self.summoner.x, self.summoner.y, 1, "generic_discharge", {rm=225, rM=255, gm=225, gM=255, bm=225, bM=255, am=35, aM=90})
			end
			game.level.map:particleEmitter(target.x, target.y, 1, "generic_discharge", {rm=225, rM=255, gm=225, gM=255, bm=225, bM=255, am=35, aM=90})
			game.party:setPlayer(target)
			self:resetCanSeeCache()
		end)
		
		game:playSoundNear(self, "talents/teleport")
			
		local ret = {
			target = target, old_control = old_control,
			life = target:addTemporaryValue("max_life", life_bonus),
			speed = target:addTemporaryValue("combat_physspeed", t.getControlBonus(self, t)/100),
			damage = target:addTemporaryValue("inc_damage", {all=t.getControlBonus(self, t)}),
			target:heal(life_bonus),
		}
		
		return ret
	end,
	deactivate = function(self, t, p)
		if p.target then
			p.target:removeTemporaryValue("max_life", p.life)
			p.target:removeTemporaryValue("inc_damage", p.damage)
			p.target:removeTemporaryValue("combat_physspeed", p.speed)
		
			if game.party:hasMember(p.target) then
				game.party:hasMember(p.target).control = old_control
			end
		end
		return true
	end,
	info = function(self, t)
		local bonus = t.getControlBonus(self, t)
		local range = t.getRangeBonus(self, t)
		return ([[Take direct control of your active thought-form, improving it's damage, attack speed, and maximum life by %d%% but leaving your body a defenseless shell.
		Also increases the range at which you can maintain your thought forms (rather this talent is active or not) by %d.
		The life, damage, and speed bonus will improve with your mindpower.]]):format(bonus, range)
	end,
}

newTalent{
	name = "Thought-Form Unity",
	short_name = "TF_UNITY",
	type = {"psionic/thought-forms", 4},
	points = 5, 
	require = psi_wil_req4,
	mode = "passive",
	getSpeedPower = function(self, t) return self:combatTalentMindDamage(t, 5, 15) end,
	getOffensePower = function(self, t) return self:combatTalentMindDamage(t, 10, 30) end,
	getDefensePower = function(self, t) return self:combatTalentMindDamage(t, 5, 15) end,
	info = function(self, t)
		local offense = t.getOffensePower(self, t)
		local defense = t.getDefensePower(self, t)
		local speed = t.getSpeedPower(self, t)
		return([[You now gain a %d%% bonus to mind speed while Thought-Form: Bowman is active, a %d bonus to mind power while Thought-Form: Warrior is active, and a %d%% bonus to resist all while Thought-Form: Defender is active. 
		At talent level one any Feedback your Thought-Forms gain will be given to you as well, at level three your Thought-Forms gain a bonus to all saves equal to your mental save, and at level five they gain a bonus to all damage equal to your bonus mind damage.
		These bonuses scale with your mindpower.]]):format(speed, offense, defense, speed)
	end,
}