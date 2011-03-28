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

local newInscription = function(t)
	-- Warning, up that if more than 5 inscriptions are ever allowed
	for i = 1, 6 do
		local tt = table.clone(t)
		tt.short_name = tt.name:upper():gsub("[ ]", "_").."_"..i
		tt.display_name = function(self, t)
			local data = self:getInscriptionData(t.short_name)
			if data.item_name then
				local n = tstring{t.name, " ["}
				n:merge(data.item_name)
				n:add("]")
				return n
			else
				return t.name
			end
		end
		tt.cooldown = function(self, t)
			local data = self:getInscriptionData(t.short_name)
			return data.cooldown
		end
		tt.old_info = tt.info
		tt.info = function(self, t)
			local ret = t.old_info(self, t)
			local data = self:getInscriptionData(t.short_name)
			if data.use_stat and data.use_stat_mod then
				ret = ret..("\nIts effects scale with your %s stat."):format(self.stats_def[data.use_stat].name)
			end
			return ret
		end
		newTalent(tt)
	end
end

-----------------------------------------------------------------------
-- Infusions
-----------------------------------------------------------------------
newInscription{
	name = "Infusion: Regeneration",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { HEAL = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_REGENERATION, data.dur, {power=(data.heal + data.inc_stat) / data.dur})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to heal yourself for %d life over %d turns.]]):format(data.heal + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[heal %d over %d turns]]):format(data.heal + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Infusion: Healing",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { HEAL = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:heal(data.heal + data.inc_stat)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to heal yourself for %d life.]]):format(data.heal + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[heal %d]]):format(data.heal + data.inc_stat)
	end,
}

newInscription{
	name = "Infusion: Wild",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = { DEFEND = 3 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)

		local target = self
		local effs = {}
		local known = false

		-- Go through all temporary effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if data.what[e.type] and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, 1 do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end
		if known then
			game.logSeen(self, "%s is cured!", self.name:capitalize())
		end
		self:setEffect(self.EFF_PAIN_SUPPRESSION, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concat(table.keys(data.what), ", ")
		return ([[Activate the infusion to cure yourself of %s effects and reduce all damage taken by %d%% for %d turns.]]):format(what, data.power+data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concat(table.keys(data.what), ", ")
		return ([[resist %d%%; cure %s]]):format(data.power + data.inc_stat, what)
	end,
}

newInscription{
	name = "Infusion: Movement",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = { DEFEND = 1 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_FREE_ACTION, data.dur, {power=1})
		game:onTickEnd(function() self:setEffect(self.EFF_WILD_SPEED, 1, {power=data.speed + data.inc_stat}) end)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to increase movement speed by %d%% for 1 game turn.
		Any actions other than movement will cancel the effect.
		Also prevent stuns, dazes and pinning effects for %d turns.
		Note: since you will be moving very fast, game turns will pass very slowly.]]):format(data.speed + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d%% speed; %d turns]]):format(data.speed + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Infusion: Sun",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = { BUFF = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:project({type="ball", range=0, selffire=true, radius=data.range + data.inc_stat}, self.x, self.y, engine.DamageType.LITE, 1)
		self:project({type="ball", range=0, selffire=true, radius=data.range + data.inc_stat}, self.x, self.y, engine.DamageType.BREAK_STEALTH, 1)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to brighten the area in a radius of %d. It also reveals any stealthy creatures.]]):format(data.range + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[radius %d]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Infusion: Heroism",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = { BUFF = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_STRENGTH, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to increase strength, dexterity and constitution by %d for %d turns.]]):format(data.power + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[+%d for %d turns]]):format(data.power + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Infusion: Mind Power",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = { BUFF = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_WILL, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to increase willpower, cunning and magic by %d for %d turns.]]):format(data.power + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[+%d for %d turns]]):format(data.power + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Infusion: Insidious Poison",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { ATTACK = 1, DISABLE=1 },
	requires_target = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime", trail="slimetrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.INSIDIOUS_POISON, {dam=data.power + data.inc_stat, dur=7, heal_factor=data.heal_factor}, {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to spit a bolt of poison doing %0.2f nature damage per turns for 7 turns and reducing the target's healing received by %d%%.]]):format(damDesc(self, DamageType.COLD, data.power + data.inc_stat) / 7, data.heal_factor)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d nature damage, %d%% healing reduction]]):format(damDesc(self, DamageType.NATURE, data.power + data.inc_stat) / 7, data.heal_factor)
	end,
}

newInscription{
	name = "Infusion: Wild Growth",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { ATTACKAREA = 2, DISABLE = 3 },
	range = 0,
	radius = 5,
	direct_hit = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 3, 20) end,
	action = function(self, t)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(tx, ty)
			DamageType:get(DamageType.ENTANGLE).projector(self, tx, ty, DamageType.ENTANGLE, dam)
		end)
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local damage = t.getDamage(self, t)
		return ([[Causes thick vines to spring from the ground and entangle all targets within %d squares for %d turns, pinning them in place and dealing %0.2f physical damage and %0.2f nature damage each turn.]]):
		format(self:getTalentRadius(t), data.dur, damDesc(self, DamageType.PHYSICAL, damage)/3, damDesc(self, DamageType.Nature, 2*damage)/3)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Rad %d for %d turns]]):format(self:getTalentRadius(t), data.dur)
	end,
}

-----------------------------------------------------------------------
-- Runes
-----------------------------------------------------------------------
newInscription{
	name = "Rune: Phase Door",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { ESCAPE = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(self.x, self.y, data.range + data.inc_stat)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to teleport randomly in a range of %d.]]):format(data.range + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[range %d]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Rune: Controlled Phase Door",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { CLOSEIN = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=data.range + data.inc_stat, radius=3, requires_knowledge=false}
		x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code does not restrict the target coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)

		-- Check LOS
		local rad = 3
		if not self:hasLOS(x, y) and rng.percent(35 + (game.level.map.attrs(self.x, self.y, "control_teleport_fizzle") or 0)) then
			game.logPlayer(self, "The targetted phase door fizzles and works randomly!")
			x, y = self.x, self.y
			rad = tg.range
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(x, y, rad)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to teleport in a range of %d.]]):format(data.range + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[range %d]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Rune: Teleportation",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { ESCAPE = 3 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(self.x, self.y, data.range + data.inc_stat, 15)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to teleport randomly in a range of %d with a minimum range of 15.]]):format(data.range + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[range %d]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Rune: Shielding",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t)
		return not self:hasEffect(self.EFF_DAMAGE_SHIELD)
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_DAMAGE_SHIELD, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to create a protective shield absorbing at most %d damage for %d turns.]]):format(data.power + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[absorb %d for %d turns]]):format(data.power + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Rune: Invisibility",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { DEFEND = 1, ESCAPE = 1 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_INVISIBILITY, data.dur, {power=data.power + data.inc_stat})
		self:usedInscription(t.short_name)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to become invisible (power %d) for %d turns.
		Charges remaining: %d]]):format(data.power + data.inc_stat, data.dur, data.nb_uses)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[power %d for %d turns; %d charges]]):format(data.power + data.inc_stat, data.dur, data.nb_uses)
	end,
}

newInscription{
	name = "Rune: Speed",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_SPEED, data.dur, {power=(data.power + data.inc_stat) / 100})
		self:usedInscription(t.short_name)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to increase your global speed by %d%% for %d turns.
		Charges remaining: %d]]):format(data.power + data.inc_stat, data.dur, data.nb_uses)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[speed %d%% for %d turns; %d charges]]):format(data.power + data.inc_stat, data.dur, data.nb_uses)
	end,
}

newInscription{
	name = "Rune: Vision",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	no_npc_use = true,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:magicMap(data.range, self.x, self.y, function(x, y)
			local g = game.level.map(x, y, Map.TERRAIN)
			if g and (g.always_remember or g:check("block_move")) then
				for i = -1, 1 do for j = -1, 1 do
					local g2 = game.level.map(x + i, y + j, Map.TERRAIN)
					if g2 and not g2:check("block_move") then return true end
				end end
			end
		end)
		self:setEffect(self.EFF_SEE_INVISIBLE, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to get a vision of the area surrounding you (%d radius) and to allow you to see invisible (power %d) for %d turns.]]):
		format(data.range, data.power + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[radius %d]]):format(data.range)
	end,
}

newInscription{
	name = "Rune: Heat Beam",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { ATTACK = 1 },
	requires_target = true,
	direct_hit = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIREBURN, {dur=5, initial=0, dam=data.power + data.inc_stat})
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to fire a beam of heat doing %0.2f fire damage over 5 turns.]]):format(damDesc(self, DamageType.FIRE, data.power + data.inc_stat))
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d fire damage]]):format(damDesc(self, DamageType.FIRE, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Frozen Spear",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { ATTACK = 1, DISABLE=1 },
	requires_target = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_ice", trail="icetrail"}}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.ICE, data.power + data.inc_stat, {type="freeze"})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to fire a bolt of ice doing %0.2f cold damage with a chance to freeze the target.]]):format(damDesc(self, DamageType.COLD, data.power + data.inc_stat))
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d cold damage]]):format(damDesc(self, DamageType.COLD, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Acid Wave",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { ATTACKAREA = 1 },
	requires_target = true,
	direct_hit = true,
	range = 0,
	radius = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return  {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		self:projectile(tg, self.x, self.y, DamageType.ACID, data.power + data.inc_stat)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_acid", {radius=tg.radius})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to fire a self-centered acid wave, doing %0.2f acid damage.]]):format(damDesc(self, DamageType.ACID, data.power + data.inc_stat))
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d acid damage]]):format(damDesc(self, DamageType.ACID, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Lightning",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { ATTACK = 1 },
	requires_target = true,
	direct_hit = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = data.power + data.inc_stat
		self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local dam = damDesc(self, DamageType.LIGHTNING, data.power + data.inc_stat)
		return ([[Activate the rune to fire a beam of lightning, doing %0.2f to %0.2f lightning damage.]]):format(dam / 3, dam)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d lightning damage]]):format(damDesc(self, DamageType.LIGHTNING, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Manasurge",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { MANA = 1 },
	on_pre_use = function(self, t)
		return self:knowTalent(self.T_MANA_POOL)
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:incMana((data.mana + data.inc_stat) / 20)
		if self.mana_regen > 0 then
			self:setEffect(self.EFF_MANASURGE, data.dur, {power=self.mana_regen * (data.mana + data.inc_stat) / 100})
		else
			if self.mana_regen < 0 then
				game.logPlayer(self, "Your negative mana regeneration rate is unaffected by the rune.")
			else
				game.logPlayer(self, "Your nonexistant mana regeneration rate is unaffected by the rune.")
			end
		end
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to unleash a manasurge upon yourself, increasing mana regeneration by %d%% over %d turns and instantly restoring %d mana.]]):format(data.mana + data.inc_stat, data.dur, (data.mana + data.inc_stat) / 20)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d%% regen over %d turns; %d instant mana]]):format(data.mana + data.inc_stat, data.dur, (data.mana + data.inc_stat) / 20)
	end,
}

-- This is mostly a copy of Time Skip .. uuuglly
newInscription{
	name = "Rune of the Rift",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { DISABLE = 2, ATTACK = 1 },
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return 150 + self:getWil() * 4 end,
	getDuration = function(self, t) return 4 end,
	action = function(self, t)
		-- Find the target and check hit
		local tg = {type="hit", self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		tx, ty = checkBackfire(self, tx, ty)
		if tx then
			target = game.level.map(tx, ty, engine.Map.ACTOR)
		end
		if target and not target.player then
			local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
			if not hit then
				game.logSeen(target, "%s resists!", target.name:capitalize())
				return true
			end
		else
			return
		end

		-- Keep the Actor from leveling on return
		target.forceLevelup = false
		-- Create an object to time the effect and store the creature
		-- First, clone the terrain that we are replacing
		local terrain = game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN)
		local temporal_instability = mod.class.Object.new{
			old_feat = game.level.map(target.x, target.y, engine.Map.TERRAIN),
			name = "temporal instability", type="temporal", subtype="anomaly",
			display = '&', color=colors.LIGHT_BLUE,
			temporary = t.getDuration(self, t),
			canAct = false,
			target = target,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map(self.target.x, self.target.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					local mx, my = util.findFreeGrid(self.target.x, self.target.y, 20, true, {[engine.Map.ACTOR]=true})
					game.zone:addEntity(game.level, self.target, "actor", mx, my)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
		-- Mixin the old terrain
		table.update(temporal_instability, terrain)
		-- Now update the display overlay
		local overlay = engine.Entity.new{
		--	image = "terrain/wormhole.png",
			display = '&', color=colors.LIGHT_BLUE, image="object/temporal_instability.png",
			display_on_seen = true,
			display_on_remember = true,
		}
		if not temporal_instability.add_displays then
			temporal_instability.add_displays = {overlay}
		else
			table.append(temporal_instability.add_displays, overlay)
		end

		self:project(tg, tx, ty, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(tx, ty, 1, "temporal_thrust")
		game:playSoundNear(self, "talents/arcane")
		-- Remove the target and place the temporal placeholder
		if not target.dead then
			if target ~= self then
				target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
			end
			game.logSeen(target, "%s has moved forward in time!", target.name:capitalize())
			game.level:removeEntity(target)
			game.level:addEntity(temporal_instability)
			game.level.map(target.x, target.y, engine.Map.TERRAIN, temporal_instability)
		else
			game.logSeen(target, "%s has been killed by the temporal energy!", target.name:capitalize())
		end

		self:incParadox(-120)

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Inflicts %0.2f temporal damage.  If your target survives it will be sent %d turns into the future.
		It will also lower your paradox by 120 (if you have any).]]):format(damDesc(self, DamageType.TEMPORAL, damage), duration)
	end,
	short_info = function(self, t)
		return ("%0.2f temporal damage, removed from time %d turns"):format(t.getDamage(self, t), t.getDuration(self, t))
	end,
}

-----------------------------------------------------------------------
-- Taints
-----------------------------------------------------------------------
newInscription{
	name = "Taint: Devourer",
	type = {"inscriptions/taints", 1},
	points = 1,
	is_spell = true,
	tactical = { ATTACK = 1, HEAL=1 },
	requires_target = true,
	direct_hit = true,
	no_energy = true,
	range = 5,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			local effs = {}

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" or e.type == "physical" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained spells
			for tid, act in pairs(target.sustain_talents) do
				if act then
					effs[#effs+1] = {"talent", tid}
				end
			end

			local nb = data.effects
			for i = 1, nb do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
				else
					target:forceUseTalent(eff[2], {ignore_energy=true})
				end
				self:heal(data.heal + data.inc_stat)
			end

			game.level.map:particleEmitter(px, py, 1, "shadow_zone")
		end)
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the taint on a foe, removing %d effects from it and healing you for %d per effects.]]):format(data.effects, data.heal + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d effects / %d heal]]):format(data.effects, data.heal + data.inc_stat)
	end,
}


newInscription{
	name = "Taint: Telepathy",
	type = {"inscriptions/taints", 1},
	points = 1,
	is_spell = true,
	range = 10,
	action = function(self, t)
		local rad = self:getTalentRange(t)
		self:setEffect(self.EFF_SENSE, 5, {
			range = rad,
			actor = 1,
		})
		self:setEffect(self.EFF_WEAKENED_MIND, 10, {power=20})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Strip the protective barriers from your mind for %d turns, allowing in the thoughts all creatures within %d squares but reducing mind save by %d for 10 turns.]]):format(data.dur, self:getTalentRange(t), 20)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Range %d telepathy for %d turns]]):format(self:getTalentRange(t), data.dur)
	end,
}
