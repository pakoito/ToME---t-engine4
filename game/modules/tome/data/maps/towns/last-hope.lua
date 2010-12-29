-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

quickEntity('<', {show_tooltip=true, name='into the wild', notice=true, display='<', color=colors.WHITE, change_level=1, change_zone="wilderness", image="terrain/stone_road1.png", add_displays = {mod.class.Grid.new{image="terrain/worldmap.png"}}})
quickEntity('S', {name='brick roof top', display='#', color=colors.RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('s', {name='brick roof', display='#', color=colors.RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('t', {name='brick roof chimney', display='#', color=colors.LIGHT_RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('C', {name='dark pit', display='#', color=colors.LIGHT_DARK, block_move=true, block_sight=true})
quickEntity('T', {name='tree', display='#', color=colors.LIGHT_GREEN, block_move=true, block_sight=true, image="terrain/tree.png"})
quickEntity('V', {name='river', display='~', color=colors.BLUE, block_move=true, image="terrain/river.png"})
quickEntity('O', {name='cobblestone road', display='.', color=colors.WHITE, image="terrain/stone_road1.png"})
quickEntity(' ', {name='grass', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"})
quickEntity('-', {name='grass', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"})
quickEntity('#', {name='wall', display='#', color=colors.WHITE, block_move=true, block_sight=true, image="terrain/granite_wall1.png"})
quickEntity('*', {name="Tannen's Tower", display='#', color=colors.WHITE, block_move=true, block_sight=true, image="terrain/granite_wall1.png"})
quickEntity('^', {name='hills', display='^', color=colors.SLATE, image="terrain/mountain.png", block_move=true, block_sight=true})
quickEntity(',', {name='dirt', display='.', color=colors.LIGHT_UMBER, image="terrain/sand.png"})
quickEntity('I', {name='tunneled wall', show_tooltip=true, display='#', color=colors.WHITE, image="terrain/wood_wall1.png"})
quickEntity('M', {name='tunneled hills', show_tooltip=true, display='^', color=colors.SLATE, image="terrain/mountain.png"})

quickEntity('1', {show_tooltip=true, name="Closed store", display='1', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('2', {show_tooltip=true, name="Armour Smith", display='2', color=colors.UMBER, resolvers.store("ARMOR"), image="terrain/wood_store_armor.png"})
quickEntity('3', {show_tooltip=true, name="Weapon Smith", display='3', color=colors.UMBER, resolvers.store("WEAPON"), resolvers.chatfeature("last-hope-weapon-store"), image="terrain/wood_store_weapon.png"})
quickEntity('4', {show_tooltip=true, name="Alchemist", display='4', color=colors.LIGHT_BLUE, resolvers.store("POTION"), image="terrain/wood_store_potion.png"})
quickEntity('5', {show_tooltip=true, name="Scribe", display='5', color=colors.WHITE, resolvers.store("SCROLL"), resolvers.chatfeature("magic-store"), image="terrain/wood_store_book.png"})
quickEntity('6', {show_tooltip=true, name="Closed store", display='6', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('7', {show_tooltip=true, name="Closed store", display='7', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('8', {show_tooltip=true, name="Closed store", display='8', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('9', {show_tooltip=true, name="Closed store", display='9', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('0', {show_tooltip=true, name="Closed store", display='0', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('a', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('b', {show_tooltip=true, name="Hall of the King", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('c', {show_tooltip=true, name="Library", display='*', color=colors.LIGHT_RED, resolvers.store("LAST_HOPE_LIBRARY"), image="terrain/wood_store_book.png"})
quickEntity('d', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('e', {show_tooltip=true, name="Rare goods", display='*', color=colors.AQUAMARINE, resolvers.store("LOST_MERCHANT"), resolvers.chatfeature("last-hope-lost-merchant"), image="terrain/wood_store_weapon.png"})
quickEntity('g', {show_tooltip=true, name="Rich merchant", display='*', color=colors.AQUAMARINE, resolvers.chatfeature("last-hope-melinda-father"), image="terrain/wood_store_closed.png"})

quickEntity('E', {show_tooltip=true, name="The Elder", display='*', color=colors.VIOLET, resolvers.chatfeature("last-hope-elder"), image="terrain/wood_store_closed.png"})
quickEntity('f', {show_tooltip=true, name="Tannen's Tower", display='*', color=colors.VIOLET, resolvers.chatfeature("tannen"), image="terrain/wood_store_closed.png"})

quickEntity('@', {show_tooltip=true, name="Statue of King Tolak the Fair", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statue1.png"}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then e:learnLore("last-hope-tolak-statue") end return true end})
quickEntity('Z', {show_tooltip=true, name="Statue of King Toknor the Brave", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statue1.png"}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then e:learnLore("last-hope-toknor-statue") end return true end})
quickEntity('Y', {show_tooltip=true, name="Statue of Queen Mirvenia the Inspirer", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statue1.png"}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then e:learnLore("last-hope-mirvenia-statue") end return true end})

startx = 95
starty = 45

return {
[[################################################################################################]],
[[#^^########------------------                                                                   ]],
[[#^^^------############----------             ^                                                  ]],
[[#^^^----------###----#######-------         ^^^^^                                               ]],
[[#^^-----**------###--------####------        ^^^^^^                                             ]],
[[#^^^---****-------###--#ssss--###-------      ^^^^^^^^                                          ]],
[[#^^----***f----OO---##--#StSS---####------     ^^^^^^^^                                         ]],
[[#^^-----**------OOO--##--#sssss----###------    ^^^^^^^^                                        ]],
[[#^ ---------------OO--###-###7#------###-----   ^^^^^^^^^^                                      ]],
[[#^ StSSSS-----ss---OO---##-----OOOOO---###----   ^^^^^^^^^^^                                    ]],
[[#^^ssssss----Ssss---OOO--##---OOOOOOOO---##----   ^^^^^^^^^                                     ]],
[[#^ ####9#---sstSss---OOO--##-OOOOOOOOOOO--##----    ^^^^^                                       ]],
[[#^^^-------##sssSss---OOO--#OOO--s--OOOOO--###---                                               ]],
[[#^^^######---##sss--s--OOO-OOO--StS--OOOOO---##---                                              ]],
[[#^^^^----###---##--ssS--OOOOO#--ssss--OOOOOO--##---                                             ]],
[[#^^--------###----ssSs#--OOO-##-##g##--OOOOOO--##---            ----                            ]],
[[#^ ----------##--#sts#--OOOO--#---------OOOOOO--#------       --------                          ]],
[[#^^-----------###-#sc--OOOOOO-##-#sssss--OOOOOO,#####---     -----------                        ]],
[[#^^-------------##-#--OOO-OOO--#--ssssss--OOOOO,,,,,#----  ---ssssssss---                       ]],
[[#^^--------------#---OOO-t-OOO-##-#SStSS--OOOOOO,##,#---------ssssssss----                      ]],
[[#^^^--#----------##-OOO-sssOOO--#--ssssss-OOOOOO--#,#####-----SStSSSSS-----                     ]],
[[#^^^--#-----------#OOO-##4##OOO-##-ssssss--OOOOOO-#,,######---ssssssss--O---                    ]],
[[#^^--###----------OOO-------OOO--#-####2#--OOOOOO-##,###,,##--ssssssss--O----                   ]],
[[#^^^-###---------OOO#--SSStS-OOO-#---------OOOOO---#,,,,,,,#--ssssssss--O-----                  ]],
[[#^^-#####-------OOO-#--sssss-OOO-#--ssss--OOOOO--T-#,-----,#--#####d##--O------                 ]],
[[#^^#######------OOO-##-#####-OOO-##-ssss--OOOOO-TT-#------,#-------,,,,,O------                 ]],
[[#^^^########----OOO--#-------OOO--#-StSS--OOOOO-TT-#-----,,#------------O-------                ]],
[[#^^############-OOO--##-StSSS-OOO-#-ssss--OOOOO--T-#----,,##---ssssssss-O--------               ]],
[[#^^^#########---OOO---#-sssss-OOO-#-ssss--OOOOOO---#,,,,,##----SSSSStSS-O---------              ]],
[[#^^#########----OOO---#-###6#-OOO-#-##e#---OOOOOO--#######-----ssssssss-O----------             ]],
[[#^^^#######---@-OOO---#-------OOO-#---------OOOOOOOOOOOOOOOOO--########-O-----------            ]],
[[#^^#######bOOOOOOOO-^^^^^^^^^^MMM^^^^^^^^^^^^OOOOOOOOOOOOOOOOOOOOOOOOOOOO-----------            ]],
[[#^^#######bOOOOOOO############III############^OOOOOOOOOOOOOOOOOOOOOOOOOOOOO---------            ]],
[[#^ #######bOOOOOOO############III############^OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO---------           ]],
[[#^ #######bOOOOOOOO-^^^^^^^^^^MMM^^^^^^^^^^^^OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO-------           ]],
[[#^^^#######--ZY-OOO---#-sSss--OOO-#---------OOOOOOOOOOOOOOOOO-----------OOOOOOO------           ]],
[[#^^#########----OOO---#-sSss--OOO-#-sssss--OOOOOO--#######--------sssss-O-OOOOO-----            ]],
[[#^^#########E---OOO---#-stss--OOO-#-SStSS-OOOOOO---####,,##-------SStSS-O-OOOOO----             ]],
[[#^^############-OOO--##-sSss--OOO-#-sssss-OOOOO--T-####,,,##------sssss-O--OOOOO---             ]],
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
[[#^^------###-----#Sss#--OOOOO#--sSs#--OOOOOO--##-----      ---ssssss--O-----        -------     ]],
[[#^^^######---ss---#s#--OOO-OOO--Ss#--OOOOO---##-----        --######-OO-----                    ]],
[[#^^^-------ssssS---#--OOO--#OOO--#--OOOOO--###-----          --------O-----                     ]],
[[#^^-sssss-#ssstss----OOO--##-OOO---OOOOO--##------            ------OO----                      ]],
[[#^^-SSStS--#sSsss#--OOO--##---OOOOOOOO---##------               ----O----                       ]],
[[#^^-sssss---#ss##--OO---##--#--OOOOO---###------                ---O---                         ]],
[[#^^^#####----##---OO--###--###-OOO---###------                    ---                           ]],
[[#^^^------------OOO--##---####-----###-----                                                     ]],
[[#^^--SStSS-----OO---##--#####---####-----                                                       ]],
[[#^^^-sssss--------###--###----###------                                                         ]],
[[#^^--#####------###--------####------                                                           ]],
[[#^^^----------###----#######------                                                              ]],
[[#^^^------############----------                                                                ]],
[[#^^########-----------------                                                                    ]],
[[################################################################################################]],
}
