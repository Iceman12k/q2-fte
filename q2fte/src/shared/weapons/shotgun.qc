



void Shotgun_Frame(entity ent)
{
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (input_buttons & BUTTON_FIRE)
	{
		if (ent.ammo_inventory[AMMO_SHELLS] < (WeaponList[WEP_SHOTGUN])->ammo_min)
		{
			Weapon_Generic_OutofAmmo(ent);
			return;
		}
		
		ent.ammo_inventory[AMMO_SHELLS]--;
		ent.attack_finished = ent.client_time + 1.2;
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
		
		#ifdef SSQC
		sound(ent, CHAN_WEAPON, "weapons/shotgf1b", 1, ATTN_NORM);
		#endif
		#ifdef CSQC
		if (prediction_playeffects)
		{
			localsound("weapons/shotgf1b", CHAN_WEAPONSHOOT1, 1);
		}
		#endif
		
		ent.viewkick_origin[1] = -2;
		ent.viewkick_angles[0] = -2;
	}
}



void Shotgun_Init()
{
	weapon_t *wep = memalloc(sizeof(weapon_t));
	WeaponList[WEP_SHOTGUN] = wep;
	wep->netname = "Shotgun";
	wep->v_model = "models/weapons/v_shotg/tris";
	wep->w_model = "models/weapons/g_shotg/tris";
	wep->h_model = "w_shotgun";
	wep->icon = "pics/w_shotgun";
	wep->frame_func = Shotgun_Frame;
	wep->draw_time = 0.8;
	wep->ammo_pool = AMMO_SHELLS;
	wep->ammo_warn = 5;
	wep->ammo_min = 1;
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_DRAW1] = anim;
	int i;
	for(i = 0; i <= 7; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_PUTAWAY1] = anim;
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 37, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 38, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 39, 10, __NULL__, __NULL__);
	anim->func_end = Weapon_Swap;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_IDLE1] = anim;
	anim->loop = TRUE;
	int i;
	for(i = 19; i <= 36; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE1] = anim;
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 8, 10, __NULL__, "weapons/shotgr1b");
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 9, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 10, 10, __NULL__, __NULL__);
	int i;
	for(i = 11; i <= 18; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
}























