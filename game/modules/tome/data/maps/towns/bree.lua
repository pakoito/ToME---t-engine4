quickEntity('S', {name='brick roof top', display='#', color=colors.RED, block_move=true, block_sight=true})
quickEntity('s', {name='brick roof', display='#', color=colors.RED, block_move=true, block_sight=true})
quickEntity('t', {name='brick roof chimney', display='#', color=colors.LIGHT_RED, block_move=true, block_sight=true})
quickEntity('#', {name='wall', display='#', color=colors.WHITE, block_move=true, block_sight=true})
quickEntity('C', {name='dark pit', display='#', color=colors.LIGHT_DARK, block_move=true, block_sight=true})
quickEntity('T', {name='tree', display='#', color=colors.LIGHT_GREEN, block_move=true, block_sight=true})
quickEntity(' ', {name='forest', display='#', color=colors.GREEN, block_move=true, block_sight=true})
quickEntity('V', {name='river', display='~', color=colors.BLUE, block_move=true,})
quickEntity('O', {name='cooblestone road', display='.', color=colors.WHITE})
quickEntity('.', {name='road', display='.', color=colors.WHITE})
quickEntity(',', {name='dirt', display='.', color=colors.LIGHT_UMBER})
quickEntity('-', {name='grass', display='.', color=colors.LIGHT_GREEN})

quickEntity('1', {name="General Store", display='1', color={r=0, g=255, b=255},
	on_move = function(self, x, y, who)
		self.store:loadup(game.level, game.zone)
		self.store:interact(who)
	end,
	store = game.stores_def[1]:clone(),
})

startx = 131
starty = 33

return {
[[                                                                                                                  VV              --                                                                  ]],
[[                                                                                                                   VV              --                                                                 ]],
[[                                                                                                                     V              --                                                                ]],
[[                                                                                                                      VV            --                                                                ]],
[[                                                                                                                        VVV          --                                                               ]],
[[                                                                                                                           VV        --                                                               ]],
[[OOOOO                                                                                                                       V         --                                                              ]],
[[    OOOO                                                                                                                     V        --                                                              ]],
[[----   OOOOO                                                                                                                  VVV      ---                             VV                             ]],
[[-------    OOOOOO                                                                                                                V      --                            VVVV                            ]],
[[-----------     OO                                                                                                               V      --                           VVWWVVV                          ]],
[[---------------  OO                                                                                                               VVV    --                        VVVWWWWWVVV                        ]],
[[----------------  OOO                                                                                                               VVV   --                      VVWWWWWWWWWVV                       ]],
[[------------------  OO                                                                                                                VVVVVVV                    VVWWWWWWWWWWWV                       ]],
[[-------------------- OOOOO                                                                                                                 --VVVV   VVVVV        VVWWWWWWWWWWWVV                      ]],
[[###------------------    OO                                                            ,,,,,,,,,,,,,,,,,,                                   --  VVVVV   VV    VVVVVVVWWWWWWWVVV                       ]],
[[CCC####------------------ OOO                                                     ,,,,,CCCCCCCCCCCCCCCCCC,,,,,,,,,                           --          VVVVVV     VVVVWWVVV                         ]],
[[TTTCCCC###---------------,, OO                                                 ,,,CCCCCCTTTTTTTTTTTTTTTTCCCCCCCCCC,,,,                        --                       VVVV                           ]],
[[---TTTTCCC###---------,,,--  OO                                              ,,CCCCTTTTTT--------------TTTTTTTTTTCCCCC,,,,,                  ^--                                                      ]],
[[-------TTTCCC##-----,,------  O                                            ,,CCCTTTT&.................----------TTTTTCCCCCC,,              ^^^ --                                                     ]],
[[----------TTTCC##,,,--------  OO                                          ,CCCTTT....--ssssssss-..---..........-----TTTTTTCCC,,,          ^^    --                                                    ]],
[[-------------TC,,###-    ---   OO                                        ,CCTTT...-----SSSSSSSS--.----------,,....&------TTTCCCC,,       ^^     --                                                    ]],
[[--------------,TTCCC###    --   OOO                                    ,,CCTT...-,,,,--ssssssss-..-sssssssssss,---......---TTTTCCT,,    ^^       --                                                   ]],
[[----------  ,,,--TTTCCC    --     OO                                 ,,CCCTT..-------,,##9#####-.--sssssssssss-,-------...----TTCCTT,  ^^^        --                                                  ]],
[[---------  ,, ,,----TTTCC          O                                ,CCC  T..--sssSsss,,,,------.--StSStSSSStS--,------.-....--TTCCTT,^^^          --                                                 ]],
[[-------   ,,   ,                   OO                              ,CCTTT...---ssstSSS---,,,----.--sssssssssss---,---...----..--TTCCT^^^^ ^^        --                                                ]],
[[-------- ,,   ,,                    OO                            ,CCTT...-----sssssss--,,-,,---.--sssssssssss---,-...-------..--TTC^^^   ^         ----                                              ]],
[[--------     {,                      OO                           ,CTT..---,,,,###6###,,,---,,--.--###########----.&----------..--T^^^^   ^       ---  --                                             ]],
[[----------                            OOO                         ,CT..,,,,----,,,,,,,,------,,-.--###b###e###-....,---sssss---.--T^^   ^         --    --                                            ]],
[[-----------                             OO                       ,CCT.,sssssss----,-----------,,.-----.-----....-,--,,-StSSS---&-T^^^   ^        --      -----                                        ]],
[[--------------                           OO                     ,CCTT.-StStSSS---,-----ssssss--..-----.--....--,,,,,,-,sssss---.-T^^^      ^      --         --             ,,&                       ]],
[[------------                              OOOOO                 ,CTT-.-sssssss---,-----SSSSSS--.------.-..--,,,-ssss--,#####---.-T^^    ^         --          -----        ,,                         ]],
[[---------                                     OO               ,CCT-.&-##5####----,----ssssss-..&.......--XXXX,-ssss--,------...-^^^  ^ ^^  ^    ---             ----    ,,,                          ]],
[[-- ----                                        OOOOOOOO        ,C  OOOO--OOOOO----,----#c##4#-.---.,----,-UUUU,-SSSS--,-----..---^^   ^   ^     ---                 -----,             OOOOOOOOOOOOOOO]],
[[--  ----                                              OOOOOOO  ,CT-OssOOOO---OOOOOOOOO--OOOO--.-T-.-sss--,XXXX,-ssss---,---..--T^^              --                      --           OOO              ]],
[[--  -----                                                   OOOOOOOOSt.---------XXXX-OOOO--OOOO---.-StS--,#0##,-ssss---,---.---^^     ^  ^      --                       ---      OOOO                ]],
[[ -     ---   -----                                           ,,CT--.ss.-sssss---XXXX,---------OOOO.-sss---,,,,,-####--,---..-T^^   ^ ^          --                         ---   OO                   ]],
[[     ----     ----                                           ,,CT--.##.-SStSS---####,------------OO-#>#-ssssss-,,,---,----.--T^^   ^           -,-                           OOOOO                    ]],
[[   -------      ----                                         ,,CTT-....-sssss--,,,,,,----------F--OO-,--SSSSSt-ss-,-,---...-T^^  ^ ^           -,                         OOOO                        ]],
[[     -------   ------                                        ,,CCTT---..#2###-,sssss,-SSSSSSSS-----OO,--ssssss-tS--,.&...---^^ ^^     ^^^     -,                   OOOOOOOO                           ]],
[[    -----        -----                                        ,,CCT----..,,,,,-StSSS,-ssssssss------OOO-#1##a#-ss....-----T^^        ^^      -,-               OOOOO                                  ]],
[[       ----  --------                                         ,,CCTT----.&----,sssss,-##7#####--------OO,.,,.,-##.----TTTT^^     ^  ^^       -,            OOOOO                                      ]],
[[      ---------------                                         ,,,CCTTTT--..---,##3##-,--,&,---------..&OOOOOOOOOOOTTTTTCC^^^   ^^  ^^        ,-          OOO                                          ]],
[[         --------                                              ,,,CCCC  --..........,-,,---,--.......-------TTTTTOCCCCC,,^^^^^^^^^^^        -.-      OOOOO                                            ]],
[[       ----------                                              ,, ,,CCCTT----------.....-......-------TTTTTTTCCCCO,,,,,     ^^^^^^^         -.-      O                                                ]],
[[         -------                                               ,,   ,,CCTTTTTTTTTT-----...------TTTTTTTCCCCCC,,,,OOO                       -.-    OOOO                                                ]],
[[           ----                                                ,,,    ,CCCCCCCCCCTTTTT-----TTTTTTCCCCCC,,,,,,      OOO                    OOOOOOOOO                                                   ]],
[[       ^^   ----                                                ,,     ,,,,,,,,,,CCCCCTTTTTTCCCCC,,,,,,              OO                 OOO--                                                         ]],
[[     ^^^^^                                                      ,,,              ,,,,,CCCCCC,,,,,                     OOOO             OOO--                                                          ]],
[[   ^^^^^^^^^                                                     ,,                   ,,,,,,                             OOOOOOO     OOO---                                                           ]],
[[   ^^^^^^^^^                                                     ,,                                                            OOOOOOO----                                                            ]],
[[  ^^^^^^^^^^^^^^^                                                ,,,                                                            ..------                                                              ]],
[[    ^^^^^^^^^^^^^^                                                ,,,                     ......                             ....-----                                                                ]],
[[    ^^^^^^^^^^^^^^^                                                ,,,          ...........    ............       ............-------,,,,                                                             ]],
[[ ^^^^^^^^^^^^^^^^^                                                  ,,        ...                         .........--------------       ,,,,,,,    ,,,,,,,,,                                          ]],
[[     ^^^^^^^^^^^^^                                                 ,,         .                                                               ,,,,,,       ,,,,,,,,,                                  ]],
[[   ^^^^^^^^^^^^^^                                                   ,,      ...                                                                                    ,,,,,        ------    ---         ]],
[[     ^^^^^^^^^^^^^^^                                                 ,,     .                                                                                          ,,,,,,,,-------   -----        ]],
[[     ^^^^^^^^^^^^^^                                                   ,    ..                                                                                                  ----------------       ]],
[[  ^^^^^^^^^^^^^^^^                                                    ,,  ..                                                                                                ------------------        ]],
[[    ^^^^^^^^^^^^^^^                                                    , ..                                                                                                 ----------------&         ]],
[[  ^^^^^^^^^^^^^^^^                                                     ,,.                                                                                                  ---    ----   ----        ]],
[[   ^^^^^^^^^^^^^                                                        ,.                                                                                                   -      --     --         ]],
[[   ^^^^^^^^^^^^^^                                                        .                                                                                                                            ]],
[[     ^^^^^^^^^^^^^^                                                      .                                                                                                                            ]],
[[                                                                                                                                                                                                      ]],
}