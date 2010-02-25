newBirthDescriptor{
	type = "class",
	name = "Archer",
	desc = {
		"Archers.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "never",
			Archer = "allow",
			Slinger = "allow",
		},
	},
	copy = {
		max_life = 95,
		life_rating = 9,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Archer",
	desc = {
		"Archer",
		"Their most important stats are: Strength and Dexterity",
	},
	stats = { dex=3, str=2, con=1, },
	talents_types = {
		["technique/archery-training"]={true, 0.3},
		["technique/archery-cripple"]={true, 0.3},
		["technique/archery-bow"]={true, 0.3},
		["technique/archery-sling"]={false, 0.1},
		["technique/combat-techniques-active"]={true, -0.1},
		["technique/combat-techniques-passive"]={false, -0.1},
		["technique/combat-training"]={true, 0.3},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_STEADY_SHOT] = 1,
		[ActorTalents.T_BOW_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		equipment = resolvers.equip{ id=true,
			{type="weapon", subtype="longbow", name="elm longbow"},
			{type="ammo", subtype="arrow", name="elm arrow"},
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Slinger",
	desc = {
		"Slinger",
		"Their most important stats are: Strength and Dexterity",
	},
	stats = { dex=3, str=2, con=1, },
	talents_types = {
		["technique/archery-training"]={true, 0.3},
		["technique/archery-cripple"]={true, 0.3},
		["technique/archery-bow"]={false, 0.1},
		["technique/archery-sling"]={true, 0.3},
		["technique/combat-techniques-active"]={true, -0.1},
		["technique/combat-techniques-passive"]={false, -0.1},
		["technique/combat-training"]={true, 0.3},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_STEADY_SHOT] = 1,
		[ActorTalents.T_SLING_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		equipment = resolvers.equip{ id=true,
			{type="weapon", subtype="sling", name="elm sling"},
			{type="ammo", subtype="shot", name="iron shot"},
		},
	},
}
