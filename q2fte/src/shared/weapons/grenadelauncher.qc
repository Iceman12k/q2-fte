



void GrenadeLauncher_Frame(entity ent)
{
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (input_buttons & BUTTON_FIRE)
	{
		if (ent.ammo_inventory[AMMO_GRENADES] < (WeaponList[WEP_GRENADELAUNCHER])->ammo_min)
		{
			Weapon_Generic_OutofAmmo(ent);
			return;
		}
		
		ent.ammo_inventory[AMMO_GRENADES]--;
		ent.attack_finished = ent.client_time + 1.3;
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
		
		#ifdef SSQC
		sound(ent, CHAN_WEAPON, "weapons/grenlf1a", 1, ATTN_NORM);
		#endif
		#ifdef CSQC
		if (prediction_playeffects)
		{
			localsound("weapons/grenlf1a", CHAN_WEAPONSHOOT1, 1);
		}
		#endif
	}
}



void GrenadeLauncher_Init()
{
	int i;
	weapon_t *wep = memalloc(sizeof(weapon_t));
	WeaponList[WEP_GRENADELAUNCHER] = wep;
	wep->netname = "Grenade Launcher";
	wep->v_model = "models/weapons/v_launch/tris";
	wep->w_model = "models/weapons/g_launch/tris";
	wep->h_model = "w_glauncher";
	wep->icon = "pics/w_glauncher";
	wep->frame_func = GrenadeLauncher_Frame;
	wep->draw_time = 0.7;
	wep->ammo_pool = AMMO_GRENADES;
	wep->ammo_warn = 5;
	wep->ammo_min = 1;
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_DRAW1] = anim;
	for(i = 0; i <= 5; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_PUTAWAY1] = anim;
	for(i = 61; i <= 65; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Swap;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_IDLE1] = anim;
	anim->loop = TRUE;
	for(i = 18; i <= 60; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE1] = anim;
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 7, 10, __NULL__, "weapons/grenlr1b");
	for(i = 8; i <= 17; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
}























