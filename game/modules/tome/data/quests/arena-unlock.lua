name = "The agent of the arena"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You were asked to prove your worth as a fighter by a rogue, in order to participate in the arena"
	if self:isCompleted() then
		desc[#desc+1] = "You succesfully defeated your adversaries and gained access to the arena!"
	end
	return table.concat(desc, "\n")
end
