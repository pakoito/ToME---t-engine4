return {
	online = {
		definition = {
			login = {position=1, type="varchar(40) NOT NULL"},
			pass = {position=2, type="varchar(40) NOT NULL"},
		},
		options = {
			autoload = "login", only_field = "pass", first_row = true,
		},
	},

	modules_played = {
		definition = {
			module = {position=1, type="varchar(40) NOT NULL"},
			times_ran = {position=2, type="bigint NOT NULL"},
		},
	},
}
