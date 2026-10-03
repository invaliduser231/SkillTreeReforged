@addMethod(W3PlayerAbilityManager)
function STR_UsesDependencies(skill : ESkill) : bool
{
	return skills[skill].isReworked || skills[skill].isUnchangedLegacy;
}

@addMethod(W3PlayerAbilityManager)
function STR_MeetsDependencies(skill : ESkill, mode : ESTRUnlockMode) : bool
{
	var required : array<ESkill>;
	var anyIsEnough : bool;
	var i : int;

	if(mode == STRUM_Free || mode == STRUM_Classic)
		return true;

	if(!STR_UsesDependencies(skill))
		return true;

	required = skills[skill].requiredSkills;
	if(required.Size() == 0)
		return true;

	anyIsEnough = mode == STRUM_Loose || skills[skill].requiredSkillsIsAlternative;

	for(i = 0; i < required.Size(); i += 1)
	{
		if(HasLearnedSkill(required[i]))
		{
			if(anyIsEnough)
				return true;
		}
		else if(!anyIsEnough)
		{
			return false;
		}
	}

	return !anyIsEnough;
}

@addMethod(W3PlayerAbilityManager)
function STR_MeetsPathPoints(skill : ESkill, mode : ESTRUnlockMode) : bool
{
	if(mode != STRUM_Classic)
		return true;

	if(skills[skill].requiredPointsSpent <= 0)
		return true;

	return pathPointsSpent[skills[skill].skillPath] >= skills[skill].requiredPointsSpent;
}

@addMethod(W3PlayerAbilityManager)
function STR_CanLearnSkillInMode(skill : ESkill, mode : ESTRUnlockMode) : bool
{
	if(skill == S_SUndefined)
		return false;

	if(skills[skill].isCoreSkill)
		return false;

	if(skills[skill].level >= skills[skill].maxLevel)
		return false;

	if(((W3PlayerWitcher)owner).levelManager.GetPointsFree(ESkillPoint) < skills[skill].cost)
		return false;

	if(!STR_MeetsDependencies(skill, mode))
		return false;

	return STR_MeetsPathPoints(skill, mode);
}

@wrapMethod(W3PlayerAbilityManager)
function CanLearnSkill(skill : ESkill) : bool
{
	var remastered : bool;
	var mode : ESTRUnlockMode;

	remastered = wrappedMethod(skill);
	mode = STR_GetUnlockMode();

	if(mode == STRUM_Remastered)
		return remastered;

	return STR_CanLearnSkillInMode(skill, mode);
}

@wrapMethod(W3PlayerAbilityManager)
function IsSkillUnlockedByDependency(skill : ESkill) : bool
{
	var remastered : bool;
	var mode : ESTRUnlockMode;

	remastered = wrappedMethod(skill);
	mode = STR_GetUnlockMode();

	if(mode == STRUM_Remastered)
		return remastered;

	return STR_MeetsDependencies(skill, mode) && STR_MeetsPathPoints(skill, mode);
}
