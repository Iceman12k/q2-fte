#ifdef SSQC
void PL_SendViewkick(entity ent, float start, float goal, float speed1, float speed2);
void PlayerRespawn();
#endif

void PL_SetSize(entity ent)
{
	if (ent.moveflags & MF_CROUCHED)
	{
		setsize(ent, PL_MINS_CROUCH, PL_MAXS_CROUCH);
	}
	else
	{
		setsize(ent, PL_MINS_STAND, PL_MAXS_STAND);
	}
}

void PL_CheckWeaponSwitch(entity ent)
{
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (ent.weapon_wanted == ent.weapon)
		return;
	
	Weapon_Putaway(ent);
}


void PL_CheckThink(entity ent)
{
	if (ent.client_time < ent.think_time)
		return;
	
	ent.think_time = ent.client_time + PLAYER_THINKFPS;
	
	int i;
	for(i = 0; i < 3; i++)
	{
		ent.viewkick_origin[i] = round(ent.viewkick_origin[i] * 100) / 100;
		ent.viewkick_angles[i] = round(ent.viewkick_angles[i] * 100) / 100;
	}
	
	ent.viewkick_origin_l = ent.viewkick_origin_g;
	ent.viewkick_angles_l = ent.viewkick_angles_g;
	ent.viewkick_origin_g = ent.viewkick_origin;
	ent.viewkick_angles_g = ent.viewkick_angles;
	
	ent.viewkick_origin = 0;
	ent.viewkick_angles = 0;
	
	#ifdef CSQC
	if (prediction_playeffects)
	{
		prediction_thinktrigger = TRUE;
	}
	#endif
}

void PL_CheckImpulse(entity ent)
{
	if (input_impulse != 0)
	{
		ent.impulse = input_impulse;
		input_impulse = 0;
	}
	
	if (ent.impulse == 0)
		return;
	
	int i;
	for(i = WEP_BLASTER; i <= WEP_BFG10K; i++)
	{
		if (ent.impulse != i)
			continue;
		
		
		weapon_t *wep = WeaponList[i];
		if (wep == __NULL__)
			continue;
		
		if (ent.weapon_inventory[i] <= 0)
		{
			#ifdef CSQC
			if (prediction_playeffects)
			{
				print("Out of item: ", wep->netname, "\n");
			}
			#endif
			continue;
		}
		else if (AmmoList[(wep->ammo_pool)] != __NULL__)
		{
			if (ent.ammo_inventory[wep->ammo_pool] < wep->ammo_min)
			{
				#ifdef CSQC
				if (prediction_playeffects)
				{
					print("Insufficient ", (AmmoList[(wep->ammo_pool)])->netname, " for ", wep->netname, "\n");
				}
				#endif
				continue;
			}
		}
		
		
		// this is the original behavior, but it feels bad
		//if (ent.weapon == i)
		//	continue;
	
		ent.weapon_wanted = i;
	}
	
	ent.impulse = 0;
}

void PL_FallingDamage(entity ent)
{
	float delta;
	
	if ((ent.oldvelocity[2] < 0) && (ent.velocity[2] > ent.oldvelocity[2]) && ((ent.flags & FL_ONGROUND)))
	{
		delta = ent.oldvelocity[2];
	}
	else
	{
		if !(ent.flags & FL_ONGROUND)
			return;
		
		delta = ent.velocity[2] - ent.oldvelocity[2];
	}
	
	delta = delta * delta * 0.0001;
	
	
	if (ent.waterlevel == 3)
		return;
	else if (ent.waterlevel == 2)
		delta *= 0.5;
	else if (ent.waterlevel == 1)
		delta *= 0.25;
	
	if (delta < 1)
		return;
	
	if (delta > 30 && ent.deadflags == DEAD_NOT)
	{
		
		float damage = (delta - 30) / 2;
        if (damage < 1)
           damage = 1;
		
		#ifdef SSQC
		if (damage < 30)
		{
			sound(ent, CHAN_PAIN, strcat(self.skin_folder, "FALL2"), 1, ATTN_VOICE);
		}
		else
		{
			sound(ent, CHAN_PAIN, strcat(self.skin_folder, "FALL1"), 1, ATTN_VOICE);
		}
		#endif
		
		
		float severity = bound(0.8, damage / 60, 1.25);
		#ifdef SSQC
		PL_SendViewkick(ent, -8 * severity, 13 * severity, 150 + (20 * severity), 190 + (20 * severity));
		#endif
	}
	else if (delta > 22)
	{
		#ifdef SSQC
		sound(ent, CHAN_AUTO, "player/land1", 1, ATTN_VOICE);
		
		PL_SendViewkick(ent, -3, 8, 150, 190);
		#endif
	}
}


void PL_CheckFootsteps(entity ent)
{
	// maybe predict this in future, for now SSQC only
	#ifdef SSQC
	if !(ent.flags & FL_ONGROUND)
		return;
	
	if (ent.deadflags & DEAD_DEAD)
		return;
	
	if (ent.client_time >= ent.footstep_time)
	{
		if (vlen(ent.oldvelocity) > 180)
		{
			ent.footstep_time = ent.client_time + 0.4;
			
			int i = ceil(random() * 4);
			sound(ent, CHAN_STEP, sprintf("player/step%i", i), 1, ATTN_STEP);
		}
	}
	#endif
}


void PL_RunPhysics()
{
	makevectors(input_angles);
	input_movevalues /= 100;
	
	#ifdef SSQC
	if (self.classname == "player")
	{
		if (self.deadflags == DEAD_NOT)
		{
			if (self.dimension_solid != 2)
			{
				if (time > self.spawn_time + 1)
				{
					int colliding = FALSE;
					
					entity lst;
					for(lst = findradius(self.origin, 256, chain); lst != world; lst = lst.chain)
					{
						if (lst.classname == "player" && lst != self)
						{
							if	((self.absmin[0] <= lst.absmax[0] &&	self.absmax[0] >= lst.absmin[0]) &&
								(self.absmin[1] <= lst.absmax[1]  &&	self.absmax[1] >= lst.absmin[1]) &&
								(self.absmin[2] <= lst.absmax[2]  &&	self.absmax[2] >= lst.absmin[2]))
							{
								colliding = TRUE;
							}
						}
					}
					
					if !(colliding)
					{
						self.dimension_hit = 3;
						self.dimension_solid = 2;
					}
				}
			}
		}
	}
	#endif
	
	
	local float tm = input_timelength;
	local float timestep = PLAYER_PHYSFPS; //we always want at least 125 fps
	while(tm > 0)
	{
		local float delta = min(tm, timestep);
		
		self.client_time += delta;
		
		if (self.deadflags == DEAD_DEAD)
		{
			input_movevalues = 0;
			
			self.client_time += input_timelength;
			self.oldvelocity = self.velocity;
			
			PM_Friction(self, input_timelength * 0.6);
			self.velocity[2] -= phys_gravity * input_timelength;
			PM_FlyMove(self, input_timelength);
			PM_CategorizePosition(self);
			PL_FallingDamage(self);
			
			if (self.flags & FL_ONGROUND)
			{
				if (vlen(self.velocity) < 30)
					self.velocity = 0;
				
				self.sview_height = max(-20, self.sview_height - (90 * input_timelength));
			}
			
			#ifdef SSQC
			self.angles = self.deadangle;
			self.fixangle = TRUE;
			//self.angles[0] = -self.deadangle[0];
			//self.v_angle = self.deadangle;
			#endif
			
			if (self.client_time >= self.attack_finished)
			{
				if (((input_buttons & BUTTON_FIRE) && !(self.input_lastbuttons & BUTTON_FIRE)) || self.client_time >= self.attack_finished)
				{
					#ifdef SSQC
					PlayerRespawn();
					#endif
				}
			}
			
			self.input_lastbuttons = input_buttons;
			
			return;
		}
		
		switch(self.movetype)
		{
			case MOVETYPE_WALK:
				self.oldvelocity = self.velocity;
				
				PM_CheckDuck(self);
				PM_CheckSpecialMovement(self);
				PM_CheckStairs(self, delta);
				PM_CheckJump(self);
				
				PM_Friction(self, delta);
				
				if (self.waterlevel >= 2)
				{
					PM_WaterMove(self, delta);
				}
				else
				{
					PM_AirMove(self, delta);
				}
				
				setorigin(self, self.origin);
				touchtriggers(self);
				
				PM_CategorizePosition(self);
				PL_FallingDamage(self);
				PL_CheckFootsteps(self);
				break;
			case MOVETYPE_NOCLIP:
				PM_SpecMove(self, input_timelength);
				break;
		}
		
		PL_CheckThink(self);
		PL_CheckImpulse(self);
		PL_CheckWeaponSwitch(self);
		PL_WeaponSimulate(self, delta);
		
		self.input_lastbuttons = input_buttons;
		tm -= timestep;
		setorigin(self, self.origin);
	}
}


