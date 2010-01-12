-- Character movements
defineAction{
	default = { "sym:276:false:false:false:false", "sym:260:false:false:false:false" },
	type = "MOVE_LEFT",
	group = "movement",
	name = "Move left",
}
defineAction{
	default = { "sym:275:false:false:false:false", "sym:262:false:false:false:false" },
	type = "MOVE_RIGHT",
	group = "movement",
	name = "Move right",
}
defineAction{
	default = { "sym:273:false:false:false:false", "sym:264:false:false:false:false" },
	type = "MOVE_UP",
	group = "movement",
	name = "Move up",
}
defineAction{
	default = { "sym:274:false:false:false:false", "sym:258:false:false:false:false" },
	type = "MOVE_DOWN",
	group = "movement",
	name = "Move down",
}
defineAction{
	default = { "sym:263:false:false:false:false" },
	type = "MOVE_LEFT_UP",
	group = "movement",
	name = "Move diagonaly left and up",
}
defineAction{
	default = { "sym:265:false:false:false:false" },
	type = "MOVE_RIGHT_UP",
	group = "movement",
	name = "Move diagonaly right and up",
}
defineAction{
	default = { "sym:257:false:false:false:false" },
	type = "MOVE_LEFT_DOWN",
	group = "movement",
	name = "Move diagonaly left and down",
}
defineAction{
	default = { "sym:259:false:false:false:false" },
	type = "MOVE_RIGHT_DOWN",
	group = "movement",
	name = "Move diagonaly right and down",
}

defineAction{
	default = { "sym:261:false:false:false:false" },
	type = "MOVE_STAY",
	group = "movement",
	name = "Stay for a turn",
}

-- Running
defineAction{
	default = { "sym:276:false:true:false:false", "sym:260:false:true:false:false" },
	type = "RUN_LEFT",
	group = "movement",
	name = "Run left",
}
defineAction{
	default = { "sym:275:false:true:false:false", "sym:262:false:true:false:false" },
	type = "RUN_RIGHT",
	group = "movement",
	name = "Run right",
}
defineAction{
	default = { "sym:273:false:true:false:false", "sym:264:false:true:false:false" },
	type = "RUN_UP",
	group = "movement",
	name = "Run up",
}
defineAction{
	default = { "sym:274:false:true:false:false", "sym:258:false:true:false:false" },
	type = "RUN_DOWN",
	group = "movement",
	name = "Run down",
}
defineAction{
	default = { "sym:263:false:true:false:false" },
	type = "RUN_LEFT_UP",
	group = "movement",
	name = "Run diagonaly left and up",
}
defineAction{
	default = { "sym:265:false:true:false:false" },
	type = "RUN_RIGHT_UP",
	group = "movement",
	name = "Run diagonaly right and up",
}
defineAction{
	default = { "sym:257:false:true:false:false" },
	type = "RUN_LEFT_DOWN",
	group = "movement",
	name = "Run diagonaly left and down",
}
defineAction{
	default = { "sym:259:false:true:false:false" },
	type = "RUN_RIGHT_DOWN",
	group = "movement",
	name = "Run diagonaly right and down",
}
