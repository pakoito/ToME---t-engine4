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
	talents = { [ActorTalents.T_STAMINA_POOL]=1, },
	copy = {
		max_life = 120,
		life_rating = 10,
		equipment = resolvers.equip{
			{type="weapon", subtype="longsword", name="iron longsword"},
			{type="armor", subtype="shield", name="iron shield"},
			{type="armor", subtype="massive", name="iron massive armor"}
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Warrior",
	desc = {
		"Simple fighters, they hack away with their trusty weapon.",
	},
	stats = { str=3, con=2, dex=1, },
	talents_types = {
		["physical/shield"]={true, 0.3},
		["physical/2hweapon"]={true, 0.3},
		["physical/combat-training"]={true, 0.3},
		["physical/weapon-training"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_SHIELD_BASH] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_SWORD_MASTERY] = 1,
	},
}

newBirthDescriptor{
	type = "class",
	name = "Rogue",
	desc = {
		"Rogues are masters of tricks, they can steal from shops and monsters",
		"and lure monsters into deadly traps.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "never",
			Rogue = "allow",
		},
	},
	talents = { [ActorTalents.T_STAMINA_POOL]=1, },
	copy = {
		max_life = 100,
		life_rating = 9,
		equipment = resolvers.equip{
			{type="weapon", subtype="dagger", name="iron dagger"},
			{type="weapon", subtype="dagger", name="iron dagger"},
			{type="armor", subtype="light", name="rough leather armour"}
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Rogue",
	desc = {
		"Rogues are masters of tricks, they can steal from shops and monsters",
		"and lure monsters into deadly traps.",
	},
	stats = { dex=2, str=1, cun=3, },
	talents_types = {
		["physical/dualweapon"]={true, 0.3},
		["physical/combat-training"]={true, 0},
		["physical/weapon-training"]={true, 0},
		["cunning/stealth"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_STEALTH] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_KNIFE_MASTERY] = 1,
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
	talents = { [ActorTalents.T_MANA_POOL]=1, },
	copy = {
		max_life = 80,
		life_rating = 7,
		equipment = resolvers.equip{
			{type="weapon", subtype="staff", name="elm staff"},
			{type="armor", subtype="cloth", name="robe"}
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Mage",
	desc = {
		"Simple fighters, they hack away with their trusty weapon.",
	},
	stats = { mag=3, wil=2, cun=1, },
	talents_types = {
		["spell/arcane"]={true, 0.3},
		["spell/fire"]={true, 0.3},
		["spell/earth"]={true, 0.3},
		["spell/water"]={true, 0.3},
		["spell/air"]={true, 0.3},
		["spell/mind"]={true, 0.3},
		["spell/temporal"]={true, 0.3},
		["spell/meta"]={true, 0.3},
		["spell/divination"]={true, 0.3},
		["spell/conveyance"]={true, 0.3},
		["spell/nature"]={true, 0.3},
		["spell/necromancy"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_MANATHRUST] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_FREEZE] = 1,
	},
}
