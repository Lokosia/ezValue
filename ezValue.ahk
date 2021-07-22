#NoEnv
#Persistent
#SingleInstance, force
SetWorkingDir, %A_ScriptDir%
SendMode Input
#Include, %A_ScriptDir%\lib\JSON.ahk
#Include, %A_ScriptDir%\lib\ToolTipOpt.ahk
ToolTipFont("s14", "Arial")
ToolTipColor("Black", "White")
Menu, Tray, Icon, %A_ScriptDir%\lib\icon.ico

GetItemFromClipboard() {
    ; Verify the information is what we're looking for
	if RegExMatch(clipboard, "Rarity: .*?\R.*?\R?.*?\R--------\R.*") = 0 {
		;MsgBox % "Not a PoE item"
		return false
	}
    return clipboard
}

;Empty tooltip on mouse click
;~ means not blocking default mouse click behaviour
~LButton::
Tooltip
return

OnClipboardChange:
	Global item := GetItemFromClipboard()
	if (item){
		tempItem := StrReplace(item, "`r`n--------`r`n", "``")
		tempItem := StrSplit(tempItem, "``")

		;collect info and split it to vars
		;Item class, rarity name
		namePlate	:= tempItem[1]
		
		;Quality, Armor/ES/Evasion
		;we have to find actually section and save var as global to use it easily later
		Global stats
		if (InStr(tempItem[2], "Armour") or InStr(tempItem[2], "Energy Shield") or InStr(tempItem[2], "Evasion")){
			stats		:= tempItem[2]
		} else {
			stats := ""
		}

		;unused vars, not always represents var names because it is just numbers of sections, bugs with rings and abyss belts
		/*
		requirements := tempItem[3]
		sockets := tempItem[4]
		ilvl := tempItem[5]
		prefsuf := tempItem[6]
		

		indexLast := tempItem[0]
		partsLast := tempItem[%indexLast%]
		*/

		;item name
		
		splitted := StrSplit(namePlate, "`n")
		;at item rarity > normal item name becomes 2 line name, at normal rarity it is 1 line, so we have to correctly find name
		if (splitted.MaxIndex() == 4){
			itemName := splitted[3] " " splitted[4]
		} else {
			itemName := splitted[3]
		}

		parsedItem := parseItemType(namePlate)
		
		;exit script on unsupported item
		if ((parsedItem[1] != "Weapon") and (parsedItem[1] != "Armour") and (parsedItem[1] != "Accessory") and (parsedItem[1] != "Flask") and (parsedItem[1] != "Currency") and (parsedItem[1] != "Jewel")) {
			;MsgBox, Banned
			return
		}
		
		rating := ratingCounter(parsedItem, parsedItem[3])
		totalRating := rating[1]
		descriptionRating := rating[2]
		
		
		;beauty whole array
		Loop % ObjLength(descriptionRating)
		{
			descriptionRating[A_Index] := beautyNumber(descriptionRating[A_Index])
		}

		descriptionArray := []
		
		descriptionArray[1]  := " -"descriptionRating[1]"%`tCORRUPTED`n"
		;life
		descriptionArray[2]  := "+"descriptionRating[2]	"`t" life1 				" Life`n"
		descriptionArray[4]  := "+"descriptionRating[4]	"`t" life2 				" Life on ES base`n" ;on ES/ES hybrid base
		descriptionArray[27] := "+"descriptionRating[27]"`t" life3 				"% Life`n"
		;es
		descriptionArray[3]  := "+"descriptionRating[3]	"`t" es1 				" total ES`n"
		descriptionArray[5]  := "+"descriptionRating[5]	"`t" es2 				" ES on ES base`n" ;on ES/ES hybrid base
		descriptionArray[28] := "+"descriptionRating[28]"`t" es3 				"% ES`n"
		descriptionArray[33] := "+"descriptionRating[33]"`t" es4 				" maximum ES`n"
		;attributes
		descriptionArray[6]  := "+"descriptionRating[6]	"`t" STR 				" STR`n"
		descriptionArray[7]  := "+"descriptionRating[7]	"`t" INT 				" INT`n"
		descriptionArray[12] := "+"descriptionRating[12]"`t" DEX 				" DEX`n"
		descriptionArray[39] := "+"descriptionRating[39]"`t" totalAttributes 	" Attributes`n"
		;resistance
		descriptionArray[8]  := "+"descriptionRating[8]	"`t" totalResistance 	"% Res`n"
		;elemental damage
		descriptionArray[20] := "+"descriptionRating[20]"`t" elementalFlat1H 	" 1H Elem DMG`n"
		descriptionArray[21] := "+"descriptionRating[21]"`t" elementalFlat2H 	" 2H Elem DMG`n"
		descriptionArray[22] := "+"descriptionRating[22]"`t" elementalSpellDMG 	" Elem Spell DMG`n"
		descriptionArray[24] := "+"descriptionRating[24]"`t" elementalFlatSpells " Elem DMG to Spells`n"
		descriptionArray[40] := "+"descriptionRating[40]"`t" elementalDmg 		" Elem DMG with ATK Skills`n"
		;spell damage
		descriptionArray[13] := "+"descriptionRating[13]"`t" spellDMG 			" Spell DMG`n"
		;phys damage
		descriptionArray[15] := "+"descriptionRating[15]"`t" physInc 			"% Phys DMG`n"
		descriptionArray[16] := "+"descriptionRating[16]"`t" physFlat 			" flat Phys DMG`n"
		;crits
		descriptionArray[18] := "+"descriptionRating[18]"`t" globalCritMulti 	" Global Crit Multi`n"
		descriptionArray[23] := "+"descriptionRating[23]"`t" spellCritChance 	" Crit Chance for Spells`n"
		descriptionArray[17] := "+"descriptionRating[17]"`t" weaponCritChance 	" Crit Chance`n"
		;speed
		descriptionArray[10] := "+"descriptionRating[10]"`t" ms 				"% MOV SPD`n"
		descriptionArray[11] := "+"descriptionRating[11]"`t" aspd 				"% ATK SPD`n"
		descriptionArray[29] := "+"descriptionRating[29]"`t" castSpeed 			"% Cast SPD`n"
		;sockets
		descriptionArray[19] := "+"descriptionRating[19]"`t" socketedBowGems 	" Socketed Bow Gems`n"
		descriptionArray[25] := "+"descriptionRating[25]"`t" socketedGems 		" Socketed Gems`n"
		descriptionArray[26] := "+"descriptionRating[26]"`t" socketedElemGems 	" Socketed Elem Gems`n"
		;jewel rolls
		descriptionArray[30] := "+"descriptionRating[30]"`t" aspdRolls 			" ATK SPD rolls`n"
		descriptionArray[31] := "+"descriptionRating[31]"`t" damageRolls 		" DMG rolls`n"
		;flasks
		descriptionArray[34] := "+"descriptionRating[34]"`t" flaskRedCharges 	"% reduced Flask Charges used`n"
		descriptionArray[35] := "+"descriptionRating[35]"`t" flaskIncCharges 	"% Flask Charges gained`n"
		descriptionArray[36] := "+"descriptionRating[36]"`t" flaskEffDuration 	"% Flask Effect Duration`n"
		;misc
		descriptionArray[32] := "+"descriptionRating[32]"`t" armour 			" Armour`n"
		descriptionArray[9]  := "+"descriptionRating[9]	"`t" accuracy 			" Accuracy`n"
		descriptionArray[37] := "+"descriptionRating[37]"`t" incRarity 			"% Rarity`n"
		descriptionArray[38] := "+"descriptionRating[38]"`t" manaReg 			"% Mana Regen`n"
		descriptionArray[14] := "+"descriptionRating[14]"`t" avoidElemAil 		"% to Avoid Elem Ailments`n"
		
		;form description
		description := "`n"
		Loop % ObjLength(descriptionArray)
		{
			if (descriptionRating[A_Index] != 0) {
				description := description descriptionArray[A_Index]
			}
		}
		;open pref suff check
		
		prefixNumber := 0
		;iterate throu all matches
		while pos := RegExMatch(item, "Prefix", matched, A_Index=1?1: pos+StrLen(matched)) {
			;sum matches
			prefixNumber++
		}

		suffixNumber := 0
		;iterate throu all matches
		while pos := RegExMatch(item, "Suffix", matched, A_Index=1?1: pos+StrLen(matched)) {
			;sum matches
			suffixNumber++
		}

		if (parsedItem[1] != "Jewel"){
			craftedSuffNumber := 0
			if(RegExMatch(item, "Master Crafted Suffix") > 0){
				craftedSuffNumber++
			}

			craftedPrefNumber := 0
			if(RegExMatch(item, "Master Crafted Prefix") > 0){
				craftedPrefNumber++
			}
		}
		;craftAllowed := false
		craftAllowed := (craftedSuffNumber == 0) and (craftedPrefNumber == 0)
		affLimit := parsedItem[1] == "Jewel" ? 2 : 3
		
		;Open suff and open preff
		if (prefixNumber < affLimit and prefixNumber != 0 and suffixNumber < affLimit and suffixNumber != 0){
			description := description "`nOpen Suffix and Prefix, aug me! "
		} else if (prefixNumber < affLimit and prefixNumber != 0){
			if(craftAllowed){
				description := description "`nPrefix craft possible "
			}else{
				description := description "`nPrefix aug me! "
			}
		} else if (suffixNumber < affLimit and suffixNumber != 0){
			if(craftAllowed){
				description := description "`nSuffix craft possible "
			}else{
				description := description "`nSuffix aug me! "
			}
		} else if (prefixNumber == affLimit and suffixNumber == affLimit){
			description := description "`nNo room for affixes "
		}
		
		description := SubStr(description, 1 , StrLen(description)-1)
		
		;form verdict
		if (parsedItem[1] == "Currency"){
			verdict := "All currency is usable"
		} else if (totalRating < 2){
			verdict := "Bad, vend to NPC or reroll"
		} else {
			verdict := "Good, use it"
		}
		
		;form tooltip
		;Item name
		finalString := itemName
		;Description of rating evaluation
		if (description != ""){
			finalString := finalString "`n" description
		}
		
		RegExMatch(item, "(?<=Item Level: )\d+", item_level)
		;Item lvl rating
		finalString := finalString "`n" item_level "/84`tItem level" 
		
		;Rating
		finalString := finalString "`n" beautyNumber(totalRating) "`tRating" 

		if (InStr(item, "Stack Size: ")){
			RegExMatch(item, "\d+", stackSize)
			
			;format beautiful sumRating
			sumRating := (totalRating * stackSize)
			sumRating := "Stack Value: " beautyNumber(sumRating)

			finalString := finalString "`n" sumRating
		}
		;Verdict in words
		;finalString := finalString "`nResult:`t" verdict
		
		
		;get mouse coords
		MouseGetPos, xpos, ypos
		;preparation vars
		tooltip_arrayed := StrSplit(finalString, "`n")
		tooltip_height := (tooltip_arrayed.MaxIndex()*14)+200
		;finding the longest string
		longest_string := 0
		new_final := ""
		for index, element in tooltip_arrayed {
			;add spaces to the start and the end of lines
			element := " " element " `n"
			new_final := new_final element
			length := StrLen(element)
			if(length > longest_string){
				longest_string := length
			}
		}
		finalString := new_final
		tooltip_width := (longest_string*11)
		;MsgBox % longest_string
		;coord limiter
		xpos := (xpos + 72 + tooltip_width) >= A_ScreenWidth ? A_ScreenWidth - 36 - tooltip_width: xpos + 36
		ypos := ((ypos + tooltip_height) >= A_ScreenHeight) ? A_ScreenHeight - tooltip_height: ypos + 36
		;show tooltip
		Tooltip % finalString, xpos,ypos
		
		;delete tooltip in 5 sec
		SetTimer, RemoveToolTip, -5000
	}
	return

RemoveToolTip:
	ToolTip
	return

beautyNumber(num){
	tempNum := Format("{:0.2f}", num)
	tempNum := regexReplace(tempNum, "\.?0+$")
	tempNum := ThousandsSep(tempNum)
	return tempNum
}

armorBase(neededBase, hybrid:=0){
	Global stats
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

convertStat(affixStat, fullStat, ratingTableIndex){
	Global rating
	Global ratingTable
	
	convertedStat := affixStat/fullStat
	;Limit rating to no more than 1, for better valueing
	if (convertedStat > 1) {
		convertedStat := 1
	}
	rating += %convertedStat%
	ratingTable[ratingTableIndex] += convertedStat
}

;add new affixes to value here
affShort(affix, numberToCheck){
	Global stats
	Global rating
	Global ratingTable

	if (affix == 2) {
		if (!armorBase("Energy", 1) and !armorBase("Energy")){
			Global life1
			life1 := getAff(" to maximum Life")
			convertStat(life1, numberToCheck, affix)
		}
	}
	if (affix == 3) {
		Global es1
		es1 := getArmor("Energy Shield")
		convertStat(es1, numberToCheck, affix)
	}
	if (affix == 4) {
		if (armorBase("Energy", 1) or armorBase("Energy")){
			Global life2
			life2 := getAff(" to maximum Life")
			convertStat(life2, numberToCheck*2, affix)
			
		}
	}
	if (affix == 5) {
		if (armorBase("Energy", 1) or armorBase("Energy")){
			Global es2
			es2 := getArmor("Energy Shield")
			convertStat(es2, numberToCheck*2, affix)
		}
	}
	if (affix == 6) {
		Global STR
		str1 := getAff(" to Strength")
		str2 := getAff(" to all Attributes")
		STR := (str1+str2)
		convertStat(STR, numberToCheck, affix)
	}
	if (affix == 7) {
		Global INT
		int1 := getAff(" to Intelligence")
		int2 := getAff(" to all Attributes")
		INT := (int1+int2)
		convertStat(INT, numberToCheck, affix)
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
		convertStat(totalResistance, numberToCheck, affix)
	}
	if (affix == 9) {
		Global accuracy
		accuracy := getAff(" to Accuracy Rating")
		convertStat(accuracy, numberToCheck, affix)
	}
	if (affix == 10) {
		Global ms
		ms := getAff("% increased Movement Speed")
		convertStat(ms, numberToCheck, affix)
	}
	if (affix == 11) {
		Global aspd
		aspd := getAff("% increased Attack Speed")
		comboSpeed := getAff("% increased Attack and Cast Speed")
		aspd += comboSpeed
		convertStat(aspd, numberToCheck, affix)
	}
	if (affix == 12) {
		Global DEX
		DEX := getAff(" to Dexterity")
		dex2 := getAff(" to all Attributes")
		DEX += dex2
		convertStat(DEX, numberToCheck, affix)
	}
	if (affix == 13) {
		Global spellDMG
		spellDMG := getAff("% increased Spell Damage")
		convertStat(spellDMG, numberToCheck, affix)
	}
	if (affix == 14) {
		Global avoidElemAil
		avoidElemAil := getAff("% chance to Avoid Elemental Ailments")
		convertStat(avoidElemAil, numberToCheck, affix)
	}
	if (affix == 15) {
		Global physInc
		physInc := getAff("% increased Physical Damage")
		convertStat(physInc, numberToCheck, affix)
	}
	if (affix == 16) {
		Global physFlat
		physFlat := getAff(" Physical Damage")
		convertStat(physFlat, numberToCheck, affix)
	}
	if (affix == 17) {
		Global weaponCritChance
		weaponCritChance := getAff("% increased Critical Strike Chance")
		globalCritChance := getAff("% increased Global Critical Strike Chance")
		weaponCritChance += globalCritChance
		convertStat(weaponCritChance, numberToCheck, affix)
	}
	if (affix == 18) {
		Global globalCritMulti
		globalCritMulti := getAff("% to Global Critical Strike Multiplier")
		convertStat(globalCritMulti, numberToCheck, affix)
	}
	if (affix == 19) {
		Global socketedBowGems
		socketedBowGems := getAff(" to Level of Socketed Bow Gems")
		addSocketedGems := getAff(" to Level of Socketed Gems")
		socketedBowGems += addSocketedGems
		convertStat(socketedBowGems, numberToCheck, affix)
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
		convertStat(elementalFlat1H, numberToCheck + addLightning, affix)
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
		convertStat(elementalFlat2H, numberToCheck + addLightning, affix)
	}
	if (affix == 22) {
		global elementalSpellDMG
		spellFire := getAff("% increased Fire Damage")
		spellCold := getAff("% increased Cold Damage")
		spellLightning := getAff("% increased Lightning Damage")
		
		spellGlobal := getAff("% increased Spell Damage")
		spellElementalGlobal := getAff("% increased Elemental Damage(?!.)")

		elementalSpellDMG := (spellFire + spellCold + spellLightning + spellGlobal + spellElementalGlobal)
		convertStat(elementalSpellDMG, numberToCheck, affix)
	}
	if (affix == 23) {
		global spellCritChance
		spellCritChance := getAff("% increased Critical Strike Chance for Spells")
		globalCritChance := getAff("% increased Global Critical Strike Chance")
		spellCritChance += globalCritChance
		convertStat(spellCritChance, numberToCheck, affix)
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
		convertStat(elementalFlatSpells, numberToCheck + addLightning, affix)
	}
	if (affix == 25) {
		Global socketedGems
		socketedGems := getAff(" to Level of Socketed Gems")
		convertStat(socketedGems, numberToCheck, affix)
	}
	if (affix == 26) {
		Global socketedElemGems
		fireGem := getAff(" to Level of Socketed Fire Gems")
		coldGem := getAff(" to Level of Socketed Cold Gems")
		lightningGem := getAff(" to Level of Socketed Lightning Gems")
		elementalGem := getAff(" to Level of Socketed Elemental Gems")
		socketedOverallGems := getAff(" to Level of Socketed Gems")
		socketedElemGems := (fireGem + coldGem + lightningGem + elementalGem + socketedOverallGems)

		convertStat(socketedElemGems, numberToCheck, affix)
	}
	if (affix == 27) {
		Global life3
		life3 := getAff("% increased maximum Life")
		convertStat(life3, numberToCheck, affix)
	}
	if (affix == 28) {
		Global es3
		es3 := getAff("% increased maximum Energy Shield")
		convertStat(es3, numberToCheck, affix)
	}
	if (affix == 29) {
		Global castSpeed
		castSpeed := getAff("% increased Cast Speed")
		comboSpeed := getAff("% increased Attack and Cast Speed")
		castSpeed += comboSpeed
		convertStat(castSpeed, numberToCheck, affix)
	}
	if (affix == 30) {
		Global aspdRolls
		needle := "Speed"
		regexReplace(item, needle, needle, aspdRolls)
		convertStat(aspdRolls, numberToCheck, affix)
	}
	if (affix == 31) {
		Global damageRolls
		needle := "m)^((?!Block).)*Damage"
		needle2 := "Critical"
		regexReplace(item, needle, needle, damageRolls)
		regexReplace(item, needle2, needle2, critRolls)
		damageRolls += critRolls
		convertStat(damageRolls, numberToCheck, affix)
	}
	if (affix == 32) {
		Global armour
		armour := getAff(" to Armour")
		convertStat(armour, numberToCheck, affix)
	}
	if (affix == 33) {
		Global es4
		es4 := getAff(" to maximum Energy Shield")
		convertStat(es4, numberToCheck, affix)
	}
	if (affix == 34) {
		Global flaskRedCharges
		flaskRedCharges := getAff("% reduced Flask Charges used")
		convertStat(flaskRedCharges, flaskRedCharges, affix)
	}
	if (affix == 35) {
		Global flaskIncCharges
		flaskIncCharges := getAff("% increased Flask Charges gained")
		convertStat(flaskIncCharges, flaskIncCharges, affix)
	}
	if (affix == 36) {
		Global flaskEffDuration
		flaskEffDuration := getAff("% increased Flask Effect Duration")
		convertStat(flaskEffDuration, flaskEffDuration, affix)
	}
	if (affix == 37) {
		Global incRarity
		incRarity := getAff("% increased Rarity of Items found")
		convertStat(incRarity, numberToCheck, affix)
	}
	if (affix == 38) {
		Global manaReg
		manaReg := getAff("% increased Mana Regeneration Rate")
		convertStat(manaReg, numberToCheck, affix)
	}
	if (affix == 39) {
		Global totalAttributes
		tempDEX := getAff(" to Dexterity(?! and)")
		tempSTR := getAff(" to Strength(?! and)")
		tempINT := getAff(" to Intelligence(?! and)")

		dAndI := getAff(" to Dexterity and Intelligence") * 2
		sAndI := getAff(" to Strength and Intelligence") * 2
		sAndD := getAff(" to Strength and Dexterity") * 2

		totalAttributes := getAff(" to all Attributes")*3

		totalAttributes += (tempDEX + tempSTR + tempINT + dAndI + sAndI + sAndD)
		convertStat(totalAttributes, numberToCheck, affix)
	}
	if (affix == 40) {
		Global elementalDmg
		elementalDmg := getAff("% increased Elemental Damage with Attack Skills")
		convertStat(elementalDmg, numberToCheck, affix)
	}
}

ratingCounter(itemType, gripType:="1H"){
	
	Global stats
	;used as a result itself
	Global rating = 0
	;used for tooltip strings
	Global ratingTable := []
	Loop, 40
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
	;40 elemental damage with attack skills
	;MsgBox % stats
	if (itemType[1] == "Currency") {
		scroll_of_wisdom := 1
		portal_scroll := scroll_of_wisdom * 3
		orb_of_transmutation := portal_scroll * 7
		orb_of_augmentation := orb_of_transmutation * 4
		orb_of_alteration := orb_of_augmentation * 4
		jewellers_orb := orb_of_alteration * 2
		chromatic_orb := jewellers_orb * 3
		orb_of_fusing := jewellers_orb * 4
		orb_of_chance := orb_of_fusing * 1
		orb_of_scouring := orb_of_chance * 4
		orb_of_regret := orb_of_scouring * 2
		orb_of_alchemy := orb_of_regret * 1
		
		armourers_scrap := portal_scroll * 5
		blacksmiths_whetstone := armourers_scrap * 3
		glassblowers_bauble := blacksmiths_whetstone * 8

		gemcutter_prism := glassblowers_bauble * 20
		chaos_orb := orb_of_alchemy * 3
		regal_orb := chaos_orb * 16
		blessed_orb := regal_orb * 1
		exalted_orb := regal_orb * 5
		divine_orb := exalted_orb * 4
		ancient_orb := chaos_orb * 10
		vaal_orb := chaos_orb / 3
		silver_coin := chaos_orb / 6
		cartographers_chisel := chaos_orb / 4
		annulment_orb := chaos_orb * 6

		if (itemType[2] == "Scroll of Wisdom") {
			rating += scroll_of_wisdom
		}
		if (itemType[2] == "Scroll Fragment") {
			rating += scroll_of_wisdom/5
		}
		if (itemType[2] == "Portal Scroll") {
			rating += portal_scroll
		}
		if (itemType[2] == "Orb of Transmutation") {
			rating += orb_of_transmutation
		}
		if (itemType[2] == "Transmutation Shard") {
			rating += orb_of_transmutation/20
		}
		if (itemType[2] == "Orb of Augmentation") {
			rating += orb_of_augmentation
		}
		if (itemType[2] == "Orb of Alteration") {
			rating += orb_of_alteration
		}
		if (itemType[2] == "Alteration Shard") {
			rating += orb_of_alteration/20
		}
		if (itemType[2] == "Jeweller's Orb") {
			rating += jewellers_orb
		}
		if (itemType[2] == "Chromatic Orb") {
			rating += chromatic_orb
		}
		if (itemType[2] == "Orb of Fusing") {
			rating += orb_of_fusing
		}
		if (itemType[2] == "Orb of Chance") {
			rating += orb_of_chance
		}
		if (itemType[2] == "Orb of Scouring") {
			rating += orb_of_scouring
		}
		if (itemType[2] == "Orb of Regret") {
			rating += orb_of_regret
		}
		if (itemType[2] == "Orb of Alchemy") {
			rating += orb_of_alchemy
		}
		if (itemType[2] == "Alchemy Shard") {
			rating += orb_of_alchemy/20
		}
		if (itemType[2] == "Armourer's Scrap") {
			rating += armourers_scrap
		}
		if (itemType[2] == "Blacksmith's Whetstone") {
			rating += blacksmiths_whetstone
		}
		if (itemType[2] == "Glassblower's Bauble") {
			rating += glassblowers_bauble
		}
		if (itemType[2] == "Gemcutter's Prism") {
			rating += gemcutter_prism
		}
		if (itemType[2] == "Chaos Orb") {
			rating += chaos_orb
		}
		if (itemType[2] == "Chaos Shard") {
			rating += chaos_orb/20
		}
		if (itemType[2] == "Regal Orb") {
			rating += regal_orb
		}
		if (itemType[2] == "Regal Shard") {
			rating += regal_orb/20
		}
		if (itemType[2] == "Blessed Orb") {
			rating += blessed_orb
		}
		if (itemType[2] == "Exalted Orb") {
			rating += exalted_orb
		}
		if (itemType[2] == "Exalted Shard") {
			rating += exalted_orb/20
		}
		if (itemType[2] == "Divine Orb") {
			rating += divine_orb
		}
		if (itemType[2] == "Ancient Orb") {
			rating += ancient_orb
		}
		if (itemType[2] == "Ancient Shard") {
			rating += ancient_orb/20
		}
		if (itemType[2] == "Vaal Orb") {
			rating += vaal_orb
		}
		if (itemType[2] == "Silver Coin") {
			rating += silver_coin
		}
		if (itemType[2] == "Cartographer's Chisel") {
			rating += cartographers_chisel
		}
		if (itemType[2] == "Orb of Annulment") {
			rating += annulment_orb
		}
		if (itemType[2] == "Annulment Shard") {
			rating += annulment_orb / 20
		}
		
	}
	if (itemType[1] == "Armour") {
		;if body armour - check for body armor suffs
		if (itemType[2] == "BodyArmour") {
			;if armour base
			if (armorBase("Armour")){
				;str 40+
				affShort(6, 40)
			}
			;if armour or evasion base
			if (armorBase("Armour") or armorBase("Evasion")){
				;life 75+
				affShort(2, 75)
			}
			
			;if energy base
			if (armorBase("Energy")){
				;int 40+
				affShort(7, 40)
				;Energy shield 575+
				affShort(3, 575)
			}

			;if energy base or hybrid
			if (armorBase("Energy", 1)){
				;hybrid life 70+
				affShort(4, 70)
				;hybrid energy shield 350+
				affShort(5, 350)
			}

			;total elemental resistance 80+
			affShort(8, 80)
		}
		
		if (itemType[2] == "Helmet") {
			;life 65+ on armor/evasion base
			affShort(2, 65)

			;Energy shield 350+
			affShort(3, 350)

			;if energy shield base or hybrid
			;life 65+
			affShort(4, 65)
			;Energy shield 200+
			affShort(5, 200)

			;accuracy 300+
			affShort(9, 300)

			;if armor or evasion base
			if (!armorBase("Energy", 1) and !armorBase("Energy")){
				;int 40
				affShort(7, 40)
			}

			;total resistance 80
			affShort(8, 80)

			;avoid elemental ailments
			affShort(14, 25)
		}

		if (itemType[2] == "Boots") {
			;movement speed 30+
			affShort(10, 30)

			;life 65+ on armor/evasion base
			affShort(2, 65)

			;Energy shield 130+
			affShort(3, 130)

			;if energy shield base or hybrid
			;65+ life
			affShort(4, 65)
			;90+ es
			affShort(5, 90)

			;str 40+
			affShort(6, 40)
			
			;int 40+
			affShort(7, 40)

			;total resistance 70
			affShort(8, 70)
		}

		if (itemType[2] == "Gloves") {
			;life 65+ on armor/evasion base
			affShort(2, 65)

			;Energy shield 150+
			affShort(3, 150)

			;if energy shield base or hybrid
			;65+ life
			affShort(4, 65)
			;100+ es
			affShort(5, 100)

			;total resistance
			affShort(8, 80)

			;accuracy 300+
			affShort(9, 300)

			;attack speed 10+
			affShort(11, 10)

			;if armour or energy shield base
			if (!armorBase("Evasion") and !armorBase("Evasion", 1)){
				;40+ dex
				affShort(12, 40)
			}

			;avoid elemental ailments
			affShort(14, 25)
		}

		if (itemType[2] == "Shield") {
			;80+ life if armour or evasion abse
			affShort(2, 80)

			;Energy shield 350+
			affShort(3, 350)
			
			;if energy shield base or hybrid
			;80+ life
			affShort(4, 80)
			;280+ es
			affShort(5, 280)

			;total resistance
			affShort(8, 100)

			;if armour base
			if (armorBase("Armour")){
				;str 35+
				affShort(6, 35)
			}
			
			;if energy base
			if (armorBase("Energy")){
				;int 35+
				affShort(7, 35)
			}

			;55+ spell damage
			affShort(13, 55)

			;80+ spell crit chance
			affShort(23, 80)
		}

		if (itemType[2] == "Quiver"){
			;75+ life
			affShort(2, 75)
			;30 elemental spell damage
			affShort(22, 30)
			;30 crit strike multi
			affShort(18, 30)
			;30 crit strike chance
			affShort(17, 30)
			;70 total res
			affShort(8, 70)
		}
	}

	if (itemType[1] == "Weapon") {
		if ((itemType[2] == "Sword") or (itemType[2] == "Axe") or (itemType[2] == "Mace") or (itemType[2] == "Claw") or (itemType[2] == "Bow")) {
			;phys increased 170+
			affShort(15, 170)

			if (gripType == "2H"){
				;xx to xx flat phys
				affShort(16, 50)
				;elemental damage 2h
				affShort(21, 100*2)
				;elemental damage with attacks
				affShort(40, 87)
			} else {
				;1H weapon
				;xx to xx flat phys
				affShort(16, 33)
				;elemental damage 1h
				affShort(20, 70*2)
				;elemental damage with attacks
				affShort(40, 51)
			}

			;attack speed 20+
			affShort(11, 20)
			
			if (itemType[2] == "Bow") {
				;weapon crit chance 30+
				affShort(17, 30)
				;crit multi 30+
				affShort(18, 30)
				;+2 socketed bow gems
				affShort(19, 2)
			}
		}

		if ((itemType[2] == "Dagger") or (itemType[2] == "Wand") or (itemType[2] == "Sceptre")) {
			;Caster
			;elemental spell damage 90+
			affShort(22, 90)
			;130+ critical strike chance for spells
			affShort(23, 130)
			;flat elemental damage to spells
			affShort(24, 50)
			;crit multi 30+
			affShort(18, 30)

			;Attack dagger or wand
			if ((itemType == "Dagger") or (itemType == "Wand")) {
				;phys increased 170+
				affShort(15, 170)
				;xx to xx flat phys
				affShort(16, 33)

				;attack speed 20+
				if (itemType == "Dagger") {
					dorw := 20
				} else {
					dorw := 10
				}
				affShort(11, dorw)

				;weapon crit chance 30+
				affShort(17, 30)
				;crit multi 30+
				affShort(18, 30)

				;elemental damage 1h
				affShort(20, 70)
			}
		}
		
		if ((itemType[2] == "Stave") or (itemType[2] == "Warstave")){
			;+1 to socketed gems AND +2 to socketed elem gems
			affShort(26, 3)

			;elemental damage 2h, but counting as 1h 
			;TODO: flat elem damage on staffs are individual compared to method in affShort,
			;now it is not precise enough also because of lightning damage
			;(it is higher than in the other weapon types)
			;because of that we count it as 1h weapon
			affShort(20, 70)

			;elemental spell damage 160+
			affShort(22, 160)
		}
	}
	
	if (itemType[1] == "Jewel") {
		if (itemType[2] == "Abyss Jewel"){
			;TODO add mods
			affShort(2, 36)
		}
		if (itemType[2] == "Jewel"){
			;% Life, 6 is middle value of all possible
			affShort(27, 6)
			;% ES
			affShort(28, 6)
			;% Cast speed
			affShort(29, 3)
			;% crit multi
			affShort(18, 10.5)
			;number of aspd compatible rolls
			affShort(30, 2)
			;% damage compatible rolls
			affShort(31, 2)
		}
	}

	if (itemType[1] == "Accessory") {
		if (itemType[2] == "Belt"){
			;70+ life
			affShort(2, 70)
			;35 STR
			affShort(6, 35)
			;280 armour
			affShort(32, 280)
			;45 energy shield
			affShort(33, 45)
			;70 total res
			affShort(8, 70)
			;30 elemental damage
			affShort(22, 30)
			;Reduced flask charges used
			affShort(34, 1)
			;Increased flask charges gained
			affShort(35, 1)
			;Flask effect duration
			affShort(36, 1)
		}

		if (itemType[2] == "Ring"){
			;55+ life if armour or evasion abse
			affShort(2, 55)
			;50 energy shield
			affShort(33, 50)
			;xx-11 flat phys to attacks
			affShort(16, 11)
			;30 elemental damage
			affShort(22, 30)
			;40 increased rarity
			affShort(37, 40)
			;80 total res
			affShort(8, 80)
			;50+ mana regen
			affShort(38, 50)
			;250+ accuracy
			affShort(9, 250)
			;75+ total attributes
			affShort(39, 75)
		}

		if (itemType[2] == "Amulet"){
			;55+ life
			affShort(2, 55)
			;xx-11 flat phys to attacks
			affShort(16, 11)
			;40 elemental damage
			affShort(40, 30)
			;40 increased rarity
			affShort(37, 40)
			;90 total res
			affShort(8, 90)
			;65+ mana regen
			affShort(38, 65)
			;250+ accuracy
			affShort(9, 250)
			;70+ total attributes
			affShort(39, 70)
			;30 crit strike multi
			affShort(18, 30)
			;30 crit strike chance
			affShort(17, 30)
			;30 elemental spell damage
			affShort(22, 30)
			;15 +% energy shield
			affShort(28, 15)
		}
	}
	

	;if corrupted - discount rating by 10%
	if(itemType[1] != "Currency"){
		if (RegExMatch(item, "Corrupted") != 0) {
			rating *= 0.9
			ratingTable[1] := 10
		}
	}
	
	return [rating, ratingTable]
}

;get desired affix value from item
getAff(affText){
	needle := "\d+(?=(\(.+\))*" affText ")"
	stat := 0
	;iterate throu all matches
	while pos := RegExMatch(item, needle, matched, A_Index=1?1: pos+StrLen(matched)) {
		;sum matches
		stat += matched
	}
	return %stat%
}

getArmor(armourToCheck){
	Global stats
	if InStr(stats, armourToCheck){
		needle := "(?<=" armourToCheck ": )\d+"
		RegExMatch(stats, needle, stat)
		return %stat%
	}
	return 0
}

ThousandsSep(x) { 
   return RegExReplace(x, "(?(?<=\.)(*COMMIT)(*FAIL))\d(?=(\d{3})+(\D|$))", "$0,") 
}

;took from ItemInfo
parseItemType(namePlate)
{
	; Grip type only matters for weapons at this point. For all others it will be 'None'.
	; Note that shields are armour and not weapons, they are not 1H.
	GripType = None
	baseType := ""
	subType := ""
	
	;finding rarity level
	rarityLevel := 0
	RegexMatch(namePlate, "(?<=Rarity: ).+", rarityLevel)
	if (rarityLevel == "Normal"){
		rarityLevel := 1
	}
	if (rarityLevel == "Magic"){
		rarityLevel := 2
	}
	if (rarityLevel == "Rare"){
		rarityLevel := 3
	}
	if (rarityLevel == "Unique"){
		rarityLevel := 4
	}

	if (rarityLevel == "Currency"){
		RegexMatch(namePlate, ".*$", currencyName)
		return [rarityLevel, currencyName]
	}
	
	;get the first line with the item class
	RegExMatch(namePlate, "(?<=Item Class: ).*", item_class)
	
	If (RegExMatch(item_class, "i)\b((One Hand|Two Hand) (Axes|Swords|Maces)|Sceptres|Staves|Warstaves|Daggers|Claws|Bows|Wands)\b", match))
		{
			baseType	:= "Weapon"
			If (RegExMatch(match1, "i)(Swords|Axes|Maces)", subMatch)) {
				subType	:= subMatch1
			} Else {
				subType	:= match1
			}
			subType:=SubStr(subType,1,StrLen(subType)-1)
			
			gripType	:= (RegExMatch(match1, "i)\b(Two Hand|Staffs|Warstaffs|Bows)\b")) ? "2H" : "1H"
			
			return [baseType, subType, gripType]
		}

	; Belts, Amulets, Rings, Quivers, Flasks
	If (RegExMatch(item_class, "i)\b(Belts|Stygian Vise|Rustic Sash)\b"))
	{
		baseType := "Accessory"
		subType = Belt
		return [baseType, subType]
	}		
	If (RegExMatch(item_class, "i)\b(Amulets|Talismans)\b")) and not (RegExMatch(item_class, "i)\bLeaguestone\b"))
	{
		baseType := "Accessory"
		subType = Amulet
		return [baseType, subType]
	}
	If (RegExMatch(item_class, "\b(Rings)\b", match))
	{
		baseType := "Accessory"
		subType := "Ring"
		return [baseType, subType]
	}
	If (RegExMatch(item_class, "\b(Quivers)\b", match))
	{
		baseType := "Armour"
		subType := "Quiver"
		return [baseType, subType]
	}
	If (RegExMatch(item_class, "Flasks", match))
	{
		
		baseType := "Flask"
		subType := "Flask"
		return [baseType, subType]
	}
	
	;Maps
	If (RegExMatch(item_class, "i)\b(Map)\b"))
	{
		Global mapMatchList
		baseType = Map
		Loop % mapMatchList.MaxIndex()
		{
			mapMatch := mapMatchList[A_Index]
			IfInString, item_class, %mapMatch%
			{
				If (RegExMatch(item_class, "\bShaped " . mapMatch))
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
	If (RegExMatch(item_class, "i)(Cobalt|Crimson|Viridian|Prismatic) Jewel", match)) {
		baseType = Jewel
		subType := "Jewel"
		return [baseType, subType]
	}
	; Abyss Jewels
	If (RegExMatch(item_class, "i)(Murderous|Hypnotic|Searching|Ghastly) Eye Jewel", match)) {
		baseType = Jewel
		subType := "Abyss Jewel"
		return [baseType, subType]
	}
	
	; Leaguestones and Scarabs
	If (RegExMatch(item_class, "i)\b(Leaguestone|Scarab)\b"))
	{
		RegexMatch(item_class, "i)(.*)(Leaguestone|Scarab)", typeMatch)
		RegexMatch(Trim(typeMatch1), "i)\b(\w+)\W*$", match) ; match last word
		baseType := Trim(typeMatch2)
		subType := Trim(match1) " " Trim(typeMatch2)
		return [baseType, subType]
	}


	; Matching armour types with regular expressions for compact code

	; Shields
	If (RegExMatch(item_class, "\b(Buckler|Bundle|Shields)\b"))
	{
		baseType = Armour
		subType = Shield
		return [baseType, subType]
	}

	; Gloves
	If (RegExMatch(item_class, "\b(Gauntlets|Gloves|Mitts)\b"))
	{
		baseType = Armour
		subType = Gloves
		return [baseType, subType]
	}

	; Boots
	If (RegExMatch(item_class, "\b(Boots|Greaves|Slippers|Shoes)\b"))
	{
		baseType = Armour
		subType = Boots
		return [baseType, subType]
	}

	; Helmets
	If (RegExMatch(item_class, "\b(Bascinet|Burgonet|Cage|Circlet|Crown|Hood|Helm|Helmet|Helmets|Mask|Sallet|Tricorne)\b"))
	{
		baseType = Armour
		subType = Helmet
		return [baseType, subType]
	}

	; Note: Body armours can have "Pelt" in their randomly assigned name,
	;    explicitly matching the three pelt base items to be safe.

	If (RegExMatch(item_class, "\b(Iron Hat|Leather Cap|Rusted Coif|Wolf Pelt|Ursine Pelt|Lion Pelt)\b"))
	{
		baseType = Armour
		subType = Helmet
		return [baseType, subType]
	}

	; BodyArmour
	; Note: Not using "$" means "Leather" could match "Leather Belt", therefore we first check that the item is not a belt. (belts are currently checked earlier so this is redundant, but the order might change)
	If (!RegExMatch(item_class, "\b(Belt)\b"))
	{
		If (RegExMatch(item_class, "\b(Body Armours|Brigandine|Chainmail|Coat|Doublet|Garb|Hauberk|Jacket|Lamellar|Leather|Plate|Raiment|Regalia|Ringmail|Robe|Tunic|Vest|Vestment)\b"))
		{
			baseType = Armour
			subType = BodyArmour
			return [baseType, subType]
		}
	}

	If (RegExMatch(item_class, "\b(Chestplate|Full Dragonscale|Full Wyrmscale|Necromancer Silks|Shabby Jerkin|Silken Wrap)\b"))
	{
		baseType = Armour
		subType = BodyArmour
		return [baseType, subType]
	}
}