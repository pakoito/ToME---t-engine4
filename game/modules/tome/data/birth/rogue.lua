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
		equipment = resolvers.equip{ id=true,
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
		["technique/dualweapon-attack"]={true, 0.3},
		["technique/dualweapon-training"]={true, 0.3},
		["technique/combat-training"]={true, 0.2},
		["technique/weapon-training"]={true, 0.2},
		["cunning/stealth"]={true, 0.3},
		["cunning/traps"]={true, 0.3},
		["cunning/dirty"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_STEALTH] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_KNIFE_MASTERY] = 1,
	},
}
