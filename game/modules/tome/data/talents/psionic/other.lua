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

		local targnum = 1
		if self:hasEffect(self.EFF_PSIFRENZY) then targnum = 1 + math.ceil(0.2*self:getTalentLevel(self.T_FRENZIED_PSIFIGHTING)) end
		local speed, hit = nil, false
		local sound, sound_miss = nil, nil
		--dam = self:getTalentLevel(t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 1, true)
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
						self.use_psi_combat = true
						local s, h = self:attackTargetWith(a, o.combat, nil, 1)
						self.use_psi_combat = false
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
	on_pre_use = function (self, t)
		if not self:getInven("PSIONIC_FOCUS") then return false end
		local tkweapon = self:getInven("PSIONIC_FOCUS")[1]
		if type(tkweapon) == "boolean" then tkweapon = nil end
		if not tkweapon or tkweapon.type == "gem" or tkweapon.archery then
--			game.logPlayer(self, "You cannot do that without a telekinetically-wielded melee weapon.")
			return false
		end
		return true
	end,
	activate = function (self, t)
		return true
	end,
	deactivate =  function (self, t)
		return true
	end,
	info = function(self, t)
		local atk = 0
		local dam = 0
		local apr = 0
		local crit = 0
		local speed = 1
		local o = self:getInven("PSIONIC_FOCUS") and self:getInven("PSIONIC_FOCUS")[1]
		if type(o) == "boolean" then o = nil end
		if not o then
			return ([[Allows you to wield a weapon telekinetically, directing it with your willpower and cunning rather than crude flesh. When activated, the telekinetically-wielded weapon will attack a random melee-range target each turn.
			The telekinetically-wielded weapon uses Willpower in place of Strength and Cunning in place of Dexterity to determine attack and damage.
			You are not telekinetically wielding anything right now.]])
		end
		if o.type == "weapon" then
			self.use_psi_combat = true
			atk = self:combatAttack(o.combat)
			dam = self:combatDamage(o.combat)
			apr = self:combatAPR(o.combat)
			crit = self:combatCrit(o.combat)
			speed = self:combatSpeed(o.combat)
			self.use_psi_combat = false
		end
		return ([[Allows you to wield a weapon telekinetically, directing it with your willpower and cunning rather than crude flesh. When activated, the telekinetically-wielded weapon will attack a random melee-range target each turn.
		The telekinetically-wielded weapon uses Willpower in place of Strength and Cunning in place of Dexterity to determine attack and damage.
		Combat stats:
		Accuracy: %d
		Damage: %d
		APR: %d
		Crit: %0.2f
		Speed: %0.2f]]):
		format(atk, dam, apr, crit, speed)
	end,
}
