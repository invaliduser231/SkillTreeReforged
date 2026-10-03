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
		line += " core=" + STRDev_Flag(skills[i].isCoreSkill) + " anyOf=" + STRDev_Flag(skills[i].requiredSkillsIsAlternative) + " req=";

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
function STRDev_CheckInvariants() : int
{
	var i, failures : int;
	var skill : ESkill;
	var remastered, classic, loose, free : bool;

	for(i = 0; i < skills.Size(); i += 1)
	{
		skill = skills[i].skillType;
		if(skill == S_SUndefined)
			continue;

		remastered = STR_CanLearnSkillInMode(skill, STRUM_Remastered);
		classic = STR_CanLearnSkillInMode(skill, STRUM_Classic);
		loose = STR_CanLearnSkillInMode(skill, STRUM_Loose);
		free = STR_CanLearnSkillInMode(skill, STRUM_Free);

		if(remastered && !loose)
		{
			LogChannel('STRDev', "FAIL loose blocks " + NameToString(skills[i].abilityName));
			failures += 1;
		}

		if((remastered || classic || loose) && !free)
		{
			LogChannel('STRDev', "FAIL free blocks " + NameToString(skills[i].abilityName));
			failures += 1;
		}

		if(classic && skills[i].requiredPointsSpent > pathPointsSpent[skills[i].skillPath])
		{
			LogChannel('STRDev', "FAIL classic ignores points " + NameToString(skills[i].abilityName));
			failures += 1;
		}
	}

	return failures;
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

	STRDev_Report("STRDev learnable R=" + IntToString(manager.STRDev_CountLearnable(STRUM_Remastered))
		+ " C=" + IntToString(manager.STRDev_CountLearnable(STRUM_Classic))
		+ " L=" + IntToString(manager.STRDev_CountLearnable(STRUM_Loose))
		+ " F=" + IntToString(manager.STRDev_CountLearnable(STRUM_Free))
		+ " failures=" + IntToString(failures));
}
