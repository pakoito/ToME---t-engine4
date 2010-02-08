load("/data/general/objects/objects.lua")

-- Artifact, droped by the sandworm queen
newEntity{
	define_as = "SANDQUEEN_HEART",
	type = "corpse", subtype = "heart",
	name = "Heart of the Sandworm Queen", unique=true,
	display = "*", color=colors.VIOLET,
	desc = [[The heart of the Ssandworm Queen, ripped from her dead body. You could ... consume it, should you feel mad enough.]],
	cost = 4000,

	use_simple = { name="consume the heart", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You consume the heart and feel the knowledge of this very old creature fill you!")
		who.unused_stats = who.unused_stats + 3
		who.unused_talents = who.unused_talents + 2
		game.logPlayer(who, "You have %d stat point(s) to spend. Press G to use them.", who.unused_stats)
		game.logPlayer(who, "You have %d talent point(s) to spend. Press G to use them.", who.unused_talents)
		return "destroy", true
	end}
}
