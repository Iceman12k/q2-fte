



void Machinegun_Frame(entity ent)
{
	if ((ent.wep_animation == WEP_ANIM_FIRE1) && !(input_buttons & BUTTON_FIRE))
	{
		ent.flags |= FL_SHOOTRELEASED;
	}
	
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (input_buttons & BUTTON_FIRE && !(ent.flags & FL_SHOOTRELEASED))
	{
		if (ent.ammo_inventory[AMMO_BULLETS] < (WeaponList[WEP_MACHINEGUN])->ammo_min)
		{
			if (ent.wep_animation != WEP_ANIM_FIRE1)
				Weapon_Generic_OutofAmmo(ent);
			return;
		}
		
		ent.wep_firemode++;
		ent.ammo_inventory[AMMO_BULLETS] -= 1;
		ent.attack_finished = ent.client_time + 0.1;
		if (ent.wep_firemode >= 4)
			ent.wep_firemode = 0;
		
		if (ent.wep_animation != WEP_ANIM_FIRE1)
			Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
		
		string snd = sprintf("weapons/machgf%gb", ceil(random() * 5));
		
		#ifdef SSQC
		sound(ent, CHAN_WEAPON, snd, 1, ATTN_NORM);
		#endif
		#ifdef CSQC
		if (prediction_playeffects)
		{
			localsound(snd, CHAN_WEAPONSHOOT1 + ent.wep_firemode, 1);
		}
		#endif
		
		int i;
		for (i = 1 ; i < 3 ; i++) {
			ent.viewkick_origin[i] = crandom() * 0.35;
			ent.viewkick_angles[i] = crandom() * 0.7;
		}
		ent.viewkick_origin[0] = crandom() * 0.35;
	}
}

void Machinegun_Idle(entity ent)
{
	if (input_buttons & BUTTON_FIRE && (ent.ammo_inventory[AMMO_BULLETS] < (WeaponList[WEP_MACHINEGUN])->ammo_min))
	{
		Weapon_Generic_OutofAmmo(ent);
	}
	else
	{
		Weapon_Generic_Idle(ent);
	}
}



void Machinegun_Init()
{
	weapon_t *wep = memalloc(sizeof(weapon_t));
	WeaponList[WEP_MACHINEGUN] = wep;
	wep->netname = "Machinegun";
	wep->v_model = "models/weapons/v_machn/tris";
	wep->w_model = "models/weapons/g_machn/tris";
	wep->h_model = "w_machinegun";
	wep->icon = "pics/w_machinegun";
	wep->frame_func = Machinegun_Frame;
	wep->draw_time = 0.5;
	wep->ammo_pool = AMMO_BULLETS;
	wep->ammo_warn = 30;
	wep->ammo_min = 1;
	
	int i;
	for(i = 1; i <= 6; i++)
	{
		precache_sound(sprintf("weapons/machgf%ib", i));
	}
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_DRAW1] = anim;
	int i;
	for(i = 0; i <= 3; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Machinegun_Idle;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_PUTAWAY1] = anim;
	int i;
	for(i = 46; i <= 49; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Swap;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_IDLE1] = anim;
	anim->loop = TRUE;
	int i;
	for(i = 6; i <= 23; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 23, 1, __NULL__, __NULL__);
	for(i = 24; i <= 45; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE1] = anim;
	int i;
	for(i = 4; i <= 5; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
}























