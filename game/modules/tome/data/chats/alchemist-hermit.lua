-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

local art_list = mod.class.Object:loadList("/data/general/objects/brotherhood-artifacts.lua")
local alchemist_num = 3
local other_alchemist_nums = {1, 2, 4}
local q = game.player:hasQuest("brotherhood-of-alchemists")
local final_reward = "INFUSION_WILD_GROWTH"
local e = {
	{
	short_name = "force",
	name = "elixir of explosive force",
	cap_name = "ELIXIR OF EXPLOSIVE FORCE",
	id = "ELIXIR_FORCE",
	start = "force_start",
	almost = "force_almost_done",
	full = "elixir_of_explosive_force",
	full_2 = "elixir_of_serendipity",
	full_3 = "elixir_of_focus",
	poached = "force_poached",
	},
	{
	short_name = "serendipity",
	name = "elixir of serendipity",
	cap_name = "ELIXIR OF SERENDIPITY",
	id = "ELIXIR_SERENDIPITY",
	start = "serendipity_start",
	almost = "serendipity_almost_done",
	full = "elixir_of_serendipity",
	full_2 = "elixir_of_explosive_force",
	full_3 = "elixir_of_focus",
	poached = "serendipity_poached",
	},
	{
	short_name = "focus",
	name = "elixir of focus",
	cap_name = "ELIXIR OF FOCUS",
	id = "ELIXIR_FOCUS",
	start = "focus_start",
	almost = "focus_almost_done",
	full = "elixir_of_focus",
	full_2 = "elixir_of_explosive_force",
	full_3 = "elixir_of_serendipity",
	poached = "focus_poached",
	},
}

--cond function for turning in non-final elixirs
--checks that player has quest and elixir ingredients, hasn't completed it yet, has started that elixir, and hasn't completed both other elixirs since that would make this the last one:
local function turn_in(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name, n) -- make sure we have the quest and the elixir's ingredients
	and not q:isCompleted(e[n].almost) and not q:isCompleted(e[n].full) --make sure we haven't finished the quest already
	and q:isCompleted(e[n].start) --make sure we've been given the task to make this elixir
	and not (q:isCompleted(e[n].full_2) and q:isCompleted(e[n].full_3)) --make sure we haven't already finished both the other elixirs, since that would make this the final one which requires a special dialog.
end

--cond function for turning in final elixir with index n
--checks that player has quest and elixir ingredients, hasn't completed it yet, has started that elixir, and both the other elixirs are done
local function turn_in_final(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name, n) -- make sure we have the quest and the elixir's ingredients
	and not q:isCompleted(e[n].almost) and not q:isCompleted(e[n].full) --make sure we haven't finished the quest already
	and q:isCompleted(e[n].start) --make sure we've been given the task to make this elixir
	and (q:isCompleted(e[n].full_2) and q:isCompleted(e[n].full_3)) --make sure the other two elixirs are made, thus making this the final turn-in
end

--cond function for turning in poached (completed by somebody besides you) elixirs
--checks that the player has the quest and elixir ingredients, hasn't turned it in, the task is complete anyway, the task has actually been started, and that it's been poached
local function turn_in_poached(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name, n) -- make sure we have the quest and the elixir's ingredients
	and not q:isCompleted(e[n].almost) --make sure we haven't turned it in already
	and q:isCompleted(e[n].full) --make sure that, even though we haven't turned it in, the elixir has been made for this alchemist
	and q:isCompleted(e[n].start) --make sure we've been given the task to make this elixir
	and q:isCompleted(e[n].poached)  --make sure this task has been poached
end

local function more_aid(npc, player)
	return not (q:isCompleted(e[1].full) and q:isCompleted(e[2].full) and q:isCompleted(e[3].full)) --make sure all the elixirs aren't already made
	--Next, for each of the three elixirs, make sure it's not the case that we're still working on it
	and not (q:isCompleted(e[1].start) and not q:isCompleted(e[1].full))
	and not (q:isCompleted(e[2].start) and not q:isCompleted(e[2].full))
	and not (q:isCompleted(e[3].start) and not q:isCompleted(e[3].full))
end

local function give_bits(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name) -- make sure we have the quest and the elixir's ingredients
	and q:isCompleted(e[n].start) --make sure we've started the task
	and not q:isCompleted(e[n].full) --... but not finished
end

local function empty_handed(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name, n) -- make sure we have the quest and the elixir's ingredients
	and q:isCompleted(e[n].start) --make sure we've started the task
	and not q:isCompleted(e[n].almost) --make sure we've not turned the stuff in before...
	and q:isCompleted(e[n].full)  --... and yet the elixir is already made (poached!)
end

--Make the alchemist's reaction to your turn-in vary depending on whether he lost.
local function alchemist_reaction_complete(npc, player, lose, other_alch, other_elixir)
	if lose == true then
		return ([[SON OF A RITCH! YOU SHOW UP TEN MINUTES AFTER I GET THE NEWS THAT SOME JACKASS ALREADY FINISHED THE ELIXIRS AND IS GETTING ACCEPTED BY THE BROTHERHOOD. WHAT THE HELL TOOK YOU SO LONG? MIRVENIA'S MAMMARIES, I'LL TAKE THESE AND MAKE YOU YOUR REWARD, BUT ONLY BECAUSE A CURSE WILL KILL ME IF I DON'T. AND IF IT TASTES LIKE PISS, THAT'S YOUR IMAGINATION, I'M SURE.]])
	else
		return ([[#LIGHT_GREEN#*The halfling hands you a note that says, 'Heard %s managed to make a %s while you've been loafing. Hurry the hell up next time.*#WHITE#
		I STILL CAN'T HEAR A DAMNED THING. FORTUNATELY, YOU DON'T LOOK LIKE THE SORT THAT MAKES INTERESTING CONVERSATION.]]):format(other_alch, other_elixir)
	end
end

if not q or (q and not q:isCompleted(e[1].start) and not q:isCompleted(e[2].start) and not q:isCompleted(e[3].start)) then

-- Here's the dialog that pops up if the player has never worked for this alchemist before:
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*After a great deal of pounding, a halfling wrapped in charred, smoking robes opens the door. He looks irritated.*#WHITE#
IT'S NOT ENOUGH THAT I WORK ALL MORNING TO MAKE A POTION THAT ENDS UP NEARLY BLOWING MY ASS OFF, BUT NOW I'VE GOT IDIOTS BEATING DOWN MY DAMNED FRONT DOOR WITH WHAT SOUNDS LIKE A BATTERING RAM, AND YES, I HEARD IT, THOUGH I CAN HARDLY MAKE OUT A BLEEDING THING WITH THESE BLEEDING, CONCUSSED EARS. WHAT DO YOU WANT?]],
	answers = {
		{"Perhaps there's something that I can help you with.", jump="ominous"},
		{"[leave]"},
	}
}

newChat{ id="ominous",
	text = [[SPEAK UP, HAMBRAIN. I'VE JUST GOTTEN MY EARDRUMS BLOWN OUT BY YET ANOTHER BY-THE-PYRE POTION GONE SOUTH, REMEMBER? THRICE-DAMNED THING WAS GOING PERFECTLY, TOO. TOKNOR'S TACKLE!]],
	answers = {
		{"I SAID, MAYBE THERE'S SOMETHING THAT I CAN HELP YOU WITH!", jump="proposal"},
	}
}

newChat{ id="proposal",
	text = [[STILL CAN'T HEAR YOU, BUT LISTEN UP. THE BROTHERHOOD OF ALCHEMISTS IS ACCEPTING THE FIRST NEW APPLICANT TO DEMONSTRATE, AMONG OTHER THINGS, THREE VERY COMPLICATED ELIXIRS. I WOULDN'T BOTHER TRYING TO JOIN SUCH A BUNCH OF ADDLE-BRAINED DEGENERATES, BUT IT SO HAPPENS THAT THE BROTHERHOOD OF ALCHEMISTS HOLDS THE SECRET CURE FOR THE COMMON BLOWN-OFF ASS, WHICH IT SO HAPPENS IS OF SOME INTEREST TO ME.]],
	answers = {
		{"HOW CAN I HELP?", jump="help"},
	}
}

newChat{ id="help",
	text = [[THE BROTHERHOOD KNOWS DAMNED WELL WHAT ADVANCES IN THE FIELD OF ALCHEMY WOULD DO FOR EVERY CIVILIZATION IN EXISTENCE, BUT THEY HOARD THEIR FEW WORTHWHILE SECRETS LIKE A GREAT BROWN WYRM SITTING ON ITS PILE OF CRAP. YOU KNOW WHAT? I DON'T EVEN WANT THE ASS-CURE FOR ME. I'M GOING TO STEAL EVERY SECRET THEY'VE GOT, WRITE THEM DOWN, MAKE A HUNDRED COPIES, AND NAIL ONE TO A TREE IN EVERY VILLAGE IN MAJ'EYAL.]],
	answers = {
		{"THAT'S NOT A VERY HERMIT-LIKE ATTITUDE.", jump="competition"},
	}
}

newChat{ id="competition",
	text = [[AND THEN WHAT WILL THEY DO? ONCE THEIR PRECIOUS SECRETS-- WHICH, IN ALL PROBABILITY, EITHER DON'T EXIST OR ARE THINGS LIKE RECIPES FOR ELIXIRS OF WHO-GIVES-A-FLYING-DUCK-- ARE OUT IN THE OPEN, THE BROTHERHOOD OF ASSWIPES WILL HAVE NOTHING TO HOLD IT TOGETHER BUT ELIXIRS OF THEIR TEARS AND WIDESPREAD DISDAIN FROM THE REST OF THE WORLD. SPEAK UP, THEN. ARE YOU IN OR OUT?]],
	answers = {
		{"I'M IN.", jump="choice", action = function(npc, player) player:grantQuest("brotherhood-of-alchemists") end,},
		{"I CANNOT AID YOU AT THIS TIME."},
	}
}

newChat{ id="choice",
	text = [[#LIGHT_GREEN#*He hands you a slip of paper with the names and properties of some elixirs on it.*#WHITE#
THE INGREDIENTS TO THESE SUCKERS ARE SORT OF A TRADE SECRET, SO I'LL TELL YOU ABOUT ONE AND WE'LL SEE HOW THAT GOES. OH, AND I'LL MAKE ENOUGH FOR YOU TO HAVE A SWIG WHEN I'M DONE, SO GOOD FOR YOU. WHICH ONE WILL IT BE? JUST POINT AT THE DAMNED LIST. I HAVEN'T HEARD A THING YOU'VE SAID YET. I HOPE TO HELL YOU'RE NOT STANDING THERE TRYING TO SELL ME SOMETHING.]],
	answers = {
		{"[Indicate the "..e[1].name..".]", jump="list",
			cond = function(npc, player) return not game.player:hasQuest("brotherhood-of-alchemists"):isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].start)
				game.player:hasQuest("brotherhood-of-alchemists"):update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[1].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"[Indicate the "..e[2].name..".]", jump="list",
			cond = function(npc, player) return not game.player:hasQuest("brotherhood-of-alchemists"):isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].start)
				game.player:hasQuest("brotherhood-of-alchemists"):update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[2].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"[Indicate the "..e[3].name..".]", jump="list",
			cond = function(npc, player) return not game.player:hasQuest("brotherhood-of-alchemists"):isCompleted(e[3].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].start)
				game.player:hasQuest("brotherhood-of-alchemists"):update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[3].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"[leave]"},
	}
}

newChat{ id="list",
	text = [[HERE'S A LIST OF THE STUFF I NEED. MOST OF IT WILL TRY TO KILL YOU, SO I HOPE YOU'RE NOT INCOMPETENT. I'VE GOT PLENTY OF INCOMPETENT HELP ALREADY. I HOPE FOR YOUR SAKE THAT YOU'RE SMARTER AND FASTER THAN THEM.]],
	answers = {
		{"I'LL BE OFF."},
	}
}

-- Quest is complete; nobody answers the door
elseif q and q:isStatus(q.DONE) then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*The door is locked and nobody responds to your knocks*#WHITE#]],
	answers = {
		{"[Leave]"},
	}
}


else -- Here's the dialog that pops up if the player *has* worked with this alchemist before (either done quests or is in the middle of one):

local other_alch, other_elixir, player_loses, alch_picked, e_picked = q:competition(player, other_alchemist_nums)

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*The halfling, still smoking, opens his door.*#WHITE#
I LIVE WAY THE HELL OUT HERE FOR A REASON, YOU PIECE OF... OH. IT'S YOU.]],
	answers = {
		-- If not the final elixir:
		{"I'VE RETURNED WITH THE INGREDIENTS FOR THE "..e[1].cap_name..".", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 1) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},
		{"I'VE RETURNED WITH THE INGREDIENTS FOR THE "..e[2].cap_name..".", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 2) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},
		{"I'VE RETURNED WITH THE INGREDIENTS FOR THE "..e[3].cap_name..".", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 3) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},

		-- If the final elixir:
		{"I'VE RETURNED WITH THE INGREDIENTS FOR THE "..e[1].cap_name..".", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 1) end,
		},
		{"I'VE RETURNED WITH THE INGREDIENTS FOR THE "..e[2].cap_name..".", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 2) end,
		},
		{"I'VE RETURNED WITH THE INGREDIENTS FOR THE "..e[3].cap_name..".", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 3) end,
		},

		-- If the elixir got made while you were out:
		{"I'VE RETURNED WITH THE INGREDIENTS FOR THE "..e[1].cap_name..".", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 1) end,
		},
		{"I'VE RETURNED WITH THE INGREDIENTS FOR THE "..e[2].cap_name..".", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 2) end,
		},
		{"I'VE RETURNED WITH THE INGREDIENTS FOR THE "..e[3].cap_name..".", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 3) end,
		},

		--Don't let player work on multiple elixirs for the same alchemist.
		--See comments in more_aid function above for all the gory detail
		{"I'VE COME TO OFFER MORE AID.", jump="choice",
			cond = function(npc, player) return more_aid(npc, player) end,
		},
		{"[leave]"},
	}
}

--Not final elixir:
newChat{ id="complete",
	text = alchemist_reaction_complete(npc, player, player_loses, other_alch, other_elixir),
	answers = {
		{"[Give him the monster bits.]", jump="complete2",
			cond = function(npc, player) return give_bits(npc, player, 1) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].almost)
				q:remove_ingredients(player, e[1].short_name, 1)
			end
		},
		{"[Give him the monster bits.]", jump="complete2",
			cond = function(npc, player) return give_bits(npc, player, 2) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].almost)
				q:remove_ingredients(player, e[2].short_name, 2)
			end
		},
		{"[Give him the monster bits.]", jump="complete2",
			cond = function(npc, player) return give_bits(npc, player, 3) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].almost)
				q:remove_ingredients(player, e[3].short_name, 3)
			end
		},
--		{"Sorry, it seems I lack some stuff. I will be back."},
	}
}

--Final elixir:
newChat{ id="totally-complete",
	text = [[#LIGHT_GREEN#*For the first time you've seen, genuine pleasure lights up the halfling's soot-smeared face.*#WHITE#
GOOD WORK, WHOEVER YOU ARE. ALL OF MAJ'EYAL OWES YOU THEIR THANKS, EXCEPT FOR MEMBERS OF THE BROTHERHOOD OF ALCHEMISTS, WHO MIGHT TRY TO DO YOU BODILY HARM. FORTUNATELY FOR YOU, THEY'RE MOSTLY HARMLESS.]],
	answers = {
		{"[Give him the monster bits]", jump="totally-complete2",
			cond = function(npc, player) return give_bits(npc, player, 1) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].almost)
				q:remove_ingredients(player, e[1].short_name, 1)
			end
		},
		{"[Give him the monster bits]", jump="totally-complete2",
			cond = function(npc, player) return give_bits(npc, player, 2) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].almost)
				q:remove_ingredients(player, e[2].short_name, 2)
			end
		},
		{"[Give him the monster bits]", jump="totally-complete2",
			cond = function(npc, player) return give_bits(npc, player, 3) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].almost)
				q:remove_ingredients(player, e[3].short_name, 3)
			end
		},
		--{"Sorry, it seems I lack some stuff. I will be back."},
	}
}

--Not final elixir:
newChat{ id="complete2",
	text = [[WAIT HERE. THERE'S A GOOD CHANCE YOU'LL GET BLOWN INTO ADVENTURER KIBBLE IF YOU STEP INSIDE THIS BUILDING. MY ROBE OF MAD ALCHEMIST PROTECTION IS THE ONLY REASON I'M NOT VAPOUR.]],
	answers = {
		{"[Wait]", jump="complete3"},

	}
}

--Final Elixir:
newChat{ id="totally-complete2",
	text = [[GIVE ME AN HOUR, AND THINK UNPLEASANT THOUGHTS ABOUT THE BROTHERHOOD. IF ANYTHING EXPLODES, COME RESCUE ME, EVEN IF IT LOOKS LIKE THE BUILDING IS AN INFERNO OF POISONOUS SMOKE AND POLKA-DOT FLAMES.]],
	answers = {
		{"[Wait]", jump="totally-complete3"},

	}
}

--Not final elixir:
newChat{ id="complete3",
	text = [[#LIGHT_GREEN#*Disaster fails to occur. The halfling finally returns and hands you a small vial of sooty glass.*#WHITE#
ENJOY, AND COME BACK ANY TIME IF YOU'RE INTERESTED IN SIMILAR WORK. I HAVEN'T WON YET. THE LONGER YOU WAIT, THE MORE LIKELY IT IS THAT YOU'LL RETURN TO A SMOKING CRATER AND ONE TRULY IRATE HALFLING.]],
	answers = {
		{"THANK YOU. I'LL BE OFF.",
			cond = function(npc, player) return q and q:isCompleted(e[1].almost) and not q:isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].full)
				q:reward(player, e[1].id)
				q:update_needed_ingredients(player)
			end
		},
		{"THANK YOU. I'LL BE OFF.",
			cond = function(npc, player) return q and q:isCompleted(e[2].almost) and not q:isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].full)
				q:reward(player, e[2].id)
				q:update_needed_ingredients(player)
			end
		},
		{"THANK YOU. I'LL BE OFF.",
			cond = function(npc, player) return q and q:isCompleted(e[3].almost) and not q:isCompleted(e[3].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].full)
				q:reward(player, e[3].id)
				q:update_needed_ingredients(player)
			end
		},
	}
}

--Final elixir:
newChat{ id="totally-complete3",
	text = [[#LIGHT_GREEN#*The halfling finally returns with a vial and a small pouch.*#WHITE#
YOUR DOSE OF THE ELIXIR, AS WELL AS SOMETHING ELSE. THIS INFUSION IS RARE AS HELL, SO DON'T GO WASTING IT.]],
	answers = {
		{"THANK YOU. I'LL BE OFF.",
			cond = function(npc, player) return q and q:isCompleted(e[1].almost) and not q:isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].full)
				q:reward(player, e[1].id)
				q:reward(player, final_reward)
				q:update_needed_ingredients(player)
				q:winner_is(player, alchemist_num)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.DONE)

			end
		},
		{"THANK YOU. I'LL BE OFF.",
			cond = function(npc, player) return q and q:isCompleted(e[2].almost) and not q:isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].full)
				q:reward(player, e[2].id)
				q:reward(player, final_reward)
				q:update_needed_ingredients(player)
				q:winner_is(player, alchemist_num)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.DONE)
			end
		},
		{"THANK YOU. I'LL BE OFF.",
			cond = function(npc, player) return q and q:isCompleted(e[3].almost) and not q:isCompleted(e[3].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].full)
				q:reward(player, e[3].id)
				q:reward(player, final_reward)
				q:update_needed_ingredients(player)
				q:winner_is(player, alchemist_num)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.DONE)
			end
		},
	}
}

newChat{ id="choice",
	text = [[WHICH ELIXIR DO YOU WANT TO HELP ME WITH? YOU ARE HERE TO DO JUST THAT, RIGHT? YOU'RE NOT SOME IMBECILE HERE LOOKING FOR A LOVE POTION?]],
	answers = {
		{"[Indicate the "..e[1].name..".]", jump="list",
			cond = function(npc, player) return not q:isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].start)
				q:update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[1].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"[Indicate the "..e[2].name..".]", jump="list",
			cond = function(npc, player) return not q:isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].start)
				q:update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[2].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"[Indicate the "..e[3].name..".]", jump="list",
			cond = function(npc, player) return not q:isCompleted(e[3].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].start)
				q:update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[3].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"[leave]"},
	}
}

newChat{ id="list",
	text = [[TAKE THIS LIST OF INGREDIENTS, AND HURRY THE HELL UP.]],
	answers = {
		{"I'LL BE OFF."},
	}
}

-- If the elixir got made while you were out:
newChat{ id="poached",
	text = [[TOO SLOW, HAMBRAIN. ELIXIR'S MADE ALREADY, AND SOMEBODY ELSE WALKED OFF WITH THE REWARD. IF YOU'RE FEELING SORRY FOR YOURSELF, ASK WHETHER THIS IS MORE OR LESS PLEASANT THAN GETTING APPRECIABLE CHUNKS OF YOUR ANATOMY BLASTED CLEAN OFF YOUR BODY THIS MORNING. THAT'S RIGHT. BYE.]],
	answers = {
		{"Hrmph.",
			cond = function(npc, player) return empty_handed(npc, player, 1) end,
			action = function(npc, player)
				q:remove_ingredients(player, e[1].short_name, 1)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].almost)
				q:update_needed_ingredients(player)
			end,
		},
		{"Hrmph.",
			cond = function(npc, player) return empty_handed(npc, player, 2) end,
			action = function(npc, player)
				q:remove_ingredients(player, e[2].short_name, 2)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].almost)
				q:update_needed_ingredients(player)
			end,
		},
		{"Hrmph.",
			cond = function(npc, player) return empty_handed(npc, player, 3) end,
			action = function(npc, player)
				q:remove_ingredients(player, e[3].short_name, 3)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].almost)
				q:update_needed_ingredients(player)
			end,
		},
	}
}

end

return "welcome"
