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
			Shadowdancer = "allow",
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
		"Rogues are masters of tricks. A rogue can get behind you unnoticed and stab you in the back for tremoundous damage.",
		"Rogues usualy prefer to dual-wield daggers. They can also become trapping experts, from detecting and disarming them to setting them.",
		"Their most important stats are: Dexterity and Cunning",
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
		["cunning/survival"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_STEALTH] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_KNIFE_MASTERY] = 1,
		[ActorTalents.T_TRAP_DETECTION] = 1,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Shadowblade",
	desc = {
		"Shadowblades are a blend of rogues and mages, able to kill with their daggers under a veil of stealth while casting spells",
		"to enhance their performance and survival.",
		"Their most important stats are: Dexterity and Cunning",
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
		["cunning/survival"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_STEALTH] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_KNIFE_MASTERY] = 1,
		[ActorTalents.T_TRAP_DETECTION] = 1,
	},
}
