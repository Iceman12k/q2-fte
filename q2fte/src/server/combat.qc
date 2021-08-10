void PL_TakeDamage(vector pos, entity targ, entity inflictor, entity attacker, int damage, int knockback, int dflags, int mod)
vector PL_GetBarrelPos(entity ent);

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

void CB_Hitscan_Attack(trace_t *trace, entity shooter, vector aim, int damage, int knockback, int dflags, int part)
{
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
}


























