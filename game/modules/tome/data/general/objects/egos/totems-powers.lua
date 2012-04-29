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
healing
cure illness
cure poisons
cure
]]

newEntity{
	name = " of healing", addon=true, instant_resolve=true,
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
