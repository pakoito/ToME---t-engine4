-------------- Levels
newAchievement{
	name = "Level 10",
	desc = [[Got a character to level 10.]],
}
newAchievement{
	name = "Level 20",
	desc = [[Got a character to level 20.]],
}
newAchievement{
	name = "Level 30",
	desc = [[Got a character to level 30.]],
}
newAchievement{
	name = "Level 40",
	desc = [[Got a character to level 40.]],
}
newAchievement{
	name = "Level 50",
	desc = [[Got a character to level 50.]],
}

--------------- Main objectives
newAchievement{
	name = "Vampire crusher",
	desc = [[Destroyed the Master in its lair of Tol Falas.]],
}
newAchievement{
	name = "A dangerous secret",
	desc = [[Found the mysterious staff and told Minas Tirith about it.]],
}

--------------- Misc
newAchievement{
	name = "That was close",
	desc = [[Kill your target while having only 1 life left.]],
}
newAchievement{
	name = "Size matters",
	desc = [[Do over 600 damage in one attack]],
}
newAchievement{
	name = "Exterminator",
	desc = [[Killed 1000 creatures]],
	can_gain = function(who)
		who.nb_kill_creatures = (who.nb_kill_creatures or 0) + 1
		if who.nb_kill_creatures >= 1000 then return true end
	end
}
