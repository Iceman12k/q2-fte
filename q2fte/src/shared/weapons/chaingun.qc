



void Chaingun_Frame(entity ent, float move_time)
{
	if (ent.wep_animation == WEP_ANIM_FIRE1 || ent.wep_animation == WEP_ANIM_FIRE2)
	{
		int shoot_bullet = FALSE;
		int spd = 2;
		if (ent.wep_animation == WEP_ANIM_FIRE2)
			spd = 4;
		
		float next_fnum = (ent.wep_framenum + move_time * 10);
		if (ceil(ent.wep_framenum*spd) % 2 == 0 && ceil(next_fnum*spd) % 2 == 1)
			shoot_bullet = TRUE;
		
		if (ent.ammo_inventory[AMMO_BULLETS] < (WeaponList[WEP_CHAINGUN])->ammo_min)
			shoot_bullet = FALSE;
		
		if (shoot_bullet)
		{
			string snd = sprintf("weapons/machgf%gb", ceil(random() * 5));
			
			ent.wep_firemode++;
			if (ent.wep_firemode > 2)
				ent.wep_firemode = 0;
			
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
			for (i = 0; i < 3; i++)
			{
				ent.viewkick_origin[i] = PL_PRandom_C(ent.client_time + i) * 0.35;
				ent.viewkick_angles[i] = PL_PRandom_C(ent.client_time + i) * 0.7;
			}
			
			ent.ammo_inventory[AMMO_BULLETS]--;
		}
	}
	
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (ent.wep_animation == WEP_ANIM_IDLE1)
	{
		if (input_buttons & BUTTON_FIRE)
		{
			#ifdef SSQC
			sound(ent, CHAN_ITEM, "weapons/chngnl1a", 0.7, ATTN_IDLE);
			sound(ent, CHAN_WEAPON, "weapons/chngnu1a", 1, ATTN_IDLE);
			#endif
			#ifdef CSQC
			if (prediction_playeffects)
			{
				localsound("weapons/chngnu1a", CHAN_WEAPON, 1);
			}
			#endif
			
			Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
			ent.attack_finished = ent.client_time + 1;
		}
	}
}

void Chaingun_Idle(entity ent)
{
	if (ent.ammo_inventory[AMMO_BULLETS] < (WeaponList[WEP_HYPERBLASTER])->ammo_min)
	{
		Weapon_Generic_OutofAmmo(ent);
	}
	else
	{
		Weapon_Generic_Idle(ent);
	}
}

void Chaingun_Spin(entity ent)
{
	if ((input_buttons & BUTTON_FIRE && ent.weapon == ent.weapon_wanted) && (ent.ammo_inventory[AMMO_BULLETS] >= (WeaponList[WEP_CHAINGUN])->ammo_min))
	{
		if (ent.wep_animation != WEP_ANIM_FIRE2)
			Weapon_StartAnimation(ent, WEP_ANIM_FIRE2);
		
		#ifdef SSQC
		sound(ent, CHAN_ITEM, "weapons/chngnl1a", 0.7, ATTN_IDLE);
		#endif
		
		ent.attack_finished = ent.client_time + 1;
	}
	else if (ent.wep_animation != WEP_ANIM_FIRE3)
	{
		#ifdef SSQC
		if (ent.wep_animation == WEP_ANIM_FIRE2)
			sound(ent, CHAN_ITEM, "weapons/chngnd1a", 1, ATTN_IDLE);
		#endif
		
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE3);
		
		ent.attack_finished = ent.client_time + 1.4;
	}
}

void Chaingun_Init()
{
	weapon_t *wep = memalloc(sizeof(weapon_t));
	WeaponList[WEP_CHAINGUN] = wep;
	wep->netname = "Chaingun";
	wep->v_model = "models/weapons/v_chain/tris";
	wep->w_model = "models/weapons/g_chain/tris";
	wep->h_model = "w_chaingun";
	wep->icon = "pics/w_chaingun";
	wep->frame_func = Chaingun_Frame;
	wep->draw_time = 0.6;
	wep->ammo_pool = AMMO_BULLETS;
	wep->ammo_warn = 50;
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
	anim->func_end = Chaingun_Idle;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_PUTAWAY1] = anim;
	int i;
	for(i = 62; i <= 64; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Swap;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_IDLE1] = anim;
	anim->loop = TRUE;
	int i;
	for(i = 32; i <= 39; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 39, 1, __NULL__, __NULL__);
	for(i = 40; i <= 43; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 43, 0.4, __NULL__, __NULL__);
	for(i = 44; i <= 51; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 51, 1, __NULL__, __NULL__);
	for(i = 52; i <= 61; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	
	
	// fire start
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE1] = anim;
	int i;
	for(i = 5; i <= 14; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Chaingun_Spin;
	
	// fire spin loop
	animstate_t *anim = memalloc(sizeof(animstate_t));
	anim->loop = TRUE;
	wep->animations[WEP_ANIM_FIRE2] = anim;
	for(i = 15; i <= 21; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Chaingun_Spin;
	
	// fire end
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE3] = anim;
	for(i = 22; i <= 31; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Chaingun_Idle;
}























