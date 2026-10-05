enum ESTRUnlockMode
{
	STRUM_Remastered,
	STRUM_Classic,
	STRUM_Flexible,
	STRUM_Free
}

enum ESTRSkillTree
{
	STRST_Remastered,
	STRST_Original,
	STRST_Hybrid
}

function STR_ReadSetting(group : name, key : name) : string
{
	if(!theGame || !theGame.GetInGameConfigWrapper())
		return "";

	return theGame.GetInGameConfigWrapper().GetVarValue(group, key);
}

function STR_GetUnlockMode() : ESTRUnlockMode
{
	switch(StringToInt(STR_ReadSetting('SkillTreeReforgedUnlock', 'STRUnlockMode'), 0))
	{
		case 1:
			return STRUM_Classic;
		case 2:
			return STRUM_Flexible;
		case 3:
			return STRUM_Free;
	}

	return STRUM_Remastered;
}

function STR_GetSkillTree() : ESTRSkillTree
{
	switch(STR_ReadSetting('SkillTreeReforgedTree', 'STRSkillTree'))
	{
		case "1":
			return STRST_Original;
		case "2":
			return STRST_Hybrid;
	}

	return STRST_Remastered;
}

function STR_UseOriginalTree() : bool
{
	return STR_GetSkillTree() == STRST_Original;
}

function STR_UseHybridTree() : bool
{
	return STR_GetSkillTree() == STRST_Hybrid;
}

function STR_GetActiveUnlockMode() : ESTRUnlockMode
{
	var mode : ESTRUnlockMode;

	mode = STR_GetUnlockMode();
	if(STR_UseOriginalTree() && mode != STRUM_Free)
		return STRUM_Classic;

	return mode;
}

function STR_KeepClearingPotion() : bool
{
	return STR_ReadSetting('SkillTreeReforgedRespec', 'STRKeepClearingPotion') == "true";
}

function STR_SetUnlockMode(mode : ESTRUnlockMode)
{
	if(!theGame || !theGame.GetInGameConfigWrapper())
		return;

	theGame.GetInGameConfigWrapper().SetVarValue('SkillTreeReforgedUnlock', 'STRUnlockMode', IntToString((int)mode));
	theGame.SaveUserSettings();
}
