quickEntity('M', {name='misty mountains', display='^', color=colors.UMBER, block_move=true})
quickEntity('W', {name='weather hills', display='^', color=colors.UMBER, block_move=true})
quickEntity('t', {name='Trallshaws', display='#', color=colors.LIGHT_GREEN, block_move=true})
quickEntity('.', {name='plains', display='.', color=colors.LIGHT_GREEN})
quickEntity('&', {name='Ettenmoors', display='^', color=colors.LIGHT_UMBER})
quickEntity('_', {name='river', display='~', color={r=0, g=80, b=255}})

quickEntity('*', {name="Dunadan's Outpost", display='*', color={r=255, g=255, b=255}})
quickEntity('1', {name="Caves below the tower of Amon Sûl", display='>', color={r=0, g=255, b=255}, change_level=1, change_zone="tower-amon-sul"})
quickEntity('2', {name="Ettenmoors's cavern", display='>', color={r=80, g=255, b=255}})
quickEntity('3', {name="Passageway into the Trollshaws", display='>', color={r=0, g=255, b=0}, change_level=1, change_zone="trollshaws"})

return {
[[W..........&&.....MM.]],
[[WW..........&&.....MM]],
[[WW...........2&&&...M]],
[[WW..............&&..M]],
[[WW1......*_________MM]],
[[WW.....___.........MM]],
[[W....._............MM]],
[[.....__..tt3t......MM]],
[[....__.ttttttt....MM.]],
[[...._....tttt....MMM.]],
}
