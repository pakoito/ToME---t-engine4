quickEntity('<', {name='into the wild', display='<', color=colors.WHITE, change_level=1, change_zone="wilderness"})
quickEntity('S', {name='brick roof top', display='#', color=colors.RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('s', {name='brick roof', display='#', color=colors.RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('t', {name='brick roof chimney', display='#', color=colors.LIGHT_RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('#', {name='wall', display='#', color=colors.WHITE, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('C', {name='dark pit', display='#', color=colors.LIGHT_DARK, block_move=true, block_sight=true})
quickEntity('T', {name='tree', display='#', color=colors.LIGHT_GREEN, block_move=true, block_sight=true, image="terrain/tree.png"})
quickEntity(' ', {name='forest', display='#', color=colors.GREEN, block_move=true, block_sight=true, image="terrain/tree.png"})
quickEntity('V', {name='river', display='~', color=colors.BLUE, block_move=true, image="terrain/river.png"})
quickEntity('O', {name='cooblestone road', display='.', color=colors.WHITE, image="terrain/stone_road1.png"})
quickEntity('.', {name='road', display='.', color=colors.WHITE, image="terrain/stone_road1.png"})
quickEntity(',', {name='dirt', display='.', color=colors.LIGHT_UMBER, image="terrain/sand.png"})
quickEntity('-', {name='grass', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"})
quickEntity('^', {name='hills', display='^', color=colors.SLATE, image="terrain/mountain.png", block_move=true})

quickEntity('4', {name="Alchemist", display='4', color=colors.LIGHT_BLUE, resolvers.store("POTION"), image="terrain/wood_store_potion.png"})
quickEntity('5', {name="Scribe", display='5', color=colors.WHITE, resolvers.store("SCROLL"), image="terrain/wood_store_book.png"})

startx = 31
starty = 13

return {
[[                                                                             ]],
[[                             ,,,,,,,,,,,,,,,,,,                              ]],
[[                        ,,,,,------------------,,,,,,,,,                     ]],
[[                     ,,,------TTTTTTTTTTTTTTTT----------,,,,                 ]],
[[                   ,,----TTTTTT--------------TTTTTTTTTT-----,,,,,            ]],
[[                 ,,---TTTT..................----------TTTTT------,,          ]],
[[                ,---TTT....--ssssssss-..---..........-----TTTTTT---,,,       ]],
[[               ,--TTT...-----SSSSSSSS--.----------,,.....------TTT----,,     ]],
[[             ,,--TT...-,,,,--ssssssss-..-sssssssssss,---......---TTTT--T,,   ]],
[[           ,,---TT..-------,,##9#####-.--sssssssssss-,-------...----TT--TT,  ]],
[[          ,---  T..--sssSsss,,,,------.--StSStSSSStS--,------.-....--TT--TT,^]],
[[         ,--TTT...---ssstSSS---,,,----.--sssssssssss---,---...----..--TT--T^^]],
[[        ,--TT...-----sssssss--,,-,,---.--sssssssssss---,-...-------..--TT-^^^]],
[[        ,-TT..---,,,,###6###,,,---,,--.--###########----..----------..--T^^^^]],
[[        ,-T..,,,,----,,,,,,,,------,,-.--###b###e###-....,---sssss---.--T^^  ]],
[[       ,--T.,sssssss----,-----------,,.-----.-----....-,--,,-StSSS---.-T^^^  ]],
[[      ,--TT.-StStSSS---,-----ssssss--..-----.--....--,,,,,,-,sssss---.-T^^^  ]],
[[      ,-TT-.-sssssss---,-----SSSSSS--.------.-..--,,,-ssss--,#####---.-T^^   ]],
[[     ,--T-..-##5####----,----ssssss-..........--ssss,-ssss--,------...-^^^  ^]],
[[     ,-  OOOO--OOOOO----,----#c##4#-.---.,----,-SStS,-SSSS--,-----..---^^   ^]],
[[<OO  ,-T-OssOOOO---OOOOOOOOO--OOOO--.-T-.-sss--,ssss,-ssss---,---..--T^^     ]],
[[  OOOOOOOOSt.---------XXXX-OOOO--OOOO---.-StS--,#0##,-ssss---,---.---^^     ^]],
[[   ,,-T--.ss.-sssss---XXXX,---------OOOO.-sss---,,,,,-####--,---..-T^^   ^ ^ ]],
[[   ,,-T--.##.-SStSS---####,------------OO-#>#-ssssss-,,,---,----.--T^^   ^   ]],
[[   ,,-TT-....-sssss--,,,,,,----------F--OO-,--SSSSSt-ss-,-,---...-T^^  ^ ^   ]],
[[   ,,--TT---..#2###-,sssss,-SSSSSSSS-----OO,--ssssss-tS--,.....---^^ ^^     ^]],
[[    ,,--T----..,,,,,-StSSS,-ssssssss------OOO-#1##a#-ss....-----T^^        ^^]],
[[    ,,--TT----..----,sssss,-##7#####--------OO,.,,.,-##.----TTTT^^     ^  ^^ ]],
[[    ,,,--TTTT--..---,##3##-,--,.,---------...OOOOOOOOOOOTTTTT--^^^   ^^  ^^  ]],
[[     ,,,----  --..........,-,,---,--.......-------TTTTTO-----,,^^^^^^^^^^^   ]],
[[     ,, ,,---TT----------.....-......-------TTTTTTT----O,,,,,     ^^^^^^^    ]],
[[     ,,   ,,--TTTTTTTTTT-----...------TTTTTTT------,,,,OOO                   ]],
[[     ,,,    ,----------TTTTT-----TTTTTT------,,,,,,      OOO                 ]],
[[      ,,     ,,,,,,,,,,-----TTTTTT-----,,,,,,              OO                ]],
[[      ,,,              ,,,,,------,,,,,                     OOOO             ]],
[[       ,,                   ,,,,,,                             OOOOOOO       ]],
[[                                                                     OOOOOOO<]],
}
