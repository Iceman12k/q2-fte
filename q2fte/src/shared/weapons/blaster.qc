

#ifdef SSQC
void Plasma_Touch()
{
	if (other.takedamage == DMG_TAKE_PLAYER)
	{
		PL_TakeDamage(self.origin, other, self, self.owner, 15, 1, 0, 0);
	}
	
	pointparticles(EFFECT_EXPLOSION_BLASTER, self.origin, trace_plane_normal);
	remove(self);
}

void Plasma_Physics()
{
	traceline(self.origin, self.origin + self.velocity * frametime, MOVE_NORMAL, self);
	self.origin = trace_endpos;
	
	if (trace_fraction < 1)
	{
		entity oself = self;
		self = trace_ent;
		other = oself;
		if (self.touch)
			self.touch();
		
		self = oself;
		other = trace_ent;
		if (self.touch)
			self.touch();
		
		self = oself;
	}
}

entity Plasma_Fire()
{
	entity mis = spawn();
	setmodel(mis, "models/objects/laser/tris");
	setsize(mis, '0 0 0', '0 0 0');
	mis.solid = SOLID_BBOX;
	mis.modelflags = MF_TRACER;
	mis.customphysics = Plasma_Physics;
	mis.touch = Plasma_Touch;
	mis.SendEntity = Proj_SendEntity;
	
	//sound(mis, CHAN_VOICE, "weapons/rockfly", 1, ATTN_IDLE, 100, SOUNDFLAG_FOLLOW, 0);
	return mis;
}
#endif



void Blaster_Frame(entity ent)
{
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (input_buttons & BUTTON_FIRE)
	{
		ent.attack_finished = ent.client_time + 0.5;
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
		
		ent.viewkick_origin[1] -= 2;
		ent.viewkick_angles[0] -= 1;
		
		#ifdef SSQC
		sound(ent, CHAN_WEAPON, "weapons/blastf1a", 1, ATTN_NORM);
		
		makevectors(ent.v_angle);
		entity mis = Plasma_Fire();
		mis.owner = self;
		mis.velocity = v_forward * 1000;
		mis.angles = [-ent.v_angle_x, ent.v_angle_y, ent.v_angle_z];
		setorigin(mis, PL_GetBarrelPos(ent) + (v_forward * 8));
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























