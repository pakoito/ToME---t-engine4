-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
You may find other ways to save yourself but they are not considered extra lives.
]]

TOOLTIP_LIFE = [[#GOLD#Life#LAST#
This is your life force. When you take damage this is reduced more and more.
If it reaches below zero you die.
Death is usually permanent so beware!
It is increased by Constitution.
]]

TOOLTIP_DAMAGE_SHIELD = [[#GOLD#Damage shields#LAST#
Various talents, items and powers can grant you a temporary damage shield.
They all work in slightly different manners, but usually will absorb some damage before crumbling down.
]]

TOOLTIP_UNNATURAL_BODY = [[#GOLD#Unnatrual Body Regeneration#LAST#
Your Unnatural Body talent allows you to feed off the life of your fallen foes.
Each time you kill a creature your maximum regeneration pool increases and each turn some of it transfers into your own life.
]]

TOOLTIP_LIFE_REGEN = [[#GOLD#Life Regeneration#LAST#
How much life you regenerate per turn.
This value can be improved with spells, talents, infusions, equipment.
]]

TOOLTIP_HEALING_MOD = [[#GOLD#Healing mod#LAST#
This represents how effective healing is for you.
All healing values are multiplied by this value (including life regeneration).
]]

TOOLTIP_AIR = [[#GOLD#Air#LAST#
The breath counter only appears when you are suffocating.
If it reaches zero you will die. Being stuck in a wall, being in deep water, ... all those kinds of situations will decrease your air.
When you come back into a breathable atmosphere you will slowly regain your air level.
]]

TOOLTIP_STAMINA = [[#GOLD#Stamina#LAST#
Stamina represents your physical fatigue. Each physical ability used reduces it.
It regenerates slowly over time or when resting.
It is increased by Willpower.
]]

TOOLTIP_MANA = [[#GOLD#Mana#LAST#
Mana represents your reserve of magical energies. Each spell cast consumes mana and each sustained spell reduces your maximum mana.
It is increased by Willpower.
]]

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
It does not regenerate naturally; you need to drain it from yourself or your victims.
Each time you kill a creature you drain 10% of your Willpower as Vim.
Also if you used a Corruption spell that cost Vim to kill a creature, that cost is refunded on death.
]]

TOOLTIP_EQUILIBRIUM = [[#GOLD#Equilibrium#LAST#
Equilibrium represents your standing in the grand balance of nature.
The closer it is to 0 the more in-balance you are. Being out of equilibrium will negatively affect your ability to use Wild Gifts.
]]

TOOLTIP_HATE = [[#GOLD#Hate#LAST#
Hate represents your inner rage against all that lives and dares face you.
It is replenished by killing creatures and through the application of your talents.
All afflicted talents are based on Hate, and many are more effective at higher levels of hate.
]]

TOOLTIP_PARADOX = [[#GOLD#Paradox#LAST#
Paradox represents how much damage you've caused to the spacetime continuum.
As your Paradox grows your spells will cost more to use and have greater effect; but they'll also become more difficult to control.
Your control over chronomancy spells increases with your Willpower.
]]

TOOLTIP_PSI = [[#GOLD#Psi#LAST#
Psi represents how much energy your mind can harness. Like matter, it can be neither created nor destroyed.
It regenerates naturally, though slowly, as you pull minute amounts of heat and kinetic energy from your surroundings.
To get meaningful amounts back in combat, you must absorb it through shields or various other talents.
Your capacity for storing energy is determined by your Willpower.
]]

TOOLTIP_FEEDBACK = [[#GOLD#Feedback#LAST#
Feedback represents using pain as a means of psionic grounding and it can be used to power feedback abilities.
Feedback decays at the rate of 10% or 1 per turn (which ever is greater) depending on talents.
All damage you take from an outside source will increase your Feedback based on to how much of your health is lost and your level.  First level characters gain 100 Feedback when losing 50% health, while 50th level characters gain the same amount when losing 20% health.
]]

TOOLTIP_NECROTIC_AURA = [[#GOLD#Necrotic Aura#LAST#
Represents the raw materials for creating undead minions.
It increases each time you or your minions kill something that is inside the aura radius.
]]

TOOLTIP_FORTRESS_ENERGY = [[#GOLD#Fortress Energy#LAST#
The energy of the Sher'Tul Fortress. It is replenished by transmogrifying items and used to power all the Fortress systems.
]]

TOOLTIP_LEVEL = [[#GOLD#Level and experience#LAST#
Each time you kill a creature that is over your own level - 5 you gain some experience.
When you reach enough experience you advance to the next level. There is a maximum of 50 levels you can gain.
Each time you level you gain stat and talent points to use to improve your character.
]]

TOOLTIP_ENCUMBERED = [[#GOLD#Encumbrance#LAST#
Each object you carry has an encumbrance value. Your maximum carrying capacity is determined by your strength.
You cannot move while encumbered; drop some items.
]]

TOOLTIP_INSCRIPTIONS = [[#GOLD#Inscriptions#LAST#
The people of Eyal have found a way to create herbal infusions and runes that can be inscribed on the skin of a creature.
Those inscriptions give the bearer always-accessible powers. Usually most people have a simple regeneration infusion, but there are other kind of potion inscriptions.
]]

-------------------------------------------------------------
-- Speeds
-------------------------------------------------------------
TOOLTIP_SPEED_GLOBAL = [[#GOLD#Global Speed#LAST#
Global speed represents how fast you are and affects everything you do.
Higher is faster, so at 200% global speed you can performa twice as many actions as you would at 100% speed.
Note that the amount of time to performa various actions like moving, casting spells, and attacking is also affected by their respective speeds.
]]
TOOLTIP_SPEED_MOVEMENT = [[#GOLD#Movement Speed#LAST#
How quickly you move compared to normal.
Higher is faster, so 200% means that you move twice as fast as normal.
]]
TOOLTIP_SPEED_SPELL = [[#GOLD#Spell Speed#LAST#
How quickly you cast spells.
Higher is faster, so 200% means that you can cast spells twice as fast as normal.
]]
TOOLTIP_SPEED_ATTACK = [[#GOLD#Attack Speed#LAST#
How quickly you attack with weapons, either ranged or melee.
Higher is faster, so 200% means that you can attack twice as fast as normal.
The actual speed may also be affected by the weapon used.
]]
TOOLTIP_SPEED_MENTAL = [[#GOLD#Mental Speed#LAST#
How quickly you perform mind powers.
Higher is faster, so 200% means that you can use mind powers twice as fast as normal.
]]
-------------------------------------------------------------
-- Stats
-------------------------------------------------------------
TOOLTIP_STR = [[#GOLD#Strength#LAST#
Strength defines your character's ability to apply physical force. It increases Physical Power, damage done with heavy weapons, Physical Save, and carrying capacity.
]]
TOOLTIP_DEX = [[#GOLD#Dexterity#LAST#
Dexterity defines your character's ability to be agile and alert. It increases Accuracy, Defense, chance to shrug off critical hits and your damage with light weapons.
]]
TOOLTIP_CON = [[#GOLD#Constitution#LAST#
Constitution defines your character's ability to withstand and resist damage. It increases your maximum life and Physical Save.
]]
TOOLTIP_MAG = [[#GOLD#Magic#LAST#
Magic defines your character's ability to manipulate the magical energy of the world. It increases your Spellpower, Spell Save, and the effect of spells and other magic items.
]]
TOOLTIP_WIL = [[#GOLD#Willpower#LAST#
Willpower defines your character's ability to concentrate. It increases your mana, stamina, psi capacity, Mindpower, Spell Save, and Mental Save.
]]
TOOLTIP_CUN = [[#GOLD#Cunning#LAST#
Cunning defines your character's ability to learn, think, and react. It allows you to learn many worldly abilities, and increases your Mindpower, Mental Save, and critical chance.
]]
TOOLTIP_STRDEXCON = "#AQUAMARINE#Physical stats#LAST#\n---\n"..TOOLTIP_STR.."\n---\n"..TOOLTIP_DEX.."\n---\n"..TOOLTIP_CON
TOOLTIP_MAGWILCUN = "#AQUAMARINE#Mental stats#LAST#\n---\n"..TOOLTIP_MAG.."\n---\n"..TOOLTIP_WIL.."\n---\n"..TOOLTIP_CUN

-------------------------------------------------------------
-- Melee
-------------------------------------------------------------
TOOLTIP_COMBAT_ATTACK = [[#GOLD#Accuracy#LAST#
Determines your chance to hit your target as well as knock your target off-balance when measured against the target's Defense.
When you use Accuracy to inflict temporary physical effects on an enemy, every point your opponent's relevant saving throw exceeds your accuracy will reduce the duration of the effect by 5%.
]]
TOOLTIP_COMBAT_PHYSICAL_POWER = [[#GOLD#Physical Power#LAST#
Measures your ability to deal physical damage in combat.
When you use Physical Power to inflict temporary physical effects on an enemy, every point your opponent's relevant saving throw exceeds your physical power will reduce the duration of the effect by 5%.
]]
TOOLTIP_COMBAT_DAMAGE = [[#GOLD#Damage#LAST#
This is the damage you inflict on your foes when you hit them.
This damage can be reduced by the target's armour or by percentile damage resistances.
It is improved by Strength or Dexterity, depending on your weapon. Some talents can change the stats that affect it.
]]
TOOLTIP_COMBAT_APR = [[#GOLD#Armour Penetration#LAST#
Armour penetration allows you to ignore a part of the target's armour (this only works for armour, not damage resistance).
This can never increase the damage you do beyond reducing armour, so it is only useful against armoured foes.
]]
TOOLTIP_COMBAT_CRIT = [[#GOLD#Critical chance#LAST#
Each time you deal damage you have a chance to make a critical hit that deals extra damage.
Some talents allow you to increase this percentage.
It is improved by Cunning.
]]
TOOLTIP_COMBAT_SPEED = [[#GOLD#Attack speed#LAST#
Attack speed represents how fast your attacks are compared to normal.
Higher is faster, representing more attacks performed in the same amount of time.
]]
TOOLTIP_COMBAT_RANGE = [[#GOLD#Firing range#LAST#
The maximum distance your weapon can reach.
]]
TOOLTIP_COMBAT_AMMO = [[#GOLD#Ammo remaining#LAST#
This is the amount of ammo you have left.
Bows and slings must be reloaded when this reaches 0.
Alchemists use gems as ammo to throw bombs.
]]

-------------------------------------------------------------
-- Defense
-------------------------------------------------------------
TOOLTIP_FATIGUE = [[#GOLD#Fatigue#LAST#
Fatigue is a percentile value that increases the cost of your talents and spells.
It represents the fatigue created by wearing heavy equipment.
Not all talents are affected; notably, Wild Gifts are not.
]]
TOOLTIP_ARMOR = [[#GOLD#Armour#LAST#
Armour value is a damage reduction from all incoming melee and ranged physical attacks.
Absorbs (hardiness)% of incoming physical damage, up to a maximum of (armour) damage absorbed.
This is countered by armour penetration and is applied before all kinds of critical damage increase, talent multipliers and damage multiplier, thus making even small amounts have greater effects.
]]
TOOLTIP_ARMOR_HARDINESS = [[#GOLD#Armour Hardiness#LAST#
Armour hardiness represents how much of each incoming blows the armour will affect.
Absorbs (hardiness)% of incoming physical damage, up to a maximum of (armour) damage absorbed.
]]
TOOLTIP_CRIT_REDUCTION = [[#GOLD#Crit Reduction#LAST#
Crit reduction reduces the chance an opponent has of landing a critical strike with a melee or ranged attack.
]]
TOOLTIP_CRIT_SHRUG = [[#GOLD#Crits Shrug Off#LAST#
Gives a chance to ignore the bonus critical damage from any direct damage attacks (melee, spells, ranged, mind powers, ...).
]]
TOOLTIP_DEFENSE = [[#GOLD#Defense#LAST#
Defense represents your chance to avoid physical melee attacks and reduces the chance you'll be knocked off-balance by an enemy's attack. It is measured against the attacker's Accuracy.
]]
TOOLTIP_RDEFENSE = [[#GOLD#Ranged Defense#LAST#
Defense represents your chance to avoid physical ranged attacks and reduces the chance you'll be knocked off-balance by an enemy's attack. It is measured against the attacker's Accuracy.
]]
TOOLTIP_PHYS_SAVE = [[#GOLD#Physical saving throw#LAST#
Increases chance to shrug off physically-induced effects.  Also reduces duration of detrimental physical effects by up to 5% per point, depending on the power of the opponent's effect.
]]
TOOLTIP_SPELL_SAVE = [[#GOLD#Spell saving throw#LAST#
Increases chance to shrug off magically-induced effects.  Also reduces duration of detrimental magical effects by up to 5% per point, depending on the power of the opponent's effect.
]]
TOOLTIP_MENTAL_SAVE = [[#GOLD#Mental saving throw#LAST#
Increases chance to shrug off mentally-induced effects.  Also reduces duration of detrimental mental effects by up to 5% per point, depending on the power of the opponent's effect.
]]

-------------------------------------------------------------
-- Spells
-------------------------------------------------------------
TOOLTIP_SPELL_POWER = [[#GOLD#Spellpower#LAST#
Your spellpower represents how powerful your magical spells are.
In addition, when your spells inflict temporary detrimental effects, every point your opponent's relevant saving throw exceeds your spellpower will reduce the duration of the effect by 5%.
]]
TOOLTIP_SPELL_CRIT = [[#GOLD#Spell critical chance#LAST#
Each time you deal damage with a spell you may have a chance to make a critical hit that deals extra damage.
Some talents allow you to increase this percentage.
It is improved by Cunning.
]]
TOOLTIP_SPELL_SPEED = [[#GOLD#Spellcasting speed#LAST#
Spellcasting speed represents how fast your spellcasting is compared to normal.
Higher is faster - 200% means that you cast spells twice as fast as someone at 100%.
]]
TOOLTIP_SPELL_COOLDOWN = [[#GOLD#Spellcooldown#LAST#
Spell cooldown represents how fast your spells will come off of cooldown.
The lower it is, the more often you'll be able to use your spell talents and runes.
]]
-------------------------------------------------------------
-- Mental
-------------------------------------------------------------
TOOLTIP_MINDPOWER = [[#GOLD#Mindpower#LAST#
Your mindpower represents how powerful your mental abilities are.
In addition, when your mental abilities inflict temporary detrimental effects, every point your opponent's relevant saving throw exceeds your mindpower will reduce the duration of the effect by 5%.
]]
TOOLTIP_MIND_CRIT = [[#GOLD#Mental critical chance#LAST#
Each time you deal damage with a mental attack you may have a chance to make a critical hit that deals extra damage.
Some talents allow you to increase this percentage.
It is improved by Cunning.
]]
TOOLTIP_MIND_SPEED = [[#GOLD#Mental speed#LAST#
Mental speed represents how fast you use psionic abilities compared to normal.
Higher is faster.
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
TOOLTIP_INC_CRIT_POWER = [[#GOLD#Critical multiplier#LAST#
All critical hits (melee, spells, ...) do this much damage.
]]
TOOLTIP_RESIST_ALL = [[#GOLD#Damage resistance: all#LAST#
All damage you receive, through any means, is decreased by this percentage.
This stacks with individual damage type resistances.
]]
TOOLTIP_RESIST = [[#GOLD#Damage resistance: specific#LAST#
All damage of this type that you receive, through any means, is reduced by this percentage.
]]
TOOLTIP_AFFINITY_ALL = [[#GOLD#Damage affinity: all#LAST#
All damage you receive, through any means, also heals you for this percentage of the damage.
This stacks with individual damage type affinities.
Important: Affinity healing happens after damage has been taken, it can not prevent death.
]]
TOOLTIP_AFFINITY = [[#GOLD#Damage affinity: specific#LAST#
All damage of this type that you receive, through any means, also heals you for this percentage of the damage..
Important: Affinity healing happens after damage has been taken, it can not prevent death.
]]
TOOLTIP_SPECIFIC_IMMUNE = [[#GOLD#Effect resistance chance#LAST#
This represents your chance to completely avoid the effect in question.
]]
TOOLTIP_ON_HIT_DAMAGE = [[#GOLD#Damage when hit#LAST#
Each time a creature hits you in melee it will suffer damage.
]]
TOOLTIP_RESISTS_PEN_ALL = [[#GOLD#Damage penetration: all#LAST#
Reduces the amount of effective resistance of your foes to any damage you deal by this percent.
If you have 50% penetration against a creature with 50% resistance it will have an effective resistance of 25%.
This stacks with individual damage type penetrations.
]]
TOOLTIP_RESISTS_PEN = [[#GOLD#Damage penetration: specific#LAST#
Reduces the amount of effective resistance of your foes to all damage you deal of this type by this percent.
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
The maximum distance your lite can light up. Anything further cannot be seen by natural means, unless the place itself is lit.
]]
TOOLTIP_VISION_SIGHT = [[#GOLD#Sight range#LAST#
How far you can see. This only works within your lite radius, or in lit areas.
]]
TOOLTIP_VISION_INFRA = [[#GOLD#Heightened Senses#LAST#
Special vision (including infravision) that works even in the dark, but only creatures can be seen this way.  Only the best ability is used.
]]
TOOLTIP_VISION_STEALTH = [[#GOLD#Stealth#LAST#
To use stealth one must possess the 'Stealth' talent.
Stealth allows you to try to hide from any creatures that would otherwise see you.
Even if they have seen you they will have a harder time hitting you.
Any creature can try to see through your stealth.
]]
TOOLTIP_VISION_SEE_STEALTH = [[#GOLD#See stealth#LAST#
Your power to see stealthed creatures. The higher it is, the more likely you are to see them (based on their own stealth score).
]]
TOOLTIP_VISION_INVISIBLE = [[#GOLD#Invisibility#LAST#
Invisible creatures are magically removed from the sight of all others. They can only be see by creatures that can see invisible.
]]
TOOLTIP_VISION_SEE_INVISIBLE = [[#GOLD#See invisible#LAST#
Your power to see invisible creatures. The higher it is, the more likely you are to see them (based on their own invisibility score).
If you do not have any see invisible score you will never be able to see invisible creatures.
]]
