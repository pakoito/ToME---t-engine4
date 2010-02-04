local Stats = require "engine.interface.ActorStats"

-- This file describes artifact not bound to a special location, they can be found anywhere
newEntity{ base = "BASE_STAFF",
	unique = true,
	name = "Staff of Destruction",
	unided_name = "ash staff",
	level_range = {20, 25},
	color=colors.VIOLET,
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

newEntity{ base = "BASE_RING",
	unique = true,
	name = "Ring of Ulmo", color = colors.LIGHT_BLUE,
	unided_name = "sea-blue ring",
	desc = [[This azure ring seems to be always moist to the touch.]],
	level_range = {10, 20},
	rarity = 150,
	cost = 5000,

	max_power = 60, power_regen = 1,
	use_power = { name = "summon a tidal wave", power = 60,
		use = function(self, who)
			local duration = 7
			local radius = 1
			local dam = 20
			-- Add a lasting map effect
			game.level.map:addEffect(who,
				who.x, who.y, duration,
				DamageType.WAVE, dam,
				radius,
				5, nil,
				engine.Entity.new{alpha=100, display='', color_br=30, color_bg=60, color_bb=200},
				function(e)
					e.radius = e.radius + 1
				end,
				false
			)
			game.logSeen(who, "%s brandishes the %s, calling forth the might of the oceans!", who.name:capitalize(), self:getName())
		end
	},
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CON] = 3 },
		max_mana = 20,
		max_stamina = 20,
		resists = {
			[DamageType.COLD] = 25,
			[DamageType.NATURE] = 10,
		},
	},
}

newEntity{ base = "BASE_LITE",
	unique = true,
	name = "Phial of Galadriel",
	unided_name = "glowing phial",
	level_range = {1, 10},
	color=colors.YELLOW,
	encumber = 1,
	rarity = 100,
	desc = [[A small crystal phial, with the light of Earendil's Star contained inside. Its light is imperishable, and near it darkness cannot endure.]],
	cost = 2000,

	max_power = 15, power_regen = 1,
	use_power = { name = "call light", power = 10,
		use = function(self, who)
			who:project({type="ball", range=0, friendlyfire=false, radius=20}, who.x, who.y, DamageType.LIGHT, 1)
			game.logSeen(who, "%s brandishes the %s and banishes all shadows!", who.name:capitalize(), self:getName())
		end
	},
	wielder = {
		lite = 4,
	},
}

newEntity{ base = "BASE_LITE",
	unique = true,
	name = "Arkenstone of Thrain",
	unided_name = "great jewel",
	level_range = {20, 30},
	color=colors.YELLOW,
	encumber = 1,
	rarity = 250,
	desc = [[A great globe seemingly filled with moonlight, the famed Heart of the Mountain, which splinters the light that falls upon it into a thousand glowing shards.]],
	cost = 4000,

	max_power = 150, power_regen = 1,
	use_power = { name = "map surroundings", power = 100,
		use = function(self, who)
			who:magicMap(20)
			game.logSeen(who, "%s brandishes the %s which glitters in all directions!", who.name:capitalize(), self:getName())
		end
	},
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
	display = '!', color=colors.VIOLET, image="object/potion-0x3-violet.png",
	encumber = 0.4,
	rarity = 150,
	desc = [[Bottle containing healing magic. But the more you drink from it, the more it refills!]],
	cost = 200,

	max_power = 100, power_regen = 1,
	use_power = { name = "heal", power = 80,
		use = function(self, who)
			who:heal(150 + who:getMag())
			game.logSeen(who, "%s quaffs an %s!", who.name:capitalize(), self:getName())
		end
	},
}

newEntity{
	unique = true,
	type = "potion", subtype="potion",
	name = "Ever Refilling Potion of Mana",
	unided_name = "strange potion",
	level_range = {35, 40},
	display = '!', color=colors.VIOLET, image="object/potion-0x3-violet.png",
	encumber = 0.4,
	rarity = 150,
	desc = [[Bottle containing raw magic. But the more you drink from it, the more it refills!]],
	cost = 200,

	max_power = 100, power_regen = 1,
	use_power = { name = "restore mana", power = 80,
		use = function(self, who)
			who:incMana(150 + who:getMag())
			game.logSeen(who, "%s quaffs an %s!", who.name:capitalize(), self:getName())
		end
	},
}
