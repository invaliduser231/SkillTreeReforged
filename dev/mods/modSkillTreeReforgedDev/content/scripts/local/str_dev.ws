function STRDev_Report(text : string)
{
	LogChannel('STRDev', text);
	theGame.GetGuiManager().ShowNotification(text);
}

function STRDev_Flag(value : bool) : string
{
	if(value)
		return "1";

	return "0";
}

function STRDev_Manager() : W3PlayerAbilityManager
{
	return (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
}

@addMethod(W3PlayerAbilityManager)
function STRDev_DumpSkills() : int
{
	var i, j : int;
	var line : string;
	var count : int;

	for(i = 0; i < skills.Size(); i += 1)
	{
		if(skills[i].skillType == S_SUndefined)
			continue;

		line = NameToString(skills[i].abilityName) + " path=" + IntToString((int)skills[i].skillPath);
		line += " lvl=" + IntToString(skills[i].level) + "/" + IntToString(skills[i].maxLevel);
		line += " cost=" + IntToString(skills[i].cost) + " pts=" + IntToString(skills[i].requiredPointsSpent);
		line += " reworked=" + STRDev_Flag(skills[i].isReworked) + " legacy=" + STRDev_Flag(skills[i].isUnchangedLegacy);
		line += " core=" + STRDev_Flag(skills[i].isCoreSkill) + " anyOf=" + STRDev_Flag(skills[i].requiredSkillsIsAlternative);
		line += " row=" + IntToString(skills[i].gridRow) + " col=" + IntToString(skills[i].gridColumn);
		line += " tier=" + IntToString(STR_GetTierThreshold(skills[i].skillType)) + " req=";

		for(j = 0; j < skills[i].requiredSkills.Size(); j += 1)
			line += NameToString(SkillEnumToName(skills[i].requiredSkills[j])) + ",";

		LogChannel('STRDev', line);
		count += 1;
	}

	return count;
}

@addMethod(W3PlayerAbilityManager)
function STRDev_CountLearnable(mode : ESTRUnlockMode) : int
{
	var i, count : int;

	for(i = 0; i < skills.Size(); i += 1)
		if(STR_CanLearnSkillInMode(skills[i].skillType, mode))
			count += 1;

	return count;
}

@addMethod(W3PlayerAbilityManager)
function STRDev_Fail(reason : string, skill : ESkill) : int
{
	LogChannel('STRDev', "FAIL " + reason + " " + NameToString(skills[skill].abilityName));
	return 1;
}

@addMethod(W3PlayerAbilityManager)
function STRDev_CheckInvariants() : int
{
	var i, failures : int;
	var skill : ESkill;
	var remastered, classic, flexible, free, game : bool;
	var savedMode : string;

	savedMode = STR_ReadSetting('SkillTreeReforgedUnlock', 'STRUnlockMode');
	theGame.GetInGameConfigWrapper().SetVarValue('SkillTreeReforgedUnlock', 'STRUnlockMode', "0");

	for(i = 0; i < skills.Size(); i += 1)
	{
		skill = skills[i].skillType;
		if(!STR_IsTreeSkill(skill))
			continue;

		remastered = STR_CanLearnSkillInMode(skill, STRUM_Remastered);
		classic = STR_CanLearnSkillInMode(skill, STRUM_Classic);
		flexible = STR_CanLearnSkillInMode(skill, STRUM_Flexible);
		free = STR_CanLearnSkillInMode(skill, STRUM_Free);
		game = CanLearnSkill(skill);

		if(remastered && !flexible)
			failures += STRDev_Fail("flexible blocks remastered", skill);

		if(classic && !flexible)
			failures += STRDev_Fail("flexible blocks classic", skill);

		if(flexible && !free)
			failures += STRDev_Fail("free blocks flexible", skill);

		if(classic && !STR_MeetsTier(skill))
			failures += STRDev_Fail("classic ignores tier", skill);

		if(remastered != game)
			failures += STRDev_Fail("remastered differs from game", skill);

		if(classic && STR_IsBlockedByTier(skill, STRUM_Classic))
			failures += STRDev_Fail("classic hint on learnable skill", skill);

		if(flexible && STR_IsBlockedByTier(skill, STRUM_Flexible))
			failures += STRDev_Fail("flexible hint on learnable skill", skill);
	}

	theGame.GetInGameConfigWrapper().SetVarValue('SkillTreeReforgedUnlock', 'STRUnlockMode', savedMode);

	return failures;
}

@addMethod(W3PlayerAbilityManager)
function STRDev_PathSummary() : string
{
	return "points S=" + IntToString(STR_GetPathPoints(ESP_Sword))
		+ " M=" + IntToString(STR_GetPathPoints(ESP_Signs))
		+ " A=" + IntToString(STR_GetPathPoints(ESP_Alchemy))
		+ " P=" + IntToString(STR_GetPathPoints(ESP_Perks));
}

exec function str_dump()
{
	STRDev_Report("STRDev dumped " + IntToString(STRDev_Manager().STRDev_DumpSkills()) + " skills to scriptlog");
}

exec function str_mode(mode : int)
{
	STR_SetUnlockMode((ESTRUnlockMode)mode);
	STRDev_Report("STRDev unlock mode " + IntToString(mode));
}

exec function str_points(amount : int)
{
	GetWitcherPlayer().levelManager.AddPoints(ESkillPoint, amount, false);
	STRDev_Report("STRDev added " + IntToString(amount) + " skill points");
}

exec function str_test()
{
	var manager : W3PlayerAbilityManager;
	var failures : int;

	manager = STRDev_Manager();
	failures = manager.STRDev_CheckInvariants();

	STRDev_Report("STRDev " + manager.STRDev_PathSummary()
		+ " learnable R=" + IntToString(manager.STRDev_CountLearnable(STRUM_Remastered))
		+ " C=" + IntToString(manager.STRDev_CountLearnable(STRUM_Classic))
		+ " X=" + IntToString(manager.STRDev_CountLearnable(STRUM_Flexible))
		+ " F=" + IntToString(manager.STRDev_CountLearnable(STRUM_Free))
		+ " failures=" + IntToString(failures));
}

@addMethod(W3PlayerAbilityManager)
function STRDev_LegacySummary() : string
{
	var i, legacyRanks, remasteredRanks, legacySkills, remasteredSkills : int;

	for(i = 0; i < skills.Size(); i += 1)
	{
		if(skills[i].skillType == S_SUndefined || skills[i].isCoreSkill || skills[i].level <= 0)
			continue;

		if(skills[i].isReworked)
		{
			remasteredSkills += 1;
			remasteredRanks += skills[i].level;
		}
		else
		{
			legacySkills += 1;
			legacyRanks += skills[i].level;
		}
	}

	return "legacy " + IntToString(legacySkills) + " skills/" + IntToString(legacyRanks) + " ranks, remastered " + IntToString(remasteredSkills) + " skills/" + IntToString(remasteredRanks) + " ranks";
}

exec function str_legacy(enabled : bool)
{
	var value : string;

	value = "false";
	if(enabled)
		value = "true";

	theGame.GetInGameConfigWrapper().SetVarValue('RemasterCombat', 'UseLegacySkillTree', value);
	theGame.SaveUserSettings();
	STRDev_Report("STRDev legacy skill tree " + value + ", " + STRDev_Manager().STRDev_LegacySummary());
}

exec function str_legacy_info()
{
	STRDev_Report("STRDev legacy=" + theGame.GetInGameConfigWrapper().GetVarValue('RemasterCombat', 'UseLegacySkillTree') + ", " + STRDev_Manager().STRDev_LegacySummary());
}
