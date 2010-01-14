quickEntity('b', {name='blue mountains', display='^', color=colors.LIGHT_BLUE, image="terrain/mountain.png", block_move=true})
quickEntity('m', {name='misty mountains', display='^', color=colors.UMBER, image="terrain/mountain.png", block_move=true})
quickEntity('g', {name='grey mountains', display='^', color=colors.SLATE, image="terrain/mountain.png", block_move=true})
quickEntity('u', {name='deep forest', display='#', color=colors.GREEN, image="terrain/tree.png", block_move=true})
quickEntity('t', {name='forest', display='#', color=colors.LIGHT_GREEN, image="terrain/tree.png", block_move=true})
quickEntity('i', {name='iron mountains', display='^', color=colors.SLATE, image="terrain/mountain.png", block_move=true})
quickEntity('=', {name='the great sea', display='~', color=colors.BLUE, image="terrain/river.png", block_move=true})
quickEntity('.', {name='plains', display='.', color=colors.LIGHT_GREEN, image="terrain/grass.png"})
quickEntity('g', {name='Forodwaith, the cold lands', display='.', color=colors.LIGHT_BLUE})
quickEntity('q', {name='Icebay of Forochel', display=';', color=colors.LIGHT_BLUE})
quickEntity('w', {name='ash', display='.', color=colors.WHITE})
quickEntity('&', {name='hills', display='^', color=colors.GREEN, image="terrain/hills.png"})
quickEntity('h', {name='low hills', display='^', color=colors.GREEN, image="terrain/hills.png"})
quickEntity(' ', {name='sea of Rhun', display='~', color=colors.BLUE, image="terrain/river.png", block_move=true})
quickEntity('_', {name='river', display='~', color={r=0, g=80, b=255}, image="terrain/river.png"})
quickEntity('~', {name='Anduin river', display='~', color={r=0, g=30, b=255}, image="terrain/river.png"})

quickEntity('A', {name="Caves below the tower of Amon Sûl", 	display='>', color={r=0, g=255, b=255}, change_level=1, change_zone="tower-amon-sul"})
quickEntity('B', {name="Ettenmoors's cavern", 			display='>', color={r=80, g=255, b=255}})
quickEntity('C', {name="Passageway into the Trollshaws", 	display='>', color={r=0, g=255, b=0}, change_level=1, change_zone="trollshaws"})
quickEntity('D', {name="A gate into a maze", 			display='>', color={r=0, g=255, b=255}, change_level=1, change_zone="maze"})

return {
[[========q=qqqqqqqqqgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg]],
[[=========q=qq=qqqqggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg]],
[[==========qq=q=qqqqgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg]],
[[==============qqq=qqggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg]],
[[===============q=q=q=gwwwwgggwwwwwgggggggggwwwwwwwwwwggggwwwwwwwwwwwwwggggwwwwwwwwggggwwwwwwwwwgggg]],
[[====================qwwwwwwwwwwwwwwwwggggggggwwwwwwwwwwwwwwwwwwwwwwwwwwggwwwwwwwwwwwwwwwwwwwwwwuuuu]],
[[======================wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww.uuuuuuuu]],
[[========================wwwwwwww...wwwwwwwwww..........wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww.uuuuuuuuuuu]],
[[========================..www....wwwwwwww................wwwwffffwwwwwwww......wwwww.uuuuuuuuuuuuuu]],
[[==========.......======.........hhhh..................fffffffwwwdwwww.........wwww.utuuuutuuuuuutuu]],
[[========......bb..===.........hhhhhhhh..&&&&&...&..fffffffffffff.................tuuututuututtuuuut]],
[[=======......bb..===............hhhh.......&&&&&&ff.._._...........................tttttttttttttttt]],
[[======...._.bb._..._............................m....._._uuu................ii........ttttttttttttt]],
[[=======.._..bb.._.._..hhhh................&....&mm~~~~.uu_uuuu..........i.....iii........tttttt^^^^]],
[[======.._...bb..._._..hhh.......hhhhhh.....&&&&._mm..~.uuu_u_uu..^l......iiiiii..............ttt^^^]],
[[=====.._..ubbb...._._..h.=....hhh|hh..........__.mm__~.uuuu_h_uu.l8........_.....................^^]],
[[===...._....bb....._..hh.=_....h.|..........__...mm..~.uuuuuu_uu.=........_........................]],
[[====.._...bbbb...._....hhhh__....|.....A..._.....mm..~.uuuuuu____........._........................]],
[[=====.._..uubb..._........._.....|h......._Ctt...mm..~6uuuuu&&&u._........._.......................]],
[[====...__..ubbb._......hh.._.....|.hh...._.t^^^._mm..~..uuu&f&&&u._........._......................]],
[[=====..._.....__......hho+-_.2---x1hh-------_L...mm---------------_........_.......................]],
[[======..==..=__....h....h|.._.hh.|ih....._..^^^._m...~..uuuuuuuuuu._........_......................]],
[[=============.....hhh....|.._.ttt|h......_.._.._mmm...~..uuuuuuuuu.._........_....................t]],
[[======........bb...h.....|..._ttt|hh...._.._...mm.....~..uuuuuuuu...._......_....................tt]],
[[=====.........bb.........[---_.t.|.h...._._..mmmmm.s._~..uuuuuuuu....._......_..................ttt]],
[[=====.........bb............._[--|....._.._..mmmm___s.~~.uuuuuuuu......_.._._..................tttt]],
[[======........bb...Db......._....|....._._...mmmm.....~~.uuuuu.u........._.._.................ttttt]],
[[=======.....ubbb..bbbb....._.....|....._....mmmmm....~~...uuuu.............._...............ttttttt]],
[[==========..ubbbu........._......|...._.....mmmm.....~~...uuuu..............._...._.......ttttttttt]],
[[==========..uuubbubb....._.......|ss__.....hmmmm....~~....uuuuuuu............._.__._ ...ttttttttttt]],
[[==========...uubuu......_........___ss_....mmmmm....~~..uuuuuuuuuu............._....  ...t  ttttttt]],
[[==========.....u.u....._........_.....______mm___...~~.uuuuuuuuuu...................        ttttttt]],
[[===========.=........._........_...........mmmm_!.!~~..uu&uuuuuuu..................         ttttttt]],
[[================....__........_..ttt......mmmm._!4!~~..uuuuuuuuu...................         ...tttt]],
[[=================.==t........_....tt.....ttmmm..!!!~.....uuuuu..................^^.        ......tt]],
[[===================tt........._.........ttmmm.......~~.........................^^^^.       .......t]],
[[===================t==......._..........ttmmmttttt._..~~~~~~....................^^^.  ...  .......t]],
[[===================t==......_...........t&mmmmtttt_s_.....~~~..................^^^^^. ... ........t]],
[[=====================......_.ttt........t&mmmtttttt..__s~~~~...................^^^^^^.............t]],
[[=====================.....=_.tt.........&&mmmttttt.....~...........................^^.............t]],
[[======================...==..ttt........&&_&&&.._.......~~........................................t]],
[[=======================.===..............^_^....._........~.......................................t]],
[[===========================..............._........_.....~........................................t]],
[[==========================.tt......._._.._........_....h=hh...SSS.................................t]],
[[==========================.tt._.._t_...__.........._..h===h.SSSS.................................tt]],
[[==========================..__.__._._._..&&&b....._....h=hh..SS.a.a.............................ttt]],
[[============================....._..._.__.&&&......_....~~.....aakaaa..a..aa..a..a..aa...a.....tttt]],
[[===========================.............._&&&^^....._....~~s...ddvvaaaaaaaaaaaaaaaaaaaaaaaaaaaaJttt]],
[[===========================.......^.&.^^&&&&&&&......__.~~sss...ddvvvvvvvavvvavaa_"""_""""""..aaatt]],
[[===========================.....^^.&.&_&^&.&^&_&&&9...._..~~ss..ddvvmvvvvvvvvvva_"""""_""""""...aat]],
[[===========================....^....__^^...^^^._^&&........~~.c.ddvvmmvvvvvvvaa_"""""""_"""".....aa]],
[[===========================..^^^_.._.......^^._.^^&&&........~~.ddvvvvvvvvvvaa""_""""""_"""""""....]],
[[============================.^t_.__._........_&^^^.&&&&&......e.ddvaavaaavvv"""""_""""_""""""".....]],
[[============================.t^_..._....hh.._&&&^^.._&&&&.&...~.ddd""a"a""""""""=="""_""""""""""...]],
[[============================.t^._.hhhhhhhh...__...._^&^&&&&&.~..dd""""""""""""======_"""""""""""aaa]],
[[===========================.^^._...h.h........._.._.^&^^._^3.~..dd"""_"_"""""=====""""""""""""aaadd]],
[[==========================..^^.._.....===.=====_._&^...._...^.~.dd"__"_"__======"""""aa""""aaaadddd]],
[[==========================.h...._...===========_&&^...._._...~~.dd_""""""""""""_""a"aaaaaaaaddddddd]],
[[========================.hhh=...=_.==========&^^^^.._._..._.~~..ddd""ddd""d"""dd_ddaadddddddddddddd]],
[[======================....=====.==============^.^._=._.....~~...ddddddddddddddddddddddddddddddddddd]],
[[==============================================.^^^==....~~~~....................ddddddddddddddddddd]],
[[===============================================..====~~~p................dddddddddddddddddddddddddd]],
[[===============================================.==^==_............ddddddddddddddddddddddddddddddddd]],
[[=================================================^^===........ddddddddddddddddddddddddddddddddddddd]],
}
