newEffect{
	name = "CUT",
	desc = "Bleeding",
	type = "physical",
	status = "detrimental",
	parameters = { power=0 },
	on_gain = function(self, err) return "#Target# start to bleed.", "+Bleeds" end,
	on_lose = function(self, err) return "#Target# stop bleeding.", "-Bleeds" end,
	on_timeout = function(self, eff)
		self:takeHit(eff.power, self)
	end,
}
