
void Generic_EffectsAndTrails()
{
	if (time >= self.part_time)
	{
		self.part_time = time + 0.02;
		
		if (self.old_origin)
		{
			if (self.modelflags & MF_ROCKET)
				trailparticles(EFFECT_TRAIL_ROCKET, self, self.old_origin, self.origin);
			
			if (self.modelflags & MF_GRENADE)
				trailparticles(EFFECT_TRAIL_GRENADE, self, self.old_origin, self.origin);
			
			if (self.modelflags & MF_TRACER)
				trailparticles(EFFECT_TRAIL_BLASTER, self, self.old_origin, self.origin);
		}
		
		self.old_origin = self.origin;
	}
	
	if (self.modelflags & MF_ROCKET)
	{
		dynamiclight_add(self.origin, 128, '1 0.65 0.15', 0, 0, PFLAGS_CORONA);
	}
	else if (self.modelflags & MF_TRACER2)
	{
		local float lght = dynamiclight_add(self.origin, 112, '1 1 0', 0, 0, PFLAGS_NOSHADOW);
		dynamiclight_set(lght, LFIELD_FLAGS, LFLAG_LIGHTMAP | LFLAG_NOSHADOWS);
	}
}


void Proj_Cleanup()
{
	sound(self, CHAN_WEAPON, "weapons/noammo", 0.1, ATTN_IDLE);
}


void Proj_Predraw()
{
	self.origin = (self.server_state)->origin + self.velocity * ((time - (self.server_state)->updatetime));
	
	Generic_EffectsAndTrails();
	addentity(self);
}


void EntUpdate_Proj(float isnew)
{
	int sendflags = ReadByte();
	
	if (isnew)
	{
		self.drawmask = MASK_GAME;
		self.predraw = Proj_Predraw;
		self.server_state = memalloc(sizeof(CLIENT_STATE));
		self.renderflags = RF_NOSHADOW;
		self.cleanup_func = Proj_Cleanup;
	}
	
	if (sendflags & 1)
	{
		(self.server_state)->updatetime = ReadFloat();
		self.origin = [ReadCoord(), ReadCoord(), ReadCoord()];
		self.velocity = [ReadFloat(), ReadFloat(), ReadFloat()];
		self.angles = [ReadAngle(), ReadAngle(), ReadAngle()];
		
		(self.server_state)->origin = self.origin;
	}
	
	if (sendflags & 64)
	{
		self.noise = ReadString();
		sound(self, CHAN_WEAPON, self.noise, 1, ATTN_IDLE, 0, SOUNDFLAG_FOLLOW);
	}
	
	if (sendflags & 128)
	{
		self.modelindex = ReadLong();
		self.modelflags = ReadLong();
	}
}

void EntGeneric_UpdateState(CLIENT_STATE *state)
{
	state->origin = self.origin;
	state->angles = self.angles;
}

void EntGeneric_Restore(CLIENT_STATE *state)
{
	self.origin = state->origin;
	self.angles = state->angles;
}

float EntGeneric_Lerp_State(CLIENT_STATE *last, CLIENT_STATE *goal)
{
	PL_Pred_Restore(self.server_state);
	local float frac = min((cltime - self.lerp_time) / self.lerp_stepsize, 1.2);
	
	int i;
	for(i = 0; i < 3; i++)
	{
		if (fabs(last->origin[i] - goal->origin[i]) < 128)
			self.origin[i] = lerp(last->origin[i], goal->origin[i], frac);
		
		float ang_diff = angle_difference(goal->angles[i], last->angles[i]);
		self.angles[i] = last->angles[i] + ang_diff * frac;
	}
}

float EntGeneric_Predraw()
{
	if (self.server_state->status == PL_PSTATE_FRESH)
	{
		self.server_state->status = PL_PSTATE_SIMULATED;
		//self.lerp_stepsize = 1/self.updaterate;
		self.lerp_stepsize = min((self.server_state)->updatetime - (self.hold_state)->updatetime, 0.3);
		
		self.framenum++;
		self.lerp_time = cltime;
		
		EntGeneric_Restore(self.hold_state);
		EntGeneric_UpdateState(self.predicted_state);
		(self.predicted_state)->updatetime = (self.hold_state)->updatetime;
		
		(self.hold_state)->updatetime = (self.server_state)->updatetime;
	}

	EntGeneric_Lerp_State(self.predicted_state, self.server_state);
	EntGeneric_UpdateState(self.hold_state);
	
	if (self.framenum > 1)
	{
		Generic_EffectsAndTrails();
		addentity(self);
	}
	
	return PREDRAW_NEXT;
}

void EntUpdate_Generic(float isnew)
{
	int sendflags = ReadByte();
	
	if (isnew)
	{
		self.server_state = memalloc(sizeof(CLIENT_STATE));
		self.predicted_state = memalloc(sizeof(CLIENT_STATE));
		self.hold_state = memalloc(sizeof(CLIENT_STATE));
		self.drawmask = MASK_GAME;
		self.predraw = EntGeneric_Predraw;
	}
	
	self.server_state->updatetime = time;
	self.predicted_state->status = PL_PSTATE_FRESH;
	self.server_state->status = PL_PSTATE_FRESH;
	
	if (sendflags & 1)
	{
		self.origin = [ReadCoord(), ReadCoord(), ReadCoord()];
		self.angles = [ReadAngle(), ReadAngle(), ReadAngle()];
		
		self.server_state->origin = self.origin;
		self.server_state->angles = self.angles;
	}
	
	if (sendflags & 2)
	{
		self.effects = ReadShort();
	}
	
	if (sendflags & 64)
	{
		self.updaterate = ReadByte();
	}
	
	if (sendflags & 128)
	{
		self.modelindex = ReadLong();
		self.modelflags = ReadLong();
	}
	
	if (isnew)
	{
		EntGeneric_UpdateState(self.hold_state);
	}
}


void NetRead_Effect_Rail()
{
	float this_ent = ReadEntityNum();
	vector start = [ReadCoord(), ReadCoord(), ReadCoord()];
	vector end = [ReadCoord(), ReadCoord(), ReadCoord()];
	
	if (this_ent == player_localentity.entnum)
		return;
	
	trailparticles(EFFECT_TRAIL_RAILGUN, world, start, end);
}













