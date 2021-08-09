



void Blaster_Frame(entity ent)
{
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (input_buttons & BUTTON_FIRE)
	{
		ent.attack_finished = ent.client_time + 0.5;
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
		
		ent.viewkick_angles[0] -= 2;
		
		#ifdef SSQC
		sound(ent, CHAN_WEAPON, "weapons/blastf1a", 1, ATTN_NORM);
		#endif
		#ifdef CSQC
		if (prediction_playeffects)
		{
			localsound("weapons/blastf1a", CHAN_WEAPON, 1);
		}
		#endif
	}
}



void Blaster_Init()
{
	weapon_t *blaster = memalloc(sizeof(weapon_t));
	WeaponList[WEP_BLASTER] = blaster;
	blaster->netname = "Blaster";
	blaster->v_model = "models/weapons/v_blast/tris";
	blaster->w_model = "models/weapons/g_blast/tris";
	blaster->h_model = "w_blaster";
	blaster->icon = "pics/w_blaster";
	blaster->frame_func = Blaster_Frame;
	blaster->draw_time = 0.5;
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	blaster->animations[WEP_ANIM_DRAW1] = anim;
	int i;
	for(i = 0; i <= 4; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	blaster->animations[WEP_ANIM_PUTAWAY1] = anim;
	int i;
	for(i = 53; i <= 55; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Swap;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	blaster->animations[WEP_ANIM_IDLE1] = anim;
	anim->loop = TRUE;
	int i;
	for(i = 9; i <= 52; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	blaster->animations[WEP_ANIM_FIRE1] = anim;
	anim->loop = FALSE;
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 5, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 6, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 7, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 8, 10, __NULL__, __NULL__);
	anim->func_end = Weapon_Generic_Idle;
}























