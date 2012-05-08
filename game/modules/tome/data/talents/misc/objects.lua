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

newTalentType{ no_silence=true, is_spell=true, type="sher'tul/fortress", name = "fortress", description = "Yiilkgur abilities." }
newTalentType{ no_silence=true, is_spell=true, type="spell/objects", name = "object spells", description = "Spell abilities of the various objects of the world." }
newTalentType{ type="technique/objects", name = "object techniques", description = "Techniques of the various objects of the world." }

--local oldTalent = newTalent
--local newTalent = function(t) if type(t.hide) == "nil" then t.hide = true end return oldTalent(t) end

newTalent{
	name = "charms", short_name = "GLOBAL_CD",
	type = {"spell/objects",1},
	points = 1,
	cooldown = 1,
	no_npc_use = true,
	hide = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ""
	end,
}


newTalent{
	name = "Arcane Supremacy",
	type = {"spell/objects",1},
	points = 1,
	mana = 40,
	cooldown = 12,
	tactical = {
		BUFF = function(self, t, target)
			local nb = 0
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "detrimental" then
					nb = nb + 1
				end
			end
			return nb
		end,
		CURE = function(self, t, target)
			local nb = 0
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "detrimental" then
					nb = nb + 1
				end
			end
			return nb
		end
	},
	getRemoveCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	action = function(self, t)
		local effs = {}
		local power = 5

		-- Go through all spell effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.type == "magical" and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				self:removeEffect(eff[2])
				power = power + 5
			end
		end

		self:setEffect(self.EFF_ARCANE_SUPREMACY, 10, {power=power})

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local count = t.getRemoveCount(self, t)
		return ([[Removes up to %d detrimental magical effects and empowers you with arcane energy for ten turns, increasing spellpower and spell save by 5 plus 5 per effect removed.]]):
		format(count)
	end,
}

newTalent{
	name = "Command Staff",
	type = {"spell/objects", 1},
	cooldown = 5,
	points = 5,
	no_npc_use = true,
	no_unlearn_last = true,
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
		return ([[Alter the flow of energies through a staff.]])
	end,
}

newTalent{
	name = "Ward",
	type = {"spell/objects", 1},
	cooldown = function(self, t)
		return math.max(10, 28 - 3 * self:getTalentLevel(t))
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
	name = "Teleport to the ground", short_name = "YIILKGUR_BEAM_DOWN",
	type = {"sher'tul/fortress", 1},
	points = 1,
	no_npc_use = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Use Yiilkgur's teleporter to teleport to the ground.]])
	end,
}

newTalent{
	name = "Block",
	type = {"technique/objects", 1},
	cooldown = function(self, t)
		return 8 - util.bound(self:getTalentLevelRaw(t), 1, 5)
	end,
	points = 5,
	hard_cap = 5,
	range = 1,
	tactical = { ATTACK = 2, DEFEND = 2 },
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
		return ([[Raise your shield into blocking position for one turn, reducing the damage of all %s attacks by %d. If you block all of an attack's damage, the attacker will be vulnerable to a deadly counterstrike (a normal attack will instead deal 200%% damage) for one turn.%s%s%s]]):format(bt_string, t.getBlockValue(self, t), sp_text, ref_text, br_text)
	end,
}
