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
			Wyrmic = "allow",
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Summoner",
	desc = {
		"Summoners never fight alone, they are always ready to invoke one of their many summons to fight at their side.",
		"Summons can range from a combat hound to a fire drake.",
		"Their most important stats are: Willpower and Constitution",
	},
	stats = { wil=3, con=2, cun=1, },
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/summon-melee"]={true, 0.3},
		["wild-gift/summon-distance"]={true, 0.3},
		["wild-gift/summon-utility"]={true, 0.3},
		["wild-gift/summon-augmentation"]={false, 0.3},
		["cunning/survival"]={true, 0},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={false, 0},
		["technique/combat-training"]={false, 0},
	},
	talents = {
		[ActorTalents.T_WAR_HOUND] = 1,
		[ActorTalents.T_FIRE_IMP] = 1,
		[ActorTalents.T_MEDITATION] = 1,
		[ActorTalents.T_TRAP_DETECTION] = 1,
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

newBirthDescriptor{
	type = "subclass",
	name = "Wyrmic",
	desc = {
		"Wyrmics are fighters who have learnt how to mimic some of the aspects of the dragons.",
		"They have access to talents normaly belonging to the various kind of drakes.",
		"Their most important stats are: Strength and Willpower",
	},
	stats = { str=3, wil=2, dex=1, },
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/sand-drake"]={true, 0.3},
		["wild-gift/fire-drake"]={true, 0.3},
		["wild-gift/cold-drake"]={true, 0.3},
		["cunning/survival"]={false, 0},
		["technique/shield-offense"]={false, -0.1},
		["technique/2hweapon-offense"]={false, -0.1},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={true, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_ICE_CLAW] = 1,
		[ActorTalents.T_BELLOWING_ROAR] = 1,
		[ActorTalents.T_MEDITATION] = 1,
		[ActorTalents.T_AXE_MASTERY] = 1,
	},
	copy = {
		max_life = 110,
		life_rating = 12,
		resolvers.equip{ id=true,
			{type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true}
		},
	},
}
