defineTile('1', 'TOWN_BREE')
defineTile('a', 'DUN_ANCIENT_RUINS')

quickEntity('B', {name='blue mountains', display='^', color=colors.LIGHT_BLUE, block_move=true})
quickEntity('M', {name='misty mountains', display='^', color=colors.UMBER, block_move=true})
quickEntity('G', {name='grey mountains', display='^', color=colors.SLATE, block_move=true})
quickEntity('T', {name='deep forest', display='#', color=colors.GREEN, block_move=true})
quickEntity('t', {name='forest', display='#', color=colors.LIGHT_GREEN, block_move=true})
quickEntity('I', {name='iron mountains', display='^', color=colors.SLATE, block_move=true})
quickEntity('=', {name='the great sea', display='~', color=colors.BLUE, block_move=true})
quickEntity('.', {name='plains', display='.', color=colors.LIGHT_GREEN})
quickEntity('g', {name='Forodwaith, the cold lands', display='.', color=colors.LIGHT_BLUE})
quickEntity('w', {name='ash', display='.', color=colors.WHITE})
quickEntity('h', {name='low hills', display='^', color=colors.GREEN})
quickEntity(' ', {name='sea of Rhun', display='~', color=colors.BLUE, block_move=true})
quickEntity('_', {name='river', display='~', color={r=0, g=80, b=255}, block_move=true})
quickEntity('~', {name='Anduin river', display='~', color={r=0, g=30, b=255}, block_move=true})

return {
[[========q=qqqqqqqqqgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg]],
[[=========q=qq=qqqqggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg]],
[[==========qq=q=qqqqgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg]],
[[==============qqq=qqggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg]],
[[===============q=q=q=gwwwwgggwwwwwgggggggggwwwwwwwwwwggggwwwwwwwwwwwwwggggwwwwwwwwggggwwwwwwwwwgggg]],
[[====================qwwwwwwwwwwwwwwwwggggggggwwwwwwwwwwwwwwwwwwwwwwwwwwggwwwwwwwwwwwwwwwwwwwwwwTTTT]],
[[======================wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww.TTTTTTTT]],
[[========================wwwwwwww...wwwwwwwwww..........wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww.TTTTTTTTTTT]],
[[========================..www....wwwwwwww................wwwwGGGGwwwwwwww......wwwww.TTTTTTTTTTTTTT]],
[[==========.......======.........hhhh..................GGGGGGGwwwDwwww.........wwww.TtTTTTtTTTTTTtTT]],
[[========......BB..===.........hhhhhhhh..&&&&&...&..GGGGGGGGGGGGG.................tTTTtTtTTtTttTTTTt]],
[[=======......BB..===............hhhh.......&&&&&&GG.._._...........................tttttttttttttttt]],
[[======...._.BB._..._............................M....._._TTT................II........ttttttttttttt]],
[[=======.._..BB.._.._..hhhh................&....&MM~~~~.TT_TTTT..........I.....III........tttttt^^^^]],
[[======.._...BB..._._..hhh.......hhhhhh.....&&&&._MM..~.TTT_T_TT..^l......IIIIII..............ttt^^^]],
[[=====.._..TBBB...._._..h.=....hhh|hh..........__.MM__~.TTTT_h_TT.l8........_.....................^^]],
[[===...._....BB....._..hh.=_....h.|..........__...MM..~.TTTTTT_TT.=........_........................]],
[[====.._...BBBB...._....hhhh__....|.....a..._.....MM..~.TTTTTT____........._........................]],
[[=====.._..TTBB..._........._.....|h......._.tt...MM..~6TTTTT&&&T._........._.......................]],
[[====...__..TBBB._......hh.._.....|.hh...._.t^^^._MM..~..TTT&G&&&T._........._......................]],
[[=====..._.....__......hho+-_.2---x1hh-------_L...MM---------------_........_.......................]],
[[======..==..=__....h....h|.._.hh.|ih....._..^^^._M...~..TTTTTTTTTT._........_......................]],
[[=============.....hhh....|.._.ttt|h......_.._.._MMM...~..TTTTTTTTT.._........_....................t]],
[[======........BB...h.....|..._ttt|hh...._.._...MM.....~..TTTTTTTT...._......_....................tt]],
[[=====.........BB.........[---_.t.|.h...._._..MMMMM.s._~..TTTTTTTT....._......_..................ttt]],
[[=====.........BB............._[--|....._.._..MMMM___s.~~.TTTTTTTT......_.._._..................tttt]],
[[======........BB....B......._....|....._._...MMMM.....~~.TTTTT.T........._.._.................ttttt]],
[[=======.....TBBB..BBBB....._.....|....._....MMMMM....~~...TTTT.............._...............ttttttt]],
[[==========..TBBBT........._......|...._.....MMMM.....~~...TTTT..............._...._.......ttttttttt]],
[[==========..TTTBBTBB....._.......|ss__.....hMMMM....~~....TTTTTTT............._.__._ ...ttttttttttt]],
[[==========...TTBTT......_........___ss_....MMMMM....~~..TTTTTTTTTT............._....  ...t  ttttttt]],
[[==========.....T.T....._........_.....______MM___...~~.TTTTTTTTTT...................        ttttttt]],
[[===========.=........._........_...........MMMM_!.!~~..TT&TTTTTTT..................         ttttttt]],
[[================....__........_..ttt......MMMM._!4!~~..TTTTTTTTT...................         ...tttt]],
[[=================.==t........_....tt.....ttMMM..!!!~.....TTTTT..................^^.        ......tt]],
[[===================tt........._.........ttMMM.......~~.........................^^^^.       .......t]],
[[===================t==......._..........ttMMMttttt._..~~~~~~....................^^^.  ...  .......t]],
[[===================t==......_...........t&MMMMtttt_s_.....~~~..................^^^^^. ... ........t]],
[[=====================......_.ttt........t&MMMtttttt..__s~~~~...................^^^^^^.............t]],
[[=====================.....=_.tt.........&&MMMttttt.....~...........................^^.............t]],
[[======================...==..ttt........&&_&&&.._.......~~........................................t]],
[[=======================.===..............^_^....._........~.......................................t]],
[[===========================..............._........_.....~........................................t]],
[[==========================.tt......._._.._........_....h=hh...SSS.................................t]],
[[==========================.tt._.._t_...__.........._..h===h.SSSS.................................tt]],
[[==========================..__.__._._._..&&&b....._....h=hh..SS.A.A.............................ttt]],
[[============================....._..._.__.&&&......_....~~.....AAkAAA..A..AA..A..A..AA...A.....tttt]],
[[===========================.............._&&&^^....._....~~s...DDvvAAAAAAAAAAAAAAAAAAAAAAAAAAAAJttt]],
[[===========================.......^.&.^^&&&&&&&......__.~~sss...DDVVVVVVVAVVVAVAA_"""_""""""..AAAtt]],
[[===========================.....^^.&.&_&^&.&^&_&&&9...._..~~ss..DDVVUVVVVVVVVVVA_"""""_""""""...AAt]],
[[===========================....^....__^^...^^^._^&&........~~.c.DDVVUUVVVVVVVAA_"""""""_"""".....AA]],
[[===========================..^^^_.._.......^^._.^^&&&........~~.DDVVVVVVVVVVAA""_""""""_"""""""....]],
[[============================.^t_.__._........_&^^^.&&&&&......e.DDVAAVAAAVVV"""""_""""_""""""".....]],
[[============================.t^_..._....hh.._&&&^^.._&&&&.&...~.DDD""A"A""""""""=="""_""""""""""...]],
[[============================.t^._.hhhhhhhh...__...._^&^&&&&&.~..DD""""""""""""======_"""""""""""AAA]],
[[===========================.^^._...h.h........._.._.^&^^._^3.~..DD"""_"_"""""=====""""""""""""AAAdd]],
[[==========================..^^.._.....===.=====_._&^...._...^.~.DD"__"_"__======"""""AA""""AAAAdddd]],
[[==========================.h...._...===========_&&^...._._...~~.DD_""""""""""""_""A"AAAAAAAAddddddd]],
[[========================.hhh=...=_.==========&^^^^.._._..._.~~..DDD""DDD""D"""DD_DDAAdddddddddddddd]],
[[======================....=====.==============^.^._=._.....~~...DDDDDDDDDDDDDDDDDDDdddddddddddddddd]],
[[==============================================.^^^==....~~~~....................ddddddddddddddddddd]],
[[===============================================..====~~~p................dddddddddddddddddddddddddd]],
[[===============================================.==^==_............ddddddddddddddddddddddddddddddddd]],
[[=================================================^^===........ddddddddddddddddddddddddddddddddddddd]],
}
