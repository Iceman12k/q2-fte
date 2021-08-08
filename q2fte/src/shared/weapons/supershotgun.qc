



void SuperShotgun_Frame(entity ent)
{
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (input_buttons & BUTTON_FIRE)
	{
		if (ent.ammo_inventory[AMMO_SHELLS] < (WeaponList[WEP_SUPERSHOTGUN])->ammo_min)
		{
			Weapon_Generic_OutofAmmo(ent);
			return;
		}
		
		ent.ammo_inventory[AMMO_SHELLS] -= 2;
		ent.attack_finished = ent.client_time + 1.2;
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
		
		#ifdef SSQC
		sound(ent, CHAN_WEAPON, "weapons/sshotf1b", 1, ATTN_NORM);
		#endif
		#ifdef CSQC
		if (prediction_playeffects)
		{
			localsound("weapons/sshotf1b", CHAN_WEAPONSHOOT1, 1);
		}
		#endif
	}
}



void SuperShotgun_Init()
{
	weapon_t *wep = memalloc(sizeof(weapon_t));
	WeaponList[WEP_SUPERSHOTGUN] = wep;
	wep->netname = "Super Shotgun";
	wep->v_model = "models/weapons/v_shotg2/tris";
	wep->w_model = "models/weapons/g_shotg2/tris";
	wep->h_model = "w_sshotgun";
	wep->icon = "pics/w_sshotgun";
	wep->frame_func = SuperShotgun_Frame;
	wep->draw_time = 0.8;
	wep->ammo_pool = AMMO_SHELLS;
	wep->ammo_warn = 8;
	wep->ammo_min = 2;
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_DRAW1] = anim;
	int i;
	for(i = 0; i <= 6; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_PUTAWAY1] = anim;
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 58, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 59, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 60, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 61, 10, __NULL__, __NULL__);
	anim->func_end = Weapon_Swap;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_IDLE1] = anim;
	anim->loop = TRUE;
	int i;
	for(i = 18; i <= 57; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE1] = anim;
	int i;
	for(i = 7; i <= 17; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
}























