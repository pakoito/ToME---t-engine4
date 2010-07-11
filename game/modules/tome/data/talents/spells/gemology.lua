-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
	name = "Create Alchemist Gems",
	type = {"spell/gemology-base", 1},
	require = spells_req1,
	points = 1,
	range = function(self, t)
		return math.ceil(5 + self:getDex(12))
	end,
	mana = 30,
	make_gem = function(self, t, base_define)
		local nb = rng.range(40, 80)
		local gem = game.zone:makeEntityByName(game.level, "object", "ALCHEMIST_" .. base_define)

		local s = {}
		while nb > 0 do
			s[#s+1] = gem:clone()
			nb = nb - 1
		end
		for i = 1, #s do gem:stack(s[i]) end

		return gem
	end,
	action = function(self, t)
		self:showEquipInven("Use which gem?", function(o) return o.type == "gem" end, function(o, inven, item)
			local gem = t.make_gem(self, t, o.define_as)
			self:addObject(self.INVEN_INVEN, gem)
			self:removeObject(inven, item)
			game.logPlayer(self, "You create: %s", gem:getName{do_color=true, do_count=true})
			return true
		end)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Carve %d to %d alchemist gems out of natural gems.
		Alchemists gems are used for lots of other spells.]]):format(40, 80)
	end,
}

newTalent{
	name = "Extract Gems",
	type = {"spell/gemology", 1},
	require = spells_req1,
	points = 5,
	mana = 5,
	cooldown = 20,
	action = function(self, t)
		self:showEquipInven("Try to extract gems from which metallic item?", function(o) return o.metallic and (o.material_level or 1) <= self:getTalentLevelRaw(t) end, function(o, inven, item)
			self:removeObject(inven, item)

			local level = o.material_level or 1
			local gem = game.zone:makeEntity(game.level, "object", {type="gem", special=function(e) return e.material_level == level end}, nil, true)
			if gem then
				self:addObject(self.INVEN_INVEN, gem)
				game.logPlayer(self, "You extract: %s", gem:getName{do_color=true, do_count=true})
			end
			return true
		end)
		return true
	end,
	info = function(self, t)
		return ([[Extract magical gems from metal weapons and armours, the higher your skill the higher level items you can work with.]])
	end,
}

newTalent{
	name = "Imbue Item",
	type = {"spell/gemology", 2},
	require = spells_req2,
	points = 5,
	mana = 80,
	cooldown = 100,
	action = function(self, t)
		self:showInventory("Use which gem?", self:getInven("INVEN"), function(gem) return gem.type == "gem" and gem.material_level <= self:getTalentLevelRaw(t) end, function(gem, gem_item)
			self:showInventory("Imbue which armour?", self:getInven("INVEN"), function(o) return o.type == "armor" and o.slot == "BODY" and not o.been_imbued end, function(o, item)
				self:removeObject(self:getInven("INVEN"), gem_item)
				o.wielder = o.wielder or {}
				table.mergeAdd(o.wielder, gem.imbue_powers)
				o.been_imbued = true
				game.logPlayer(self, "You imbue your %s with %s.", o:getName{do_colour=true, no_count=true}, gem:getName{do_colour=true, no_count=true})
			end)
		end)
		return true
	end,
	info = function(self, t)
		return ([[Imbue an body armour with a gem, granting it additional powers.
		You can only imbue items once, and it is permanent.]])
	end,
}

newTalent{
	name = "Gem Vision",
	type = {"spell/gemology", 3},
	require = spells_req3,
	cooldown = 10,
	mana = 15,
	points = 5,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo or ammo:getNumber() < 2 then
			game.logPlayer(self, "You need to ready 2 alchemist gems in your quiver.")
			return
		end

		local x, y = self:getTarget{type="ball", nolock=true, no_restrict=true, range=100, radius=3 + self:getTalentLevel(t)}
		if not x then return nil end

		for i = 1, 2 do self:removeObject(self:getInven("QUIVER"), 1) end
		self:magicMap(3 + self:getTalentLevel(t), x, y)
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[Consumes two alchemist gems to see remote areas in a radius of %d.]]):
		format(3 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Gem Portal",
	type = {"spell/gemology",4},
	require = spells_req4,
	cooldown = 20,
	mana = 20,
	points = 5,
	range = 1,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo or ammo:getNumber() < 5 then
			game.logPlayer(self, "You need to ready 2 alchemist gems in your quiver.")
			return
		end

		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)

		for i = 1, 5 do self:removeObject(self:getInven("QUIVER"), 1) end
		local power = math.floor(4 + self:combatSpellpower(0.06) * self:getTalentLevel(t))
		self:probabilityTravel(x, y, power)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Crush 5 alchemists gems into dust to mark an impassable terrain, you immediately enter it and appear on the other side of the obstacle.
		Works up to %d grids away.]]):
		format(math.floor(4 + self:combatSpellpower(0.06) * self:getTalentLevel(t)))
	end,
}
