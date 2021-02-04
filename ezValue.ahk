#NoEnv
#Persistent
#SingleInstance, force
SetWorkingDir, %A_ScriptDir%
SendMode Input
#Include, %A_ScriptDir%\lib\JSON.ahk
#Include, %A_ScriptDir%\lib\ToolTipOpt.ahk
ToolTipFont("s14", "Arial")
ToolTipColor("Black", "White")

GetItemFromClipboard() {
    ; Verify the information is what we're looking for
    if RegExMatch(clipboard, "Rarity: .*?\R.*?\R?.*?\R--------\R.*") = 0 {
        ;MsgBox % "Not a PoE item"
		return false
    }
    return clipboard
}

OnClipboardChange:
	Global item := GetItemFromClipboard()
	if (item){
		tempItem := StrReplace(item, "`r`n--------`r`n", "``")
		tempItem := StrSplit(tempItem, "``")

		namePlate	:= tempItem[1]
		stats		:= tempItem[2]
		requirements := tempItem[3]
		sockets := tempItem[4]
		ilvl := tempItem[5]
		prefsuf := tempItem[6]

		indexLast := tempItem[0]
		partsLast := tempItem[%indexLast%]

		;item name
		RegExMatch(item, "(?<=\n)\D+(?=\n-------)", itemName)
		;item type
		itemType := parseItemType(stats, namePlate)[2]

		parsedItem := parseItemType(stats, namePlate)
		rating := ratingCounter(parsedItem[2], stats, parsedItem[3])
		totalRating := rating[1]

		descriptionRating := rating[2]
		descriptionArray := [0, 0, 0, 0, 0, 0]
		
		descriptionArray[1] := "-"descriptionRating[1]"% for CORRUPTED and not full link and qual`n"
		descriptionArray[2] := "+"descriptionRating[2]" for " life1 " Life`n"
		descriptionArray[3] := "+"descriptionRating[3]" for " es1 " Total Energy Shield`n"
		descriptionArray[4] := "+"descriptionRating[4]" for " life2 " Life on Energy/Energy hybrid base`n"
		descriptionArray[5] := "+"descriptionRating[5]" for " es2 " ES on Energy/Energy hybrid base`n"
		descriptionArray[6] := "+"descriptionRating[6]" for " STR " STR`n"
		descriptionArray[7] := "+"descriptionRating[7]" for " INT " INT`n"
		descriptionArray[8] := "+"descriptionRating[8]" for " totalResistance "% Total Resistance`n"
		descriptionArray[9] := "+"descriptionRating[9]" for " accuracy " Accuracy`n"
		descriptionArray[10] := "+"descriptionRating[10]" for " ms " Movement Speed`n"
		descriptionArray[11] := "+"descriptionRating[11]" for " aspd " Attack Speed`n"
		descriptionArray[12] := "+"descriptionRating[12]" for " DEX " DEX`n"
		descriptionArray[13] := "+"descriptionRating[13]" for " spellDMG " Spell Damage`n"
		descriptionArray[14] := "+"descriptionRating[14]" for " spellCritChance " Spell Critical Strike Chance`n"
		descriptionArray[15] := "+"descriptionRating[15]" for " physInc "% increased Physical Damage`n"
		descriptionArray[16] := "+"descriptionRating[16]" for " physFlat " flat Physical Damage`n"
		descriptionArray[17] := "+"descriptionRating[17]" for " weaponCritChance " increased Critical Strike Chance`n"
		descriptionArray[18] := "+"descriptionRating[18]" for " globalCritMulti " to Global Critical Strike Multiplier`n"
		descriptionArray[19] := "+"descriptionRating[19]" for " socketedBowGems " to Socketed Bow Gems`n"
		descriptionArray[20] := "+"descriptionRating[20]" for " elementalFlat1H " Elemental Damage on 1H weapon`n"
		descriptionArray[21] := "+"descriptionRating[21]" for " elementalFlat2H " Elemental Damage on 2H weapon`n"
		descriptionArray[22] := "+"descriptionRating[22]" for " elementalSpellDMG " Elemental Spell Damage`n"
		descriptionArray[23] := "+"descriptionRating[23]" for " spellCritChance " total Critical Strike Chance for Spells`n"
		descriptionArray[24] := "+"descriptionRating[24]" for " elementalFlatSpells " Elemental Damage to Spells`n"
		descriptionArray[25] := "+"descriptionRating[25]" for " socketedGems " to Socketed Gems`n"
		descriptionArray[26] := "+"descriptionRating[26]" for " socketedElemGems " to Socketed Elemental Gems`n"
		descriptionArray[27] := "+"descriptionRating[27]" for " life3 "% Life`n"
		descriptionArray[28] := "+"descriptionRating[28]" for " es3 "% Energy Shield`n"
		descriptionArray[29] := "+"descriptionRating[29]" for " castSpeed "% Cast Speed`n"
		descriptionArray[30] := "+"descriptionRating[30]" for " aspdRolls " Attack Speed rolls`n"
		descriptionArray[31] := "+"descriptionRating[31]" for " damageRolls " Damage rolls`n"
		descriptionArray[32] := "+"descriptionRating[32]" for " armour " to Armour`n"
		descriptionArray[33] := "+"descriptionRating[33]" for " es4 " to maximum Energy Shield`n"
		descriptionArray[34] := "+"descriptionRating[34]" for " flaskRedCharges "% reduced Flask Charges used`n"
		descriptionArray[35] := "+"descriptionRating[35]" for " flaskIncCharges "% increased Flask Charges gained`n"
		descriptionArray[36] := "+"descriptionRating[36]" for " flaskEffDuration "% increased Flask Effect Duration`n"
		descriptionArray[37] := "+"descriptionRating[37]" for " incRarity "% increased Rarity of Items found`n"
		descriptionArray[38] := "+"descriptionRating[38]" for " manaReg "% increased Mana Regeneration Rate`n"
		descriptionArray[39] := "+"descriptionRating[39]" for " totalAttributes " to Total Attributes`n"
		
		description := ""
		Loop % ObjLength(descriptionArray)
		{
			if (descriptionRating[A_Index] != 0) {
				description := description descriptionArray[A_Index]
			}
		}
		description := SubStr(description, 1 , StrLen(description)-1)
		value := (totalRating/2)
		if (value < 1){
			verdict := "Bad item, vend to NPC or reroll"
		} else {
			verdict := "Good item, use it"
		}
		;form tooltip
		finalString = %itemName%`n`n%description%`nSum Rating: %totalRating%`n`nValue: %value%`nVerdict: %verdict%
		;show tooltip
		Tooltip % finalString
		;delete tooltip in 5 sec
		SetTimer, RemoveToolTip, -5000
	}
	return

RemoveToolTip:
	ToolTip
	return

armorBase(byRef stats, neededBase, hybrid:=0){
	if (neededBase == "Armour"){
		if (hybrid == 0){
			if ((RegExMatch(stats, "Armour") != 0) and (RegExMatch(stats, "Evasion") == 0) and (RegExMatch(stats, "Energy") == 0)){
				return true
			}
		} else {
			if ((RegExMatch(stats, "Armour") != 0) and ((RegExMatch(stats, "Evasion") != 0) or (RegExMatch(stats, "Energy") != 0))) {
				return true
			}
		}
	}
	if (neededBase == "Evasion"){
		if (hybrid == 0){
			if ((RegExMatch(stats, "Armour") == 0) and (RegExMatch(stats, "Evasion") != 0) and (RegExMatch(stats, "Energy") == 0)){
				return true
			}
		} else {
			if ((RegExMatch(stats, "Evasion") != 0) and ((RegExMatch(stats, "Armour") != 0) or (RegExMatch(stats, "Energy") != 0))) {
				return true
			}
		}
	}
	if (neededBase == "Energy"){
		if (hybrid == 0){
			if ((RegExMatch(stats, "Armour") == 0) and (RegExMatch(stats, "Evasion") == 0) and (RegExMatch(stats, "Energy") != 0)){
				return true
			}
		} else {
			if ((RegExMatch(stats, "Energy") != 0) and ((RegExMatch(stats, "Armour") != 0) or (RegExMatch(stats, "Evasion") != 0))) {
				return true
			}
		}
	}
	return false
}

convertStat(affixStat, fullStat, ByRef rating, ByRef ratingTable, ratingTableIndex){
	convertedStat := affixStat/fullStat
	rating += %convertedStat%
	ratingTable[ratingTableIndex] += convertedStat
}

affShort(affix, numberToCheck, ByRef rating, ByRef ratingTable, ByRef stats){
	if (affix == 2) {
		if (!armorBase(stats, "Energy", 1) and !armorBase(stats, "Energy")){
			Global life1
			life1 := getAff(" to maximum Life")
			convertStat(life1, numberToCheck, rating, ratingTable, affix)
		}
	}
	if (affix == 3) {
		Global es1
		es1 := getArmor(stats, "Energy Shield")
		convertStat(es1, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 4) {
		if (armorBase(stats, "Energy", 1) or armorBase(stats, "Energy")){
			Global life2
			life2 := getAff(" to maximum Life")
			convertStat(life2, numberToCheck*2, rating, ratingTable, affix)
			
		}
	}
	if (affix == 5) {
		if (armorBase(stats, "Energy", 1) or armorBase(stats, "Energy")){
			Global es2
			es2 := getArmor(stats, "Energy Shield")
			convertStat(es2, numberToCheck*2, rating, ratingTable, affix)
		}
	}
	if (affix == 6) {
		Global STR
		str1 := getAff(" to Strength")
		str2 := getAff(" to all Attributes")
		STR := (str1+str2)
		convertStat(STR, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 7) {
		Global INT
		int1 := getAff(" to Intelligence")
		int2 := getAff(" to all Attributes")
		INT := (int1+int2)
		convertStat(INT, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 8) {
		Global totalResistance
		fire := getAff("% to Fire Resistance")
		cold := getAff("% to Cold Resistance")
		lightning := getAff("% to Lightning Resistance")
		chaos := getAff("% to Chaos Resistance")
		fchaos := getAff("% to Fire and Chaos Resistances")*2
		cchaos := getAff("% to Cold and Chaos Resistances")*2
		lchaos := getAff("% to Lightning and Chaos Resistances")*2
		allElements := getAff("% to all Elemental Resistances")*3
		fireAndCold := getAff("% to Fire and Cold Resistances")*2
		coldAndLightning := getAff("% to Cold and Lightning Resistances")*2
		fireAndLightning := getAff("% to Fire and Lightning Resistances")*2

		totalResistance := (fire+cold+lightning+allElements+fireAndCold+coldAndLightning+fireAndLightning+chaos+cchaos+fchaos+lchaos)
		convertStat(totalResistance, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 9) {
		Global accuracy
		accuracy := getAff(" to Accuracy Rating")
		convertStat(accuracy, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 10) {
		Global ms
		ms := getAff("% increased Movement Speed")
		convertStat(ms, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 11) {
		Global aspd
		aspd := getAff("% increased Attack Speed")
		comboSpeed := getAff("% increased Attack and Cast Speed")
		aspd += comboSpeed
		convertStat(aspd, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 12) {
		Global DEX
		DEX := getAff(" to Dexterity")
		dex2 := getAff(" to all Attributes")
		DEX += dex2
		convertStat(DEX, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 13) {
		Global spellDMG
		spellDMG := getAff("% increased Spell Damage")
		convertStat(spellDMG, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 14) {
		Global spellCritChance
		spellCritChance := getAff("% increased Critical Strike Chance for Spells")
		convertStat(spellCritChance, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 15) {
		Global physInc
		physInc := getAff("% increased Physical Damage")
		convertStat(physInc, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 16) {
		Global physFlat
		physFlat := getAff(" Physical Damage")
		convertStat(physFlat, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 17) {
		Global weaponCritChance
		weaponCritChance := getAff("% increased Critical Strike Chance")
		globalCritChance := getAff("% increased Global Critical Strike Chance")
		weaponCritChance += globalCritChance
		convertStat(weaponCritChance, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 18) {
		Global globalCritMulti
		globalCritMulti := getAff("% to Global Critical Strike Multiplier")
		convertStat(globalCritMulti, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 19) {
		Global socketedBowGems
		socketedBowGems := getAff(" to Level of Socketed Bow Gems")
		addSocketedGems := getAff(" to Level of Socketed Gems")
		socketedBowGems += addSocketedGems
		convertStat(socketedBowGems, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 20) {
		global elementalFlat1H
		modsNum := 0
		flatCold := getAff(" Cold Damage")
		if (flatCold != 0) {
			modsNum++
		}
		flatFire := getAff(" Fire Damage")
		if (flatFire != 0) {
			modsNum++
		}
		flatLightning := getAff(" Lightning Damage")
		flatLightning := getAff(" Lightning Damage")
		if (flatLightning != 0) {
			modsNum++
		}
		addLightning := 0
		if (flatLightning != 0){
			addLightning := (50*2)/modsNum
		}
		
		elementalFlat1H := (flatCold+flatFire+flatLightning)
		convertStat(elementalFlat1H, numberToCheck + addLightning, rating, ratingTable, affix)
	}
	if (affix == 21) {
		global elementalFlat2H
		modsNum := 0
		flatCold := getAff(" Cold Damage")
		if (flatCold != 0) {
			modsNum++
		}
		flatFire := getAff(" Fire Damage")
		if (flatFire != 0) {
			modsNum++
		}
		flatLightning := getAff(" Lightning Damage")
		if (flatLightning != 0) {
			modsNum++
		}
		addLightning := 0
		if (flatLightning != 0){
			addLightning := (90*2)/modsNum
		}
		elementalFlat2H := (flatCold+flatFire+flatLightning)
		convertStat(elementalFlat2H, numberToCheck + addLightning, rating, ratingTable, affix)
	}
	if (affix == 22) {
		global elementalSpellDMG
		spellFire := getAff("% increased Fire Damage")
		spellCold := getAff("% increased Cold Damage")
		spellLightning := getAff("% increased Lightning Damage")

		spellGlobal := getAff("% increased Spell Damage")
		spellElementalGlobal := getAff("% increased Elemental Damage")

		elementalSpellDMG := (spellFire + spellCold + spellLightning + spellGlobal + spellElementalGlobal)
		convertStat(elementalSpellDMG, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 23) {
		global spellCritChance
		spellCritChance := getAff("% increased Critical Strike Chance for Spells")
		globalCritChance := getAff("% increased Global Critical Strike Chance")
		spellCritChance += globalCritChance
		convertStat(spellCritChance, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 24) {
		global elementalFlatSpells
		flatFireSpell := getAff(" Fire Damage to Spells")
		flatColdSpell := getAff(" Cold Damage to Spells")
		flatLightningSpell := getAff(" Lightning Damage to Spells")
		addLightning := 0
		if (flatLightningSpell != 0){
			addLightning = 40
		}
		elementalFlatSpells := (flatFireSpell + flatColdSpell + flatLightningSpell)
		convertStat(elementalFlatSpells, numberToCheck + addLightning, rating, ratingTable, affix)
	}
	if (affix == 25) {
		Global socketedGems
		socketedGems := getAff(" to Level of Socketed Gems")
		convertStat(socketedGems, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 26) {
		Global socketedElemGems
		fireGem := getAff(" to Level of Socketed Fire Gems")
		coldGem := getAff(" to Level of Socketed Cold Gems")
		lightningGem := getAff(" to Level of Socketed Lightning Gems")
		elementalGem := getAff(" to Level of Socketed Elemental Gems")
		socketedOverallGems := getAff(" to Level of Socketed Gems")
		socketedElemGems := (fireGem + coldGem + lightningGem + elementalGem + socketedOverallGems)

		convertStat(socketedElemGems, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 27) {
		Global life3
		life3 := getAff("% increased maximum Life")
		convertStat(life3, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 28) {
		Global es3
		es3 := getAff("% increased maximum Energy Shield")
		convertStat(es3, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 29) {
		Global castSpeed
		castSpeed := getAff("% increased Cast Speed")
		comboSpeed := getAff("% increased Attack and Cast Speed")
		castSpeed += comboSpeed
		convertStat(castSpeed, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 30) {
		Global aspdRolls
		needle := "increased.+Speed"
		regexReplace(item, needle, needle, aspdRolls)
		convertStat(aspdRolls, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 31) {
		Global damageRolls
		needle := "increased.+Damage"
		regexReplace(item, needle, needle, damageRolls)
		convertStat(damageRolls, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 32) {
		Global armour
		armour := getAff(" to Armour")
		convertStat(armour, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 33) {
		Global es4
		es4 := getAff(" to maximum Energy Shield")
		convertStat(es4, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 34) {
		Global flaskRedCharges
		flaskRedCharges := getAff("% reduced Flask Charges used")
		convertStat(flaskRedCharges, flaskRedCharges, rating, ratingTable, affix)
	}
	if (affix == 35) {
		Global flaskIncCharges
		flaskIncCharges := getAff("% increased Flask Charges gained")
		convertStat(flaskIncCharges, flaskIncCharges, rating, ratingTable, affix)
	}
	if (affix == 36) {
		Global flaskEffDuration
		flaskEffDuration := getAff("% increased Flask Effect Duration")
		convertStat(flaskEffDuration, flaskEffDuration, rating, ratingTable, affix)
	}
	if (affix == 37) {
		Global incRarity
		incRarity := getAff("% increased Rarity of Items found")
		convertStat(incRarity, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 38) {
		Global manaReg
		manaReg := getAff("% increased Mana Regeneration Rate")
		convertStat(manaReg, numberToCheck, rating, ratingTable, affix)
	}
	if (affix == 39) {
		Global totalAttributes
		tempDEX := getAff(" to Dexterity")
		tempSTR := getAff(" to Strength")
		tempINT := getAff(" to Intelligence")
		totalAttributes := getAff(" to all Attributes")*3

		totalAttributes += (tempDEX + tempSTR + tempINT)
		convertStat(totalAttributes, numberToCheck, rating, ratingTable, affix)
	}
}

ratingCounter(itemType, stats, gripType:="1H"){
	;used as a result itself
	rating = 0
	;used for tooltip strings
	ratingTable := []
	Loop, 39
	{
		ratingTable[A_Index] := 0
	}
	;1 if corrupted
	;2 life on armor or/and evasion base
	;3 es
	;4 es on es or hybrid base
	;5 life on es or hybrid base
	;6 str
	;7 int
	;8 total res
	;9 to accuracy rating
	;10 to movement speed
	;11 to attack speed
	;12 DEX
	;13 spell damage
	;14 spell critical strike chance
	;15 % increased Physical Damage
	;16 flat Physical damage
	;17 weapon crit chance
	;18 crit multi
	;19 socketed bow gems
	;20 flat elemental 1 handed
	;21 flat elemental 2 handed
	;22 elemental spell damage
	;23 critical strike chance for spells
	;24 flat elemental damage to spells
	;25 socketed gems
	;26 socketed elemental gems
	;27 % life
	;28 % es
	;29 % cast speed
	;30 any attack speed roll
	;31 any damage roll
	;32 armour (on belt, in affixes)
	;33 es (on belt, in affixes)
	;34 redused flask charges used
	;35 increased flask charges gained
	;36 increased flask effect duration
	;37 increased rarity of items found
	;38 mana regen rate
	;39 total attributes

	;if body armour - check for body armor suffs
	if (itemType == "BodyArmour") {
		;life 75+ on armor/evasion base
		affShort(2, 75, rating, ratingTable, stats)
		
		;Energy shield 575+
		affShort(3, 575, rating, ratingTable, stats)
		
		;if energy shield base or hybrid
		;life 70+
		affShort(4, 70, rating, ratingTable, stats)
		;Energy shield 350+
		affShort(5, 350, rating, ratingTable, stats)
		
		;if armour base
		if (armorBase(stats, "Armour")){
			;str 40+
			affShort(6, 40, rating, ratingTable, stats)
		}
		
		;if energy base
		if (armorBase(stats, "Energy")){
			;int 40+
			affShort(7, 40, rating, ratingTable, stats)
		}

		;total elemental resistance 80+
		affShort(8, 80, rating, ratingTable, stats)
	}
	
	if (itemType == "Helmet") {
		;life 65+ on armor/evasion base
		affShort(2, 65, rating, ratingTable, stats)

		;Energy shield 350+
		affShort(3, 350, rating, ratingTable, stats)

		;if energy shield base or hybrid
		;life 65+
		affShort(4, 65, rating, ratingTable, stats)
		;Energy shield 200+
		affShort(5, 200, rating, ratingTable, stats)

		;accuracy 300+
		affShort(9, 300, rating, ratingTable, stats)

		;if armor or evasion base
		if (!armorBase(stats, "Energy", 1) and !armorBase(stats, "Energy")){
			;int 40
			affShort(7, 40, rating, ratingTable, stats)
		}

		;total resistance 80
		affShort(8, 80, rating, ratingTable, stats)
	}

	if (itemType == "Boots") {
		;movement speed 20+
		affShort(10, 20, rating, ratingTable, stats)

		;life 65+ on armor/evasion base
		affShort(2, 65, rating, ratingTable, stats)

		;Energy shield 130+
		affShort(3, 130, rating, ratingTable, stats)

		;if energy shield base or hybrid
		;65+ life
		affShort(4, 65, rating, ratingTable, stats)
		;90+ es
		affShort(5, 90, rating, ratingTable, stats)

		;str 40+
		affShort(6, 40, rating, ratingTable, stats)
		
		;int 40+
		affShort(7, 40, rating, ratingTable, stats)

		;total resistance 70
		affShort(8, 70, rating, ratingTable, stats)
	}

	if (itemType == "Gloves") {
		;life 65+ on armor/evasion base
		affShort(2, 65, rating, ratingTable, stats)

		;Energy shield 150+
		affShort(3, 150, rating, ratingTable, stats)

		;if energy shield base or hybrid
		;65+ life
		affShort(4, 65, rating, ratingTable, stats)
		;100+ es
		affShort(5, 100, rating, ratingTable, stats)

		;total resistance
		affShort(8, 80, rating, ratingTable, stats)

		;accuracy 300+
		affShort(9, 300, rating, ratingTable, stats)

		;attack speed 10+
		affShort(11, 10, rating, ratingTable, stats)

		;if armour or energy shield base
		if (!armorBase(stats, "Evasion") and !armorBase(stats, "Evasion", 1)){
			;40+ dex
			affShort(12, 40, rating, ratingTable, stats)
		}
	}

	if (itemType == "Shield") {
		;80+ life if armour or evasion abse
		affShort(2, 80, rating, ratingTable, stats)

		;Energy shield 350+
		affShort(3, 350, rating, ratingTable, stats)
		
		;if energy shield base or hybrid
		;80+ life
		affShort(4, 80, rating, ratingTable, stats)
		;280+ es
		affShort(5, 280, rating, ratingTable, stats)

		;total resistance
		affShort(8, 100, rating, ratingTable, stats)

		;if armour base
		if (armorBase(stats, "Armour")){
			;str 35+
			affShort(6, 35, rating, ratingTable, stats)
		}
		
		;if energy base
		if (armorBase(stats, "Energy")){
			;int 35+
			affShort(7, 35, rating, ratingTable, stats)
		}

		;55+ spell damage
		affShort(13, 55, rating, ratingTable, stats)

		;80+ spell crit chance
		affShort(14, 80, rating, ratingTable, stats)
	}

	if ((itemType == "Sword") or (itemType == "Axe") or (itemType == "Mace") or (itemType == "Claw") or (itemType == "Bow")) {
		;phys increased 170+
		affShort(15, 170, rating, ratingTable, stats)

		if (gripType == "2H"){
			;xx to xx flat phys
			affShort(16, 50, rating, ratingTable, stats)
			;elemental damage 2h
			affShort(21, 100*2, rating, ratingTable, stats)
		} else {
			;1H weapon
			;xx to xx flat phys
			affShort(16, 33, rating, ratingTable, stats)
			;elemental damage 1h
			affShort(20, 70*2, rating, ratingTable, stats)
		}

		;attack speed 20+
		affShort(11, 20, rating, ratingTable, stats)

		if (itemType == "Bow") {
			;weapon crit chance 30+
			affShort(17, 30, rating, ratingTable, stats)
			;crit multi 30+
			affShort(18, 30, rating, ratingTable, stats)
			;+2 socketed bow gems
			affShort(19, 2, rating, ratingTable, stats)
		}
	}

	if ((itemType == "Dagger") or (itemType == "Wand") or (itemType == "Sceptre")) {
		;Caster
		;elemental spell damage 90+
		affShort(22, 90, rating, ratingTable, stats)
		;130+ critical strike chance for spells
		affShort(23, 130, rating, ratingTable, stats)
		;flat elemental damage to spells
		affShort(24, 50, rating, ratingTable, stats)
		;crit multi 30+
		affShort(18, 30, rating, ratingTable, stats)

		;Attack dagger or wand
		if ((itemType == "Dagger") or (itemType == "Wand")) {
			;phys increased 170+
			affShort(15, 170, rating, ratingTable, stats)
			;xx to xx flat phys
			affShort(16, 33, rating, ratingTable, stats)

			;attack speed 20+
			if (itemType == "Dagger") {
				dorw := 20
			} else {
				dorw := 10
			}
			affShort(11, dorw, rating, ratingTable, stats)

			;weapon crit chance 30+
			affShort(17, 30, rating, ratingTable, stats)
			;crit multi 30+
			affShort(18, 30, rating, ratingTable, stats)

			;elemental damage 1h
			affShort(20, 70, rating, ratingTable, stats)
		}
	}
	
	if ((itemType == "Staff") or (itemType == "Warstaff")){
		;+1 to socketed gems AND +2 to socketed elem gems
		affShort(26, 3, rating, ratingTable, stats)

		;elemental damage 2h, but counting as 1h 
		;TODO: flat elem damage on staffs are individual compared to method in affShort,
		;now it is not precise enough also because of lightning damage
		;(it is higher than in the other weapon types)
		;because of that we count it as 1h weapon
		affShort(20, 70, rating, ratingTable, stats)

		;elemental spell damage 160+
		affShort(22, 160, rating, ratingTable, stats)
	}
	
	if (itemType == "Jewel"){
		;% Life, 6 is middle value of all possible
		affShort(27, 6, rating, ratingTable, stats)
		;% ES
		affShort(28, 6, rating, ratingTable, stats)
		;% Cast speed
		affShort(29, 3, rating, ratingTable, stats)
		;% crit multi
		affShort(18, 10.5, rating, ratingTable, stats)
		;number of aspd compatible rolls
		affShort(30, 2, rating, ratingTable, stats)
		;% damage compatible rolls
		affShort(31, 2, rating, ratingTable, stats)
	}

	if (itemType == "Belt"){
		;70+ life if armour or evasion abse
		affShort(2, 70, rating, ratingTable, stats)
		;35 STR
		affShort(6, 35, rating, ratingTable, stats)
		;280 armour
		affShort(32, 280, rating, ratingTable, stats)
		;45 energy shield
		affShort(33, 45, rating, ratingTable, stats)
		;70 total res
		affShort(8, 70, rating, ratingTable, stats)
		;30 elemental damage
		affShort(22, 30, rating, ratingTable, stats)
		;Reduced flask charges used
		affShort(34, 1, rating, ratingTable, stats)
		;Increased flask charges gained
		affShort(35, 1, rating, ratingTable, stats)
		;Flask effect duration
		affShort(36, 1, rating, ratingTable, stats)
	}

	if (itemType == "Ring"){
		;55+ life if armour or evasion abse
		affShort(2, 55, rating, ratingTable, stats)
		;50 energy shield
		affShort(33, 50, rating, ratingTable, stats)
		;xx-11 flat phys to attacks
		affShort(16, 11, rating, ratingTable, stats)
		;30 elemental damage
		affShort(22, 30, rating, ratingTable, stats)
		;40 increased rarity
		affShort(37, 40, rating, ratingTable, stats)
		;80 total res
		affShort(8, 80, rating, ratingTable, stats)
		;50+ mana regen
		affShort(38, 50, rating, ratingTable, stats)
		;250+ accuracy
		affShort(9, 250, rating, ratingTable, stats)
		;75+ total attributes
		affShort(39, 75, rating, ratingTable, stats)
	}

	if (itemType == "Amulet"){
		;55+ life
		affShort(2, 55, rating, ratingTable, stats)
		;xx-11 flat phys to attacks
		affShort(16, 11, rating, ratingTable, stats)
		;30 elemental damage
		affShort(22, 30, rating, ratingTable, stats)
		;40 increased rarity
		affShort(37, 40, rating, ratingTable, stats)
		;90 total res
		affShort(8, 90, rating, ratingTable, stats)
		;65+ mana regen
		affShort(38, 65, rating, ratingTable, stats)
		;250+ accuracy
		affShort(9, 250, rating, ratingTable, stats)
		;70+ total attributes
		affShort(39, 70, rating, ratingTable, stats)
		;30 crit strike multi
		affShort(18, 30, rating, ratingTable, stats)
		;30 crit strike chance
		affShort(17, 30, rating, ratingTable, stats)
		;30 elemental spell damage
		affShort(22, 30, rating, ratingTable, stats)
		;15 +% energy shield
		affShort(28, 15, rating, ratingTable, stats)
	}

	if (itemType == "Quiver"){
		;75+ life
		affShort(2, 75, rating, ratingTable, stats)
		;30 elemental spell damage
		affShort(22, 30, rating, ratingTable, stats)
		;30 crit strike multi
		affShort(18, 30, rating, ratingTable, stats)
		;30 crit strike chance
		affShort(17, 30, rating, ratingTable, stats)
		;70 total res
		affShort(8, 70, rating, ratingTable, stats)
	}
	;if corrupted - discount rating by 25%
	if (RegExMatch(item, "Corrupted") != 0) {
		rating *= 0.75
		ratingTable[1] := 25
	}
	
	;beautify numbers
	Loop % ObjLength(ratingTable)
	{
		;Corruption index
		if (A_Index != 1) { 
			ratingTable[A_Index] := floorDecimal(ratingTable[A_Index])
		}
	}
	return [floorDecimal(rating), ratingTable]
}

;get desired affix value from item
getAff(affText){
	needle := "\d+(?=" affText ")"
	stat := 0
	;iterate throu all matches
	while pos := RegExMatch(item, needle, matched, A_Index=1?1: pos+StrLen(matched)) {
		;sum matches
		stat += matched
	}
	return %stat%
}

getArmor(stats, armourToCheck){
	if InStr(stats, armourToCheck){
		needle := "(?<=" armourToCheck ": )\d+"
		RegExMatch(stats, needle, stat)
		return %stat%
	}
	return 0
}

floorDecimal(num) {

  num:=Floor(num*100)
  SetFormat Float, 0.2
  return num/100

}

;took from ItemInfo
parseItemType(stats, namePlate)
{
	; Grip type only matters for weapons at this point. For all others it will be 'None'.
	; Note that shields are armour and not weapons, they are not 1H.
	GripType = None
	baseType := ""
	subType := ""
	; Check stats section first as weapons usually have their sub type as first line
	Loop, Parse, stats, `n, `r
	{
		If (RegExMatch(A_LoopField, "i)\b((One Handed|Two Handed) (Axe|Sword|Mace)|Sceptre|Staff|Warstaff|Dagger|Claw|Bow|Wand)\b", match))
		{
			baseType	:= "Weapon"
			If (RegExMatch(match1, "i)(Sword|Axe|Mace)", subMatch)) {
				subType	:= subMatch1
			} Else {
				subType	:= match1
			}
			gripType	:= (RegExMatch(match1, "i)\b(Two Handed|Staff|Warstaff|Bow)\b")) ? "2H" : "1H"
			;MsgBox, %stats%
			;MsgBox, %baseType%`r%subType%`r%gripType%
			return [baseType, subType, gripType]
		}
	}

	; Check name plate section
	Loop, Parse, namePlate, `n, `r
	{		
		; Get third line in case of rare or unique item and retrieve the base item name
		LoopField := RegExReplace(A_LoopField, "<<.*>>", "")
		If (RarityLevel > 2)
		{
			Loop, Parse, namePlate, `n, `r
			{
				If (A_Index = 3) {
				   LoopField := Trim(A_LoopField) ? Trim(A_LoopField) : LoopField
				}
			}
		}

		; Belts, Amulets, Rings, Quivers, Flasks
		If (RegExMatch(LoopField, "i)\b(Belt|Stygian Vise|Rustic Sash)\b"))
		{
			baseType = Item
			subType = Belt
			return [baseType, subType]
		}		
		If (RegExMatch(LoopField, "i)\b(Amulet|Talisman)\b")) and not (RegExMatch(LoopField, "i)\bLeaguestone\b"))
		{
			baseType = Item
			subType = Amulet
			return [baseType, subType]
		}
		If (RegExMatch(LoopField, "\b(Ring|Quiver|Flask)\b", match))
		{
			baseType := "Item"
			subType := match1
			return [baseType, subType]
		}
		If (RegExMatch(LoopField, "i)\b(Map)\b"))
		{
			Global mapMatchList
			baseType = Map
			Loop % mapMatchList.MaxIndex()
			{
				mapMatch := mapMatchList[A_Index]
				IfInString, LoopField, %mapMatch%
				{
					If (RegExMatch(LoopField, "\bShaped " . mapMatch))
					{
						subType = Shaped %mapMatch%
					}
					Else
					{
						subType = %mapMatch%
					}
					return [baseType, subType]
				}
			}
			
			subType = Unknown%A_Space%Map
			return [baseType, subType]
		}
		
		; Jewels
		If (RegExMatch(LoopField, "i)(Cobalt|Crimson|Viridian|Prismatic) Jewel", match)) {
			baseType = Jewel
			subType := match1 " Jewel"
			return [baseType, baseType]
		}
		; Abyss Jewels
		If (RegExMatch(LoopField, "i)(Murderous|Hypnotic|Searching|Ghastly) Eye Jewel", match)) {
			baseType = Jewel
			subType := match1 " Eye Jewel"
			return [baseType, baseType]
		}
		
		; Leaguestones and Scarabs
		If (RegExMatch(Loopfield, "i)\b(Leaguestone|Scarab)\b"))
		{
			RegexMatch(LoopField, "i)(.*)(Leaguestone|Scarab)", typeMatch)
			RegexMatch(Trim(typeMatch1), "i)\b(\w+)\W*$", match) ; match last word
			baseType := Trim(typeMatch2)
			subType := Trim(match1) " " Trim(typeMatch2)
			return [baseType, subType]
		}


		; Matching armour types with regular expressions for compact code

		; Shields
		If (RegExMatch(LoopField, "\b(Buckler|Bundle|Shield)\b"))
		{
			baseType = Armour
			subType = Shield
			return [baseType, subType]
		}

		; Gloves
		If (RegExMatch(LoopField, "\b(Gauntlets|Gloves|Mitts)\b"))
		{
			baseType = Armour
			subType = Gloves
			return [baseType, subType]
		}

		; Boots
		If (RegExMatch(LoopField, "\b(Boots|Greaves|Slippers)\b"))
		{
			baseType = Armour
			subType = Boots
			return [baseType, subType]
		}

		; Helmets
		If (RegExMatch(LoopField, "\b(Bascinet|Burgonet|Cage|Circlet|Crown|Hood|Helm|Helmet|Mask|Sallet|Tricorne)\b"))
		{
			baseType = Armour
			subType = Helmet
			return [baseType, subType]
		}

		; Note: Body armours can have "Pelt" in their randomly assigned name,
		;    explicitly matching the three pelt base items to be safe.

		If (RegExMatch(LoopField, "\b(Iron Hat|Leather Cap|Rusted Coif|Wolf Pelt|Ursine Pelt|Lion Pelt)\b"))
		{
			baseType = Armour
			subType = Helmet
			return [baseType, subType]
		}

		; BodyArmour
		; Note: Not using "$" means "Leather" could match "Leather Belt", therefore we first check that the item is not a belt. (belts are currently checked earlier so this is redundant, but the order might change)
		If (!RegExMatch(LoopField, "\b(Belt)\b"))
		{
			If (RegExMatch(LoopField, "\b(Armour|Brigandine|Chainmail|Coat|Doublet|Garb|Hauberk|Jacket|Lamellar|Leather|Plate|Raiment|Regalia|Ringmail|Robe|Tunic|Vest|Vestment)\b"))
			{
				baseType = Armour
				subType = BodyArmour
				return [baseType, subType]
			}
		}

		If (RegExMatch(LoopField, "\b(Chestplate|Full Dragonscale|Full Wyrmscale|Necromancer Silks|Shabby Jerkin|Silken Wrap)\b"))
		{
			baseType = Armour
			subType = BodyArmour
			return [baseType, subType]
		}
	}
}