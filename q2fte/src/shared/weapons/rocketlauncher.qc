

#ifdef SSQC
void Rocket_Touch()
{
	if (other.takedamage == DMG_TAKE_PLAYER)
	{
		PL_TakeDamage(self.origin, other, self, self.owner, 110, 140, 0, 0);
	}
	
	CB_RadiusDamage(self, self.owner, self.origin, 120, 120, 160, 0, other);
	
	self.origin += trace_plane_normal * 8;
	pointparticles(EFFECT_EXPLOSION_ROCKET, self.origin);
	
	sound(self, CHAN_VOICE, "", 1, ATTN_IDLE);
	remove(self);
}

void Rocket_Physics()
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

entity Rocket_Fire()
{
	entity mis = spawn();
	setmodel(mis, "models/objects/rocket/tris");
	setsize(mis, '0 0 0', '0 0 0');
	mis.solid = SOLID_BBOX;
	mis.modelflags = MF_ROCKET;
	mis.customphysics = Rocket_Physics;
	mis.touch = Rocket_Touch;
	mis.SendEntity = Proj_SendEntity;
	mis.noise = "weapons/rockfly";
	
	//sound(mis, CHAN_VOICE, "weapons/rockfly", 1, ATTN_IDLE, 100, SOUNDFLAG_FOLLOW, 0);
	return mis;
}
#endif


void RocketLauncher_Frame(entity ent)
{
	if (ent.client_time < ent.attack_finished)
		return;
	
	if (input_buttons & BUTTON_FIRE)
	{
		if (ent.ammo_inventory[AMMO_ROCKETS] < (WeaponList[WEP_ROCKETLAUNCHER])->ammo_min)
		{
			Weapon_Generic_OutofAmmo(ent);
			return;
		}
		
		ent.ammo_inventory[AMMO_ROCKETS]--;
		ent.attack_finished = ent.client_time + 1;
		Weapon_StartAnimation(ent, WEP_ANIM_FIRE1);
		
		#ifdef SSQC
		sound(ent, CHAN_WEAPON, "weapons/rocklf1a", 1, ATTN_NORM);
		
		makevectors(ent.v_angle);
		entity mis = Rocket_Fire();
		mis.owner = self;
		mis.velocity = v_forward * 650;
		mis.angles = [-ent.v_angle_x, ent.v_angle_y, ent.v_angle_z];
		setorigin(mis, PL_GetBarrelPos(ent) + (v_forward * 8));
		
		#endif
		#ifdef CSQC
		if (prediction_playeffects)
		{
			localsound("weapons/rocklf1a", CHAN_WEAPONSHOOT1, 1);
		}
		#endif
		
		ent.viewkick_origin[1] = -2;
		ent.viewkick_angles[0] = -1;
	}
}



void RocketLauncher_Init()
{
	int i;
	weapon_t *wep = memalloc(sizeof(weapon_t));
	WeaponList[WEP_ROCKETLAUNCHER] = wep;
	wep->netname = "Rocket Launcher";
	wep->v_model = "models/weapons/v_rocket/tris";
	wep->w_model = "models/weapons/g_rocket/tris";
	wep->h_model = "w_rlauncher";
	wep->icon = "pics/w_rlauncher";
	wep->frame_func = RocketLauncher_Frame;
	wep->draw_time = 0.6;
	wep->ammo_pool = AMMO_ROCKETS;
	wep->ammo_warn = 5;
	wep->ammo_min = 1;
	
	precache_model("models/objects/rocket/tris");
	precache_sound("weapons/rockfly");
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_DRAW1] = anim;
	for(i = 0; i <= 4; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_PUTAWAY1] = anim;
	for(i = 51; i <= 54; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Swap;
	
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_IDLE1] = anim;
	anim->loop = TRUE;
	for(i = 13; i <= 50; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	
	
	animstate_t *anim = memalloc(sizeof(animstate_t));
	wep->animations[WEP_ANIM_FIRE1] = anim;
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 5, 10, __NULL__, "weapons/rocklr1b");
	for(i = 6; i <= 12; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	anim->func_end = Weapon_Generic_Idle;
}























