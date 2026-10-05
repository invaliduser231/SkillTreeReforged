class STR_TreeSwitchConfirmation extends ConfirmationPopupData
{
	public var characterMenu : CR4CharacterDupeMenu;

	protected function OnUserAccept() : void
	{
		characterMenu.STR_ApplyTreeSwitch();
	}

	protected function OnUserDecline() : void
	{
		super.OnUserDecline();
		characterMenu.STR_CancelTreeSwitch();
	}
}

function STR_GetSaveTree() : ESTRSkillTree
{
	if(FactsQuerySum("str_original_tree") > 0)
		return STRST_Original;

	if(FactsQuerySum("str_hybrid_tree") > 0)
		return STRST_Hybrid;

	return STRST_Remastered;
}

function STR_SetSaveTree(tree : ESTRSkillTree)
{
	FactsRemove("str_original_tree");
	FactsRemove("str_hybrid_tree");

	if(tree == STRST_Original)
		FactsAdd("str_original_tree", 1, -1);
	else if(tree == STRST_Hybrid)
		FactsAdd("str_hybrid_tree", 1, -1);
}

function STR_SetTreeSetting(tree : ESTRSkillTree)
{
	if(!theGame || !theGame.GetInGameConfigWrapper())
		return;

	theGame.GetInGameConfigWrapper().SetVarValue('SkillTreeReforgedTree', 'STRSkillTree', IntToString((int)tree));
	theGame.SaveUserSettings();
}

@addMethod(W3PlayerAbilityManager)
function STR_HasSkillsOutsideTree(fromTree : ESTRSkillTree, toTree : ESTRSkillTree) : bool
{
	var i : int;

	for(i = 0; i < skills.Size(); i += 1)
	{
		if(skills[i].level <= 0)
			continue;

		if(STR_IsSkillOfTree(skills[i].skillType, fromTree) && !STR_IsSkillOfTree(skills[i].skillType, toTree))
			return true;
	}

	return false;
}

@addField(CR4CharacterDupeMenu)
var strTreeSwitchPopup : STR_TreeSwitchConfirmation;

@addField(CR4CharacterDupeMenu)
var strTreeSwitchPending : bool;

@addField(CR4CharacterDupeMenu)
var strTreeSwitchTarget : ESTRSkillTree;

@addMethod(CR4CharacterDupeMenu)
function STR_CheckTreeSwitch()
{
	var pam : W3PlayerAbilityManager;
	var tree, saveTree : ESTRSkillTree;

	if(strTreeSwitchPending)
		return;

	tree = STR_GetSkillTree();
	saveTree = STR_GetSaveTree();
	if(tree == saveTree)
		return;

	pam = (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
	if(!pam || !pam.STR_HasSkillsOutsideTree(saveTree, tree))
	{
		STR_SetSaveTree(tree);
		return;
	}

	STR_SetTreeSetting(saveTree);

	if(thePlayer.IsInCombat())
	{
		showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
		return;
	}

	strTreeSwitchPending = true;
	strTreeSwitchTarget = tree;
}

@addMethod(CR4CharacterDupeMenu)
function STR_AskTreeSwitch()
{
	if(!strTreeSwitchPending || strTreeSwitchPopup)
		return;

	strTreeSwitchPopup = new STR_TreeSwitchConfirmation in this;
	strTreeSwitchPopup.HideTutorial = true;
	strTreeSwitchPopup.SetMessageTitle(GetLocStringByKeyExt("str_tree_switch_title"));
	strTreeSwitchPopup.SetMessageText(GetLocStringByKeyExt("str_tree_switch_text"));
	strTreeSwitchPopup.characterMenu = this;
	strTreeSwitchPopup.BlurBackground = true;

	RequestSubMenu('PopupMenu', strTreeSwitchPopup);
}

@addMethod(CR4CharacterDupeMenu)
function STR_ApplyTreeSwitch()
{
	STR_SetTreeSetting(strTreeSwitchTarget);
	GetWitcherPlayer().ResetCharacterDev();
	STR_SetSaveTree(strTreeSwitchTarget);
	strTreeSwitchPending = false;
	strTreeSwitchPopup = NULL;
	UpdateData(true);
}

@addMethod(CR4CharacterDupeMenu)
function STR_CancelTreeSwitch()
{
	strTreeSwitchPending = false;
	strTreeSwitchPopup = NULL;
}

@wrapMethod(CR4CharacterDupeMenu)
function UpdateData(tabs : bool) : void
{
	STR_CheckTreeSwitch();
	wrappedMethod(tabs);
}

@wrapMethod(CR4CharacterDupeMenu)
function OnTabChanged(tabIndex : int)
{
	wrappedMethod(tabIndex);
	STR_AskTreeSwitch();
}

@wrapMethod(CR4CharacterDupeMenu)
function OnSetSelectedRenderer(id : int)
{
	wrappedMethod(id);
	STR_AskTreeSwitch();
}
