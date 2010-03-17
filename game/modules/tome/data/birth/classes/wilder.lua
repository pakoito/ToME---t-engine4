newBirthDescriptor{
	type = "class",
	name = "Wilder",
	desc = {
		"Wilders are one with nature, in a manner or an other. There are as many different wilders as there are aspects of nature.",
		"They can take on the aspect of creatures, summon creatures to them, feel the druidic call, ...",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "never",
			Summoner = "allow",
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Summoner",
	desc = {
		"",
		"Their most important stats are: Willpower",
	},
	stats = { wil=3, mag=2, cun=1, },
	talents_types = {
		["gift/summon-melee"]={true, 0.3},
		["gift/summon-distance"]={true, 0.3},
		["gift/summon-utility"]={true, 0.3},
		["cunning/survival"]={false, 0},
		["technique/combat-techniques-active"]={true, 0},
		["technique/combat-techniques-passive"]={true, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_WAR_HOUND] = 1,
	},
	copy = {
		max_life = 90,
		life_rating = 10,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true}
		},
	},
}
