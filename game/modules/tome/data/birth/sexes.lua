-- Player sexes
newBirthDescriptor{
	type = "sex",
	name = "Female",
	desc =
	{
		"You are a female of the species.",
		"There is no in-game difference between the two sexes.",
	},
	data = { female=true, },
}

newBirthDescriptor{
	type = "sex",
	name = "Male",
	desc =
	{
		"You are a male of the species.",
		"There is no in-game difference between the two sexes.",
	},
	flags = { male=true, },
}
