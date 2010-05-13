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
	name = "Sense",
	type = {"spell/divination", 1},
	require = spells_req1,
	points = 5,
	mana = 10,
	cooldown = 10,
	tactical = {
		ATTACK = 10,
	},
	action = function(self, t)
		local rad = 10 + self:combatSpellpower(0.1) * self:getTalentLevel(t)
		self:setEffect(self.EFF_SENSE, 2, {
			range = rad,
			actor = 1,
			object = (self:getTalentLevel(t) >= 2) and 1 or 0,
			trap = (self:getTalentLevel(t) >= 5) and 1 or 0,
		})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Sense foes around you in a radius of %d.
		At level 2 it detects objects.
		At level 5 it detects traps.
		The radius will increase with the Magic stat]]):format(10 + self:combatSpellpower(0.1) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Identify",
	type = {"spell/divination", 2},
	require = spells_req2,
	points = 5,
	mana = 20,
	action = function(self, t)
		local rad = math.floor(0 + (self:getTalentLevel(t) - 4))

		if self:getTalentLevel(t) < 3 then
			self:showEquipInven("Identify object", function(o) return not o:isIdentified() end, function(o)
				o:identify(true)
				game.logPlayer(self, "You identify: "..o:getName{do_color=true})
				return true
			end)
			return true
		end

		if self:getTalentLevel(t) >= 3 then
			for inven_id, inven in pairs(self.inven) do
				for i, o in ipairs(inven) do
					o:identify(true)
				end
			end
			game.logPlayer(self, "You identify all your inventory.")
		end

		if self:getTalentLevel(t) >= 4 then
			local idx = 1
			while true do
				local o = game.level.map:getObject(self.x, self.y, idx)
				if not o then break end
				o:identify(true)
				idx = idx + 1
			end
			game.logPlayer(who, "You identify everything around you.")
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Identify the powers and nature of an object.
		At level 3 it identifies all the objects in your possession.
		At level 4 it identifies all the objects on the floor in a radius of %d.]]):format(math.floor(0 + (self:getTalentLevel(t) - 4)))
	end,
}

newTalent{
	name = "Vision",
	type = {"spell/divination", 3},
	require = spells_req3,
	points = 5,
	mana = 20,
	cooldown = 20,
	action = function(self, t)
		self:magicMap(10 + self:combatSpellpower(0.1) * self:getTalentLevel(t))
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Form a map of your surroundings in your mind in a radius of %d.]]):format(10 + self:combatSpellpower(0.1) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Telepathy",
	type = {"spell/divination", 4},
	mode = "sustained",
	require = spells_req4,
	points = 5,
	sustain_mana = 200,
	cooldown = 30,
	activate = function(self, t)
		-- There is an implicit +10, as it is the default radius
		local rad = self:combatSpellpower(0.1) * self:getTalentLevel(t)
		game:playSoundNear(self, "talents/spell_generic")
		return {
			esp = self:addTemporaryValue("esp", {range=rad, all=1}),
			drain = self:addTemporaryValue("mana_regen", -3 * self:getTalentLevelRaw(t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("esp", p.esp)
		self:removeTemporaryValue("mana_regen", p.drain)
		return true
	end,
	info = function(self, t)
		return ([[Allows to sense the presence of foes in your mind, in a radius of %d.
		This powerfull spell will continuously drain mana while active.
		The bonus will increase with the Magic stat]]):format(10 + self:combatSpellpower(0.1) * self:getTalentLevel(t))
	end,
}
