@wrapMethod(CR4CharacterDupeMenu)
function GetSkillTooltipDescription(targetSkill : SSkill, isGridView : bool, out currentLevelDesc : string, out nextLevelDesc : string) : void
{
	var pam : W3PlayerAbilityManager;
	var tierPoints : array<int>;

	wrappedMethod(targetSkill, isGridView, currentLevelDesc, nextLevelDesc);

	pam = (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
	if(!pam || !pam.STR_IsBlockedByTier(targetSkill.skillType, STR_GetActiveUnlockMode()))
		return;

	tierPoints.PushBack(pam.STR_GetTierThreshold(targetSkill.skillType));
	tierPoints.PushBack(pam.STR_GetPathPoints(targetSkill.skillPath));

	nextLevelDesc += "<br><br><font color=\"#d61010\">" + GetLocStringByKeyExtWithParams("str_tooltip_tree_points", tierPoints) + "</font>";
}

@wrapMethod(CR4CharacterDupeMenu)
function GetSkillTooltipDescriptionForSkillLevel(targetSkill : SSkill, skillLevel : int) : string
{
	var description : string;
	var ability : SAbilityAttributeValue;
	var args : array<string>;

	description = wrappedMethod(targetSkill, skillLevel);

	if(targetSkill.skillType == S_Perk_15)
	{
		ability = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_15, 'duration', false, false);
		args.PushBack(NoTrailZeros(ability.valueAdditive / 60));
		description = GetLocStringByKeyExtWithParams(targetSkill.localisationDescriptionKey, , , args);
	}

	return description;
}
