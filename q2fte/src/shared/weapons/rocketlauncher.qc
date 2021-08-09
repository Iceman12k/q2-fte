



void RocketLauncher_Frame(entity ent)
{
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (input_buttons & BUTTON_FIRE)
	{
		if (ent.ammo_inventory[AMMO_ROCKETS] < (WeaponList[WEP_ROCKETLAUNCHER])->ammo_min)
		{
			Weapon_Generic_OutofAmmo(ent);
			return;
		}
		
		ent.ammo_inventory[AMMO_ROCKETS]--;
		ent.attack_finished = ent.client_time + 1;
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
		
		#ifdef SSQC
		sound(ent, CHAN_WEAPON, "weapons/rocklf1a", 1, ATTN_NORM);
		#endif
		#ifdef CSQC
		if (prediction_playeffects)
		{
			localsound("weapons/rocklf1a", CHAN_WEAPONSHOOT1, 1);
		}
		#endif
		
		ent.viewkick_origin[1] = -2;
		ent.viewkick_angles[0] = -1;
	}
}



void RocketLauncher_Init()
{
	int i;
	weapon_t *wep = memalloc(sizeof(weapon_t));
	WeaponList[WEP_ROCKETLAUNCHER] = wep;
	wep->netname = "Rocket Launcher";
	wep->v_model = "models/weapons/v_rocket/tris";
	wep->w_model = "models/weapons/g_rocket/tris";
	wep->h_model = "w_rlauncher";
	wep->icon = "pics/w_rlauncher";
	wep->frame_func = RocketLauncher_Frame;
	wep->draw_time = 0.6;
	wep->ammo_pool = AMMO_ROCKETS;
	wep->ammo_warn = 5;
	wep->ammo_min = 1;
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_DRAW1] = anim;
	for(i = 0; i <= 4; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_PUTAWAY1] = anim;
	for(i = 51; i <= 54; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Swap;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_IDLE1] = anim;
	anim->loop = TRUE;
	for(i = 13; i <= 50; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE1] = anim;
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 5, 10, __NULL__, "weapons/rocklr1b");
	for(i = 6; i <= 12; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
}























