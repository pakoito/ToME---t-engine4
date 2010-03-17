-- Main quest: the Staff of Absorption
name = "A mysterious staff"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Deep in the tower of Tol Falas you fought and destroyed the Master, a powerful vampire."
	desc[#desc+1] = "In its remains you found a strange staff, it radiates power and danger and you dare not use it yourself."
	desc[#desc+1] = "You should bring it to the elders of Minas Tirith in the south east."
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	game.logPlayer(who, "#00FFFF#You can feel the power of this staff just by carrying it. This is both ancient and dangerous.")
	game.logPlayer(who, "#00FFFF#It should be shown to the wise elders in Minas Tirith!")
end
