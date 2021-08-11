void PL_TakeDamage(vector pos, entity targ, entity inflictor, entity attacker, int damage, int knockback, int dflags, int mod)
vector PL_GetBarrelPos(entity ent);

float CB_CanDamage(vector pos, entity targ)
{
	trace_t trace;
	vector org;
	
	org = targ.origin;
	traceline_full(&trace, pos, org, MOVE_NOMONSTERS, targ);
	if (trace_fraction >= 1)
		return TRUE;
	
	org = targ.origin + '15 15 0';
	traceline_full(&trace, pos, org, MOVE_NOMONSTERS, targ);
	if (trace_fraction >= 1)
		return TRUE;
	
	org = targ.origin + '15 -15 0';
	traceline_full(&trace, pos, org, MOVE_NOMONSTERS, targ);
	if (trace_fraction >= 1)
		return TRUE;
	
	org = targ.origin + '-15 15 0';
	traceline_full(&trace, pos, org, MOVE_NOMONSTERS, targ);
	if (trace_fraction >= 1)
		return TRUE;
	
	org = targ.origin + '-15 -15 0';
	traceline_full(&trace, pos, org, MOVE_NOMONSTERS, targ);
	if (trace_fraction >= 1)
		return TRUE;
	
	return FALSE;
}

void CB_Hitscan_DealDamage(trace_t *trace, entity targ, entity inflictor, entity attacker, int damage, int knockback, int dflags, int part)
{
	if (targ.takedamage == DMG_TAKE_PLAYER)
	{
		PL_TakeDamage(trace->endpos, targ, inflictor, attacker, damage, knockback, dflags, 0);
		pointparticles(EFFECT_IMPACT_BLOOD, trace->endpos, trace->plane_normal);
	}
	else
	{
		if (part)
		{
			pointparticles(part, trace->endpos, trace->plane_normal);
		}
	}
}

void CB_RadiusDamage(entity inflictor, entity attacker, vector org, float radius, int damage, int knockback, int dflags, entity ignore)
{
	
	entity lst = findradius(org, radius + 96)
	for(lst; lst; lst = lst.chain)
	{
		if (lst.takedamage == DMG_TAKE_NOT)
			continue;
		if (lst == ignore)
			continue;
		
		vector centorg = (lst.absmin + lst.absmax) * 0.5;
		float points = (radius - vlen(centorg - org)) / radius;
		if (points > 0)
		{
			if (lst == attacker)
				points *= 0.5;
			
			if (!CB_CanDamage(inflictor.origin, lst))
				continue;
			
			if (lst.takedamage == DMG_TAKE_PLAYER)
				PL_TakeDamage(org, lst, inflictor, attacker, damage * points, knockback * points, dflags, 0);
		}
	}
}

void CB_Hitscan_Attack(trace_t *trace, entity shooter, vector aim, int damage, int knockback, int dflags, int part)
{
	antilag_hitscan(shooter);
	
	vector pos = PL_GetBarrelPos(shooter);
	if (dflags & DFL_PENETRATE)
	{
		trace->ent = self;
		while (trace->ent.solid != SOLID_BSP)
		{
			traceline_full(trace, pos, pos + aim, MOVE_NORMAL, trace->ent);
			pos = trace->endpos;
			CB_Hitscan_DealDamage(trace, trace->ent, shooter, shooter, damage, knockback, dflags, part);
		}
	}
	else
	{
		traceline_full(trace, pos, pos + aim, MOVE_NORMAL, self);
		CB_Hitscan_DealDamage(trace, trace->ent, shooter, shooter, damage, knockback, dflags, part);
	}
	
	antilag_unmove_all();
}


























