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

--[[
Totems
*healing
*cure illness
*cure poisons
*thorny skin
]]

newEntity{
	name = " of cure illness", addon=true, instant_resolve=true,
	keywords = {cureill=true},
	level_range = {15, 50},
	rarity = 8,

	charm_power_def = {add=1, max=5, floor=true},
	resolvers.charm("removes up to %d diseases from the target", 20, function(self, who)
		local tg = {default_target=who, type="hit", nowarning=true, range=6 + who:getWil(4), first_target="friend"}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local nb = self:getCharmPower()
		who:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			local effs = {}

			-- Go through all temporary effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.disease then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			for i = 1, nb do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
				end
			end
		end)
		game:playSoundNear(who, "talents/heal")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of cure poisons", addon=true, instant_resolve=true,
	keywords = {curepoison=true},
	level_range = {1, 50},
	rarity = 8,

	charm_power_def = {add=1, max=5, floor=true},
	resolvers.charm("removes up to %d poisons from the target", 20, function(self, who)
		local tg = {default_target=who, type="hit", nowarning=true, range=6 + who:getWil(4), first_target="friend"}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local nb = self:getCharmPower()
		who:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			local effs = {}

			-- Go through all temporary effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.poison then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			for i = 1, nb do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
				end
			end
		end)
		game:playSoundNear(who, "talents/heal")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of thorny skin", addon=true, instant_resolve=true,
	keywords = {thorny=true},
	level_range = {1, 50},
	rarity = 6,

	charm_power_def = {add=5, max=50, floor=true},
	resolvers.charm(function(self) return ("hardens the skin for 6 turns increasing armour by %d and armour hardiness by %d%%%%"):format(self:getCharmPower(), 20 + self.material_level * 10) end, 20, function(self, who)
		who:setEffect(who.EFF_THORNY_SKIN, 6, {ac=self:getCharmPower(), hard=20 + self.material_level * 10})
		game:playSoundNear(who, "talents/heal")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of healing", addon=true, instant_resolve=true,
	keywords = {heal=true},
	level_range = {25, 50},
	rarity = 20,

	charm_power_def = {add=50, max=250, floor=true},
	resolvers.charm("heals the target for %d", 35, function(self, who)
		local tg = {default_target=who, type="hit", nowarning=true, range=6 + who:getWil(4), first_target="friend"}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:getCharmPower()
		who:project(tg, x, y, engine.DamageType.HEAL, dam)
		game:playSoundNear(who, "talents/heal")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}
