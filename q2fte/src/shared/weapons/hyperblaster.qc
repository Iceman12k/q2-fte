



void Hyperblaster_Frame(entity ent, float move_time)
{
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (ent.wep_animation == WEP_ANIM_IDLE1)
	{
		if (input_buttons & BUTTON_FIRE)
		{
			#ifdef SSQC
			sound(ent, CHAN_ITEM, "weapons/hyprbl1a", 0.7, ATTN_IDLE);
			sound(ent, CHAN_WEAPON, "weapons/hyprbu1a", 1, ATTN_IDLE);
			#endif
			#ifdef CSQC
			if (prediction_playeffects)
			{
				localsound("weapons/hyprbu1a", CHAN_WEAPON, 1);
			}
			#endif
			
			Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
			ent.attack_finished = ent.client_time + 1;
		}
	}
}

void Hyperblaster_Fire(entity ent)
{
	int shoot_bullet = FALSE;
	if (input_buttons & BUTTON_FIRE || ent.wep_framenum < 1)
		shoot_bullet = TRUE;
	
	if (ent.ammo_inventory[AMMO_CELLS] < (WeaponList[WEP_HYPERBLASTER])->ammo_min)
		shoot_bullet = FALSE;
	
	if (shoot_bullet)
	{
		ent.wep_firemode++;
		if (ent.wep_firemode > 2)
			ent.wep_firemode = 0;
		
		#ifdef SSQC
		sound(ent, CHAN_WEAPON, "weapons/hyprbf1a", 1, ATTN_NORM);
		
		
		makevectors(ent.v_angle);
		entity mis = Plasma_Fire();
		mis.owner = self;
		mis.velocity = v_forward * 1000;
		mis.angles = [-ent.v_angle_x, ent.v_angle_y, ent.v_angle_z];
		if (ent.wep_firemode == 1)
			mis.modelflags = MF_TRACER2;
		else
			mis.modelflags = 0;
		setorigin(mis, PL_GetBarrelPos(ent) + (v_forward * 8) + (v_up * ent.wep_firemode));
		
		#endif
		#ifdef CSQC
		if (prediction_playeffects)
		{
			localsound("weapons/hyprbf1a", CHAN_WEAPONSHOOT1 + ent.wep_firemode, 1);
		}
		#endif
		
		ent.ammo_inventory[AMMO_CELLS]--;
	}
}

void Hyperblaster_Idle(entity ent)
{
	if (ent.ammo_inventory[AMMO_CELLS] < (WeaponList[WEP_HYPERBLASTER])->ammo_min)
	{
		Weapon_Generic_OutofAmmo(ent);
	}
	else
	{
		Weapon_Generic_Idle(ent);
	}
}

void Hyperblaster_Spin(entity ent)
{
	if ((input_buttons & BUTTON_FIRE && ent.weapon == ent.weapon_wanted) && (ent.ammo_inventory[AMMO_CELLS] >= (WeaponList[WEP_HYPERBLASTER])->ammo_min))
	{
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
		
		#ifdef SSQC
		sound(ent, CHAN_ITEM, "weapons/hyprbl1a", 0.7, ATTN_IDLE);
		#endif
		
		ent.attack_finished = ent.client_time + 1;
	}
	else if (ent.wep_animation != WEP_ANIM_FIRE2)
	{
		#ifdef SSQC
		sound(ent, CHAN_ITEM, "weapons/hyprbd1a", 1, ATTN_IDLE);
		#endif
		
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE2);
		
		ent.attack_finished = ent.client_time + 1.4;
	}
}

void Hyperblaster_Init()
{
	weapon_t *wep = memalloc(sizeof(weapon_t));
	WeaponList[WEP_HYPERBLASTER] = wep;
	wep->netname = "Hyperblaster";
	wep->v_model = "models/weapons/v_hyperb/tris";
	wep->w_model = "models/weapons/g_hyperb/tris";
	wep->h_model = "w_hyperblaster";
	wep->icon = "pics/w_hyperblaster";
	wep->frame_func = Hyperblaster_Frame;
	wep->draw_time = 0.7;
	wep->ammo_pool = AMMO_CELLS;
	wep->ammo_warn = 25;
	wep->ammo_min = 1;
	
	int i;
	for(i = 1; i <= 6; i++)
	{
		precache_sound(sprintf("weapons/machgf%ib", i));
	}
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_DRAW1] = anim;
	int i;
	for(i = 0; i <= 5; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Hyperblaster_Idle;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_PUTAWAY1] = anim;
	int i;
	for(i = 50; i <= 53; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Swap;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_IDLE1] = anim;
	anim->loop = TRUE;
	int i;
	for(i = 21; i <= 49; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	
	
	// fire start
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE1] = anim;
	int i;
	for(i = 6; i <= 11; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, Hyperblaster_Fire, __NULL__);
	}
	anim->func_end = Hyperblaster_Spin;
	
	// fire end
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE2] = anim;
	for(i = 12; i <= 20; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Hyperblaster_Idle;
}























