quickEntity('<', {show_tooltip=true, name="exit to the wilds", 	display='<', color={r=0, g=255, b=255}})
defineTile('.', "GRASS")
defineTile('#', "TREE")
defineTile('u', "GRASS", nil, "UKRUK")
defineTile('o', "GRASS", nil, "HILL_ORC_WARRIOR")
defineTile('O', "GRASS", nil, "HILL_ORC_ARCHER")

startx = 0
starty = 0

return {
[[...........O...###]],
[[..............####]],
[[.....oo.......####]],
[[....ouo......#####]],
[[....oo.....O######]],
[[...........#######]],
[[O......O..<#######]],
[[......############]],
[[....##############]],
[[..################]],
[[##################]],
}
