return {
	allow_build = {
		definition = {
			what = {position=1, type="varchar(40) NOT NULL", primary_key=true},
			allowed = {position=2, type="tinyint NOT NULL"},
		},
		options = {
			autoload = "what", only_field = "allowed",
		},
		statements =
		{
			setAllowBuild = [[REPLACE INTO allow_build VALUES (:what, 1)]],
		},
	},

	achievements = {
		definition = {
			id = {position=1, type="varchar(120) NOT NULL"},
			turn = {position=2, type="bigint NOT NULL"},
			date_gained = {position=3, type="datetime NOT NULL"},
			who = {position=4, type="varchar(200) NOT NULL"},
		},
		options = {
			autoload = "id",
		}
	},
}
