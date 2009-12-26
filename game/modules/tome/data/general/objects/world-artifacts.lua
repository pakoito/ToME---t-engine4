-- This file describes artifact not bound to a special location, they can be found anywhere
newEntity{
	unique = true,
	slot = "MAINHAND",
	type = "weapon", subtype="staff",
	name = "Staff of Destruction",
	level_range = {20, 25},
	display = "\\", color=colors.VIOLET,
	encumber = 6,
	rarity = 20,
	desc = [[This unique looking staff is carved with runes of destruction.]],

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
	type = "jewelery", subtype="lite",
	name = "Phial of Galadriel",
	level_range = {1, 10},
	display = "~", color=colors.YELLOW,
	encumber = 1,
	rarity = 10,
	desc = [[A small crystal phial, with the light of Earendil's Star contained inside. Its light is imperishable, and near it darkness cannot endure.]],

	wielder = {
		lite = 3,
	},
}

newEntity{
	unique = true,
	slot = "LITE",
	type = "jewelery", subtype="lite",
	name = "Arkenstone of Thrain",
	level_range = {20, 30},
	display = "~", color=colors.YELLOW,
	encumber = 1,
	rarity = 25,

	desc = [[A great globe seemingly filled with moonlight, the famed Heart of the Mountain, which splinters the light that falls upon it into a thousand glowing shards.]],

	wielder = {
		lite = 5,
	},
}

newEntity{
	unique = true,
	slot = "AMULET",
	type = "jewelery", subtype="amulet",
	name = "Shifting Amulet",
	level_range = {1, 10},
	display = '"', color=colors.VIOLET,
	encumber = 1,
	rarity = 10,
	desc = [[A crystal clear stone hangs on the chain. It displays images of your surroundings, but somehow they seem closer.]],

	use = function(self, o)
		game.logSeen(self, "%s uses the Shifting Amulet and blinks away!", self.name:capitalize())
		self:teleportRandom(self.x, self.y, 10)
		self:useEnergy()
	end,
}
