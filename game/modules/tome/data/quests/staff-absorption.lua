-- Main quest: the Staff of Absorption
name = "A mysterious staff"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Deep in the tower of Tol Falas you fought and destroyed the Master, a powerful vampie."
	desc[#desc+1] = "In its remains you found a strange staff, it radiates power and danger and you dare not sue it yourself."
	desc[#desc+1] = "You should bring it to the elders of Minas Tirith in the south east."
	return table.concat(desc, "\n")
end
