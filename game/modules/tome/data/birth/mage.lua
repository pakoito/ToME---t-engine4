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
			["Arcane Blade"] = "allow",
			Archmage = "allow",
		},
	},
	talents = { [ActorTalents.T_MANA_POOL]=1, },
	copy = {
		max_life = 80,
		life_rating = 7,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff"},
			{type="armor", subtype="cloth", name="robe"}
		},
		resolvers.inventory{ id=true,
			{type="potion", subtype="potion", name="potion of lesser mana"},
			{type="potion", subtype="potion", name="potion of lesser mana"},
		},
		resolvers.generic(function(e)
			e.hotkey[10] = {"inventory", "potion of lesser mana"}
		end),
	},
	talents_types = {
		["spell/arcane"]={true, -0.3},
		["spell/fire"]={true, -0.3},
		["spell/earth"]={true, -0.3},
		["spell/water"]={true, -0.3},
		["spell/air"]={true, -0.3},
		["spell/phantasm"]={true, -0.3},
		["spell/temporal"]={true, -0.3},
		["spell/meta"]={true, -0.3},
		["spell/divination"]={true, -0.3},
		["spell/conveyance"]={true, -0.3},
		["spell/nature"]={true, -0.3},
		["spell/necromancy"]={true, -0.3},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Archmage",
	desc = {
		"Archmagi devote their whole life to the study of magic. What they lack in most other skills they make up with magic.",
	},
	stats = { mag=3, wil=2, cun=1, },
	talents_types = {
		["spell/arcane"]={true, 0.7},
		["spell/fire"]={true, 0.7},
		["spell/earth"]={true, 0.7},
		["spell/water"]={true, 0.7},
		["spell/air"]={true, 0.7},
		["spell/phantasm"]={true, 0.7},
		["spell/temporal"]={true, 0.7},
		["spell/meta"]={true, 0.7},
		["spell/divination"]={true, 0.7},
		["spell/conveyance"]={true, 0.7},
		["spell/nature"]={true, 0.7},
		["spell/necromancy"]={true, 0.7},
	},
	talents = {
		[ActorTalents.T_MANATHRUST] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_FREEZE] = 1,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Arcane Blade",
	desc = {
		"The Arcane Blade is a mage at heart but who can stand his own in a melee.",
	},
	stats = { mag=2, wil=1, str=2, dex=1},
	talents_types = {
		["spell/arcane"]={true, 0.3},
		["spell/fire"]={true, 0.3},
		["spell/earth"]={true, 0.3},
		["spell/water"]={true, 0.3},
		["spell/air"]={true, 0.3},
		["spell/phantasm"]={true, 0.3},
		["spell/temporal"]={false, 0.3},
		["spell/meta"]={false, 0.3},
		["spell/divination"]={true, 0.3},
		["spell/conveyance"]={true, 0.3},
		["spell/nature"]={true, 0.3},
		["spell/necromancy"]={false, 0.3},
		["technique/combat-training"]={true, 0},
		["technique/weapon-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_MANATHRUST] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_STAMINA_POOL]=1,
	},
}
