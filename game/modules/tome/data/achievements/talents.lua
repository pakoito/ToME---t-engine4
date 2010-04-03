newAchievement{
	name = "Elementalist",
	desc = [[Maxed all elemental spells.]],
	can_gain = function(who)
		local types = table.reverse{"spell/fire", "spell/earth", "spell/water", "spell/air"}
		local nb = 0
		for id, _ in pairs(who.talents) do
			local t = who:getTalentFromId(id)
			if types[t.type[1]] then nb = nb + who:getTalentLevelRaw(t) end
		end
		return nb >= 4 * 4 * 5
	end
}

newAchievement{
	name = "Warper",
	desc = [[Maxed all arcane, conveyance, divination and temporal spells.]],
	can_gain = function(who)
		local types = table.reverse{"spell/arcane", "spell/temporal", "spell/conveyance", "spell/divination"}
		local nb = 0
		for id, _ in pairs(who.talents) do
			local t = who:getTalentFromId(id)
			if types[t.type[1]] then nb = nb + who:getTalentLevelRaw(t) end
		end
		return nb >= 4 * 4 * 5
	end
}
