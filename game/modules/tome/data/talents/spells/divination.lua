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
	name = "Indentify",
	type = {"spell/divination", 2},
	require = spells_req2,
	points = 3,
	mana = 20,
	cooldown = 20,
	action = function(self, t)
		local rad = math.floor(0 + (self:getTalentLevel(t) - 4))
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
		return {
			esp = self:addTemporaryValue("esp", {range=rad, all=1}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("esp", p.esp)
		return true
	end,
	info = function(self, t)
		return ([[Allows to sense the presence of foes in your mind, in a radius of %d.
		The bonus will increase with the Magic stat]]):format(10 + self:combatSpellpower(0.1) * self:getTalentLevel(t))
	end,
}
