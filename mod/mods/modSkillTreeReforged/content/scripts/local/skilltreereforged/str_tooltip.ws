@wrapMethod(CR4CharacterDupeMenu)
function GetSkillTooltipDescription(targetSkill : SSkill, isGridView : bool, out currentLevelDesc : string, out nextLevelDesc : string) : void
{
	var pam : W3PlayerAbilityManager;
	var tierPoints : array<int>;

	wrappedMethod(targetSkill, isGridView, currentLevelDesc, nextLevelDesc);

	pam = (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
	if(!pam || !pam.STR_IsBlockedByTier(targetSkill.skillType, STR_GetUnlockMode()))
		return;

	tierPoints.PushBack(pam.STR_GetTierThreshold(targetSkill.skillType));
	tierPoints.PushBack(pam.STR_GetPathPoints(targetSkill.skillPath));

	nextLevelDesc += "<br><br><font color=\"#d61010\">" + GetLocStringByKeyExtWithParams("str_tooltip_tree_points", tierPoints) + "</font>";
}
