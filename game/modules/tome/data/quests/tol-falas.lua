-- Quest for Tol Falas
name = "The Island of Dread"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You have heard that, far to the south of Bree, in the bay of Belfalas lies the ruined tower of Tol Falas."
	desc[#desc+1] = "There are disturbing rumors of greater undeads and nobody who got there ever returned."
	desc[#desc+1] = "You should explore it and find the truth, and the treasures, for yourself!"
	return table.concat(desc, "\n")
end
