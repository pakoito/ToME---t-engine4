-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

require "engine.class"

module(..., package.seeall, class.make)


-------------------------------------------------------------
-- Resources
-------------------------------------------------------------
TOOLTIP_GOLD = [[#GOLD#Gold#LAST#
Money!
With gold you can buy items in the various stores in town.
You can gain money by looting it from your foes, by selling items and by doing some quests.
]]

TOOLTIP_LIVES = [[#GOLD#Lives#LAST#
How many lives you have and how many you lost.
Your total number of lives depends on the permadeath setting you choose.
You may find other ways to save yourself but they are not considered extra lives.]]

TOOLTIP_LIFE = [[#GOLD#Life#LAST#
This is your life force, when you take damage this is reduced more and more.
If it reaches below zero you die.
Death is usually permanent so beware!
It is increased by Constitution.]]

TOOLTIP_LIFE_REGEN = [[#GOLD#Life Regeneration#LAST#
How many life you regenerate per turn.
This value can be improved with spells, talents, infusions, equipment.]]

TOOLTIP_HEALING_MOD = [[#GOLD#Healing mod#LAST#
This represents how effective is healing for you.
All healing values are multiplied by this value (including life regeneration).]]

TOOLTIP_AIR = [[#GOLD#Air#LAST#
The breath counter only appears when you are suffocating.
If it reaches zero you will die. Being stuck in a wall, being in deep water, ... all those kind of situations will decrease your air.
When you come back into a breathable atmosphere you will slowly regain your air level.
]]

TOOLTIP_STAMINA = [[#GOLD#Stamina#LAST#
Stamina represents your physical fatigue. Each physical ability used reduces it.
It regenerates slowly over time or when resting.
It is increased by Willpower.]]

TOOLTIP_MANA = [[#GOLD#Mana#LAST#
Mana represents your reserve of magical energies. Each spell cast consumes mana and each sustained spell reduces your maximum mana.
It is increased by Willpower.]]

TOOLTIP_POSITIVE = [[#GOLD#Positive#LAST#
Positive energy represents your reserve of positive "celestial" power.
It slowly decreases and is replenished by using some talents.
]]

TOOLTIP_NEGATIVE = [[#GOLD#Negative#LAST#
Negative energy represents your reserve of negative "celestial" power.
It slowly decreases and is replenished by using some talents.
]]

TOOLTIP_VIM = [[#GOLD#Vim#LAST#
Vim represents the amount of life energy you control. Each corruption talent requires some.
It does not regenerates naturally, you need to drain it from yourself or you victims.
Each time you kill a creature you drain 10% of your Willpower as Vim.
Also if you used a Corruption spell that costed Vim to kill a creature, that cost is refunded on death.
]]

TOOLTIP_EQUILIBRIUM = [[#GOLD#Equilibrium#LAST#
Equilibrium represents your standing in the grand balance of nature.
The closer it is to 0 the more in-balance you are. Being out of equilibrium will negatively affect your ability to use Wild Gifts.
]]

TOOLTIP_HATE = [[#GOLD#Hate#LAST#
Hate represents your inner rage against all that lives and dares face you.
It slowly decreases and is replenished by killing creatures.
All afflicted talents are based on Hate, the higher hate is the more effective the talents are.
]]

TOOLTIP_PARADOX = [[#GOLD#Paradox#LAST#
Paradox represents how much damage you've caused to the spacetime continuum.
As your Paradox grows your spells will cost more to use and have greater effect; but they'll also become more difficult to control.
Your control over chronomancy spells increases with your Willpower.
]]

TOOLTIP_PSI = [[#GOLD#Psi#LAST#
Psi represents how much energy your mind can harness. Like matter, it can be neither created nor destroyed.
It does not regenerate naturally. You must absorb energy through shields or through various other talents.
Your capacity for storing energy is determined by your Willpower.
]]

TOOLTIP_LEVEL = [[#GOLD#Level and experience#LAST#
Each time you kill a creature that is over your own level - 5 you gain some experience.
When you reach enough experience you advance to the next level. There is a maximum of 50 levels you can gain.
Each time you level you gain stat and talent points to use to improve your character.
]]

TOOLTIP_ENCUMBERED = [[#GOLD#Encumberance#LAST#
Each object you carry has an encumberance value, your maximum carrying capacity is determined by your strength.
You can not move while encumbered, drop some items.
]]

TOOLTIP_INSCRIPTIONS = [[#GOLD#Inscriptions#LAST#
The people of Eyal have found a way to create herbal infusions and runes that can be inscribed on the skin of a creature.
Those inscriptions give the bearer always accessible powers. Usually most people have a simple regeneration infusion, but there are other kind of potion inscriptions.
]]

-------------------------------------------------------------
-- Speeds
-------------------------------------------------------------
TOOLTIP_SPEED_GLOBAL = [[#GOLD#Global Speed#LAST#
Global speed affects everything you do.
It represents how much "energy" you get per game turn, once you reach a certain point you can act.
I.E: at 200% global speed you get twice as much energy per game turn and thus can act twice when other creatures only act once.
]]
TOOLTIP_SPEED_MOVEMENT = [[#GOLD#Movement Speed#LAST#
The additional time you have to move.
It represents how many more movements you can do in the same time.
I.E: at 100% you will be able to do 100% more movements (aka twice as many) in the same time it would have taken you to do one at 0% speed.
]]
TOOLTIP_SPEED_SPELL = [[#GOLD#Spell Speed#LAST#
The additional time you have cast a spell.
It represents how many more spells you can cast in the same time.
I.E: at 100% you will be able to cast 100% more spells (aka twice as many) in the same time it would have taken you to do one at 0% speed.
]]
TOOLTIP_SPEED_ATTACK = [[#GOLD#Attack Speed#LAST#
The additional time you have to attack (in melee or ranged).
It represents how many more attacks you can do in the same time.
I.E: at 100% you will be able to do 100% more attacks (aka twice as many) in the same time it would have taken you to do one at 0% speed.
]]

-------------------------------------------------------------
-- Stats
-------------------------------------------------------------
TOOLTIP_STR = [[#GOLD#Strength#LAST#
Strength defines your character's ability to apply physical force. It increases your melee damage, damage done with heavy weapons, your chance to hit, your chance to save against physical effects, and carrying capacity.
]]
TOOLTIP_DEX = [[#GOLD#Dexterity#LAST#
Dexterity defines your character's ability to be agile and alert. It increases your chance to hit, your ability to avoid attacks, and your damage with light weapons.
]]
TOOLTIP_CON = [[#GOLD#Constitution#LAST#
Constitution defines your character's ability to withstand and resist damage. It increases your maximum life, your chance to save against physical effects and your global damage reduction.
]]
TOOLTIP_MAG = [[#GOLD#Magic#LAST#
Magic defines your character's ability to manipulate the magical energy of the world. It increases your spell power, your chance to save against magical effects, and the effect of spells and other magic items.
]]
TOOLTIP_WIL = [[#GOLD#Willpower#LAST#
Willpower defines your character's ability to concentrate. It increases your mana, stamina, psi capacity, and your chance to save against magical and mental effects.
]]
TOOLTIP_CUN = [[#GOLD#Cunning#LAST#
Cunning defines your character's ability to learn, think, and react. It allows you to learn many worldly abilities, and increases your chance to save against mental effects and critical chance.
]]
TOOLTIP_STRDEXCON = "#AQUAMARINE#Physical stats#LAST#\n---\n"..TOOLTIP_STR.."\n---\n"..TOOLTIP_DEX.."\n---\n"..TOOLTIP_CON
TOOLTIP_MAGWILCUN = "#AQUAMARINE#Mental stats#LAST#\n---\n"..TOOLTIP_MAG.."\n---\n"..TOOLTIP_WIL.."\n---\n"..TOOLTIP_CUN

-------------------------------------------------------------
-- Melee
-------------------------------------------------------------
TOOLTIP_COMBAT_ATTACK = [[#GOLD#Accuracy chance#LAST#
Your accuracy value represents your chance to hit your opponents, it is measured directly against the target's defense rating.
It is improved by both Strength and Dexterity.
]]
TOOLTIP_COMBAT_DAMAGE = [[#GOLD#Damage#LAST#
This is the damage you inflict on your foes when you hit them.
This damage can be reduced by the target's armour or by percentile damage resistances.
It is improved by both Strength and Dexterity, some talents can change the stats that affect it.
]]
TOOLTIP_COMBAT_APR = [[#GOLD#Armour Penetration#LAST#
Armour penetration allows you to ignore a part of the target's armour (this only works for armour, not damage resistance).
This can never increase the damage you do beyond reducing armour, so it is only useful against armoured foes.
]]
TOOLTIP_COMBAT_CRIT = [[#GOLD#Critical chance#LAST#
Each time you deal damage you have a chance to make a critical hit that deals 150% of the normal damage.
Some talents allow you to increase this percentage.
It is improved by Cunning.
]]
TOOLTIP_COMBAT_SPEED = [[#GOLD#Attack speed#LAST#
Attack speed represents how fast your attacks are compared to a normal turn.
The lower it is the faster your attacks are.
]]
TOOLTIP_COMBAT_RANGE = [[#GOLD#Firing range#LAST#
The maximum distance your weapon can reach.
]]
TOOLTIP_COMBAT_AMMO = [[#GOLD#Ammo remaining#LAST#
This is the amount of ammo you have left.
Bows and sling have a "basic" infinite ammo so you can fire even when this reaches 0.
Alchemists use gems to throw bombs, they require ammo.
]]

-------------------------------------------------------------
-- Defense
-------------------------------------------------------------
TOOLTIP_FATIGUE = [[#GOLD#Fatigue#LAST#
Fatigue is a percentile value that increases the cost of all your talents and spells.
It represents the fatigue created by wearing heavy equipment.
Not all talents are affected, notably Wild Gifts are not.
]]
TOOLTIP_ARMOR = [[#GOLD#Armour#LAST#
Armour value is a damage reduction from every incoming melee and ranged physical attacks.
Absorbs (hardiness)% of incoming physical damage, up to a maximum of (armour) damage absorbed.
This is countered by armour penetration and is applied before all kinds of critical damage increase, talent multipliers and damage multiplier, thus making even small amounts have greater effects.
]]
TOOLTIP_ARMOR_HARDINESS = [[#GOLD#Armour Hardiness#LAST#
Armour hardiness value represents how much of every incoming blows the armour will affect.
Absorbs (hardiness)% of incoming physical damage, up to a maximum of (armour) damage absorbed.
]]
TOOLTIP_DEFENSE = [[#GOLD#Defense#LAST#
Defense represents your chance to avoid being hit at all by a melee attack, it is measured against the attacker's accuracy chance.
]]
TOOLTIP_RDEFENSE = [[#GOLD#Ranged Defense#LAST#
Ranged defense represents your chance to avoid being hit at all by a ranged attack, it is measured against the attacker's accuracy chance.
]]
TOOLTIP_PHYS_SAVE = [[#GOLD#Physical saving throw#LAST#
This value represents your resistance against physical attacks induced special effects, like bleeding, stuns, knockbacks, ...
It is measured against your target's accuracy.
]]
TOOLTIP_SPELL_SAVE = [[#GOLD#Spell saving throw#LAST#
This value represents your resistance against spell attacks induced special effects, like freezes, knockbacks, ...
It is measured against your target's spellpower.
]]
TOOLTIP_MENTAL_SAVE = [[#GOLD#Mental saving throw#LAST#
This value represents your resistance against mental attacks induced special effects, like confusion, fear, ...
It is measured against your target's spellpower or mental power.
]]

-------------------------------------------------------------
-- Spells
-------------------------------------------------------------
TOOLTIP_SPELL_POWER = [[#GOLD#Spellpower#LAST#
Your spellpower value represents how effective/powerful your spells and magical effects are.
It is improved by both Magic, some talents can change the stats that affect it.
]]
TOOLTIP_SPELL_CRIT = [[#GOLD#Spell critical chance#LAST#
Each time you deal damage with a spell you have a chance to make a critical hit that deals 150% of the normal damage.
Some talents allow you to increase this percentage.
It is improved by Cunning.
]]
TOOLTIP_SPELL_SPEED = [[#GOLD#Spellcasting speed#LAST#
Spellcasting speed represents how fast your spellcasting is compared to a normal turn.
The lower it is the faster it is.
]]
TOOLTIP_MINDPOWER = [[#GOLD#Mindpower#LAST#
Your mindpower value represents how effective/powerful your mental effects are.
It is improved by both Willpower and Cunning, some talents can change the stats that affect it.
]]

-------------------------------------------------------------
-- Damage and resists
-------------------------------------------------------------
TOOLTIP_INC_DAMAGE_ALL = [[#GOLD#Damage increase: all#LAST#
All damage you deal, through any means, is increased by this percentage.
This stacks with individual damage type increases.
]]
TOOLTIP_INC_DAMAGE = [[#GOLD#Damage increase: specific#LAST#
All damage of this type that you deal, through any means, is increased by this percentage.
]]
TOOLTIP_INC_CRIT_POWER = [[#GOLD#Critical multiplicator#LAST#
All critical damage (melee, spells, ...) do this much damage.
]]
TOOLTIP_RESIST_ALL = [[#GOLD#Damage resistance: all#LAST#
All damage you receive, through any means, is decreased by this percentage.
This stacks with individual damage type resistances.
]]
TOOLTIP_RESIST = [[#GOLD#Damage resistance: specific#LAST#
All damage of this type that you receive, through any means, is reduced by this percentage.
]]
TOOLTIP_SPECIFIC_IMMUNE = [[#GOLD#Effect resistance chance#LAST#
This represents your chance to completely avoid the effect in question.
]]
TOOLTIP_ON_HIT_DAMAGE = [[#GOLD#Damage when hit#LAST#
Each time a creature hits your in melee it will suffer damage.
]]
TOOLTIP_RESISTS_PEN_ALL = [[#GOLD#Damage penetration: all#LAST#
Reduces the amount of effective resistance of your foes to any damage you deal by this percent.
If you have 50% penetration against a creature with 50% resistance it will have an effective resistance of 25%.
This stacks with individual damage type penetrations.
]]
TOOLTIP_RESISTS_PEN = [[#GOLD#Damage penetration: specific#LAST#
Reduces the amount of effective resistance of your foes to all damage of this type you deal by this percent.
If you have 50% penetration against a creature with 50% resistance it will have an effective resistance of 25%.
]]

-------------------------------------------------------------
-- Misc
-------------------------------------------------------------
TOOLTIP_ESP = [[#GOLD#Telepathy#LAST#
Allows you to sense creatures of the given type(s) even if they are not currently in your line of sight.
]]
TOOLTIP_ESP_RANGE = [[#GOLD#Telepathy range#LAST#
Determines the distance up to which you can sense creatures with telepathy.
]]
TOOLTIP_ESP_ALL = [[#GOLD#Telepathy#LAST#
Allows you to sense any creatures even if they are not currently in your line of sight.
]]
TOOLTIP_VISION_LITE = [[#GOLD#Lite radius#LAST#
The maximun distance your lite can light up, anything further can not be see by natural means, unless the place itself is lit.
]]
TOOLTIP_VISION_SIGHT = [[#GOLD#Sight range#LAST#
How far your sight can see, this only works in lit areas.
]]
TOOLTIP_VISION_INFRA = [[#GOLD#Infravision#LAST#
A secondary sight that allows you to see even in the dark, but only creatures can be seen this way.
]]
TOOLTIP_VISION_STEALTH = [[#GOLD#Stealth#LAST#
To use stealth one must possess the 'Stealth' talent.
Stealth allows you to try to hide from any creatures that would otehrwise see you.
Even if they have seen you they will have a harder time hitting you.
Any creature can try to see you through stealth.
]]
TOOLTIP_VISION_SEE_STEALTH = [[#GOLD#See stealth#LAST#
Your power to see stealthed creatures, the higher it is the more likely you are to see them (based on their own stealth score).
]]
TOOLTIP_VISION_INVISIBLE = [[#GOLD#Invisibility#LAST#
Invisible creatures are magically removed from the sight of all others. They can only be see by creatures that can see invisible.
]]
TOOLTIP_VISION_SEE_INVISIBLE = [[#GOLD#See invisible#LAST#
Your power to see invisible creatures, the higher it is the more likely you are to see them (based on their own invisibility score).
If you do not have any see invisible score you will never be able to see invisible creatures.
]]
