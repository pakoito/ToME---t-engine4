-- This file describes artifact not bound to a special location, they can be found anywhere
newEntity{
	unique = true,
	slot = "MAINHAND",
	type = "weapon", subtype="staff",
	name = "Staff of Destruction",
	unided_name = "ash staff",
	level_range = {20, 25},
	display = "\\", color=colors.VIOLET,
	encumber = 6,
	rarity = 100,
	desc = [[This unique looking staff is carved with runes of destruction.]],
	cost = 5000,

	require = { stat = { mag=24 }, },
	combat = {
		dam = 15,
		apr = 4,
		dammod = {mag=1.5},
	},
	wielder = {
		combat_spellpower = 10,
		combat_spellcrit = 15,
	},
}

newEntity{
	unique = true,
	slot = "LITE",
	type = "jewelry", subtype="lite",
	name = "Phial of Galadriel",
	unided_name = "glowing phial",
	level_range = {1, 10},
	display = "~", color=colors.YELLOW,
	encumber = 1,
	rarity = 100,
	desc = [[A small crystal phial, with the light of Earendil's Star contained inside. Its light is imperishable, and near it darkness cannot endure.]],
	cost = 2000,

	wielder = {
		lite = 4,
	},
}

newEntity{
	unique = true,
	slot = "LITE",
	type = "jewlery", subtype="lite",
	name = "Arkenstone of Thrain",
	unided_name = "great jewel",
	level_range = {20, 30},
	display = "~", color=colors.YELLOW,
	encumber = 1,
	rarity = 250,
	desc = [[A great globe seemingly filled with moonlight, the famed Heart of the Mountain, which splinters the light that falls upon it into a thousand glowing shards.]],
	cost = 4000,

	wielder = {
		lite = 5,
	},
}

newEntity{
	unique = true,
	type = "potion", subtype="potion",
	name = "Ever Refilling Potion of Healing",
	unided_name = "strange potion",
	level_range = {35, 40},
	display = '!', color=colors.VIOLET,
	encumber = 0.4,
	rarity = 80,
	desc = [[Bottle containing healing magic. But the more you drink from it, the more it refills!]],
	cost = 2000,

	max_power = 40, power_regen = 1,
	use_power = { name = "blink away", power = 30,
		use = function(self, who)
			who:heal(150 + who:getMag())
			game.logSeen(who, "%s quaffs an %s!", who.name:capitalize(), self:getName())
		end
	},
}
