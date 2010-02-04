load("/data/general/objects/objects.lua")

-- Artifact, droped by the sandworm queen
newEntity{
	define_as = "TOME_OF_IMPROVEMENT",
	type = "scroll", subtype = "tome",
	name = "Tome of Improvemend", unique=true,
	display = "?", color=colors.VIOLET,
	desc = [[This very rare tome of power contains magic words that can make the user stronger, wiser, more able, ...]],
	cost = 4000,

	use_simple = { name="increase talent and stat points", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You read the tome alound and feel its magic change you!")
		who.unused_stats = who.unused_stats + 3
		who.unused_talents = who.unused_talents + 2
		game.logPlayer(who, "You have %d stat point(s) to spend. Press G to use them.", who.unused_stats)
		game.logPlayer(who, "You have %d talent point(s) to spend. Press G to use them.", who.unused_talents)
		return "destroy", true
	end}
}
