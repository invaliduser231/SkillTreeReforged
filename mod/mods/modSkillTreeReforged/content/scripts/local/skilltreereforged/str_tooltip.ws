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

function STR_SkillAttribute(skill : ESkill, attributeName : name, addSkillMods : bool) : SAbilityAttributeValue
{
	return GetWitcherPlayer().GetSkillAttributeValue(skill, attributeName, false, addSkillMods);
}

function STR_LegacyTooltipArgs(skill : ESkill, skillLevel : int, out ints : array<int>, out floats : array<float>, out strings : array<string>) : bool
{
	var charges : float;
	var ability : SAbilityAttributeValue;

	switch(skill)
	{
		case S_Sword_s09:
			ints.PushBack(RoundMath(CalculateAttributeValue(STR_SkillAttribute(S_Sword_s09, 'damage_reduction', false)) * skillLevel * 100));
			return true;
		case S_Magic_s02:
			ability = STR_SkillAttribute(S_Magic_s02, 'stamina_cost_reduction_after_1', false);
			ints.PushBack(RoundMath(ability.valueMultiplicative * (skillLevel - 1) * 100));
			return true;
		case S_Magic_s10:
			ints.PushBack(RoundMath(CalculateAttributeValue(STR_SkillAttribute(S_Magic_s10, 'trap_duration', false)) * skillLevel));
			charges = CalculateAttributeValue(STR_SkillAttribute(S_Magic_s03, 'charge_count', false));
			charges += CalculateAttributeValue(STR_SkillAttribute(S_Magic_s10, 'charge_count', false)) * skillLevel;
			ints.PushBack(RoundMath(charges));
			if(skillLevel > 1)
				ints.PushBack(2);
			else
				ints.PushBack(1);
			return true;
		case S_Alchemy_s19:
			ints.PushBack(RoundMath(CalculateAttributeValue(STR_SkillAttribute(S_Alchemy_s19, 'synergy_bonus', false)) * skillLevel * 100));
			return true;
		case S_Perk_15:
			ability = STR_SkillAttribute(S_Perk_15, 'duration', false);
			strings.PushBack(NoTrailZeros(ability.valueAdditive / 60));
			return true;
		case S_Perk_18:
			ability = STR_SkillAttribute(S_Perk_18, 'focus_gain', true);
			floats.PushBack(ability.valueAdditive);
			return true;
		case S_Perk_19:
			ability = STR_SkillAttribute(S_Perk_19, 'critical_hit_chance', true);
			ints.PushBack(RoundMath(100 * ability.valueAdditive));
			return true;
	}

	return false;
}

@wrapMethod(CR4CharacterDupeMenu)
function GetSkillTooltipDescriptionForSkillLevel(targetSkill : SSkill, skillLevel : int) : string
{
	var description, rawText, locKey : string;
	var ints : array<int>;
	var floats : array<float>;
	var strings : array<string>;
	var level : int;

	description = wrappedMethod(targetSkill, skillLevel);

	level = skillLevel;
	if(level == 2)
		locKey = targetSkill.localisationDescriptionLevel2Key;
	else if(level >= 3)
		locKey = targetSkill.localisationDescriptionLevel3Key;
	else
		locKey = targetSkill.localisationDescriptionKey;

	if(level == 0)
		level = 1;

	if(!STR_LegacyTooltipArgs(targetSkill.skillType, level, ints, floats, strings))
		return description;

	rawText = GetLocStringByKeyExt(locKey);
	if(!StrBeginsWith(description, rawText))
		return description;

	return GetLocStringByKeyExtWithParams(locKey, ints, floats, strings) + StrRight(description, StrLen(description) - StrLen(rawText));
}
