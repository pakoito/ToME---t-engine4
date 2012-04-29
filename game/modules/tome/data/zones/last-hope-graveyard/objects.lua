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

local Talents = require "engine.interface.ActorTalents"
local Stats = require "engine.interface.ActorStats"
local DamageType = require "engine.DamageType"

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_LORE",
	define_as = "CELIA_NOTE",
	name = "creased letter", lore="celia-letter",
	desc = [[A letter.]],
	rarity = false,
	encumberance = 0,
}

newEntity{ define_as = "CELIA_HEART",
	power_source = {arcane=true},
	unique = true,
	type = "misc", subtype="heart",
	unided_name = "bloody heart",
	name = "Celia's Still Beating Heart",
	level_range = {20, 35},
	rarity = false,
	display = "*", color=colors.RED,  image = "object/artifact/celias_heart.png",
	encumber = 2,
	not_in_stores = true,
	desc = [[The living heart of the necromancer Celia, carved out of her chest and preserved with magic.]],

	max_power = 75, power_regen = 1,
	use_sound = "talents/slime",
	use_power = { name = "extract a tiny part of Celia's soul", power = 75, use = function(self, who)
		local p = who:isTalentActive(who.T_NECROTIC_AURA)
		if not p then return end
		p.souls = util.bound(p.souls + 1, 0, p.souls_max)
		who.changed = true
		game.logPlayer(who, "You squeeze Celia's heart in your hand, absorbing part of her soul into your necrotic aura.")
		self.max_power = self.max_power + 5
		self.use_power.power = self.use_power.power + 5
		return {id=true, used=true}
	end },
}
