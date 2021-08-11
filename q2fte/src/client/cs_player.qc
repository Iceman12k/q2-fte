
float autocvar_cl_nolerp;
entity viewmodel_primary;

struct CLIENT_STATE {
	float 	updatetime;
	int 	status;
	int 	saved_frame;
	int 	current_frame;
	
	
	
	float 	impulse;
	
	float 	client_time;
	float 	attack_finished;
	float	land_time;
	
	float 	input_lastbuttons;
	
	float 	movetype;
	float 	waterlevel;
	float	watertype;
	
	float 	sview_height;
	
	float	wep_framenum;
	int		wep_animation:8;
	int		wep_firemode:8;
	
	int		weapon_inventory[MAX_WEAPONS];
	int		ammo_inventory[MAX_AMMO];
	
	vector 	origin;
	vector 	velocity;
	vector	v_angle;
	
	float 	flags;
	int		moveflags;
	
	float 	weapon;
	float	weapon_wanted;
	
	int		deadflags:8;
	int		health:10;
	
	float	think_time;
	vector	viewkick_origin;
	vector	viewkick_angles;
	vector	viewkick_origin_l;
	vector	viewkick_angles_l;
	vector	viewkick_origin_g;
	vector	viewkick_angles_g;
};
.CLIENT_STATE *hold_state;
.CLIENT_STATE *server_state;
.CLIENT_STATE *predicted_state;
.vector		origin_errorcorrect;
.entity		weapon_held;

const int PL_PSTATE_FRESH = 1;
const int PL_PSTATE_SIMULATED = 2;

float autocvar_cl_rollangle;

void PL_CustomPhysics()
{
	
}

void PL_Pred_UpdateState(CLIENT_STATE *state)
{
	state->client_time = self.client_time;
	state->attack_finished = self.attack_finished;
	state->land_time = self.land_time;
	
	state->impulse = self.impulse;
	state->input_lastbuttons = self.input_lastbuttons;
	
	state->movetype = self.movetype;
	state->waterlevel = self.waterlevel;
	
	state->sview_height = self.sview_height;
	
	state->weapon = self.weapon;
	state->weapon_wanted = self.weapon_wanted;
	state->wep_framenum = self.wep_framenum;
	state->wep_animation = self.wep_animation;
	state->wep_firemode = self.wep_firemode;
	
	int i;
	for(i = 0; i < MAX_AMMO; i++)
		state->ammo_inventory[i] = self.ammo_inventory[i];
	
	state->origin = self.origin;
	state->velocity = self.velocity;
	state->v_angle = self.v_angle;
	
	state->flags = self.flags;
	state->moveflags = self.moveflags;
	
	state->deadflags = self.deadflags;
	state->health = self.health;
	
	state->think_time = self.think_time;
	state->viewkick_origin = self.viewkick_origin;
	state->viewkick_origin_l = self.viewkick_origin_l;
	state->viewkick_origin_g = self.viewkick_origin_g;
	
	state->viewkick_angles = self.viewkick_angles;
	state->viewkick_angles_l = self.viewkick_angles_l;
	state->viewkick_angles_g = self.viewkick_angles_g;
}

void PL_Pred_Restore(CLIENT_STATE *state)
{
	state.current_frame = state->saved_frame + 1;
	
	self.client_time = state->client_time;
	self.attack_finished = state->attack_finished;
	self.land_time = state->land_time;
	
	self.impulse = state->impulse;
	self.input_lastbuttons = state->input_lastbuttons;
	
	self.movetype = state->movetype;
	self.waterlevel = state->waterlevel;
	
	self.sview_height = state->sview_height;
	
	self.weapon = state->weapon;
	self.weapon_wanted = state->weapon_wanted;
	self.wep_framenum = state->wep_framenum;
	self.wep_animation = state->wep_animation;
	self.wep_firemode = state->wep_firemode;
	
	int i;
	for(i = 0; i < MAX_AMMO; i++)
		self.ammo_inventory[i] = state->ammo_inventory[i];
	
	self.origin = state->origin;
	self.velocity = state->velocity;
	self.v_angle = state->v_angle;
	
	self.flags = state->flags;
	self.moveflags = state->moveflags;
	
	self.deadflags = state->deadflags;
	self.health = state->health;
	
	self.think_time = state->think_time;
	self.viewkick_origin = state->viewkick_origin;
	self.viewkick_origin_l = state->viewkick_origin_l;
	self.viewkick_origin_g = state->viewkick_origin_g;
	
	self.viewkick_angles = state->viewkick_angles;
	self.viewkick_angles_l = state->viewkick_angles_l;
	self.viewkick_angles_g = state->viewkick_angles_g;
	
	if (state.current_frame < clientcommandframe-128)
		state.current_frame = clientcommandframe-128;	//avoid an infinite loop
}

void PL_Pred_Simulate(float frame_goto)
{
	for (float i = self.predicted_state.current_frame; i <= frame_goto; i++)
	{
		float isFrame = getinputstate(self.predicted_state.current_frame);

		if (isFrame == 0)
			continue;
		if (input_timelength == 0)
			continue;
		
		if (i > prediction_effectframe && i != frame_goto)
		{
			prediction_playeffects = TRUE;
			prediction_effectframe = i;
		}
		else
		{
			prediction_playeffects = FALSE;
		}
		
		PL_RunPhysics();
		
		self.predicted_state.current_frame++;
	}
	
	prediction_playeffects = FALSE;
}


void PL_Pred_Updated()
{
	self.predicted_state.status = PL_PSTATE_SIMULATED;
	
	PL_Pred_Restore(self.predicted_state);
	PL_Pred_Simulate(clientcommandframe);
	local vector rough_origin = self.origin + [0, 0, self.sview_height];
	
	
	PL_Pred_Restore(self.server_state);
	self.predicted_state.current_frame = servercommandframe + 1;
	
	PL_Pred_UpdateState(self.predicted_state);
	self.predicted_state.saved_frame = servercommandframe;
	PL_Pred_Simulate(clientcommandframe);
	
	
	local vector new_origin = self.origin + [0, 0, self.sview_height];
	self.origin_errorcorrect = (rough_origin - (new_origin - self.origin_errorcorrect));
}

void PL_Pred_ErrorCorrection()
{
	local float d = vlen(self.origin_errorcorrect);
	//tracebox(self.origin, self.mins + '0 0 8', self.maxs - '0 0 16', self.origin + self.origin_errorcorrect, MOVE_WORLDONLY, self);
	//d *= trace_fraction;
	
	local float spd = clframetime * 0.2;
	if (d < 0.01)
		d = 0;
	else if (d < 4)
		d -= 120*spd;
	else if (d < 8)
		d -= 280*spd;
	else if (d < 18)
		d -= 400*spd;
	else if (d < 28)
		d -= 800*spd;
	else if (d < 42)
		d -= 1200*spd;
	else if (d < 64)
		d -= 2000*spd;
	else if (d < 112)
		d -= 2000*spd;
	else if (d < 128)
		d = 110;
	else
		d = 0;
	
	d = max(0, d);
	self.origin_errorcorrect = d * normalize(self.origin_errorcorrect);
}

void PL_Pred_Frame()
{
	PL_Pred_Restore(self.predicted_state);
	PL_Pred_Simulate(clientcommandframe);
	
	PL_Pred_ErrorCorrection();
}


float autocvar_cl_zoomscale;
float PL_Lerp_State(CLIENT_STATE *last, CLIENT_STATE *goal)
{
	PL_Pred_Restore(self.server_state);
	local float frac = min((cltime - self.lerp_time) / self.lerp_stepsize, 1.05);
	
	if (self.lerp_time == 0)
		return;
	
	self.client_time = lerp(last->client_time, goal->client_time, frac);
	
	int i;
	for(i = 0; i < 3; i++)
	{
		if (fabs(last->origin[i] - goal->origin[i]) < 128)
			self.origin[i] = lerp(last->origin[i], goal->origin[i], frac);
		
		float ang_diff = angle_difference(goal->v_angle[i], last->v_angle[i]);
		if (fabs(ang_diff) < 90)
		{
			self.v_angle[i] = last->v_angle[i] + ang_diff * frac;
		}
	}
	
	// we can't lerp if crouching changed, because crouching causes a large snap
	if ((last->moveflags & MF_CROUCHED) == (goal->moveflags & MF_CROUCHED))
		self.sview_height = lerp(last->sview_height, goal->sview_height, frac);
}

vector last_alive_angle;
float PL_LocalThink()
{
	self.renderflags = RF_EXTERNALMODEL | RF_NOSHADOW;
	
	if !(is_spectator)
	{
		if (self.predicted_state.status == PL_PSTATE_FRESH)
			PL_Pred_Updated();
		
		PL_Pred_Frame();
		
		if (self.deadflags == DEAD_NOT)
			last_alive_angle = self.v_angle;
	}
	else
	{
		input_buttons = 0;
		if (self.moveflags & MF_CROUCHED)
			input_buttons |= 4;
		
		input_angles = (self.server_state)->v_angle;
		input_movevalues = 0;
		
		if (self.server_state->status == PL_PSTATE_FRESH)
		{
			self.server_state->status = PL_PSTATE_SIMULATED;
			
			//self.v_angle_lerp_last = self.v_angle_lerp_goal;
			//self.v_angle_lerp_goal = self.server_state->v_angle;
			self.lerp_stepsize = min((self.server_state)->updatetime - (self.hold_state)->updatetime, 0.3);
			//self.lerp_stepsize += bound(0.002, self.lerp_stepsize * 0.1, 0.006);
			
			self.lerp_time = cltime;
			
			PL_Pred_Restore(self.hold_state);
			PL_Pred_UpdateState(self.predicted_state);
			(self.predicted_state)->updatetime = (self.hold_state)->updatetime;
			
			//PL_Pred_Restore(self.server_state);
			(self.hold_state)->updatetime = (self.server_state)->updatetime;
		}
		
		PL_Lerp_State(self.predicted_state, self.server_state);
		PL_Pred_UpdateState(self.hold_state);
		
		
		/*
		PL_Pred_Restore(self.server_state);
		PL_Pred_UpdateState(self.predicted_state);
		(self.predicted_state)->updatetime = (self.server_state)->updatetime;
		
		local float tm = min(time - self.server_state->updatetime, 0.6);// + XERP_TIME;
		PL_Pred_BasicXerp(tm);
		
		PL_Pred_ErrorCorrection();
		self.origin += self.origin_errorcorrect;
		//print(ftos(vlen(self.origin_errorcorrect)), "\n");
		//*/
		
		
		//local float frac = min((cltime - self.v_angle_lerp_time) / self.v_angle_lerp_stepsize, 1);
		//self.v_angle[0] = self.v_angle_lerp_last[0] + angle_difference(self.v_angle_lerp_goal[0], self.v_angle_lerp_last[0]) * frac;
		//self.v_angle[1] = self.v_angle_lerp_last[1] + angle_difference(self.v_angle_lerp_goal[1], self.v_angle_lerp_last[1]) * frac;
		
		if (self.moveflags & MF_CROUCHED) {
			self.view_ofs[2] = -2;
		} else {
			self.view_ofs[2] = 22;
		}
		
		last_alive_angle = self.v_angle;
		view_angles = self.v_angle;
	}
	
	vector view_origin = self.origin;
	vector v_angles = view_angles;
	if (self.deadflags == DEAD_DEAD)
	{
		v_angles = last_alive_angle;
		view_angles = last_alive_angle;
		
		v_angles[2] = 30;
	}
	
	makevectors(view_angles);
	
	int i;
	float frac;
	if (cltime >= self.vdmg_lerptime)
	{
		self.vdmg_lerptime = cltime + 0.1;
		
		float amt = (self.vdmg_time - cltime) / 0.5;
		amt = bound(0, amt, 1);
		self.vdmg_angles_last = self.vdmg_angles_current;
		self.vdmg_angles_current = self.vdmg_angles * (amt);
		
		self.vdmg_alpha_last = self.vdmg_alpha_current;
		self.vdmg_alpha_current = self.vdmg_alpha * (amt);
		
		self.vdmg_blend_last = self.vdmg_blend_current;
		self.vdmg_blend_current = self.vdmg_blend * (amt);
		
		
		
		
		float amt = (self.vfall_time - cltime) / 0.3;
		amt = bound(0, amt, 1);
		self.vfall_last = self.vfall_current;
		self.vfall_current = self.vfall_angles * (amt);
	}
	
	frac = (self.vdmg_lerptime - cltime) / 0.1;
	for(i = 0; i < 3; i++)
	{
		v_angles[i] += lerp(self.vdmg_angles_current[i], self.vdmg_angles_last[i], frac);
		//self.vdmg_blend_draw = lerp(self.vdmg_blend_current[i], self.vdmg_blend_last[i], frac);
	}
	self.vdmg_alpha_draw = lerp(self.vdmg_alpha_current, self.vdmg_alpha_last, frac);
	v_angles[0] += lerp(self.vfall_current[0], self.vfall_last[0], frac);
	view_origin[2] -= lerp(self.vfall_current[0], self.vfall_last[0], frac) * 0.4;
	
	
	
	frac = (self.think_time - self.client_time) / 0.1;
	for(i = 0; i < 3; i++)
	{
		v_angles[i] += lerp(self.viewkick_angles_g[i], self.viewkick_angles_l[i], frac);
	}
	
	view_origin += lerp(self.viewkick_origin_g[0], self.viewkick_origin_l[0], frac) * v_right;
	view_origin += lerp(self.viewkick_origin_g[1], self.viewkick_origin_l[1], frac) * v_forward;
	view_origin[2] += lerp(self.viewkick_origin_g[2], self.viewkick_origin_l[2], frac);
	
	view_origin += self.origin_errorcorrect;
	view_origin += self.view_ofs;
	view_origin[2] += self.sview_height;
	
	traceline(self.origin, view_origin, MOVE_WORLDONLY, self);
	view_origin = trace_endpos;
	
	setproperty(VF_ORIGIN, view_origin);
	
	
	setproperty(VF_ANGLES, v_angles);
	//
}



float PL_Predraw()
{
	self.renderflags = 0;
	
	if (player_localentity == self)
	{
		PL_LocalThink();
		
		self.angles = [view_angles[0] * -0.25, view_angles[1], 0];
	}
	else
	{
		input_buttons = 0;
		if (self.moveflags & MF_CROUCHED)
			input_buttons |= 4;
		
		input_angles = (self.server_state)->v_angle;
		input_movevalues = 0;
		
		PL_SetSize(self);
		
		if (self.server_state->status == PL_PSTATE_FRESH)
		{
			self.server_state->status = PL_PSTATE_SIMULATED;
		}
		
		self.angles = [self.v_angle[0] * -0.25, self.v_angle[1], 0];
	}
	
	
	
	self.lerpfrac += clframetime * 10;
	while (self.lerpfrac >= 1)
	{
		self.frame = self.frame2;
		self.frame2++;
		
		self.lerpfrac -= 1;
	}
	
	vector o_org = self.origin;
	local float animstate = 0;
	if (self.deadflags == DEAD_DEAD)
	{
		if !(self.frame2 >= 173 && self.frame2 <= 178)
		{
			self.frame2 = 173;
		}
		
		animstate = 5;
	}
	else
	{
		if (self.flags & FL_ONGROUND)
		{
			if (self.moveflags & MF_CROUCHED)
			{
				if (vlen([self.velocity_x, self.velocity_y, 0]) > 10)
					animstate = 3;
				else
					animstate = 2;
			}
			else
			{
				if (vlen([self.velocity_x, self.velocity_y, 0]) > 60)
					animstate = 1;
			}
		}
		else
		{
			animstate = 4;
			
			if (self.frame2 != 67)
			{
				self.frame2 == 66;
			}
		}
	}
	
	
	if (animstate == 0)
	{
		self.frame2 = max(self.frame2, 0);
		
		if (self.frame2 > 39)
			self.frame2 = 0;
	}
	else if (animstate == 1)
	{
		self.frame2 = max(self.frame2, 40);
		
		if (self.frame2 > 45)
			self.frame2 = 40;
	}
	else if (animstate == 2)
	{
		self.frame2 = max(self.frame2, 135);
		
		if (self.frame2 > 153)
			self.frame2 = 135;
	}
	else if (animstate == 3)
	{
		self.frame2 = max(self.frame2, 155);
		
		if (self.frame2 > 159)
			self.frame2 = 155;
	}
	else if (animstate == 4)
	{
		self.frame2 = max(self.frame2, 66);
		
		if (self.frame2 > 67)
			self.frame2 = 67;
	}
	else if (animstate == 5)
	{
		self.frame2 = max(self.frame2, 173);
		
		if (self.frame2 > 177)
			self.frame2 = 177;
	}
	
	addentity(self);
	self.origin = o_org;
	
	if (player_localentity != self) // for collision
	{
		//PL_Pred_BasicXerp(min(getstatf(STAT_PING) / 1000, 0.04));
		PL_Pred_Restore(self.server_state);
		PL_SetSize(self);
		
		if ((self.origin[2] + self.maxs[2]) > (player_localentity.origin[2] + player_localentity.mins[2]))
		{
			self.mins[0] += 2;
			self.mins[1] += 2;
			
			self.maxs[0] -= 2;
			self.maxs[1] -= 2;
		}
		setsize(self, self.mins, self.maxs);
	}
	
	
	if (self == player_localentity && self.deadflags == DEAD_NOT)
	{
		if (self.weapon_current != __NULL__)
		{
			viewmodel_primary.renderflags = RF_VIEWMODEL;
			
			if (viewmodel_primary.weapon != self.weapon)
			{
				viewmodel_primary.weapon = self.weapon;
				viewmodel_primary.frame = (self.wep_frame)->frame;
				viewmodel_primary.frame2 = (self.wep_frame)->frame;
			}
			
			if (viewmodel_primary.frame2 != (self.wep_frame)->frame)
			{
				viewmodel_primary.frame = viewmodel_primary.frame2;
				viewmodel_primary.lerpfrac = 0;
			}
			
			viewmodel_primary.lerpfrac = self.wep_framenum - floor(self.wep_framenum);//frametime * (self.wep_frame)->rate;
			if ((self.wep_frame)->rate < 3 || autocvar_cl_nolerp)
				viewmodel_primary.lerpfrac = 1;
			
			viewmodel_primary.frame2 = (self.wep_frame)->frame;
			
			setmodel(viewmodel_primary, (self.weapon_current)->v_model);
			addentity(viewmodel_primary);
		}
	}
	
	if (WeaponList[self.weapon] != __NULL__)
	{
		string hmod = strcat(self.skin_folder, (WeaponList[self.weapon])->h_model);
		if (self.weapon_held.model != hmod)
			setmodel(self.weapon_held, hmod);
		
		self.weapon_held.origin = self.origin;
		self.weapon_held.angles = self.angles;
		
		self.weapon_held.frame = self.frame;
		self.weapon_held.frame2 = self.frame2;
		self.weapon_held.lerpfrac = self.lerpfrac;
		
		self.weapon_held.renderflags = self.renderflags;
		addentity(self.weapon_held);
	}
	
	
	return PREDRAW_NEXT;
}






void EntUpdate_Player(float isnew)
{
	local int sendflags = ReadLong();
	local int localflags = ReadByte();
	
	if (isnew)
	{
		self.server_state = memalloc(sizeof(CLIENT_STATE));
		self.predicted_state = memalloc(sizeof(CLIENT_STATE));
		self.hold_state = memalloc(sizeof(CLIENT_STATE));
	}
	
		
	if ((localflags & NLFL_LOCAL))
	{
		player_localentity = self;
		
		if (!(localflags & NLFL_SPECTATE))
			is_spectator = FALSE;
		
		if (self.classname != "player")
		{
			isnew = TRUE;
		}
	}
	
	if (isnew)
	{
		self.weapon_current = WeaponList[0];
		
		self.predraw = PL_Predraw;
		self.drawmask = MASK_GAME;
		
		self.classname = "player";
		self.flags |= FL_CLIENT;
		
		self.customphysics = PL_CustomPhysics;
		self.friction = 1;
		self.gravity = 1;
		self.mass = 200;
		setsize(self, '-16 -16 -24', '16 16 32');
		self.alpha = 1;
		
		if !(self.weapon_held)
			self.weapon_held = spawn();
	}
	
	self.server_state->updatetime = time;
	self.predicted_state->status = PL_PSTATE_FRESH;
	self.server_state->status = PL_PSTATE_FRESH;
	
	if (sendflags & 2)
	{
		if (localflags & NLFL_LOCAL)
		{
			self.origin = [ReadFloat(), ReadFloat(), ReadFloat()];
			self.velocity = [ReadFloat(), ReadFloat(), ReadFloat()];
			
			if (localflags & NLFL_SPECTATE)
			{
				self.v_angle = [ReadShort() / 100, ReadShort() / 100, 0];
			}
			else
			{
				self.v_angle = [ReadAngle(), ReadAngle(), 0];
			}
		}
		else
		{
			self.origin = [ReadFloat(), ReadFloat(), ReadFloat()];
			self.velocity = [ReadShort(), ReadShort(), ReadShort()];
			self.v_angle = [ReadChar(), ReadAngle(), 0];
		}
		
		(self.server_state)->origin = self.origin;
		(self.server_state)->velocity = self.velocity;
		(self.server_state)->v_angle = self.v_angle;
	}
	
	if (sendflags & 4)
	{
		self.team = ReadByte();
		self.solid = ReadByte();
		
		int data = ReadByte();
		self.dimension_hit = (data & 15);
		self.dimension_solid = ((data >> 4) & 15);
	}
	
	if (localflags & NLFL_LOCAL)
	{
		if (sendflags & 1)
		{
			self.client_time = ReadFloat();
			
			(self.server_state)->client_time = self.client_time;
		}
		
		if (sendflags & 8)
		{
			self.land_time = ReadFloat();
			(self.server_state)->land_time = self.land_time;
			
			
			self.movetype = ReadByte();
			self.moveflags = ReadShort();
			self.flags = ReadLong();
			
			(self.server_state)->movetype = self.movetype;
			(self.server_state)->moveflags = self.moveflags;
			(self.server_state)->flags = self.flags;
		}
		
		if (sendflags & 16)
		{
			self.waterlevel = ReadByte();
			self.watertype = ReadByte();
			
			(self.server_state)->waterlevel = self.waterlevel;
			(self.server_state)->watertype = self.watertype;
		}
		
		if (sendflags & 32)
		{
			self.sview_height = ReadFloat();
			
			(self.server_state)->sview_height = self.sview_height;
		}
		
		if (sendflags & 64)
		{
			self.weapon = ReadByte();
			self.weapon_wanted = ReadByte();
			(self.server_state)->weapon = self.weapon;
			(self.server_state)->weapon_wanted = self.weapon_wanted;
			
			self.attack_finished = ReadFloat();
			self.wep_framenum = ReadFloat();
			self.wep_animation = ReadByte();
			self.wep_firemode = ReadByte();
			(self.server_state)->attack_finished = self.attack_finished;
			(self.server_state)->wep_framenum = self.wep_framenum;
			(self.server_state)->wep_animation = self.wep_animation;
			(self.server_state)->wep_firemode = self.wep_firemode;
		}
		
		if (sendflags & 128)
		{
			int i;
			for(i = 0; i < MAX_AMMO; i++)
			{
				self.ammo_inventory[i] = ReadShort();
				(self.server_state)->ammo_inventory[i] = self.ammo_inventory[i];
			}
		}
		
		if (sendflags & 256)
		{
			int i;
			for(i = 0; i < MAX_WEAPONS; i++)
			{
				int data = ReadByte();
				if (i <= MAX_WEAPONS - 2)
				{
					self.weapon_inventory[i] = data & 15;
					self.weapon_inventory[i + 1] = (data >> 4) & 15;
					
					(self.server_state)->weapon_inventory[i] = self.weapon_inventory[i];
					(self.server_state)->weapon_inventory[i + 1] = self.weapon_inventory[i + 1];
					
					i++;
				}
				else
				{
					self.weapon_inventory[i] = data;
					(self.server_state)->weapon_inventory[i] = self.weapon_inventory[i];
				}
			}
		}
		
		if (sendflags & 512)
		{
			self.deadflags = ReadByte();
			self.health = ReadShort();
			
			(self.server_state)->deadflags = self.deadflags;
			(self.server_state)->health = self.health;
		}
		
		if (sendflags & 4096)
		{
			self.think_time = ReadFloat();
			(self.server_state)->think_time = self.think_time;
			
			self.viewkick_origin = [ReadShort(), ReadShort(), ReadShort()] 		/ 100;
			self.viewkick_origin_l = [ReadShort(), ReadShort(), ReadShort()] 	/ 100;
			self.viewkick_origin_g = [ReadShort(), ReadShort(), ReadShort()] 	/ 100;
			(self.server_state)->viewkick_origin = self.viewkick_origin;
			(self.server_state)->viewkick_origin_l = self.viewkick_origin_l;
			(self.server_state)->viewkick_origin_g = self.viewkick_origin_g;
			
			self.viewkick_angles = [ReadShort(), ReadShort(), ReadShort()] 		/ 100;
			self.viewkick_angles_l = [ReadShort(), ReadShort(), ReadShort()] 	/ 100;
			self.viewkick_angles_g = [ReadShort(), ReadShort(), ReadShort()] 	/ 100;
			(self.server_state)->viewkick_angles = self.viewkick_angles;
			(self.server_state)->viewkick_angles_l = self.viewkick_angles_l;
			(self.server_state)->viewkick_angles_g = self.viewkick_angles_g;
		}
	}
	else
	{
		if (sendflags & 8)
		{
			self.movetype = ReadByte();
			self.moveflags = ReadByte();
			self.flags = ReadLong();
			
			(self.server_state)->movetype = self.movetype;
			(self.server_state)->moveflags = self.moveflags;
			(self.server_state)->flags = self.flags;
		}
		
		if (sendflags & 64)
		{
			self.weapon = ReadByte();
			(self.server_state)->weapon = self.weapon;
		}
		
		if (sendflags & 512)
		{
			self.deadflags = ReadByte();
			(self.server_state)->deadflags = self.deadflags;
		}
	}
	
	
	
	
	
	if (sendflags & 8192)
	{
		string o_tex = self.skin_texture;
		
		self.skin_folder = ReadString();
		self.skin_texture = ReadString();
		PlayerInfo_Update(self.entnum, self.skin_folder, self.skin_texture);
		
		playerinfo_t *pinfo = PlayerInfo[255];
		if (self.entnum < 255)
		{
			pinfo = PlayerInfo[self.entnum];
			setcustomskin(self, strcat(pinfo->skin, ".skin"), strcat("replace \"\" \"", pinfo->skin, "\""));
		}
		
		setmodel(self, pinfo->model);
	}
}








