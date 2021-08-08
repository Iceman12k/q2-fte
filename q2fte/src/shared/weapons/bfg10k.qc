



void BFG_Frame(entity ent)
{
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (input_buttons & BUTTON_FIRE)
	{
		if (ent.ammo_inventory[AMMO_CELLS] < (WeaponList[WEP_BFG10K])->ammo_min)
		{
			Weapon_Generic_OutofAmmo(ent);
			return;
		}
		
		ent.attack_finished = ent.client_time + 2.7;
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
		
		#ifdef SSQC
		sound(ent, CHAN_WEAPON, "weapons/bfg__f1y", 1, ATTN_NORM);
		#endif
		#ifdef CSQC
		if (prediction_playeffects)
		{
			localsound("weapons/bfg__f1y", CHAN_WEAPONSHOOT1, 1);
		}
		#endif
	}
}

void BFG_Fire(entity ent)
{
	ent.ammo_inventory[AMMO_CELLS] -= 50;
}


void BFG_Init()
{
	int i;
	weapon_t *wep = memalloc(sizeof(weapon_t));
	WeaponList[WEP_BFG10K] = wep;
	wep->netname = "BFG10k";
	wep->v_model = "models/weapons/v_bfg/tris";
	wep->w_model = "models/weapons/g_bfg/tris";
	wep->h_model = "w_bfg";
	wep->icon = "pics/w_bfg";
	wep->frame_func = BFG_Frame;
	wep->draw_time = 1;
	wep->ammo_pool = AMMO_CELLS;
	wep->ammo_warn = 99;
	wep->ammo_min = 50;
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_DRAW1] = anim;
	for(i = 0; i <= 8; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_PUTAWAY1] = anim;
	for(i = 55; i <= 58; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Swap;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_IDLE1] = anim;
	anim->loop = TRUE;
	for(i = 32; i <= 54; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE1] = anim;
	for(i = 9; i <= 16; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 17, BFG_Fire, __NULL__);
	for(i = 18; i <= 31; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
}























