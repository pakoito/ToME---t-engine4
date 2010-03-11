quickEntity('<', {show_tooltip=true, name='into the wild', display='<', color=colors.WHITE, change_level=1, change_zone="wilderness"})
quickEntity('S', {name='brick roof top', display='#', color=colors.RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('s', {name='brick roof', display='#', color=colors.RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('t', {name='brick roof chimney', display='#', color=colors.LIGHT_RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('#', {name='wall', display='#', color=colors.WHITE, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('C', {name='dark pit', display='#', color=colors.LIGHT_DARK, block_move=true, block_sight=true})
quickEntity('T', {name='tree', display='#', color=colors.LIGHT_GREEN, block_move=true, block_sight=true, image="terrain/tree.png"})
quickEntity('V', {name='river', display='~', color=colors.BLUE, block_move=true, image="terrain/river.png"})
quickEntity('O', {name='cooblestone road', display='.', color=colors.WHITE, image="terrain/stone_road1.png"})
quickEntity(' ', {name='grass', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"})
quickEntity('-', {name='grass', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"})
quickEntity('^', {name='hills', display='^', color=colors.SLATE, image="terrain/mountain.png", block_move=true, block_sight=true})

quickEntity('1', {show_tooltip=true, name="Closed store", display='1', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('2', {show_tooltip=true, name="Armour Smith", display='2', color=colors.UMBER, resolvers.store("ARMOR"), image="terrain/wood_store_armor.png"})
quickEntity('3', {show_tooltip=true, name="Weapon Smith", display='3', color=colors.UMBER, resolvers.store("WEAPON"), image="terrain/wood_store_weapon.png"})
quickEntity('4', {show_tooltip=true, name="Alchemist", display='4', color=colors.LIGHT_BLUE, resolvers.store("POTION"), image="terrain/wood_store_potion.png"})
quickEntity('5', {show_tooltip=true, name="Scribe", display='5', color=colors.WHITE, resolvers.store("SCROLL"), image="terrain/wood_store_book.png"})
quickEntity('6', {show_tooltip=true, name="Closed store", display='6', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('7', {show_tooltip=true, name="Closed store", display='7', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('8', {show_tooltip=true, name="Closed store", display='8', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('9', {show_tooltip=true, name="Closed store", display='9', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('0', {show_tooltip=true, name="Closed store", display='0', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('a', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('b', {show_tooltip=true, name="Hall of the King", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('c', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('d', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('e', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})

quickEntity('E', {show_tooltip=true, name="The Elder", display='*', color=colors.VIOLET, resolvers.chatfeature("minas-tirith-elder"), image="terrain/wood_store_closed.png"})

startx = 95
starty = 45

return {
[[################################################################################################]],
[[#^^########------------------                                                                   ]],
[[#^^^------############----------             ^                                                  ]],
[[#^^^----------###----#######-------         ^^^^^                                               ]],
[[#^^----ssss-----###--------####------        ^^^^^^                                             ]],
[[#^^^---StSS-------###--#ssss--###-------      ^^^^^^^^                                          ]],
[[#^^----ssss----OO---##--#StSS---####------     ^^^^^^^^                                         ]],
[[#^^----x#a#-----OOO--##--#sssss----###------    ^^^^^^^^                                        ]],
[[#^ ---------------OO--###-#m#7#------###-----   ^^^^^^^^^^                                      ]],
[[#^ StSSSS-----ss---OO---##-----OOOOO---###----   ^^^^^^^^^^^                                    ]],
[[#^^ssssss----Ssss---OOO--##---OOOOOOOO---##----   ^l^^^^^^^                                     ]],
[[#^ ####9#---sstSss---OOO--##-OOOOOOOOOOO--##----    ^^^^^                                       ]],
[[#^^^-------##sssSss---OOO--#OOO--s--OOOOO--###---                                               ]],
[[#^^^######---##ssh--s--OOO-OOO--StS--OOOOO---##---                                              ]],
[[#^^^^----###---##--ssS--OOOOO#--ssss--OOOOOO--##---                                             ]],
[[#^^--------###----ssSs#--OOO-##-#####--OOOOOO--##---            ----                            ]],
[[#^ ----------##--#stsi--OOOO--#---------OOOOOO--#------       --------                          ]],
[[#^^-----------###-#s#--OOOOOO-##-#sssss--OOOOOO,#####---     -----------                        ]],
[[#^^-------------##-#--OOO-OOO--#--ssssss--OOOOO,,,,,#----  ---ssssssss---                       ]],
[[#^^--------------#---OOO-t-OOO-##-#SStSS--OOOOOO,##,#---------ssssssss----                      ]],
[[#^^^--#----------##-OOO-sssOOO--#--ssssss-OOOOOO--#,#####-----SStSSSSS-----                     ]],
[[#^^^--#-----------#OOO-##4##OOO-##-ssssss--OOOOOO-#,,######---ssssssss--O---                    ]],
[[#^^--###----------OOO-------OOO--#-####2#--OOOOOO-##,#k#,,##--ssssssss--O----                   ]],
[[#^^^-###---------OOO#--SSStS-OOO-#---------OOOOO---#,,,,,,,#--ssssssss--O-----                  ]],
[[#^^-#####-------OOO-#--sssss-OOO-#--ssss--OOOOO--T-#,-----,#--#####d##--O------                 ]],
[[#^^#######------OOO-##-###j#-OOO-##-ssss--OOOOO-TT-#------,#-------,,,,,O------                 ]],
[[#^^^########----OOO--#-------OOO--#-StSS--OOOOO-TT-#-----,,#------------O-------                ]],
[[#^^############-OOO--##-StSSS-OOO-#-ssss--OOOOO--T-#----,,##---ssssssss-O--------               ]],
[[#^^^#########---OOO---#-sssss-OOO-#-ssss--OOOOOO---#,,,,,##----SSSSStSS-O---------              ]],
[[#^^#####B###----OOO---#-###6#-OOO-#-##g#---OOOOOO--#######-----ssssssss-O----------             ]],
[[#^^^#######-----OOO---#-------OOO-#---------OOOOOOOOOOOOOOOOO--###e####-O-----------            ]],
[[#^^#######bOOOOOOOO-^^^^^^^^^^MMM^^^^^^^^^^^^OOOOOOOOOOOOOOOOOOOOOOOOOOOO-----------            ]],
[[#^^#######bOOOOOOO############III############^OOOOOOOOOOOOOOOOOOOOOOOOOOOOO---------            ]],
[[#^ #######bOOOOOOO############III############^OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO---------           ]],
[[#^ #######bOOOOOOOO-^^^^^^^^^^MMM^^^^^^^^^^^^OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO-------           ]],
[[#^^^#######-----OOO---#-sSss--OOO-#---------OOOOOOOOOOOOOOOOO-----------OOOOOOO------           ]],
[[#^^#########----OOO---#-sSss--OOO-#-sssss--OOOOOO--#######--------sssss-O-OOOOO-----            ]],
[[#^^#########E---OOO---#-stss--OOO-#-SStSS-OOOOOO---####,,##-------SStSS-O-OOOOO----             ]],
[[#^^############-OOO--##-sSss--OOO-#-sssss-OOOOO--T-##k#,,,##------sssss-O--OOOOO---             ]],
[[#^^#########----OOO--#--####-OOO--#-sssss-OOOOO-TT-#,,,,-,,#------sssss-O---OOOO---             ]],
[[#^^#######------OOO-##-------OOO-##-###3#-OOOOO-TT-#,-----,#------###0#-O---OOOOO---            ]],
[[#^^-#####-------OOO-#--Ssss--OOO-#--------OOOOO--T-#,-----,#------------O----OOOO----           ]],
[[#^^^-###---------OOO#-#stss--OOO-#-ssssss--OOOOO---#,----,,#----ssssss--O-----OOOO----        --]],
[[#^^--###----------OOO--#sSs-OOO--#-StSSSS--OOOOOO-##,-,,,,##----SStSSS--O------OOOO----      --O]],
[[#^^---#-----------#OOO--###-OOO-##-ssssss--OOOOOO-#,,,,####-----ssssss--O-------OOOO----    --OO]],
[[#^^^--#----------##-OOO----OOO--#--###5##-OOOOOO--#,#####-------ssssss-OO--------OOOO--------OO<]],
[[#^^^-------------#---OOO---OOO-##---------OOOOOO,##,#-----------####1#-O----------OOOO----OOOOOO]],
[[#^^-------------##----OOO-OOO--#--ss------OOOOO,,,,,#------------------O-----------OOOOOOOOOOO--]],
[[#^^^----------###--ss--OOOOOO-##-ssSs----OOOOOO,#####------------------O-------- ---OOOOOOOOO---]],
[[#^^^---------##---ssSs--OOOO--#--ssts#--OOOOOO--#------ ------ssssss--OO------    ---OOOOO----- ]],
[[#^^--------###---sstss#--OOO-##-ssSs#--OOOOOO--##-----    ----StSSSS--O------      -----------  ]],
[[#^^------###-----#Sss#--OOOOO#--sSsf--OOOOOO--##-----      ---ssssss--O-----        -------     ]],
[[#^^^######---ss---#s#--OOO-OOO--Ss#--OOOOO---##-----        --###w##-OO-----                    ]],
[[#^^^-------ssssS---#--OOO--#OOO--#--OOOOO--###-----          --------O-----                     ]],
[[#^^-sssss-#ssstss----OOO--##-OOO---OOOOO--##------            ------OO----                      ]],
[[#^^-SSStS--#sSsss#--OOO--##---OOOOOOOO---##------               ----O----                       ]],
[[#^^-sssss---#ss##--OO---##--X--OOOOO---###------                ---O---                         ]],
[[#^^^#####----##---OO--###--XXX-OOO---###------                    ---                           ]],
[[#^^^------------OOO--##---XXX#-----###-----                                                     ]],
[[#^^--SStSS-----OO---##--XX###---####-----                                                       ]],
[[#^^^-sssss--------###--###----###------                                                         ]],
[[#^^--#####------###--------####------                                                           ]],
[[#^^^----------###----#######------                                                              ]],
[[#^^^------############----------                                                                ]],
[[#^^########-----------------                                                                    ]],
[[################################################################################################]],
}