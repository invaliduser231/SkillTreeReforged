@addMethod(W3PlayerAbilityManager)
function STR_IsTreeSkill(skill : ESkill) : bool
{
	if(skill == S_SUndefined || skills[skill].isCoreSkill)
		return false;

	return skills[skill].isReworked || skills[skill].isUnchangedLegacy;
}

@addMethod(W3PlayerAbilityManager)
function STR_GetPathPoints(path : ESkillPath) : int
{
	var i, points : int;

	for(i = 0; i < skills.Size(); i += 1)
	{
		if(skills[i].skillPath != path || skills[i].level <= 0)
			continue;

		if(STR_IsTreeSkill(skills[i].skillType))
			points += skills[i].level;
	}

	return points;
}

@addMethod(W3PlayerAbilityManager)
function STR_GetTierThreshold(skill : ESkill) : int
{
	if(skills[skill].skillPath == ESP_Perks)
		return Abs(skills[skill].gridColumn - 6) / 3 * 6;

	return skills[skill].gridRow / 6 * 6;
}

@addMethod(W3PlayerAbilityManager)
function STR_MeetsTier(skill : ESkill) : bool
{
	return STR_GetPathPoints(skills[skill].skillPath) >= STR_GetTierThreshold(skill);
}

@addMethod(W3PlayerAbilityManager)
function STR_MeetsDependencies(skill : ESkill) : bool
{
	var required : array<ESkill>;
	var anyIsEnough : bool;
	var i : int;

	required = skills[skill].requiredSkills;
	if(required.Size() == 0)
		return true;

	anyIsEnough = skills[skill].requiredSkillsIsAlternative;

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
function STR_IsUnlockedInMode(skill : ESkill, mode : ESTRUnlockMode) : bool
{
	switch(mode)
	{
		case STRUM_Classic:
			return STR_MeetsTier(skill);
		case STRUM_Flexible:
			return STR_MeetsDependencies(skill) || STR_MeetsTier(skill);
		case STRUM_Free:
			return true;
	}

	return STR_MeetsDependencies(skill);
}

@addMethod(W3PlayerAbilityManager)
function STR_IsBlockedByTier(skill : ESkill, mode : ESTRUnlockMode) : bool
{
	if(!STR_IsTreeSkill(skill) || skills[skill].level >= skills[skill].maxLevel)
		return false;

	if(STR_MeetsTier(skill))
		return false;

	switch(mode)
	{
		case STRUM_Classic:
			return true;
		case STRUM_Flexible:
			return !STR_MeetsDependencies(skill);
	}

	return false;
}

@addMethod(W3PlayerAbilityManager)
function STR_CanLearnSkillInMode(skill : ESkill, mode : ESTRUnlockMode) : bool
{
	if(!STR_IsTreeSkill(skill))
		return false;

	if(skills[skill].level >= skills[skill].maxLevel)
		return false;

	if(((W3PlayerWitcher)owner).levelManager.GetPointsFree(ESkillPoint) < skills[skill].cost)
		return false;

	return STR_IsUnlockedInMode(skill, mode);
}

@wrapMethod(W3PlayerAbilityManager)
function CanLearnSkill(skill : ESkill) : bool
{
	var remastered : bool;
	var mode : ESTRUnlockMode;

	remastered = wrappedMethod(skill);
	mode = STR_GetUnlockMode();

	if(mode == STRUM_Remastered || !STR_IsTreeSkill(skill))
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

	if(mode == STRUM_Remastered || !STR_IsTreeSkill(skill))
		return remastered;

	return STR_IsUnlockedInMode(skill, mode);
}

@wrapMethod(W3PlayerAbilityManager)
function HasSpentEnoughPoints(skill : ESkill) : bool
{
	var remastered : bool;
	var mode : ESTRUnlockMode;

	remastered = wrappedMethod(skill);
	mode = STR_GetUnlockMode();

	if(mode == STRUM_Remastered || !STR_IsTreeSkill(skill))
		return remastered;

	return STR_IsUnlockedInMode(skill, mode);
}
