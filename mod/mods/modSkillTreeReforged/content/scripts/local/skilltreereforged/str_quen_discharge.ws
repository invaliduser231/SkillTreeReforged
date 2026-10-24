function STR_QuenDischargeMovedToExplodingShield() : bool
{
	var min, max : SAbilityAttributeValue;

	theGame.GetDefinitionsManager().GetAbilityAttributeValue('magic_s13', 'discharge_percent', min, max);
	return CalculateAttributeValue(min) > 0;
}

@addMethod(W3QuenEntity)
function STR_ApplyQuenDischarge(damageData : W3DamageAction)
{
	var player : W3PlayerWitcher;
	var casterActor : CActor;
	var attackAction : W3Action_Attack;
	var discharge : W3DamageAction;
	var min, max : SAbilityAttributeValue;
	var ratio, incomingDamage : float;

	player = GetWitcherPlayer();
	casterActor = owner.GetActor();
	if(!player || !damageData || !damageData.attacker || casterActor != thePlayer)
		return;

	if(!player.CanUseSkill(S_Magic_s14) || player.CanUseSkill(S_Magic_s13) || !STR_QuenDischargeMovedToExplodingShield())
		return;

	if(damageData.WasDodged() || damageData.GetHitReactionType() == EHRT_Reflect || damageData.IsDoTDamage() || damageData.IsActionRanged())
		return;

	if((CBaseGameplayEffect)damageData.causer)
		return;

	attackAction = (W3Action_Attack)damageData;
	if(attackAction && attackAction.CanBeParried() && (attackAction.IsParried() || attackAction.IsCountered()))
		return;

	if(damageData.attacker == casterActor || !IsRequiredAttitudeBetween(thePlayer, damageData.attacker, true))
		return;

	if(VecDistanceSquared(casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition()) > 13)
		return;

	ratio = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s14, 'discharge_percent', false, true)) * owner.GetSkillLevel(S_Magic_s14);
	if(player.IsSetBonusActive(EISB_Bear_2))
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(GetSetBonusAbility(EISB_Bear_2), 'quen_dmg_boost', min, max);
		ratio *= 1 + min.valueMultiplicative;
	}

	incomingDamage = MaxF(0, damageData.processedDmg.vitalityDamage - damageData.GetDamageValue(theGame.params.DAMAGE_NAME_DIRECT));
	if(ratio <= 0 || incomingDamage <= 0)
		return;

	discharge = new W3DamageAction in theGame.damageMgr;
	discharge.Initialize(casterActor, damageData.attacker, this, 'quen', EHRT_Light, CPS_SpellPower, false, false, true, false, 'hit_shock');
	InitSignDataForDamageAction(discharge);
	discharge.AddDamage(theGame.params.DAMAGE_NAME_SHOCK, ratio * incomingDamage);
	discharge.SetCanPlayHitParticle(true);
	discharge.SetHitEffect('hit_electric_quen');
	discharge.SetHitEffect('hit_electric_quen', true);
	discharge.SetHitEffect('hit_electric_quen', false, true);
	discharge.SetHitEffect('hit_electric_quen', true, true);
	theGame.damageMgr.ProcessAction(discharge);
	delete discharge;

	casterActor.PlayEffect('quen_force_discharge');
}

@wrapMethod(W3QuenEntity)
function OnTargetHit(out damageData : W3DamageAction)
{
	wrappedMethod(damageData);
	STR_ApplyQuenDischarge(damageData);
}
