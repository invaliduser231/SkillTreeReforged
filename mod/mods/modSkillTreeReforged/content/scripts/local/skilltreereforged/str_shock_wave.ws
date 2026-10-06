@addMethod(W3AardProjectile)
function STR_ApplyShockWave(victimNPC : CNewNPC)
{
	var player : W3PlayerWitcher;
	var shockWave : W3DamageAction;
	var sp : SAbilityAttributeValue;
	var dmgVal : float;

	player = GetWitcherPlayer();
	if(!player || !victimNPC || !victimNPC.IsAlive() || !action || !owner || !owner.IsPlayer())
		return;

	if(!owner.CanUseSkill(S_Magic_s06) || owner.CanUseSkill(S_Magic_s33) || player.IsMutationActive(EPMT_Mutation6))
		return;

	if(!IsRequiredAttitudeBetween(victimNPC, caster, true))
		return;

	sp = action.GetPowerStatValue();
	dmgVal = player.GetSkillLevel(S_Magic_s06) * victimNPC.GetHealth() * (0.01 + 0.03 * LogF(sp.valueMultiplicative));
	if(dmgVal <= 0)
		return;

	shockWave = new W3DamageAction in theGame.damageMgr;
	shockWave.Initialize(action.attacker, victimNPC, this, caster.GetName() + "_sign", EHRT_None, CPS_SpellPower, false, false, true, false);
	shockWave.SetSignSkill(signSkill);
	shockWave.SetHitAnimationPlayType(EAHA_ForceNo);
	shockWave.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, dmgVal);
	theGame.damageMgr.ProcessAction(shockWave);
	delete shockWave;
}

@wrapMethod(W3AardProjectile)
function ProcessCollision(collider : CGameplayEntity, pos, normal : Vector)
{
	var newHit : bool;

	newHit = hitEntities.FindFirst(collider) == -1;
	wrappedMethod(collider, pos, normal);

	if(newHit)
		STR_ApplyShockWave((CNewNPC)collider);
}
