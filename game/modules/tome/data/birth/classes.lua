newBirthDescriptor{
	type = "class",
	name = "Warrior",
	desc = {
		"Simple fighters, they hack away with their trusty weapon.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "never",
			Warrior = "allow",
		},
	},
	talents = { ActorTalents.T_STAMINA_POOL, },
}

newBirthDescriptor{
	type = "subclass",
	name = "Warrior",
	desc = {
		"Simple fighters, they hack away with their trusty weapon.",
	},
	stats = { str=3, con=2, dex=1, },
	talents_types = {
		["physical/1hweapon"]=true,
		["physical/2hweapon"]=true,
		["physical/shield"]=true,
		["physical/1hweapon"]=true,
	},
}

newBirthDescriptor{
	type = "class",
	name = "Mage",
	desc = {
		"The basic spellcaster with lots of different skills",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "never",
			Mage = "allow",
		},
	},
	talents = { ActorTalents.T_MANA_POOL, },
}

newBirthDescriptor{
	type = "subclass",
	name = "Mage",
	desc = {
		"Simple fighters, they hack away with their trusty weapon.",
	},
	stats = { mag=3, wil=2, cun=1, },
	talents_types = {
		["spell/arcane"]=true,
		["spell/fire"]=true,
		["spell/earth"]=true,
		["spell/cold"]=true,
		["spell/air"]=true,
		["spell/conveyance"]=false,
		["spell/nature"]=false,
	},
	talents = {
		ActorTalents.T_MANATHRUST,
	},
}
