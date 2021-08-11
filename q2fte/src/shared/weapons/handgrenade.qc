



void HandGrenade_Frame(entity ent)
{
	if (ent.wep_firemode == 1)
	{
		if (ent.client_time >= ent.attack_finished)
		{
			ent.wep_firemode = 0;
		}
		else if (!(input_buttons & BUTTON_FIRE))
		{
			Weapon_StartAnimation(ent, WEP_ANIM_FIRE2);
			ent.wep_firemode = 0;
			
			ent.attack_finished = ent.client_time + 1;
			
			#ifdef SSQC
			sound(ent, CHAN_WEAPON, "weapons/hgrent1a", 1, ATTN_NORM);
			#endif
			#ifdef CSQC
			if (prediction_playeffects)
			{
				localsound("weapons/hgrent1a", CHAN_WEAPONSHOOT1, 1);
			}
			#endif
		}
	}
	else if ((input_buttons & BUTTON_FIRE) && ent.wep_firemode == 0)
	{
		if (ent.client_time < ent.attack_finished)
			return;
		
		
		if (ent.ammo_inventory[AMMO_GRENADES] < (WeaponList[WEP_HANDGRENADE])->ammo_min)
		{
			Weapon_Generic_OutofAmmo(ent);
			return;
		}
		
		ent.wep_firemode = 2;
		ent.ammo_inventory[AMMO_GRENADES]--;
		ent.attack_finished = ent.client_time + 10;
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
		
		#ifdef SSQC
		sound(ent, CHAN_WEAPON, "weapons/hgrena1b", 1, ATTN_NORM);
		#endif
		#ifdef CSQC
		if (prediction_playeffects)
		{
			localsound("weapons/hgrena1b", CHAN_WEAPONSHOOT1, 1);
		}
		#endif
	}
}

void HandGrenade_PrepThrow(entity ent)
{
	ent.wep_firemode = 1;
}



void HandGrenade_Init()
{
	int i;
	weapon_t *wep = memalloc(sizeof(weapon_t));
	WeaponList[WEP_HANDGRENADE] = wep;
	wep->netname = "Hand Grenades";
	wep->v_model = "models/weapons/v_handgr/tris";
	wep->w_model = "models/weapons/v_handgr/tris";
	wep->h_model = "a_grenades";
	wep->icon = "pics/w_hgrenade";
	wep->frame_func = HandGrenade_Frame;
	wep->draw_time = 0.4;
	wep->ammo_pool = AMMO_GRENADES;
	wep->ammo_warn = 5;
	wep->ammo_min = 1;
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_DRAW1] = anim;
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 0, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 1, 10, __NULL__, __NULL__);
	anim->func_end = Weapon_Generic_Idle;
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_PUTAWAY1] = anim;
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 1, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 0, 10, __NULL__, __NULL__);
	anim->func_end = Weapon_Swap;
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_IDLE1] = anim;
	anim->loop = TRUE;
	for(i = 16; i <= 48; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE1] = anim;
	for(i = 2; i <= 9; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 10, 10, HandGrenade_PrepThrow, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 10, 0.001, __NULL__, __NULL__);
	anim->func_end = Weapon_Generic_Idle;
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE2] = anim;
	for(i = 11; i <= 15; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 15, 2, __NULL__, __NULL__);
	anim->func_end = Weapon_Generic_Idle;
}























