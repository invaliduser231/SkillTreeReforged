function STR_GetHybridPlacement(skill : ESkill, out row : int, out column : int, out anchor : ESkill) : bool
{
	switch(skill)
	{
		case S_Sword_s17:
			row = 0;
			column = 0;
			anchor = S_Sword_s22;
			return true;
		case S_Magic_s14:
			row = 12;
			column = 12;
			anchor = S_Magic_s36;
			return true;
		case S_Alchemy_s01:
			row = 12;
			column = 12;
			anchor = S_Alchemy_s23;
			return true;
		case S_Alchemy_s06:
			row = 12;
			column = 0;
			anchor = S_Alchemy_s05;
			return true;
		case S_Alchemy_s17:
			row = 21;
			column = 12;
			anchor = S_Alchemy_s22;
			return true;
		case S_Perk_14:
			row = 0;
			column = 12;
			anchor = S_Perk_42;
			return true;
		case S_Perk_20:
			row = 25;
			column = 0;
			anchor = S_Perk_39;
			return true;
	}

	return false;
}

function STR_IsHybridSkill(skill : ESkill) : bool
{
	var row, column : int;
	var anchor : ESkill;

	return STR_GetHybridPlacement(skill, row, column, anchor);
}

function STR_GetHybridAnchor(skill : ESkill) : ESkill
{
	var row, column : int;
	var anchor : ESkill;

	if(!STR_GetHybridPlacement(skill, row, column, anchor))
		return S_SUndefined;

	return anchor;
}

function STR_IsHybridNode(skill : ESkill) : bool
{
	return STR_UseHybridTree() && STR_IsHybridSkill(skill);
}

function STR_GetTabSkillPath(tabIndex : int) : ESkillPath
{
	switch(tabIndex)
	{
		case CharacterMenuTab_Sword:
			return ESP_Sword;
		case CharacterMenuTab_Signs:
			return ESP_Signs;
		case CharacterMenuTab_Alchemy:
			return ESP_Alchemy;
		case CharacterMenuTab_Perks:
			return ESP_Perks;
	}

	return ESP_NotSet;
}

@addMethod(CR4CharacterDupeMenu)
function STR_AppendHybridEntries(path : ESkillPath, entries : CScriptedFlashArray)
{
	var playerSkills : array<SSkill>;
	var gfxSkill, dependency : CScriptedFlashObject;
	var dependencies : CScriptedFlashArray;
	var anchor : ESkill;
	var i, row, column : int;

	playerSkills = thePlayer.GetPlayerSkills();

	for(i = 1; i < playerSkills.Size(); i += 1)
	{
		if(playerSkills[i].skillPath != path || !STR_GetHybridPlacement(playerSkills[i].skillType, row, column, anchor))
			continue;

		gfxSkill = m_flashValueStorage.CreateTempFlashObject();
		GetSkillGFxObject(playerSkills[i], true, gfxSkill);
		gfxSkill.SetMemberFlashNumber('gridRow', row);
		gfxSkill.SetMemberFlashNumber('gridColumn', column);

		dependencies = gfxSkill.CreateFlashArray();
		dependency = gfxSkill.CreateFlashObject();
		dependency.SetMemberFlashString('name', NameToString(SkillEnumToName(anchor)));
		dependencies.PushBackFlashObject(dependency);
		gfxSkill.SetMemberFlashArray('skillDependencyRequirements', dependencies);
		gfxSkill.SetMemberFlashBool('isUsingSkillDependency', true);

		if(path == ESP_Perks)
			gfxSkill.SetMemberFlashInt('perkPosition', playerSkills[i].positionID);

		entries.PushBackFlashObject(gfxSkill);
	}
}
