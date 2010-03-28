newChat{ id="ambush",
	text = [[#VIOLET#*As you come out of Tol Falas you encounter a band of orcs*#LAST#
You! Give us that staff NOW and we might offer you a quick death!]],
	answers = {
		{"What do you speak about?", jump="what"},
		{"Why would you want it?", jump="why"},
		{"#LIGHT_GREEN#[Attack]"},
	}
}

newChat{ id="what",
	text = [[Do not feign to be dumb with Ukruk! ATTACK!]],
	answers = {
		{"#LIGHT_GREEN#[Attack]"},
	}
}

newChat{ id="why",
	text = [[That is not your concern! ATTACK!]],
	answers = {
		{"#LIGHT_GREEN#[Attack]"},
	}
}

return "ambush"
