newBirthDescriptor{
	type = "class",
	name = "Warrior",
	desc = {
		"Warriors train in all aspects of physical combat. They can be an juggernaut of destruction wielding a two-handed greatsword or a massive iron-clad protector with a shield.",
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
	copy = {
		max_life = 120,
		life_rating = 10,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Fighter",
	desc = {
		"A Fighter specializes in weapon and shield combat, rarely leaving the cover of her many protective techniques.",
		"A good Fighter is able to withstand terrible attacks from all sides, protected by her shield, and when the time comes she lashes out at her foes with incredible strength.",
		"Their most important stats are: Strength and Dexterity",
	},
	stats = { str=3, con=2, dex=1, },
	talents_types = {
		["technique/shield-offense"]={true, 0.3},
		["technique/shield-defense"]={true, 0.3},
		["technique/2hweapon-offense"]={false, -0.1},
		["technique/2hweapon-cripple"]={false, -0.1},
		["technique/dualweapon-attack"]={false, -0.1},
		["technique/dualweapon-training"]={false, -0.1},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={true, 0.3},
		["technique/combat-training"]={true, 0.3},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SHIELD_PUMMEL] = 1,
		[ActorTalents.T_SHIELD_WALL] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_HEAVY_ARMOUR_TRAINING] = 1,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true},
			{type="armor", subtype="shield", name="iron shield", autoreq=true},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true}
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Berserker",
	desc = {
		"A Berserker wields huge two-handed weapons of destruction, bringing pain and death to her foes as she cleaves them in two.",
		"A Berserker usualy forfeits all ideas of self-defence to concentrate on what she does best: killing things.",
		"Their most important stats are: Strength and Constitution",
	},
	stats = { str=3, con=2, dex=1, },
	talents_types = {
		["technique/shield-offense"]={false, -0.1},
		["technique/shield-defense"]={false, -0.1},
		["technique/2hweapon-offense"]={true, 0.3},
		["technique/2hweapon-cripple"]={true, 0.3},
		["technique/dualweapon-attack"]={false, -0.1},
		["technique/dualweapon-training"]={false, -0.1},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={true, 0.3},
		["technique/combat-training"]={true, 0.3},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_BERSERKER] = 1,
		[ActorTalents.T_STUNNING_BLOW] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_HEAVY_ARMOUR_TRAINING] = 1,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true},
		},
	},
}
