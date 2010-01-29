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
			Fighter = "allow",
			Berserker = "allow",
		},
	},
	talents = { [ActorTalents.T_STAMINA_POOL]=1, },
	copy = {
		max_life = 120,
		life_rating = 10,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Fighter",
	desc = {
		"A warrior specializing in weapon and shield combat.",
	},
	stats = { str=3, con=2, dex=1, },
	talents_types = {
		["technique/shield-offense"]={true, 0.3},
		["technique/shield-defense"]={true, 0.3},
		["technique/2hweapon-offense"]={true, 0},
		["technique/2hweapon-cripple"]={true, 0},
		["technique/combat-training"]={true, 0.2},
		["technique/weapon-training"]={true, 0.2},
	},
	talents = {
		[ActorTalents.T_SHIELD_PUMMEL] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_HEAVY_ARMOUR_TRAINING] = 1,
	},
	copy = {
		equipment = resolvers.equip{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword"},
			{type="armor", subtype="shield", name="iron shield"},
			{type="armor", subtype="heavy", name="iron mail armour"}
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Berserker",
	desc = {
		"A warrior specializing in two handed weapon combat",
	},
	stats = { str=3, con=2, dex=1, },
	talents_types = {
		["technique/shield-offense"]={true, 0},
		["technique/shield-defense"]={true, 0},
		["technique/2hweapon-offense"]={true, 0.3},
		["technique/2hweapon-cripple"]={true, 0.3},
		["technique/combat-training"]={true, 0.2},
		["technique/weapon-training"]={true, 0.2},
	},
	talents = {
		[ActorTalents.T_BERSERKER] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_HEAVY_ARMOUR_TRAINING] = 1,
	},
	copy = {
		equipment = resolvers.equip{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword"},
			{type="armor", subtype="heavy", name="iron mail armour"}
		},
	},
}
