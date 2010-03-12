-- Special items, used for quests

newEntity{ define_as = "STAFF_ABSORPTION",
	unique = true, quest=true,
	slot = "MAINHAND",
	type = "weapon", subtype="staff",
	unided_name = "dark runed staff",
	name = "Staff of Absorption",
	level_range = {30, 30},
	display = "\\", color=colors.VIOLET,
	encumber = 7,
	desc = [[Carved with runes of power this staff seems to have been made long ago. Yet it retains no signs of tarnishment.
	Light around it seems to dim and you can feel its tremoundous power simply by touching it.]],

	require = { stat = { mag=60 }, },
	combat = {
		dam = 30,
		apr = 4,
		atk = 20,
		dammod = {mag=1},
	},
	wielder = {
		combat_spellpower = 20,
		combat_spellcrit = 10,
	},

	max_power = 1000, power_regen = 1,
	use_power = { name = "absorb energies", power = 1000,
		use = function(self, who)
			game.logPlayer(who, "This power seems to much to wield, you fear it might absorb YOU.")
		end
	},

	on_pickup = function(self, who)
		if who == game.player then
			who:grantQuest("staff-absorption")
		end
	end,
	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}
