defineAction{
	default = { "uni:<", "uni:>" },
	type = "CHANGE_LEVEL",
	group = "actions",
	name = "Go to next/previous level",
}

defineAction{
	default = { "uni:G" },
	type = "LEVELUP",
	group = "actions",
	name = "Levelup window",
}
defineAction{
	default = { "uni:m" },
	type = "USE_TALENTS",
	group = "actions",
	name = "Use talents",
}

defineAction{
	default = { "uni:R" },
	type = "REST",
	group = "actions",
	name = "Rest for a while",
}

defineAction{
	default = { "sym:115:true:false:false:false" },
	type = "SAVE_GAME",
	group = "actions",
	name = "Save game",
}

defineAction{
	default = { "sym:120:true:false:false:false" },
	type = "QUIT_GAME",
	group = "actions",
	name = "Quit game",
}

defineAction{
	default = { "sym:116:true:false:false:false" },
	type = "SHOW_TIME",
	group = "actions",
	name = "Show game calendar",
}

defineAction{
	default = { "sym:115:false:false:true:false" },
	type = "SWITCH_GFX",
	group = "actions",
	name = "Switch graphical modes",
}
