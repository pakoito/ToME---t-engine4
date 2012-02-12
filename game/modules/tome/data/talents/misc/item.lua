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
	name = "Command Staff",
	type = {"misc/item", 1},
	cooldown = function(self, t)
		--return math.max(30 - 5 * self:getTalentLevel(t), 5)
		return 5
	end,
	points = 5,
	--hard_cap = 5,
	no_npc_use = true,
	--[=[
	en_fct = function(self, t)
		if self:getTalentLevel(t) > 5 then 
			print("instant?")
			return "instant"
		else
			print("not instant?")
			return "1 turn"
		end
	end,
]=]
	action = function(self, t)
		local staff = self:hasStaffWeapon()
		if not staff then
			game.logPlayer(self, "You must be holding a staff.")
			return
		end
		local state = {}
		local Chat = require("engine.Chat")
		local chat = Chat.new("command-staff", {name="Command Staff"}, self, {version=staff, state=state, co=coroutine.running()})
		local d = chat:invoke()
		if not coroutine.yield() then return nil end
		return true		
	end,
	info = function(self, t)
		--return ([[Alter the flow of energies through a staff. The effect is instantaneous at extremely high talent levels.]])
		return ([[Alter the flow of energies through a staff.]])
	end,
}

newTalent{
	name = "Reload",
	type = {"misc/item", 1},
	cooldown = 0,
	points = 5,
	hard_cap = 5,
	tactical = { AMMO = 2 },
	on_pre_use = function(self, t, silent) if not self:hasAmmo() then if not silent then game.logPlayer(self, "You must have a quiver or pouch equipped.") end return false end return true end,
	shots_per_turn = function(self, t)
		local s =  self:getTalentFromId(self.T_BOW_MASTERY)
		local add = s.getReloadBoost(self, s)
		return self:getTalentLevelRaw(t) + add
	end,
	action = function(self, t)
		local q, err = self:hasAmmo()
		if not q then 
			game.logPlayer(self, "%s", err) 
			return
		end
		if q.combat.shots_left == q.combat.capacity then
			game.logPlayer(self, "Your %s is full.", q.name)
			return
		end
		self:setEffect(self.EFF_RELOADING, q.combat.capacity, {ammo = q, shots_per_turn = t.shots_per_turn(self, t)})
		return true
	end,
	info = function(self, t)
		local spt = t.shots_per_turn(self, t)
		return ([[Reload your quiver or shot pouch at the rate of %d shot%s per turn.]]):format(spt, (spt > 1 and "s") or "")
	end,
}

newTalent{
	name = "Savagery",
	type = {"misc/item", 1},
	points = 5,
	hard_cap = 5,
	mode = "passive",
	getDuration = function(self, t)
		return 2 * self:getTalentLevel(t) + 3
	end,
	getPower = function(self, t)
		return 0.5
	end,
	do_savagery = function(self, t)
		self:setEffect(self.EFF_SAVAGERY, t.getDuration(self, t), {power = t.getPower(self, t)})
	end,
	info = function(self, t)
		return ([[Whenever you land a critical strike, you gain a stacking bonus of %d to your critical power multiplier, up to a maximum bonus of 1.5. The buff lasts for %d turns.]]):format(t.getPower(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Ward",
	type = {"misc/item", 1},
	cooldown = function(self, t)
		return 45 - 5 * self:getTalentLevel(t)
	end,
	points = 5,
	hard_cap = 5,
	no_npc_use = true,
	action = function(self, t)
		local state = {}
		local Chat = require("engine.Chat")
		local chat = Chat.new("ward", {name="Ward"}, self, {version=self, state=state})
		local d = chat:invoke()
		local co = coroutine.running()
		--print("before d.unload, state.set_ward is ", state.set_ward)
		d.unload = function() coroutine.resume(co, state.set_ward) end
		--print("state.set_ward is ", state.set_ward)
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		return ([[Bring a damage-type-specific ward into being. The ward will fully negate as many attacks of its element as it has charges.]])
	end,
}


newTalent{
	name = "Bloodflow",
	type = {"misc/item", 1},
	cooldown = function(self, t)
		return 45 - 5 * self:getTalentLevel(t)
	end,
	points = 5,
	hard_cap = 5,
	no_npc_use = true,
	tactical = { BUFF = 2 },
	getTalentCount = function(self, t) return math.ceil(self:getTalentLevel(t) + 1) end,
	getMaxLevel = function(self, t) return self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local amount = self.life * 0.5
		if self.life <= amount + 1 then
			game.logPlayer(self, "Doing this would kill you.")
			return
		end
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[2] <= t.getMaxLevel(self, t) then
				tids[#tids+1] = tid
			end
		end
		for i = 1, t.getTalentCount(self, t) do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		self.changed = true
		game:playSoundNear(self, "talents/spell_generic")
		self:takeHit(amount, self)
		return true
	end,
	info = function(self, t)
		local talentcount = t.getTalentCount(self, t)
		local maxlevel = t.getMaxLevel(self, t)
		return ([[Sacrifice half of your current health to reset the cooldown of %d talents of tier %d or less.]]):
		format(talentcount, maxlevel)
	end,
}

newTalent{
	name = "Elemental Retribution",
	type = {"misc/item", 1},
	points = 5,
	hard_cap = 5,
	mode = "passive",
	tactical = { BUFF = 1 },
	getDuration = function(self, t)
		return 2 * self:getTalentLevel(t) + 3
	end,
	getPower = function(self, t)
		return self:getTalentLevel(t)*3
	end,
	getElementsString = function(self, t)
		if not self.elemental_retribution then return "(error 1)" end
		local ret_list = {}
		local count = 1
		for k, v in pairs(self.elemental_retribution) do
			if v > 0 then 
				ret_list[count] = k 
				count = count + 1
			end
		end
		local n = #ret_list
		--print("just defined n as: ", n)
		if n < 1 then return "(error 2)" end
		local e_string = ""
		if n == 1 then 
			e_string = DamageType.dam_def[ret_list[1]].name
			--print("1: e_string is ", e_string)
		elseif n == 2 then
			e_string = DamageType.dam_def[ret_list[1]].name.." or "..DamageType.dam_def[ret_list[2]].name
			--print("2: e_string is ", e_string)
		else
			for i = 1, #ret_list-1 do 
				e_string = e_string..DamageType.dam_def[ret_list[i]].name..", "
				--print("3+: e_string is ", e_string)
			end
			e_string = e_string.."or "..DamageType.dam_def[ret_list[n]].name
		end
		return e_string
	end,
	do_retribution = function(self, t)
		self:setEffect(self.EFF_ELEMENTAL_RETRIBUTION, t.getDuration(self, t), {power = t.getPower(self, t), e_string = t.getElementsString(self, t), maximum = t.getPower(self, t)*3})
	end,
	info = function(self, t)
		return ([[Whenever you suffer %s damage, you gain a stacking bonus of %d to spellpower up to a maximum of %d. The buff lasts for %d turns.]]):format(t.getElementsString(self, t), t.getPower(self, t), t.getPower(self, t)*3, t.getDuration(self, t))
	end,
}

newTalent{
	name = "Soul Drain",
	type = {"misc/item", 1},
	points = 5,
	hard_cap = 5,
	cooldown = function(self, t)
		return math.max(6, math.ceil(25 - self:getTalentLevelRaw(t)*3))
	end,
	tactical = { DEFEND = 2, ATTACKAREA = 2, DISABLE = 1 },
	direct_hit = true,
	range = 0,
	radius = function(self, t)
		return 2 + math.ceil(self:getTalentLevel(t)/2)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getLeech = function(self, t)
		--return self:combatStatTalentIntervalDamage(t, "combatMindpower", 6, 30)
		return 3
	end,
	getDam = function(self, t)
		return self:spellCrit(self:combatTalentSpellDamage(t, 28, 270))
	end,
	action = function(self, t)
		local leech = t.getLeech(self, t)
		local dam = t.getDam(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				self:incMana(leech)
				self:incVim(leech * 0.5)
				self:incPositive(leech * 0.25)
				self:incNegative(leech * 0.25)
				self:incEquilibrium(-leech * 0.35)
				self:incStamina(leech * 0.65)
				self:incHate(leech * 0.05)
				self:incPsi(leech * 0.2)
			end
			DamageType:get(DamageType.SOUL_DRAIN).projector(self, tx, ty, DamageType.SOUL_DRAIN, dam)
		end)
		-- Lightning ball gets a special treatment to make it look neat
		local sradius = (tg.radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
		local nb_forks = 16
		local angle_diff = 360 / nb_forks
		for i = 0, nb_forks - 1 do
			local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
			local tx = self.x + math.floor(math.cos(a) * tg.radius)
			local ty = self.y + math.floor(math.sin(a) * tg.radius)
			game.level.map:particleEmitter(x, y, tg.radius, "lightning", {radius=tg.radius, grids=grids, tx=tx-self.x, ty=ty-self.y, nb_particles=25, life=8})
		end

		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRadius(t)
		local en = t.getLeech(self, t)
		local dam = damDesc(self, DamageType.BLIGHT, t.getDam(self, t))
		return ([[You tear at the very soul of every target around you in a radius of %d. Deals %d blight damage. Reduces the mana, vim, positive enerty, negative energy, stamina, hate, and psi of each target by 50%%. Increases their equilibrium by 50%%. Provides a small boost to all of your resources.]]):format(range, dam)
	end,
}

newTalent{
	name = "Fearscape Fog",
	type = {"misc/item", 1},
	points = 5,
	cooldown = 20,
	tactical = {
		ATTACK = 10,
	},
	range = 0,
	radius = function(self, t)
		return 2 + self:getTalentLevelRaw(t)
	end,
	direct_hit = true,
	tactical = { DISABLE = 3 },
	--requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		--local x, y = self:getTarget(tg)
		--if not x or not y then return nil end
		self:project(tg, self.x, self.y, function(px, py)
			local g = engine.Entity.new{name="darkness", show_tooltip=true, block_sight=true, always_remember=false, unlit=self:getTalentLevel(t) * 10}
			game.level.map(px, py, Map.TERRAIN+1, g)
			game.level.map.remembers(px, py, false)
			game.level.map.lites(px, py, false)
		end, nil, {type="dark"})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[Call forth the dread mists of the Fearscape, blocking all but the most powerful light in a radius of %d.]]):format(self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Perception",
	type = {"misc/item", 1},
	points = 5,
	tactical = { BUFF = 2 },
	cooldown = 30,
	getSeeInvisible = function(self, t) return self:combatTalentSpellDamage(t, 10, 45) end,
	getSeeStealth = function(self, t) return self:combatTalentSpellDamage(t, 10, 20) end,
	getCriticalPower = function(self, t) return 0.3 + self:getTalentLevel(t) * 0.1 end,
	action = function(self, t)
		self:setEffect(self.EFF_PERCEPTION, 5, {si=t.getSeeInvisible(self, t), ss=t.getSeeStealth(self, t), crit=t.getCriticalPower(self, t)})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local seeinvisible = t.getSeeInvisible(self, t)
		local seestealth = t.getSeeStealth(self, t)
		local criticalpower = t.getCriticalPower(self, t)
		return ([[You sharpen your senses to supernatural acuity.
		See invisible: +%d
		See through stealth: +%d
		Critical power: +%.1f
		The effects will improve with your Spellpower.]]):
		format(seeinvisible, seestealth, criticalpower)
	end,
}

newTalent{
	name = "Lifebind",
	type = {"misc/item", 1},
	points = 5,
	cooldown = 50,
	tactical = { ATTACK = 2 },
	range = function(self, t)
		return self:getTalentLevel(t)
	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return  end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		game:playSoundNear(self, "talents/arcane")
		
		-- Try to insta-kill
		if target then
			if target:checkHit(self:combatSpellpower(), target:combatPhysicalResist(), 0, self:getMaxAccuracy("spell"), 15) and target:canBe("instakill") and target.life > 0 then
				local t_percent = target.life / target.max_life
				local s_percent = self.life / self.max_life
				target.life = target.max_life * s_percent
				self.life = self.max_life * t_percent
				game.level.map:particleEmitter(x, y, 1, "entropythrust")
				game.level.map:particleEmitter(self.x, self.y, 1, "entropythrust")
			else
				game.logSeen(target, "%s resists the lifebind!", target.name:capitalize())
			end
		end
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Attempts to swap your life force for that of the target. If the swap is successful, your health percentage will be set at the target's health percentage, and vice versa. Enemies that are immune to instakill effects will resist this. The range increases with talent level.]])
	end,
}

newTalent{
	name = "Block",
	type = {"misc/item", 1},
	cooldown = function(self, t)
		return 8 - self:getTalentLevelRaw(t)
	end,
	points = 5,
	hard_cap = 5,
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	getProperties = function(self, t)
		local shield = self:hasShield()
		--if not shield then return nil end
		local p = {
			sp = (shield and shield.special_combat and shield.special_combat.spellplated or false),
			ref = (shield and shield.special_combat and shield.special_combat.reflective or false),
			br = (shield and shield.special_combat and shield.special_combat.bloodruned or false),
		}
		return p
	end,
	getBlockValue = function(self, t)
		local shield = self:hasShield()
		if not shield then return 0 end
		return (shield.special_combat and shield.special_combat.block) or 0
	end,
	getBlockedTypes = function(self, t)
		local shield = self:hasShield()
		local bt = {DamageType.PHYSICAL}
		if not shield then return bt, "error!" end
		local count = 2
		if shield.wielder.resists then 
			for res, v in pairs(shield.wielder.resists) do
				if v > 0 then 
					bt[count] = res
					count = count + 1
				end
			end
		end
		if shield.wielder.on_melee_hit then 
			for res, v in pairs(shield.wielder.on_melee_hit) do
				if v > 0 then
					local add = true
					for i = 1, #bt do
						if bt[i] == res then add = false end 
					end
					if add then 
						bt[count] = res
						count = count + 1
					end
				end
			end
		end
		local n = #bt
		if n < 1 then return "(error 2)" end
		local e_string = ""
		if n == 1 then 
			e_string = DamageType.dam_def[bt[1]].name
		elseif n == 2 then
			e_string = DamageType.dam_def[bt[1]].name.." and "..DamageType.dam_def[bt[2]].name
		else
			for i = 1, #bt-1 do 
				e_string = e_string..DamageType.dam_def[bt[i]].name..", "
			end
			e_string = e_string.."and "..DamageType.dam_def[bt[n]].name
		end
		return bt, e_string
	end,
	action = function(self, t)
		local properties = t.getProperties(self, t)
		local bt, bt_string = t.getBlockedTypes(self, t)
		self:setEffect(self.EFF_BLOCKING, 1, {power = t.getBlockValue(self, t), d_types=bt, properties=properties})
		return true
	end,
	info = function(self, t)
		local properties = t.getProperties(self, t)
		local sp_text = ""
		local ref_text = ""
		local br_text = ""
		if properties.sp then
			sp_text = (" Increases your spell save by %d for that turn."):format(t.getBlockValue(self, t))
		end
		if properties.ref then
			ref_text = " Reflects all blocked damage back to the source."
		end
		if properties.br then
			br_text = " All blocked damage heals the wielder."
		end
		local bt, bt_string = t.getBlockedTypes(self, t)
		return ([[Raise your shield into blocking position for one turn, reducing the damage of all %s attacks by %d. If you block all of an attack's damage, the attacker will be vulnerable to a deadly counterstrike for one turn.%s%s%s]]):format(bt_string, t.getBlockValue(self, t), sp_text, ref_text, br_text)
	end,
}
