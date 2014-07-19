-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	type = {"spell/stone-alchemy-base", 1},
	require = spells_req1,
	points = 1,
	mana = 30,
	no_npc_use = true,
	no_unlearn_last = true,
	make_gem = function(self, t, base_define)
		local nb = rng.range(40, 80)
		local gem = game.zone:makeEntityByName(game.level, "object", "ALCHEMIST_" .. base_define)
		if not gem then return end

		local s = {}
		while nb > 0 do
			s[#s+1] = gem:clone()
			nb = nb - 1
		end
		for i = 1, #s do gem:stack(s[i]) end

		return gem
	end,
	action = function(self, t)
		local ret = self:talentDialog(self:showEquipInven("Use which gem?", function(o) return not o.unique and o.type == "gem" and not o.__tagged end, function(o, inven, item)
			if not o then return end
			local gem = t.make_gem(self, t, o.define_as)
			if not gem then return end
			self:addObject(self.INVEN_INVEN, gem)
			self:removeObject(inven, item)
			game.logPlayer(self, "You create: %s", gem:getName{do_color=true, do_count=true})
			self:sortInven()
			self:talentDialogReturn(true)
			return true
		end))
		if not ret then return nil end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Carve 40 to 80 alchemist gems out of a natural gemstone.
		Alchemists gems are used for many other spells, and each gem type creates a different effect.]]):format()
	end,
}

newTalent{
	name = "Extract Gems",
	type = {"spell/stone-alchemy", 1},
	require = spells_req1,
	points = 5,
	no_npc_use = true,
	no_unlearn_last = true,
	on_learn = function(self, t)
		self:learnTalent(self.T_CREATE_ALCHEMIST_GEMS, true)
	end,
	on_unlearn = function(self, t)
		self:unlearnTalent(self.T_CREATE_ALCHEMIST_GEMS)
	end,
	filterGem = function(self, t, o) return o.metallic and (o.material_level or 1) <= self:getTalentLevelRaw(t) and not o.__tagged end,
	getGem = function(self, t, o)
		if not o then return end

		local level = o.material_level or 1
		local gem = game.zone:makeEntity(game.level, "object", {ignore_material_restriction=true, type="gem", special=function(e) return not e.unique and e.material_level == level end}, nil, true)
		if gem then return gem end
	end,
	extractGem = function(self, t, o, inven, item, d)
		if not o then return end
		self:removeObject(inven, item)

		local level = o.material_level or 1
		local gem = t.getGem(self, t, o)
		if gem then
			self:addObject(self.INVEN_INVEN, gem)
			game.logPlayer(self, "You extract %s from %s", gem:getName{do_color=true, do_count=true}, o:getName{do_color=true, do_count=true})
			self:sortInven()
			self:talentDialogReturn(true)
		end
		return true
	end,
	action = function(self, t)
		if not self:talentDialog(self:showEquipInven("Try to extract gems from which metallic item?", function(o) return t.filterGem(self, t, o) end, function(o, inven, item) return t.extractGem(self, t, o, inven, item, d) end)) then return nil end
		return true
	end,
	info = function(self, t)
		local material = ""
		if self:getTalentLevelRaw(t) >=1 then material=material.."	-Iron\n" end
		if self:getTalentLevelRaw(t) >=2 then material=material.."	-Steel\n" end
		if self:getTalentLevelRaw(t) >=3 then material=material.."	-Dwarven-steel\n" end
		if self:getTalentLevelRaw(t) >=4 then material=material.."	-Stralite\n" end
		if self:getTalentLevelRaw(t) >=5 then material=material.."	-Voratun" end
		return ([[Extract magical gems from metal weapons and armours. At this skill level you can work with:
		%s]]):format(material)
	end,
}

newTalent{
	name = "Imbue Item",
	type = {"spell/stone-alchemy", 2},
	require = spells_req2,
	points = 5,
	mana = 80,
	cooldown = 100,
	no_npc_use = true,
	no_unlearn_last = true,
	action = function(self, t)
		local ret = self:talentDialog(self:showInventory("Use which gem?", self:getInven("INVEN"), function(gem) return gem.type == "gem" and gem.imbue_powers and gem.material_level and gem.material_level <= self:getTalentLevelRaw(t) end, function(gem, gem_item)
			local nd = self:showInventory("Imbue which armour?", self:getInven("INVEN"), function(o) return o.type == "armor" and (o.slot == "BODY" or (self:knowTalent(self.T_CRAFTY_HANDS) and (o.slot == "HEAD" or o.slot == "BELT"))) and not o.been_imbued end, function(o, item)
				self:removeObject(self:getInven("INVEN"), gem_item)
				o.wielder = o.wielder or {}
				table.mergeAdd(o.wielder, gem.imbue_powers, true)
				if gem.talent_on_spell then
					o.talent_on_spell = o.talent_on_spell or {}
					table.append(o.talent_on_spell, gem.talent_on_spell)
				end
				o.been_imbued = " <"..gem.name..">"
				game.logPlayer(self, "You imbue your %s with %s.", o:getName{do_colour=true, no_count=true}, gem:getName{do_colour=true, no_count=true})
				o.special = true
				self:talentDialogReturn(true)
				game:unregisterDialog(self:talentDialogGet())
			end)
			nd.unload = function(_) game:unregisterDialog(self:talentDialogGet()) end
			return true
		end))
		if not ret then return nil end
		return true
	end,
	info = function(self, t)
		return ([[Imbue %s with a gem (up to tier %d), granting it additional powers.
		You can only imbue items once, and it is permanent.]]):format(self:knowTalent(self.T_CRAFTY_HANDS) and "body armour, a belt, or a head piece" or "a body armour", self:getTalentLevelRaw(t))
	end,
}
newTalent{
	name = "Gem Portal",
	type = {"spell/stone-alchemy",3},
	require = spells_req3,
	cooldown = function(self, t) return math.max(5, 20 - (self:getTalentLevelRaw(t) * 2)) end,
	mana = 20,
	points = 5,
	range = 1,
	no_npc_use = true,
	getRange = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.06) * self:getTalentLevel(t), 4, 0, 20, 16)) end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo or ammo:getNumber() < 5 then
			game.logPlayer(self, "You need to ready 5 alchemist gems in your quiver.")
			return
		end

		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t, simple_dir_request=true}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)

		local ox, oy = self.x, self.y
		local l = line.new(self.x, self.y, x, y)
		local nextx, nexty = l()
		if not nextx or not game.level.map:checkEntity(nextx, nexty, Map.TERRAIN, "block_move", self) then return end

		self:probabilityTravel(x, y, t.getRange(self, t))

		if ox == self.x and oy == self.y then return end

		for i = 1, 5 do self:removeObject(self:getInven("QUIVER"), 1) end
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		return ([[Crush 5 alchemists gems into dust to mark impassable terrain next to you. You immediately enter it and appear on the other side of the obstacle, up to %d grids away.]]):
		format(range)
	end,
}

newTalent{
	name = "Stone Touch",
	type = {"spell/stone-alchemy",4},
	require = spells_req4,
	points = 5,
	mana = 45,
	cooldown = 15,
	tactical = { DISABLE = { stun = 1.5, instakill = 1.5 } },
	range = function(self, t)
		if self:getTalentLevel(t) < 3 then return 1
		else return math.floor(self:combatTalentScale(t, 1, 5)) end
	end,
	requires_target = true,
	target = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		if self:getTalentLevel(t) >= 3 then tg.type = "beam" end
		return tg
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3.6, 6.3)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end

			if target:canBe("stun") and target:canBe("stone") and target:canBe("instakill") then
				target:setEffect(target.EFF_STONED, t.getDuration(self, t), {apply_power=self:combatSpellpower()})
				game.level.map:particleEmitter(tx, ty, 1, "archery")
			end
		end)
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Touch your foe and turn it to stone for %d turns.
		Stoned creatures are unable to act or regen life, and are very brittle.
		If a stoned creature is hit by an attack that deals more than 30%% of its life, it will shatter and be destroyed.
		Stoned creatures are highly resistant to fire and lightning, and somewhat resistant to physical attacks.
		At level 3 the touch will become a beam.
		This spell may fail against creatures resistant to being stunned, that are specifically immune to stoning, or certain bosses.]]):
		format(duration)
	end,
}
