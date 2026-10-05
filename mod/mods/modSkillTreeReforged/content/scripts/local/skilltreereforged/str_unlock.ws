@addMethod(W3PlayerAbilityManager)
function STR_IsOriginalTreeSkill(skill : ESkill) : bool
{
	if(skill == S_SUndefined || skills[skill].isCoreSkill || skills[skill].isReworked)
		return false;

	return skills[skill].skillSubPath != ESSP_NotSet && skills[skill].skillSubPath != ESSP_Core;
}

@addMethod(W3PlayerAbilityManager)
function STR_IsSkillOfTree(skill : ESkill, tree : ESTRSkillTree) : bool
{
	if(tree == STRST_Original)
		return STR_IsOriginalTreeSkill(skill);

	if(skill == S_SUndefined || skills[skill].isCoreSkill)
		return false;

	if(tree == STRST_Hybrid && STR_IsHybridSkill(skill))
		return true;

	return skills[skill].isReworked || skills[skill].isUnchangedLegacy;
}

@addMethod(W3PlayerAbilityManager)
function STR_IsTreeSkill(skill : ESkill) : bool
{
	return STR_IsSkillOfTree(skill, STR_GetSkillTree());
}

@addMethod(W3PlayerAbilityManager)
function STR_GetPathPoints(path : ESkillPath) : int
{
	var i, points : int;
	var tree : ESTRSkillTree;

	tree = STR_GetSkillTree();

	for(i = 0; i < skills.Size(); i += 1)
	{
		if(skills[i].skillPath != path || skills[i].level <= 0)
			continue;

		if(STR_IsSkillOfTree(skills[i].skillType, tree))
			points += skills[i].level;
	}

	return points;
}

@addMethod(W3PlayerAbilityManager)
function STR_GetTierThreshold(skill : ESkill) : int
{
	var row, column : int;
	var anchor : ESkill;

	if(STR_UseOriginalTree())
		return skills[skill].requiredPointsSpent;

	if(STR_IsHybridNode(skill))
	{
		STR_GetHybridPlacement(skill, row, column, anchor);
	}
	else
	{
		row = skills[skill].gridRow;
		column = skills[skill].gridColumn;
	}

	if(skills[skill].skillPath == ESP_Perks)
		return Abs(column - 6) / 3 * 6;

	return row / 6 * 6;
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

	if(STR_IsHybridNode(skill))
		return HasLearnedSkill(STR_GetHybridAnchor(skill));

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
	mode = STR_GetActiveUnlockMode();

	if(skills[skill].isReworked && STR_UseOriginalTree())
		return false;

	if((mode == STRUM_Remastered && !STR_IsHybridNode(skill)) || !STR_IsTreeSkill(skill))
		return remastered;

	return STR_CanLearnSkillInMode(skill, mode);
}

@wrapMethod(W3PlayerAbilityManager)
function IsSkillUnlockedByDependency(skill : ESkill) : bool
{
	var remastered : bool;
	var mode : ESTRUnlockMode;

	remastered = wrappedMethod(skill);
	mode = STR_GetActiveUnlockMode();

	if((mode == STRUM_Remastered && !STR_IsHybridNode(skill)) || !STR_IsTreeSkill(skill))
		return remastered;

	return STR_IsUnlockedInMode(skill, mode);
}

@wrapMethod(W3PlayerAbilityManager)
function HasSpentEnoughPoints(skill : ESkill) : bool
{
	var remastered : bool;
	var mode : ESTRUnlockMode;

	remastered = wrappedMethod(skill);
	mode = STR_GetActiveUnlockMode();

	if((mode == STRUM_Remastered && !STR_IsHybridNode(skill)) || !STR_IsTreeSkill(skill))
		return remastered;

	return STR_IsUnlockedInMode(skill, mode);
}
