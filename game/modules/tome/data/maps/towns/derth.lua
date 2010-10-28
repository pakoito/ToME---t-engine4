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

quickEntity('<', {show_tooltip=true, name='into the wild', display='<', color=colors.WHITE, change_level=1, change_zone="wilderness"})
quickEntity('S', {name='brick roof top', display='#', color=colors.RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('s', {name='brick roof', display='#', color=colors.RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('t', {name='brick roof chimney', display='#', color=colors.LIGHT_RED, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('#', {name='wall', display='#', color=colors.WHITE, block_move=true, block_sight=true, image="terrain/wood_wall1.png"})
quickEntity('C', {name='dark pit', display='#', color=colors.LIGHT_DARK, block_move=true, block_sight=true})
quickEntity('T', {name='tree', display='#', color=colors.LIGHT_GREEN, block_move=true, block_sight=true, image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/tree_alpha1.png"}}})
quickEntity(' ', {name='forest', display='#', color=colors.GREEN, block_move=true, block_sight=true, image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/tree_alpha1.png"}}})
quickEntity('V', {name='river', display='~', color=colors.BLUE, block_move=true, image="terrain/river.png"})
quickEntity('O', {name='cobblestone road', display='.', color=colors.WHITE, image="terrain/stone_road1.png"})
quickEntity('.', {name='road', display='.', color=colors.WHITE, image="terrain/stone_road1.png"})
quickEntity(',', {name='dirt', display='.', color=colors.LIGHT_UMBER, image="terrain/sand.png"})
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
quickEntity('9', {show_tooltip=true, name="Gem Store", display='9', color=colors.BLUE, resolvers.store("GEMSTORE"), image="terrain/wood_store_gem.png"})
quickEntity('0', {show_tooltip=true, name="Closed store", display='0', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('a', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('b', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('c', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('d', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})
quickEntity('e', {show_tooltip=true, name="Closed store", display='*', color=colors.LIGHT_UMBER, block_move=true, block_sight=true, image="terrain/wood_store_closed.png"})

startx = 76
starty = 36

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
[[  OOOOOOOOSt.---------ssss-OOOO--OOOO---.-StS--,#0##,-ssss---,---.---^^     ^]],
[[   ,,-T--.ss.-sssss---ssss,---------OOOO.-sss---,,,,,-####--,---..-T^^   ^ ^ ]],
[[   ,,-T--.##.-SStSS---####,------------OO-###-ssssss-,,,---,----.--T^^   ^   ]],
[[   ,,-TT-....-sssss--,,,,,,-------------OO-,--SSSSSt-ss-,-,---...-T^^  ^ ^   ]],
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
