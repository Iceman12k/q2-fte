

#ifdef SSQC
void HGrenade_Explode()
{
	CB_RadiusDamage(self, self.owner, self.origin, 165, 125, 160, 0, other);
	
	pointparticles(EFFECT_EXPLOSION_GRENADE, self.origin);
	
	sound(self, CHAN_VOICE, "", 1, ATTN_IDLE);
	remove(self);
}

void HGrenade_Touch()
{
	if (other.takedamage == DMG_TAKE_NOT)
	{
		if (random() > 0.5)
			sound(self, CHAN_VOICE, "weapons/hgrenb1a", 1, ATTN_NORM);
		else
			sound(self, CHAN_VOICE, "weapons/hgrenb2a", 1, ATTN_NORM);
		
		return;
	}
	
	
	if (other.takedamage == DMG_TAKE_PLAYER)
	{
		PL_TakeDamage(self.origin, other, self, self.owner, 120, 140, 0, 0);
		HGrenade_Explode();
	}
}

void HGrenade_Think()
{
	if (time >= self.think_time)
	{
		other = world;
		HGrenade_Explode();
		return;
	}
	
	
	self.SendFlags = 1;
	self.nextthink = time + 1/self.updaterate;
	self.think = HGrenade_Think;
}

entity HGrenade_Fire()
{
	entity mis = spawn();
	setmodel(mis, "models/objects/grenade2/tris");
	setsize(mis, '0 0 0', '0 0 0');
	mis.solid = SOLID_BBOX;
	mis.movetype = MOVETYPE_BOUNCE;
	mis.modelflags = MF_GRENADE;
	mis.SendEntity = EntGeneric_SendEntity;
	mis.avelocity = '300 300 300';
	mis.updaterate = 80;
	mis.touch = HGrenade_Touch;
	
	mis.think_time = time + 3;
	
	mis.nextthink = time + 1/mis.updaterate;
	mis.think = HGrenade_Think;
	
	return mis;
}
#endif

void HandGrenade_Throw(entity ent)
{
	#ifdef SSQC
	makevectors(input_angles);
	entity mis = HGrenade_Fire();
	mis.owner = self;
	mis.angles = [-ent.v_angle_x, ent.v_angle_y, ent.v_angle_z];
	setorigin(mis, PL_GetBarrelPos(ent) + (v_forward * 8));
	
	float timer = (ent.attack_finished - ent.client_time);
	float speed = 350 + (3.0 - timer) * ((800 - 350) / 3.0);
	mis.velocity = v_forward * speed;
	mis.velocity += ent.velocity * 0.2;
	mis.bouncefactor = 0.3;
	
	mis.think_time = ent.attack_finished;
	
	float scale = 200 + crandom() * 10;
	mis.velocity += scale * v_up;
	scale = crandom() * 10;
	mis.velocity += scale * v_right;
	#endif
	
	ent.wep_firemode = 0;
	ent.attack_finished = ent.client_time + 1;
}

void HandGrenade_Frame(entity ent)
{
	if (ent.wep_firemode == 1)
	{
		if (ent.client_time >= ent.attack_finished)
		{
			ent.wep_firemode = 0;
			
			#ifdef SSQC
			PL_TakeDamage(ent.origin, ent, ent, ent, 160, 160, 0, 0);
			CB_RadiusDamage(ent, ent, ent.origin, 165, 125, 160, 0, ent);
			pointparticles(EFFECT_EXPLOSION_GRENADE, PL_GetBarrelPos(ent));
			#endif
		}
		else if (!(input_buttons & BUTTON_FIRE))
		{
			ent.wep_firemode = 2;
			Weapon_StartAnimation(ent, WEP_ANIM_FIRE2);
			
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
		ent.attack_finished = ent.client_time + 3;
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
	ent.attack_finished = ent.client_time + 3;
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
	
	precache_sound("weapons/hgrenb1a");
	precache_sound("weapons/hgrenb2a");
	
	
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
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 11, 10, __NULL__, __NULL__);
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 12, 10, HandGrenade_Throw, __NULL__);
	for(i = 13; i <= 15; i++)
	{
		Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), i, 10, __NULL__, __NULL__);
	}
	Anim_AddFrame(&(anim->frame_list_head), &(anim->frame_list_tail), 15, 2, __NULL__, __NULL__);
	anim->func_end = Weapon_Generic_Idle;
}























