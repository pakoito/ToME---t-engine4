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
	name = "Telekinetic Grasp",
	type = {"psionic/other", 1},
	points = 1,
	cooldown = 0,
	psi = 0,
	type_no_req = true,
	no_unlearn_last = true,
	no_npc_use = true,
	action = function(self, t)
		local inven = self:getInven("INVEN")
		local d d = self:showInventory("Telekinetically grasp which item?", inven, function(o)
			return (o.type == "weapon" or o.type == "gem") and o.subtype ~= "sling"
		end, function(o, item)
			local pf = self:getInven("PSIONIC_FOCUS")
			if not pf then return end
			-- Put back the old one in inventory
			local old = self:removeObject(pf, 1, true)
			if old then
				self:addObject(inven, old)
			end
--Note: error with set items -- set_list, on_set_broken, on_set_complete
			-- Fix the slot_forbid bug
			if o.slot_forbid then
				-- Store any original on_takeoff function
				if o.on_takeoff then
					o._old_on_takeoff = o.on_takeoff
				end
				-- Save the original slot_forbid
				o._slot_forbid = o.slot_forbid
				o.slot_forbid = nil
				-- And prepare the resoration of everything
				o.on_takeoff = function(self)
					-- Remove the slot forbid fix
					self.slot_forbid = self._slot_forbid
					self._slot_forbid = nil
					-- Run the original on_takeoff
					if self._old_on_takeoff then
						self.on_takeoff = self._old_on_takeoff
						self._old_on_takeoff = nil
						self:on_takeoff()
					-- Or remove on_takeoff entirely
					else
						self.on_takeoff = nil
					end
				end
			end

			o = self:removeObject(inven, item)
			-- Force "wield"
			self:addObject(pf, o)
			game.logSeen(self, "%s wears: %s.", self.name:capitalize(), o:getName{do_color=true})

			self:sortInven()
			d.used_talent = true
		end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		return ([[Encase a weapon or gem in mentally-controlled forces, holding it aloft and bringing it to bear with the power of your mind alone.]])
	end,
}

newTalent{
	name = "Beyond the Flesh",
	type = {"psionic/other", 1},
	points = 1,
	mode = "sustained",
	cooldown = 0,
	sustain_psi = 0,
	range = 1,
	direct_hit = true,
	no_energy = true,
	no_unlearn_last = true,
	tactical = { BUFF = 3 },
	do_tkautoattack = function(self, t)
		if game.zone.wilderness then return end
		local tkweapon = self:getInven("PSIONIC_FOCUS")[1]
		if type(tkweapon) == "boolean" then tkweapon = nil end
		if not tkweapon or tkweapon.type ~= "weapon" or tkweapon.subtype == "mindstar" then return end


		local targnum = 1
		if self:hasEffect(self.EFF_PSIFRENZY) then targnum = self:hasEffect(self.EFF_PSIFRENZY).power end
		local speed, hit = nil, false
		local sound, sound_miss = nil, nil
		--dam = self:getTalentLevel(t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, targnum, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly pick a target
		local tg = {type="hit", range=1, talent=t}
		for i = 1, targnum do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			if self:getInven(self.INVEN_PSIONIC_FOCUS) then
				for i, o in ipairs(self:getInven(self.INVEN_PSIONIC_FOCUS)) do
					if o.combat and not o.archery then
						print("[PSI ATTACK] attacking with", o.name)
						self:attr("use_psi_combat", 1)
						local s, h = self:attackTargetWith(a, o.combat, nil, 1)
						self:attr("use_psi_combat", -1)
						speed = math.max(speed or 0, s)
						hit = hit or h
						if hit and not sound then sound = o.combat.sound
						elseif not hit and not sound_miss then sound_miss = o.combat.sound_miss end
						if not o.combat.no_stealth_break then break_stealth = true end
						self:breakStepUp()
					end
				end
			else
				return nil
			end

		end
		return hit
	end,
	callbackOnWear = function(self, t, p)
		if self.__to_recompute_beyond_the_flesh then return end
		self.__to_recompute_beyond_the_flesh = true
		game:onTickEnd(function()
			self.__to_recompute_beyond_the_flesh = nil
			local p = self.sustain_talents[t.id]
			self:forceUseTalent(t.id, {ignore_energy=true, ignore_cd=true, no_talent_fail=true})
			if t.on_pre_use(self, t) then self:forceUseTalent(t.id, {ignore_energy=true, ignore_cd=true, no_talent_fail=true, talent_reuse=true}) end
		end)
	end,
	callbackOnTakeoff = function(self, t, p)
		if self.__to_recompute_beyond_the_flesh then return end
		self.__to_recompute_beyond_the_flesh = true
		game:onTickEnd(function()
			self.__to_recompute_beyond_the_flesh = nil
			local p = self.sustain_talents[t.id]
			self:forceUseTalent(t.id, {ignore_energy=true, ignore_cd=true, no_talent_fail=true})
			if t.on_pre_use(self, t) then self:forceUseTalent(t.id, {ignore_energy=true, ignore_cd=true, no_talent_fail=true, talent_reuse=true}) end
		end)
	end,
	callbackOnActBase = function(self, t, p)
		local p = self.sustain_talents[t.id]
		
		if self:hasEffect(self.EFF_PSIFRENZY) then
			if p.mindstar_grab then
				self:project({type="ball", radius=p.mindstar_grab.range}, self.x, self.y, function(px, py)
					local a = game.level.map(px, py, Map.ACTOR)
					if a and self:reactionToward(a) < 0 then
						local dist = core.fov.distance(self.x, self.y, px, py)
						if dist > 1 and rng.percent(p.mindstar_grab.chance) then 
							local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
							if tx and ty and a:canBe("knockback") then
								a:move(tx, ty, true)
							end
						end
					end
				end)
			elseif self:getInven("PSIONIC_FOCUS")[1] and self:getInven("PSIONIC_FOCUS")[1].type == "gem" then
				local list = {}
				local gem = self:getInven("PSIONIC_FOCUS")[1]
				self:project({type="ball", radius=6}, self.x, self.y, function(px, py)
					local a = game.level.map(px, py, Map.ACTOR)
					if a and self:reactionToward(a) < 0 then
						local dist = core.fov.distance(self.x, self.y, px, py)
						list[#list+1] = {dist=dist, a=a}
					end
				end)
				if #list <= 0 then return end
				
				local elem = {
					black = {DamageType.ACID, "acid"},
					blue = {DamageType.LIGHTNING, "lightning_explosion"},
					green = {DamageType.NATURE, "slime"},
					red = {DamageType.FIRE, "flame"},
					violet = {DamageType.ARCANE, "manathrust"},
					white = {DamageType.COLD, "freeze"},
					yellow = {DamageType.LIGHT, "light"},
				}
				local bolt = elem[gem.subtype]
				
				table.sort(list, "dist")
				local a = list[1].a
				self:project({type="ball", range=6, radius=0, selffire=false, talent=t}, a.x, a.y, bolt[1], self:hasEffect(self.EFF_PSIFRENZY).damage, {type=bolt[2]})
				
			end
			return
		end
		
		if not p.mindstar_grab then return end
		if not rng.percent(p.mindstar_grab.chance) then return end

		local list = {}
		self:project({type="ball", radius=p.mindstar_grab.range}, self.x, self.y, function(px, py)
			local a = game.level.map(px, py, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				local dist = core.fov.distance(self.x, self.y, px, py)
				if dist > 1 then list[#list+1] = {dist=dist, a=a} end
			end
		end)
		if #list <= 0 then return end
		
		table.sort(list, "dist")
		local a = list[#list].a
		local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if tx and ty and a:canBe("knockback") then
			a:move(tx, ty, true)
			game.logSeen(a, "%s telekinetically grabs %s!", self.name:capitalize(), a.name)
		end
	end,
	on_pre_use = function (self, t)
		if not self:getInven("PSIONIC_FOCUS") then return false end
		local tkweapon = self:getInven("PSIONIC_FOCUS")[1]
		if type(tkweapon) == "boolean" then tkweapon = nil end
		if not tkweapon or (tkweapon.type ~= "weapon" and tkweapon.type ~= "gem") then
			return false
		end
		return true
	end,
	activate = function (self, t)
		local tk = self:getInven("PSIONIC_FOCUS")[1]
		if not tk then return false end

		local ret = {}
		if tk.type == "gem" then
			local power = (tk.material_level or 1) * 4 + math.ceil(self:callTalent(self.T_RESONANT_FOCUS, "bonus") / 5)
			self:talentTemporaryValue(ret, "inc_stats", {
				[self.STAT_STR] = power,
				[self.STAT_DEX] = power,
				[self.STAT_MAG] = power,
				[self.STAT_WIL] = power,
				[self.STAT_CUN] = power,
				[self.STAT_CON] = power,
			})
		elseif tk.subtype == "mindstar" then
			ret.mindstar_grab = {
				chance = (tk.material_level or 1) * 5 + 5 + self:callTalent(self.T_RESONANT_FOCUS, "bonus"),
				range = 2 + (tk.material_level or 1),
			}
		else
			self:talentTemporaryValue(ret, "use_psi_combat", 1)
		end
		return ret
	end,
	deactivate =  function (self, t)
		return true
	end,
	info = function(self, t)
		local base = [[Allows you to wield a physical melee weapon, a mindstar or a gem telekinetically, gaining a special effect for each.
		A gem will provide +4 bonus to all primary stats per tier of the gem.
		A mindstar will randomly try to telekinetically grab a far away foe (5% chance and range 2 for a tier 1 mindstar, +1 range and +5% chance for each tier above 1) and pull it into melee range.
		A physical melee weapon will act as a semi independant entity, attacking foes nearby each turn while also replacing Strength and Dexterity with Willpower and Cunning for accuracy and damage calculations (for all melee weapons).

		]]

		local o = self:getInven("PSIONIC_FOCUS") and self:getInven("PSIONIC_FOCUS")[1]
		if type(o) == "boolean" then o = nil end
		if not o then return base end

		local atk = 0
		local dam = 0
		local apr = 0
		local crit = 0
		local speed = 1
		if o.type == "gem" then
			local ml = o.material_level or 1
			base = base..([[The telekinetically-wielded gem grants you +%d stats.]]):format(ml * 4)
		elseif o.subtype == "mindstar" then
			local ml = o.material_level or 1			
			base = base..([[The telekinetically-wielded mindstar has a %d%% chance to grab a foe up to %d range away.]]):format((ml + 1) * 5, ml + 2)
		else
			self:attr("use_psi_combat", 1)
			atk = self:combatAttack(o.combat)
			dam = self:combatDamage(o.combat)
			apr = self:combatAPR(o.combat)
			crit = self:combatCrit(o.combat)
			speed = self:combatSpeed(o.combat)
			self:attr("use_psi_combat", -1)
			base = base..([[The telekinetically-wielded weapon uses Willpower in place of Strength, and Cunning in place of Dexterity, to determine Accuracy and damage.
			Combat stats:
			Accuracy: %d
			Damage: %d
			APR: %d
			Crit: %0.2f
			Speed: %0.2f]]):
			format(atk, dam, apr, crit, speed)
		end
		return base
	end,

}
