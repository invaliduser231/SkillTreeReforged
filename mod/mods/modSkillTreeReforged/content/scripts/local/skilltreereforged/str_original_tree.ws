function STR_GetOriginalColumn(subPath : ESkillSubPath) : int
{
	switch(subPath)
	{
		case ESSP_Sword_StyleFast:
		case ESSP_Signs_Aard:
		case ESSP_Alchemy_Potions:
		case ESSP_Perks_col1:
			return 0;
		case ESSP_Sword_StyleStrong:
		case ESSP_Signs_Igni:
		case ESSP_Alchemy_Oils:
		case ESSP_Perks_col2:
			return 3;
		case ESSP_Sword_Utility:
		case ESSP_Signs_Yrden:
		case ESSP_Alchemy_Bombs:
		case ESSP_Perks_col3:
			return 6;
		case ESSP_Sword_Crossbow:
		case ESSP_Signs_Quen:
		case ESSP_Alchemy_Mutagens:
		case ESSP_Perks_col4:
			return 9;
	}

	return 12;
}

@addMethod(W3PlayerAbilityManager)
function STR_GetOriginalRow(skill : ESkill) : int
{
	var i, rank : int;

	if(skills[skill].skillPath != ESP_Perks)
		return skills[skill].requiredPointsSpent;

	for(i = 0; i < skills.Size(); i += 1)
	{
		if(skills[i].skillSubPath == skills[skill].skillSubPath && skills[i].positionID < skills[skill].positionID && STR_IsOriginalTreeSkill(skills[i].skillType))
			rank += 1;
	}

	return rank * 6;
}

@addMethod(CR4CharacterDupeMenu)
function STR_BuildOriginalTab(path : ESkillPath) : CScriptedFlashArray
{
	var pam : W3PlayerAbilityManager;
	var playerSkills : array<SSkill>;
	var gfxSkills : CScriptedFlashArray;
	var gfxSkill : CScriptedFlashObject;
	var mode : ESTRUnlockMode;
	var i, pathPoints : int;

	pam = (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
	mode = STR_GetActiveUnlockMode();
	pathPoints = pam.STR_GetPathPoints(path);
	gfxSkills = m_flashValueStorage.CreateTempFlashArray();
	playerSkills = thePlayer.GetPlayerSkills();

	for(i = 1; i < playerSkills.Size(); i += 1)
	{
		if(playerSkills[i].skillPath != path || !pam.STR_IsOriginalTreeSkill(playerSkills[i].skillType))
			continue;

		gfxSkill = m_flashValueStorage.CreateTempFlashObject();
		GetSkillGFxObject(playerSkills[i], true, gfxSkill);
		gfxSkill.SetMemberFlashNumber('gridRow', pam.STR_GetOriginalRow(playerSkills[i].skillType));
		gfxSkill.SetMemberFlashNumber('gridColumn', STR_GetOriginalColumn(playerSkills[i].skillSubPath));
		gfxSkill.SetMemberFlashArray('skillDependencyRequirements', gfxSkill.CreateFlashArray());
		gfxSkill.SetMemberFlashBool('isUsingSkillDependency', true);
		gfxSkill.SetMemberFlashInt('requiredPointsSpent', playerSkills[i].requiredPointsSpent);
		gfxSkill.SetMemberFlashString('skillPathPoints', IntToString(pathPoints));
		gfxSkill.SetMemberFlashBool('hasRequiredPointsSpent', pam.STR_IsUnlockedInMode(playerSkills[i].skillType, mode));

		if(path == ESP_Perks)
			gfxSkill.SetMemberFlashInt('perkPosition', playerSkills[i].positionID);

		gfxSkills.PushBackFlashObject(gfxSkill);
	}

	return gfxSkills;
}

@wrapMethod(CR4CharacterDupeMenu)
function PopulateDataForTab(tabIndex : int, entriesArray : CScriptedFlashArray) : void
{
	var entries : CScriptedFlashArray;

	entries = entriesArray;

	if(STR_UseOriginalTree())
	{
		switch(tabIndex)
		{
			case CharacterMenuTab_Sword:
				entries = STR_BuildOriginalTab(ESP_Sword);
				break;
			case CharacterMenuTab_Signs:
				entries = STR_BuildOriginalTab(ESP_Signs);
				break;
			case CharacterMenuTab_Alchemy:
				entries = STR_BuildOriginalTab(ESP_Alchemy);
				break;
			case CharacterMenuTab_Perks:
				entries = STR_BuildOriginalTab(ESP_Perks);
				break;
		}
	}

	wrappedMethod(tabIndex, entries);
}
