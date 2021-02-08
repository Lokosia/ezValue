# ezValue
Tool for getting value of items in online RPG Path of Exile.

## Introduction
**As of ver 0.0.1**
This programm is based on reddit post https://www.reddit.com/r/pathofexile/comments/56rtmk/the_is_this_item_worth_something_guide/

Code inspired by ItemInfo https://github.com/aRTy42/POE-ItemInfo

All you have to do in game is hover over an item and press Ctrl+C, that way item info will be copied to clipboard and ezValue will show main affixes according to reddit post.
Tooltip will appear with item information and recommendation, to use item if it's at least ok, or to sell it to NPC. If item have at least 2 good affixes with recommended numbers, it's rating will be 2+ which means item is overall good and usable. As higher it's sum rating, the better the item. Value of item should show number according to 100% scale, where 2 mods with desirable numbers give 1.00(or 100%), and 1 mod gives only 0.5 (or 50%).

## My changes
Towards reddit post - item appraisal is dynamic, for example while according to post you need "at least 75 life" on body armour, ezValue will show rating of existing Life value by simple formula

`(item affix value/reddit post value goal)`

I hope this helps players to easily get what item could be worth of something, or if it is scrap. It is also could be very useful for SSF players, because there is no actual point in getting selling price of item in trade league.

Also the goal of this script is to be maximally lightweight and easy changeble.

## Requirements
For now ezValue require you to have AutoHotkey to be able to run https://www.autohotkey.com/

## Roadmap
- Refactor code - make it more beautiful, organized and so there is no ItemInfo code used (most of it uses deprecated AHK functions)
- Add small GUI, so user will be able to change behavior of Tooltip and its content
- Make representaion of ezValue information more distinct, maybe by adding colors to tooltip like in popular MMOs (common, uncommon, rare, epic legenady) according to item total value
- (?) Add an option for user to individually set weights of affixes or choose weight profile, so for example when starting a new character with physical build, affixes with elemental damage wont have any weight

- Add affix counter - if there is an open affix, mention in in tooltip with recommendation to add craft, and give some rating to possible crafts
- Add quality counter - if item is not corrupted, quality of item is not at least 20% then recommend to increase its quality

- (?) Add map affix warning - there is an interesting feature in ItemInfo that could warn you about bad map mods, that could be helpful for initial map check and to check it after corruption if there is mods that you character is afraid of. I'm still not sure if I should add same feature here

- Rebalance values - as of now that reddit post is 4 years old, there is probably some improvements could be used
- Add more usable affixes - there is good affixes like the Conquerors ones that is guaranteed good, but not mentioned in the post, probably there is even more standart affixes that should be added
