



void Railgun_Frame(entity ent)
{
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (input_buttons & BUTTON_FIRE)
	{
		if (ent.ammo_inventory[AMMO_SLUGS] < (WeaponList[WEP_RAILGUN])->ammo_min)
		{
			Weapon_Generic_OutofAmmo(ent);
			return;
		}
		
		ent.attack_finished = ent.client_time + 1.6;
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
	}
}

void Railgun_Fire(entity ent)
{
	ent.ammo_inventory[AMMO_SLUGS]--;
	
	#ifdef SSQC
	sound(ent, CHAN_WEAPON, "weapons/railgf1a", 1, ATTN_NORM);
	#endif
	#ifdef CSQC
	if (prediction_playeffects)
	{
		localsound("weapons/railgf1a", CHAN_WEAPONSHOOT1, 1);
	}
	#endif
	
	ent.viewkick_origin[1] = -3;
    ent.viewkick_angles[0] = -3;
}


void Railgun_Init()
{
	int i;
	weapon_t *wep = memalloc(sizeof(weapon_t));
	WeaponList[WEP_RAILGUN] = wep;
	wep->netname = "Railgun";
	wep->v_model = "models/weapons/v_rail/tris";
	wep->w_model = "models/weapons/g_rail/tris";
	wep->h_model = "w_railgun";
	wep->icon = "pics/w_railgun";
	wep->frame_func = Railgun_Frame;
	wep->draw_time = 0.6;
	wep->ammo_pool = AMMO_SLUGS;
	wep->ammo_warn = 5;
	wep->ammo_min = 1;
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_DRAW1] = anim;
	for(i = 0; i <= 3; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_PUTAWAY1] = anim;
	for(i = 57; i <= 61; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Swap;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_IDLE1] = anim;
	anim->loop = TRUE;
	for(i = 19; i <= 56; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE1] = anim;
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 3, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 4, 10, Railgun_Fire, __NULL__);
	for(i = 5; i <= 18; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
}























