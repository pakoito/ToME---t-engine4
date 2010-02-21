load("/data/general/objects/objects.lua")

-- Artifact, droped by the sandworm queen
newEntity{
	define_as = "SANDQUEEN_HEART",
	type = "corpse", subtype = "heart",
	name = "Heart of the Sandworm Queen", unique=true, unided_name="pulsing organ",
	display = "*", color=colors.VIOLET,
	desc = [[The heart of the Sandworm Queen, ripped from her dead body. You could ... consume it, should you feel mad enough.]],
	cost = 4000,

	use_simple = { name="consume the heart", use = function(self, who)
		game.logPlayer(who, "#00FFFF#You consume the heart and feel the knowledge of this very old creature fills you!")
		who.unused_stats = who.unused_stats + 3
		who.unused_talents = who.unused_talents + 2
		game.logPlayer(who, "You have %d stat point(s) to spend. Press G to use them.", who.unused_stats)
		game.logPlayer(who, "You have %d talent point(s) to spend. Press G to use them.", who.unused_talents)

		who:learnTalentType("gift/sand", false)
		game.logPlayer(who, "You are transformed by the heart of the Queen!.")
		game.logPlayer(who, "#00FF00#You gain an affinity for sand. You can now learn new sand talents (press G).")

		return "destroy", true
	end}
}
